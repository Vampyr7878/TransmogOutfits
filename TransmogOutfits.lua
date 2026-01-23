local TransmogOutfits = LibStub("AceAddon-3.0"):NewAddon("TransmogOutfits")

TransmogOutfits.FoundOutfits = {}
TransmogOutfits.Select = false
TransmogOutfits.Page = 1
TransmogOutfits.NumPages = 1
TransmogOutfits.CurrentOutfit = 1
TransmogOutfits.HookedSlots = {}

TransmogOutfits.MaleTranslate = {["Human"]              = {-0.05, -2.3 ,  1.5 },
								 ["Orc"]                = { 0.05, -3.6 ,  1.5 },
								 ["Dwarf"]              = {-0.07, -2.5 ,  1.1 },
								 ["Scourge"]            = {-0.15, -2.2 ,  1.4 },
								 ["NightElf"]           = {-0.15, -2.8 ,  1.9 },
								 ["Tauren"]             = {-0.12, -4.1 ,  1.9 },
								 ["Gnome"]              = { 0   , -1.5 ,  0.7 },
								 ["Troll"]              = { 0.17, -2.7 ,  1.7 },
								 ["Draenei"]            = {-0.2 , -3.5 ,  1.8 },
								 ["BloodElf"]           = {-0.05, -2.1 ,  1.6 },
								 ["Worgen"]             = { 0.05, -3.5 ,  1.7 },
								 ["Goblin"]             = { 0   , -1.8 ,  0.8 },
								 ["Pandaren"]           = {-0.35, -3.8 ,  1.6 },
								 ["VoidElf"]            = {-0.05, -2.1 ,  1.6 },
								 ["Nightborne"]         = { 0   , -2.8 ,  1.9 },
								 ["LightforgedDraenei"] = {-0.2,  -3.5 ,  1.8 },
								 ["HighmountainTauren"] = {-0.12, -4.1 ,  1.9 },
								 ["DarkIronDwarf"]      = {-0.12, -2.5 ,  1.1 },
								 ["MagharOrc"]          = { 0.05, -3.6 ,  1.5 },
								 ["KulTiran"]           = { 0   , -2.8 ,  2   },
								 ["ZandalariTroll"]     = {-0.05, -2.95,  2.15},
								 ["Mechagnome"]         = {-0.07, -1.6 ,  0.7 },
								 ["Vulpera"]            = {-0.22, -2.1 ,  0.8 },
								 ["Dracthyr"]		    = {-0.97, -3.3 ,  2.2 },
								 ["EarthenDwarf"]       = {-0.07, -2.5 ,  1.1 },
								 ["Harronir"]           = {-0.15, -1.9 ,  1.95}}
							  
TransmogOutfits.FemaleTranslate = {["Human"]              = {-0.05, -1.8 ,  1.5 },
								   ["Orc"]                = {-0.2 , -2.2 ,  1.55},
								   ["Dwarf"]              = {-0.1 , -2   ,  1.07},
								   ["Scourge"]            = { 0.07, -1.8 ,  1.45},
								   ["NightElf"]           = {-0.05, -2.05,  1.85},
								   ["Tauren"]             = {-0.35, -3.3 ,  1.9 },
								   ["Gnome"]              = {-0.22, -1.7 ,  0.65},
								   ["Troll"]              = {-0.12, -2.1 ,  1.9 },
								   ["Draenei"]            = {-0.15, -1.55,  1.9 },
								   ["BloodElf"]           = {-0.05, -1.8 ,  1.5 },
								   ["Worgen"]             = {-0.1 , -2.7 ,  1.8 },
								   ["Goblin"]             = {-0.22, -2   ,  0.87},
								   ["Pandaren"]           = {-0.3 , -3.2 ,  1.6 },
								   ["VoidElf"]            = {-0.05, -1.8 ,  1.5 },
								   ["Nightborne"]         = { 0  ,  -2.05,  1.85},
								   ["LightforgedDraenei"] = {-0.15, -1.8 ,  1.9 },
								   ["HighmountainTauren"] = {-0.35, -3.3 ,  1.9 },
								   ["DarkIronDwarf"]      = {-0.07, -2   ,  1.07},
								   ["MagharOrc"]          = {-0.2 , -2.2 ,  1.55},
								   ["KulTiran"]           = {-0.07, -2.1 ,  2   },
								   ["ZandalariTroll"]     = {-0.25, -2.4 ,  2.3 },
								   ["Mechagnome"]         = {-0.17, -1.6 ,  0.65},
								   ["Vulpera"]            = {-0.22, -2.1 ,  0.85},
								   ["Dracthyr"]			  = {-0.97, -3.3 ,  2.2 },
								   ["EarthenDwarf"]       = {-0.1 , -2   ,  1.07},
								   ["Harronir"]           = {-0.05, -1.7 ,  1.8 }}

function TransmogOutfits:FrameOnEvent(event, arg1)
	if event == "ADDON_LOADED" then
		if arg1 == "Blizzard_Transmog" then
			TransmogOutfits:FrameCreate()
			self:UnregisterEvent("ADDON_LOADED")
		end
	elseif event == "TRANSMOGRIFY_CLOSE" then
		TransmogOutfits:HideSelectFrame()
		TransmogOutfits.NewFrame:Hide()
		self:RegisterEvent("TRANSMOGRIFY_OPEN")
	end
