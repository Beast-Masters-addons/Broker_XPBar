local _G = _G

-- addon name and namespace
local ADDON, NS = ...

local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON)

-- get translations
local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale(ADDON)

-- the TextEngine module
local TextEngine = Addon:NewModule("TextEngine")

-- local variables

local _

local moduleData = {
	functionCache = {},
	functionDefinitions = {},
}

-- function definitions
do
	moduleData.functionDefinitions["XPValueOfMax"] = {
		name = "XPValueOfMax",
		label = L["XP: Value/Max"],
		description = L["XP: Value/Max"],
		tag = "XP",
		mutable = false,
		code = [[
local valid, fallbackText = Check("XP")

if not valid then
    return fallbackText
end

local xp = GetValue("XP")
local total = GetValue("MaxXP")
local color = GetColorById("XP")

return Colorize(color, FormatNumber(xp, true)) .. "/" .. Colorize(color, FormatNumber(total, true)) 
]]
	}
	moduleData.functionDefinitions["XPValuePercent"] = {
		name = "XPValuePercent",
		label = L["XP: Value (Percent)"],
		description = L["XP: Value (Percent)"],
		tag = "XP",
		mutable = false,
		code = [[
local valid, fallbackText = Check("XP")

if not valid then
    return fallbackText
end

local xp = GetValue("XP")
local total = GetValue("MaxXP")
local percent = Percentage(xp, 0, total)
local color = GetColorById("XP")

return Colorize(color, FormatNumber(xp, true)) .. " (" .. Colorize(color, percent) .. "%)" 
]]
	}
	moduleData.functionDefinitions["XPValueCompact"] = {
		name = "XPValueCompact",
		label = L["XP: Value/Max (Percent)"],
		description = L["XP: Value/Max (Percent)"],
		tag = "XP",
		mutable = false,
		code = [[
local valid, fallbackText = Check("XP")

if not valid then
    return fallbackText
end

local xp = GetValue("XP")
local total = GetValue("MaxXP")
local percent = Percentage(xp, 0, total)
local color = GetColorById("XP")

return Colorize(color, FormatNumber(xp, true)) .. "/" .. Colorize(color, FormatNumber(total, true)) .. " (" .. Colorize(color, percent) .. "%)" 
]]
	}
	moduleData.functionDefinitions["XPToGoPercent"] = {
		name = "XPToGoPercent",
		label = L["XP: To Go (Percent)"],
		description = L["XP: To Go (Percent)"],
		tag = "XP",
		mutable = false,
		code = [[
local valid, fallbackText = Check("XP")

if not valid then
    return fallbackText
end

local xp = GetValue("XP")
local total = GetValue("MaxXP")
local togo = total - xp
local percent = Percentage(togo, 0, total)
local color = GetColorById("XP")

return Colorize(color, FormatNumber(togo, true)) .. " (" .. Colorize(color, percent) .. "%)" 
]]
	}
	moduleData.functionDefinitions["XPLong"] = {
		name = "XPLong",
		label = L["XP: Long"],
		description = L["XP: Long"],
		tag = "XP",
		mutable = false,
		code = [[
local valid, fallbackText = Check("XP")

if not valid then
    return fallbackText
end

local xp = GetValue("XP")
local total = GetValue("MaxXP")
local percent = Percentage(xp, 0, total)
local color = GetColorById("XP")

local rested = GetValue("Rested")
local restPercent = Percentage(rested, 0, total)
local restColor = GetColorById("Rested")

return Colorize(color, FormatNumber(xp, true)) .. "/" .. Colorize(color, FormatNumber(total, true)) .. " (" .. Colorize(color, percent) .. "%) - R: " .. Colorize(restColor, FormatNumber(rested, true)) .. " (" .. Colorize(restColor, restPercent) .. "%)" 
]]
	}
	moduleData.functionDefinitions["XPLongNoColor"] = {
		name = "XPLongNoColor",
		label = L["XP: Long (No Color)"],
		description = L["XP: Long (No Color)"],
		tag = "XP",
		mutable = false,
		code = [[
local valid, fallbackText = Check("XP")

if not valid then
    return fallbackText
end

local xp = GetValue("XP")
local total = GetValue("MaxXP")
local percent = Percentage(xp, 0, total)

local rested = GetValue("Rested")
local restPercent = Percentage(rested, 0, total)

return FormatNumber(xp, true) .. "/" .. FormatNumber(total, true) .. " (" .. percent .. "%) - R: " .. FormatNumber(rested, true) .. " (" .. restPercent .. "%)" 
]]
	}
	moduleData.functionDefinitions["XPFull"] = {
		name = "XPFull",
		label = L["XP: Full"],
		description = L["XP: Full"],
		tag = "XP",
		mutable = false,
		code = [[
local valid, fallbackText = Check("XP")

if not valid then
    return fallbackText
end

local xp = GetValue("XP")
local total = GetValue("MaxXP")
local percent = Percentage(xp, 0, total)
local color = GetColorById("XP")

local completedPercent = Percentage(GetValue("QuestCompleteXP"), 0, total)
local incompletePercent = Percentage(GetValue("QuestIncompleteXP"), 0, total)

local rested = GetValue("Rested")
local restPercent = Percentage(rested, 0, total)
local restColor = GetColorById("Rested")

return Colorize(color, FormatNumber(xp, true)) .. "/" .. Colorize(color, FormatNumber(total, true)) .. " (" .. Colorize(color, percent) .. "%) - C: " .. Colorize(GetColorById("QuestCompleteXP"), completedPercent) .. "% - I: " .. Colorize(GetColorById("QuestIncompleteXP"), incompletePercent) .. "% - R: " .. Colorize(restColor, FormatNumber(rested, true)) .. " (" .. Colorize(restColor, restPercent) .. "%)" 
]]
	}
	moduleData.functionDefinitions["XPFullNoColor"] = {
		name = "XPFullNoColor",
		label = L["XP: Full (No Color)"],
		description = L["XP: Full (No Color)"],
		tag = "XP",
		mutable = false,
		code = [[
local valid, fallbackText = Check("XP")

if not valid then
    return fallbackText
end

local xp = GetValue("XP")
local total = GetValue("MaxXP")
local percent = Percentage(xp, 0, total)

local completedPercent = Percentage(GetValue("QuestCompleteXP"), 0, total)
local incompletePercent = Percentage(GetValue("QuestIncompleteXP"), 0, total)

local rested = GetValue("Rested")
local restPercent = Percentage(rested, 0, total)

return FormatNumber(xp, true) .. "/" .. FormatNumber(total, true) .. " (" .. percent .. "%) - C: " .. completedPercent .. "% - I: " .. incompletePercent .. "% - R: " .. FormatNumber(rested, true) .. " (" .. restPercent .. "%)"
]]
	}
	moduleData.functionDefinitions["XPTTL"] = {
		name = "XPTTL",
		label = L["XP: Time To Level"],
		description = L["XP: Time To Level"],
		tag = "XP",
		mutable = false,
		code = [[
local valid, fallbackText = Check("XP")

if not valid then
    return fallbackText
end

return GetDescription("TimeToLevel", true) .. ": " .. GetValue("TimeToLevel")
]]
	}
	moduleData.functionDefinitions["XPKTL"] = {
		name = "XPKTL",
		label = L["XP: Kills To Level"],
		description = L["XP: Kills To Level"],
		tag = "XP",
		mutable = false,
		code = [[
local valid, fallbackText = Check("XP")

if not valid then
    return fallbackText
end

local ktl = GetValue("KillsToLevel")	

return GetDescription("KillsToLevel", true) .. ": " .. FormatNumber(ktl, true)
]]
	}
	moduleData.functionDefinitions["XPXPH"] = {
		name = "XPXPH",
		label = L["XP: XP Per Hour"],
		description = L["XP: XP Per Hour"],
		tag = "XP",
		mutable = false,
		code = [[
local valid, fallbackText = Check("XP")

if not valid then
    return fallbackText
end

local xpph = math.floor(GetValue("XPPerHour"))	
		
return GetDescription("XPPerHour", true) .. ": " .. FormatNumber(xpph, true)
]]
	}
	moduleData.functionDefinitions["XPKPH"] = {
		name = "XPKPH",
		label = L["XP: Kills Per Hour"],
		description = L["XP: Kills Per Hour"],
		tag = "XP",
		mutable = false,
		code = [[
local kph = math.floor(GetValue("KillsPerHour"))
		
return GetDescription("KillsPerHour", true) .. ": " .. FormatNumber(kph, true)
]]
	}
	moduleData.functionDefinitions["XPCustomLabel"] = {
		name = "XPCustomLabel",
		label = L["XP: Custom Label"],
		description = L["XP: Custom Label"],
		tag = "XP",
		mutable = true,
		code = [[
local valid, fallbackText = Check("XP")

if not valid then
    return fallbackText
end

local xp = GetValue("XP")
local total = GetValue("MaxXP")
local percent = Percentage(xp, 0, total)
local color = GetColorById("XP")

return Colorize(color, FormatNumber(xp, true)) .. "/" .. Colorize(color, FormatNumber(total, true)) .. " (" .. Colorize(color, percent) .. "%)" 
]]
	}
	moduleData.functionDefinitions["XPCustomBar"] = {
		name = "XPCustomBar",
		label = L["XP: Custom Bar"],
		description = L["XP: Custom Bar"],
		tag = "XP",
		mutable = true,
		code = [[
local valid, fallbackText = Check("XP")

if not valid then
    return fallbackText
end

local xp = GetValue("XP")
local total = GetValue("MaxXP")
local percent = Percentage(xp, 0, total)

local completedPercent = Percentage(GetValue("QuestCompleteXP"), 0, total)
local incompletePercent = Percentage(GetValue("QuestIncompleteXP"), 0, total)

local rested = GetValue("Rested")
local restPercent = Percentage(rested, 0, total)

return FormatNumber(xp, true) .. "/" .. FormatNumber(total, true) .. " (" .. percent .. "%) - C: " .. completedPercent .. "% - I: " .. incompletePercent .. "% - R: " .. FormatNumber(rested, true) .. " (" .. restPercent .. "%)"
]]
	}
	moduleData.functionDefinitions["RepValueOfMax"] = {
		name = "RepValueOfMax",
		label = L["Rep: Value/Max"],
		description = L["Rep: Value/Max"],
		tag = "Reputation",
		mutable = false,
		code = [[
local valid, fallbackText = Check("Reputation")

if not valid then
    return fallbackText
end

local rep = GetValue("Reputation")
local total = GetValue("MaxReputation")
local color = GetColorById("Reputation")

return Colorize(color, FormatNumber(rep, true)) .. "/" .. Colorize(color, FormatNumber(total, true)) 
]]
	}
	moduleData.functionDefinitions["RepValuePercent"] = {
		name = "RepValuePercent",
		label = L["Rep: Value (Percent)"],
		description = L["Rep: Value (Percent)"],
		tag = "Reputation",
		mutable = false,
		code = [[
local valid, fallbackText = Check("Reputation")

if not valid then
    return fallbackText
end

local rep = GetValue("Reputation")
local total = GetValue("MaxReputation")
local percent = Percentage(rep, 0, total)
local color = GetColorById("Reputation")

return Colorize(color, FormatNumber(rep, true)) .. " (" .. Colorize(color, percent) .. "%)" 
]]
	}
	moduleData.functionDefinitions["RepValueCompact"] = {
		name = "RepValueCompact",
		label = L["Rep: Value/Max (Percent)"],
		description = L["Rep: Value/Max (Percent)"],
		tag = "Reputation",
		mutable = false,
		code = [[
local valid, fallbackText = Check("Reputation")

if not valid then
    return fallbackText
end

local rep = GetValue("Reputation")
local total = GetValue("MaxReputation")
local percent = Percentage(rep, 0, total)
local color = GetColorById("Reputation")

return Colorize(color, FormatNumber(rep, true)) .. "/" .. Colorize(color, FormatNumber(total, true)) .. " (" .. Colorize(color, percent) .. "%)" 
]]
	}
	moduleData.functionDefinitions["RepToGoPercent"] = {
		name = "RepValuePercent",
		label = L["Rep: To Go (Percent)"],
		description = L["Rep: To Go (Percent)"],
		tag = "Reputation",
		mutable = false,
		code = [[
local valid, fallbackText = Check("Reputation")

if not valid then
    return fallbackText
end

local rep = GetValue("Reputation")
local total = GetValue("MaxReputation")
local togo = total - rep
local percent = Percentage(togo, 0, total)
local color = GetColorById("Reputation")

return Colorize(color, FormatNumber(togo, true)) .. " (" .. Colorize(color, percent) .. "%)" 
]]
	}
	moduleData.functionDefinitions["RepLong"] = {
		name = "RepLong",
		label = L["Rep: Long"],
		description = L["Rep: Long"],
		tag = "Reputation",
		mutable = false,
		code = [[
local valid, fallbackText = Check("Reputation")

if not valid then
    return fallbackText
end

local rep = GetValue("Reputation")
local total = GetValue("MaxReputation")
local percent = Percentage(rep, 0, total)
local color = GetColorById("Reputation")

local standing = GetValue("Standing")
local standingColor = GetColorById("Standing")

return Colorize(color, FormatNumber(rep, true)) .. "/" .. Colorize(color, FormatNumber(total, true)) .. " (" .. Colorize(color, percent) .. "%) - " .. Colorize(standingColor, standing)
]]
	}
	moduleData.functionDefinitions["RepLongNoColor"] = {
		name = "RepLongNoColor",
		label = L["Rep: Long (No Color)"],
		description = L["Rep: Long (No Color)"],
		tag = "Reputation",
		mutable = false,
		code = [[
local valid, fallbackText = Check("Reputation")

if not valid then
    return fallbackText
end

local rep = GetValue("Reputation")
local total = GetValue("MaxReputation")
local percent = Percentage(rep, 0, total)
local color = GetColorById("Reputation")

local standing = GetValue("Standing")

return FormatNumber(rep, true) .. "/" .. FormatNumber(total, true) .. " (" .. percent .. "%) - " .. standing
]]
	}
	moduleData.functionDefinitions["RepFull"] = {
		name = "RepFull",
		label = L["Rep: Full"],
		description = L["Rep: Full"],
		tag = "Reputation",
		mutable = false,
		code = [[
local valid, fallbackText = Check("Reputation")

if not valid then
    return fallbackText
end

local rep = GetValue("Reputation")
local total = GetValue("MaxReputation")
local percent = Percentage(rep, 0, total)
local color = GetColorById("Reputation")

local standing = GetValue("Standing")
local standingColor = GetColorById("Standing")

local faction = GetValue("Faction")

return Colorize(standingColor, faction) .. ": " .. Colorize(color, FormatNumber(rep, true)) .. "/" .. Colorize(color, FormatNumber(total, true)) .. " (" .. Colorize(color, percent) .. "%) - " .. Colorize(standingColor, standing)
]]
	}
	moduleData.functionDefinitions["RepFullNoColor"] = {
		name = "RepFullNoColor",
		label = L["Rep: Full (No Color)"],
		description = L["Rep: Full (No Color)"],
		tag = "Reputation",
		mutable = false,
		code = [[
local valid, fallbackText = Check("Reputation")

if not valid then
    return fallbackText
end

local rep = GetValue("Reputation")
local total = GetValue("MaxReputation")
local percent = Percentage(rep, 0, total)

local standing = GetValue("Standing")

local faction = GetValue("Faction")

return faction .. ": " .. FormatNumber(rep, true) .. "/" .. FormatNumber(total, true) .. " (" .. percent .. "%) - " .. standing
]]
	}
	moduleData.functionDefinitions["RepTTL"] = {
		name = "RepTTL",
		label = L["Rep: Time To Level"],
		description = L["Rep: Time To Level"],
		tag = "Reputation",
		mutable = false,
		code = [[
local valid, fallbackText = Check("Reputation")

if not valid then
    return fallbackText
end

return GetDescription("TimeToStanding", true) .. ": " .. GetValue("TimeToStanding")
]]
	}
	moduleData.functionDefinitions["RepKTL"] = {
		name = "RepKTL",
		label = L["Rep: Kills To Level"],
		description = L["Rep: Kills To Level"],
		tag = "Reputation",
		mutable = false,
		code = [[
local valid, fallbackText = Check("Reputation")

if not valid then
    return fallbackText
end

return GetDescription("KillsToStanding", true) .. ": " .. GetValue("KillsToStanding")
]]
	}
	moduleData.functionDefinitions["RepRPH"] = {
		name = "RepRPH",
		label = L["Rep: Rep Per Hour"],
		description = L["Rep: Rep Per Hour"],
		tag = "Reputation",
		mutable = false,
		code = [[
local valid, fallbackText = Check("Reputation")

if not valid then
    return fallbackText
end

local rph = math.floor(GetValue("ReputationPerHour"))

return GetDescription("ReputationPerHour", true) .. ": " .. FormatNumber(rph, true)
]]
	}
	moduleData.functionDefinitions["RepKPH"] = {
		name = "RepKPH",
		label = L["Rep: Kills Per Hour"],
		description = L["Rep: Kills Per Hour"],
		tag = "Reputation",
		mutable = false,
		code = [[
local kph = math.floor(GetValue("KillsPerHour"))
		
return GetDescription("KillsPerHour", true) .. ": " .. FormatNumber(kph, true)
]]
	}
	moduleData.functionDefinitions["RepCustomLabel"] = {
		name = "RepCustomLabel",
		label = L["Rep: Custom Label"],
		description = L["Rep: Custom Label"],
		tag = "Reputation",
		mutable = true,
		code = [[
local valid, fallbackText = Check("Reputation")

if not valid then
    return fallbackText
end

local rep = GetValue("Reputation")
local total = GetValue("MaxReputation")
local percent = Percentage(re, 0, total)
local color = GetColorById("Reputation")

return Colorize(color, FormatNumber(rep, true)) .. "/" .. Colorize(color, FormatNumber(total, true)) .. " (" .. Colorize(color, percent) .. "%)" 
]]
	}
	moduleData.functionDefinitions["RepCustomBar"] = {
		name = "RepCustomBar",
		label = L["Rep: Custom Bar"],
		description = L["Rep: Custom Bar"],
		tag = "Reputation",
		mutable = true,
		code = [[
local valid, fallbackText = Check("Reputation")

if not valid then
    return fallbackText
end

local rep = GetValue("Reputation")
local total = GetValue("MaxReputation")
local percent = Percentage(rep, 0, total)

local standing = GetValue("Standing")

local faction = GetValue("Faction")

return faction .. ": " .. FormatNumber(rep, true) .. "/" .. FormatNumber(total, true) .. " (" .. percent .. "%) - " .. standing
]]
	}
