local addonName, ns = ...
local className = "BagFrame"

ns.BagFrame = ns.BagFrame or {}

setmetatable(ns.BagFrame, {
	__call = function (self, ...)
		return self:New(...)
	end
})

---------------
-- Libraries --
---------------

local FrameworkClass = ObeliskFrameworkManager:GetLibrary("ObeliskFrameworkClass", 1)
if not FrameworkClass then
	error(ns.Debug:sprint(addonName .. className, "Failed to load ObeliskFrameworkClass"))
end

local CycleSort = ObeliskFrameworkManager:GetLibrary("ObeliskCycleSort", 0)
if not CycleSort then
	error(ns.Debug:sprint(addonName .. className, "Failed to load ObeliskCycleSort"))
end

local SavedVariablesManager = ObeliskFrameworkManager:GetLibrary("ObeliskSavedVariablesManager", 0)
if not SavedVariablesManager then
	error(ns.Debug:sprint(addonName .. className, "Failed to load ObeliskSavedVariablesManager"))
end

---------------
-- Constants --
---------------
local SV_BAGS_STR = "Bags"
ns.BagFrame.DefaultConfigTable = {
	IsMasterBag = false,
	NumColumns = 1,
	Slots = {},
	Position = {
		"CENTER",
		UIParent,
		"CENTER",
		0,
		0,
	},
}

-----------
-- local --
-----------

local isShown = true
local createdBags = {}

local cycleSortFuncs = {
	Compare = function(arr, val1, val2)
		if arr[val1].virt < arr[val2].virt then
			return -1
		elseif arr[val1].virt > arr[val2].virt then
			return 1
		else
			return 0
		end
	end,
	Swap = function(arr, val1, val2)

		--print("Swap: val1: " .. val1 .. "->" .. arr[val1].phys .. " val2: " .. val2 .. "->" .. arr[val2].phys)
		local temp = arr[val1].virt
		arr[val1].virt = arr[val2].virt
		arr[val2].virt = temp

		local bagId1, slotId1 = ns.BagSlot.DecodeSlotIdentifier(arr[val1].phys)
		local bagId2, slotId2 = ns.BagSlot.DecodeSlotIdentifier(arr[val2].phys)

		-- Wait for server...
		repeat
			local _, _, locked1 = GetContainerItemInfo(bagId1, slotId1)
	        local _, _, locked2 = GetContainerItemInfo(bagId2, slotId2)

	        if locked1 or locked2 then
	            coroutine.yield()
	        end
	    until not (locked1 or locked2)

		PickupContainerItem(bagId1, slotId1)
		PickupContainerItem(bagId2, slotId2)
	end
}