end

function TransmogOutfits:ContextMenu(parent)
	MenuUtil.CreateContextMenu(parent, function(owner, root)
		root:CreateButton("Rename", function() self:ContextMenuClick(1) end)
		root:CreateButton("Remove", function() self:ContextMenuClick(2) end)
	end)
end

function TransmogOutfits:ContextMenuClick(value)
	if value == 1 then
		self.RenameFrame:Show()
	elseif value == 2 then
		self:RemoveOutfit()
	end
end

function TransmogOutfits:ShowSelectFrame()
	TransmogFrame.WardrobeCollection.TabContent:Hide()
	TransmogFrame.WardrobeCollection.TabHeaders:Hide()
	TransmogOutfits.SelectButton:SetText("Close")
	local _, race = UnitRace("player")
	local sex = UnitSex("player")
	local _, alteredForm = C_PlayerInfo.GetAlternateFormInfo()
	for i = 1, 9 do
		self.Models[i].actor:SetModelByUnit("player", false, true, false, not alteredForm)
		self.Models[i]:SetPaused(true)
		local file = self.Models[i].actor:GetModelFileID()
		if file == 1011653 or file == 1000764 or file == 4220448 then
			race = "Human"
		elseif file == 4395382 then
			race = "BloodElf"
		end
		if file == 1968587 then
			self.Models[i]:SetCameraPosition(-0.2, -3.6, 1.5)
		elseif sex == 2 then
			self.Models[i]:SetCameraPosition(self.MaleTranslate[race][1], self.MaleTranslate[race][2], self.MaleTranslate[race][3])
		elseif sex == 3 then
			self.Models[i]:SetCameraPosition(self.FemaleTranslate[race][1], self.FemaleTranslate[race][2], self.FemaleTranslate[race][3])
		end
	end
	self.SelectFrame:Show()
	self.Select = true
end

function TransmogOutfits:HideSelectFrame()
	self.SelectFrame:Hide()
	self.Select = false
	TransmogFrame.WardrobeCollection.TabContent:Show()
	TransmogFrame.WardrobeCollection.TabHeaders:Show()
	TransmogOutfits.SelectButton:SetText("Addon Outfits")
end

function TransmogOutfits:ButtonOnClick()
	if self == TransmogOutfits.NewButton then
		TransmogOutfits.NewNameBox:SetText("")
		TransmogOutfits.NewFrame:Show()
	elseif self == TransmogOutfits.SelectButton then
		if TransmogOutfits.Select then
			TransmogOutfits:HideSelectFrame()
		else
			TransmogOutfits:ShowSelectFrame()
		end
	elseif self == TransmogOutfits.SaveButton then
		TransmogOutfits:UpdateOutfit()
	elseif self == TransmogOutfits.RandomButton then
		TransmogOutfits:RandomOutfit()
	elseif self == TransmogOutfits.NewDoneButton then
		TransmogOutfits:NewOutfit()
	elseif self == TransmogOutfits.NewCancelButton then
		TransmogOutfits.NewFrame:Hide()
	elseif self == TransmogOutfits.SelectSearchButton then
		TransmogOutfits:SearchOutfit()
	elseif self == TransmogOutfits.SelectSortButton then
		TransmogOutfits:SortOutfits()
	elseif self == TransmogOutfits.RemoveYesButton then
		TransmogOutfits:RemoveYes()
	elseif self == TransmogOutfits.RemoveNoButton then
		TransmogOutfits.RemoveFrame:Hide()
	elseif self == TransmogOutfits.PrevPageButton then
		TransmogOutfits:PrevPage()
	elseif self == TransmogOutfits.NextPageButton then
		TransmogOutfits:NextPage()
	elseif self == TransmogOutfits.RenameDoneButton then
		TransmogOutfits:RenameDone()
	elseif self == TransmogOutfits.RenameCancelButton then
		TransmogOutfits.RenameFrame:Hide()
	end
end

function TransmogOutfits:FindName(name)
	for i = 1, table.getn(transmogOutfitOutfits) do
		if transmogOutfitOutfits[i]["name"] == name then
			return i
		end
	end
	return nil
end

