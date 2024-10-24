local TransmogOutfits = LibStub("AceAddon-3.0"):NewAddon("TransmogOutfits")

TransmogOutfits.FoundOutfits = {}
TransmogOutfits.Select = false
TransmogOutfits.Sets = false
TransmogOutfits.Page = 1
TransmogOutfits.WardrobeTab = 1
TransmogOutfits.NumPages = 1
TransmogOutfits.CurrentOutfit = 1
TransmogOutfits.FoundBlizzardOutfits = 0
TransmogOutfits.InitCamera = true

TransmogOutfits.MaleTranslate = {["Human"]              = 1.00,
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
								 ["Dracthyr"]		    = 2.30,
								 ["EarthenDwarf"]       = 1.00}
							  
TransmogOutfits.FemaleTranslate = {["Human"]              = 1.00,
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
								   ["Dracthyr"]			  = 2.30,
								   ["EarthenDwarf"]       = 1.00}

function TransmogOutfits:FrameOnEvent(event, arg1)
	if event == "TRANSMOGRIFY_UPDATE" and WardrobeTransmogFrame ~= nil and WardrobeTransmogFrame:IsVisible() then
		TransmogOutfits:FrameCreate(self)
		self:UnregisterEvent("TRANSMOGRIFY_UPDATE")
	elseif event == "TRANSMOGRIFY_CLOSE" then
		if TransmogOutfits.NewFrame ~= nil then
			TransmogOutfits.NewFrame:Hide()
		end
		if TransmogOutfits.SelectFrame ~= nil then
			TransmogOutfits.SelectFrame:Hide()
		end
		if TransmogOutfits.RemoveFrame ~= nil then
			TransmogOutfits.RemoveFrame:Hide()
		end
		self:Hide()
		TransmogOutfits.Select = false
		TransmogOutfits.Sets = false
		WardrobeCollectionFrame.FilterButton:Show()
		WardrobeCollectionFrame:SetTab(1)
		self:RegisterEvent("TRANSMOGRIFY_UPDATE")
		collectgarbage("collect")
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
	self.Sets = WardrobeCollectionFrame.SetsTransmogFrame:IsVisible()
	WardrobeCollectionFrame.ItemsCollectionFrame:Hide()
	WardrobeCollectionFrame.SetsTransmogFrame:Hide()
	WardrobeCollectionFrame.FilterButton:Hide()
	self.WardrobeTab = WardrobeCollectionFrame.selectedTransmogTab
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
		if self.InitCamera then
			self.Models[i]:SetCameraPosition(WardrobeTransmogFrame.ModelScene:GetCameraPosition())
		end
		self.Models[i].actor:SetModelByUnit("player", false, true, false, not alteredForm)
		self.Models[i]:SetPaused(true)
		local file = self.Models[i].actor:GetModelFileID()
		if file == 1011653 or file == 1000764 or file == 4220448 then
			race = "Human"
		elseif file == 4395382 then
			race = "BloodElf"
		end
		self.Models[i].actor:SetScale(scale)
		if sex == 2 then
			self.Models[i].actor:SetPosition(self.MaleTranslate[race], zoom, 0)
		elseif sex == 3 then
			self.Models[i].actor:SetPosition(self.FemaleTranslate[race], zoom, 0)
		end
	end
	self.SelectFrame:Show()
	self.Select = true
end

function TransmogOutfits:HideSelectFrame()
	if self.Sets then
		WardrobeCollectionFrame.SetsTransmogFrame:Show()
	else
		WardrobeCollectionFrame.ItemsCollectionFrame:Show()
	end
	WardrobeCollectionFrame.FilterButton:Show()
	WardrobeCollectionFrame:SetTab(self.WardrobeTab)
	WardrobeCollectionFrameSearchBox:Show()
	self.SelectFrame:Hide()
	self.Select = false
end

function TransmogOutfits:ButtonOnClick()
	if self == TransmogOutfits.NewButton then
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
	elseif self == TransmogOutfits.DoneButton then
		TransmogOutfits:HideSelectFrame()
	elseif self == TransmogOutfits.NewDoneButton then
		TransmogOutfits:NewOutfit()
	elseif self == TransmogOutfits.CancelButton then
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

