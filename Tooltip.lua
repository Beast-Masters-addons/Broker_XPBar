local _G = _G

-- addon name and namespace
local ADDON, NS = ...

local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON)

-- the Tooltip module
local Tooltip = Addon:NewModule("Tooltip")

-- tooltip library
local QT = LibStub:GetLibrary("LibQTip-1.0")

-- get translations
local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale(ADDON)

-- local functions
local floor    = math.floor
local tostring = tostring

local UnitXP          = _G.UnitXP
local UnitXPMax       = _G.UnitXPMax
local GetXPExhaustion = _G.GetXPExhaustion

-- local variables
local _

local tooltip = nil

local Factions
local History
local ReputationHistory
local QuestInfo

-- constants
local FORMAT_NUMBER_PREFIX = "TT"

-- icons
local ICON_PLUS	 = [[|TInterface\BUTTONS\UI-PlusButton-Up:16:16|t]]
local ICON_MINUS = [[|TInterface\BUTTONS\UI-MinusButton-Up:16:16|t]]

-- callbacks
local function ToggleDetails(cell, option)
	local options = Addon:GetModule("Options")
	
	if options then
		options:ToggleSetting(option)
	
		Tooltip:Refresh()
	end
end

-- module handling
function Tooltip:OnInitialize()
	Factions = Addon:GetModule("Factions")
	History = Addon:GetModule("History")
	ReputationHistory = Addon:GetModule("ReputationHistory")
	QuestInfo = Addon:GetModule("QuestInfo")
end

function Tooltip:OnEnable()
	-- empty
end

function Tooltip:OnDisable()
	self:Remove()
end

function Tooltip:Create(obj, autoHideDelay)
	if not self:IsEnabled() then
		return
	end

	autoHideDelay = autoHideDelay and autoHideDelay or 0.1

	tooltip = QT:Acquire(ADDON.."TT", 3)
	
	tooltip:Hide()
	tooltip:Clear()
	tooltip:SetScale(1)
		
	self:Draw()

	tooltip:SetAutoHideDelay(autoHideDelay, obj)
	tooltip:EnableMouse()
	tooltip:SmartAnchorTo(obj)
	tooltip:Show()
end

function Tooltip:Remove()
	if tooltip then
		tooltip:Hide()
		QT:Release(tooltip)
		tooltip = nil
	end
end

function Tooltip:Refresh()
	if not self:IsEnabled() then
		self:Remove()
		return
	end
	
	self:Draw()
	
	tooltip:Show()
end

