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
ns.BagFamilies.Inventory = {}
ns.BagFamilies.Bank = {}

setmetatable(ns.BagFamilies.Inventory, { __call = function()
	return "Inventory"
end })

setmetatable(ns.BagFamilies.Bank, { __call = function()
	return "Bank"
end })

for k,v in pairs(physicalBagTypes) do
	ns.BagFamilies.Inventory[k] = function()
		return ns.BagFamilies.Inventory() .. v
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
		return bag == ns.BagFamilies.Inventory()
	end
end

function ns.BagFamilies:IsBackpackBag(bag)
	local t = type(bag)
	if t == "number" then
		return bag > 0 and bag < (NUM_BAG_SLOTS + 1)
	elseif t == "string" then
		local res = bag == "InventoryCooking" or
			bag == "InventoryEnchanting" or
			bag == "InventoryEngineering" or
			bag == "InventoryGem" or
			bag == "InventoryHerb" or
			bag == "InventoryInscription" or
			bag == "InventoryLeatherworking" or
			bag == "InventoryMining" or
			bag == "InventorySoul" or
			bag == "InventoryFishing" or
			bag == "InventoryAmmoPouch" or
			bag == "InventoryQuiver"
		return res
	end
end

function ns.BagFamilies:IsBank(bag)
	local t = type(bag)
	if t == "number" then
		return bag == BANK_CONTAINER
	elseif t == "string" then
		return bag == ns.BagFamilies.Bank()
	end
end

function ns.BagFamilies:IsBankBag(bag)
	local t = type(bag)
	if t == "number" then
		return bag > NUM_BAG_SLOTS and bag < (NUM_BAG_SLOTS + NUM_BANKBAGSLOTS + 1)
	elseif t == "string" then
		local res = bag == "BankCooking" or
			bag == "BankEnchanting" or
			bag == "BankEngineering" or
			bag == "BankGem" or
			bag == "BankHerb" or
			bag == "BankInscription" or
			bag == "BankLeatherworking" or
			bag == "BankMining" or
			bag == "BankSoul" or
			bag == "BankFishing" or
			bag == "BankAmmoPouch" or
			bag == "BankQuiver"
		return res
	end
end

function ns.BagFamilies:IsReagents(bag)
	if type(bag) == "number" then
		return bag == REAGENTBANK_CONTAINER
	elseif type(bag) == "string" then
		error("ns.BagFamilies.IsReagents not implemented for type string")
	end
end