function TransmogOutfits:FindBlizzardOutfit(name)
	local blizzardOutfits = C_TransmogCollection.GetOutfits()
	for i = 1, table.getn(blizzardOutfits) do
		if C_TransmogCollection.GetOutfitInfo(blizzardOutfits[i]) == name then
			return i
		end
	end
	return nil
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
	local blizzardOutfits = C_TransmogCollection.GetOutfits()
	local index = self:FindBlizzardOutfit(name)
	if index ~= nil then
		local outfit = WardrobeTransmogFrame.ModelScene:GetPlayerActor():GetItemTransmogInfoList()
		C_TransmogCollection.ModifyOutfit(blizzardOutfits[index], outfit)
	else
		index = self:FindName(name)
		if index ~= nil then
			local outfit = {}
			outfit["name"] = name
			outfit[1] = self:GetTransmog(TransmogUtil.GetTransmogLocation("HEADSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main))
			outfit[3] = self:GetTransmog(TransmogUtil.GetTransmogLocation("SHOULDERSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main))
			if WardrobeTransmogFrame.SecondaryShoulderButton:IsVisible() then
				outfit[33] = self:GetTransmog(TransmogUtil.GetTransmogLocation("SHOULDERSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Secondary))
			else
				outfit[33] = outfit[3]
			end
			outfit[4] = self:GetTransmog(TransmogUtil.GetTransmogLocation("SHIRTSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main))
			outfit[5] = self:GetTransmog(TransmogUtil.GetTransmogLocation("CHESTSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main))
			outfit[6] = self:GetTransmog(TransmogUtil.GetTransmogLocation("WAISTSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main))
			outfit[7] = self:GetTransmog(TransmogUtil.GetTransmogLocation("LEGSSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main))
			outfit[8] = self:GetTransmog(TransmogUtil.GetTransmogLocation("FEETSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main))
			outfit[9] = self:GetTransmog(TransmogUtil.GetTransmogLocation("WRISTSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main))
			outfit[10] = self:GetTransmog(TransmogUtil.GetTransmogLocation("HANDSSLOT" ,Enum.TransmogType.Appearance, Enum.TransmogModification.Main))
			outfit[15] = self:GetTransmog(TransmogUtil.GetTransmogLocation("BACKSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main))
			outfit[16] = self:GetTransmog(TransmogUtil.GetTransmogLocation("MAINHANDSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main))
			outfit[17] = self:GetTransmog(TransmogUtil.GetTransmogLocation("SECONDARYHANDSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main))
			outfit[19] = self:GetTransmog(TransmogUtil.GetTransmogLocation("TABARDSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main))
			outfit["enchant1"] = self:GetTransmog(TransmogUtil.GetTransmogLocation("MAINHANDSLOT", Enum.TransmogType.Illusion, Enum.TransmogModification.Main))
			outfit["enchant2"] = self:GetTransmog(TransmogUtil.GetTransmogLocation("SECONDARYHANDSLOT", Enum.TransmogType.Illusion, Enum.TransmogModification.Main))
			transmogOutfitOutfits[index] = outfit
		end
	end
	if self.SelectFrame:IsVisible() then
		self.SelectFrame:Hide()
		self.SelectFrame:Show()
	end
end

function TransmogOutfits:NewOutfit()
	local name = self.NewNameBox:GetText()
	local number = table.getn(transmogOutfitOutfits)
	local current = table.getn(C_TransmogCollection.GetOutfits())
	local max = C_TransmogCollection.GetNumMaxOutfits()
	self.NewNameBox:SetText("")
	if transmogOutfitBlizzard and current < max then
		local icon
		local outfit = WardrobeTransmogFrame.ModelScene:GetPlayerActor():GetItemTransmogInfoList()
		for slotID, itemTransmogInfo in ipairs(outfit) do
			local appearanceID = itemTransmogInfo.appearanceID
			if appearanceID ~= Constants.Transmog.NoTransmogID then
				icon = select(4, C_TransmogCollection.GetAppearanceSourceInfo(appearanceID))
				if icon then
					break
				end
			end
		end
		C_TransmogCollection.NewOutfit(name, icon, outfit)
	else
		if name ~= "" and self:FindName(name) == nil then
			local outfit = {}
			self.NameText:SetText(name)
			outfit["name"] = name
			outfit[1] = self:GetTransmog(TransmogUtil.GetTransmogLocation("HEADSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main))
			outfit[3] = self:GetTransmog(TransmogUtil.GetTransmogLocation("SHOULDERSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main))
			if WardrobeTransmogFrame.SecondaryShoulderButton:IsVisible() then
				outfit[33] = self:GetTransmog(TransmogUtil.GetTransmogLocation("SHOULDERSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Secondary))
			else
				outfit[33] = outfit[3]
			end
			outfit[4] = self:GetTransmog(TransmogUtil.GetTransmogLocation("SHIRTSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main))
			outfit[5] = self:GetTransmog(TransmogUtil.GetTransmogLocation("CHESTSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main))
			outfit[6] = self:GetTransmog(TransmogUtil.GetTransmogLocation("WAISTSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main))
			outfit[7] = self:GetTransmog(TransmogUtil.GetTransmogLocation("LEGSSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main))
			outfit[8] = self:GetTransmog(TransmogUtil.GetTransmogLocation("FEETSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main))
			outfit[9] = self:GetTransmog(TransmogUtil.GetTransmogLocation("WRISTSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main))
			outfit[10] = self:GetTransmog(TransmogUtil.GetTransmogLocation("HANDSSLOT" ,Enum.TransmogType.Appearance, Enum.TransmogModification.Main))
			outfit[15] = self:GetTransmog(TransmogUtil.GetTransmogLocation("BACKSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main))
			outfit[16] = self:GetTransmog(TransmogUtil.GetTransmogLocation("MAINHANDSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main))
			outfit[17] = self:GetTransmog(TransmogUtil.GetTransmogLocation("SECONDARYHANDSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main))
			outfit[19] = self:GetTransmog(TransmogUtil.GetTransmogLocation("TABARDSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main))
			outfit["enchant1"] = self:GetTransmog(TransmogUtil.GetTransmogLocation("MAINHANDSLOT", Enum.TransmogType.Illusion, Enum.TransmogModification.Main))
			outfit["enchant2"] = self:GetTransmog(TransmogUtil.GetTransmogLocation("SECONDARYHANDSLOT", Enum.TransmogType.Illusion, Enum.TransmogModification.Main))
			transmogOutfitOutfits[number + 1] = outfit
		end
	end
	self.NewFrame:Hide()
	self:SearchOutfit()
end

function TransmogOutfits:RandomOutfit()
	local blizzardOutfits = C_TransmogCollection.GetOutfits()
	local number = table.getn(blizzardOutfits) + table.getn(transmogOutfitOutfits)
	local rand = math.random(1, number)
	self:ApplyOutfit(rand)
end

function TransmogOutfits:SearchOutfit()
	local blizzardOutfits = C_TransmogCollection.GetOutfits()
	self.FoundOutfits = {}
	if self.SelectSearchBox:GetText() == "" then
		for i = 1, table.getn(blizzardOutfits) do
			self.FoundOutfits[i] = {}
			self.FoundOutfits[i].index = i
			self.FoundOutfits[i].name = C_TransmogCollection.GetOutfitInfo(blizzardOutfits[i])
		end
		self.FoundBlizzardOutfits = table.getn(self.FoundOutfits)
		for i = 1, table.getn(transmogOutfitOutfits) do
			self.FoundOutfits[i + self.FoundBlizzardOutfits] = {}
			self.FoundOutfits[i + self.FoundBlizzardOutfits].index = i + self.FoundBlizzardOutfits
			self.FoundOutfits[i + self.FoundBlizzardOutfits].name = transmogOutfitOutfits[i]["name"]
		end
	else
		local j = 1, name
		for i = 1, table.getn(blizzardOutfits) do
			name = C_TransmogCollection.GetOutfitInfo(blizzardOutfits[i])
			if string.find(name, self.SelectSearchBox:GetText()) then
				self.FoundOutfits[j] = {}
				self.FoundOutfits[j].index = i
				self.FoundOutfits[j].name = name
				j = j + 1
			end
		end
		self.FoundBlizzardOutfits = table.getn(self.FoundOutfits)
		for i = 1, table.getn(transmogOutfitOutfits) do
			if string.find(transmogOutfitOutfits[i]["name"], self.SelectSearchBox:GetText()) then
				self.FoundOutfits[j] = {}
				self.FoundOutfits[j].index = i + self.FoundBlizzardOutfits
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
	local blizzardOutfits = C_TransmogCollection.GetOutfits()
	if blizzardOutfits[index] ~= nil then
		self.NameText:SetText(C_TransmogCollection.GetOutfitInfo(blizzardOutfits[index]))
		C_Transmog.LoadOutfit(blizzardOutfits[index])
	else
		local outfit = transmogOutfitOutfits[index - self.FoundBlizzardOutfits]
		if outfit ~= nil then
			self.NameText:SetText(outfit["name"])
			self:SetTransmog(TransmogUtil.GetTransmogLocation("HEADSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main), outfit[1])
			self:SetTransmog(TransmogUtil.GetTransmogLocation("SHOULDERSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main), outfit[3])
			self:SetTransmog(TransmogUtil.GetTransmogLocation("SHOULDERSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Secondary), outfit[33])
			self:SetTransmog(TransmogUtil.GetTransmogLocation("SHIRTSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main), outfit[4])
			self:SetTransmog(TransmogUtil.GetTransmogLocation("CHESTSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main), outfit[5])
			self:SetTransmog(TransmogUtil.GetTransmogLocation("WAISTSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main), outfit[6])
			self:SetTransmog(TransmogUtil.GetTransmogLocation("LEGSSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main), outfit[7])
			self:SetTransmog(TransmogUtil.GetTransmogLocation("FEETSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main), outfit[8])
			self:SetTransmog(TransmogUtil.GetTransmogLocation("WRISTSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main), outfit[9])
			self:SetTransmog(TransmogUtil.GetTransmogLocation("HANDSSLOT" ,Enum.TransmogType.Appearance, Enum.TransmogModification.Main), outfit[10])
			self:SetTransmog(TransmogUtil.GetTransmogLocation("BACKSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main), outfit[15])
			self:SetTransmog(TransmogUtil.GetTransmogLocation("MAINHANDSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main), outfit[16])
			self:SetTransmog(TransmogUtil.GetTransmogLocation("SECONDARYHANDSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main), outfit[17])
			self:SetTransmog(TransmogUtil.GetTransmogLocation("TABARDSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main), outfit[19])
			self:SetTransmog(TransmogUtil.GetTransmogLocation("MAINHANDSLOT", Enum.TransmogType.Illusion, Enum.TransmogModification.Main), outfit["enchant1"])
			self:SetTransmog(TransmogUtil.GetTransmogLocation("SECONDARYHANDSLOT", Enum.TransmogType.Illusion, Enum.TransmogModification.Main), outfit["enchant2"])
		end
	end
end

function TransmogOutfits:RenameDone()
	if self.RenameNameBox:GetText() ~= "" then
		local blizzardOutfits = C_TransmogCollection.GetOutfits()
		if self.CurrentOutfit > self.FoundBlizzardOutfits then
			if self.NameText:GetText() == transmogOutfitOutfits[self.CurrentOutfit - self.FoundBlizzardOutfits]["name"] then
				transmogOutfitOutfits[self.CurrentOutfit - self.FoundBlizzardOutfits]["name"] = self.RenameNameBox:GetText()
				self.NameText:SetText(self.RenameNameBox:GetText())
			else
				transmogOutfitOutfits[self.CurrentOutfit - self.FoundBlizzardOutfits]["name"] = self.RenameNameBox:GetText()
			end
		else
			if self.NameText:GetText() == C_TransmogCollection.GetOutfitInfo(blizzardOutfits[self.CurrentOutfit]) then
				C_TransmogCollection.RenameOutfit(blizzardOutfits[self.CurrentOutfit], self.RenameNameBox:GetText())
				self.NameText:SetText(self.RenameNameBox:GetText())
			else
				C_TransmogCollection.RenameOutfit(blizzardOutfits[self.CurrentOutfit], self.RenameNameBox:GetText())
			end
		end
		TransmogOutfits:SearchOutfit()
		self.RenameFrame:Hide()
	end
end

function TransmogOutfits:RemoveOutfit()
	local blizzardOutfits = C_TransmogCollection.GetOutfits()
	local name
	if self.CurrentOutfit > self.FoundBlizzardOutfits then
		name = transmogOutfitOutfits[self.CurrentOutfit - self.FoundBlizzardOutfits]["name"]
	else 
		name = C_TransmogCollection.GetOutfitInfo(blizzardOutfits[self.CurrentOutfit])
	end
	self.RemoveFrame:Show()
	self.RemoveText:SetText("\n\nDo you really want to remove outfit\nnamed " .. name .. "?")
end

function TransmogOutfits:RemoveYes()
	local blizzardOutfits = C_TransmogCollection.GetOutfits()
	if self.CurrentOutfit > self.FoundBlizzardOutfits then
		if self.NameText:GetText() == transmogOutfitOutfits[self.CurrentOutfit - self.FoundBlizzardOutfits]["name"] then
			self.NameText:SetText("No Outfit")
		end
	elseif self.NameText:GetText() == C_TransmogCollection.GetOutfitInfo(blizzardOutfits[self.CurrentOutfit]) then
		self.NameText:SetText("No Outfit")
	end
	if blizzardOutfits[self.CurrentOutfit] ~= nil then
		C_TransmogCollection.DeleteOutfit(blizzardOutfits[self.CurrentOutfit])
	else
		table.remove(transmogOutfitOutfits, self.CurrentOutfit - self.FoundBlizzardOutfits)
	end
	self:SearchOutfit()
	self.RemoveFrame:Hide()
end

function TransmogOutfits:GetTransmog(slot)
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

function TransmogOutfits:SetTransmog(slot, transmog)
	C_Transmog.ClearPending(slot)
	local _, _, _, canTransmogrify = C_Transmog.GetSlotInfo(slot)
	if canTransmogrify and transmog ~= nil and transmog ~= 0 then
		C_Transmog.SetPending(slot, TransmogUtil.CreateTransmogPendingInfo(Enum.TransmogPendingType.Apply, transmog))
	end
end

function TransmogOutfits:SelectFrameOnShow()
	local blizzardOutfits = C_TransmogCollection.GetOutfits()
	TransmogOutfits.NumPages = math.ceil(table.getn(TransmogOutfits.FoundOutfits) / 8)
	if TransmogOutfits.NumPages <= 0 then
		TransmogOutfits.NumPages = 1
	end
	if TransmogOutfits.Page > TransmogOutfits.NumPages then
		TransmogOutfits.Page = TransmogOutfits.NumPages
	end
	TransmogOutfits.PagesText:SetText("Page " .. TransmogOutfits.Page .. "/" .. TransmogOutfits.NumPages)
	for i = 1, 8 do
		TransmogOutfits.Models[i]:Show()
		local outfit = TransmogOutfits.FoundOutfits[i + 8 * (TransmogOutfits.Page - 1)]
		if outfit ~= nil and outfit.index <= TransmogOutfits.FoundBlizzardOutfits and blizzardOutfits[outfit.index] ~= nil then
			local sources  = C_TransmogCollection.GetOutfitItemTransmogInfoList(blizzardOutfits[TransmogOutfits.FoundOutfits[i + 8 * (TransmogOutfits.Page - 1)].index])
			TransmogOutfits.Models[i].actor:Undress()
			for slotID, itemTransmogInfo in ipairs(sources) do
				local canRecurse = false
				if slotID == 17 then
					local transmogLocation = TransmogUtil.GetTransmogLocation("MAINHANDSLOT", Enum.TransmogType.Appearance, Enum.TransmogModification.Main)
					local mainHandCategoryID = C_Transmog.GetSlotEffectiveCategory(transmogLocation)
					canRecurse = TransmogUtil.IsCategoryLegionArtifact(mainHandCategoryID)
				end
				TransmogOutfits.Models[i].actor:SetItemTransmogInfo(itemTransmogInfo, slotID)
			end
			TransmogOutfits.ModelTexts[i]:SetText(outfit.name)
		elseif outfit ~= nil and transmogOutfitOutfits[outfit.index - TransmogOutfits.FoundBlizzardOutfits] then
			local sources = transmogOutfitOutfits[outfit.index - TransmogOutfits.FoundBlizzardOutfits]
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

function TransmogOutfits:WardrobeTabOnClick()
	TransmogOutfits:HideSelectFrame();
	WardrobeCollectionFrame:ClickTab(self)
end

function TransmogOutfits:WardrobeSlotOnClick(button)
	TransmogOutfits:HideSelectFrame();
	self:OnClick(button)
end
	
function TransmogOutfits:FrameCreate(frame)
	WardrobeTransmogFrame.OutfitDropdown:Hide()
	self.FoundOutfits = {}
	local blizzardOutfits = C_TransmogCollection.GetOutfits()
	for i = 1, table.getn(blizzardOutfits) do
		self.FoundOutfits[i] = {}
		self.FoundOutfits[i].index = i
		self.FoundOutfits[i].name = C_TransmogCollection.GetOutfitInfo(blizzardOutfits[i])
	end
	self.FoundBlizzardOutfits = table.getn(self.FoundOutfits)
	for i = 1, table.getn(transmogOutfitOutfits) do
		self.FoundOutfits[i + self.FoundBlizzardOutfits] = {}
		self.FoundOutfits[i + self.FoundBlizzardOutfits].index = i + table.getn(blizzardOutfits)
		self.FoundOutfits[i + self.FoundBlizzardOutfits].name = transmogOutfitOutfits[i]["name"]
	end
	frame:SetFrameStrata("TOOLTIP")
	frame:SetWidth(WardrobeTransmogFrame:GetWidth()) 
	frame:SetHeight(50)
	frame:ClearAllPoints()
	frame:SetPoint("BOTTOMRIGHT", WardrobeTransmogFrame, "TOPRIGHT", 0, 0)
	frame:SetParent(WardrobeTransmogFrame)
	frame:Show()
	WardrobeCollectionFrameTab1:SetScript("OnClick", self.WardrobeTabOnClick)
	WardrobeCollectionFrameTab2:SetScript("OnClick", self.WardrobeTabOnClick)
	WardrobeTransmogFrame.HeadButton:SetScript("OnClick", self.WardrobeSlotOnClick)
	WardrobeTransmogFrame.ShoulderButton:SetScript("OnClick", self.WardrobeSlotOnClick)
	WardrobeTransmogFrame.SecondaryShoulderButton:SetScript("OnClick", self.WardrobeSlotOnClick)
	WardrobeTransmogFrame.BackButton:SetScript("OnClick", self.WardrobeSlotOnClick)
	WardrobeTransmogFrame.ChestButton:SetScript("OnClick", self.WardrobeSlotOnClick)
	WardrobeTransmogFrame.ShirtButton:SetScript("OnClick", self.WardrobeSlotOnClick)
	WardrobeTransmogFrame.TabardButton:SetScript("OnClick", self.WardrobeSlotOnClick)
	WardrobeTransmogFrame.WristButton:SetScript("OnClick", self.WardrobeSlotOnClick)
	WardrobeTransmogFrame.HandsButton:SetScript("OnClick", self.WardrobeSlotOnClick)
	WardrobeTransmogFrame.WaistButton:SetScript("OnClick", self.WardrobeSlotOnClick)
	WardrobeTransmogFrame.LegsButton:SetScript("OnClick", self.WardrobeSlotOnClick)
	WardrobeTransmogFrame.FeetButton:SetScript("OnClick", self.WardrobeSlotOnClick)
	WardrobeTransmogFrame.MainHandButton:SetScript("OnClick", self.WardrobeSlotOnClick)
	WardrobeTransmogFrame.SecondaryHandButton:SetScript("OnClick", self.WardrobeSlotOnClick)
	self:SetupNameFrame(self.NameFrame, self.NameText)
	if self.SelectFrame == nil then
		self.SelectFrame = CreateFrame("FRAME", nil, WardrobeCollectionFrame, "CollectionsBackgroundTemplate")
		self.SelectFrame:SetScript("OnShow", self.SelectFrameOnShow)
		self:ModelFrames(self.SelectFrame)
		self.RandomButton = CreateFrame("BUTTON", nil, self.SelectFrame, "UIPanelButtonTemplate")
		self:SetupButton(self.RandomButton, "Select Random", 100)
		self.RandomButton:SetPoint("TOPRIGHT", self.SelectFrame, "TOPRIGHT")
		self.DoneButton = CreateFrame("BUTTON", nil, self.SelectFrame, "UIPanelButtonTemplate")
		self:SetupButton(self.DoneButton, "Done", 100)
		self.DoneButton:SetPoint("BOTTOMRIGHT", self.SelectFrame, "BOTTOMRIGHT")
		self.SelectSearchBox = CreateFrame("EDITBOX", nil, self.SelectFrame, "InputBoxTemplate")
		self:SetupEditBox(self.SelectSearchBox, 120)
		self.SelectSearchBox:SetAutoFocus(false)
		self.SelectSearchBox:SetPoint("BOTTOMRIGHT", self.SelectFrame, "TOPRIGHT", -100, 0)
		self.SelectSearchButton = CreateFrame("BUTTON", nil, self.SelectFrame, "UIPanelButtonTemplate")
		self:SetupButton(self.SelectSearchButton, "Search", 100)
		self.SelectSearchButton:SetFrameStrata("TOOLTIP")
		self.SelectSearchButton:SetPoint("BOTTOMRIGHT", self.SelectFrame, "TOPRIGHT", 0, 0)
		self.SelectSortButton = CreateFrame("BUTTON", nil, self.SelectFrame, "UIPanelButtonTemplate")
		self:SetupButton(self.SelectSortButton, "Sort: A-Z", 100)
		self.SelectSortButton:SetFrameStrata("TOOLTIP")
		self.SelectSortButton:SetPoint("TOPLEFT", self.SelectFrame, "TOPLEFT", 0, 0)
		self.Pages = CreateFrame("FRAME", nil, self.SelectFrame, nil)
		self.Pages:SetPoint("BOTTOM", self.SelectFrame, "BOTTOM", 0, 20)
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
	end
	self.SelectFrame:Hide()
end

function TransmogOutfits:ModelFrames(parent)
	self.Models = {}
	self.ModelTexts = {}
	self.Models[1] = CreateFrame("ModelScene", "1", parent, BackdropTemplateMixin and "BackdropTemplate")
	self.ModelTexts[1] = self.Models[1]:CreateFontString(nil, "OVERLAY", "GameFontWhite")
	self:SetupModelFrame(self.Models[1], self.ModelTexts[1], -225, 100)
	self.Models[2] = CreateFrame("ModelScene", "2", parent, BackdropTemplateMixin and "BackdropTemplate")
	self.ModelTexts[2] = self.Models[2]:CreateFontString(nil, "OVERLAY", "GameFontWhite")
	self:SetupModelFrame(self.Models[2], self.ModelTexts[2], -75, 100)
	self.Models[3] = CreateFrame("ModelScene", "3", parent, BackdropTemplateMixin and "BackdropTemplate")
	self.ModelTexts[3] = self.Models[3]:CreateFontString(nil, "OVERLAY", "GameFontWhite")
	self:SetupModelFrame(self.Models[3], self.ModelTexts[3], 75, 100)
	self.Models[4] = CreateFrame("ModelScene", "4", parent, BackdropTemplateMixin and "BackdropTemplate")
	self.ModelTexts[4] = self.Models[4]:CreateFontString(nil, "OVERLAY", "GameFontWhite")
	self:SetupModelFrame(self.Models[4], self.ModelTexts[4], 225, 100)
	self.Models[5] = CreateFrame("ModelScene", "5", parent, BackdropTemplateMixin and "BackdropTemplate")
	self.ModelTexts[5] = self.Models[5]:CreateFontString(nil, "OVERLAY", "GameFontWhite")
	self:SetupModelFrame(self.Models[5], self.ModelTexts[5], -225, -100)
	self.Models[6] = CreateFrame("ModelScene", "6", parent, BackdropTemplateMixin and "BackdropTemplate")
	self.ModelTexts[6] = self.Models[6]:CreateFontString(nil, "OVERLAY", "GameFontWhite")
	self:SetupModelFrame(self.Models[6], self.ModelTexts[6], -75, -100)
	self.Models[7] = CreateFrame("ModelScene", "7", parent, BackdropTemplateMixin and "BackdropTemplate")
	self.ModelTexts[7] = self.Models[7]:CreateFontString(nil, "OVERLAY", "GameFontWhite")
	self:SetupModelFrame(self.Models[7], self.ModelTexts[7], 75, -100)
	self.Models[8] = CreateFrame("ModelScene", "8", parent, BackdropTemplateMixin and "BackdropTemplate")
	self.ModelTexts[8] = self.Models[8]:CreateFontString(nil, "OVERLAY", "GameFontWhite")
	self:SetupModelFrame(self.Models[8], self.ModelTexts[8], 225, -100)
end

function TransmogOutfits:ModelFrameOnClick(button, down)
	local index = TransmogOutfits.FoundOutfits[tonumber(self:GetName()) + 8 * (TransmogOutfits.Page - 1)].index
	if button == "LeftButton" then
		if IsControlKeyDown() then
			TransmogOutfits:PreviewOutfit(index)
		else
			TransmogOutfits:ApplyOutfit(index)
		end
	elseif button == "RightButton" then
		TransmogOutfits.CurrentOutfit = index
		TransmogOutfits:ContextMenu(self)
	end
end

function TransmogOutfits:PreviewOutfit(index)
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
		local outfit = transmogOutfitOutfits[index - self.FoundBlizzardOutfits]
		if outfit ~= nil then
			self:SetTransmogInfo(DressUpFrame.ModelScene:GetPlayerActor(), outfit[1], nil, nil, 1)
			self:SetTransmogInfo(DressUpFrame.ModelScene:GetPlayerActor(), outfit[3], outfit[33], nil, 3)
			self:SetTransmogInfo(DressUpFrame.ModelScene:GetPlayerActor(), outfit[4], nil, nil, 4)
			self:SetTransmogInfo(DressUpFrame.ModelScene:GetPlayerActor(), outfit[5], nil, nil, 5)
			self:SetTransmogInfo(DressUpFrame.ModelScene:GetPlayerActor(), outfit[6], nil, nil, 6)
			self:SetTransmogInfo(DressUpFrame.ModelScene:GetPlayerActor(), outfit[7], nil, nil, 7)
			self:SetTransmogInfo(DressUpFrame.ModelScene:GetPlayerActor(), outfit[8], nil, nil, 8)
			self:SetTransmogInfo(DressUpFrame.ModelScene:GetPlayerActor(), outfit[9], nil, nil, 9)
			self:SetTransmogInfo(DressUpFrame.ModelScene:GetPlayerActor(), outfit[10], nil, nil, 10)
			self:SetTransmogInfo(DressUpFrame.ModelScene:GetPlayerActor(), outfit[15], nil, nil, 15)
			self:SetTransmogInfo(DressUpFrame.ModelScene:GetPlayerActor(), outfit[16], nil, outfit["enchant1"], 16)
			self:SetTransmogInfo(DressUpFrame.ModelScene:GetPlayerActor(), outfit[17], nil, outfit["enchant2"], 17)
			self:SetTransmogInfo(DressUpFrame.ModelScene:GetPlayerActor(), outfit[19], nil, nil, 19)
		end
	end
end

function TransmogOutfits:SetupModelFrame(frame, text, x, y)
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
	frame:SetPoint("CENTER", self.SelectFrame, "CENTER", x, y)
	frame:EnableMouse(true)
	frame:SetScript("OnMouseDown", self.ModelFrameOnClick)
	text:ClearAllPoints()
	text:SetPoint("BOTTOM", frame, "BOTTOM", 0, 10)
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
	frame:SetWidth(WardrobeTransmogFrame:GetWidth() - 100) 
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
	button:SetHeight(25)
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

function TransmogOutfits:SetBlizzOut(info, val)
	transmogOutfitBlizzard = val
end

function TransmogOutfits:GetBlizzOut(info)
	return transmogOutfitBlizzard
end

function TransmogOutfits:OnInitialize()
	self.Frame = CreateFrame("FRAME", nil, UIParent)
	self.Frame:RegisterEvent("ADDON_LOADED")
	self.Frame:RegisterEvent("TRANSMOGRIFY_UPDATE")
	self.Frame:RegisterEvent("TRANSMOGRIFY_CLOSE")
	self.Frame:SetScript("OnEvent", self.FrameOnEvent)
	self.NameFrame = CreateFrame("FRAME", nil, self.Frame, BackdropTemplateMixin and "BackdropTemplate")
	self.NameText = self.NameFrame:CreateFontString(nil, "OVERLAY", "GameFontWhite")
	self.NameFrame:SetPoint("TOP", self.Frame, "TOP")
	self.NewButton = CreateFrame("BUTTON", nil, self.Frame, "UIPanelButtonTemplate")
	self:SetupButton(self.NewButton, "Save New", 100)
	self.NewButton:SetPoint("BOTTOMLEFT", self.Frame, "BOTTOMLEFT")
	self.SelectButton = CreateFrame("BUTTON", nil, self.Frame, "UIPanelButtonTemplate")
	self:SetupButton(self.SelectButton, "Select Outfit", 100)
	self.SelectButton:SetPoint("BOTTOM", self.Frame, "BOTTOM")
	self.SaveButton = CreateFrame("BUTTON", nil, self.Frame, "UIPanelButtonTemplate")
	self:SetupButton(self.SaveButton, "Save Current", 100)
	self.SaveButton:SetPoint("BOTTOMRIGHT", self.Frame, "BOTTOMRIGHT")

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

	local options = {
		name = "Transmog Outfits",
		handler = TransmogOutfits,
		type = "group",
		args = {
			blizzout ={
				name = "Use Blizzard Outfit slots first",
				type = "toggle",
				width = "full",
				desc = "When enabled newly created outfits will be saved using Blizzard Outfit slots until you run out of them",
				set = "SetBlizzOut",
				get = "GetBlizzOut"
			}
		}
	}
	LibStub("AceConfig-3.0"):RegisterOptionsTable("TransmogOutfits", options, nil)
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("TransmogOutfits", "Transmog Outfits")

	if transmogOutfitOutfits == nil then
		transmogOutfitOutfits = {}
	end
	if transmogOutfitBlizzard == nil then
		transmogOutfitBlizzard = false
	end
end