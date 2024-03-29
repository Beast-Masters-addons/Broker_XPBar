local _G = _G

-- addon name and namespace
local ADDON, NS = ...

local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON)

-- the History module
local History = Addon:NewModule("History")

-- local functions
local pairs   = pairs
local tinsert = table.insert
local tremove = table.remove
local tgetn   = table.getn
local time    = time
local sqrt    = math.sqrt
local floor   = math.floor
local ceil    = math.ceil

local GetNumGroupMembers    = _G.GetNumGroupMembers
local GetNumSubgroupMembers = _G.GetNumSubgroupMembers
local GetXPExhaustion       = _G.GetXPExhaustion
local IsInRaid              = _G.IsInRaid
local UnitXP                = _G.UnitXP
local UnitXPMax             = _G.UnitXPMax

local LE_PARTY_CATEGORY_HOME = _G.LE_PARTY_CATEGORY_HOME

local _

-- constants
local MAX_HISTORY      = 12
local MAX_TIME_MINUTES = 120

local moduleData = {
	-- data
	totalKills    = 0,
	totalXP       = 0,
	activityKills = 0,
	activityXP    = 0,
	xpPerKill     = 0,
	grpXpPerKill  = 0,
	raidPenaltyPerKill = 0,
	startTime     = nil,
	endRestTime   = nil,
	startXP       = 0,
	lvlMaxXP      = 0,
	doneLvlXP     = 0,
	activeBucket  = floor(time() / 60) - 1,
	taintedXP     = true,
	taintedMobs   = false,
	historyXP     = {},
	historyMobs   = {},
	
	-- params
	weight        = 0.5,
	timeframe     = 3600,
}

-- module handling
function History:OnInitialize()	
	-- empty
end

function History:OnEnable()
	-- init the module
	self:Initialize()
end

function History:OnDisable()
	self:Reset()
end

function History:Initialize()
	self:Reset()

	moduleData.startTime = time()
	
	if (GetXPExhaustion() or 0) == 0 then
		moduleData.endRestTime  = moduleData.startTime
	end
	
	moduleData.totalKills    = 0
	moduleData.totalXP       = 0
	moduleData.activityKills = 0
	moduleData.activityXP    = 0
	moduleData.startXP       = UnitXP("player")
	moduleData.lvlMaxXP      = UnitXPMax("player")	
end

function History:Reset()
	for key in pairs(moduleData.historyXP) do
		NS:ReleaseTable(moduleData.historyXP[key])
		moduleData.historyXP[key] = nil
	end
	
	for index in ipairs(moduleData.historyMobs) do
		NS:ReleaseTable(moduleData.historyMobs[index])
		moduleData.historyMobs[index] = nil
	end	
end

