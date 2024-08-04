transmogOutfitSelect = false
transmogOutfitSets = false
transmogOutfitPage = 1
transmogOutfitWardrobeTab = 1
transmogOutfitNumPages = 1
transmogOutfitCurrentOutfit = 1
transmogOutfitFoundOutfits = {}
transmogOutfitFoundBlizzardOutfits = 0

local transmogOutfitsMaleTranslate = {["Human"]              = 1.00,
									  ["Orc"]                = 1.20,
									  ["Dwarf"]              = 1.00,
									  ["Scourge"]            = 1.10,
									  ["NightElf"]           = 1.30,
									  ["Tauren"]             = 1.75,
									  ["Gnome"]              = 0.70,
									  ["Troll"]              = 0.85,
									  ["Draenei"]            = 1.50,
									  ["BloodElf"]           = 1.10,
									  ["Worgen"]             = 1.05,
									  ["Goblin"]             = 0.70,
									  ["Pandaren"]           = 1.60,
									  ["VoidElf"]            = 1.10,
									  ["Nightborne"]         = 1.20,
									  ["LightforgedDraenei"] = 1.50,
									  ["HighmountainTauren"] = 1.75,
									  ["DarkIronDwarf"]      = 1.00,
									  ["MagharOrc"]          = 1.20,
									  ["KulTiran"]           = 1.35,
									  ["ZandalariTroll"]     = 1.45,
									  ["Mechagnome"]         = 0.85,
									  ["Vulpera"]            = 0.95,
									  ["Dracthyr"]			 = 2.30,
									  ["EarthenDwarf"]       = 1.00}
							  
local transmogOutfitsFemaleTranslate = {["Human"]              = 1.00,
										["Orc"]                = 1.20,
										["Dwarf"]              = 0.85,
										["Scourge"]            = 0.85,
										["NightElf"]           = 1.20,
										["Tauren"]             = 1.75,
										["Gnome"]              = 0.85,
										["Troll"]              = 1.30,
										["Draenei"]            = 1.35,
										["BloodElf"]           = 1.05,
										["Worgen"]             = 1.25,
										["Goblin"]             = 0.95,
										["Pandaren"]           = 1.50,
										["VoidElf"]            = 1.05,
										["Nightborne"]         = 1.10,
										["LightforgedDraenei"] = 1.35,
										["HighmountainTauren"] = 1.75,
										["DarkIronDwarf"]      = 0.85,
										["MagharOrc"]          = 1.20,
										["KulTiran"]           = 1.30,
										["ZandalariTroll"]     = 1.65,
										["Mechagnome"]         = 0.85,
										["Vulpera"]            = 1.05,
										["Dracthyr"]		   = 2.30,
										["EarthenDwarf"]       = 1.00}

function transmogOutfitFrameOnEvent(self, event, arg1)
	if event == "ADDON_LOADED" and arg1 == "TransmogOutfits" then
		self:UnregisterEvent("ADDON_LOADED")
		if transmogOutfitOutfits == nil then
			transmogOutfitOutfits = {}
		end
	elseif event == "TRANSMOGRIFY_UPDATE" and WardrobeTransmogFrame ~= nil and WardrobeTransmogFrame:IsVisible() then
		transmogOutfitFrameCreate(self)
		self:UnregisterEvent("TRANSMOGRIFY_UPDATE")
	elseif event == "TRANSMOGRIFY_CLOSE" then
		if transmogOutfitNewFrame ~= nil then
			transmogOutfitNewFrame:Hide()
		end
		if transmogOutfitSelectFrame ~= nil then
			transmogOutfitSelectFrame:Hide()
		end
		if transmogOutfitRemoveFrame ~= nil then
			transmogOutfitRemoveFrame:Hide()
		end
		transmogOutfitSelect = false
		transmogOutfitSets = false
		WardrobeCollectionFrame.FilterButton:Show()
		WardrobeCollectionFrame:SetTab(1)
		self:RegisterEvent("TRANSMOGRIFY_UPDATE")
	end
end

function transmogOutfitDropDownOnLoad()
	local renameOutfit = {}
	renameOutfit.text = "Rename"
	renameOutfit.value = 1
	renameOutfit.func = transmogOutfitDropDownOnClick
	local removeOutfit = {}
	removeOutfit.text = "Remove"
	removeOutfit.value = 2
	removeOutfit.func = transmogOutfitDropDownOnClick
	UIDropDownMenu_AddButton(renameOutfit)
	UIDropDownMenu_AddButton(removeOutfit)
end

function transmogOutfitDropDownOnClick(value)
	if value.value == 1 then
		transmogOutfitRenameFrame:Show()
	elseif value.value == 2 then
		TransmogOutfitRemoveOutfit()
	end
end

function transmogOutfitShowSelectFrame()
	transmogOutfitSets = WardrobeCollectionFrame.SetsTransmogFrame:IsVisible()
	WardrobeCollectionFrame.ItemsCollectionFrame:Hide()
	WardrobeCollectionFrame.SetsTransmogFrame:Hide()
	WardrobeCollectionFrame.FilterButton:Hide()
	transmogOutfitWardrobeTab = WardrobeCollectionFrame.selectedTransmogTab
	WardrobeCollectionFrame:SetTab(0)
	WardrobeCollectionFrameSearchBox:Hide()
	local scale = WardrobeTransmogFrame.ModelScene:GetPlayerActor():GetScale()
	local _, race = UnitRace("player")
	local sex = UnitSex("player")
	local _, alteredForm = C_PlayerInfo.GetAlternateFormInfo()
	local zoom = 0
	if race == "Dracthyr" and not alteredForm then
		zoom = 1
	end
	for i = 1, 8 do
		transmogOutfitModels[i]:SetCameraPosition(WardrobeTransmogFrame.ModelScene:GetCameraPosition())
		transmogOutfitModels[i].actor:SetModelByUnit("player", false, true, false, not alteredForm)
		transmogOutfitModels[i]:SetPaused(true)
		local file = transmogOutfitModels[i].actor:GetModelFileID()
		if file == 1011653 or file == 1000764 or file == 4220448 then
			race = "Human"
		elseif file == 4395382 then
			race = "BloodElf"
		end
		transmogOutfitModels[i].actor:SetScale(scale)
		if sex == 2 then
			transmogOutfitModels[i].actor:SetPosition(transmogOutfitsMaleTranslate[race], zoom, 0)
		elseif sex == 3 then
			transmogOutfitModels[i].actor:SetPosition(transmogOutfitsFemaleTranslate[race], zoom, 0)
		end
	end
	transmogOutfitSelectFrame:Show()
	transmogOutfitSelect = true
