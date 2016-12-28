transmogOutfitRadioButtons = {}

function transmogOutfitFrameOnEvent(self, event, arg1)
	if event == "ADDON_LOADED" and arg1 == "TransmogOutfits" then
		self:UnregisterEvent("ADDON_LOADED")
		if transmogOutfitOutfits == nil then
			transmogOutfitOutfits = {}
		end
	elseif event == "TRANSMOGRIFY_OPEN" then
		WardrobeOutfitDropDown:Hide()
		transmogOutfitFrameCreate(self)
	elseif event == "TRANSMOGRIFY_CLOSE" then
		transmogOutfitNewFrame:Hide()
		transmogOutfitSelectFrame:Hide()
	end
end

function transmogOutfitButtonOnClick(self)
	if self == transmogOutfitNewButton then
		transmogOutfitNewFrame:Show()
	elseif self == transmogOutfitSelectButton then
		transmogOutfitSelectFrame:Show()
	elseif self == transmogOutfitSaveButton then
		TransmogOutfitUpdateOutfit()
	elseif self == transmogOutfitNewDoneButton then
		TransmogOutfitNewOutfit()
	elseif self == transmogOutfitSelectRemoveButton then
		TransmogOutfitRemoveOutfit()
	elseif self == transmogOutfitSelectDoneButton then
		TransmogOutfitSelectOutfit()
	elseif self == transmogOutfitNewCancelButton then
		transmogOutfitNewFrame:Hide()
	end
end

function transmogOutfitSelectScrollFrameOnShow(self)
	local frame = CreateFrame("FRAME", nil, self)
	frame:SetWidth(100)
	frame:SetHeight(table.getn(transmogOutfitOutfits) * 15)
	for i = 1, table.getn(transmogOutfitOutfits) do
		transmogOutfitRadioButtons[i] = CreateFrame("CHECKBUTTON", nil, frame, "UIRadioButtonTemplate")
		TransmogOutfitSetupRadioButton(transmogOutfitRadioButtons[i], transmogOutfitOutfits[i]["name"])
		transmogOutfitRadioButtons[i]:SetPoint("BOTTOM", frame, "TOPLEFT", 15, i * -15)
	end
	self:SetScrollChild(frame)
end

function transmogOutfitSelectScrollFrameOnHide(self)
	for i = 1, table.getn(transmogOutfitRadioButtons) do
		transmogOutfitRadioButtons[i]:Hide()
		transmogOutfitRadioButtons[i] = nil
	end
	transmogOutfitRadioButtons = {}
end

function transmogOutfitRadioButtonOnClick(self)
	for i = 1, table.getn(transmogOutfitRadioButtons) do
		transmogOutfitRadioButtons[i]:SetChecked(false)
	end
	self:SetChecked(true)
end

function TransmogOutfitSetupRadioButton(button, name)
	local text = button:CreateFontString(nil, "OVERLAY", "GameFontWhite")
	button:SetWidth(15)
	button:SetHeight(15)
	if name == transmogOutfitNameText:GetText() then
		button:SetChecked(true)
	end
	button:SetScript("OnClick", transmogOutfitRadioButtonOnClick)
	text:ClearAllPoints()
	text:SetPoint("LEFT", button, "RIGHT")
	text:SetJustifyH("CENTER")
	text:SetJustifyV("CENTER")
	text:SetText(name)
end

function TransmogOutfitGetCheckedButton()
	for i = 1, table.getn(transmogOutfitRadioButtons) do
		if transmogOutfitRadioButtons[i]:GetChecked() then
			return i
		end
	end
	return nil
end

function TransmogOutfitFindName(name)
	for i = 1, table.getn(transmogOutfitOutfits) do
		if transmogOutfitOutfits[i]["name"] == name then
			return i
		end
	end
	return nil
end

