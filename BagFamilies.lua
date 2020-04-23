local addonName, ns = ...

local physicalBagTypes = {
	Cooking = "Cooking",
	Enchanting = "Enchanting",
	Engineering = "Engineering",
	Gem = "Gem",
	Herb = "Herb",
	Inscription = "Inscription",
	Leatherworking = "Leatherworking",
	Mining = "Mining",
	Soul = "Soul",
	Fishing = "Fishing",
	AmmoPouch = "AmmoPouch",
	Quiver = "Quiver",
}

ns.BagFamilies = {}
ns.BagFamilies.Backpack = {}
ns.BagFamilies.Bank = {}
ns.BagFamilies.Reagents = {}

setmetatable(ns.BagFamilies.Backpack, { __call = function()
	return "Backpack"
end })

setmetatable(ns.BagFamilies.Bank, { __call = function()
	return "Bank"
end })

setmetatable(ns.BagFamilies.Reagents, { __call = function()
	return "Reagents"
end})

for k,v in pairs(physicalBagTypes) do
	ns.BagFamilies.Backpack[k] = function()
		return ns.BagFamilies.Backpack() .. v
	end
	ns.BagFamilies.Bank[k] = function()
		return ns.BagFamilies.Bank() .. v
	end
end

function ns.BagFamilies:IsBackpack(bag)
	local t = type(bag)
	if t == "number" then
		return bag == BACKPACK_CONTAINER
	elseif t == "string" then
		return bag == ns.BagFamilies.Backpack()
	end
end

function ns.BagFamilies:IsBackpackBag(bag)
	local t = type(bag)
	if t == "number" then -- BagID
		return bag > 0 and bag < (NUM_BAG_SLOTS + 1)
	elseif t == "string" then
		local res = bag == self.Backpack.Cooking() or
			bag == self.Backpack.Enchanting() or
			bag == self.Backpack.Engineering() or
			bag == self.Backpack.Gem() or
			bag == self.Backpack.Herb() or
			bag == self.Backpack.Inscription() or
			bag == self.Backpack.Leatherworking() or
			bag == self.Backpack.Mining() or
			bag == self.Backpack.Soul() or
			bag == self.Backpack.Fishing() or
			bag == self.Backpack.AmmoPouch() or
			bag == self.Backpack.Quiver()
		return res
	end
end

function ns.BagFamilies:IsBank(bag)
	local t = type(bag)
	if t == "number" then -- BagID
		return bag == BANK_CONTAINER
	elseif t == "string" then
		return bag == ns.BagFamilies.Bank()
	end
end

function ns.BagFamilies:IsBankBag(bag)
	local t = type(bag)
	if t == "number" then -- BagID
		return bag > NUM_BAG_SLOTS and bag < (NUM_BAG_SLOTS + NUM_BANKBAGSLOTS + 1)
	elseif t == "string" then
		local res = bag == self.Bank.Cooking() or
			bag == self.Bank.Enchanting() or
			bag == self.Bank.Engineering() or
			bag == self.Bank.Gem() or
			bag == self.Bank.Herb() or
			bag == self.Bank.Inscription() or
			bag == self.Bank.Leatherworking() or
			bag == self.Bank.Mining() or
			bag == self.Bank.Soul() or
			bag == self.Bank.Fishing() or
			bag == self.Bank.AmmoPouch() or
			bag == self.Bank.Quiver()
		return res
	end
end

function ns.BagFamilies:IsReagents(bag)
	if type(bag) == "number" then -- BagID
		return bag == REAGENTBANK_CONTAINER
	elseif type(bag) == "string" then
		error("ns.BagFamilies.IsReagents not implemented for type string")
	end
end

function ns.BagFamilies:BagIDToBagFamily(bagId)
	if self:IsReagents(bagId) then
		return ns.BagFamilies.Reagents()
	elseif self:IsBackpack(bagId) then
		return ns.BagFamilies.Inventory()
	elseif self:IsBank(bagId) then
		return ns.BagFamilies.Bank()
	end

	local BackpackOrBank
	if self:IsBackpackBag(bagId) then
		BackpackOrBank = self.Backpack
	elseif self:IsBankBag(bagId) then
		BackpackOrBank = self.Bank
	end

	if BackpackOrBank then
		local _, bagType = GetContainerNumFreeSlots(bagId)
		if bagType == 0 then
			return BackpackOrBank.Cooking()
		elseif bagType == 1 then
			return BackpackOrBank.Quiver()
		elseif bagType == 2 then
			return BackpackOrBank.AmmoPouch()
		elseif bagType == 4 then
			return BackpackOrBank.Soul()
		elseif bagType == 8 then
			return BackpackOrBank.Leatherworking()
		elseif bagType == 16 then
			return BackpackOrBank.Inscription()
		elseif bagType == 32 then
			return BackpackOrBank.Herb()
		elseif bagType == 64 then
			return BackpackOrBank.Enchanting()
		elseif bagType == 128 then
			return BackpackOrBank.Engineering()
		-- elseif bagType == 256 then -- Keyring
		elseif bagType == 512 then
			return BackpackOrBank.Gem()
		elseif bagType == 1024 then
			return BackpackOrBank.Mining()
		-- elseif bagType == 2048 then -- Unknown
		-- elseif bagType == 4096 then -- Vanity Pets
		end
	end

	return "Unknown"
	--error("ns.BagFamilies.BagIDToBagFamily: Unknown type of given bagID: " .. bagID)
end