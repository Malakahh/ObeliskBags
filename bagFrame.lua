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
	Title = "My Custom Bag",
	NumColumns = 1,
	Slots = {},
	Position = {
		"CENTER",
		UIParent,
		"CENTER",
		0,
		0,
	},
	BagFamily = ns.BagFamilies.Inventory(),
	Children = {}
}

-----------
-- local --
-----------

-- local bagCnt = 1
-- local createdBags = {}

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


		print("Swap: val1: " .. val1 .. "->" .. arr[val1].phys .. " val2: " .. val2 .. "->" .. arr[val2].phys)
		local temp = arr[val1].virt
		arr[val1].virt = arr[val2].virt
		arr[val2].virt = temp

		-- temp = arr[val1].phys
		-- arr[val1].phys = arr[val2].phys
		-- arr[val2].phys = temp


		local bagId1, slotId1 = ns.BagSlot.DecodeSlotIdentifier(arr[val1].phys)
		local bagId2, slotId2 = ns.BagSlot.DecodeSlotIdentifier(arr[val2].phys)

		
		local attempts = 0

		-- Wait for server...
		repeat
			local _, _, locked1 = GetContainerItemInfo(bagId1, slotId1)
	        local _, _, locked2 = GetContainerItemInfo(bagId2, slotId2)

	        if locked1 or locked2 then
	            coroutine.yield()
	        end

	        attempts = attempts + 1
	    until not (locked1 or locked2)

	    print("Swapping: attempts: " .. attempts)

		PickupContainerItem(bagId1, slotId1)
		PickupContainerItem(bagId2, slotId2)
	end
}

-- local function DefragBags()
-- 	ClearCursor()

-- 	-- Reorder createdBags, so that we can get proper Ids
-- 	createdBags = ns.Util.Table.Arrange(createdBags)

-- 	-- Gather old bag data
-- 	local oldBagData = {}
-- 	local oldSlots = {}
-- 	local cnt = 1
-- 	for i = 1, #createdBags do
-- 		local gridView = createdBags[i].GridView

-- 		for k = 1, #gridView.items do
-- 			oldSlots[#oldSlots + 1] = {
-- 				phys = gridView.items[k]:GetPhysicalIdentifier(),
-- 				--virt = gridView.items[k]:GetVirtualIdentifier()
-- 				virt = cnt
-- 			}
-- 			cnt = cnt + 1
-- 		end

-- 		if not createdBags[i].IsMasterBag then
-- 			oldBagData[i] = {
-- 				numColumns = gridView:GetNumColumns(),
-- 				numSlots = gridView:ItemCount(),
-- 			}
-- 		end
-- 	end

-- 	-- Delete old bags
-- 	for i = #createdBags, 1, -1 do
-- 		if not createdBags[i].IsMasterBag then
-- 			createdBags[i]:DeleteBag()
-- 		end
-- 	end

-- 	-- Spawn new bags
-- 	for _,v in pairs(oldBagData) do
-- 		local bagConfig = ns.Util.Table.Copy(ns.BagFrame.DefaultConfigTable)
-- 		bagConfig.NumColumns = v.numColumns
-- 		bagConfig.Slots = v.numSlots
-- 		ns.BagFrame:New(bagConfig)
-- 	end

-- 	-- Create new list with shuffled virtual order
-- 	local newSlots = {}
-- 	for i = 1, #createdBags do
-- 		local gridView = createdBags[i].GridView

-- 		for n = 1, #gridView.items do
-- 			local nPhys = gridView.items[n]:GetPhysicalIdentifier()
-- 			local idx = ns.Util.Table.IndexWhere(oldSlots, function(k,v,...)
-- 				return v.phys == nPhys
-- 			end)