end

-- Credits: Core logic taken from Pitbull 4 LuaTexts module. Thank you! :-)
local function GetText(...)
	-- first arg indicates execution success
	local success = select(1, ...)
	
	if not success then
		pcall(geterrorhandler(), select(2, ...))
		
		return "{err}"
	elseif select('#', ...) > 1 and select(2, ...) ~= nil then
		-- create and return the formatted string
		return select(2, ...)
	end

	-- no value returned, return empty string
	return ""
end

-- module handling
function TextEngine:OnInitialize()	
	-- empty
end

function TextEngine:OnEnable()
end

function TextEngine:OnDisable()
end

-- Credits: Core logic taken from Pitbull 4 LuaTexts module. Thank you! :-)
function TextEngine:GenerateText(id, mockUpValues)
	local name = self:GetName(id)
	local code = self:GetCode(id)

	if type(code) ~= "string" then
		return "{?id?}"
	end

	local func = moduleData.functionCache[id]
	local scriptEnv = TextEngine.ScriptEnv

	if not scriptEnv then
		return "{?env?}"
	end
	
	if not func then
		-- build function
		local funcString = 'return function() ' .. code .. ' end'
		local funcName = "TextEngine:"..name
		local createFunc, err = loadstring(funcString, funcName)
		
		if createFunc then
			-- Note: The following call is always safe. The only actual code executing is the
			-- return of the function wrapper that's hard coded above.
			-- So no error handling needed.
			func = createFunc()
			setfenv(func, scriptEnv)
			moduleData.functionCache[id] = func
		else
			geterrorhandler()(err)
			
			return "{err}"
		end
	end

	-- pass additional params in the script environment
	scriptEnv.mockUpValues = mockUpValues and true or false
	scriptEnv.temporalText = false

	return GetText(pcall(func)), scriptEnv.temporalText
