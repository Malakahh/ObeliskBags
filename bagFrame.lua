local addonName, ns = ...

local libGridView = ObeliskFrameworkManager:GetLibrary("ObeliskGridView", 1)
if not libGridView then
	print("libGridView not gotten")
end

ns.bagFrame = CreateFrame("FRAME")
ns.bagFrame:SetPoint("CENTER")
ns.bagFrame:SetBackdrop({
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true,
	tileSize = 16,
	edgeSize = 16,
	insets = { left = 4, right = 4, top = 4, bottom = 4}
	})
ns.bagFrame:SetBackdropColor(0, 0, 0, 1)
ns.bagFrame:SetClampedToScreen(true)

ns.bagFrame:SetSize(200, 400)

ns.bagFrame:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
ns.bagFrame:RegisterEvent("BAG_UPDATE")

local cellSize = 24

ns.bagFrame.gridView = libGridView(0, 0, "GridView", ns.bagFrame)
ns.bagFrame.gridView:SetPoint("TOPLEFT", 0, 0)
ns.bagFrame.gridView:SetPoint("BOTTOMRIGHT", 0, 0)
ns.bagFrame.gridView:SetCellSize(cellSize, cellSize)


-- ns.bagFrame.slot = ns.BagSlot:New(1,1,ns.bagFrame)
-- ns.bagFrame.slot:ClearAllPoints()
-- ns.bagFrame.slot:SetPoint("CENTER")
-- ns.bagFrame.slot:SetSize(32, 32)
-- ns.bagFrame.slot2 = ns.BagSlot:New(ns.bagFrame)
-- ns.bagFrame.slot2:ClearAllPoints()
-- ns.bagFrame.slot2:SetPoint("CENTER")
-- ns.bagFrame.slot2:SetSize(32, 32)

--ns.bagFrame.slot.testlol = ns.bagFrame.slot:CreateTexture(nil, "BACKGROUND")
--ns.bagFrame.slot.testlol:SetColorTexture(1,0,1,0.5)
-- ns.bagFrame.slot.testlol:SetAllPoints()


-- function ns.bagFrame:OnShow()
-- 	local bagNum, slotNum;
-- 	for bagNum = 0, 4 do
-- 		local maxNumSlots = GetContainerNumSlots(bagNum)
-- 		local slotNum
-- 		for slotNum = 0, maxNumSlots do
-- 			local slot = _G["ContainerFrame"..bagNum.."Item"..slotNum]
-- 			if slot ~= nil then
-- 				slot:SetSize(cellSize, cellSize)
-- 				self.gridView:AddItem(slot)
-- 			end
-- 		end
-- 	end
-- 	self.gridView:Update()
-- end

local slots = {}

local bagNum
for bagNum = BACKPACK_CONTAINER, NUM_BAG_SLOTS do
	local maxNumSlots = GetContainerNumSlots(bagNum)
	local slotNum
	for slotNum = 1, maxNumSlots do
		local slot = ns.BagSlot:New(bagNum, slotNum, ns.bagFrame)
		slot:SetSize(cellSize, cellSize)
		ns.bagFrame.gridView:AddItem(slot)
		slots[slot:GetIdentifier()] = slot
	end
end
ns.bagFrame.gridView:SetNumColumns(5)
ns.bagFrame.gridView:Update()
ns.bagFrame.gridView:Show()


function ns.bagFrame:BAG_UPDATE(bagNum)
	local maxNumSlots = GetContainerNumSlots(bagNum)
	local i
	for i = 1, maxNumSlots do
		local itemId = GetContainerItemID(bagNum, slots[bagNum .. i].ItemSlot:GetID())
		local icon = GetItemIcon(itemId)
		
		slots[bagNum .. i]:SetIcon(icon)
	end


	-- self.slot:SetIcon(icon)

	--self.slot.icon:SetTexture(icon)
	--SetItemButtonTexture(self.slot.icon, icon)
	--SetItemButtonTextureVertexColor(self.slot.icon, 1, 1, 1)
end

function ns.bagFrame:ToggleBags()
	if self:IsShown() then
		self:Hide()
	else
		self:Show()
		self:OnShow()
	end
end