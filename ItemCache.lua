local addonName, ns = ...

-- local frame = CreateFrame("FRAME")
-- frame:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
-- frame:RegisterEvent("GET_ITEM_INFO_RECEIVED")

ns.ItemCache = {}
ns.ItemCache.cache = {}

function ns.ItemCache:GetInfo(itemId, updateCache)
	if self.cache[itemId] ~= nil and not updateCache then
		return self.cache[itemId]
	end

	local item = {}
	item.name, _, item.rarity, _, _, item.itemType, _, _, _, item.icon = GetItemInfo(itemId)

	self.cache[itemId] = item
	return item
end

-- function frame:GET_ITEM_INFO_RECEIVED(itemId)
-- 	--local item = ns.ItemCache:GetInfo(itemId, true)
-- end