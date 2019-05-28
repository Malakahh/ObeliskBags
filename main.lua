local addonName, ns = ...

-- bit of config
ns.CellSize = 37

---------------
-- Libraries --
---------------

local libStack = ObeliskFrameworkManager:GetLibrary("ObeliskCollectionsStack", 0)
if not libStack then
	error(ns.Debug:sprint(addonName .. className, "Failed to load ObeliskCollectionsStack"))
end

-----------
-- local --
-----------

local frame = CreateFrame("FRAME")
frame:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("BAG_UPDATE")

-- Make table of all inventory slots
local allInventorySlots = {}

local function CollectInventorySlots()
	do
		local bagNum
		for bagNum = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
			local maxNumSlots = GetContainerNumSlots(bagNum)
			local slotNum
			for slotNum = 1, maxNumSlots do
				local slot = ns.BagSlot:New(bagNum, slotNum)
				slot:SetSize(ns.CellSize, ns.CellSize)
				allInventorySlots[slot:GetIdentifier()] = slot
			end
		end
	end

	-- Stack to handle slots available to create new bags from.
	-- Anything in this stack is considered the inventory of the master bag.
	-- Start by putting all slots into master bag.
	-- Distribute later
	ns.InventorySlotPool = libStack()

	do
		local bagNum
		for bagNum = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
			local maxNumSlots = GetContainerNumSlots(bagNum)
			local slotNum
			for slotNum = 1, maxNumSlots do
				ns.InventorySlotPool:Push(allInventorySlots[ns.BagSlot:GetIdentifier(bagNum, slotNum)])
			end
		end
	end
end

function frame:PLAYER_ENTERING_WORLD()
	CollectInventorySlots()

	local masterBag = ns.BagFrame:New(true)
	masterBag.GridView:SetNumColumns(10)
	masterBag:Update()
end

function frame:BAG_UPDATE(bagId)
	local maxNumSlots = GetContainerNumSlots(bagId)
	local i
	for i = 1, maxNumSlots do
		local slot = allInventorySlots[ns.BagSlot:GetIdentifier(bagId, i)]

		if slot ~= nil then
			local itemId = GetContainerItemID(bagId, slot.ItemSlot:GetID())
			slot:SetItem(itemId)
		end
	end
end