function TransmogOutfits:UpdateOutfit()
	local name = self.NameText:GetText()
	local index = self:FindName(name)
	if index ~= nil then
		local outfit = {}
		outfit["name"] = name
		outfit[1] = self:GetTransmog(Enum.TransmogOutfitSlot.Head, Enum.TransmogType.Appearance)
		outfit[3] = self:GetTransmog(Enum.TransmogOutfitSlot.ShoulderRight, Enum.TransmogType.Appearance)
		outfit[33] = self:GetTransmog(Enum.TransmogOutfitSlot.ShoulderLeft, Enum.TransmogType.Appearance)
		outfit[4] = self:GetTransmog(Enum.TransmogOutfitSlot.Body, Enum.TransmogType.Appearance)
		outfit[5] = self:GetTransmog(Enum.TransmogOutfitSlot.Chest, Enum.TransmogType.Appearance)
		outfit[6] = self:GetTransmog(Enum.TransmogOutfitSlot.Waist, Enum.TransmogType.Appearance)
		outfit[7] = self:GetTransmog(Enum.TransmogOutfitSlot.Legs, Enum.TransmogType.Appearance)
		outfit[8] = self:GetTransmog(Enum.TransmogOutfitSlot.Feet, Enum.TransmogType.Appearance)
		outfit[9] = self:GetTransmog(Enum.TransmogOutfitSlot.Wrist, Enum.TransmogType.Appearance)
		outfit[10] = self:GetTransmog(Enum.TransmogOutfitSlot.Hand ,Enum.TransmogType.Appearance)
		outfit[15] = self:GetTransmog(Enum.TransmogOutfitSlot.Back, Enum.TransmogType.Appearance)
		outfit[16] = self:GetTransmog(Enum.TransmogOutfitSlot.WeaponMainHand, Enum.TransmogType.Appearance)
		outfit[17] = self:GetTransmog(Enum.TransmogOutfitSlot.WeaponOffHand, Enum.TransmogType.Appearance)
		outfit[19] = self:GetTransmog(Enum.TransmogOutfitSlot.Tabard, Enum.TransmogType.Appearance)
		outfit["enchant1"] = self:GetTransmog(Enum.TransmogOutfitSlot.WeaponMainHand, Enum.TransmogType.Illusion)
		outfit["enchant2"] = self:GetTransmog(Enum.TransmogOutfitSlot.WeaponOffHand, Enum.TransmogType.Illusion)
		transmogOutfitOutfits[index] = outfit
	end
	if self.SelectFrame:IsVisible() then
		self.SelectFrame:Hide()
		self.SelectFrame:Show()
	end
end

function TransmogOutfits:NewOutfit()
	local name = self.NewNameBox:GetText()
	local number = table.getn(transmogOutfitOutfits)
	self.NewNameBox:SetText("")
	if name ~= "" and self:FindName(name) == nil then
		local outfit = {}
		self.NameText:SetText(name)
		outfit["name"] = name
		outfit[1] = self:GetTransmog(Enum.TransmogOutfitSlot.Head, Enum.TransmogType.Appearance)
		outfit[3] = self:GetTransmog(Enum.TransmogOutfitSlot.ShoulderRight, Enum.TransmogType.Appearance)
		outfit[33] = self:GetTransmog(Enum.TransmogOutfitSlot.ShoulderLeft, Enum.TransmogType.Appearance)
		outfit[4] = self:GetTransmog(Enum.TransmogOutfitSlot.Body, Enum.TransmogType.Appearance)
		outfit[5] = self:GetTransmog(Enum.TransmogOutfitSlot.Chest, Enum.TransmogType.Appearance)
		outfit[6] = self:GetTransmog(Enum.TransmogOutfitSlot.Waist, Enum.TransmogType.Appearance)
		outfit[7] = self:GetTransmog(Enum.TransmogOutfitSlot.Legs, Enum.TransmogType.Appearance)
		outfit[8] = self:GetTransmog(Enum.TransmogOutfitSlot.Feet, Enum.TransmogType.Appearance)
		outfit[9] = self:GetTransmog(Enum.TransmogOutfitSlot.Wrist, Enum.TransmogType.Appearance)
		outfit[10] = self:GetTransmog(Enum.TransmogOutfitSlot.Hand ,Enum.TransmogType.Appearance)
		outfit[15] = self:GetTransmog(Enum.TransmogOutfitSlot.Back, Enum.TransmogType.Appearance)
		outfit[16] = self:GetTransmog(Enum.TransmogOutfitSlot.WeaponMainHand, Enum.TransmogType.Appearance)
		outfit[17] = self:GetTransmog(Enum.TransmogOutfitSlot.WeaponOffHand, Enum.TransmogType.Appearance)
		outfit[19] = self:GetTransmog(Enum.TransmogOutfitSlot.Tabard, Enum.TransmogType.Appearance)
		outfit["enchant1"] = self:GetTransmog(Enum.TransmogOutfitSlot.WeaponMainHand, Enum.TransmogType.Illusion)
		outfit["enchant2"] = self:GetTransmog(Enum.TransmogOutfitSlot.WeaponOffHand, Enum.TransmogType.Illusion)
		transmogOutfitOutfits[number + 1] = outfit
	end
	self.NewFrame:Hide()
	self:SearchOutfit()
end

function TransmogOutfits:RandomOutfit()
	local number = table.getn(transmogOutfitOutfits)
	local rand = math.random(1, number)
	self:ApplyOutfit(rand)
end

function TransmogOutfits:SearchOutfit()
	self.FoundOutfits = {}
	if self.SelectSearchBox:GetText() == "" then
		for i = 1, table.getn(transmogOutfitOutfits) do
			self.FoundOutfits[i] = {}
			self.FoundOutfits[i].index = i
			self.FoundOutfits[i].name = transmogOutfitOutfits[i]["name"]
		end
	else
		local j = 1
		for i = 1, table.getn(transmogOutfitOutfits) do
			if string.find(string.lower(transmogOutfitOutfits[i]["name"]), string.lower(self.SelectSearchBox:GetText())) then
				self.FoundOutfits[j] = {}
				self.FoundOutfits[j].index = i
				self.FoundOutfits[j].name = transmogOutfitOutfits[i]["name"]
				j = j + 1
			end
		end
	end
	if self.SelectFrame:IsVisible() then
		self.SelectFrame:Hide()
		self.SelectFrame:Show()
	end
end

