local addonName, ns = ...
local className = "BagFrame"

ns.BagFrame = {}

setmetatable(ns.BagFrame, {
	__call = function (self, ...)
		return self:New(...)
	end,
	__index = ns.BagFrame
})

---------------
-- Libraries --
---------------

local FrameworkClass = ObeliskFrameworkManager:GetLibrary("ObeliskFrameworkClass", 0)
if not FrameworkClass then
	error(ns.Debug:sprint(addonName .. className, "Failed to load ObeliskFrameworkClass"))
end

local libGridView = ObeliskFrameworkManager:GetLibrary("ObeliskGridView", 1)
if not libGridView then
	error(ns.Debug:sprint(addonName .. className, "Failed to load ObeliskGridView"))
end



-----------
-- local --
-----------


local isShown = true
local createdBags = {}

-----------
-- Class --
-----------

function ns.BagFrame:New(isMasterBag)
	if isMasterBag and ns.MasterBag then
		error(ns.Debug:sprint(addonName .. className, "Attempted to create multiple master bags"))
		return
	end

	local name = addonName .. className
	if isMasterBag then
		name = name .. "Master"
	end

	local instance = FrameworkClass(self, "FRAME", name, UIParent)
	instance.IsMasterBag = isMasterBag

	instance.padding = 6
	instance.spacing = 6

	-- frame
	instance:SetPoint("CENTER")
	instance:SetBackdrop({
		bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
		edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
		tile = true,
		tileSize = 16,
		edgeSize = 16,
		insets = { left = 4, right = 4, top = 4, bottom = 4}
	})
	instance:SetBackdropColor(0, 0, 0, 1)

	-- Title
	instance.Title = instance:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	instance.Title:SetPoint("TOPLEFT", instance.padding, -instance.padding)
	instance.Title:SetText("Title")

	-- gridView
	instance.GridView = libGridView(0, 0, "GridView", instance)
	instance.GridView:SetCellSize(ns.CellSize, ns.CellSize)
	instance.GridView:SetCellMargin(2,2)
	instance.GridView:SetPoint("TOPLEFT", instance.Title, "BOTTOMLEFT", 0, -instance.spacing)
	instance.GridView:SetPoint("BOTTOMRIGHT", -instance.padding, instance.padding)

	instance.GridView:ToggleDebug()

	-- frame movement
	instance:SetMovable(true)
	instance:SetClampedToScreen(true)

	instance:SetScript("OnMouseDown", function(self, btn)
		if btn == "LeftButton" and IsShiftKeyDown() then
			self:ClearAllPoints()
			self:StartMoving()
		end
	end)

	instance:SetScript("OnMouseUp", function(self, btn)
		self:StopMovingOrSizing()
	end)

	-- Master bag
	if isMasterBag then
		-- Manually add to gridview to skip adding to available pool again
		for i = 1, ns.InventorySlotPool:Count() do
			instance.GridView:AddItem(ns.InventorySlotPool.items[i])
		end

		instance.BtnNewBag = CreateFrame("Button", addonName .. "NewBagButton", instance, "UIPanelButtonTemplate")
		instance.BtnNewBag:SetSize(100, 19)
		instance.BtnNewBag:SetPoint("TOPRIGHT", instance, "TOPRIGHT", -instance.padding, instance.padding)
		instance.BtnNewBag:SetText("New Bag")

		instance.BtnNewBag:SetScript("OnClick", function(btn)
			ns.BagSetupFrame:Show()
		end)

		ns.MasterBag = instance
	else
		instance.BtnDelete = CreateFrame("Button", addonName .. "DeleteButton", instance, "UIPanelButtonTemplate")
		instance.BtnDelete:SetSize(100, 19)
		instance.BtnDelete:SetPoint("TOPRIGHT", instance, "TOPRIGHT", -instance.padding, instance.padding)
		instance.BtnDelete:SetText("Delete bag")

		instance.BtnDelete:SetScript("OnClick", function(btn)
			instance:MergeBag(ns.MasterBag)
			ns.MasterBag:Update()
		end)
	end

	table.insert(createdBags, instance)

	return instance
end

function ns.BagFrame:MergeBag(target)
	while #self.GridView.items > 0 do
		local slot = self.GridView.items[1]
		self:RemoveSlot(slot)
		target:AddSlot(slot)
	end

	self:Hide()
end

function ns.BagFrame:Sort()
	local compFunc = function(a, b) return a:GetIdentifier() < b:GetIdentifier() end
	self.GridView:Sort(compFunc)

	if self.IsMasterBag then
		table.sort(ns.InventorySlotPool.items, compFunc)
	end
end

function ns.BagFrame:AddSlot(slot)
	self.GridView:AddItem(slot)

	if self.IsMasterBag then
		ns.InventorySlotPool:Push(slot)
	end
end

function ns.BagFrame:RemoveSlot(slot)
	self.GridView:RemoveItem(slot)
end

function ns.BagFrame:Update()
	local gridWidth, gridHeight = self.GridView:GetCalculatedGridSize()

	if gridWidth == nil then
		error(ns.Debug:sprint(className, "Failed to calculate grid width"))
	end

	if gridHeight == nil then
		error(ns.Debug:sprint(className, "Failed to calculate grid height"))
	end

	gridWidth = gridWidth + self.padding * 2
	self:SetWidth(gridWidth)

	gridHeight = gridHeight + self.padding * 2 + self.Title:GetHeight() + self.spacing
	self:SetHeight(gridHeight)

	self:Sort()
	self.GridView:Update()
end

function ns.BagFrame:ToggleBags()
	for k,v in pairs(createdBags) do
		if isShown then
			v:Hide()
		else
			v:Show()
		end
	end

	isShown = not isShown
end