end

function transmogOutfitHideSelectFrame()
	if transmogOutfitSets then
		WardrobeCollectionFrame.SetsTransmogFrame:Show()
	else
		WardrobeCollectionFrame.ItemsCollectionFrame:Show()
	end
	WardrobeCollectionFrame.FilterButton:Show()
	WardrobeCollectionFrame:SetTab(transmogOutfitWardrobeTab)
	WardrobeCollectionFrameSearchBox:Show()
	transmogOutfitSelectFrame:Hide()
	transmogOutfitSelect = false
end

function transmogOutfitButtonOnClick(self)
	if self == transmogOutfitNewButton then
		transmogOutfitNewFrame:Show()
	elseif self == transmogOutfitSelectButton then
		if transmogOutfitSelect then
			transmogOutfitHideSelectFrame()
		else
			transmogOutfitShowSelectFrame()
		end
	elseif self == transmogOutfitSaveButton then
		TransmogOutfitUpdateOutfit()
	elseif self == transmogOutfitRandomButton then
		TransmogOutfitRandomOutfit()
	elseif self == transmogOutfitDoneButton then
		transmogOutfitHideSelectFrame()
	elseif self == transmogOutfitNewDoneButton then
		TransmogOutfitNewOutfit()
	elseif self == transmogOutfitNewCancelButton then
		transmogOutfitNewFrame:Hide()
	elseif self == transmogOutfitSelectSearchButton then
		TransmogOutfitSearchOutfit()
	elseif self == transmogOutfitSelectSortButton then
		TransmogOutfitSortOutfit()
	elseif self == transmogOutfitRemoveYesButton then
		TransmogOutfitRemoveYes()
	elseif self == transmogOutfitRemoveNoButton then
		transmogOutfitRemoveFrame:Hide()
	elseif self == transmogOutfitPrevPageButton then
		TransmogOutfitPrevPage()
	elseif self == transmogOutfitNextPageButton then
		TransmogOutfitNextPage()
	elseif self == transmogOutfitRenameDoneButton then
		TransmogOutfitRenameDone()
	elseif self == transmogOutfitRenameCancelButton then
		transmogOutfitRenameFrame:Hide()
	end
end

