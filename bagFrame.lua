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

local function DefragBags()
	print("DefragBags called")

	local foundFreeSlot = false

	-- free slots
	for i = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
		local numberOfFreeSlots, bagType = GetContainerNumFreeSlots(i)
		if numberOfFreeSlots > 0 and bagType == 0 then
			foundFreeSlot = true
		end
	end

	if not foundFreeSlot then
		print(addonName .. ": Cannot perform defragmentation, no free regular bag slots")
		return
	end

	-- Gather old bag data
	local oldBagData = {}
	for i = #createdBags, 1, -1 do
		if not createdBags[i].IsMasterBag then
			oldBagData[i] = {
				numColumns = createdBags[i].GridView:GetNumColumns(),
				numSlots = createdBags[i].GridView:ItemCount()
			}
			createdBags[i]:DeleteBag()
		end
	end

	-- Remove oldB
	-- do
	-- 	local max = #createdBags
	-- 	for i = max, 1, -1 do
	-- 		print("Deleting " .. i .. "...")

	-- 		if not createdBags[i].IsMasterBag then
	-- 			createdBags[i]:DeleteBag()
	-- 		end
	-- 	end
	-- end


	for k,v in pairs(oldBagData) do
		ns.BagFrame.Spawn(v.numColumns, v.numSlots)
	end
end

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

	---------
	-- Layout

	instance.padding = 6
	instance.spacing = 6
	instance.btnHeight = 19

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

	-- Btn Close
	instance.BtnClose = CreateFrame("BUTTON", addonName .. "CloseButton", instance, "UIPanelCloseButtonNoScripts")
	instance.BtnClose:SetPoint("TOPRIGHT", 0, 0)
	instance.BtnClose:SetScript("OnClick", function(self, btn)
		instance:Close()
	end)

	-- gridView
	instance.GridView = libGridView(0, 0, "GridView", instance)
	instance.GridView:SetCellSize(ns.CellSize, ns.CellSize)
	instance.GridView:SetCellMargin(2,2)
	instance.GridView:SetPoint("TOPRIGHT", instance.BtnClose, "BOTTOMRIGHT", -instance.padding, 0)

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

	-- ConfigBtn
	instance.BtnConfig = CreateFrame("BUTTON", addonName .. "ConfigButton", instance, "UIPanelButtonTemplate")
	instance.BtnConfig:SetSize(25, instance.btnHeight)
	instance.BtnConfig.icon = instance.BtnConfig:CreateTexture(nil, "ARTWORK")
	instance.BtnConfig.icon:SetTexture("Interface\\Buttons\\UI-OptionsButton")
	instance.BtnConfig.icon:SetSize(12, 12)
	instance.BtnConfig.icon:SetPoint("TOPLEFT", instance.BtnConfig, "TOPLEFT", 6, -4)

	-- Master bag dependant layout
	if isMasterBag then
		-- Manually add to gridview to skip adding to available pool again
		for i = 1, ns.InventorySlotPool:Count() do
			instance.GridView:AddItem(ns.InventorySlotPool.items[i])
		end

		instance.BtnNewBag = CreateFrame("BUTTON", addonName .. "NewBagButton", instance, "UIPanelButtonTemplate")
		instance.BtnNewBag:SetSize(100, instance.btnHeight)
		instance.BtnNewBag:SetPoint("BOTTOMLEFT", instance, "BOTTOMLEFT", instance.padding, instance.padding)
		instance.BtnNewBag:SetText("New Bag")

		instance.BtnNewBag:SetScript("OnClick", function(btn)
			ns.BagSetupFrame:Show()
		end)

		instance.BtnConfig:SetPoint("LEFT", instance.BtnNewBag, "RIGHT", instance.spacing, 0)

		instance.BtnDefrag = CreateFrame("BUTTON", addonName .. "DefragButton", instance, "UIPanelButtonTemplate")
		instance.BtnDefrag:SetSize(100, instance.btnHeight)
		instance.BtnDefrag:SetText("Defrag")
		instance.BtnDefrag:SetPoint("LEFT", instance.BtnConfig, "RIGHT", instance.spacing, 0)
		instance.BtnDefrag:SetScript("OnClick", function(self, btn)
			DefragBags()
		end)

		instance.MoneyFrame = CreateFrame("FRAME", addonName .. "MoneyFrame", instance, "SmallMoneyFrameTemplate")
		instance.MoneyFrame:SetPoint("BOTTOMRIGHT", instance.padding, instance.padding * 1.5)

		ns.MasterBag = instance
	else
		instance.BtnDelete = CreateFrame("BUTTON", addonName .. "DeleteButton", instance, "UIPanelButtonTemplate")
		instance.BtnDelete:SetSize(100, instance.btnHeight)
		instance.BtnDelete:SetPoint("BOTTOMLEFT", instance, "BOTTOMLEFT", instance.padding, instance.padding)
		instance.BtnDelete:SetText("Delete bag")
		instance.BtnDelete:SetScript("OnClick", function(self, btn)
			instance:DeleteBag()
		end)

		instance.BtnConfig:SetPoint("LEFT", instance.BtnDelete, "RIGHT", instance.spacing, 0)
	end

	table.insert(createdBags, instance)
	instance.Id = ns.Util.Table.IndexOf(createdBags, instance)

	return instance
end

function ns.BagFrame.Spawn(numColumns, numSlots)
	local bag = ns.BagFrame:New(false)
	bag.GridView:SetNumColumns(numColumns)

	-- get slots
	local slots = {}
	for i = 1, numSlots, 1 do
		local slot = ns.InventorySlotPool:Pop()
		table.insert(slots, slot)
	end

	table.sort(slots, function (a, b)
		return a:GetIdentifier() < b:GetIdentifier()
	end)

	for i = 1, #slots do
		ns.MasterBag:RemoveSlot(slots[i])
	 	bag:AddSlot(slots[i])
	end

	-- Handle size of bag
	local gridWidth, gridHeight = bag.GridView:GetCalculatedGridSize()
	bag:SetSize(gridWidth, gridHeight)
	bag:Update()

	ns.MasterBag:Update()
end

function ns.BagFrame:DeleteBag()
	self:MergeBag(ns.MasterBag)
	ns.Util.Table.RemoveByVal(createdBags, self)
	ns.MasterBag:Update()
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

	self.GridView:SetWidth(gridWidth)
	self.GridView:SetHeight(gridHeight)

	local width = gridWidth + self.padding * 2
	local height = gridHeight + self.BtnClose:GetHeight() + self.padding + self.btnHeight
	if self.IsMasterBag then

	end

	self:SetWidth(width)
	self:SetHeight(height)

	self:Sort()
	self.GridView:Update()
end

function ns.BagFrame:Close()
	self:Hide()
	local flip = true

	for _,v in pairs(createdBags) do
		if v:IsVisible() then
			flip = false
			break
		end
	end

	if flip then
		isShown = false
	end
end

function ns.BagFrame:Open()
	self:Show()
	local flip = true

	for _,v in pairs(createdBags) do
		if not v:IsVisible() then
			flip = false
			break
		end
	end

	if flip then
		isShown = true
	end
end

function ns.BagFrame:ToggleBags()
	local shoudClose = isShown

	for k,v in pairs(createdBags) do
		if shoudClose then
			v:Close()
		else
			v:Open()
		end
	end
end