function TransmogOutfits:SortOutfits()
	local text = self.SelectSortButton:GetText()
	if text == "Sort: A-Z" then
		table.sort(self.FoundOutfits, function (o1, o2) return string.lower(o1.name) < string.lower(o2.name) end )
		self.SelectSortButton:SetText("Sort: Def")
	elseif text == "Sort: Def" then
		table.sort(self.FoundOutfits, function (o1, o2) return o1.index < o2.index end )
		self.SelectSortButton:SetText("Sort: A-Z")
	end
	if self.SelectFrame:IsVisible() then
		self.SelectFrame:Hide()
		self.SelectFrame:Show()
	end
end

function TransmogOutfits:ApplyOutfit(index)
	local outfit = transmogOutfitOutfits[index]
	if outfit ~= nil then
		C_TransmogOutfitInfo.ClearAllPendingTransmogs()
		self.NameText:SetText(outfit["name"])
		self:SetTransmog(Enum.TransmogOutfitSlot.Head, Enum.TransmogType.Appearance, outfit[1])
		self:SetTransmog(Enum.TransmogOutfitSlot.ShoulderRight, Enum.TransmogType.Appearance, outfit[3])
		self:SetTransmog(Enum.TransmogOutfitSlot.ShoulderLeft, Enum.TransmogType.Appearance, outfit[33])
		self:SetTransmog(Enum.TransmogOutfitSlot.Body, Enum.TransmogType.Appearance, outfit[4])
		self:SetTransmog(Enum.TransmogOutfitSlot.Chest, Enum.TransmogType.Appearance, outfit[5])
		self:SetTransmog(Enum.TransmogOutfitSlot.Waist, Enum.TransmogType.Appearance, outfit[6])
		self:SetTransmog(Enum.TransmogOutfitSlot.Legs, Enum.TransmogType.Appearance, outfit[7])
		self:SetTransmog(Enum.TransmogOutfitSlot.Feet, Enum.TransmogType.Appearance, outfit[8])
		self:SetTransmog(Enum.TransmogOutfitSlot.Wrist, Enum.TransmogType.Appearance, outfit[9])
		self:SetTransmog(Enum.TransmogOutfitSlot.Hand ,Enum.TransmogType.Appearance, outfit[10])
		self:SetTransmog(Enum.TransmogOutfitSlot.Back, Enum.TransmogType.Appearance, outfit[15])
		self:SetTransmog(Enum.TransmogOutfitSlot.WeaponMainHand, Enum.TransmogType.Appearance, outfit[16])
		self:SetTransmog(Enum.TransmogOutfitSlot.WeaponOffHand, Enum.TransmogType.Appearance, outfit[17])
		self:SetTransmog(Enum.TransmogOutfitSlot.Tabard, Enum.TransmogType.Appearance, outfit[19])
		self:SetTransmog(Enum.TransmogOutfitSlot.WeaponMainHand, Enum.TransmogType.Illusion, outfit["enchant1"])
		self:SetTransmog(Enum.TransmogOutfitSlot.WeaponOffHand, Enum.TransmogType.Illusion, outfit["enchant2"])
	end
end

function TransmogOutfits:RenameDone()
	if self.RenameNameBox:GetText() ~= "" then
		if self.NameText:GetText() == transmogOutfitOutfits[self.CurrentOutfit]["name"] then
			transmogOutfitOutfits[self.CurrentOutfit]["name"] = self.RenameNameBox:GetText()
			self.NameText:SetText(self.RenameNameBox:GetText())
		else
			transmogOutfitOutfits[self.CurrentOutfit]["name"] = self.RenameNameBox:GetText()
		end
		TransmogOutfits:SearchOutfit()
		self.RenameFrame:Hide()
	end
end

function TransmogOutfits:RemoveOutfit()
	local name
	name = transmogOutfitOutfits[self.CurrentOutfit]["name"]
	self.RemoveFrame:Show()
	self.RemoveText:SetText("\n\nDo you really want to remove outfit\nnamed " .. name .. "?")
end

function TransmogOutfits:RemoveYes()
	if self.NameText:GetText() == transmogOutfitOutfits[self.CurrentOutfit]["name"] then
		self.NameText:SetText("No Outfit")
	end
	table.remove(transmogOutfitOutfits, self.CurrentOutfit)
	self:SearchOutfit()
	self.RemoveFrame:Hide()
end

function TransmogOutfits:GetTransmog(slot, type)
	local option = 0
	if slot == Enum.TransmogOutfitSlot.WeaponMainHand then
		option = TransmogFrame.CharacterPreview:GetSlotFrame(slot, type).slotData.currentWeaponOptionInfo.weaponOption
	elseif slot == Enum.TransmogOutfitSlot.WeaponOffHand then
		option = TransmogFrame.CharacterPreview:GetSlotFrame(Enum.TransmogOutfitSlot.WeaponMainHand, type).slotData.currentWeaponOptionInfo.weaponOption
		if option ~= 2 and option ~= 3 then
			option = TransmogFrame.CharacterPreview:GetSlotFrame(slot, type).slotData.currentWeaponOptionInfo.weaponOption
		end
	end
	local slotinfo = C_TransmogOutfitInfo.GetViewedOutfitSlotInfo(slot, type, option)
	return slotinfo.transmogID
end