local function DefragBags()
	ClearCursor()

	-- Reorder createdBags, so that we can get proper Ids
	createdBags = ns.Util.Table.Arrange(createdBags)

	-- Gather old bag data
	local oldBagData = {}
	local oldSlots = {}
	for i = 1, #createdBags do
		local gridView = createdBags[i].GridView

		for k = 1, #gridView.items do
			oldSlots[#oldSlots + 1] = {
				phys = gridView.items[k]:GetPhysicalIdentifier(),
				virt = gridView.items[k]:GetVirtualIdentifier()
			}
		end

		if not createdBags[i].IsMasterBag then
			oldBagData[i] = {
				numColumns = gridView:GetNumColumns(),
				numSlots = gridView:ItemCount(),
			}
		end
	end

	-- Delete old bags
	for i = #createdBags, 1, -1 do
		if not createdBags[i].IsMasterBag then
			createdBags[i]:DeleteBag()
		end
	end

	-- Spawn new bags
	for _,v in pairs(oldBagData) do
		local bagConfig = ns.Util.Table.Copy(ns.BagFrame.DefaultConfigTable)
		bagConfig.NumColumns = v.numColumns
		bagConfig.Slots = v.numSlots
		ns.BagFrame:New(bagConfig)
	end

	-- Restore items to virtual positions
	local newSlots = {}
	for i = 1, #createdBags do
		local gridView = createdBags[i].GridView

		for n = 1, #gridView.items do
			local nPhys = gridView.items[n]:GetPhysicalIdentifier()
			local idx = ns.Util.Table.IndexWhere(oldSlots, function(k,v,...)
				return v.phys == nPhys
			end)

			newSlots[#newSlots + 1] = oldSlots[idx]
		end
	end

	-- print("Old")
	-- do
	-- 	local s = ""
	-- 	for k,v in pairs(oldSlots) do
	-- 		s = s .. " " .. k .. ":".. v.virt
	-- 	end
	-- 	print(s)
	-- end

	CycleSort.Sort(newSlots, cycleSortFuncs)
end

-----------
-- Class --
-----------

function ns.BagFrame:New(configTable)
	if configTable == nil then
		error(ns.Debug:sprint(addonName .. className, "Attempted to create bag with configTable == nil"))
		return
	end

	if configTable.IsMasterBag and ns.MasterBag then
		error(ns.Debug:sprint(addonName .. className, "Attempted to create multiple master bags"))
		return
	end

	local name = addonName .. className
	if configTable.IsMasterBag then
		name = name .. "Master"
	end

	local instance = FrameworkClass({
		prototype = self,
		frameType = "FRAME",
		frameName = name,
		parent = UIParent,
		inheritsFrame = nil
	})
	instance.IsMasterBag = configTable.IsMasterBag
	table.insert(createdBags, instance)
	instance.Id = ns.Util.Table.IndexOf(createdBags, instance)

	local SV_bags = SavedVariablesManager.GetRegisteredTable(SV_BAGS_STR)
	if not SV_bags then
		error(ns.Debug:sprint(addonName .. className, "Failed SavedVariablesManager.GetRegisteredTable with key 'Bags'"))
	end
	SV_bags[instance.Id] = {}
	SV_bags[instance.Id].Slots = {}
	SV_bags[instance.Id].IsMasterBag = configTable.IsMasterBag
	SavedVariablesManager.Save(SV_BAGS_STR)

	instance:LayoutInit()
	instance.GridView:ToggleDebug()

	if configTable.NumColumns then
		instance.NumColumns = configTable.NumColumns
	end

	if configTable.Position then
		local pos = configTable.Position
		pos[2] = UIParent
		instance:ClearAllPoints()
		instance:SetPoint(unpack(pos))

		SV_bags[instance.Id].Position = pos
		SavedVariablesManager.Save(SV_BAGS_STR)
	end

	-- Master bag dependant layout
	if instance.IsMasterBag then
		-- Manually add to gridview to skip adding to available pool again
		for i = 1, ns.InventorySlotPool:Count() do
			local slot = ns.InventorySlotPool.items[i]
			instance.GridView:AddItem(slot)
			slot:SetOwner(instance)
		end

		ns.MasterBag = instance
	elseif configTable.Slots then
		if type(configTable.Slots) == "table" and #configTable.Slots > 0 then
			local compFunc = function(key, value, phys) return value:GetPhysicalIdentifier() == phys end
			for k,v in pairs(configTable.Slots) do
				local idx = ns.Util.Table.IndexWhere(ns.InventorySlotPool.items, compFunc, v)
				local slot = table.remove(ns.InventorySlotPool.items, idx)
				ns.MasterBag:RemoveSlot(slot)
				instance:AddSlot(slot)
			end
		elseif type(configTable.Slots) == "number" then
			-- get slots
			local slots = {}
			for i = 1, configTable.Slots, 1 do
				local slot = ns.InventorySlotPool:Pop()
				table.insert(slots, slot)
			end

			table.sort(slots, function (a, b)
				return a:GetPhysicalIdentifier() < b:GetPhysicalIdentifier()
			end)

			for i = 1, #slots do
				ns.MasterBag:RemoveSlot(slots[i])
			 	instance:AddSlot(slots[i])
			end
		end

		-- Handle size of bag
		local gridWidth, gridHeight = instance.GridView:GetCalculatedGridSize()
		instance:SetSize(gridWidth, gridHeight)

		instance:Update()
		ns.MasterBag:Update()
	end

	return instance
end

function ns.BagFrame.OnMouseDown(self, btn)
	if btn == "LeftButton" then
		self:ClearAllPoints()
		self:StartMoving()
	end
end

function ns.BagFrame.OnMouseUp(self, btn)
	self:StopMovingOrSizing()

	local SV_bags = SavedVariablesManager.GetRegisteredTable(SV_BAGS_STR)
	SV_bags[self.Id].Position = { self:GetPoint() }
	SavedVariablesManager.Save(SV_BAGS_STR)
end

function ns.BagFrame.BtnClose_OnClick(self, btn)
	self:GetParent():Close()
end

function ns.BagFrame.BtnDelete_OnClick(self, btn)
	self:GetParent():DeleteBag()
end

function ns.BagFrame.BtnNew_OnClick(self, btn)
	ns.BagSetupFrame:Show()
end

function ns.BagFrame.BtnDefrag_OnClick(self, btn)
	DefragBags()
end

ns.BagFrame[FrameworkClass.PROPERTY_GET_PREFIX .. "NumColumns"] = function(self, key)
	return self.GridView:GetNumColumns()
end

ns.BagFrame[FrameworkClass.PROPERTY_SET_PREFIX .. "NumColumns"] = function(self, key, value)
	self.GridView:SetNumColumns(value)

	local SV_bags = SavedVariablesManager.GetRegisteredTable(SV_BAGS_STR)
	SV_bags[self.Id].NumColumns = value
	SavedVariablesManager.Save(SV_BAGS_STR)

	return value
end

function ns.BagFrame:DeleteBag()
	self:MergeBag(ns.MasterBag)
	ns.Util.Table.RemoveByVal(createdBags, self)
	ns.MasterBag:Update()

	local SV_bags = SavedVariablesManager.GetRegisteredTable(SV_BAGS_STR)
	SV_bags[self.Id] = nil
	SavedVariablesManager.Save(SV_BAGS_STR)
end

function ns.BagFrame:MergeBag(target)
	while #self.GridView.items > 0 do
		local slot = self.GridView.items[1]
		self:RemoveSlot(slot)
		target:AddSlot(slot)
	end

	self:Hide()
end

function ns.BagFrame:SortSlots()
	local compFunc = function(a, b) return a:GetPhysicalIdentifier() < b:GetPhysicalIdentifier() end
	self.GridView:Sort(compFunc)

	if self.IsMasterBag then
		table.sort(ns.InventorySlotPool.items, compFunc)
	end
end

function ns.BagFrame:AddSlot(slot)
	self.GridView:AddItem(slot)
	slot:SetOwner(self)

	local SV_bags = SavedVariablesManager.GetRegisteredTable(SV_BAGS_STR)

	if type(SV_bags[self.Id].Slots) == "number" then
		SV_bags[self.Id].Slots = {}
	end

	table.insert(SV_bags[self.Id].Slots, slot:GetPhysicalIdentifier())
	SavedVariablesManager.Save(SV_BAGS_STR)

	if self.IsMasterBag then
		ns.InventorySlotPool:Push(slot)
	end
end

function ns.BagFrame:RemoveSlot(slot)
	self.GridView:RemoveItem(slot)

	local SV_bags = SavedVariablesManager.GetRegisteredTable(SV_BAGS_STR)
	ns.Util.Table.RemoveByVal(SV_bags[self.Id].Slots, slot:GetPhysicalIdentifier())
	SavedVariablesManager.Save(SV_BAGS_STR)
end

function ns.BagFrame:Update()
	local gridWidth, gridHeight = self.GridView:GetCalculatedGridSize()

	if gridWidth == nil then
		error(ns.Debug:sprint(className, "Failed to calculate grid width"))
	end
 
	if gridHeight == nil then
		error(ns.Debug:sprint(className, "Failed to calculate grid height"))
	end

	self.GridView:SetWidth(gridWidth)
	self.GridView:SetHeight(gridHeight)

	local width = gridWidth + self.padding * 2
	local height = gridHeight + self.BtnClose:GetHeight() + self.padding + self.btnHeight

	self:SetWidth(width)
	self:SetHeight(height)

	self:SortSlots()
	self.GridView:Update()
end

function ns.BagFrame:Close()
	self:Hide()
	local flip = true

	for _,v in pairs(createdBags) do
		if v:IsVisible() then
			flip = false
			break
		end
	end

	if flip then
		isShown = false
	end
end

function ns.BagFrame:Open()
	self:Show()
	local flip = true

	for _,v in pairs(createdBags) do
		if not v:IsVisible() then
			flip = false
			break
		end
	end

	if flip then
		isShown = true
	end
end

function ns.BagFrame:ToggleBags()
	local shoudClose = isShown

	for k,v in pairs(createdBags) do
		if shoudClose then
			v:Close()
		else
			v:Open()
		end
	end
end

