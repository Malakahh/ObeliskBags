local addonName, ns = ...

local libStack = ObeliskFrameworkManager:GetLibrary("ObeliskCollectionsStack", 0)
if not libStack then
	print("libStack not gotten")
end

local frame = CreateFrame("FRAME")
frame:SetScript("OnEvent", function(self, event, ...) self[event](self, ...) end)
frame:RegisterEvent("PLAYER_LOGIN")

local manager = {}
manager.slotStack = libStack()

function frame:PLAYER_LOGIN( ... )
	for i = 0, 4 do -- Iterate through player bags
		local numSlots = GetContainerNumSlots(i)
		if numSlots > 0 then
			for slot = 1, numSlots do
				manager.slotStack:Push(_G["ContainerFrame" .. (i + 1) .. "Item" .. slot])
			end
		end
	end	
end

ns.ContainerSlotManager = manager