function WeaponOption(categoryID)
	local spec = GetSpecializationInfo(GetSpecialization())
	if categoryID == 12 then
		return Enum.TransmogOutfitSlotOption.OneHandedWeapon
	elseif categoryID == 13 then
		return Enum.TransmogOutfitSlotOption.OneHandedWeapon
	elseif categoryID == 14 then
		return Enum.TransmogOutfitSlotOption.OneHandedWeapon
	elseif categoryID == 15 then
		return Enum.TransmogOutfitSlotOption.OneHandedWeapon
	elseif categoryID == 16 then
		return Enum.TransmogOutfitSlotOption.OneHandedWeapon
	elseif categoryID == 17 then
		return Enum.TransmogOutfitSlotOption.OneHandedWeapon
	elseif categoryID == 28 then
		return Enum.TransmogOutfitSlotOption.OneHandedWeapon
	elseif categoryID == 20 then
		if spec == 72 then
			return Enum.TransmogOutfitSlotOption.FuryTwoHandedWeapon
		end
		return Enum.TransmogOutfitSlotOption.TwoHandedWeapon
	elseif categoryID == 21 then
		if spec == 72 then
			return Enum.TransmogOutfitSlotOption.FuryTwoHandedWeapon
		end
		return Enum.TransmogOutfitSlotOption.TwoHandedWeapon
	elseif categoryID == 22 then
		if spec == 72 then
			return Enum.TransmogOutfitSlotOption.FuryTwoHandedWeapon
		end
		return Enum.TransmogOutfitSlotOption.TwoHandedWeapon
	elseif categoryID == 23 then
		if spec == 72 then
			return Enum.TransmogOutfitSlotOption.FuryTwoHandedWeapon
		end
		return Enum.TransmogOutfitSlotOption.TwoHandedWeapon
	elseif categoryID == 24 then
		if spec == 72 then
			return Enum.TransmogOutfitSlotOption.FuryTwoHandedWeapon
		end
		return Enum.TransmogOutfitSlotOption.TwoHandedWeapon
	elseif categoryID == 25 then
		return Enum.TransmogOutfitSlotOption.RangedWeapon
	elseif categoryID == 26 then
		return Enum.TransmogOutfitSlotOption.RangedWeapon
	elseif categoryID == 27 then
		return Enum.TransmogOutfitSlotOption.RangedWeapon
	elseif categoryID == 19 then
		return Enum.TransmogOutfitSlotOption.OffHand
	elseif categoryID == 18 then
		return Enum.TransmogOutfitSlotOption.Shield
	else
		return 0
	end
end

function TransmogOutfits:SetTransmog(slot, type, transmog)
	local option = 0
	local display = 1
	local info = C_TransmogCollection.GetSourceInfo(transmog)
	if info == nil then
		return
	end
	if info.isHideVisual then
		display = 3
	end
	if slot == Enum.TransmogOutfitSlot.WeaponMainHand or slot == Enum.TransmogOutfitSlot.WeaponOffHand then
		option = WeaponOption(info.categoryID)
	end
	C_TransmogOutfitInfo.SetPendingTransmog(slot, type, option, transmog, display)
end

function HookSlotScript(slot, type, index)
	if TransmogOutfits.HookedSlots[index] == nil or TransmogOutfits.HookedSlots[index] == false then
		frame = TransmogFrame.CharacterPreview:GetSlotFrame(slot, type)
		if frame ~= nil then
			frame:HookScript("OnClick", function() TransmogOutfits:WardrobeSlotOnClick() end)
			TransmogOutfits.HookedSlots[index] = true
		else
			TransmogOutfits.HookedSlots[index] = false
		end
	end
end

