local _G = _G

-- addon name and namespace
local ADDON, NS = ...

local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON)

-- get translations
local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale(ADDON)

-- the modules
local Factions   = Addon:GetModule("Factions")
local History    = Addon:GetModule("History")
local Options    = Addon:GetModule("Options")
local QuestInfo  = Addon:GetModule("QuestInfo")
local RepHistory = Addon:GetModule("ReputationHistory")
local TextEngine = Addon:GetModule("TextEngine")

-- local functions
local floor    = math.floor
local tostring = tostring

local UnitXP          = UnitXP
local UnitXPMax       = UnitXPMax
local GetXPExhaustion = GetXPExhaustion
local UnitLevel       = UnitLevel

local _

-- the script environment 
local ScriptEnv = setmetatable({}, {__index = _G})

TextEngine.ScriptEnv = ScriptEnv

local function IsTemporalValue(id)
	if id == "TimeToLevel" or id == "XPPerHour"  or id == "KillsPerHour" or id == "TimeToStanding" or id == "ReputationPerHour" then
		return true
	end
	
	return false
end

local function GetMockUpValue(id)
	if id == "XP" then
		return 2700
	elseif id == "MaxXP" then
		return 10000
	elseif id == "QuestCompleteXP" then
		return 770
	elseif id == "QuestIncompleteXP" then
		return 1350
	elseif id == "Rested" then
		return 6030
	elseif id == "Level" then
		return 65
	elseif id == "KillsToLevel" then
		return 263
	elseif id == "TimeToLevel" then
		return NS:FormatTime(5278)
	elseif id == "XPPerHour" then
		return 4979
	elseif id == "KillsPerHour" then
		return 173
	elseif id == "Reputation" then
		return 7230
	elseif id == "MaxReputation" then
		return 12000
	elseif id == "QuestCompleteRep" then
		return 1270
	elseif id == "QuestIncompleteRep" then
		return 1045
	elseif id == "Standing" then
		return Factions:GetStandingLabel(6)
	elseif id == "Faction" then
		return "Rainbow Unicorns"
	elseif id == "TimeToStanding" then
		return NS:FormatTime(13683)
	elseif id == "KillsToStanding" then
		return 1073
	elseif id == "ReputationPerHour" then
		return 1255
	end
	
	return "{?id?}"
end
ScriptEnv.GetMockUpValue = GetMockUpValue

local function GetValue(id, ...)
	if ScriptEnv.mockUpValues then
		return GetMockUpValue(id)
	end

	ScriptEnv.temporalText = IsTemporalValue(id)
	
	if id == "XP" then
		return UnitXP("player")
	elseif id == "MaxXP" then
		return UnitXPMax("player")
	elseif id == "QuestCompleteXP" then
		return QuestInfo:GetValue("CompletedQuestXP")
	elseif id == "QuestIncompleteXP" then
		return QuestInfo:GetValue("IncompleteQuestXP")
	elseif id == "Rested" then
		return GetXPExhaustion() or 0
	elseif id == "Level" then
		return UnitLevel("player")
	elseif id == "KillsToLevel" then
		return History:GetKillsToLevel()
	elseif id == "TimeToLevel" then
		return History:GetTimeToLevel()
	elseif id == "XPPerHour" then
		return History:GetXPPerHour()
	elseif id == "KillsPerHour" then
		return History:GetKillsPerHour()
	elseif id == "Reputation" then
		local _, _, _, minRep, _, currentRep = Factions:GetFactionInfo(Addon:GetFaction())
		
		return currentRep - minRep
	elseif id == "MaxReputation" then
		local _, _, _, minRep, maxRep = Factions:GetFactionInfo(Addon:GetFaction())
		
		return maxRep - minRep
	elseif id == "QuestCompleteRep" then
		return QuestInfo:GetValue("CompletedQuestRep")
	elseif id == "QuestIncompleteRep" then
		return QuestInfo:GetValue("IncompleteQuestRep")
	elseif id == "Standing" then
		local _, _, standing = Factions:GetFactionInfo(Addon:GetFaction())

		return Factions:GetStandingLabel(standing)
	elseif id == "Faction" then		
		local name = Factions:GetFactionName(Addon:GetFaction())
	
		local maxLength = select(1, ...)
	
		if type(maxLength) == "number" and name and name:len() > maxLength then
			local short = Options:GetShortName(Addon:GetFaction())
			
			if short then
				name = short
			end
		end
	
		return name
	elseif id == "TimeToStanding" then
		return RepHistory:GetTimeToLevel(Addon:GetFaction())
	elseif id == "KillsToStanding" then
		return RepHistory:GetKillsToLevel(Addon:GetFaction())
	elseif id == "ReputationPerHour" then
		return RepHistory:GetRepPerHour(Addon:GetFaction())
	end
	
	return "{?id?}"
