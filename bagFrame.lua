local addonName, ns = ...
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
	error(ns.Debug:sprint(addonName .. "BagFrame", "Failed to load ObeliskFrameworkClass"))
end

local libGridView = ObeliskFrameworkManager:GetLibrary("ObeliskGridView", 1)
if not libGridView then
	error(ns.Debug:sprint(addonName .. "BagFrame", "Failed to load ObeliskGridView"))
end

-----------
-- local --
-----------

local cellSize = 24
local slots = {}

do
	local bagNum
	for bagNum = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
		local maxNumSlots = GetContainerNumSlots(bagNum)
		local slotNum
		for slotNum = 1, maxNumSlots do
			local slot = ns.BagSlot:New(bagNum, slotNum)
			slot:SetSize(cellSize, cellSize)
			slots[slot:GetIdentifier()] = slot
		end
	end
end

local frame = CreateFrame("FRAME")
frame:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
frame:RegisterEvent("BAG_UPDATE")

function frame:BAG_UPDATE(bagId)
	local maxNumSlots = GetContainerNumSlots(bagId)
	local i
	for i = 1, maxNumSlots do
		local slot = slots[ns.BagSlot:GetIdentifier(bagId, i)]

		if slot ~= nil then
			local itemId = GetContainerItemID(bagId, slot.ItemSlot:GetID())
			slot:SetItem(itemId)
		end
	end
end

-----------
-- Class --
-----------

function ns.BagFrame:New(isMasterBag)
	local instance = FrameworkClass(self, "FRAME", "ObeliskBagsBagFrame", UIParent)

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
	instance:SetClampedToScreen(true)
	instance:SetSize(200, 300)

	-- Title
	instance.Title = instance:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	instance.Title:SetPoint("TOPLEFT", instance.padding, -instance.padding)
	instance.Title:SetText("Title")

	-- gridView
	instance.GridView = libGridView(0, 0, "GridView", instance)
	instance.GridView:SetCellSize(cellSize, cellSize)
	instance.GridView:SetPoint("TOPLEFT", instance.Title, "BOTTOMLEFT", 0, -instance.spacing)
	instance.GridView:SetPoint("BOTTOMRIGHT", -instance.padding, instance.padding)

	instance.GridView:ToggleDebug()

	return instance
end

function ns.BagFrame:AddSlot(slot)
	self.GridView:AddItem(slot)
end

function ns.BagFrame:RemoveSlot(slot)
	self.GridView:RemoveItem(slot)
end

function ns.BagFrame:UpdateGridView()
	self.GridView:Update()
end

local masterBag = ns.BagFrame:New(true)
do
	local bagNum
	for bagNum = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
		local maxNumSlots = GetContainerNumSlots(bagNum)
		local slotNum
		for slotNum = 1, maxNumSlots do
			masterBag:AddSlot(slots[ns.BagSlot:GetIdentifier(bagNum, slotNum)])
		end
	end
end

masterBag:UpdateGridView()

function ns.BagFrame:ToggleBags()
	-- print("Hi")
	-- print(masterBag:GetName())
	if masterBag:IsShown() then
		masterBag:Hide()
	else
		masterBag:Show()
		--masterBag:OnShow()
	end
end