-- 			newSlots[#newSlots + 1] = oldSlots[idx]
-- 		end
-- 	end

-- 	-- This actually calls a selection sort for now, for simplicity. I was worried my cyclesort implementation was wrong
-- 	CycleSort.Sort(newSlots, cycleSortFuncs)

	-- print("New")
	-- do
	-- 	local s = ""
	-- 	for k,v in pairs(newSlots) do
	-- 		s = s .. " " .. k .. ":".. v.virt .. ":" .. v.phys
	-- 	end
	-- 	print(s)
	-- end




	-- for i = 1, #newSlots - 1 do
	-- 	if i ~= newSlots[i].virt then
	-- 		print("i: " .. i .. " virt:" .. newSlots[i].virt)
	-- 		for k = i + 1, #newSlots do
	-- 			if i == newSlots[k].virt then
					

	-- 				local bagId1, slotId1 = ns.BagSlot.DecodeSlotIdentifier(newSlots[k].phys)
	-- 				local bagId2, slotId2 = ns.BagSlot.DecodeSlotIdentifier(newSlots[i].phys)

					
	-- 				local attempts = 0

	-- 				-- Wait for server...
	-- 				repeat
	-- 					local _, _, locked1 = GetContainerItemInfo(bagId1, slotId1)
	-- 			        local _, _, locked2 = GetContainerItemInfo(bagId2, slotId2)

	-- 			        if locked1 or locked2 then
	-- 			            coroutine.yield()
	-- 			        end

	-- 			        attempts = attempts + 1
	-- 			    until not (locked1 or locked2)

	-- 			    print("Swapping: attempts: " .. attempts)

	-- 				PickupContainerItem(bagId1, slotId1)
	-- 				PickupContainerItem(bagId2, slotId2)

	-- 				local temp = newSlots[k].virt
	-- 				newSlots[k].virt = newSlots[i].virt
	-- 				newSlots[i].virt = temp

	-- 				coroutine.yield()
	-- 			end
	-- 		end
	-- 	end
	-- end

	-- print("Finish")
	-- do
	-- 	local s = ""
	-- 	for k,v in pairs(newSlots) do
	-- 		s = s .. " " .. k .. ":".. v.virt .. ":" .. v.phys
	-- 	end
	-- 	print(s)
	-- end
-- end

-- local cor
-- local frame = CreateFrame("FRAME")
-- --frame:RegisterEvent("ITEM_LOCK_CHANGED")
-- function frame:OnUpdate(elapsed)
-- 	local alive = coroutine.resume(cor)
-- 	if not alive then
-- 		self:SetScript("OnUpdate", nil)
-- 	end
-- end

-- local function Start()
-- 	cor = coroutine.create(DefragBags)
-- 	frame:SetScript("OnUpdate", frame.OnUpdate)
-- end

local function DefragBags()
	local swapBag, swapSlot = nil, nil

	for bagNum = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
		local numFreeSlots, bagType = GetContainerNumFreeSlots(bagNum)

		if numFreeSlots > 0 and bagType == 0 then
			swapBag = bagNum
			swapSlot = GetContainerFreeSlots(bagNum)[1]
			break
		end
	end

	if swapBag == nil or swapSlot == nil then
		print("Unable to defrag. Must have at least 1 available slot in a regular bag.")
		return
	end

	ClearCursor()

	-- Reorder createdBags, so that we can get proper Ids
	createdBags = ns.Util.Table.Arrange(createdBags)

	local virtItemSlots = {}

	-- Collect item information
	for i = 1, #createdBags do
		local gridView = createdBags[i].GridView
		for k = 1, #gridView.items do
			local b, s = ns.BagSlot.DecodeSlotIdentifier(gridView.items[k]:GetPhysicalIdentifier())
			local _, itemCount, _, _, _, _, _, _, _, itemId = GetContainerItemInfo(b,s)

			if itemId ~= nil then
				table.insert(virtItemSlots, {
					itemCount = itemCount,
					itemId = itemId,
					virt = ns.BagSlot.EncodeSlotIdentifier(i, k)
				})
			end
		end
	end

	-- Gather old bag data
	local oldBagData = {}
	for i = 1, #createdBags do
		local gridView = createdBags[i].GridView

		if not createdBags[i].IsMasterBag then
			oldBagData[i] = createdBags[i]:GetConfigTable()
			oldBagData[i].Slots = #oldBagData[i].Slots
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
		ns.BagFrame:New(v)
	end

	-- Rearrange items
	local locked = {}
	for _,v in pairs(virtItemSlots) do
		local fromBag, fromSlot
		local fromFound = false

		-- Check if item is already in place, in which case we can skip it
		local skip = false
		for i = 1, #createdBags do
			local gridView = createdBags[i].GridView

			for n = 1, #gridView.items do
				if gridView.items[n]:GetVirtualIdentifier() == v.virt then
					local b, s = ns.BagSlot.DecodeSlotIdentifier(gridView.items[n]:GetPhysicalIdentifier())
					local _, itemCount, _, _, _, _, _, _, _, itemId = GetContainerItemInfo(b,s)

					if itemId == v.itemId and itemCount	== v.itemCount then
						skip = true
						locked[ns.BagSlot.EncodeSlotIdentifier(b, s)] = true
						break
					end
				end
			end

			if skip then
				break
			end
		end

		if not skip then

			-- Iterate through bags to find correct items
			for i = 1, #createdBags do
				local gridView = createdBags[i].GridView

				for n = 1, #gridView.items do
					local physId = gridView.items[n]:GetPhysicalIdentifier()
					if not locked[physId] then
						local b, s = ns.BagSlot.DecodeSlotIdentifier(physId)
						local _, itemCount, _, _, _, _, _, _, _, itemId = GetContainerItemInfo(b, s)

						if itemId == v.itemId and itemCount == v.itemCount then
							fromBag = b
							fromSlot = s
							fromFound = true
							break
						end
					end
				end

				if fromFound then
					break
				end
			end

			if fromFound then
				local toBag, toSlot
				local toFound

				-- Find "to"
				for i = 1, #createdBags do
					local gridView = createdBags[i].GridView

					for n = 1, #gridView.items do
						if gridView.items[n]:GetVirtualIdentifier() == v.virt then
							toBag, toSlot = ns.BagSlot.DecodeSlotIdentifier(gridView.items[n]:GetPhysicalIdentifier())
							toFound = true
							break
						end
					end

					if toFound then
						break
					end
				end

				-- Swap
				if toFound and not (fromBag == toBag and fromSlot == toSlot) then
					-- TODO: Could skip swap slot if "to" slot is empty
					-- TODO: Could skip swap slot if item in "to" is of different itemID than "from"
					-- TODO: Could skip swap slot if itemID in "to" doesn't stack with "from", even if the itemID is equal

					-- Wait for lock...
					repeat
						local _, _, locked1 = GetContainerItemInfo(fromBag, fromSlot)
				        local _, _, locked2 = GetContainerItemInfo(swapBag, swapSlot)

				        if locked1 or locked2 then
				            coroutine.yield()
				        end
				    until not (locked1 or locked2)

					PickupContainerItem(fromBag, fromSlot)
					PickupContainerItem(swapBag, swapSlot)

					coroutine.yield()

					-- Wait for lock...
					repeat
						local _, _, locked1 = GetContainerItemInfo(toBag, toSlot)
				        local _, _, locked2 = GetContainerItemInfo(fromBag, fromSlot)

				        if locked1 or locked2 then
				            coroutine.yield()
				        end
				    until not (locked1 or locked2)

	 				PickupContainerItem(toBag, toSlot)
	 				PickupContainerItem(fromBag, fromSlot)

	 				coroutine.yield()

	 				-- Wait for lock...
	 				repeat
						local _, _, locked1 = GetContainerItemInfo(swapBag, swapSlot)
				        local _, _, locked2 = GetContainerItemInfo(toBag, toSlot)

				        if locked1 or locked2 then
				            coroutine.yield()
				        end
				    until not (locked1 or locked2)

	 				PickupContainerItem(swapBag, swapSlot)
	 				PickupContainerItem(toBag, toSlot)

	 				repeat
						local _, _, locked1 = GetContainerItemInfo(swapBag, swapSlot)
				        local _, _, locked2 = GetContainerItemInfo(toBag, toSlot)

				        if locked1 or locked2 then
				            coroutine.yield()
				        end
				    until not (locked1 or locked2)

	 				locked[ns.BagSlot.EncodeSlotIdentifier(toBag, toSlot)] = true

	 				coroutine.yield()
				end
			end
		end
	end
end

local cor
local frame = CreateFrame("FRAME")
function frame:OnUpdate(elapsed)
	local alive = coroutine.resume(cor)
	if not alive then
		self:SetScript("OnUpdate", nil)
	end
end

local function Start()
	cor = coroutine.create(DefragBags)
	frame:SetScript("OnUpdate", frame.OnUpdate)
end

-----------
-- Class --
-----------

function ns.BagFrame:New(configTable, Id)
	if not configTable then
		error(ns.Debug:sprint(addonName .. className, "Attempted to create bag with configTable == nil"))
		return
	end

	if not Id then
		error(ns.Debug:sprint(addonName .. className, "Attempted to create bag with Id == nil"))
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

	instance.Id = Id

	if configTable.BagFamily then
		instance.BagFamily = configTable.BagFamily
	end

	--table.insert(createdBags, instance)
	--instance.Id = ns.Util.Table.IndexOf(createdBags, instance)
	instance.IsMasterBag = configTable.IsMasterBag

	local SV_bag = instance:GetSV()
	SV_bag.BagFamily = instance.BagFamily
	SV_bag.Slots = {}
	SV_bag.IsMasterBag = configTable.IsMasterBag
	SavedVariablesManager.Save(SV_BAGS_STR)

	instance:LayoutInit()
	instance.GridView:ToggleDebug()

	if configTable.NumColumns then
		instance.NumColumns = configTable.NumColumns
	end

	if configTable.Position then
		instance:SetPosition(configTable.Position)
	end

	if configTable.Title then
		instance.TitleText = configTable.Title
	end

	-- Master bag dependant layout
	if instance.IsMasterBag then
		-- Manually add to gridview to skip adding to available pool again
		for i = 1, ns.SlotPools[instance.BagFamily]:Count() do
			local slot = ns.SlotPools[instance.BagFamily].items[i]
			instance.GridView:AddItem(slot)
			slot:SetOwner(instance)
		end

		instance.Title:SetText(instance.Title:GetText() .. " - Master Bag - " .. instance.BagFamily)


		SV_bag.Children = {}
		SavedVariablesManager.Save(SV_BAGS_STR)

		instance.TreeShown = true
		instance.Children = {}
		instance.PhysicalBags = {}

		if instance.BagFamily == ns.BagFamilies.Inventory() then
			table.insert(instance.PhysicalBags, BACKPACK_CONTAINER)
			table.insert(instance.PhysicalBags, BACKPACK_CONTAINER + 1)
			table.insert(instance.PhysicalBags, BACKPACK_CONTAINER + 2)
			table.insert(instance.PhysicalBags, BACKPACK_CONTAINER + 3)
			table.insert(instance.PhysicalBags, BACKPACK_CONTAINER + 4)
		elseif instance.BagFamily == ns.BagFamilies.Bank() then
			table.insert(instance.PhysicalBags, BANK_CONTAINER)
			table.insert(instance.PhysicalBags, NUM_BAG_SLOTS + 1)
			table.insert(instance.PhysicalBags, NUM_BAG_SLOTS + 2)
			table.insert(instance.PhysicalBags, NUM_BAG_SLOTS + 3)
			table.insert(instance.PhysicalBags, NUM_BAG_SLOTS + 4)
			table.insert(instance.PhysicalBags, NUM_BAG_SLOTS + 5)
			table.insert(instance.PhysicalBags, NUM_BAG_SLOTS + 6)
			table.insert(instance.PhysicalBags, NUM_BAG_SLOTS + 7)
		end

		-- TODO: Master bag should be a logo instead
	elseif configTable.Slots then
		local masterBag = ns.MasterBags[instance.BagFamily]

		if type(configTable.Slots) == "table" and #configTable.Slots > 0 then
			local compFunc = function(key, value, phys) return value:GetPhysicalIdentifier() == phys end
			for k,v in pairs(configTable.Slots) do
				local idx = ns.Util.Table.IndexWhere(ns.SlotPools[instance.BagFamily].items, compFunc, v)
				local slot = table.remove(ns.SlotPools[instance.BagFamily].items, idx)
				masterBag:RemoveSlot(slot)
				instance:AddSlot(slot)
			end
		elseif type(configTable.Slots) == "number" then
			-- get slots
			local slots = {}
			for i = 1, configTable.Slots, 1 do
				local slot = ns.SlotPools[instance.BagFamily]:Pop()
				table.insert(slots, slot)
			end

			table.sort(slots, function (a, b)
				return a:GetPhysicalIdentifier() < b:GetPhysicalIdentifier()
			end)

			for i = 1, #slots do
				masterBag:RemoveSlot(slots[i])
			 	instance:AddSlot(slots[i])
			end
		end

		-- Handle size of bag
		local gridWidth, gridHeight = instance.GridView:GetCalculatedGridSize()
		instance:SetSize(gridWidth, gridHeight)

		masterBag:AddChild(instance)

		instance:Update()
		masterBag:Update()
	end

	instance:LayoutInitDelayed()


	return instance
end

function ns.BagFrame:AddChild(child)
	assert(self.IsMasterBag, "Attempted to call AddChild on a non-master bag.")

	print("Adding child: " .. child.Id)
	self.Children[child.Id] = child

	local SV_bag = self:GetSV()
	SV_bag.Children[child.Id] = child:GetConfigTable()
	SavedVariablesManager.Save(SV_BAGS_STR)
end

function ns.BagFrame:RemoveChild(child)
	assert(self.IsMasterBag, "Attempted to call RemoveChild on a non-master bag.")

	self.Children[child.Id] = nil

	local SV_bag = self:GetSV()
	SV_bag[child.Id] = nil
	SavedVariablesManager.Save(SV_BAGS_STR)
end

function ns.BagFrame:SetPosition(pos)
	pos[2] = UIParent
	self:ClearAllPoints()
	self:SetPoint(unpack(pos))

	local SV_bag = self:GetSV()

	SV_bag.Position = pos
	SV_bag.Position[2] = nil -- Don't save parent table
	SavedVariablesManager.Save(SV_BAGS_STR)
end

function ns.BagFrame:GetConfigTable()
	local configTable = {
		IsMasterBag = self.IsMasterBag,
		Title = self.Title:GetText(),
		NumColumns = self.NumColumns,
		Slots = {}, -- Added below
		Position = { self:GetPoint() },
		BagFamily = self.BagFamily,
		Children = {}
	}

	for k,_ in pairs(ns.BagFrame.DefaultConfigTable) do
		assert(configTable[k] ~= nil, "GetConfigTable does not have the same keys as ns.BagFrame.DefaultConfigTable")
	end	

	if self.IsMasterBag then
		for _,v in pairs(self.Children) do
			table.insert(configTable.Children, v:GetConfigTable())
		end
	end

	for _,v in pairs(self.GridView.items) do
		table.insert(configTable.Slots, v:GetPhysicalIdentifier())
	end

	return configTable
end

function ns.BagFrame.OnMouseDown(self, btn)
	if btn == "LeftButton" then
		self:ClearAllPoints()
		self:StartMoving()
	end
end

function ns.BagFrame.OnMouseUp(self, btn)
	self:StopMovingOrSizing()

	local SV_bag = self:GetSV()
	SV_bag.Position = { self:GetPoint() }
	SavedVariablesManager.Save(SV_BAGS_STR)
end

function ns.BagFrame.BtnClose_OnClick(self, btn)
	self:GetParent():Close()
end

function ns.BagFrame.BtnDelete_OnClick(self, btn)
	self:GetParent():DeleteBag()
end

function ns.BagFrame.BtnNew_OnClick(self, btn)
	ns.BagSetupFrame:Open(nil, false, self:GetParent().BagFamily)
end

function ns.BagFrame.BtnConfig_OnClick(self, btn)
	ns.BagSetupFrame:Open(self:GetParent(), true, self:GetParent().BagFamily)
end

function ns.BagFrame.BtnDefrag_OnClick(self, btn)
	local parent = self:GetParent()
	parent.cor = coroutine.create(parent.Defrag)
	parent:SetScript("OnUpdate", parent.OnUpdate)
end

ns.BagFrame[FrameworkClass.PROPERTY_GET_PREFIX .. "NumColumns"] = function(self, key)
	return self.GridView:GetNumColumns()
end

ns.BagFrame[FrameworkClass.PROPERTY_SET_PREFIX .. "NumColumns"] = function(self, key, value)
	self.GridView:SetNumColumns(value)

	local SV_bag = self:GetSV()
	SV_bag.NumColumns = value
	SavedVariablesManager.Save(SV_BAGS_STR)

	return value
end

ns.BagFrame[FrameworkClass.PROPERTY_GET_PREFIX .. "TitleText"] = function(self, key)
	return self.Title:GetText()
end

ns.BagFrame[FrameworkClass.PROPERTY_SET_PREFIX .. "TitleText"] = function(self, key, value)
	self.Title:SetText(value)

	local SV_bag = self:GetSV()
	SV_bag.Title = self.Title:GetText()
	SavedVariablesManager.Save(SV_BAGS_STR)

	return value
end

function ns.BagFrame:DeleteBag()
	local masterBag = ns.MasterBags[self.BagFamily]
	self:MergeBag(masterBag)

	masterBag:RemoveChild(self)
	masterBag:Update()

	local SV_bags = SavedVariablesManager.GetRegisteredTable(SV_BAGS_STR)
	SV_bags[masterBag.Id].Children[self.Id] = nil
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
		table.sort(ns.SlotPools[self.BagFamily].items, compFunc)
	end
end

function ns.BagFrame:AddSlot(slot)
	self.GridView:AddItem(slot)
	slot:SetOwner(self)

	--local SV_bags = SavedVariablesManager.GetRegisteredTable(SV_BAGS_STR)
	local SV_bag = self:GetSV()

	if type(SV_bag.Slots) == "number" then
		SV_bag.Slots = {}
	end

	table.insert(SV_bag.Slots, slot:GetPhysicalIdentifier())
	SavedVariablesManager.Save(SV_BAGS_STR)

	if self.IsMasterBag then
		ns.SlotPools[self.BagFamily]:Push(slot)
	end
end

function ns.BagFrame:RemoveSlot(slot)
	self.GridView:RemoveItem(slot)

	--local SV_bags = SavedVariablesManager.GetRegisteredTable(SV_BAGS_STR)
	local SV_bag = self:GetSV()
	ns.Util.Table.RemoveByVal(SV_bag.Slots, slot:GetPhysicalIdentifier())
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

function ns.BagFrame:GetSV()
	local SV_bags = SavedVariablesManager.GetRegisteredTable(SV_BAGS_STR)

	if not TESTLOL then
		TESTLOL = SV_bags
	end

	if not SV_bags then
		error(ns.Debug:sprint(addonName .. className, "Failed SavedVariablesManager.GetRegisteredTable with key '" .. SV_BAGS_STR .. "'"))
	end

	if self.IsMasterBag then
		if SV_bags[self.Id] == nil then
			print("Adding new bag with id: " .. self.Id)
			SV_bags[self.Id] = {}
		end

		return SV_bags[self.Id]
	else
		local masterBag = ns.MasterBags[self.BagFamily]
		SV_bags[masterBag.Id].Children[self.Id] = SV_bags[masterBag.Id].Children[self.Id] or {}
		return SV_bags[masterBag.Id].Children[self.Id]
	end
end

function ns.BagFrame:Close()
	self:Hide()
	local flip = true

	local masterBag = ns.MasterBags[self.BagFamily]

	local i = 0
	repeat
		local workingBag
		if i == 0 then
			workingBag = masterBag
		else
			workingBag = masterBag.Children[i]
		end
		
		if workingBag:IsVisible() then
			flip = false
			break
		end

		i = i + 1
	until(i > #masterBag.Children)

	if flip then
		masterBag.TreeShown = false
	end
end

function ns.BagFrame:Open()
	self:Show()
	local flip = true

	local masterBag = ns.MasterBags[self.BagFamily]

	local i = 0
	repeat
		local workingBag
		if i == 0 then
			workingBag = masterBag
		else
			workingBag = masterBag.Children[i]
		end
		
		if not workingBag:IsVisible() then
			flip = false
			break
		end

		i = i + 1
	until(i > #masterBag.Children)

	if flip then
		masterBag.TreeShown = true
	end
end

function ns.BagFrame:ToggleBags()
	local masterBag = ns.MasterBags[self.BagFamily]
	local shouldClose = masterBag.TreeShown

	local i = 0
	repeat
		local workingBag
		if i == 0 then
			workingBag = masterBag
		else
			workingBag = masterBag.Children[i]
		end

		if shouldClose then
			workingBag:Close()
		else
			workingBag:Open()
		end

		i = i + 1
	until(i > #masterBag.Children)
end

function ns.BagFrame:IterateBagTree(func)
	local masterBag = ns.MasterBags[self.BagFamily]
	
	if func(masterBag) then
		return
	end

	for _,bag in pairs(masterBag.Children) do
		if func(bag) then
			return
		end
	end
end

local function ItemSwap(fromBag, fromSlot, toBag, toSlot)

	-- Wait for lock...
	repeat
		local _, _, locked1 = GetContainerItemInfo(fromBag, fromSlot)
		local _, _, locked2 = GetContainerItemInfo(toBag, toSlot)

		if locked1 or locked2 then
			coroutine.yield()
		end
	until not (locked1 or locked2)

	PickupContainerItem(fromBag, fromSlot)
	PickupContainerItem(toBag, toSlot)

	coroutine.yield()
end

function ns.BagFrame:OnUpdate( ... )
	local alive = coroutine.resume(self.cor, self)
	if not alive then
		self:SetScript("OnUpdate", nil)
	end
end

function ns.BagFrame:Defrag()
	local masterBag = ns.MasterBags[self.BagFamily]
	local swapBag, swapSlot = nil, nil

	for _, bagNum in pairs(masterBag.PhysicalBags) do
		local numFreeSlots, bagType = GetContainerNumFreeSlots(bagNum)

		if numFreeSlots > 0 and bagType == 0 then
			swapBag = bagNum
			swapSlot = GetContainerFreeSlots(bagNum)[1]
			break
		end
	end

	if swapBag == nil or swapSlot == nil then
		print("Unable to defrag. Must have at least 1 available slot in a regular bag.")
		return
	end

	ClearCursor()

	local virtItemSlots = {}

	-- Collect item information
	print("Collect item information")
	do
		local cnt = 0
		self:IterateBagTree(function(bag)
			local gridView = bag.GridView
			for i = 1, #gridView.items do
				local b, s = ns.BagSlot.DecodeSlotIdentifier(gridView.items[i]:GetPhysicalIdentifier())
				local _, itemCount, _, _, _, _, _, _, _, itemId = GetContainerItemInfo(b,s)

				if itemId ~= nil then
					local virt = ns.BagSlot.EncodeSlotIdentifier(cnt, i)

					if bag.IsMasterBag then
						virt = ns.BagSlot.EncodeSlotIdentifier(0, i)
					end

					table.insert(virtItemSlots, {
						itemCount = itemCount,
						itemId = itemId,
						virt = virt
					})
					print(C_Item.GetItemNameByID(itemId) .. " - " .. ns.BagSlot.EncodeSlotIdentifier(bag.Id, i))
				end
			end

			cnt = cnt + 1
		end)
	end

	-- Gather old bag data
	print("Gather old bag data")
	local oldBagData = {}
	self:IterateBagTree(function(bag)
		print("Gathering oldBagData from: " .. bag.Id)
		local gridView = bag.GridView

		if not bag.IsMasterBag then
			oldBagData[bag.Id] = bag:GetConfigTable()
			oldBagData[bag.Id].Slots = #oldBagData[bag.Id].Slots
		end
	end)
	
	-- Delete old bags
	print("Delete old bags: " .. #masterBag.Children)
	for i = #masterBag.Children, 1, -1 do
		if masterBag.Children[i] then
			masterBag.Children[i]:DeleteBag()
			print("Deleting child: " .. i)
		end
	end

	-- Spawn new bags
	print("Spawn new bags")
	do
		local cnt = 0
		for _,v in pairs(oldBagData) do
			cnt = cnt + 1
			ns.BagFrame:New(v,cnt)
			print("Spawning bag: " .. cnt)
		end
	end

	-- Rearrange items
	print("Rearrange items")
	local locked = {}
	for _,v in pairs(virtItemSlots) do
		local fromBag, fromSlot
		local fromFound = false

		-- Check if item is alreadt in place, in which case we can skip it
		local skip = false
		self:IterateBagTree(function(bag)
			local gridView = bag.GridView

			for i = 1, #gridView.items do
				local virt = gridView.items[i]:GetVirtualIdentifier()

				if bag.IsMasterBag then -- Special case, always bag 0 for defragging
					local _, slotId = ns.BagSlot.DecodeSlotIdentifier(virt)
					virt = ns.BagSlot.EncodeSlotIdentifier(0, slotId)
				end

				if virt == v.virt then
					local b, s = ns.BagSlot.DecodeSlotIdentifier(gridView.items[i]:GetPhysicalIdentifier())
					local _, itemCount, _, _, _, _, _, _, _, itemId = GetContainerItemInfo(b,s)

					if itemId == v.itemId and itemCount == v.itemCount then
						print("Item is in place, skipping")
						skip = true
						locked[ns.BagSlot.EncodeSlotIdentifier(b, s)] = true
						return true
					end
				end
			end
		end)

		if not skip then
			print("Item is not in place, moving")

			-- Iterate through bags to find correct items
			self:IterateBagTree(function(bag)
				local gridView = bag.GridView

				for i = 1, #gridView.items do
					local physId = gridView.items[i]:GetPhysicalIdentifier()
					if not locked[physId] then
						local b, s = ns.BagSlot.DecodeSlotIdentifier(physId)
						local _, itemCount, _, _, _, _, _, _, _, itemId = GetContainerItemInfo(b, s)

						if itemId == v.itemId and itemCount == v.itemCount then
							fromBag	= b
							fromSlot = s
							fromFound = true
							return true
						end
					end
				end
			end)

			if fromFound then
				local toBag, toSlot
				local toFound

				-- Find "to"
				self:IterateBagTree(function(bag)
					local gridView = bag.GridView

					for i = 1, #gridView.items do
						local virt = gridView.items[i]:GetVirtualIdentifier()

						if bag.IsMasterBag then -- Special case, always bag 0 for defragging
							local _, slotId = ns.BagSlot.DecodeSlotIdentifier(virt)
							virt = ns.BagSlot.EncodeSlotIdentifier(0, slotId)
						end

						if virt == v.virt then
							toBag, toSlot = ns.BagSlot.DecodeSlotIdentifier(gridView.items[i]:GetPhysicalIdentifier())
							toFound = true
							return true
						end
					end
				end)

				if toFound and not (fromBag == toBag and fromSlot == toSlot) then
					-- TODO: Could skip swap slot if "to" slot is empty
					-- TODO: Could skip swap slot if item in "to" is of different itemId than "from"
					-- TODO: Could skip swap slot if itemID in "to" doesn't stack with "from", even if the itemID is equal

					ItemSwap(fromBag, fromSlot, swapBag, swapSlot)
					ItemSwap(toBag, toSlot, fromBag, fromSlot)
					ItemSwap(swapBag, swapSlot, toBag, toSlot)

					repeat
						local _, _, locked1 = GetContainerItemInfo(swapBag, swapSlot)
						local _, _, locked2 = GetContainerItemInfo(toBag, toSlot)

						if locked1 or locked2 then
							coroutine.yield()
						end
					until not (locked1 or locked2)

					locked[ns.BagSlot.EncodeSlotIdentifier(toBag, toSlot)] = true
					coroutine.yield()
				else
					print("Failed to find to")
				end
			end
		end
	end
end