end
ScriptEnv.GetValue = GetValue

local function GetDescription(id, short)
	if ScriptEnv.mockUpValues then
		return GetMockUpValue(id)
	end

	if id == "XP" then
		return short and L["XP"] or L["Experience"]
	elseif id == "MaxXP" then
		return short and L["Max. XP"] or L["Maximum Experience"]
	elseif id == "QuestCompleteXP" then
		return short and L["Abbrev_Quest Complete"] or L["Quest Complete"]
	elseif id == "QuestIncompleteXP" then
		return short and L["Abbrev_Quest Incomplete"] or L["Quest Incomplete"]
	elseif id == "Rested" then
		return short and L["Abbrev_Rested"] or L["Rested"]
	elseif id == "Level" then
		return short and L["Lvl"] or L["Level"]
	elseif id == "KillsToLevel" then
		return short and L["Abbrev_Kills to Level"] or L["Kills to Level"]
	elseif id == "TimeToLevel" then
		return short and L["Abbrev_Time to Level"] or L["Time to Level"]
	elseif id == "XPPerHour" then
		return short and L["XP/h"] or L["Experience per Hour"]
	elseif id == "KillsPerHour" then
		return short and L["Kills/h"] or L["Kills per Hour"]
	elseif id == "Reputation" then
		return short and L["Rep"] or L["Reputation"]
	elseif id == "MaxReputation" then
		return short and L["Max. Rep"] or L["Maximum Reputation"]
	elseif id == "QuestCompleteRep" then
		return short and L["Abbrev_Quest Complete"] or L["Quest Complete"]
	elseif id == "QuestIncompleteRep" then
		return short and L["Abbrev_Quest Incomplete"] or L["Quest Incomplete"]
	elseif id == "Standing" then
		return short and L["Abbrev_Standing"] or L["Standing"]
	elseif id == "Faction" then
		return short and L["Abbrev_Faction"] or L["Faction"]
	elseif id == "TimeToStanding" then
		return short and L["Abbrev_Time to Standing"] or L["Time to next Standing"]
	elseif id == "KillsToStanding" then
		return short and L["Abbrev_Kills to Standing"] or L["Kills to next Standing"]
	elseif id == "ReputationPerHour" then
		return short and L["Rep/h"] or L["Reputation per Hour"]
	end
	
	return "{?id?}"
end
ScriptEnv.GetDescription = GetDescription

local function AtMax(id)
	if ScriptEnv.mockUpValues then
		return false
	end

	if id == "XP" then
		return Addon.MAX_LEVEL == UnitLevel("player")
	elseif id == "Rested" then
		local exhaustion = GetXPExhaustion() or 0
		local maxXP = UnitXPMax("player")
		
		return Percentage(exhaustion, 0, maxXP) == 150
	elseif id == "Level" then
		return Addon.MAX_LEVEL == UnitLevel("player")
	elseif id == "Reputation" then
		local _, _, _, _, _, _, _, _, _, _, _, _, _, _, _, atMax = Factions:GetFactionInfo(Addon:GetFaction())
		
		return atMax
	elseif id == "Standing" then
		local _, _, standing, _, _, _, _, _, _, _, _, _, _, _, friendID = Factions:GetFactionInfo(Addon:GetFaction())

		return friendID and standing == 6 or standing == 8
	end
	
	return nil
