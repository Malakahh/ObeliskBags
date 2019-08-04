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

-- Stacks to handle slots available to create new bags from.
-- Anything in this stack is considered the inventory of the master bag.
-- Start by putting all slots into master bag.
-- Distribute later
ns.SlotPools = {}
setmetatable(ns.SlotPools, {
	__index = function(t,k)
		if rawget(t, k) == nil then
			rawset(t, k, libStack())
		end
		
		return rawget(t, k)
	end
})

local SV_BAGS_STR = "Bags"

local frame = CreateFrame("FRAME")
frame:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("BAG_UPDATE")
frame:RegisterEvent("BANKFRAME_OPENED")
frame:RegisterEvent("BANKFRAME_CLOSED")
frame:RegisterEvent("PLAYERBANKSLOTS_CHANGED")

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

	do
		local bagNum
		for bagNum = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
			local maxNumSlots = GetContainerNumSlots(bagNum)
			local slotNum
			for slotNum = 1, maxNumSlots do
				ns.SlotPools[ns.BagFamilies.Inventory()]:Push(allInventorySlots[ns.BagSlot.EncodeSlotIdentifier(bagNum, slotNum)])
			end
		end
	end
end

-- Make table of all bank slots
local allBankSlots = {}

local function CollectBankSlots()
	do
		local bagNum = BANK_CONTAINER
		repeat
			local maxNumSlots = GetContainerNumSlots(bagNum)
			for slotNum = 1, maxNumSlots do
				local slot = ns.BagSlot:New(bagNum, slotNum)
				slot:SetSize(ns.CellSize, ns.CellSize)
				allBankSlots[slot:GetPhysicalIdentifier()] = slot
			end

			if bagNum == BANK_CONTAINER then
				bagNum = NUM_BAG_SLOTS + 1
			else
				bagNum = bagNum + 1
			end
		until (bagNum == (NUM_BAG_SLOTS + NUM_BANKBAGSLOTS))
	end

	do
		local bagNum = BANK_CONTAINER
		repeat
			local maxNumSlots = GetContainerNumSlots(bagNum)
			for slotNum = 1, maxNumSlots do
				ns.SlotPools[ns.BagFamilies.Bank()]:Push(allBankSlots[ns.BagSlot.EncodeSlotIdentifier(bagNum, slotNum)])
			end

			if bagNum == BANK_CONTAINER then
				bagNum = NUM_BAG_SLOTS + 1
			else
				bagNum = bagNum + 1
			end
		until (bagNum == NUM_BAG_SLOTS + NUM_BANKBAGSLOTS)
	end
end

local function SpawnInventoryBags()
	local SV_Bags = SavedVariablesManager.GetRegisteredTable(SV_BAGS_STR)
	local inventoryBags, bagCount = ns.Util.Table.SelectGiven(SV_Bags, function(k,v,...) return v.BagFamily == ns.BagFamilies.Inventory() end)

	if bagCount > 0 then -- We have some bags saved, nice!
		local workingSet = ns.Util.Table.Copy(inventoryBags)

		-- Start with master bag
		do
			local inventoryMasterBags = ns.Util.Table.SelectGiven(workingSet, function(k,v,...) return v.IsMasterBag end)
			for k,v in pairs(inventoryMasterBags) do
				ns.MasterBags[v.BagFamily] = ns.BagFrame:New(v)
				workingSet[k] = nil
			end
		end

		-- Remaining bags
		for k,v in pairs(workingSet) do
			ns.BagFrame:New(v)
		end
	else -- This is the first time, please be gentle
		local masterBagConfig = ns.Util.Table.Copy(ns.BagFrame.DefaultConfigTable)
		masterBagConfig.IsMasterBag = true
		masterBagConfig.NumColumns = 10
		ns.MasterBags[masterBagConfig.BagFamily] = ns.BagFrame:New(masterBagConfig)
	end
end

function frame:PLAYER_LOGIN()
	ns.MasterBags = {}

	CollectInventorySlots()
	SavedVariablesManager.Init(OB_SV)
	SavedVariablesManager.CreateRegisteredTable(SV_BAGS_STR)
	SavedVariablesManager.Save()

	SpawnInventoryBags()

	local bagNum
	for bagNum = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
		self:BAG_UPDATE(bagNum)
	end

	ns.MasterBags[ns.BagFamilies.Inventory()]:Update()
end

-- function frame:PLAYER_LEAVING_WORLD()
-- 	SavedVariablesManager.Save()
-- end

local function SpawnBankBags()
	local SV_Bags = SavedVariablesManager.GetRegisteredTable(SV_BAGS_STR)
	local bankBags, bagCount = ns.Util.Table.SelectGiven(SV_Bags, function(k,v,...) return v.BagFamily == ns.BagFamilies.Bank() end)
	
	if bagCount > 0 then
		local workingSet = ns.Util.Table.Copy(bankBags)

		-- Start with master bags
		do
			local bankMasterBags = ns.Util.Table.SelectGiven(workingSet, function(k,v,...) return v.IsMasterBag end)
			for k,v in pairs(bankMasterBags) do
				ns.MasterBags[v.BagFamily] = ns.BagFrame:New(v)
				workingSet[k] = nil
			end
		end

		-- Remaining bags
		for k,v in pairs(workingSet) do
			ns.BagFrame:New(v)
		end
	else -- This is the first time, please be gentle
		local masterBagConfig = ns.Util.Table.Copy(ns.BagFrame.DefaultConfigTable)
		masterBagConfig.IsMasterBag = true
		masterBagConfig.NumColumns = 10
		masterBagConfig.BagFamily = ns.BagFamilies.Bank()
		
		ns.MasterBags[masterBagConfig.BagFamily] = ns.BagFrame:New(masterBagConfig)
	end
end

local function BankUpdate()
	local bagNum = BANK_CONTAINER
	repeat
		local maxNumSlots = GetContainerNumSlots(bagNum)
		for slotNum = 1, maxNumSlots do
			local slot = allBankSlots[ns.BagSlot.EncodeSlotIdentifier(bagNum, slotNum)]

			if slot ~= nil then
				local itemId = GetContainerItemID(bagNum, slot.ItemSlot:GetID())
				slot:SetItem(itemId)
			end
		end

		if bagNum == BANK_CONTAINER then
			bagNum = NUM_BAG_SLOTS + 1
		else
			bagNum = bagNum + 1
		end
	until (bagNum == NUM_BAG_SLOTS + NUM_BANKBAGSLOTS)
end

--PLAYERBANKSLOTS_CHANGED
local bankLoaded = false
function frame:BANKFRAME_OPENED()
	if not bankLoaded then
		bankLoaded = true
		CollectBankSlots()
		SpawnBankBags()
	end

	BankUpdate()

	ns.MasterBags[ns.BagFamilies.Bank()]:Update()
	ns.MasterBags[ns.BagFamilies.Bank()]:Open()
end

function frame:BANKFRAME_CLOSED()
	ns.MasterBags[ns.BagFamilies.Bank()]:Close()
end

function frame:PLAYERBANKSLOTS_CHANGED()
	BankUpdate()
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

	BankUpdate()
end
