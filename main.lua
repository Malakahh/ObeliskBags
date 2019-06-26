local addonName, ns = ...

OB_SV = OB_SV or {}

---------------
-- Libraries --
---------------

local libStack = ObeliskFrameworkManager:GetLibrary("ObeliskCollectionsStack", 0)
if not libStack then
	error(ns.Debug:sprint(addonName .. className, "Failed to load ObeliskCollectionsStack"))
end

local SavedVariablesManager = ObeliskFrameworkManager:GetLibrary("ObeliskSavedVariablesManager", 0)
if not SavedVariablesManager then
	error(ns.Debug:sprint(addonName .. className, "Failed to load ObeliskSavedVariablesManager"))
end

-----------
-- local --
-----------

local SV_BAGS_STR = "Bags"

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

local function SpawnBags()
	local SV_Bags = SavedVariablesManager.GetRegisteredTable(SV_BAGS_STR)
	if #SV_Bags > 0 then -- We have some bags saved, nice!
		local workingSet = ns.Util.Table.Copy(SV_Bags)
		local masterBagIdx = ns.Util.Table.IndexWhere(workingSet, function(k, v, ...) return v.IsMasterBag end)

		-- Start with master bag
		-- ns.BagFrame:New(workingSet[masterBagIdx])
		-- workingSet[masterBagIdx] = nil

		-- Remaining bags
		for k,v in pairs(workingSet) do
			ns.BagFrame:New(v)
		end
	else -- This is the first time, please be gentle
		local masterBagConfig = ns.Util.Table.Copy(ns.BagFrame.DefaultConfigTable)
		masterBagConfig.IsMasterBag = true
		local masterBag = ns.BagFrame:New(masterBagConfig)
		masterBag.NumColumns = 10
	end
end

function frame:PLAYER_ENTERING_WORLD()
	CollectInventorySlots()
	SavedVariablesManager.Init(OB_SV)
	SavedVariablesManager.CreateRegisteredTable(SV_BAGS_STR)
	SavedVariablesManager.Save()

	SpawnBags()

	--local masterBagConfig = ns.Util.Table.Copy(ns.BagFrame.DefaultConfigTable)
	--masterBagConfig.IsMasterBag = true
	--local masterBag = ns.BagFrame:New(masterBagConfig)
	--masterBag.GridView:SetNumColumns(10)

	local bagNum
	for bagNum = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
		self:BAG_UPDATE(bagNum)
	end

	ns.MasterBag:Update()
end

function frame:PLAYER_LEAVING_WORLD()
	SavedVariablesManager.Save()
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