end
ScriptEnv.AtMax = AtMax

local function HasWatchedFaction()
	if ScriptEnv.mockUpValues then
		return true
	end

	return Addon:GetFaction() and true or false
end
ScriptEnv.HasWatchedFaction = HasWatchedFaction

local function Check(id)
	if ScriptEnv.mockUpValues then
		return true
	end

	local valid = true
	local message
	
	if id == "XP" then
		if AtMax("XP") then
			valid = false
			message = L["Max. Level"] 
		end
	elseif id == "Reputation" then
		if not HasWatchedFaction() then
			valid = false
			message = L["No watched faction"] 
		elseif AtMax("Reputation") then
			valid = false
			message = L["Max. Reputation"] 
		end
	end
	
	return valid, message
end
ScriptEnv.Check = Check

local function FormatNumber(value, useAbbrev)
	return NS:FormatNumber(value, Options:GetSetting("Separators"), useAbbrev, Options:GetSetting("DecimalPlaces"))
end
ScriptEnv.FormatNumber = FormatNumber

local function Percentage(value, minValue, maxValue)
	value = value or 0
	minValue = minValue or 0
	maxValue = maxValue or 1
	
	if minValue == maxValue then
		return 100
	end
	
	return floor((((value - minValue) / (maxValue - minValue)) * 100) + 0.5)
end
ScriptEnv.Percentage = Percentage

local function GetColor(value, from, to)
	return NS:GetColorByValue(value, from, to)
end
ScriptEnv.GetColor = GetColor

local function GetColorById(id)
	if id == "XP" then
		return GetColor(GetValue("XP"), 0, GetValue("MaxXP"))
	elseif id == "QuestCompleteXP" then
		return GetColor(GetValue("QuestCompleteXP"), 0, GetValue("MaxXP") - GetValue("XP"))
	elseif id == "QuestIncompleteXP" then
		return GetColor(GetValue("QuestIncompleteXP"), 0, GetValue("MaxXP") - GetValue("XP") - GetValue("QuestCompleteXP"))
	elseif id == "Rested" then
		return GetColor(GetValue("Rested"), 0, GetValue("MaxXP") * 1.5)
	elseif id == "Reputation" then
		return GetColor(GetValue("Reputation"), 0, GetValue("MaxReputation"))
	elseif id == "QuestCompleteRep" then
		return GetColor(GetValue("QuestCompleteRep"), 0, GetValue("MaxReputation") - GetValue("Reputation"))
	elseif id == "QuestIncompleteRep" then
		return GetColor(GetValue("QuestIncompleteRep"), 0, GetValue("MaxReputation") - GetValue("Reputation") - GetValue("QuestCompleteRep"))
	elseif id == "Standing" then
		local faction = Addon:GetFaction()
		local _, _, standing, _, _, _, _, _, _, _, _, _, _, _, friendID = Factions:GetFactionInfo(faction)
		local r, g, b, a = Addon:GetBlizzardReputationColor(standing, friendID)
		
		return string.format("%02x%02x%02x", r*255, g*255, b*255)
	end
	
	return "ffffff"
end
ScriptEnv.GetColorById = GetColorById

local function Colorize(color, text)
	if text == nil then
		return ""
	end

	if type(color) == "table" then
		color = NS:ConvertRGBToHexColor(color.r, color.g, color.b)
	elseif not NS:IsValidHexColor(color) then
		color = "ffffff"
	end
	
	return string.format("|cff%s%s|r", color, text)
end
ScriptEnv.Colorize = Colorize