end

function TextEngine:GetName(id)
	return moduleData.functionDefinitions[id] and moduleData.functionDefinitions[id].name or nil
end

function TextEngine:GetLabel(id)
	return moduleData.functionDefinitions[id] and moduleData.functionDefinitions[id].label or nil
end

function TextEngine:GetTag(id)
	return moduleData.functionDefinitions[id] and moduleData.functionDefinitions[id].tag or nil
end

function TextEngine:GetDescription(id)
	return moduleData.functionDefinitions[id] and moduleData.functionDefinitions[id].description or nil
end

function TextEngine:IsMutable(id)
	return moduleData.functionDefinitions[id] and moduleData.functionDefinitions[id].mutable or nil
end

function TextEngine:GetCode(id)
	return moduleData.functionDefinitions[id] and moduleData.functionDefinitions[id].code or nil
end

function TextEngine:SetCode(id, code)
	if not self:IsMutable(id) then
		return false
	end
	
	moduleData.functionCache[id] = nil
	moduleData.functionDefinitions[id].code = code
	
	return true
end

-- iterators:
-- IterateTextIds
-- IterateMutableTextIds
-- IterateTextIdsForTag
do --Do-end block for iterators
	local emptyTbl = {}
	local tablestack = setmetatable({}, {__mode = 'k'})

	local function KeyOnlyIter(t, prestate)
		if not t then 
			return nil 
		end

		if t.iterator then
			local key = t.iterator(t.t, prestate)

			if key then
				return key
			end				
		end
		
		tablestack[t] = true
		return nil, nil		
	end

	local function IterateKeys(toIterate)
		local tbl = next(tablestack) or {}		
		tablestack[tbl] = nil
		
		local data = toIterate or emptyTbl
		
		local iterator, t, state = pairs(data)
		
		tbl.iterator   = iterator
		tbl.t          = t
		
		return KeyOnlyIter, tbl, state
	end
	
	--- Returns iterator that provides registered text ids.
	--
	function TextEngine:IterateTextIds()
		return IterateKeys(moduleData.functionDefinitions)
	end

	local function MutableTextIdsIter(t, prestate)
		if not t then 
			return nil 
		end

		if t.iterator then
			local key, value = t.iterator(t.t, prestate)
			while key do
				if value and value.mutable then
					return key
				end

				key, value = t.iterator(t.t, key)
			end
		end
		
		tablestack[t] = true
		return nil, nil		
	end	
	
	--- Returns iterator that provides registered text ids of mutable texts.
	--
	function TextEngine:IterateMutableTextIds()
		local tbl = next(tablestack) or {}		
		tablestack[tbl] = nil
		
		local data = moduleData.functionDefinitions or emptyTbl
		
		local iterator, t, state = pairs(data)
		
		tbl.iterator   = iterator
		tbl.t          = t
		
		return MutableTextIdsIter, tbl, state
	end
	
	local function TextIdsForTagIter(t, prestate)
		if not t then 
			return nil 
		end

		if t.iterator then
			local key, value = t.iterator(t.t, prestate)
			while key do
				if value and value.tag == t.tag then
					return key
				end

				key, value = t.iterator(t.t, key)
			end
		end
		
		tablestack[t] = true
		return nil, nil		
	end	
	
	--- Returns iterator that provides registered text ids with given tag.
	--
	-- @param tag Tag for which the iterator should provide the text ids.
	function TextEngine:IterateTextIdsForTag(tag)
		local tbl = next(tablestack) or {}		
		tablestack[tbl] = nil
		
		local data = moduleData.functionDefinitions or emptyTbl
		
		local iterator, t, state = pairs(data)
		
		tbl.iterator   = iterator
		tbl.t          = t
		tbl.tag        = tag
		
		return TextIdsForTagIter, tbl, state
	end
end

-- test
function TextEngine:Debug(msg)
	Addon:Debug("(TextEngine) " .. tostring(msg))
end