function TransmogOutfits:SelectFrameOnShow()
	HookSlotScript(Enum.TransmogOutfitSlot.Head, Enum.TransmogType.Appearance, 1)
	HookSlotScript(Enum.TransmogOutfitSlot.ShoulderRight, Enum.TransmogType.Appearance, 3)
	HookSlotScript(Enum.TransmogOutfitSlot.ShoulderLeft, Enum.TransmogType.Appearance, 33)
	HookSlotScript(Enum.TransmogOutfitSlot.Body, Enum.TransmogType.Appearance, 4)
	HookSlotScript(Enum.TransmogOutfitSlot.Chest, Enum.TransmogType.Appearance, 5)
	HookSlotScript(Enum.TransmogOutfitSlot.Waist, Enum.TransmogType.Appearance, 6)
	HookSlotScript(Enum.TransmogOutfitSlot.Legs, Enum.TransmogType.Appearance, 7)
	HookSlotScript(Enum.TransmogOutfitSlot.Feet, Enum.TransmogType.Appearance, 8)
	HookSlotScript(Enum.TransmogOutfitSlot.Wrist, Enum.TransmogType.Appearance, 9)
	HookSlotScript(Enum.TransmogOutfitSlot.Hand ,Enum.TransmogType.Appearance, 10)
	HookSlotScript(Enum.TransmogOutfitSlot.Back, Enum.TransmogType.Appearance, 15)
	HookSlotScript(Enum.TransmogOutfitSlot.WeaponMainHand, Enum.TransmogType.Appearance, 16)
	HookSlotScript(Enum.TransmogOutfitSlot.WeaponOffHand, Enum.TransmogType.Appearance, 17)
	HookSlotScript(Enum.TransmogOutfitSlot.Tabard, Enum.TransmogType.Appearance, 19)
	HookSlotScript(Enum.TransmogOutfitSlot.WeaponMainHand, Enum.TransmogType.Illusion, 16)
	HookSlotScript(Enum.TransmogOutfitSlot.WeaponOffHand, Enum.TransmogType.Illusion, 17)
	TransmogOutfits.NumPages = math.ceil(table.getn(TransmogOutfits.FoundOutfits) / 9)
	if TransmogOutfits.NumPages <= 0 then
		TransmogOutfits.NumPages = 1
	end
	if TransmogOutfits.Page > TransmogOutfits.NumPages then
		TransmogOutfits.Page = TransmogOutfits.NumPages
	end
	TransmogOutfits.PagesText:SetText("Page " .. TransmogOutfits.Page .. "/" .. TransmogOutfits.NumPages)
	for i = 1, 9 do
		TransmogOutfits.Models[i]:Show()
		local outfit = TransmogOutfits.FoundOutfits[i + 9 * (TransmogOutfits.Page - 1)]
		if outfit ~= nil and transmogOutfitOutfits[outfit.index] then
			local sources = transmogOutfitOutfits[outfit.index]
			TransmogOutfits.Models[i].actor:Undress()
			TransmogOutfits:SetTransmogInfo(TransmogOutfits.Models[i].actor, sources[1], nil, nil, 1)
			TransmogOutfits:SetTransmogInfo(TransmogOutfits.Models[i].actor, sources[3], sources[33], nil, 3)
			TransmogOutfits:SetTransmogInfo(TransmogOutfits.Models[i].actor, sources[4], nil, nil, 4)
			TransmogOutfits:SetTransmogInfo(TransmogOutfits.Models[i].actor, sources[5], nil, nil, 5)
			TransmogOutfits:SetTransmogInfo(TransmogOutfits.Models[i].actor, sources[6], nil, nil, 6)
			TransmogOutfits:SetTransmogInfo(TransmogOutfits.Models[i].actor, sources[7], nil, nil, 7)
			TransmogOutfits:SetTransmogInfo(TransmogOutfits.Models[i].actor, sources[8], nil, nil, 8)
			TransmogOutfits:SetTransmogInfo(TransmogOutfits.Models[i].actor, sources[9], nil, nil, 9)
			TransmogOutfits:SetTransmogInfo(TransmogOutfits.Models[i].actor, sources[10], nil, nil, 10)
			TransmogOutfits:SetTransmogInfo(TransmogOutfits.Models[i].actor, sources[15], nil, nil, 15)
			TransmogOutfits:SetTransmogInfo(TransmogOutfits.Models[i].actor, sources[16], nil, sources["enchant1"], 16)
			TransmogOutfits:SetTransmogInfo(TransmogOutfits.Models[i].actor, sources[17], nil, sources["enchant2"], 17)
			TransmogOutfits:SetTransmogInfo(TransmogOutfits.Models[i].actor, sources[19], nil, nil, 19)
			TransmogOutfits.ModelTexts[i]:SetText(outfit.name)
		else
			TransmogOutfits.Models[i]:Hide()
		end
	end
end

function TransmogOutfits:SetTransmogInfo(model, appearanceID, secondaryAppearanceID, illusionID, slotID)
	if appearanceID == nil then
		return
	end
	local itemTransmogInfo = ItemUtil.CreateItemTransmogInfo(appearanceID, secondaryAppearanceID, illusionID)
	model:SetItemTransmogInfo(itemTransmogInfo, slotID)
end

function TransmogOutfits:PrevPage()
	if self.Page > 1 then
		self.Page = self.Page - 1
		self.SelectFrame:Hide()
		self.SelectFrame:Show()
	else
		self.Page = self.Page
	end
end

function TransmogOutfits:NextPage()
	if self.Page < self.NumPages then
		self.Page =self.Page + 1
		self.SelectFrame:Hide()
		self.SelectFrame:Show()
	else
		self.Page = self.Page
	end
end

function TransmogOutfits:WardrobeSlotOnClick(button)
	TransmogOutfits:HideSelectFrame();
end

