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
	inventoryMasterBags, bagCount = ns.Util.Table.SelectGiven(SV_Bags, function(k,v,...) return v.BagFamily == ns.BagFamilies.Inventory() end)

	if bagCount > 0 then -- We have some bags saved, nice!
		PENIS = inventoryMasterBags

		-- I'm not sure why this is necessary, but it seems the call to SV_bag.Children = {} in BagFrame:New() overwrites the inventoryMasterBags table. I don't see why this should be happening
		local children = ns.Util.Table.Copy(inventoryMasterBags[1].value.Children)

		-- Start with master bag
		ns.MasterBags[inventoryMasterBags[1].value.BagFamily] = ns.BagFrame:New(inventoryMasterBags[1].value, inventoryMasterBags[1].key)

		-- Remaining bags
		for k,v in pairs(children) do
			ns.BagFrame:New(v, k)
		end
	else -- This is the first time, please be gentle
		local cnt = 0
		for _,_ in pairs(SV_Bags) do
			cnt = cnt + 1
		end

		local masterBagConfig = ns.Util.Table.Copy(ns.BagFrame.DefaultConfigTable)
		masterBagConfig.IsMasterBag = true
		masterBagConfig.NumColumns = 10
		ns.MasterBags[masterBagConfig.BagFamily] = ns.BagFrame:New(masterBagConfig, cnt)
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

local function SpawnBankBags()
	local SV_Bags = SavedVariablesManager.GetRegisteredTable(SV_BAGS_STR)
	local bankMasterBags, bagCount = ns.Util.Table.SelectGiven(SV_Bags, function(k,v,...) return v.BagFamily == ns.BagFamilies.Bank() end)
	
	if bagCount > 0 then

		-- I'm not sure why this is necessary, but it seems the call to SV_bag.Children = {} in BagFrame:New() overwrites the inventoryMasterBags table. I don't see why this should be happening
		local children = ns.Util.Table.Copy(bankMasterBags[1].value.Children)

		-- Start with master bag
		ns.MasterBags[bankMasterBags[1].value.BagFamily] = ns.BagFrame:New(bankMasterBags[1].value, bankMasterBags[1].key)

		-- Remaining Bags
		for k,v in pairs(children) do
			ns.BagFrame:New(v, k)
		end
	else -- This is the first time, please be gentle
		local cnt = 0
		for _,_ in pairs(SV_Bags) do
			cnt = cnt + 1
		end

		local masterBagConfig = ns.Util.Table.Copy(ns.BagFrame.DefaultConfigTable)
		masterBagConfig.IsMasterBag = true
		masterBagConfig.NumColumns = 10
		masterBagConfig.BagFamily = ns.BagFamilies.Bank()
		
		ns.MasterBags[masterBagConfig.BagFamily] = ns.BagFrame:New(masterBagConfig, cnt)
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

	local masterBag = ns.MasterBags[ns.BagFamilies.Bank()]
	masterBag:Update()
	masterBag:Open()

	for _, v in pairs(masterBag.Children) do
		v:Open()
	end
end

function frame:BANKFRAME_CLOSED()
	local masterBag = ns.MasterBags[ns.BagFamilies.Bank()]
	masterBag:Close()

	for _,v in pairs(masterBag.Children) do
		v:Close()
	end
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