function TransmogOutfitUpdateOutfit()
	local name = transmogOutfitNameText:GetText()
	local index = TransmogOutfitFindName(name)
	if index > 0 then
		local outfit = {}
		outfit["name"] = name
		outfit[1] = TransmogOutfitGetTransmog(1)
		outfit[3] = TransmogOutfitGetTransmog(3)
		outfit[4] = TransmogOutfitGetTransmog(4)
		outfit[5] = TransmogOutfitGetTransmog(5)
		outfit[6] = TransmogOutfitGetTransmog(6)
		outfit[7] = TransmogOutfitGetTransmog(7)
		outfit[8] = TransmogOutfitGetTransmog(8)
		outfit[9] = TransmogOutfitGetTransmog(9)
		outfit[10] = TransmogOutfitGetTransmog(10)
		outfit[15] = TransmogOutfitGetTransmog(15)
		outfit[16] = TransmogOutfitGetTransmog(16)
		outfit[17] = TransmogOutfitGetTransmog(17)
		outfit[19] = TransmogOutfitGetTransmog(19)
		outfit["enchant1"] = TransmogOutfitGetEnchant(16)
		outfit["enchant2"] = TransmogOutfitGetEnchant(17)
		transmogOutfitOutfits[index] = outfit
	end
end

function TransmogOutfitNewOutfit()
	local name = transmogOutfitNewNameBox:GetText()
	local number = table.getn(transmogOutfitOutfits)
	transmogOutfitNewNameBox:SetText("")
	if name ~= "" and TransmogOutfitFindName(name) == nil then
		local outfit = {}
		transmogOutfitNameText:SetText(name)
		outfit["name"] = name
		outfit[1] = TransmogOutfitGetTransmog(1)
		outfit[3] = TransmogOutfitGetTransmog(3)
		outfit[4] = TransmogOutfitGetTransmog(4)
		outfit[5] = TransmogOutfitGetTransmog(5)
		outfit[6] = TransmogOutfitGetTransmog(6)
		outfit[7] = TransmogOutfitGetTransmog(7)
		outfit[8] = TransmogOutfitGetTransmog(8)
		outfit[9] = TransmogOutfitGetTransmog(9)
		outfit[10] = TransmogOutfitGetTransmog(10)
		outfit[15] = TransmogOutfitGetTransmog(15)
		outfit[16] = TransmogOutfitGetTransmog(16)
		outfit[17] = TransmogOutfitGetTransmog(17)
		outfit[19] = TransmogOutfitGetTransmog(19)
		outfit["enchant1"] = TransmogOutfitGetEnchant(16)
		outfit["enchant2"] = TransmogOutfitGetEnchant(17)
		transmogOutfitOutfits[number + 1] = outfit
		transmogOutfitNewFrame:Hide()
	end
end

function TransmogOutfitRemoveOutfit()
	local index = TransmogOutfitGetCheckedButton()
	if index > 0 then
		table.remove(transmogOutfitOutfits, index)
	end
	transmogOutfitSelectScrollFrame:Hide()
	transmogOutfitSelectScrollFrame:Show()
end

function TransmogOutfitSelectOutfit()
	local index = TransmogOutfitGetCheckedButton()
	local outfit = transmogOutfitOutfits[index]
	transmogOutfitNameText:SetText(outfit["name"])
	TransmogOutfitSetTransmog(1, outfit[1])
	TransmogOutfitSetTransmog(3, outfit[3])
	TransmogOutfitSetTransmog(4, outfit[4])
	TransmogOutfitSetTransmog(5, outfit[5])
	TransmogOutfitSetTransmog(6, outfit[6])
	TransmogOutfitSetTransmog(7, outfit[7])
	TransmogOutfitSetTransmog(8, outfit[8])
	TransmogOutfitSetTransmog(9, outfit[9])
	TransmogOutfitSetTransmog(10, outfit[10])
	TransmogOutfitSetTransmog(15, outfit[15])
	TransmogOutfitSetTransmog(16, outfit[16])
	TransmogOutfitSetTransmog(17, outfit[17])
	TransmogOutfitSetTransmog(19, outfit[19])
	TransmogOutfitSetEnchant(16, outfit["enchant1"])
	TransmogOutfitSetEnchant(17, outfit["enchant2"])
	transmogOutfitSelectFrame:Hide()
end

function TransmogOutfitGetTransmog(slot)
	local transmog
	local baseSourceID, _, appliedSourceID, _, pendingSourceID, _, hasPendingUndo = C_Transmog.GetSlotVisualInfo(slot, LE_TRANSMOG_TYPE_APPEARANCE)
	if hasPendingUndo then
		transmog = baseSourceID
	elseif pendingSourceID ~= 0 then
		transmog = pendingSourceID
	elseif appliedSourceID ~= 0 then
		transmog = appliedSourceID
	else
		transmog = baseSourceID
	end
	return transmog
