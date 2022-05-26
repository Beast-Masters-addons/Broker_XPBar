local _G = _G

-- addon name and namespace
local ADDON, NS = ...

-- local functions
local string_format = string.format
local tinsert       = table.insert
local pairs         = pairs
local tostring      = tostring

-- get translations
local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale(ADDON)

-- coloring tools
local Crayon = LibStub:GetLibrary("LibCrayon-3.0")

-- colors
NS.HexColors = {
	Blueish  = "04adcb",
	Brownish = "eda55f",
	GrayOut  = "888888",
	Green    = "00ff00",
	Magenta  = "ff00ff",
	Orange   = "e54100",
	Red      = "ff0000",
	White    = "ffffff",
	Yellow   = "ffff00",
}

-- utilities
local tablestack = setmetatable({}, {__mode = 'k'})

local cmdLinePattern = "^ *([^%s]+) *"

function NS:GetArgs(str)
   local ret = self:NewTable()
   local pos=0
   
   while true do
     local word
     _, pos, word=string.find(str, cmdLinePattern, pos+1)
	 
     if not word then
       break
     end
	 
     --word = string.lower(word)
     table.insert(ret, word)
   end
   
   return ret
end

function NS:Colorize(color, text)
    if not text then
	    return ""
	end

	if type(text) ~= "string" then
		text = tostring(text)
	end
	
	if NS.HexColors[color] then
		text = text:gsub("(.*)(|r)", "%1%2|cff" .. NS.HexColors[color])
		text = "|cff" .. NS.HexColors[color] .. tostring(text) .. "|r"
	end
	
	return text
end

function NS:ColorizeByValue(value, from, to, ...)
	if type(value) == "number" and Crayon then
		from = from or 0
		to   = to or 1
		
		local hexColor = Crayon:GetThresholdHexColor(value, from, to)
		
		local args = {...}
		local ret = {}
		
		for k, v in ipairs(args) do
			v = "|cff" .. hexColor .. v .. "|r"
			
			ret[k] = v
		end
		
		return unpack(ret)
	else
		return ...
	end
end

function NS:GetColorByValue(value, from, to)
	if type(value) == "number" and Crayon then
		from = from or 0
		to   = to or 1
		
		return Crayon:GetThresholdHexColor(value, from, to)
	end
	
	return "ffffff"
end

function NS:ConvertRGBToHexColor(r, g, b)
	if type(r) ~= "number" or type(g) ~= "number" or type(b) ~= "number" then
		return "ffffff"
	end
	
	local factor = 255

	if r > 1 or g > 1 or b > 1 then
		factor = 1
	end
	
	r = r >= 0 and r or 0
	r = r < factor and r or factor
	
	g = g >= 0 and g or 0
	g = g < factor and g or factor

	b = b >= 0 and b or 0
	b = b < factor and b or factor
	
	return string.format("%02x%02x%02x", r*factor, g*factor, b*factor)
end

function NS:IsValidHexColor(color, withAlpha)
	if type(color) ~= "string" then
		return false
	end
	
	local requiredLength = withAlpha and 8 or 6
	
	if string.len(color) ~= requiredLength then
		return false
	end

	return not string.match(color, "[^0-9a-f]") and true or false
end

function NS:ClearTable(tab)
	if type(tab) == "table" then
		for k in pairs(tab) do
			tab[k] = nil
		end
	end
end

function NS:NewTable(...)
	local tab = next(tablestack) or {...}
	
	if tablestack[tab] then
		for i = 1, select("#", ...) do
			tab[i] = select(i, ...)
		end
	end
	
	tablestack[tab] = nil
	
	return tab
end

function NS:ReleaseTable(tab)
	if type(tab) == "table" then
		self:ClearTable(tab)
		tablestack[tab] = true	
	end
end

function NS:FormatTime(stamp)
	stamp = type(stamp) == "number" and stamp or 0
	
	local days    = floor(stamp/86400)
	local hours   = floor((stamp - days * 86400) / 3600)
	local minutes = floor((stamp - days * 86400 - hours * 3600) / 60)
	local seconds = floor((stamp - days * 86400 - hours * 3600 - minutes * 60))

	if days > 0 then
		return string_format("%dd %02d:%02d", days, hours, minutes)
	else
		return string_format("%02d:%02d", hours, minutes)
	end
end

local abbreviations = {
		[0]  = "", 
		[1]  = L["Abbrev_kilo"], 
		[2]  = L["Abbrev_million"], 
		[3]  = L["Abbrev_billion"], 
}

function NS:FormatNumber(number, sep, abbrev, decimals)
	if type(number) ~= "number" then
		return number
	end
	
	local lvl    = 0
	
	if abbrev then
		while number >= 1000 do
			number = number / 1000
			lvl = lvl + 1
			
			if lvl == #abbreviations - 1 then
				break
			end
		end				
	end
	
	number = string.format("%." .. decimals .. "f", number)
	
	local num, decimal = string.match(number,'^(%d*)(.-)$')
	
	if sep then
		num = num:reverse():gsub('(%d%d%d)', "%1"..L["_S_thousand_separator"]):reverse()
		-- remove leading separator if necessary
		-- TODO: move into regexp pattern above
		num = num:gsub('^([^%d])(.*)', "%2")
	end	
	
	-- trim right zeros
	decimal = decimal:gsub('^(%p%d-)(0*)$', "%1")
	
	if decimal == "." then 
		decimal = ""
	else
		-- localize decimal seperator
		decimal = decimal:gsub('^(%p)(%d*)$', L["_S_decimal_separator"].."%2")
	end
	
	return num .. decimal .. abbreviations[lvl]
end