-- xp rate calculations
function History:GetWriteBucket()
	local bucketTime = floor(time() / 60)
	local bucket = moduleData.historyXP[#moduleData.historyXP]
	
	if not bucket or bucket.time ~= bucketTime then
		bucket = NS:NewTable()
		
		bucket.time    = bucketTime		
		bucket.totalXP = 0
		bucket.kills   = 0

		tinsert(moduleData.historyXP, bucket)
	end
	
	return bucket
end

function History:GetTimeToLevel()
	if moduleData.totalXP == 0 then
		return "~"
	end

	local duration = time() - moduleData.startTime

	if duration == 0 then
		return "~"
	end

	local durationRest = 0
	
	if moduleData.endRestTime then
		durationRest = moduleData.endRestTime - moduleData.startTime
	end
	
	local xpToGo = UnitXPMax("player") - UnitXP("player")
	
	-- xp/s (current)
	local xpPerSecCurrent = self:GetXPPerSecond()
	-- kills/s (current)
	local killsPerSecCurrent = self:GetKillsPerSecond()
	-- fraction of time with rested bonus
	local restFactor

	if moduleData.timeframe == 0 or duration < moduleData.timeframe then
		restFactor   = durationRest / duration
	else
		local durationRestActivity = 0
		
		if durationRest > 0 then
			durationRestActivity = durationRest - (duration - moduleData.timeframe)
		end
		
		restFactor = (durationRestActivity / moduleData.timeframe) * moduleData.weight + (durationRest / duration) * (1-moduleData.weight)		
	end

	if xpPerSecCurrent == 0 then
		return "~"
	end
	
	-- xp/s (based on mob kills)
	local xpPerSecMobs = moduleData.xpPerKill * killsPerSecCurrent
	
	local xpRested = GetXPExhaustion() or 0
	
	-- fraction of xp/s done by mobkills
	local mobFraction = xpPerSecMobs / xpPerSecCurrent
	
	-- how far does the rested bonus extend 
	-- based on our current fraction of mobkills of xp earned 
	local xpRestRange = 0

	if mobFraction > 0 then
		xpRestRange = xpRested / mobFraction
	end
	
	if xpRestRange > xpToGo then
		xpRestRange = xpToGo
	end

	-- xpPerSecCurrent = xpPerSecNoMobs + 2*xpPerSecMobs
	local ttl = xpRestRange / xpPerSecCurrent + (xpToGo - xpRestRange) / (xpPerSecCurrent - (xpPerSecMobs * restFactor))
	
	return NS:FormatTime(ttl)	
end

function History:GetKillsToLevel()
	if moduleData.xpPerKill == 0 then 
		return "~" 
	end
	
	local rested = GetXPExhaustion() or 0
	local xpToGo = UnitXPMax("player") - UnitXP("player")
	
	local bonus = 0
	
	if GetNumGroupMembers(LE_PARTY_CATEGORY_HOME) > 0 then
		if IsInRaid() then
			bonus = moduleData.raidPenaltyPerKill
		else
			bonus = moduleData.grpXpPerKill
		end
	end
	
	-- NOTE: since there is no formula calculating the group bonus available 
	-- we depend on the data we extracted from the combat log
	-- so group bonus is incorrect if the number of players in party/raid changes
	-- but it will adjust fairly quick (and we cant take everything into account)
	if rested >= xpToGo then
		return ceil(xpToGo/(moduleData.xpPerKill * 2 + bonus))
	else
		return ceil((rested/(moduleData.xpPerKill * 2 + bonus)) + ((xpToGo - rested)/(moduleData.xpPerKill + bonus)))
	end
end

function History:GetKillsPerHour()
	return self:GetKillsPerSecond() * 3600
end

function History:GetKillsPerSecond()
	local duration = time() - moduleData.startTime

	if duration == 0 then
		return 0
	end

	if moduleData.timeframe == 0 or duration < moduleData.timeframe then
		return moduleData.totalKills / duration
	else
		return ((moduleData.activityKills / moduleData.timeframe) * moduleData.weight + (moduleData.totalKills / duration) * (1-moduleData.weight))
	end
end

function History:GetXPPerHour()
	return self:GetXPPerSecond() * 3600
end

function History:GetXPPerSecond()
	local duration = time() - moduleData.startTime

	if duration == 0 then
		return 0
	end

	if moduleData.timeframe == 0 or duration < moduleData.timeframe then
		return moduleData.totalXP / duration
	else		
		return ((moduleData.activityXP / moduleData.timeframe) * moduleData.weight + (moduleData.totalXP / duration) * (1-moduleData.weight))
	end
end

function History:Process()
	self:ProcessXPHistory()
	self:ProcessMobHistory()
end

function History:ProcessXPHistory()
	local currentBucket = floor(time() / 60)
	if not moduleData.taintedXP and currentBucket == moduleData.activeBucket then 
		return 
	end
	
	moduleData.activeBucket = currentBucket

	-- remove old buckets
	local oldest = moduleData.activeBucket - MAX_TIME_MINUTES
	
	while #moduleData.historyXP ~= 0 and moduleData.historyXP[1].time <= oldest do
		NS:ReleaseTable(moduleData.historyXP[1])
		tremove(moduleData.historyXP, 1)
	end

	local xp, mobxp, kills = 0, 0, 0
	
	oldest = moduleData.activeBucket - moduleData.timeframe / 60
	
	for _, bucket in pairs(moduleData.historyXP) do
		if bucket.time > oldest then
			xp    = xp + bucket.totalXP
			kills = kills + bucket.kills
		end
	end

	moduleData.activityXP    = xp
	moduleData.activityKills = kills
	
	moduleData.taintedXP = false	
end

function History:ProcessMobHistory()
	if not moduleData.taintedMobs then 
		return 
	end
	
	-- regular mean
	local total = 0
	local mean = 0
	local size = #moduleData.historyMobs
	
	for _, xp in ipairs(moduleData.historyMobs) do
		total = total + xp.kxp
	end
	
	mean = total/size

	-- std deviation
	total = 0
	local stdev = 0
	
	for _, xp in pairs(moduleData.historyMobs) do
		total = total + (xp.kxp - mean)^2
	end
	
	if size > 1 then
		stdev = sqrt(total/(size-1))
	else
		stdev = 0
	end

	-- mean of values within the stdev
	total = 0
	local group = 0
	local raid = 0
	local count = 0
	
	local low = mean - stdev
	local high = mean + stdev
	
	for _, xp in ipairs(moduleData.historyMobs) do
		if xp.kxp >= low and xp.kxp <= high then
			total = total + xp.kxp
			group = group + xp.gxp
			raid  = raid - xp.pxp
			count = count + 1
		end
	end
	
	if count == 0 then
		moduleData.xpPerKill          = 0
		moduleData.grpXpPerKill       = 0
		moduleData.raidPenaltyPerKill = 0
	else
		moduleData.xpPerKill          = total/count
		moduleData.grpXpPerKill       = group/count
		moduleData.raidPenaltyPerKill = raid/count
	end

	moduleData.taintedMobs = false	
end

function History:UpdateXP()
	local bucket = self:GetWriteBucket()

	-- check for lvl up
	if moduleData.lvlMaxXP < UnitXPMax("player") then
		local leftXP = moduleData.lvlMaxXP - (moduleData.totalXP + moduleData.startXP)
		moduleData.totalXP = moduleData.totalXP + leftXP
		bucket.totalXP = bucket.totalXP + leftXP
		moduleData.doneLvlXP = moduleData.totalXP

		moduleData.startXP  = 0
		moduleData.lvlMaxXP = UnitXPMax("player")	
	end

	local lvlXP = UnitXP("player") - moduleData.startXP
	local delta = lvlXP - (moduleData.totalXP - moduleData.doneLvlXP)
	
	-- track activity	
	moduleData.totalXP = lvlXP + moduleData.doneLvlXP
	bucket.totalXP = bucket.totalXP + delta
	
	if not moduleData.endRestTime and (GetXPExhaustion() or 0) == 0 then
		moduleData.endRestTime  = time()
	end

	moduleData.taintedXP = true
end

function History:AddKill(xp, bonus, penalty)
	-- track activity	
	local bucket = self:GetWriteBucket()
	
	moduleData.totalKills   = moduleData.totalKills + 1
	bucket.kills = bucket.kills + 1

	-- track mob kills
	local mobdata = NS:NewTable()
	
	mobdata.kxp = xp
	mobdata.gxp = bonus
	mobdata.pxp = penalty	
	
	tinsert(moduleData.historyMobs, mobdata)
				
	-- remove oldest entry if we exceed history size
	if #moduleData.historyMobs > MAX_HISTORY then
		NS:ReleaseTable(moduleData.historyMobs[1])
		tremove(moduleData.historyMobs, 1)
	end
		
	moduleData.taintedMobs = true	
end

-- getter
function History:GetTotalXP()
	return moduleData.totalXP
end

function History:GetTotalKills()
	return moduleData.totalKills
end

-- params
function History:GetWeight()
	return moduleData.weight
end

function History:SetWeight(weight)
	if weight < 0 then
		weight = 0
	elseif weight > 1 then
		weight = 1
	end

	if weight == moduleData.weight then
		return
	end
	
	moduleData.weight = weight
	
	moduleData.taintedXP = true
end

function History:GetTimeFrame()
	return moduleData.timeframe
end

function History:SetTimeFrame(timeframe)
	if timeframe < 0 then
		timeframe = 0
	end

	if timeframe == moduleData.timeframe then
		return
	end
	
	moduleData.timeframe = timeframe
	
	moduleData.taintedXP = true
end

-- helper
function History:IsTainted()
	return moduleData.taintedXP or moduleData.taintedMobs
end

-- test
function History:Debug(msg)
	Addon:Debug("(History) " .. tostring(msg))
end

