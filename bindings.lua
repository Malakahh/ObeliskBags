local addonName, ns = ...

BINDING_HEADER_OB_H = "Obelisk Bags";
BINDING_NAME_OB_TOGGLE = "Open/Close bags";

function ObeliskBags_ToggleBags()
	ns.bagFrame:ToggleBags()
end