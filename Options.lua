local _G = _G

-- addon name and namespace
local ADDON, NS = ...

local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON)

-- the Options module
local Options = Addon:NewModule("Options")

-- internal event handling
Options.callbacks = LibStub("CallbackHandler-1.0"):New(Options)

-- setup libs
local AceGUI            = LibStub("AceGUI-3.0")
local AceConfig 		= LibStub:GetLibrary("AceConfig-3.0")
local AceConfigReg 		= LibStub:GetLibrary("AceConfigRegistry-3.0")
local AceConfigDialog	= LibStub:GetLibrary("AceConfigDialog-3.0")

local LibSharedMedia = LibStub("LibSharedMedia-3.0", true)

-- get translations
local L              = LibStub:GetLibrary("AceLocale-3.0"):GetLocale(ADDON)

-- local functions
local pairs   = pairs
local tinsert = table.insert
local tremove = table.remove

local _

local BLACK = {r = 0, g = 0, b = 0, a = 1}

local DEFAULT_LENGTH = 250
local dimension

local Factions
local Notifications
local TextEngine

function GetMaxDimension()
    if _G.WOW_PROJECT_ID ~= _G.WOW_PROJECT_MAINLINE then
        local index = GetCurrentResolution()
        local resolutions = NS:NewTable(GetScreenResolutions())

        if index > 0 and index <= #resolutions then
            x, y = resolutions[index]:match("(%d+)x(%d+)")
        else
            x = GetScreenWidth()
            y = GetScreenHeight()
        end
    else
        x = GetScreenWidth()
        y = GetScreenHeight()
    end
    
	x = tonumber(x)
	y = tonumber(y)
	
    NS:ReleaseTable(resolutions)
    
    if not x or not y then
        return DEFAULT_LENGTH
    end
    
	return x > y and x or y
end

-- options
local defaults = {
	profile = {
		ShowText               = "XP",
		ShowXP                 = true,
		ShowRep                = false,
		ShowQuestCompletedXP   = true,
		ShowQuestIncompleteXP  = true,
		ShowQuestCompletedRep  = true,
		ShowQuestIncompleteRep = true,
		Shadow                 = true,
		Thickness              = 2,
		Length                 = 0,
		Spark                  = 1,
		Inverse                = false,
		ExternalTexture        = false,
		Texture                = nil,
		NoTexture              = false,
		LabelXPText            = "XPValueCompact",
		LabelRepText           = "RepValueCompact",
		BarXPText              = "XPFullNoColor",
		BarRepText             = "RepFullNoColor",
		Separators             = false,
		TTAbbreviations        = false,
		DecimalPlaces          = 2,
		ShowBlizzBars          = false,
		HideHint               = false,
		Location               = "Bottom",
		xOffset                = 0,
		yOffset                = 0,
		Inside                 = false,
		Strata                 = "HIGH",
		Jostle                 = false,
		BlizzRep               = true,
        Minimap	               = false,
        MaxHideXPText          = false,
        MaxHideXPBar           = false,
        MaxHideRepText         = false,
        MaxHideRepBar          = false,
        AutoTrackOnGain        = false,
        AutoTrackOnLoss        = false,
		XP                     = {r = 0.0, g = 0.4, b = 0.9, a = 1},
		QuestCompletedXP       = {r = 0.2, g = 1.0, b = 0.2, a = 1},
		QuestIncompleteXP      = {r = 1.0, g = 0.6, b = 0.0, a = 1},
		Rest                   = {r = 1.0, g = 0.2, b = 1.0, a = 1},
		None                   = {r = 0.0, g = 0.0, b = 0.0, a = 1},
		Rep                    = {r = 1.0, g = 0.2, b = 1.0, a = 1},
		QuestCompletedRep      = {r = 0.2, g = 1.0, b = 0.2, a = 1},
		QuestIncompleteRep     = {r = 1.0, g = 0.6, b = 0.0, a = 1},
		NoRep                  = {r = 0.0, g = 0.0, b = 0.0, a = 1},
		Weight                 = 0.8,
		TimeFrame              = 30,
		TTHideXPDetails        = false,
		TTHideRepDetails       = false,
		Ticks                  = 0,
		ShowBarText            = false,
		MouseOver              = false,
		Font                   = Addon.FONT_NAME_DEFAULT,
		FontSize               = 10,
		SideBySideText         = false,
		SideBySideSeparator    = " | ",
		Notification           = false,
		ToastNotification      = true,
		factions               = {},
	},
	char = {
	},	
}

local strata = {
	opt2val = 
	{
		[1] = "BACKGROUND", 
		[2] = "LOW", 
		[3] = "MEDIUM", 
		[4] = "HIGH", 
		[5] = "DIALOG", 
		[6] = "FULLSCREEN", 
		[7] = "FULLSCREEN_DIALOG", 
		[8] = "TOOLTIP" 
	},
	val2opt = 
	{
		BACKGROUND        = 1, 
		LOW               = 2, 
		MEDIUM            = 3, 
		HIGH              = 4, 
		DIALOG            = 5, 
		FULLSCREEN        = 6, 
		FULLSCREEN_DIALOG = 7, 
		TOOLTIP           = 8, 
	},
}

