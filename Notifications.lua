local _G = _G

-- addon name and namespace
local ADDON, NS = ...

local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON)

-- the Notifications module
local Notifications = Addon:NewModule("Notifications", "AceTimer-3.0", "LibSink-2.0")

-- get translations
local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale(ADDON)

-- toast notifications
local LibToast = LibStub("LibToast-1.0")

-- modules
local Factions  = nil
local QuestInfo = nil

-- constants
local ICON      = "Interface\\Addons\\"..ADDON.."\\icon.tga"

-- local functions
local pairs     = pairs

local UnitLevel = _G.UnitLevel
local UnitXP    = _G.UnitXP
local UnitXPMax = _G.UnitXPMax

local _

local moduleData = {
	-- data
	targets = {
		Notification = true,
		ToastNotification = true,
	},
	
	types = {
	},	
	
	tainted = true,
	timer = nil,
}

-- module handling
function Notifications:OnInitialize()	
	Factions          = Addon:GetModule("Factions")
	QuestInfo         = Addon:GetModule("QuestInfo")

	-- setup toast support
	LibToast:Register(Addon.FULLNAME, function(toast, ...)
		toast:SetTitle(Addon.FULLNAME)
		toast:SetIconTexture(ICON)
		toast:SetText(...)
		toast:SetUrgencyLevel("moderate")
	end)	
	
	-- init the module
	self:Initialize()
end

function Notifications:OnEnable()
	-- nothing
end

function Notifications:OnDisable()
	if moduleData.timer then
		self:CancelTimer(moduleData.timer)
		moduleData.timer = nil
	end

	self:Reset()
end

function Notifications:Reset()
	for notificationType in pairs(moduleData.types) do
		Notifications:ResetType(notificationType)
	end
end

function Notifications:ResetType(notificationType)
	local settings = moduleData.types[notificationType]

	if settings then
		settings.level = 0
	end
end

function Notifications:Initialize()
	moduleData.types["XP"] = {
		level     = 0,
		getter    = "GetNotificationLevel",
		reference = function() return UnitLevel("player"); end,
		message   = L["Hand in completed quests to level up!"],
	}
	
	moduleData.types["Reputation"] = {
		level = 0,
		getter = "GetNotificationStanding",
		reference = function() 
			local faction = Addon:GetFaction()		
			
			if not faction then
				return 0
			end
			
			local _, _, standing = Factions:GetFactionInfo(faction)
			
			return standing
		end,
		message = L["Hand in completed quests to level up faction!"],
	}
	
	moduleData.tainted = true
end

function Notifications:Process(delayed)
	if not moduleData.tainted then
		return
	end

	if delayed then
		self:ScheduleProcess()
		
		return
	end
	
	for notificationType, settings in pairs(moduleData.types) do
		self:SetNotificationLevel(notificationType, self[settings.getter](self))
	end
	
	moduleData.tainted = false
end

function Notifications:ScheduleProcess()
	if not moduleData.timer then
		moduleData.timer = self:ScheduleTimer("ScheduledProcess", 1)
	end
end

function Notifications:ScheduledProcess()
	moduleData.timer = nil
	
	self:Process()
end

function Notifications:SettingChanged(notificationTarget)
	for notificationType, setting in pairs(moduleData.types) do
		self:TrySendNotification(notificationType, notificationTarget)
	end
end

function Notifications:SetNotificationLevel(notificationType, level)	
	local settings = moduleData.types[notificationType]
	
	if settings and settings.level ~= level then
		settings.level = level
		
		self:TrySendNotifications(notificationType)
	end	
end

function Notifications:TrySendNotifications(notificationType)
	for notificationTarget in pairs(moduleData.targets) do
		self:TrySendNotification(notificationType, notificationTarget)
	end
end

function Notifications:TrySendNotification(notificationType, notificationTarget)
	local settings = moduleData.types[notificationType]
	
	if settings and settings.level > settings.reference() and Addon:GetSetting(notificationTarget) then
		self:SendNotification(notificationTarget, settings.message)
	end		
end

function Notifications:GetNotificationLevel()
	local currentXP        = UnitXP("player")
	local maxXP            = UnitXPMax("player")
	local completedQuestXP = QuestInfo:GetValue("CompletedQuestXP")
	
	return currentXP + completedQuestXP >= maxXP and UnitLevel("player") + 1 or UnitLevel("player")
end

function Notifications:GetNotificationStanding()
	local faction = Addon:GetFaction()		
	
	if not faction then
		return 0
	end
	
	local name, _, standing, minRep, maxRep, currentRep, _, _, _, _, _, _, _, _, friendID = Factions:GetFactionInfo(faction)	
	local maxStanding = friendID and 6 or 8	
	local completedQuestRep = QuestInfo:GetValue("CompletedQuestRep")
	
	return (standing < maxStanding and currentRep + completedQuestRep >= maxRep) and standing + 1 or standing
end

function Notifications:SendNotification(notificationTarget, text)
	if type(text) ~= "string" then
		return
	end

	if notificationTarget == "Notification" then
		self:Pour(NS:Colorize("Yellow", text))
	elseif notificationTarget == "ToastNotification" then
		LibToast:Spawn(Addon.FULLNAME, NS:Colorize("Yellow", text))
	end
end

function Notifications:Taint()
	moduleData.tainted = true
end

-- test
function Notifications:Debug(msg)
	Addon:Debug("(Notifications) " .. tostring(msg))
end
