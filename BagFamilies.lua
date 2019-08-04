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