function TransmogOutfits:FrameCreate()
	self.FoundOutfits = {}
	for i = 1, table.getn(transmogOutfitOutfits) do
		self.FoundOutfits[i] = {}
		self.FoundOutfits[i].index = i
		self.FoundOutfits[i].name = transmogOutfitOutfits[i]["name"]
	end
	if self.SelectButton == nil then
		self.SelectButton = CreateFrame("BUTTON", nil, TransmogFrame.WardrobeCollection, "UIPanelButtonTemplate")
		self:SetupButton(self.SelectButton, "Addon Outfits", 120)
		self.SelectButton:SetPoint("TOPRIGHT", TransmogFrame.WardrobeCollection, "TOPRIGHT", -10, -10)
		self.SelectFrame = CreateFrame("FRAME", nil, TransmogFrame.WardrobeCollection, TransmogWardrobeCustomSetsMixin and "CollectionsBackgroundTemplate")
		self.SelectFrame:SetScript("OnShow", self.SelectFrameOnShow)
		self.SelectFrame:SetFrameStrata("HIGH")
		self.NameFrame = CreateFrame("FRAME", nil, self.SelectFrame, BackdropTemplateMixin and "BackdropTemplate")
		self.NameText = self.NameFrame:CreateFontString(nil, "OVERLAY", "GameFontWhite")
		self.NameFrame:SetPoint("BOTTOMLEFT", self.SelectFrame, "TOPLEFT", 0, 30)
		self.NewButton = CreateFrame("BUTTON", nil, self.SelectFrame, "UIPanelButtonTemplate")
		self:SetupButton(self.NewButton, "Create New", 100)
		self.NewButton:SetPoint("BOTTOMLEFT", self.SelectFrame, "TOPLEFT", 100, 0)
		self.SaveButton = CreateFrame("BUTTON", nil, self.SelectFrame, "UIPanelButtonTemplate")
		self:SetupButton(self.SaveButton, "Save Changes", 100)
		self.SaveButton:SetPoint("BOTTOMLEFT", self.SelectFrame, "TOPLEFT", 200, 0)
		self:ModelFrames(self.SelectFrame)
		self.RandomButton = CreateFrame("BUTTON", nil, self.SelectFrame, "UIPanelButtonTemplate")
		self:SetupButton(self.RandomButton, "Select Random", 130)
		self.RandomButton:SetPoint("BOTTOMRIGHT", self.SelectFrame, "TOPRIGHT")
		self.SelectSearchBox = CreateFrame("EDITBOX", nil, self.SelectFrame, "InputBoxTemplate")
		self:SetupEditBox(self.SelectSearchBox, 110)
		self.SelectSearchBox:SetAutoFocus(false)
		self.SelectSearchBox:SetPoint("BOTTOMRIGHT", self.SelectFrame, "TOPRIGHT", -130, 30)
		self.SelectSearchButton = CreateFrame("BUTTON", nil, self.SelectFrame, "UIPanelButtonTemplate")
		self:SetupButton(self.SelectSearchButton, "Search", 120)
		self.SelectSearchButton:SetFrameStrata("TOOLTIP")
		self.SelectSearchButton:SetPoint("BOTTOMRIGHT", self.SelectFrame, "TOPRIGHT", -130, 0)
		self.SelectSortButton = CreateFrame("BUTTON", nil, self.SelectFrame, "UIPanelButtonTemplate")
		self:SetupButton(self.SelectSortButton, "Sort: A-Z", 100)
		self.SelectSortButton:SetFrameStrata("TOOLTIP")
		self.SelectSortButton:SetPoint("BOTTOMLEFT", self.SelectFrame, "TOPLEFT", 0, 0)
		self.Pages = CreateFrame("FRAME", nil, self.SelectFrame, nil)
		self.Pages:SetPoint("BOTTOM", self.SelectFrame, "BOTTOM", 0, 0)
		self.Pages:SetFrameStrata("TOOLTIP")
		self.Pages:SetWidth(150)
		self.Pages:SetHeight(50)
		self.PagesText = self.Pages:CreateFontString(nil, "OVERLAY", "GameFontWhite")
		self.PagesText:ClearAllPoints()
		self.PagesText:SetAllPoints(self.Pages) 
		self.PagesText:SetJustifyH("CENTER")
		self.PagesText:SetJustifyV("MIDDLE")
		self.PrevPageButton = CreateFrame("BUTTON", nil, self.Pages, "UIPanelButtonTemplate")
		self:SetupButton(self.PrevPageButton, "<", 25)
		self.PrevPageButton:SetPoint("LEFT", self.Pages, "LEFT", 0, 0)
		self.NextPageButton = CreateFrame("BUTTON", nil, self.Pages, "UIPanelButtonTemplate")
		self:SetupButton(self.NextPageButton, ">", 25)
		self.NextPageButton:SetPoint("RIGHT", self.Pages, "RIGHT", 0, 0)
		self.SelectFrame:Hide()
	end
	self:SetupNameFrame(self.NameFrame, self.NameText)
end

function TransmogOutfits:ModelFrames(parent)
	self.Models = {}
	self.ModelsBg = {}
	self.ModelTexts = {}
	local index
	for i = 1, 3 do
		for j = 1, 3 do
			index = j + (i - 1) * 3
			self.Models[index] = CreateFrame("ModelScene", tostring(index), parent, BackdropTemplateMixin and "BackdropTemplate")
			self.ModelsBg[index] = CreateFrame("FRAME", nil, self.Models[index], BackdropTemplateMixin and "BackdropTemplate")
			self.ModelTexts[index] = self.ModelsBg[index]:CreateFontString(nil, "OVERLAY", "GameFontWhite")
			self:SetupModelFrame(self.Models[index], self.ModelsBg[index], self.ModelTexts[index], -200 + (j - 1) * 200, 260 - (i - 1) * 245)
		end
	end
end

function TransmogOutfits:ModelFrameOnClick(button, down)
	local index = TransmogOutfits.FoundOutfits[tonumber(self:GetName()) + 9 * (TransmogOutfits.Page - 1)].index
	if button == "LeftButton" then
		TransmogOutfits:ApplyOutfit(index)
	elseif button == "RightButton" then
		TransmogOutfits.CurrentOutfit = index
		TransmogOutfits:ContextMenu(self)
	end
end

