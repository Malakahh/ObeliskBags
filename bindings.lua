local addonName, ns = ...

BINDING_HEADER_OB_H = "Obelisk Bags";
BINDING_NAME_OB_TOGGLE = "Open/Close bags";
BINDING_NAME_OB_BANK_TOGGLE = "Open/Close bank"

function ObeliskBags_ToggleBags()
	ns.MasterBags[ns.BagFamilies.Inventory()]:ToggleBags()
end

function ObeliskBags_ToggleBank()
	ns.MasterBags[ns.BagFamilies.Bank()]:ToggleBags()
end