-- bookkeeping for show text
-- (needed to achieve ordered combobox, named option value and translated display value)
local showtext = {
	val2txt = {
		None     = L["None"], 
		XP       = L["XP"], 
		Rep      = L["Reputation"], 
		XPFirst  = L["XP over Rep"], 
		RepFirst = L["Rep over XP"], 
	},
	opt2txt = {
		[1]  = L["None"], 
		[2]  = L["XP"], 
		[3]  = L["Reputation"], 
		[4]  = L["XP over Rep"], 
		[5]  = L["Rep over XP"], 
	},
	opt2val = {
		[1]  = "None", 
		[2]  = "XP", 
		[3]  = "Rep", 
		[4]  = "XPFirst", 
		[5]  = "RepFirst", 
	},
	val2opt = {
		None     = 1, 
		XP       = 2, 
		Rep      = 3, 
		XPFirst  = 4, 
		RepFirst = 5, 
	}
}

-- cache faction info
local factionTable = {}
local lookupOptIndexToFaction = {}
local lookupFactionToOptIndex = {}

-- frame selector
local mousehook     = CreateFrame("Frame")
mousehook.tooltip   = _G.GameTooltip
mousehook.setCursor = _G.SetCursor

function mousehook:OnUpdate(elap)
    if IsMouseButtonDown("RightButton") then
        return self:Stop()
    end

    local frame = GetMouseFocus()
    local name = frame and frame:GetName() or tostring(frame)
    
    SetCursor("CAST_CURSOR")
    if not frame then return end
    self.tooltip:SetOwner(frame, "ANCHOR_BOTTOMLEFT")
    self.tooltip:SetText(name, 1.0, 0.82, 0)
    self.tooltip:Show()
    
    if IsMouseButtonDown("LeftButton") then
        self:Stop()
        if not type(frame.GetName) == 'function' or not frame:GetName() then
            Addon:Output(L["This frame has no global name and cannot be used!"])
        else
        	Options:SetSetting("Frame", name)
        	AceConfigReg:NotifyChange(Addon.FULLNAME)
        end
    end
end

function mousehook:Start()
    self:SetScript("OnUpdate", self.OnUpdate)
end

function mousehook:Stop()
	ResetCursor()
    self.tooltip:Hide()
    self:SetScript("OnUpdate", nil)
end

hooksecurefunc(_G.GameMenuFrame, "Show", function() mousehook:Stop() end)

-- ticks
local tickSelection = {0, 1, 2, 3, 4, 9, 19}

local tickConfig = {}

do
	for _, ticks in pairs(tickSelection) do
		tickConfig[ticks] = NS:Colorize("Yellow", string.format("%i: ", ticks)) .. NS:Colorize("Blueish", string.format("%.4g%% ", 100/(ticks+1))) .. L["per Tick"]
	end
end

local textsConfig = {
	xpBarLabels = {},
	xpBrokerLabels = {},
	repBarLabels = {},
	repBrokerLabels = {},
	templateLabels = {},
	customLabels = {},
	textTemplate = nil,
	textCustom = nil,
	useMockUpValues = false,
}

local shortNamesConfig = {
	faction = 1,
}

-- module handling
function Options:OnInitialize()
	Factions      = Addon:GetModule("Factions")
	Notifications = Addon:GetModule("Notifications")
	TextEngine    = Addon:GetModule("TextEngine")
	
	-- options
	self.options = {}
	
	-- options
	self.db = LibStub:GetLibrary("AceDB-3.0"):New(Addon.MODNAME.."_DB", defaults, "Default")
	
	Notifications:SetSinkStorage(self.db.profile)
	
    dimension = GetMaxDimension()
    
	self:Setup()
		
	-- profile support
	self.options.args.profile = LibStub:GetLibrary("AceDBOptions-3.0"):GetOptionsTable(self.db)
	self.db.RegisterCallback(self, "OnProfileChanged", "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileCopied",  "OnProfileChanged")
	self.db.RegisterCallback(self, "OnProfileReset",   "OnProfileChanged")

	AceConfigReg:RegisterOptionsTable(Addon.FULLNAME, self.options)
	AceConfigDialog:AddToBlizOptions(Addon.FULLNAME)
end

function Options:OnEnable()
	-- empty
end

function Options:OnDisable()
	-- empty
end

function Options:OnProfileChanged(event, database, newProfileKey)
	self.db.profile = database.profile
	
	Addon:OnOptionsReloaded()
end