end

function TransmogOutfitSetTransmog(slot, transmog)
	local _, _, _, canTransmogrify = C_Transmog.GetSlotInfo(slot, LE_TRANSMOG_TYPE_APPEARANCE)
	if canTransmogrify then
		C_Transmog.SetPending(slot, LE_TRANSMOG_TYPE_APPEARANCE, transmog)
	end
end

function TransmogOutfitGetEnchant(slot)
	local enchant
	local baseSourceID, _, appliedSourceID, _, pendingSourceID, _, hasPendingUndo = C_Transmog.GetSlotVisualInfo(slot, LE_TRANSMOG_TYPE_ILLUSION)
	if hasPendingUndo then
		enchant = baseSourceID
	elseif pendingSourceID ~= 0 then
		enchant = pendingSourceID
	elseif appliedSourceID ~= 0 then
		enchant = appliedSourceID
	else
		enchant = baseSourceID
	end
	return enchant
end

function TransmogOutfitSetEnchant(slot, enchant)
	local _, _, _, canTransmogrify = C_Transmog.GetSlotInfo(slot, LE_TRANSMOG_TYPE_ILLUSION)
	if canTransmogrify then
		C_Transmog.SetPending(slot, LE_TRANSMOG_TYPE_ILLUSION, enchant)
	end
end

function transmogOutfitFrameCreate(frame)
	if WardrobeTransmogFrame:IsVisible() then
		frame:SetFrameStrata("TOOLTIP")
		frame:SetWidth(WardrobeTransmogFrame:GetWidth()) 
		frame:SetHeight(50)
		frame:ClearAllPoints()
		frame:SetPoint("BOTTOMRIGHT", WardrobeTransmogFrame, "TOPRIGHT", 0, 0)
		frame:SetParent(WardrobeTransmogFrame)
		frame:Show()
		TransmogOutfitSetupNameFrame(transmogOutfitNameFrame, transmogOutfitNameText)
	end
end

function TransmogOutfitSetupNameFrame(frame, text)
	frame:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
					   edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
					   tile = true,
					   tileSize = 16,
					   edgeSize = 16, 
					   insets = {left = 1,
								 right = 1,
								 top = 1,
								 bottom = 1}}) 
	frame:SetBackdropColor(0, 0, 0, 1)
	frame:SetWidth(WardrobeTransmogFrame:GetWidth() - 100) 
	frame:SetHeight(25)
	text:ClearAllPoints()
	text:SetAllPoints(frame) 
	text:SetJustifyH("CENTER")
	text:SetJustifyV("CENTER")
	text:SetText("No Outfit")
	frame:Show()
end

function TransmogOutfitSetupButton(button, text)
	button:SetText(text)
	button:SetHeight(25)
	button:SetWidth(100)
	button:ClearAllPoints()
	button:SetScript("OnClick", transmogOutfitButtonOnClick)
	button:Show()
end

function TransmogOutfitSetupPopupFrame(frame, width, height)
	frame:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
					   edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
					   tile = true,
					   tileSize = 16,
					   edgeSize = 16, 
					   insets = {left = 1,
								 right = 1,
								 top = 1,
								 bottom = 1}}) 
	frame:SetFrameStrata("TOOLTIP")
	frame:SetBackdropColor(0, 0, 0, 1)
	frame:SetWidth(width) 
	frame:SetHeight(height)
	frame:Hide()
end

function TransmogOutfitSetupEditBox(editBox)
	editBox:SetWidth(200)
	editBox:SetHeight(25)
	editBox:ClearAllPoints()
	editBox:Show()
end

function TransmogOutfitSetupScrollFrame(scrollFrame)
	scrollFrame:SetWidth(100)
	scrollFrame:SetHeight(200)
	scrollFrame:ClearAllPoints()
	scrollFrame:SetScript("OnShow", transmogOutfitSelectScrollFrameOnShow)
	scrollFrame:SetScript("OnHide", transmogOutfitSelectScrollFrameOnHide)
	scrollFrame:Show()
end