function TransmogOutfits:SetupModelFrame(frame, bg, text, x, y)
	frame.actor = frame:CreateActor("actor")
	frame:SetWidth(180)
	frame:SetHeight(230)
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
	frame:SetPoint("CENTER", self.SelectFrame, "CENTER", x, y)
	frame:EnableMouse(true)
	frame:SetScript("OnMouseDown", self.ModelFrameOnClick)
	bg:SetWidth(180)
	bg:SetHeight(25)
	bg:SetBackdrop({bgFile = "Interface/Tooltips/UI-Tooltip-Background", 
					   edgeFile = "Interface/Tooltips/UI-Tooltip-Border", 
					   tile = true,
					   tileSize = 16,
					   edgeSize = 16, 
					   insets = {left = 1,
								 right = 1,
								 top = 1,
								 bottom = 1}}) 
	bg:SetBackdropColor(0, 0, 0, 0.8)
	bg:SetPoint("TOP", frame, "TOP", 0, 0)
	text:ClearAllPoints()
	text:SetPoint("CENTER", bg, "CENTER", 0, 0)
	text:SetJustifyH("CENTER")
	text:SetJustifyV("MIDDLE")
end

function TransmogOutfits:SetupNameFrame(frame, text)
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
	frame:SetWidth(300) 
	frame:SetHeight(25)
	text:ClearAllPoints()
	text:SetAllPoints(frame) 
	text:SetJustifyH("CENTER")
	text:SetJustifyV("MIDDLE")
	text:SetText("No Outfit")
	frame:Show()
end

function TransmogOutfits:SetupButton(button, text, width)
	button:SetText(text)
	button:SetHeight(30)
	button:SetWidth(width)
	button:ClearAllPoints()
	button:SetScript("OnClick", self.ButtonOnClick)
	button:Show()
end

function TransmogOutfits:SetupPopupFrame(frame, width, height)
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

function TransmogOutfits:SetupEditBox(editBox, width)
	editBox:SetWidth(width)
	editBox:SetHeight(25)
	editBox:ClearAllPoints()
	editBox:Show()
end

function TransmogOutfits:OnInitialize()
	self.Frame = CreateFrame("FRAME", nil, UIParent)
	self.Frame:RegisterEvent("ADDON_LOADED")
	self.Frame:RegisterEvent("TRANSMOGRIFY_CLOSE")
	self.Frame:SetScript("OnEvent", self.FrameOnEvent)
	if transmogOutfitOutfits == nil then
		transmogOutfitOutfits = {}
	end
	self.NewFrame = CreateFrame("FRAME", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate")
	self:SetupPopupFrame(self.NewFrame, 250, 100)
	self.NewFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	self.NewNameBox = CreateFrame("EDITBOX", nil, self.NewFrame, "InputBoxTemplate")
	self:SetupEditBox(self.NewNameBox, 200)
	self.NewNameBox:SetPoint("CENTER", self.NewFrame, "CENTER", 0, 25)
	self.NewDoneButton = CreateFrame("BUTTON", nil, self.NewFrame, "UIPanelButtonTemplate")
	self:SetupButton(self.NewDoneButton, "Done", 100)
	self.NewDoneButton:SetPoint("CENTER", self.NewFrame, "CENTER", -50, -25)
	self.NewCancelButton = CreateFrame("BUTTON", nil, self.NewFrame, "UIPanelButtonTemplate")
	self:SetupButton(self.NewCancelButton, "Cancel", 100)
	self.NewCancelButton:SetPoint("CENTER", self.NewFrame, "CENTER", 50, -25)
	self.RemoveFrame = CreateFrame("FRAME", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate") 
	self:SetupPopupFrame(self.RemoveFrame, 250, 100)
	self.RemoveFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	self.RemoveText = self.RemoveFrame:CreateFontString(nil, "OVERLAY", "GameFontWhite")
	self.RemoveText:ClearAllPoints()
	self.RemoveText:SetAllPoints(self.RemoveFrame) 
	self.RemoveText:SetJustifyH("CENTER")
	self.RemoveText:SetJustifyV("TOP")
	self.RemoveYesButton = CreateFrame("BUTTON", nil, self.RemoveFrame, "UIPanelButtonTemplate")
	self:SetupButton(self.RemoveYesButton, "Yes", 100)
	self.RemoveYesButton:SetPoint("CENTER", self.RemoveFrame, "CENTER", -55, -25)
	self.RemoveNoButton = CreateFrame("BUTTON", nil, self.RemoveFrame, "UIPanelButtonTemplate")
	self:SetupButton(self.RemoveNoButton, "No", 100)
	self.RemoveNoButton:SetPoint("CENTER", self.RemoveFrame, "CENTER", 55, -25)
	self.RenameFrame = CreateFrame("FRAME", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate")
	self:SetupPopupFrame(self.RenameFrame, 250, 100)
	self.RenameFrame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
	self.RenameNameBox = CreateFrame("EDITBOX", nil, self.RenameFrame, "InputBoxTemplate")
	self:SetupEditBox(self.RenameNameBox, 200)
	self.RenameNameBox:SetPoint("CENTER", self.RenameFrame, "CENTER", 0, 25)
	self.RenameDoneButton = CreateFrame("BUTTON", nil, self.RenameFrame, "UIPanelButtonTemplate")
	self:SetupButton(self.RenameDoneButton, "Done", 100)
	self.RenameDoneButton:SetPoint("CENTER", self.RenameFrame, "CENTER", -50, -25)
	self.RenameCancelButton = CreateFrame("BUTTON", nil, self.RenameFrame, "UIPanelButtonTemplate")
	self:SetupButton(self.RenameCancelButton, "Cancel", 100)
	self.RenameCancelButton:SetPoint("CENTER", self.RenameFrame, "CENTER", 50, -25)
end