function TransmogOutfitFindBlizzardOutfit(name)
	local blizzardOutfits = C_TransmogCollection.GetOutfits()
	for i = 1, table.getn(blizzardOutfits) do
		if C_TransmogCollection.GetOutfitInfo(blizzardOutfits[i]) == name then
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
	local blizzardOutfits = C_TransmogCollection.GetOutfits()
	local index = TransmogOutfitFindBlizzardOutfit(name)
	if index ~= nil then
		local outfit = WardrobeOutfitDropdownOverrideMixin:GetItemTransmogInfoList()
		C_TransmogCollection.ModifyOutfit(blizzardOutfits[index], outfit)
	else
		index = TransmogOutfitFindName(name)
		if index ~= nil then
			local outfit = {}
			outfit["name"] = name
			outfit[1] = TransmogOutfitGetTransmog(TransmogUtil.GetTransmogLocation("HEADSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main))
			outfit[3] = TransmogOutfitGetTransmog(TransmogUtil.GetTransmogLocation("SHOULDERSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main))
			outfit[33] = TransmogOutfitGetTransmog(TransmogUtil.GetTransmogLocation("SHOULDERSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Secondary))
			outfit[4] = TransmogOutfitGetTransmog(TransmogUtil.GetTransmogLocation("SHIRTSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main))
			outfit[5] = TransmogOutfitGetTransmog(TransmogUtil.GetTransmogLocation("CHESTSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main))
			outfit[6] = TransmogOutfitGetTransmog(TransmogUtil.GetTransmogLocation("WAISTSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main))
			outfit[7] = TransmogOutfitGetTransmog(TransmogUtil.GetTransmogLocation("LEGSSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main))
			outfit[8] = TransmogOutfitGetTransmog(TransmogUtil.GetTransmogLocation("FEETSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main))
			outfit[9] = TransmogOutfitGetTransmog(TransmogUtil.GetTransmogLocation("WRISTSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main))
			outfit[10] = TransmogOutfitGetTransmog(TransmogUtil.GetTransmogLocation("HANDSSLOT" ,Enum.TransmogType.Appearance, Enum.TransmogModification.Main))
			outfit[15] = TransmogOutfitGetTransmog(TransmogUtil.GetTransmogLocation("BACKSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main))
			outfit[16] = TransmogOutfitGetTransmog(TransmogUtil.GetTransmogLocation("MAINHANDSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main))
			outfit[17] = TransmogOutfitGetTransmog(TransmogUtil.GetTransmogLocation("SECONDARYHANDSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main))
			outfit[19] = TransmogOutfitGetTransmog(TransmogUtil.GetTransmogLocation("TABARDSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main))
			outfit["enchant1"] = TransmogOutfitGetTransmog(TransmogUtil.GetTransmogLocation("MAINHANDSLOT", Enum.TransmogType.Illusion, Enum.TransmogModification.Main))
			outfit["enchant2"] = TransmogOutfitGetTransmog(TransmogUtil.GetTransmogLocation("SECONDARYHANDSLOT", Enum.TransmogType.Illusion, Enum.TransmogModification.Main))
			transmogOutfitOutfits[index] = outfit
		end
	end
	if transmogOutfitSelectFrame:IsVisible() then
		transmogOutfitSelectFrame:Hide()
		transmogOutfitSelectFrame:Show()
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
		outfit[1] = TransmogOutfitGetTransmog(TransmogUtil.GetTransmogLocation("HEADSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main))
		outfit[3] = TransmogOutfitGetTransmog(TransmogUtil.GetTransmogLocation("SHOULDERSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main))
		outfit[33] = TransmogOutfitGetTransmog(TransmogUtil.GetTransmogLocation("SHOULDERSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Secondary))
		outfit[4] = TransmogOutfitGetTransmog(TransmogUtil.GetTransmogLocation("SHIRTSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main))
		outfit[5] = TransmogOutfitGetTransmog(TransmogUtil.GetTransmogLocation("CHESTSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main))
		outfit[6] = TransmogOutfitGetTransmog(TransmogUtil.GetTransmogLocation("WAISTSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main))
		outfit[7] = TransmogOutfitGetTransmog(TransmogUtil.GetTransmogLocation("LEGSSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main))
		outfit[8] = TransmogOutfitGetTransmog(TransmogUtil.GetTransmogLocation("FEETSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main))
		outfit[9] = TransmogOutfitGetTransmog(TransmogUtil.GetTransmogLocation("WRISTSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main))
		outfit[10] = TransmogOutfitGetTransmog(TransmogUtil.GetTransmogLocation("HANDSSLOT" ,Enum.TransmogType.Appearance, Enum.TransmogModification.Main))
		outfit[15] = TransmogOutfitGetTransmog(TransmogUtil.GetTransmogLocation("BACKSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main))
		outfit[16] = TransmogOutfitGetTransmog(TransmogUtil.GetTransmogLocation("MAINHANDSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main))
		outfit[17] = TransmogOutfitGetTransmog(TransmogUtil.GetTransmogLocation("SECONDARYHANDSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main))
		outfit[19] = TransmogOutfitGetTransmog(TransmogUtil.GetTransmogLocation("TABARDSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main))
		outfit["enchant1"] = TransmogOutfitGetTransmog(TransmogUtil.GetTransmogLocation("MAINHANDSLOT", Enum.TransmogType.Illusion, Enum.TransmogModification.Main))
		outfit["enchant2"] = TransmogOutfitGetTransmog(TransmogUtil.GetTransmogLocation("SECONDARYHANDSLOT", Enum.TransmogType.Illusion, Enum.TransmogModification.Main))
		transmogOutfitOutfits[number + 1] = outfit
		transmogOutfitNewFrame:Hide()
	end
	TransmogOutfitSearchOutfit()
end

function TransmogOutfitRandomOutfit()
	local blizzardOutfits = C_TransmogCollection.GetOutfits()
	local number = table.getn(blizzardOutfits) + table.getn(transmogOutfitOutfits)
	local rand = math.random(1, number)
	TransmogOutfitApplyOutfit(rand)
end

function TransmogOutfitSearchOutfit()
	local blizzardOutfits = C_TransmogCollection.GetOutfits()
	transmogOutfitFoundOutfits = {}
	if transmogOutfitSelectSearchBox:GetText() == "" then
		for i = 1, table.getn(blizzardOutfits) do
			transmogOutfitFoundOutfits[i] = {}
			transmogOutfitFoundOutfits[i].index = i
			transmogOutfitFoundOutfits[i].name = C_TransmogCollection.GetOutfitInfo(blizzardOutfits[i])
		end
		transmogOutfitFoundBlizzardOutfits = table.getn(transmogOutfitFoundOutfits)
		for i = 1, table.getn(transmogOutfitOutfits) do
			transmogOutfitFoundOutfits[i + transmogOutfitFoundBlizzardOutfits] = {}
			transmogOutfitFoundOutfits[i + transmogOutfitFoundBlizzardOutfits].index = i + transmogOutfitFoundBlizzardOutfits
			transmogOutfitFoundOutfits[i + transmogOutfitFoundBlizzardOutfits].name = transmogOutfitOutfits[i]["name"]
		end
	else
		local j = 1, name
		for i = 1, table.getn(blizzardOutfits) do
			name = C_TransmogCollection.GetOutfitInfo(blizzardOutfits[i])
			if string.find(name, transmogOutfitSelectSearchBox:GetText()) then
				transmogOutfitFoundOutfits[j] = {}
				transmogOutfitFoundOutfits[j].index = i
				transmogOutfitFoundOutfits[j].name = name
				j = j + 1
			end
		end
		transmogOutfitFoundBlizzardOutfits = table.getn(transmogOutfitFoundOutfits)
		for i = 1, table.getn(transmogOutfitOutfits) do
			if string.find(transmogOutfitOutfits[i]["name"], transmogOutfitSelectSearchBox:GetText()) then
				transmogOutfitFoundOutfits[j] = {}
				transmogOutfitFoundOutfits[j].index = i + transmogOutfitFoundBlizzardOutfits
				transmogOutfitFoundOutfits[j].name = transmogOutfitOutfits[i]["name"]
				j = j + 1
			end
		end
	end
	if transmogOutfitSelectFrame:IsVisible() then
		transmogOutfitSelectFrame:Hide()
		transmogOutfitSelectFrame:Show()
	end
end

function TransmogOutfitSortOutfit()
	local text = transmogOutfitSelectSortButton:GetText()
	if text == "Sort: A-Z" then
		table.sort(transmogOutfitFoundOutfits, function (o1, o2) return string.lower(o1.name) < string.lower(o2.name) end )
		transmogOutfitSelectSortButton:SetText("Sort: Def")
	elseif text == "Sort: Def" then
		table.sort(transmogOutfitFoundOutfits, function (o1, o2) return o1.index < o2.index end )
		transmogOutfitSelectSortButton:SetText("Sort: A-Z")
	end
	if transmogOutfitSelectFrame:IsVisible() then
		transmogOutfitSelectFrame:Hide()
		transmogOutfitSelectFrame:Show()
	end
end

function TransmogOutfitApplyOutfit(index)
	local blizzardOutfits = C_TransmogCollection.GetOutfits()
	if blizzardOutfits[index] ~= nil then
		transmogOutfitNameText:SetText(C_TransmogCollection.GetOutfitInfo(blizzardOutfits[index]))
		C_Transmog.LoadOutfit(blizzardOutfits[index])
	else
		local outfit = transmogOutfitOutfits[index - transmogOutfitFoundBlizzardOutfits]
		if outfit ~= nil then
			transmogOutfitNameText:SetText(outfit["name"])
			TransmogOutfitSetTransmog(TransmogUtil.GetTransmogLocation("HEADSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main), outfit[1])
			TransmogOutfitSetTransmog(TransmogUtil.GetTransmogLocation("SHOULDERSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main), outfit[3])
			TransmogOutfitSetTransmog(TransmogUtil.GetTransmogLocation("SHOULDERSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Secondary), outfit[33])
			TransmogOutfitSetTransmog(TransmogUtil.GetTransmogLocation("SHIRTSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main), outfit[4])
			TransmogOutfitSetTransmog(TransmogUtil.GetTransmogLocation("CHESTSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main), outfit[5])
			TransmogOutfitSetTransmog(TransmogUtil.GetTransmogLocation("WAISTSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main), outfit[6])
			TransmogOutfitSetTransmog(TransmogUtil.GetTransmogLocation("LEGSSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main), outfit[7])
			TransmogOutfitSetTransmog(TransmogUtil.GetTransmogLocation("FEETSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main), outfit[8])
			TransmogOutfitSetTransmog(TransmogUtil.GetTransmogLocation("WRISTSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main), outfit[9])
			TransmogOutfitSetTransmog(TransmogUtil.GetTransmogLocation("HANDSSLOT" ,Enum.TransmogType.Appearance, Enum.TransmogModification.Main), outfit[10])
			TransmogOutfitSetTransmog(TransmogUtil.GetTransmogLocation("BACKSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main), outfit[15])
			TransmogOutfitSetTransmog(TransmogUtil.GetTransmogLocation("MAINHANDSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main), outfit[16])
			TransmogOutfitSetTransmog(TransmogUtil.GetTransmogLocation("SECONDARYHANDSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main), outfit[17])
			TransmogOutfitSetTransmog(TransmogUtil.GetTransmogLocation("TABARDSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main), outfit[19])
			TransmogOutfitSetTransmog(TransmogUtil.GetTransmogLocation("MAINHANDSLOT", Enum.TransmogType.Illusion, Enum.TransmogModification.Main), outfit["enchant1"])
			TransmogOutfitSetTransmog(TransmogUtil.GetTransmogLocation("SECONDARYHANDSLOT", Enum.TransmogType.Illusion, Enum.TransmogModification.Main), outfit["enchant2"])
		end
	end
end

function TransmogOutfitRenameDone()
	if transmogOutfitRenameNameBox:GetText() ~= "" then
		local blizzardOutfits = C_TransmogCollection.GetOutfits()
		if transmogOutfitCurrentOutfit > transmogOutfitFoundBlizzardOutfits then
			if transmogOutfitNameText:GetText() == transmogOutfitOutfits[transmogOutfitCurrentOutfit - transmogOutfitFoundBlizzardOutfits]["name"] then
				transmogOutfitOutfits[transmogOutfitCurrentOutfit - transmogOutfitFoundBlizzardOutfits]["name"] = transmogOutfitRenameNameBox:GetText()
				transmogOutfitNameText:SetText(transmogOutfitRenameNameBox:GetText())
			else
				transmogOutfitOutfits[transmogOutfitCurrentOutfit - transmogOutfitFoundBlizzardOutfits]["name"] = transmogOutfitRenameNameBox:GetText()
			end
		else
			if transmogOutfitNameText:GetText() == C_TransmogCollection.GetOutfitInfo(blizzardOutfits[transmogOutfitCurrentOutfit]) then
				C_TransmogCollection.ModifyOutfit(blizzardOutfits[transmogOutfitCurrentOutfit], transmogOutfitRenameNameBox:GetText())
				transmogOutfitNameText:SetText(transmogOutfitRenameNameBox:GetText())
			else
				C_TransmogCollection.ModifyOutfit(blizzardOutfits[transmogOutfitCurrentOutfit], transmogOutfitRenameNameBox:GetText())
			end
		end
		TransmogOutfitSearchOutfit()
		transmogOutfitRenameFrame:Hide()
	end
end

function TransmogOutfitRemoveOutfit()
	local blizzardOutfits = C_TransmogCollection.GetOutfits()
	local name
	if transmogOutfitCurrentOutfit > transmogOutfitFoundBlizzardOutfits then
		name = transmogOutfitOutfits[transmogOutfitCurrentOutfit - transmogOutfitFoundBlizzardOutfits]["name"]
	else 
		name = C_TransmogCollection.GetOutfitInfo(blizzardOutfits[transmogOutfitCurrentOutfit])
	end
	transmogOutfitRemoveFrame:Show()
	transmogOutfitRemoveText:SetText("\n\nDo you really want to remove outfit\nnamed " .. name .. "?")
end

function TransmogOutfitRemoveYes()
	local blizzardOutfits = C_TransmogCollection.GetOutfits()
	if transmogOutfitCurrentOutfit > transmogOutfitFoundBlizzardOutfits then
		if transmogOutfitNameText:GetText() == transmogOutfitOutfits[transmogOutfitCurrentOutfit - transmogOutfitFoundBlizzardOutfits]["name"] then
			transmogOutfitNameText:SetText("No Outfit")
		end
	elseif transmogOutfitNameText:GetText() == C_TransmogCollection.GetOutfitInfo(blizzardOutfits[transmogOutfitCurrentOutfit]) then
		transmogOutfitNameText:SetText("No Outfit")
	end
	if blizzardOutfits[transmogOutfitCurrentOutfit] ~= nil then
		C_TransmogCollection.DeleteOutfit(blizzardOutfits[transmogOutfitCurrentOutfit])
	else
		table.remove(transmogOutfitOutfits, transmogOutfitCurrentOutfit - transmogOutfitFoundBlizzardOutfits)
	end
	TransmogOutfitSearchOutfit()
	transmogOutfitRemoveFrame:Hide()
end

function TransmogOutfitGetTransmog(slot)
	local transmog
	local baseSourceID, _, appliedSourceID, _, pendingSourceID, _, hasPendingUndo = C_Transmog.GetSlotVisualInfo(slot)
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
	C_Transmog.ClearPending(slot)
	local _, _, _, canTransmogrify = C_Transmog.GetSlotInfo(slot)
	if canTransmogrify and transmog ~= nil and transmog ~= 0 then
		C_Transmog.SetPending(slot, TransmogUtil.CreateTransmogPendingInfo(Enum.TransmogPendingType.Apply, transmog))
	end
end

function transmogOutfitSelectFrameOnShow(self)
	local blizzardOutfits = C_TransmogCollection.GetOutfits()
	transmogOutfitNumPages = math.ceil(table.getn(transmogOutfitFoundOutfits) / 8)
	if transmogOutfitNumPages <= 0 then
		transmogOutfitNumPages = 1
	end
	if transmogOutfitPage > transmogOutfitNumPages then
		transmogOutfitPage = transmogOutfitNumPages
	end
	transmogOutfitPagesText:SetText("Page " .. transmogOutfitPage .. "/" .. transmogOutfitNumPages)
	for i = 1, 8 do
		transmogOutfitModels[i]:Show()
		local outfit = transmogOutfitFoundOutfits[i + 8 * (transmogOutfitPage - 1)]
		if outfit ~= nil and outfit.index <= transmogOutfitFoundBlizzardOutfits and blizzardOutfits[outfit.index] ~= nil then
			local sources  = C_TransmogCollection.GetOutfitItemTransmogInfoList(blizzardOutfits[transmogOutfitFoundOutfits[i + 8 * (transmogOutfitPage - 1)].index])
			transmogOutfitModels[i].actor:Undress()
			for slotID, itemTransmogInfo in ipairs(sources) do
				local canRecurse = false
				if slotID == 17 then
					local transmogLocation = TransmogUtil.GetTransmogLocation("MAINHANDSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main)
					local mainHandCategoryID = C_Transmog.GetSlotEffectiveCategory(transmogLocation)
					canRecurse = TransmogUtil.IsCategoryLegionArtifact(mainHandCategoryID)
				end
				transmogOutfitModels[i].actor:SetItemTransmogInfo(itemTransmogInfo, slotID)
			end
			transmogOutfitModelTexts[i]:SetText(outfit.name)
		elseif outfit ~= nil and transmogOutfitOutfits[outfit.index - transmogOutfitFoundBlizzardOutfits] then
			local sources = transmogOutfitOutfits[outfit.index - transmogOutfitFoundBlizzardOutfits]
			transmogOutfitModels[i].actor:Undress()
			TransmogOutfitSetTransmogInfo(transmogOutfitModels[i].actor, sources[1], nil, nil, 1)
			TransmogOutfitSetTransmogInfo(transmogOutfitModels[i].actor, sources[3], sources[33], nil, 3)
			TransmogOutfitSetTransmogInfo(transmogOutfitModels[i].actor, sources[4], nil, nil, 4)
			TransmogOutfitSetTransmogInfo(transmogOutfitModels[i].actor, sources[5], nil, nil, 5)
			TransmogOutfitSetTransmogInfo(transmogOutfitModels[i].actor, sources[6], nil, nil, 6)
			TransmogOutfitSetTransmogInfo(transmogOutfitModels[i].actor, sources[7], nil, nil, 7)
			TransmogOutfitSetTransmogInfo(transmogOutfitModels[i].actor, sources[8], nil, nil, 8)
			TransmogOutfitSetTransmogInfo(transmogOutfitModels[i].actor, sources[9], nil, nil, 9)
			TransmogOutfitSetTransmogInfo(transmogOutfitModels[i].actor, sources[10], nil, nil, 10)
			TransmogOutfitSetTransmogInfo(transmogOutfitModels[i].actor, sources[15], nil, nil, 15)
			TransmogOutfitSetTransmogInfo(transmogOutfitModels[i].actor, sources[16], nil, sources["enchant1"], 16)
			TransmogOutfitSetTransmogInfo(transmogOutfitModels[i].actor, sources[17], nil, sources["enchant2"], 17)
			TransmogOutfitSetTransmogInfo(transmogOutfitModels[i].actor, sources[19], nil, nil, 19)
			transmogOutfitModelTexts[i]:SetText(outfit.name)
		else
			transmogOutfitModels[i]:Hide()
		end
	end
end

function TransmogOutfitSetTransmogInfo(model, appearanceID, secondaryAppearanceID, illusionID, slotID)
	if slotID == 3 then
		local baseSourceID = C_Transmog.GetSlotVisualInfo(TransmogUtil.GetTransmogLocation("SHOULDERSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Secondary))
		if secondaryAppearanceID == baseSourceID then
			secondaryAppearanceID = nil
		end
	end
	local itemTransmogInfo = ItemUtil.CreateItemTransmogInfo(appearanceID, secondaryAppearanceID, illusionID)
	local canRecurse = false
	if slotID == 16 then
		local mainHandCategoryID = C_Transmog.GetBaseCategory(appearanceID)
		canRecurse = TransmogUtil.IsCategoryLegionArtifact(mainHandCategoryID)
		if mainHandCategoryID and TransmogUtil.IsCategoryRangedWeapon(mainHandCategoryID) then
			slotID = nil
		end
	end
	model:SetItemTransmogInfo(itemTransmogInfo, slotID, canRecurse)
end

function TransmogOutfitPrevPage()
	if transmogOutfitPage > 1 then
		transmogOutfitPage = transmogOutfitPage - 1
		transmogOutfitSelectFrame:Hide()
		transmogOutfitSelectFrame:Show()
	else
		transmogOutfitPage = transmogOutfitPage
	end
end

function TransmogOutfitNextPage()
	if transmogOutfitPage < transmogOutfitNumPages then
		transmogOutfitPage =transmogOutfitPage + 1
		transmogOutfitSelectFrame:Hide()
		transmogOutfitSelectFrame:Show()
	else
		transmogOutfitPage = transmogOutfitPage
	end
end

function TransmogOutfitWardrobeTabOnClick(self)
	transmogOutfitHideSelectFrame();
	WardrobeCollectionFrame:ClickTab(self)
end

function TransmogOutfitWardrobeSlotOnClick(self, button)
	transmogOutfitHideSelectFrame();
	self:OnClick(button)
end
	
function transmogOutfitFrameCreate(frame)
	WardrobeTransmogFrame.OutfitDropdown:Hide()
	transmogOutfitFoundOutfits = {}
	local blizzardOutfits = C_TransmogCollection.GetOutfits()
	for i = 1, table.getn(blizzardOutfits) do
		transmogOutfitFoundOutfits[i] = {}
		transmogOutfitFoundOutfits[i].index = i
		transmogOutfitFoundOutfits[i].name = C_TransmogCollection.GetOutfitInfo(blizzardOutfits[i])
	end
	transmogOutfitFoundBlizzardOutfits = table.getn(transmogOutfitFoundOutfits)
	for i = 1, table.getn(transmogOutfitOutfits) do
		transmogOutfitFoundOutfits[i + transmogOutfitFoundBlizzardOutfits] = {}
		transmogOutfitFoundOutfits[i + transmogOutfitFoundBlizzardOutfits].index = i + table.getn(blizzardOutfits)
		transmogOutfitFoundOutfits[i + transmogOutfitFoundBlizzardOutfits].name = transmogOutfitOutfits[i]["name"]
	end
	frame:SetFrameStrata("TOOLTIP")
	frame:SetWidth(WardrobeTransmogFrame:GetWidth()) 
	frame:SetHeight(50)
	frame:ClearAllPoints()
	frame:SetPoint("BOTTOMRIGHT", WardrobeTransmogFrame, "TOPRIGHT", 0, 0)
	frame:SetParent(WardrobeTransmogFrame)
	frame:Show()
	WardrobeCollectionFrameTab1:SetScript("OnClick", TransmogOutfitWardrobeTabOnClick)
	WardrobeCollectionFrameTab2:SetScript("OnClick", TransmogOutfitWardrobeTabOnClick)
	WardrobeTransmogFrame.HeadButton:SetScript("OnClick", TransmogOutfitWardrobeSlotOnClick)
	WardrobeTransmogFrame.ShoulderButton:SetScript("OnClick", TransmogOutfitWardrobeSlotOnClick)
	WardrobeTransmogFrame.SecondaryShoulderButton:SetScript("OnClick", TransmogOutfitWardrobeSlotOnClick)
	WardrobeTransmogFrame.BackButton:SetScript("OnClick", TransmogOutfitWardrobeSlotOnClick)
	WardrobeTransmogFrame.ChestButton:SetScript("OnClick", TransmogOutfitWardrobeSlotOnClick)
	WardrobeTransmogFrame.ShirtButton:SetScript("OnClick", TransmogOutfitWardrobeSlotOnClick)
	WardrobeTransmogFrame.TabardButton:SetScript("OnClick", TransmogOutfitWardrobeSlotOnClick)
	WardrobeTransmogFrame.WristButton:SetScript("OnClick", TransmogOutfitWardrobeSlotOnClick)
	WardrobeTransmogFrame.HandsButton:SetScript("OnClick", TransmogOutfitWardrobeSlotOnClick)
	WardrobeTransmogFrame.WaistButton:SetScript("OnClick", TransmogOutfitWardrobeSlotOnClick)
	WardrobeTransmogFrame.LegsButton:SetScript("OnClick", TransmogOutfitWardrobeSlotOnClick)
	WardrobeTransmogFrame.FeetButton:SetScript("OnClick", TransmogOutfitWardrobeSlotOnClick)
	WardrobeTransmogFrame.MainHandButton:SetScript("OnClick", TransmogOutfitWardrobeSlotOnClick)
	WardrobeTransmogFrame.SecondaryHandButton:SetScript("OnClick", TransmogOutfitWardrobeSlotOnClick)
	TransmogOutfitSetupNameFrame(transmogOutfitNameFrame, transmogOutfitNameText)
	if transmogOutfitSelectFrame == nil then
		transmogOutfitSelectFrame = CreateFrame("FRAME", nil, WardrobeCollectionFrame, "CollectionsBackgroundTemplate")
		transmogOutfitSelectFrame:SetScript("OnShow", transmogOutfitSelectFrameOnShow)
		ModelFrames(transmogOutfitSelectFrame)
		transmogOutfitRandomButton = CreateFrame("BUTTON", nil, transmogOutfitSelectFrame, "UIPanelButtonTemplate")
		TransmogOutfitSetupButton(transmogOutfitRandomButton, "Select Random", 100)
		transmogOutfitRandomButton:SetPoint("TOPRIGHT", transmogOutfitSelectFrame, "TOPRIGHT")
		transmogOutfitDoneButton = CreateFrame("BUTTON", nil, transmogOutfitSelectFrame, "UIPanelButtonTemplate")
		TransmogOutfitSetupButton(transmogOutfitDoneButton, "Done", 100)
		transmogOutfitDoneButton:SetPoint("BOTTOMRIGHT", transmogOutfitSelectFrame, "BOTTOMRIGHT")
		transmogOutfitSelectSearchBox = CreateFrame("EDITBOX", nil, transmogOutfitSelectFrame, "InputBoxTemplate")
		TransmogOutfitSetupEditBox(transmogOutfitSelectSearchBox, 120)
		transmogOutfitSelectSearchBox:SetAutoFocus(false)
		transmogOutfitSelectSearchBox:SetPoint("BOTTOMRIGHT", transmogOutfitSelectFrame, "TOPRIGHT", -100, 0)
		transmogOutfitSelectSearchButton = CreateFrame("BUTTON", nil, transmogOutfitSelectFrame, "UIPanelButtonTemplate")
		TransmogOutfitSetupButton(transmogOutfitSelectSearchButton, "Search", 100)
		transmogOutfitSelectSearchButton:SetFrameStrata("TOOLTIP")
		transmogOutfitSelectSearchButton:SetPoint("BOTTOMRIGHT", transmogOutfitSelectFrame, "TOPRIGHT", 0, 0)
		transmogOutfitSelectSortButton = CreateFrame("BUTTON", nil, transmogOutfitSelectFrame, "UIPanelButtonTemplate")
		TransmogOutfitSetupButton(transmogOutfitSelectSortButton, "Sort: A-Z", 100)
		transmogOutfitSelectSortButton:SetFrameStrata("TOOLTIP")
		transmogOutfitSelectSortButton:SetPoint("TOPLEFT", transmogOutfitSelectFrame, "TOPLEFT", 0, 0)
		transmogOutfitPages = CreateFrame("FRAME", nil, transmogOutfitSelectFrame, nil)
		transmogOutfitPages:SetPoint("BOTTOM", transmogOutfitSelectFrame, "BOTTOM", 0, 20)
		transmogOutfitPages:SetFrameStrata("TOOLTIP")
		transmogOutfitPages:SetWidth(150)
		transmogOutfitPages:SetHeight(50)
		transmogOutfitPagesText = transmogOutfitPages:CreateFontString(nil, "OVERLAY", "GameFontWhite")
		transmogOutfitPagesText:ClearAllPoints()
		transmogOutfitPagesText:SetAllPoints(transmogOutfitPages) 
		transmogOutfitPagesText:SetJustifyH("CENTER")
		transmogOutfitPagesText:SetJustifyV("MIDDLE")
		transmogOutfitPrevPageButton = CreateFrame("BUTTON", nil, transmogOutfitPages, "UIPanelButtonTemplate")
		TransmogOutfitSetupButton(transmogOutfitPrevPageButton, "<", 25)
		transmogOutfitPrevPageButton:SetPoint("LEFT", transmogOutfitPages, "LEFT", 0, 0)
		transmogOutfitNextPageButton = CreateFrame("BUTTON", nil, transmogOutfitPages, "UIPanelButtonTemplate")
		TransmogOutfitSetupButton(transmogOutfitNextPageButton, ">", 25)
		transmogOutfitNextPageButton:SetPoint("RIGHT", transmogOutfitPages, "RIGHT", 0, 0)
	end
	transmogOutfitSelectFrame:Hide()
end

function ModelFrames(parent)
	transmogOutfitModels = {}
	transmogOutfitModelTexts = {}
	transmogOutfitModels[1] = CreateFrame("ModelScene", "1", parent, BackdropTemplateMixin and "BackdropTemplate")
	transmogOutfitModelTexts[1] = transmogOutfitModels[1]:CreateFontString(nil, "OVERLAY", "GameFontWhite")
	SetupModelFrame(transmogOutfitModels[1], transmogOutfitModelTexts[1], -225, 100)
	transmogOutfitModels[2] = CreateFrame("ModelScene", "2", parent, BackdropTemplateMixin and "BackdropTemplate")
	transmogOutfitModelTexts[2] = transmogOutfitModels[2]:CreateFontString(nil, "OVERLAY", "GameFontWhite")
	SetupModelFrame(transmogOutfitModels[2], transmogOutfitModelTexts[2], -75, 100)
	transmogOutfitModels[3] = CreateFrame("ModelScene", "3", parent, BackdropTemplateMixin and "BackdropTemplate")
	transmogOutfitModelTexts[3] = transmogOutfitModels[3]:CreateFontString(nil, "OVERLAY", "GameFontWhite")
	SetupModelFrame(transmogOutfitModels[3], transmogOutfitModelTexts[3], 75, 100)
	transmogOutfitModels[4] = CreateFrame("ModelScene", "4", parent, BackdropTemplateMixin and "BackdropTemplate")
	transmogOutfitModelTexts[4] = transmogOutfitModels[4]:CreateFontString(nil, "OVERLAY", "GameFontWhite")
	SetupModelFrame(transmogOutfitModels[4], transmogOutfitModelTexts[4], 225, 100)
	transmogOutfitModels[5] = CreateFrame("ModelScene", "5", parent, BackdropTemplateMixin and "BackdropTemplate")
	transmogOutfitModelTexts[5] = transmogOutfitModels[5]:CreateFontString(nil, "OVERLAY", "GameFontWhite")
	SetupModelFrame(transmogOutfitModels[5], transmogOutfitModelTexts[5], -225, -100)
	transmogOutfitModels[6] = CreateFrame("ModelScene", "6", parent, BackdropTemplateMixin and "BackdropTemplate")
	transmogOutfitModelTexts[6] = transmogOutfitModels[6]:CreateFontString(nil, "OVERLAY", "GameFontWhite")
	SetupModelFrame(transmogOutfitModels[6], transmogOutfitModelTexts[6], -75, -100)
	transmogOutfitModels[7] = CreateFrame("ModelScene", "7", parent, BackdropTemplateMixin and "BackdropTemplate")
	transmogOutfitModelTexts[7] = transmogOutfitModels[7]:CreateFontString(nil, "OVERLAY", "GameFontWhite")
	SetupModelFrame(transmogOutfitModels[7], transmogOutfitModelTexts[7], 75, -100)
	transmogOutfitModels[8] = CreateFrame("ModelScene", "8", parent, BackdropTemplateMixin and "BackdropTemplate")
	transmogOutfitModelTexts[8] = transmogOutfitModels[8]:CreateFontString(nil, "OVERLAY", "GameFontWhite")
	SetupModelFrame(transmogOutfitModels[8], transmogOutfitModelTexts[8], 225, -100)
end

function transmogOutfitModelFrameOnClick(self, button, down)
	local index = transmogOutfitFoundOutfits[tonumber(self:GetName()) + 8 * (transmogOutfitPage - 1)].index
	if button == "LeftButton" then
		if IsControlKeyDown() then
			TransmogOutfitPreviewOutfit(index)
		else
			TransmogOutfitApplyOutfit(index)
		end
	elseif button == "RightButton" then
	transmogOutfitCurrentOutfit = index
		ToggleDropDownMenu(1, nil, transmogOutfitDropDown, self, 0, 200)
	end
end

function TransmogOutfitPreviewOutfit(index)
	DressUpFrame_Show(DressUpFrame)
	DressUpFrame.ModelScene:GetPlayerActor():Undress()
	local blizzardOutfits = C_TransmogCollection.GetOutfits()
	if blizzardOutfits[index] ~= nil then
		local sources  = C_TransmogCollection.GetOutfitItemTransmogInfoList(blizzardOutfits[index])
		for slotID, itemTransmogInfo in ipairs(sources) do
			local canRecurse = false
			if slotID == 17 then
				local transmogLocation = TransmogUtil.GetTransmogLocation("MAINHANDSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main)
				local mainHandCategoryID = C_Transmog.GetSlotEffectiveCategory(transmogLocation)
				canRecurse = TransmogUtil.IsCategoryLegionArtifact(mainHandCategoryID)
			end
			DressUpFrame.ModelScene:GetPlayerActor():SetItemTransmogInfo(itemTransmogInfo, slotID)
		end
	else
		local outfit = transmogOutfitOutfits[index - transmogOutfitFoundBlizzardOutfits]
		if outfit ~= nil then
			TransmogOutfitSetTransmogInfo(DressUpFrame.ModelScene:GetPlayerActor(), outfit[1], nil, nil, 1)
			TransmogOutfitSetTransmogInfo(DressUpFrame.ModelScene:GetPlayerActor(), outfit[3], outfit[33], nil, 3)
			TransmogOutfitSetTransmogInfo(DressUpFrame.ModelScene:GetPlayerActor(), outfit[4], nil, nil, 4)
			TransmogOutfitSetTransmogInfo(DressUpFrame.ModelScene:GetPlayerActor(), outfit[5], nil, nil, 5)
			TransmogOutfitSetTransmogInfo(DressUpFrame.ModelScene:GetPlayerActor(), outfit[6], nil, nil, 6)
			TransmogOutfitSetTransmogInfo(DressUpFrame.ModelScene:GetPlayerActor(), outfit[7], nil, nil, 7)
			TransmogOutfitSetTransmogInfo(DressUpFrame.ModelScene:GetPlayerActor(), outfit[8], nil, nil, 8)
			TransmogOutfitSetTransmogInfo(DressUpFrame.ModelScene:GetPlayerActor(), outfit[9], nil, nil, 9)
			TransmogOutfitSetTransmogInfo(DressUpFrame.ModelScene:GetPlayerActor(), outfit[10], nil, nil, 10)
			TransmogOutfitSetTransmogInfo(DressUpFrame.ModelScene:GetPlayerActor(), outfit[15], nil, nil, 15)
			TransmogOutfitSetTransmogInfo(DressUpFrame.ModelScene:GetPlayerActor(), outfit[16], nil, outfit["enchant1"], 16)
			TransmogOutfitSetTransmogInfo(DressUpFrame.ModelScene:GetPlayerActor(), outfit[17], nil, outfit["enchant2"], 17)
			TransmogOutfitSetTransmogInfo(DressUpFrame.ModelScene:GetPlayerActor(), outfit[19], nil, nil, 19)
		end
	end
end

function SetupModelFrame(frame, text, x, y)
	frame.actor = frame:CreateActor("actor")
	frame:SetWidth(150)
	frame:SetHeight(200)
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
	frame:Show()
	frame:SetCameraOrientationByAxisVectors(0, 1, 0, -1, 0, 0, 0, 0, 1)
	frame.actor:SetYaw(-1.5)
	frame.actor:Show()
	frame:SetPoint("CENTER", transmogOutfitSelectFrame, "CENTER", x, y)
	frame:EnableMouse(true)
	frame:SetScript("OnMouseDown", transmogOutfitModelFrameOnClick)
	text:ClearAllPoints()
	text:SetPoint("BOTTOM", frame, "BOTTOM", 0, 10)
	text:SetJustifyH("CENTER")
	text:SetJustifyV("MIDDLE")
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
	text:SetJustifyV("MIDDLE")
	text:SetText("No Outfit")
	frame:Show()
end

function TransmogOutfitSetupButton(button, text, width)
	button:SetText(text)
	button:SetHeight(25)
	button:SetWidth(width)
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

function TransmogOutfitSetupEditBox(editBox, width)
	editBox:SetWidth(width)
	editBox:SetHeight(25)
	editBox:ClearAllPoints()
	editBox:Show()
end

local transmogOutfitFrame = CreateFrame("FRAME", nil, UIParent)
transmogOutfitFrame:RegisterEvent("ADDON_LOADED")
transmogOutfitFrame:RegisterEvent("TRANSMOGRIFY_UPDATE")
transmogOutfitFrame:RegisterEvent("TRANSMOGRIFY_CLOSE")
transmogOutfitFrame:SetScript("OnEvent", transmogOutfitFrameOnEvent)
transmogOutfitNameFrame = CreateFrame("FRAME", nil, transmogOutfitFrame, BackdropTemplateMixin and "BackdropTemplate")
transmogOutfitNameText = transmogOutfitNameFrame:CreateFontString(nil, "OVERLAY", "GameFontWhite")
transmogOutfitNameFrame:SetPoint("TOP", transmogOutfitFrame, "TOP")
transmogOutfitNewButton = CreateFrame("BUTTON", nil, transmogOutfitFrame, "UIPanelButtonTemplate")
TransmogOutfitSetupButton(transmogOutfitNewButton, "Save New", 100)
transmogOutfitNewButton:SetPoint("BOTTOMLEFT", transmogOutfitFrame, "BOTTOMLEFT")
transmogOutfitSelectButton = CreateFrame("BUTTON", nil, transmogOutfitFrame, "UIPanelButtonTemplate")
TransmogOutfitSetupButton(transmogOutfitSelectButton, "Select Outfit", 100)
transmogOutfitSelectButton:SetPoint("BOTTOM", transmogOutfitFrame, "BOTTOM")
transmogOutfitSaveButton = CreateFrame("BUTTON", nil, transmogOutfitFrame, "UIPanelButtonTemplate")
TransmogOutfitSetupButton(transmogOutfitSaveButton, "Save Current", 100)
transmogOutfitSaveButton:SetPoint("BOTTOMRIGHT", transmogOutfitFrame, "BOTTOMRIGHT")

transmogOutfitNewFrame = CreateFrame("FRAME", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate")
TransmogOutfitSetupPopupFrame(transmogOutfitNewFrame, 250, 100)
transmogOutfitNewFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
transmogOutfitNewNameBox = CreateFrame("EDITBOX", nil, transmogOutfitNewFrame, "InputBoxTemplate")
TransmogOutfitSetupEditBox(transmogOutfitNewNameBox, 200)
transmogOutfitNewNameBox:SetPoint("CENTER", transmogOutfitNewFrame, "CENTER", 0, 25)
transmogOutfitNewDoneButton = CreateFrame("BUTTON", nil, transmogOutfitNewFrame, "UIPanelButtonTemplate")
TransmogOutfitSetupButton(transmogOutfitNewDoneButton, "Done", 100)
transmogOutfitNewDoneButton:SetPoint("CENTER", transmogOutfitNewFrame, "CENTER", -50, -25)
transmogOutfitNewCancelButton = CreateFrame("BUTTON", nil, transmogOutfitNewFrame, "UIPanelButtonTemplate")
TransmogOutfitSetupButton(transmogOutfitNewCancelButton, "Cancel", 100)
transmogOutfitNewCancelButton:SetPoint("CENTER", transmogOutfitNewFrame, "CENTER", 50, -25)

transmogOutfitRemoveFrame = CreateFrame("FRAME", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate") 
TransmogOutfitSetupPopupFrame(transmogOutfitRemoveFrame, 250, 100)
transmogOutfitRemoveFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
transmogOutfitRemoveText = transmogOutfitRemoveFrame:CreateFontString(nil, "OVERLAY", "GameFontWhite")
transmogOutfitRemoveText:ClearAllPoints()
transmogOutfitRemoveText:SetAllPoints(transmogOutfitRemoveFrame) 
transmogOutfitRemoveText:SetJustifyH("CENTER")
transmogOutfitRemoveText:SetJustifyV("TOP")
transmogOutfitRemoveYesButton = CreateFrame("BUTTON", nil, transmogOutfitRemoveFrame, "UIPanelButtonTemplate")
TransmogOutfitSetupButton(transmogOutfitRemoveYesButton, "Yes", 100)
transmogOutfitRemoveYesButton:SetPoint("CENTER", transmogOutfitRemoveFrame, "CENTER", -55, -25)
transmogOutfitRemoveNoButton = CreateFrame("BUTTON", nil, transmogOutfitRemoveFrame, "UIPanelButtonTemplate")
TransmogOutfitSetupButton(transmogOutfitRemoveNoButton, "No", 100)
transmogOutfitRemoveNoButton:SetPoint("CENTER", transmogOutfitRemoveFrame, "CENTER", 55, -25)

transmogOutfitRenameFrame = CreateFrame("FRAME", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate")
TransmogOutfitSetupPopupFrame(transmogOutfitRenameFrame, 250, 100)
transmogOutfitRenameFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
transmogOutfitRenameNameBox = CreateFrame("EDITBOX", nil, transmogOutfitRenameFrame, "InputBoxTemplate")
TransmogOutfitSetupEditBox(transmogOutfitRenameNameBox, 200)
transmogOutfitRenameNameBox:SetPoint("CENTER", transmogOutfitRenameFrame, "CENTER", 0, 25)
transmogOutfitRenameDoneButton = CreateFrame("BUTTON", nil, transmogOutfitRenameFrame, "UIPanelButtonTemplate")
TransmogOutfitSetupButton(transmogOutfitRenameDoneButton, "Done", 100)
transmogOutfitRenameDoneButton:SetPoint("CENTER", transmogOutfitRenameFrame, "CENTER", -50, -25)
transmogOutfitRenameCancelButton = CreateFrame("BUTTON", nil, transmogOutfitRenameFrame, "UIPanelButtonTemplate")
TransmogOutfitSetupButton(transmogOutfitRenameCancelButton, "Cancel", 100)
transmogOutfitRenameCancelButton:SetPoint("CENTER", transmogOutfitRenameFrame, "CENTER", 50, -25)

transmogOutfitDropDown = CreateFrame("FRAME", "GarrisonReportDropDown", UIParent, "UIDropDownMenuTemplate")
UIDropDownMenu_Initialize(transmogOutfitDropDown, transmogOutfitDropDownOnLoad, "MENU")