function Options:Setup()
	self.options = {
		type = 'group',
		args = {
			bars = {
				type = 'group',
				name = L["Bar Properties"],
				desc = L["Set the bar properties."],
				order = 1,
				args = {
					thickness = {
						type = 'range',
						name = L["Thickness"],
						desc = L["Set the thickness of the bars."],
						get = function() return self:GetSetting("Thickness") end,
						set = function(info, value)
							self:SetSetting("Thickness", value)
						end,
						min = 1.5,
						max = 64,
						step = 0.1,
						order = 1,
					},
					length = {
						type = 'range',
						name = L["Length"],
						desc = L["Set the length of the bars. If zero bar will adjust to the dimension of the frame it attaches to."],
						get = function() return self:GetSetting("Length") end,
						set = function(info, value)
							self:SetSetting("Length", value)
						end,
						min = 0,
						max = dimension,
						step = 1,
						order = 2,
					},
					showxp = {
						type = 'toggle',
						name = L["Show XP Bar"],
						desc = L["Show the XP bar."],
						get = function() return self:GetSetting("ShowXP") end,
						set = function()
							self:ToggleSetting("ShowXP")
						end,
						order = 3,
					},
					showrep = {
						type = 'toggle',
						name = L["Show Reputation Bar"],
						desc = L["Show the reputation bar."],
						get = function() return self:GetSetting("ShowRep") end,
						set = function()
							self:ToggleSetting("ShowRep")
						end,
						order = 4,
					},
					showQuestCompleteXP = {
						type = 'toggle',
						name = L["Show Completed Quest XP"],
						desc = L["Show XP of completed quests on the bar."],
						get = function() return self:GetSetting("ShowQuestCompletedXP") end,
						set = function()
							self:ToggleSetting("ShowQuestCompletedXP")
						end,
						width = "full",
						order = 5,
					},
					showQuestIncompleteXP = {
						type = 'toggle',
						name = L["Show Incomplete Quest XP"],
						desc = L["Show XP of incomplete quests on the bar."],
						get = function() return self:GetSetting("ShowQuestIncompleteXP") end,
						set = function()
							self:ToggleSetting("ShowQuestIncompleteXP")
						end,
						width = "full",
						order = 6,
					},
					showQuestCompleteRep = {
						type = 'toggle',
						name = L["Show Completed Quest Reputation"],
						desc = L["Show reputation of completed quests on the bar."],
						get = function() return self:GetSetting("ShowQuestCompletedRep") end,
						set = function()
							self:ToggleSetting("ShowQuestCompletedRep")
						end,
						width = "full",
						order = 7,
					},
					showQuestIncompleteRep = {
						type = 'toggle',
						name = L["Show Incomplete Quest Reputation"],
						desc = L["Show reputation of incomplete quests the bar."],
						get = function() return self:GetSetting("ShowQuestIncompleteRep") end,
						set = function()
							self:ToggleSetting("ShowQuestIncompleteRep")
						end,
						width = "full",
						order = 8,
					},
					spark = {
						type = 'range',
						name = L["Spark Intensity"],
						desc = L["Set the brightness level of the spark."],
						get = function() return self:GetSetting("Spark") end,
						set = function(info, value) 
							self:SetSetting("Spark", value)
						end,
						min = 0,
						max = 1,
						step = 0.01,
						bigStep = 0.05,
						order = 9,
					},
					shadow = {
						type = 'toggle',
						name = L["Shadow"],
						desc = L["Toggle shadow display for bars."],
						get = function() return self:GetSetting("Shadow") end,
						set = function()
							self:ToggleSetting("Shadow")
						end,
						order = 10,
					},
					inverse = {
						type = 'toggle',
						name = L["Inverse Order"],
						desc = L["Place the reputation bar before the XP bar."],
						get = function() return self:GetSetting("Inverse") end,
						set = function()
							self:ToggleSetting("Inverse")
						end,
						order = 11,
					},
					noTex = {
						type = 'toggle',
						name = L["No Texture"],
						desc = L["Don't use any texture but use opaque colors for bars."],
						get = function() return self:GetSetting("NoTexture") end,
						set = function()
							self:ToggleSetting("NoTexture")
						end,
						order = 12,
					},
					external = {
						type = 'toggle',
						name = L["Other Texture"],
						desc = L["Use external texture for bar instead of the one provided with the addon."],
						get = function() return self:GetSetting("ExternalTexture") end,
						set = function()
							self:ToggleSetting("ExternalTexture")
						end,
						hidden = function(info)
							return not LibSharedMedia
						end,
						disabled = function(info)
							return self:GetSetting("NoTexture")
						end,
						order = 13,
					},
					texture = {
						type = 'select',
						name = L["Bar Texture"],
						desc = L["Texture of the bars."] .. "\n" .. L["If you want more textures, you should install the addon 'SharedMedia'."],
						get = function() return self:GetSetting("Texture") end,
						set = function(info, value)
							self:SetSetting("Texture", value)
						end,
						values = function(info)
							return LibSharedMedia:HashTable("statusbar")
						end,
						hidden = function(info)
							return not LibSharedMedia
						end,
						disabled = function(info)
							return self:GetSetting("NoTexture") or not self:GetSetting("ExternalTexture")
						end,
						dialogControl = AceGUI.WidgetRegistry["LSM30_Statusbar"] and "LSM30_Statusbar" or nil,
						order = 14,
					},
					ticks = {
						type = 'select',
						name = L["Ticks"],
						desc = L["Set the number of ticks shown on the bar."],
						get = function() return self:GetSetting("Ticks") end,
						set = function(info, key)
							self:SetSetting("Ticks", key)
						end,
						values = tickConfig,
						order = 15,
					},
					frame = {
						type = 'group',
						name = L["Frame"],
						desc = L["Set the frame attachment properties."],
						order = 1,
						args = {
							attached = {
								type = "input",
								name = L["Frame to attach to"],
								desc = L["The exact name of the frame to attach to."],
								get = function()
										return self:GetSetting("Frame")
									end,
								set = function(info, value)
									self:SetSetting("Frame", value)
								end,
								order = 1,
							},
							attach = {
								type = "execute",
								name = L["Select by Mouse"],
								desc = L["Click to activate the frame selector. (Left-Click to select frame, Right-Click do deactivate selector)"],
								func = function() mousehook:Start() end,
								order = 2,
							},
							location = {
								type = "select", 
								name = L["Attach to Side"],
								desc = L["Select the side to attach the bars to."],
								get = function()
										return self:GetSetting("Location")
									end,
								set = function(info, value)
									self:SetSetting("Location", value)
								end,
								values = { Top = L["Top"], Bottom = L["Bottom"], Left = L["Left"], Right = L["Right"] },
								order = 3,
							},
							strata = {
								type = "select", 
								name = L["Strata"],
								desc = L["Select the strata of the bars."],
								get = function() return strata.val2opt[self:GetSetting("Strata")] end,
								set = function(info, value)
									self:SetSetting("Strata", strata.opt2val[value] or "BACKGROUND")
								end,
								values = strata.opt2val,
								order = 4,
							},
							xOffset = {
								type = 'range',
								name = L["X-Offset"],
								desc = L["Set the x-Offset of the bars."],
								get = function() return self:GetSetting("xOffset") end,
								set = function(info, value)
									self:SetSetting("xOffset", value)
								end,
								min = -dimension,
								max =  dimension,
								step = 1,
								order = 5,
							},
							yOffset = {
								type = 'range',
								name = L["Y-Offset"],
								desc = L["Set the y-Offset of the bars."],
								get = function() return self:GetSetting("yOffset") end,
								set = function(info, value)
									self:SetSetting("yOffset", value)
								end,
								min = -dimension,
								max =  dimension,
								step = 1,
								order = 6,
							},
							inside = {
								type = 'toggle',
								name = L["Inside"],
								desc = L["Attach bars to the inside of the frame."],
								get = function() return self:GetSetting("Inside") end,
								set = function()
									self:ToggleSetting("Inside")
								end,
								order = 7,
							},
							jostle = {
								type = 'toggle',
								name = L["Jostle"],
								desc = L["Move Blizzard-frames to avoid overlapping with the bars."],
								get = function() return self:GetSetting("Jostle") end,
								set = function()
									self:ToggleSetting("Jostle")
								end,
								order = 8,
							},
							refresh = {
								type = 'execute',
								name = L["Refresh"],
								desc = L["Refresh bar position."],
								func = function() 
									local Bar = Addon:GetModule("Bar")
									
									if Bar then
										Bar:Reanchor() 
									end
								end,
								order = 9,
							},
						},
					},
					colors = {
						type = 'group',
						name = L["Colors"],
						desc = L["Set the bar colors."],
						order = 2,
						args = {
							xpBarDesc = { 
								type = "header",
								name = L["XP Bar Colors"],
								order = 1,
							},
							currentXP = {
								type = "color",
								name = L["Current XP"],
								desc = L["Set the color of the XP bar."],
								hasAlpha = true,
								get = function ()
									return self:GetColor("XP")
								end,
								set = function (info, r, g, b, a)
									self:SetColor("XP", r, g, b, a)
								end,
								order = 2,
							},
							restedXP = {
								type = 'color',
								name = L["Rested XP"],
								desc = L["Set the color of the rested bar."],
								hasAlpha = true,
								get = function ()
									return self:GetColor("Rest")
								end,
								set = function (info, r, g, b, a)
									self:SetColor("Rest", r, g, b, a)
								end,
								order = 3,
							},
							completedQuestXP = {
								type = 'color',
								name = L["Completed Quest XP"],
								desc = L["Set the color of the completed quest XP bar."],
								hasAlpha = true,
								get = function ()
									return self:GetColor("QuestCompletedXP")
								end,
								set = function (info, r, g, b, a)
									self:SetColor("QuestCompletedXP", r, g, b, a)
								end,
								order = 4,
							},
							incompleteQuestXP = {
								type = 'color',
								name = L["Incomplete Quest XP"],
								desc = L["Set the color of the incomplete quest XP bar."],
								hasAlpha = true,
								get = function ()
									return self:GetColor("QuestIncompleteXP")
								end,
								set = function (info, r, g, b, a)
									self:SetColor("QuestIncompleteXP", r, g, b, a)
								end,
								order = 5,
							},
							noXP = {
								type = 'color',
								name = L["No XP"],
								desc = L["Set the empty color of the XP bar."],
								hasAlpha = true,
								get = function ()
									return self:GetColor("None")
								end,
								set = function (info, r, g, b, a)
									self:SetColor("None", r, g, b, a)
								end,
								order = 6,
							},
							repBarDesc = { 
								type = "header",
								name = L["Reputation Bar Colors"],
								order = 7,
							},
							rep = {
								type = 'color',
								name = L["Reputation"],
								desc = L["Set the color of the reputation bar."],
								hasAlpha = true,
								get = function ()
									return self:GetColor("Rep")
								end,
								set = function (info, r, g, b, a)
									self:SetColor("Rep", r, g, b, a)
								end,
								order = 8,
							},
							completedQuestRep = {
								type = 'color',
								name = L["Completed Quest Reputation"],
								desc = L["Set the color of the completed quest reputation bar."],
								hasAlpha = true,
								get = function ()
									return self:GetColor("QuestCompletedRep")
								end,
								set = function (info, r, g, b, a)
									self:SetColor("QuestCompletedRep", r, g, b, a)
								end,
								order = 9,
							},
							incompleteQuestRep = {
								type = 'color',
								name = L["Incomplete Quest Reputation"],
								desc = L["Set the color of the incomplete quest reputation bar."],
								hasAlpha = true,
								get = function ()
									return self:GetColor("QuestIncompleteRep")
								end,
								set = function (info, r, g, b, a)
									self:SetColor("QuestIncompleteRep", r, g, b, a)
								end,
								order = 10,
							},
							noRep = {
								type = 'color',
								name = L["No Reputation"],
								desc = L["Set the empty color of the reputation bar."],
								hasAlpha = true,
								get = function ()
									return self:GetColor("NoRep")
								end,
								set = function (info, r, g, b, a)
									self:SetColor("NoRep", r, g, b, a)
								end,
								order = 11,
							},
							blizzRep = {
								type = 'toggle',
								name = L["Blizzard Reputation Colors"],
								desc = L["Toggle the use of Blizzard reputation colors."],
								get = function() return self:GetSetting("BlizzRep") end,
								set = function()
									self:ToggleSetting("BlizzRep")
								end,
								width = "full",
								order = 12,
							},
						},
					},
					bartext = {
						type = 'group',
						name = L["Bar Text"],
						desc = L["Set the bar text properties."],
						order = 3,
						args = {
							xpLabel = {
								type = "select", 
								name = L["Select XP Text"],
								desc = L["Select the text for XP bar."],
								get  = function() return self:GetSetting("BarXPText") end,
								set  = function(info, value)
									self:SetSetting("BarXPText", value)
								end,
								values = function(info, value)
									NS:ClearTable(textsConfig.xpBrokerLabels)
									
									for id in TextEngine:IterateTextIdsForTag("XP") do
										textsConfig.xpBrokerLabels[id] = TextEngine:GetLabel(id)
									end

									return textsConfig.xpBrokerLabels
								end,
								order = 1,
							},
							repLabel = {
								type = "select", 
								name = L["Select Reputation Text"],
								desc = L["Select the text for reputation bar."],
								get  = function() return self:GetSetting("BarRepText") end,
								set  = function(info, value)
									self:SetSetting("BarRepText", value)
								end,
								values = function(info, value)
									NS:ClearTable(textsConfig.repBrokerLabels)
									
									for id in TextEngine:IterateTextIdsForTag("Reputation") do
										textsConfig.repBrokerLabels[id] = TextEngine:GetLabel(id)
									end

									return textsConfig.repBrokerLabels
								end,
								order = 2,
							},
							text = {
								type = 'toggle',
								name = L["Show Bar Text"],
								desc = L["Show selected text on bar."],
								get = function() return self:GetSetting("ShowBarText") end,
								set = function()
									self:ToggleSetting("ShowBarText")
								end,
								order = 3,
							},
							mouseover = {
								type = 'toggle',
								name = L["Mouse-Over"],
								desc = L["Show text only on mouse over bar."],
								get = function() return self:GetSetting("MouseOver") end,
								set = function()
									self:ToggleSetting("MouseOver")
								end,
								order = 4,
							},
							sideBySideText = {
								type = 'toggle',
								name = L["Side by Side Text"],
								desc = L["Text for both bars is shown in single line centered over both bars."],
								get = function() return self:GetSetting("SideBySideText") end,
								set = function()
									self:ToggleSetting("SideBySideText")
								end,
								order = 5,
							},
							sideBySideSeparator = {
								type = 'input',
								name = L["Side by Side Separator"],
								desc = L["Separator used between XP and reputation texts."],
								get = function() return self:GetSetting("SideBySideSeparator") end,
								set = function(info, value)
									self:SetSetting("SideBySideSeparator", value)
								end,
								order = 6,
							},
							font = {
								type = 'select',
								name = L["Font"],
								desc = L["Select the font of the bar text."] .. "\n" .. L["If you want more fonts, you should install the addon 'SharedMedia'."],
								get = function() return self:GetSetting("Font") end,
								set = function(info, value)
									self:SetSetting("Font", value)
								end,
								values = function(info)
									return LibSharedMedia:HashTable("font")
								end,
								hidden = function(info)
									return not LibSharedMedia
								end,
								dialogControl = AceGUI.WidgetRegistry["LSM30_Font"] and "LSM30_Font" or nil,
								order = 7,
							},
							fontSize = {
								type = 'range',
								name = L["Font Size"],
								desc = L["Select the font size of the text."],
								get = function() return self:GetSetting("FontSize") end,
								set = function(info, value)
									self:SetSetting("FontSize", value)
								end,
								min = 2,
								max = 32,
								step = 1,
								order = 8,
							},
						},
					},
				},
			},
			label = {
				type = 'group',
				name = L["Broker Label"],
				desc = L["Set the Broker label properties."],
				order = 2,
				args = {
					xpLabel = {
						type = "select", 
						name = L["Select XP Text"],
						desc = L["Select the XP text for Broker display."],
						get  = function() return self:GetSetting("LabelXPText") end,
						set  = function(info, value)
							self:SetSetting("LabelXPText", value)
						end,
						values = function(info, value)
							NS:ClearTable(textsConfig.xpBarLabels)
							
							for id in TextEngine:IterateTextIdsForTag("XP") do
								textsConfig.xpBarLabels[id] = TextEngine:GetLabel(id)
							end

							return textsConfig.xpBarLabels
						end,
						order = 1,
					},
					repLabel = {
						type = "select", 
						name = L["Select Reputation Text"],
						desc = L["Select the reputation text for Broker display."],
						get  = function() return self:GetSetting("LabelRepText") end,
						set  = function(info, value)
							self:SetSetting("LabelRepText", value)
						end,
						values = function(info, value)
							NS:ClearTable(textsConfig.repBarLabels)
							
							for id in TextEngine:IterateTextIdsForTag("Reputation") do
								textsConfig.repBarLabels[id] = TextEngine:GetLabel(id)
							end

							return textsConfig.repBarLabels
						end,
						order = 2,
					},
					showText = {
						type = "select", 
						name = L["Select Label Text"],
						desc = L["Select the label text for the Broker display."],
						get  = function() 
							return showtext.val2opt[self:GetSetting("ShowText")]
						end,
						set  = function(info, value)
							self:SetSetting("ShowText", showtext.opt2val[value])
						end,
						values = showtext.opt2txt,
						order = 3,
					},
				},
			},
			tooltip = {
				type = 'group',
				name = L["Tooltip"],
				desc = L["Set the tooltip properties."],
				order = 3,
				args = {
					tooltipAbbrev = {
						type = 'toggle',
						name = L["Abbreviations"],
						desc = L["Use abbreviations to shorten numbers."],
						get  = function() return self:GetSetting("TTAbbreviations") end,
						set  = function()
							self:ToggleSetting("TTAbbreviations")
						end,
						order = 1,
					},
				},
			},
			numbers = {
				type = 'group',
				name = L["Numbers"],
				desc = L["General settings for number formatting."],
				order = 4,
				args = {
					separators = {
						type = 'toggle',
						name = L["Separators"],
						desc = L["Use separators for numbers to improve readability."],
						get  = function() return self:GetSetting("Separators") end,
						set  = function()
							self:ToggleSetting("Separators") 
						end,
						order = 1,
					},
					decimalPlaces = {
						type = 'select',
						name = L["Decimal Places"],
						desc = L["Set the number of decimal places when using abbreviations."],
						get  = function() return self:GetSetting("DecimalPlaces") end,
						set  = function(info, value)
							self:SetSetting("DecimalPlaces", value) 
						end,
						values = { [0] = "0", [1] = "1", [2] = "2", [3] = "3" },
						order = 2,
					},
				},
			},
			texts = {
				type = 'group',
				name = L["Custom Texts"],
				desc = L["Setup custom texts for bars and label."],
				order = 5,
				args = {
					templates = {
						type = "select", 
						name = L["Template Text"],
						desc = L["Texts to be used as templates for custom texts."],
						get  = function() return textsConfig.textTemplate end,
						set  = function(info, value)							
							textsConfig.textTemplate = value
							
							self:Update()
						end,
						values = function(info, value)
							NS:ClearTable(textsConfig.templateLabels)
							
							for id in TextEngine:IterateTextIds() do
								if not TextEngine:IsMutable(id) then
									textsConfig.templateLabels[id] = TextEngine:GetLabel(id)
								end
							end

							return textsConfig.templateLabels
						end,
						order = 1,
					},
					copyTemplate = { 
						type = 'execute',
						name = L["Copy"],
						desc = L["Copy fixed template to selected custom text."],
						func = function()
							if textsConfig.textTemplate and textsConfig.textCustom then
								self:SetSetting(textsConfig.textCustom, TextEngine:GetCode(textsConfig.textTemplate))
							end
							
							self:Update()
						end,	
						disabled = function(info)
							return not textsConfig.textTemplate or not textsConfig.textCustom
						end,
						order = 2,
					},
					previewTemplateText = { 
						type = "description",
						name = function() 
							return textsConfig.textTemplate and TextEngine:GenerateText(textsConfig.textTemplate, textsConfig.useMockUpValues) or L["No template selected."]
						end,
						order = 3,
					},
					customTexts = {
						type = "select", 
						name = L["Custom Text"],
						desc = L["Custom text for configuration."],
						get  = function() return textsConfig.textCustom end,
						set  = function(info, value)
							textsConfig.textCustom = value

							self:Update()
						end,
						values = function(info, value)
							NS:ClearTable(textsConfig.customLabels)
							
							for id in TextEngine:IterateMutableTextIds() do
								textsConfig.customLabels[id] = TextEngine:GetLabel(id)
							end

							return textsConfig.customLabels
						end,
						order = 4,
					},
					previewCustom = { 
						type = 'execute',
						name = L["Preview"],
						desc = L["Preview custom text using dummy data."],
						func = function() 
							self:Update()
						end,	
						disabled = function(info)
							return not textsConfig.textCustom
						end,
						order = 5,
					},
					previewCustomText = { 
						type = "description",
						name = function() 
							return textsConfig.textCustom and TextEngine:GenerateText(textsConfig.textCustom, textsConfig.useMockUpValues) or L["No custom text selected."]
						end,
						order = 6,
					},
					customCode = { 
						type = 'input',
						name = L["Code"],
						desc = L["Custom code to modify."],
						multiline = true,
						width = "full",
						get  = function()
							if textsConfig.textCustom then
								return self:GetSetting(textsConfig.textCustom) or TextEngine:GetCode(textsConfig.textCustom)
							end

							return ""
						end,
						set  = function(info, value)
							if textsConfig.textCustom then
								self:SetSetting(textsConfig.textCustom, value)
							end
						end,
						disabled = function(info)
							return not textsConfig.textCustom
						end,
						order = 7,
					},
					mockUpValues = {
						type = 'toggle',
						name = L["Mock Values"],
						desc = L["Use mock values for preview."],
						get  = function() return textsConfig.useMockUpValues end,
						set  = function()
							textsConfig.useMockUpValues = not textsConfig.useMockUpValues
						end,
						order = 8,
					},
					codeInstructions = { 
						type = "description",
						name = L["Custom code instructions"],
						order = 9,
					},
				},
			},
			notifications = {
				type = 'group',
				name = L["Notifications"],
				desc = L["Set the level up notifications when completed quests allow you to gain a level."],
				order = 6,
				args = {
					notification = {
						type = 'toggle',
						name = L["Notification"],
						desc = L["Show a notification with configurable output target."],
						get  = function() return self:GetSetting("Notification") end,
						set  = function()
							self:ToggleSetting("Notification")
						end,
						order = 1,
					},
					testNotification = { 
						type = 'execute',
						name = L["Test Notification"],
						desc = L["Show a test notification."],
						order = 2,
						func = function() Notifications:SendNotification("Notification", L["Hand in completed quests to level up!"]) end,	
					},
					toastNotification = {
						type = 'toggle',
						name = L["Toast Notification"],
						desc = L["Show a Toast notification."],
						get  = function() return self:GetSetting("ToastNotification") end,
						set  = function()
							self:ToggleSetting("ToastNotification") 
						end,
						order = 3,
					},
					testToast = { 
						type = 'execute',
						name = L["Test Toast"],
						desc = L["Show a test Toast notification."],
						order = 4,
						func = function() Notifications:SendNotification("ToastNotification", L["Hand in completed quests to level up!"]) end,	
					},
				},
			},
			autotrack = {
				type = 'group',
				name = L["Faction Tracking"],
				desc = L["Auto-switch watched faction on reputation gains/losses."],
				order = 7,
				args = {
					gain = {
						type = 'toggle',
						name = L["Switch on Reputation Gain"],
						desc = L["Auto-switch watched faction on reputation gain."],
						get  = function() return self:GetSetting("AutoTrackOnGain") end,
						set  = function()
							self:ToggleSetting("AutoTrackOnGain")
						end,
						width = "full",
						order = 1,
					},
					loss = {
						type = 'toggle',
						name = L["Switch on Reputation Loss"],
						desc = L["Auto-switch watched faction on reputation loss."],
						get  = function() return self:GetSetting("AutoTrackOnLoss") end,
						set  = function()
							self:ToggleSetting("AutoTrackOnLoss") 
						end,
						width = "full",
						order = 2,
					},
				},
			},
			level = {
				type = 'group',
				name = L["Leveling"],
				desc = L["Set the leveling properties."],
				order = 8,
				args = {
					timeFrame = {
						type = 'range',
						name = L["Time Frame"],
						desc = L["Set time frame for dynamic TTL calculation."],
						get = function() return self:GetSetting("TimeFrame") end,
						set = function(info, value) 
							self:SetSetting("TimeFrame", value)
						end,
						min = 0,
						max = 120,
						step = 1,
						order = 1,
					},
					weight = {
						type = 'range',
						name = L["Weight"],
						desc = L["Set the weight of the time frame vs. the session average for dynamic TTL calculation."],
						get = function() return self:GetSetting("Weight") end,
						set = function(info, value) 
							self:SetSetting("Weight", value)
						end,
						min = 0,
						max = 1,
						step = 0.01,
						order = 2,
					},
				},
			},
			maxLvl = {
				type = 'group',
				name = L["Max. XP/Rep"],
				desc = L["Set the display behaviour at maximum level/reputation."],
				order = 9,
				args = {
					hideXpTxt = {
						type = 'toggle',
						name = L["No XP Label"],
						desc = L["Don't show the XP label text at maximum level."],
						get  = function() return self:GetSetting("MaxHideXPText") end,
						set  = function()
							self:ToggleSetting("MaxHideXPText")
						end,
						order = 1,
					},
					hideXpBar = {
						type = 'toggle',
						name = L["No XP Bar"],
						desc = L["Don't show the XP bar at maximum level."],
						get  = function() return self:GetSetting("MaxHideXPBar") end,
						set  = function()
							self:ToggleSetting("MaxHideXPBar")
						end,
						order = 2,
					},
					hideRepTxt = {
						type = 'toggle',
						name = L["No Reputation Label"],
						desc = L["Don't show the reputation label text at maximum reputation."],
						get  = function() return self:GetSetting("MaxHideRepText") end,
						set  = function()
							self:ToggleSetting("MaxHideRepText")
						end,
						order = 3,
					},
					hideRepBar = {
						type = 'toggle',
						name = L["No Reputation Bar"],
						desc = L["Don't show the reputation bar at maximum reputation."],
						get  = function() return self:GetSetting("MaxHideRepBar") end,
						set  = function()
							self:ToggleSetting("MaxHideRepBar")
						end,
						order = 4,
					},
				},
			},
			factions = {
				type = 'group',
				name = L["Factions"],
				desc = L["Faction specific settings."],
				order = 10,
				args = {
					faction = {
						type = "select", 
						name = L["Faction"],
						desc = L["Faction to set a short name for."],
						get  = function() return shortNamesConfig.faction end,
						set  = function(info, value)							
							shortNamesConfig.faction = value
							
							self:Update()
						end,
						handler = self,
						values = "QueryFactions", 
						order = 1,
					},
					shortName = { 
						type = 'input',
						name = L["Short Name"],
						desc = L["Short name for selected faction."],
						get  = function() return self:GetShortName(lookupOptIndexToFaction[shortNamesConfig.faction]) or "" end,
						set  = function(info, value)
							self:SetShortName(lookupOptIndexToFaction[shortNamesConfig.faction], value)
						end,
						disabled = function(info)
							return shortNamesConfig.faction == 1
						end,
						order = 2,
					},
				},
			},
			faction = {
				type = "select", 
				name = L["Faction"],
				desc = L["Select the faction to track."],
				get = function()
					return lookupFactionToOptIndex[Addon:GetFaction()] or 1
				end,
				set = function(info, key)
					Addon:SetFaction(lookupOptIndexToFaction[key] or 0)
				end,
				handler = self,
				values = "QueryFactions", 
				order = 1,
			},
			blizzBars = {
				type = 'toggle',
				name = L["Blizzard Bars"],
				desc = L["Show the default Blizzard bars."],
				get  = function() return self:GetSetting("ShowBlizzBars") end,
				set  = function()
					self:ToggleSetting("ShowBlizzBars") 
				end,
				order = 2,
			},
			minimap = {
				type = 'toggle',
				name = L["Minimap Button"],
				desc = L["Show the minimap button."],
				get  = function() return self:GetSetting("Minimap") end,
				set  = function()
					self:ToggleSetting("Minimap")
				end,
				order = 3,
			},
			hint = {
				type = 'toggle',
				name = L["Hide Hint"],
				desc = L["Hide the usage hint in the tooltip."],
				get  = function() return self:GetSetting("HideHint") end,
				set  = function()
					self:ToggleSetting("HideHint")
				end,
				order = 4,
			},
		}
	}

	self.options.args.notifications.args.notificationTargets = Notifications:GetSinkAce3OptionsDataTable()	
