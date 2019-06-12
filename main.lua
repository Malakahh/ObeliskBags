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
				allInventorySlots[slot:GetPhysicalIdentifier()] = slot
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
				ns.InventorySlotPool:Push(allInventorySlots[ns.BagSlot.EncodeSlotIdentifier(bagNum, slotNum)])
			end
		end
	end
end

function frame:PLAYER_ENTERING_WORLD()
	CollectInventorySlots()

	local masterBag = ns.BagFrame:New(true)
	masterBag.GridView:SetNumColumns(10)

	local bagNum
	for bagNum = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
		self:BAG_UPDATE(bagNum)
	end

	masterBag:Update()
end

function frame:BAG_UPDATE(bagId)
	local maxNumSlots = GetContainerNumSlots(bagId)
	local i
	for i = 1, maxNumSlots do
		local slot = allInventorySlots[ns.BagSlot.EncodeSlotIdentifier(bagId, i)]

		if slot ~= nil then
			local itemId = GetContainerItemID(bagId, slot.ItemSlot:GetID())
			slot:SetItem(itemId)
		end
	end
end

-- local CycleSort = ObeliskFrameworkManager:GetLibrary("ObeliskCycleSort", 0)
-- if not CycleSort then
-- 	error(ns.Debug:sprint(addonName .. className, "Failed to load ObeliskCycleSort"))
-- end

-- local funcs = {
-- 	Compare = function(arr, val1, val2)
-- 		if arr[val1] < arr[val2] then
-- 			return -1
-- 		elseif arr[val1] > arr[val2] then
-- 			return 1
-- 		else
-- 			return 0
-- 		end
-- 	end,
-- 	Swap = function(arr, val1, val2)
-- 		local temp = arr[val1]
-- 		arr[val1] = arr[val2]
-- 		arr[val2] = temp
-- 	end
-- }
-- local t = {2, 23, 4, 2, 123, 2, 5,6,7,8,3,5,43,2,1,0,1,-1,123,2}
-- do
-- 	local s = ""
-- 	for k,v in pairs(t) do
-- 		s = s .. " " .. v
-- 	end
-- 	print(s)
-- end
-- CycleSort.Sort(t, funcs)