local transmogOutfitFrame = CreateFrame("FRAME", nil, UIParent)
transmogOutfitFrame:RegisterEvent("ADDON_LOADED")
transmogOutfitFrame:RegisterEvent("TRANSMOGRIFY_OPEN")
transmogOutfitFrame:RegisterEvent("TRANSMOGRIFY_CLOSE")
transmogOutfitFrame:SetScript("OnEvent", transmogOutfitFrameOnEvent)
transmogOutfitNameFrame = CreateFrame("FRAME", nil, transmogOutfitFrame)
transmogOutfitNameText = transmogOutfitNameFrame:CreateFontString(nil, "OVERLAY", "GameFontWhite")
transmogOutfitNameFrame:SetPoint("TOP", transmogOutfitFrame, "TOP")
transmogOutfitNewButton = CreateFrame("BUTTON", nil, transmogOutfitFrame, "UIPanelButtonTemplate")
TransmogOutfitSetupButton(transmogOutfitNewButton, "New")
transmogOutfitNewButton:SetPoint("BOTTOMLEFT", transmogOutfitFrame, "BOTTOMLEFT")
transmogOutfitSelectButton = CreateFrame("BUTTON", nil, transmogOutfitFrame, "UIPanelButtonTemplate")
TransmogOutfitSetupButton(transmogOutfitSelectButton, "Select")
transmogOutfitSelectButton:SetPoint("BOTTOM", transmogOutfitFrame, "BOTTOM")
transmogOutfitSaveButton = CreateFrame("BUTTON", nil, transmogOutfitFrame, "UIPanelButtonTemplate")
TransmogOutfitSetupButton(transmogOutfitSaveButton, "Save")
transmogOutfitSaveButton:SetPoint("BOTTOMRIGHT", transmogOutfitFrame, "BOTTOMRIGHT")

transmogOutfitNewFrame = CreateFrame("FRAME", nil, UIParent)
TransmogOutfitSetupPopupFrame(transmogOutfitNewFrame, 250, 100)
transmogOutfitNewFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
transmogOutfitNewNameBox = CreateFrame("EDITBOX", nil, transmogOutfitNewFrame, "InputBoxTemplate")
TransmogOutfitSetupEditBox(transmogOutfitNewNameBox)
transmogOutfitNewNameBox:SetPoint("CENTER", transmogOutfitNewFrame, "CENTER", 0, 25)
transmogOutfitNewDoneButton = CreateFrame("BUTTON", nil, transmogOutfitNewFrame, "UIPanelButtonTemplate")
TransmogOutfitSetupButton(transmogOutfitNewDoneButton, "Done")
transmogOutfitNewDoneButton:SetPoint("CENTER", transmogOutfitNewFrame, "CENTER", -50, -25)
transmogOutfitNewCancelButton = CreateFrame("BUTTON", nil, transmogOutfitNewFrame, "UIPanelButtonTemplate")
TransmogOutfitSetupButton(transmogOutfitNewCancelButton, "Cancel")
transmogOutfitNewCancelButton:SetPoint("CENTER", transmogOutfitNewFrame, "CENTER", 50, -25)

transmogOutfitSelectFrame = CreateFrame("FRAME", nil, UIParent)
TransmogOutfitSetupPopupFrame(transmogOutfitSelectFrame, 150, 300)
transmogOutfitSelectFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
transmogOutfitSelectRemoveButton = CreateFrame("BUTTON", nil, transmogOutfitSelectFrame, "UIPanelButtonTemplate")
TransmogOutfitSetupButton(transmogOutfitSelectRemoveButton, "Remove")
transmogOutfitSelectRemoveButton:SetPoint("CENTER", transmogOutfitSelectFrame, "TOP", 0, -25)
transmogOutfitSelectScrollFrame = CreateFrame("SCROLLFRAME", nil, transmogOutfitSelectFrame, "UIPanelScrollFrameTemplate")
TransmogOutfitSetupScrollFrame(transmogOutfitSelectScrollFrame)
transmogOutfitSelectScrollFrame:SetPoint("CENTER", transmogOutfitSelectFrame, "CENTER")
transmogOutfitSelectDoneButton = CreateFrame("BUTTON", nil, transmogOutfitSelectFrame, "UIPanelButtonTemplate")
TransmogOutfitSetupButton(transmogOutfitSelectDoneButton, "Done")
transmogOutfitSelectDoneButton:SetPoint("CENTER", transmogOutfitSelectFrame, "BOTTOM", 0, 25)