end

function Options:Update()
	AceConfigReg:NotifyChange(Addon.FULLNAME)
end

-- faction helper
function Options:QueryFactions()
	local sortingTable = NS:NewTable()

	-- reset lookup table
	NS:ClearTable(factionTable)
	NS:ClearTable(lookupOptIndexToFaction)
	NS:ClearTable(lookupFactionToOptIndex)
	
	for index, factionID in Factions:IterateAllFactions() do
		if factionID then
			local name, _, standing, _, _ , _ ,_ , _, isHeader, _, hasRep, _, _, _, friendID = Factions:GetFactionInfo(factionID)
			
			if not isHeader or hasRep then
				local r, g, b = Addon:GetBlizzardReputationColor(standing, friendID)
				
				tinsert(sortingTable, {factionID, name, "|cff"..string.format("%02x%02x%02x", r*255, g*255, b*255)..name.."|r"})
			end
		end
	end
	
	Factions:RestoreUI()
	
	-- sort by name
	table.sort(sortingTable, function(a, b) return a[2]<b[2] end)
	
	-- insert nil
	tinsert(sortingTable, 1, {0, L["None"], L["None"]})
	
	for k, v in pairs(sortingTable) do
		tinsert(factionTable, v[3])
		lookupOptIndexToFaction[#factionTable] = v[1]
		lookupFactionToOptIndex[v[1]]          = #factionTable
	end

	NS:ReleaseTable(sortingTable)
	
	return factionTable
end

-- option getter / setter
function Options:GetSetting(option)
	return self.db.profile[option]
end

function Options:SetSetting(option, value)
	local current = self:GetSetting(option)

	if current == value then
		return
	end
	
	self.db.profile[option] = value

	-- fire event when setting changed
	self.callbacks:Fire(ADDON .. "_SETTING_CHANGED", option, value, current)
end

function Options:ToggleSetting(option)
	self:SetSetting(option, not self:GetSetting(option) and true or false)
end

function Options:ToggleSettingTrueNil(option)
	self:SetSetting(option, not self:GetSetting(option) and true or nil)
end

function Options:GetColor(id)
	local color = self.db.profile[id] or BLACK

	return color.r, color.g, color.b, color.a
end

function Options:SetColor(id, r, g, b, a)
	if not self.db.profile[id] then
		return
	end

	local current = {r = self.db.profile[id].r, g = self.db.profile[id].g, b = self.db.profile[id].b, a = self.db.profile[id].a}
	local value   = {r = r, g = g, b = b, a = a}
	
	self.db.profile[id].r = r
	self.db.profile[id].g = g
	self.db.profile[id].b = b
	self.db.profile[id].a = a
	
	-- fire event when setting changed
	self.callbacks:Fire(ADDON .. "_SETTING_CHANGED", id, value, current)
end

function Options:GetShortName(faction)
	return self.db.profile.factions[faction]
end

function Options:SetShortName(faction, value)
	local current = self:GetShortName(option)

	if value == "" or value == Factions:GetFactionName(faction) then
		value = nil
	end
	
	if current == value then
		return
	end
	
	self.db.profile.factions[faction] = value

	-- fire event when setting changed
	self.callbacks:Fire(ADDON .. "_SETTING_CHANGED", option, value, current)
end

function Options:GetCharSetting(option)
	return self.db.char[option]
end

function Options:SetCharSetting(option, value)
	local current = self:GetCharSetting(option)

	if current == value then
		return
	end
	
	self.db.char[option] = value

	-- fire event when setting changed
	self.callbacks:Fire(ADDON .. "_CHAR_SETTING_CHANGED", option, value, current)
end

-- test
function Options:Debug(msg)
	Addon:Debug("(Options) " .. tostring(msg))
end