function Tooltip:Draw()
	if not tooltip then
		return
	end

	tooltip:Hide()
	tooltip:Clear()
	
	local colcount = tooltip:GetColumnCount()	
	
	-- add header
	local lineNum = tooltip:AddHeader( " " )
	tooltip:SetCell(lineNum, 1, NS:Colorize("White", Addon.FULLNAME), "CENTER", colcount)

	-- add xp data
	if Addon:GetSetting("ShowXP") then
		-- show current data
		tooltip:AddLine(" ")
		
		if Addon.playerLvl < Addon.MAX_LEVEL then
			local totalXP = UnitXPMax("player")
			local currentXP = UnitXP("player")
			local currentXPPercent = floor(((currentXP / totalXP) * 100) + 0.5)
			local toLevelXP = totalXP - currentXP
			local toLevelXPPercent = floor(((toLevelXP / totalXP) * 100) + 0.5)
						
			local completedQuestXP = QuestInfo:GetValue("CompletedQuestXP")
			local xpCQ, xpCQPercent

			local incompleteQuestXP = QuestInfo:GetValue("IncompleteQuestXP")
			local xpIQ, xpIQPercent

			local toLvlWithoutCQPercent = 0
			
			if completedQuestXP < toLevelXP then
				toLvlWithoutCQPercent = floor((((toLevelXP - completedQuestXP) / totalXP) * 100) + 0.5)
			end
			
			if completedQuestXP > 0 then
				xpCQ = Addon:FormatNumber(completedQuestXP, FORMAT_NUMBER_PREFIX)
				
				xpCQPercent = floor(((completedQuestXP / totalXP) * 100) + 0.5)
				
				xpCQ, xpCQPercent = NS:ColorizeByValue(xpCQPercent, 0, toLevelXPPercent, xpCQ, xpCQPercent)
			end
			
			if incompleteQuestXP > 0 then
				xpIQ = Addon:FormatNumber(incompleteQuestXP, FORMAT_NUMBER_PREFIX)
				
				xpIQPercent = floor(((incompleteQuestXP / totalXP) * 100) + 0.5)
				
				xpIQ, xpIQPercent = NS:ColorizeByValue(xpIQPercent, 0, toLvlWithoutCQPercent, xpIQ, xpIQPercent)
			end
			
			local lvlUpHint = ""
			
			if completedQuestXP > toLevelXP then
				lvlUpHint = lvlUpHint .. " " .. NS:Colorize("Yellow", L["Level up!"])
			end
			
			local exhaustion = GetXPExhaustion()
			local xpEx, xpExPercent
			
			if exhaustion then
				xpEx = Addon:FormatNumber(exhaustion, FORMAT_NUMBER_PREFIX)
				
				xpExPercent = floor(((exhaustion / totalXP) * 100) + 0.5)
				
				xpEx, xpExPercent = NS:ColorizeByValue(xpExPercent, 0, 150, xpEx, xpExPercent)
			end
			
			currentXP = Addon:FormatNumber(currentXP, FORMAT_NUMBER_PREFIX)
			toLevelXP = Addon:FormatNumber(toLevelXP, FORMAT_NUMBER_PREFIX)
			
			currentXP, toLevelXP, currentXPPercent = NS:ColorizeByValue(currentXPPercent, 0, 100, currentXP, toLevelXP, currentXPPercent)
			
			lineNum = tooltip:AddLine(" ")
			tooltip:SetCell(lineNum, 1, NS:Colorize("Blueish", L["Level"]), "LEFT")
			tooltip:SetCell(lineNum, 2, Addon.playerLvl, "LEFT")

			lineNum = tooltip:AddLine(" ")
			tooltip:SetCell(lineNum, 1, NS:Colorize("Blueish", L["Current XP"]), "LEFT")
			tooltip:SetCell(lineNum, 2, string.format("%s/%s (%s%%)", currentXP, Addon:FormatNumber(totalXP, FORMAT_NUMBER_PREFIX), currentXPPercent), "LEFT")

			if exhaustion then
				lineNum = tooltip:AddLine(" ")
				tooltip:SetCell(lineNum, 1, NS:Colorize("Blueish", L["Rested XP"]), "LEFT")
				tooltip:SetCell(lineNum, 2, string.format("%s (%s%%)", xpEx, xpExPercent), "LEFT")
			end
			
			if completedQuestXP > 0 then			
				lineNum = tooltip:AddLine(" ")
				tooltip:SetCell(lineNum, 1, NS:Colorize("Blueish", L["Completed quest XP"]), "LEFT")
				tooltip:SetCell(lineNum, 2, string.format("%s (%s%%)%s", xpCQ, xpCQPercent, lvlUpHint), "LEFT")
			end
			
			if incompleteQuestXP > 0 then
				lineNum = tooltip:AddLine(" ")
				tooltip:SetCell(lineNum, 1, NS:Colorize("Blueish", L["Incomplete quest XP"]), "LEFT")
				tooltip:SetCell(lineNum, 2, string.format("%s (%s%%)", xpIQ, xpIQPercent), "LEFT")
			end
			
			lineNum = tooltip:AddLine(" ")
			tooltip:SetCell(lineNum, 1, NS:Colorize("Blueish", L["To next level"]), "LEFT")
			tooltip:SetCell(lineNum, 2, toLevelXP, "LEFT")
		
			-- toggle history data +/-
			tooltip:SetCell(lineNum, 3, Addon:GetSetting("TTHideXPDetails") and ICON_PLUS or ICON_MINUS, "RIGHT")
			tooltip:SetCellScript(lineNum, 3, "OnMouseDown", ToggleDetails, "TTHideXPDetails")
		else
			lineNum = tooltip:AddLine(" ")
			tooltip:SetCell(lineNum, 1, NS:Colorize("Blueish", L["Level"]), "LEFT")
			tooltip:SetCell(lineNum, 2, tostring(Addon.playerLvl) .. " " .. L["(max. Level)"], "LEFT")
		end
		
		-- show history data
		if not Addon:GetSetting("TTHideXPDetails") and Addon.playerLvl < Addon.MAX_LEVEL then			
			History:Process()
			
			local kph  = floor(History:GetKillsPerHour())
			local xpph = floor(History:GetXPPerHour())
			
			tooltip:AddLine(" ")
			lineNum = tooltip:AddLine(" ")
			tooltip:SetCell(lineNum, 1, NS:Colorize("Blueish", L["Session XP"]), "LEFT")
			tooltip:SetCell(lineNum, 2, Addon:FormatNumber(History:GetTotalXP(), FORMAT_NUMBER_PREFIX), "LEFT")
			
			lineNum = tooltip:AddLine(" ")
			tooltip:SetCell(lineNum, 1, NS:Colorize("Blueish", L["Session kills"]), "LEFT")
			tooltip:SetCell(lineNum, 2, History:GetTotalKills(), "LEFT")
			
			tooltip:AddLine(" ")
			lineNum = tooltip:AddLine(" ")
			tooltip:SetCell(lineNum, 1, NS:Colorize("Blueish", L["XP per hour"]), "LEFT")
			tooltip:SetCell(lineNum, 2, Addon:FormatNumber(xpph, FORMAT_NUMBER_PREFIX), "LEFT")

			lineNum = tooltip:AddLine(" ")
			tooltip:SetCell(lineNum, 1, NS:Colorize("Blueish", L["Kills per hour"]), "LEFT")
			tooltip:SetCell(lineNum, 2, kph, "LEFT")
			
			tooltip:AddLine(" ")
			lineNum = tooltip:AddLine(" ")
			tooltip:SetCell(lineNum, 1, NS:Colorize("Blueish", L["Time to level"]), "LEFT")
			tooltip:SetCell(lineNum, 2, History:GetTimeToLevel(), "LEFT")
			
			lineNum = tooltip:AddLine(" ")
			tooltip:SetCell(lineNum, 1, NS:Colorize("Blueish", L["Kills to level"]), "LEFT")
			tooltip:SetCell(lineNum, 2, NS:Colorize("Red", History:GetKillsToLevel() ), "LEFT")		
		end
		
	end
	
	-- add reputation data
	local faction = Addon:GetFaction()
	
	if Addon:GetSetting("ShowRep") and faction then	
		lineNum = tooltip:AddLine(" ")
	
		local name, desc, standing, minRep, maxRep, actualRep, _, _, _, _, _, _, _, _, friendID = Factions:GetFactionInfo(faction)
		local r, g, b, a = Addon:GetBlizzardReputationColor(standing, friendID)
		
		lineNum = tooltip:AddLine(" ")
		tooltip:SetCell(lineNum, 1, NS:Colorize("Orange", L["Faction"]), "LEFT")
		tooltip:SetCell(lineNum, 2, name, "LEFT")

		lineNum = tooltip:AddLine(" ")
		tooltip:SetCell(lineNum, 1, NS:Colorize("Orange", L["Standing"]), "LEFT")
		tooltip:SetCell(lineNum, 2, "|cff" .. string.format("%02x%02x%02x", r*255, g*255, b*255) .. Factions:GetStandingLabel(standing, friendID) .. "|r", "LEFT")		

		if not Addon.atMaxRep then
			local totalRep = maxRep - minRep
			local toLevelRep = maxRep - actualRep
			local toLevelRepPercent = floor(((toLevelRep / totalRep) * 100) + 0.5)
			local currentRep = totalRep - toLevelRep
			local currentRepPercent = floor(((currentRep / totalRep) * 100) + 0.5)

			local completedQuestRep = QuestInfo:GetValue("CompletedQuestRep")
			local repCQ, repCQPercent

			local incompleteQuestRep = QuestInfo:GetValue("IncompleteQuestRep")
			local repIQ, repIQPercent

			local toLvlWithoutCQPercent = 0
			
			if completedQuestRep < toLevelRep then
				toLvlWithoutCQPercent = floor((((toLevelRep - completedQuestRep) / totalRep) * 100) + 0.5)
			end
			
			if completedQuestRep > 0 then
				repCQ = Addon:FormatNumber(completedQuestRep, FORMAT_NUMBER_PREFIX)
				
				repCQPercent = floor(((completedQuestRep / totalRep) * 100) + 0.5)
				
				repCQ, repCQPercent = NS:ColorizeByValue(repCQPercent, 0, toLevelRepPercent, repCQ, repCQPercent)
			end
			
			if incompleteQuestRep > 0 then
				repIQ = Addon:FormatNumber(incompleteQuestRep, FORMAT_NUMBER_PREFIX)
				
				repIQPercent = floor(((incompleteQuestRep / totalRep) * 100) + 0.5)
				
				repIQ, repIQPercent = NS:ColorizeByValue(repIQPercent, 0, toLvlWithoutCQPercent, repIQ, repIQPercent)
			end
			
			local lvlUpHint = ""
			
			if completedQuestRep > toLevelRep then
				lvlUpHint = lvlUpHint .. " " .. NS:Colorize("Yellow", L["Level up!"])
			end			
			
			currentRep = Addon:FormatNumber(currentRep, FORMAT_NUMBER_PREFIX)
			toLevelRep = Addon:FormatNumber(toLevelRep, FORMAT_NUMBER_PREFIX)
				
			currentRep, toLevelRep, currentRepPercent = NS:ColorizeByValue(currentRepPercent, 0, 100, currentRep, toLevelRep, currentRepPercent)

			lineNum = tooltip:AddLine(" ")
			tooltip:SetCell(lineNum, 1, NS:Colorize("Orange", L["Current reputation"]), "LEFT")
			tooltip:SetCell(lineNum, 2, string.format("%s/%s (%s%%)", currentRep, Addon:FormatNumber(totalRep, FORMAT_NUMBER_PREFIX), currentRepPercent), "LEFT")

			if completedQuestRep > 0 then			
				lineNum = tooltip:AddLine(" ")
				tooltip:SetCell(lineNum, 1, NS:Colorize("Orange", L["Completed quest Rep"]), "LEFT")
				tooltip:SetCell(lineNum, 2, string.format("%s (%s%%)%s", repCQ, repCQPercent, lvlUpHint), "LEFT")
			end
			
			if incompleteQuestRep > 0 then
				lineNum = tooltip:AddLine(" ")
				tooltip:SetCell(lineNum, 1, NS:Colorize("Orange", L["Incomplete quest Rep"]), "LEFT")
				tooltip:SetCell(lineNum, 2, string.format("%s (%s%%)", repIQ, repIQPercent), "LEFT")
			end
			
			lineNum = tooltip:AddLine(" ")
			tooltip:SetCell(lineNum, 1, NS:Colorize("Orange", L["To next standing"]), "LEFT")
			tooltip:SetCell(lineNum, 2, toLevelRep, "LEFT")

			-- toggle history data +/-
			tooltip:SetCell(lineNum, 3, Addon:GetSetting("TTHideRepDetails") and ICON_PLUS or ICON_MINUS, "RIGHT")
			tooltip:SetCellScript(lineNum, 3, "OnMouseDown", ToggleDetails, "TTHideRepDetails")
		end
		
		-- show history data
		if not Addon:GetSetting("TTHideRepDetails") and not Addon.atMaxRep then
			ReputationHistory:ProcessFaction(faction)
			ReputationHistory:ProcessMobHistory()
			
			local total = ReputationHistory:GetTotalRep(faction)
			local repph = floor(ReputationHistory:GetRepPerHour(faction))
			
			tooltip:AddLine(" ")
			
			if Addon.playerLvl == Addon.MAX_LEVEL then
				lineNum = tooltip:AddLine(" ")
				tooltip:SetCell(lineNum, 1, NS:Colorize("Orange", L["Session kills"]), "LEFT")
				tooltip:SetCell(lineNum, 2, History:GetTotalKills(), "LEFT")
			end

			lineNum = tooltip:AddLine(" ")
			tooltip:SetCell(lineNum, 1, NS:Colorize("Orange", L["Session rep"]), "LEFT")
			tooltip:SetCell(lineNum, 2, Addon:FormatNumber(total, FORMAT_NUMBER_PREFIX), "LEFT")
			
			lineNum = tooltip:AddLine(" ")
			tooltip:SetCell(lineNum, 1, NS:Colorize("Orange", L["Rep per hour"]), "LEFT")
			tooltip:SetCell(lineNum, 2, Addon:FormatNumber(repph, FORMAT_NUMBER_PREFIX), "LEFT")

			if Addon.playerLvl == Addon.MAX_LEVEL then
				lineNum = tooltip:AddLine(" ")
				tooltip:SetCell(lineNum, 1, NS:Colorize("Orange", L["Kills per hour"]), "LEFT")
				tooltip:SetCell(lineNum, 2, floor(History:GetKillsPerHour()), "LEFT")
			end
			
			lineNum = tooltip:AddLine(" ")
			tooltip:SetCell(lineNum, 1, NS:Colorize("Orange", L["Time to level"]), "LEFT")
			tooltip:SetCell(lineNum, 2, ReputationHistory:GetTimeToLevel(faction), "LEFT")
						
			lineNum = tooltip:AddLine(" ")
			tooltip:SetCell(lineNum, 1, NS:Colorize("Orange", L["Kills to level"]), "LEFT")
			tooltip:SetCell(lineNum, 2, NS:Colorize("Red", ReputationHistory:GetKillsToLevel(faction) ), "LEFT")					
		end
		
	end
	
	-- add hint
	if not Addon:GetSetting("HideHint") then
		tooltip:AddLine(" ")
		lineNum = tooltip:AddLine(" ")
		tooltip:SetCell(lineNum, 1,  NS:Colorize("Brownish", L["Click"] .. ":" ) .. " " .. NS:Colorize("Yellow", L["Send current XP to an open editbox."] ), nil, "LEFT", colcount)
		if faction then
			lineNum = tooltip:AddLine(" ")
			tooltip:SetCell(lineNum, 1, NS:Colorize("Brownish", L["Shift-Click"] .. ":" ) .. " " .. NS:Colorize("Yellow", L["Send current reputation to an open editbox."] ), nil, "LEFT", colcount )
		end
		lineNum = tooltip:AddLine(" ")
		tooltip:SetCell(lineNum, 1, NS:Colorize("Brownish", L["Right-Click"] .. ":" ) .. " " .. NS:Colorize("Yellow", L["Open option menu."] ), nil, "LEFT", colcount )
	end
	
end

-- test
function Tooltip:Debug(msg)
	Addon:Debug("(Tooltip) " .. tostring(msg))
end
