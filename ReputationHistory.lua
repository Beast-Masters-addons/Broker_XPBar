local _G = _G

-- addon name and namespace
local ADDON, NS = ...

local Addon = LibStub("AceAddon-3.0"):GetAddon(ADDON)

-- the ReputationHistory module
local ReputationHistory = Addon:NewModule("ReputationHistory", "AceTimer-3.0")

-- local functions
local pairs   = pairs
local tinsert = table.insert
local tremove = table.remove
local tgetn   = table.getn
local time    = time
local sqrt    = math.sqrt
local floor   = math.floor
local ceil    = math.ceil

local IsInGuild	= _G.IsInGuild

local CHAT_MSG_GUILD	= _G.CHAT_MSG_GUILD

local _

-- constants
local MAX_HISTORY      = 12
local MAX_TIME_MINUTES = 120

-- modules
local Factions          = nil

-- module data
local moduleData = {
	-- data
	startTime     = nil,
	factions      = {},
	
	-- mob data
	historyMobs   = {
		-- entries
		-- { time, reputation = { faction = amount } }
	},
	
	repPerKill    = {
		-- entries
		-- faction = value
	},
	
	taintedMobs   = false,
	
	-- params
	weight        = 0.5,
	timeframe     = 3600,
}

-- module handling
function ReputationHistory:OnInitialize()	
	-- set module references
	Factions = Addon:GetModule("Factions")
end

function ReputationHistory:OnEnable()
	-- init the module
	self:Initialize()
end

function ReputationHistory:OnDisable()
	self:Reset()
end

function ReputationHistory:Initialize()
	self:Reset()

	moduleData.startTime = time()
	
	self:InitFactions()
end

function ReputationHistory:Reset()
	for faction in pairs(moduleData.factions) do
		local data = moduleData.factions[faction]
		
		for index in ipairs(data.history) do
			NS:ReleaseTable(data.history[index])
		end
		
		NS:ReleaseTable(moduleData.factions[faction])
		moduleData.factions[faction] = nil
	end
	
	for index in pairs(moduleData.historyMobs) do
		NS:ReleaseTable(moduleData.historyMobs[index].factions)
		NS:ReleaseTable(moduleData.historyMobs[index])
		moduleData.historyMobs[index] = nil
	end		
end

function ReputationHistory:InitFactions()
	if IsInGuild() and not self:GuildFactionAvailable() then
		self:ScheduleTimer("InitFactions", 1)
	else
		self:Update()
	end
end

-- reputation rate calculations
function ReputationHistory:InitFaction(faction)
	if not faction or moduleData.factions[faction] then
		return nil
	end

	local _, _, standing, minRep, maxRep, currentRep, _, _, isHeader, _, hasRep = Factions:GetFactionInfo(faction)
	
	if isHeader and not hasRep then
		return nil
	end

	local data = NS:NewTable()
	
	data.startRep      = currentRep
	data.totalRep      = 0
	data.activityRep   = 0
	data.tainted       = false
	data.activeBucket  = floor(time() / 60) - 1
	data.history       = {}
	
	moduleData.factions[faction] = data
	
	return data
end

function ReputationHistory:GetWriteBucket(faction)
	if not moduleData.factions[faction] then
		return nil
	end

	local history = moduleData.factions[faction].history
	
	local bucketTime = floor(time() / 60)
	local bucket = history[#history]
	
	if not bucket or bucket.time ~= bucketTime then
		bucket = NS:NewTable()
		
		bucket.time       = bucketTime
		bucket.reputation = 0

		tinsert(history, bucket)
	end
	
	return bucket
end

function ReputationHistory:GetTimeToLevel(faction)
	if not moduleData.factions[faction] then 
		return "~"
	end
	
	local data = moduleData.factions[faction]
	
	if data.totalRep == 0 then
		return "~"
	end

	local duration = time() - moduleData.startTime

	if duration == 0 then
		return "~"
	end

	local _, _, _, minRep, maxRep, currentRep = Factions:GetFactionInfo(faction)
	local toLvlRep = maxRep - currentRep
	
	-- rep/s (current)
	local repPerSec = self:GetRepPerSecond(faction)

	if not repPerSec or repPerSec == 0 then
		return "~"
	end
	
	local ttl = toLvlRep / repPerSec
	
	return NS:FormatTime(ttl)
end

function ReputationHistory:GetRepPerHour(faction)
	local rps = self:GetRepPerSecond(faction)

	return rps * 3600
end

function ReputationHistory:GetRepPerSecond(faction)
	if not moduleData.factions[faction] then 
		return 0
	end
	
	local data = moduleData.factions[faction]
	
	local duration = time() - moduleData.startTime

	if duration == 0 then
		return 0
	end

	if moduleData.timeframe == 0 or duration < moduleData.timeframe then
		return data.totalRep / duration
	else		
		return ((data.activityRep / moduleData.timeframe) * moduleData.weight + (data.totalRep / duration) * (1-moduleData.weight))
	end
end

function ReputationHistory:GetKillsToLevel(faction)
	if not moduleData.factions[faction] then 
		return "~"
	end
	
	local data = moduleData.factions[faction]
	local repPerKill = moduleData.repPerKill[faction] or 0
	
	if data.totalRep == 0 or repPerKill == 0 then
		return "~"
	end
	
	local _, _, _, minRep, maxRep, currentRep = Factions:GetFactionInfo(faction)
	local toLvlRep = maxRep - currentRep

	return ceil(toLvlRep/repPerKill)
end

function ReputationHistory:GetTotalRep(faction)
	if not moduleData.factions[faction] then 
		return 0
	end
	
	return moduleData.factions[faction].totalRep
end

function ReputationHistory:Process()
	for faction in pairs(moduleData.factions) do
		self:ProcessFaction(faction)
	end
	
	self:ProcessMobHistory()
end

function ReputationHistory:ProcessFaction(faction)
	if not moduleData.factions[faction] then 
		return 
	end

	local data = moduleData.factions[faction]
	local currentBucket = floor(time() / 60)

	if not data.tainted and currentBucket == data.activeBucket then 
		return 
	end
		
	data.activeBucket = currentBucket
	
	-- remove old buckets
	local oldest = data.activeBucket - MAX_TIME_MINUTES
	
	while #data.history ~= 0 and data.history[1].time <= oldest do
		NS:ReleaseTable(data.history[1])
		tremove(data.history, 1)
	end

	local reputation = 0
	
	oldest = data.activeBucket - moduleData.timeframe / 60

	for _, bucket in pairs(data.history) do
		if bucket.time > oldest then
			reputation = reputation + bucket.reputation
		end
	end

	data.activityRep = reputation
	
	data.tainted = false	
end

function ReputationHistory:ProcessMobHistory()
	if not moduleData.taintedMobs then
		return
	end
	
	NS:ClearTable(moduleData.repPerKill)
	
	local count = #moduleData.historyMobs
	
	for i = 1, count do
		local data = moduleData.historyMobs[i]
		
		for faction, amount in pairs(data.factions) do
			local total = moduleData.repPerKill[faction] or 0
		
			moduleData.repPerKill[faction] = total + amount
		end
	end	

	for faction, total in pairs(moduleData.repPerKill) do
		moduleData.repPerKill[faction] = total / count
	end	
	
	moduleData.taintedMobs = false
end

function ReputationHistory:Update()
	for index, id in Factions:IterateAllFactions() do
		local _, _, _, _, _, currentRep, _, _, isHeader, _, hasRep, _, _, id  = Factions:GetFactionInfo(id)
		
		if id and (not isHeader or hasRep) then		
			if not moduleData.factions[id] then
				self:InitFaction(id)
			end
			
			local data = moduleData.factions[id]

			if data then
				local totalRep = currentRep - data.startRep
				if totalRep ~= data.totalRep then					
					local bucket = self:GetWriteBucket(id)

					local delta = totalRep - data.totalRep
					
					bucket.reputation = bucket.reputation + delta
					data.totalRep     = totalRep
					
					data.tainted = true
				end
			end
		end
	end
	
	-- restore folding state of factions in ui list
	Factions:RestoreUI()
end

-- mob based rep
function ReputationHistory:AddKill()
	-- track mob kills
	local mobdata = NS:NewTable()
	
	mobdata.time = time()
	mobdata.factions = NS:NewTable()

	tinsert(moduleData.historyMobs, mobdata)
	
	-- remove oldest entry if we exceed history size
	if #moduleData.historyMobs > MAX_HISTORY then
		NS:ReleaseTable(moduleData.historyMobs[1].factions)
		NS:ReleaseTable(moduleData.historyMobs[1])
		tremove(moduleData.historyMobs, 1)
	end

	moduleData.taintedMobs = true	
end

function ReputationHistory:TryRegisterKillReputation(faction, amount)
	if not faction or type(amount) ~= "number" or amount < 0 or #moduleData.historyMobs == 0 then
		return
	end
	
	for i = 1, #moduleData.historyMobs do
		local data = moduleData.historyMobs[i]
		
		if data.time == time() and not data.factions[faction] then
			data.factions[faction] = amount
			
			moduleData.taintedMobs = true
			
			return
		end
	end	
end

-- params
function ReputationHistory:GetWeight()
	return moduleData.weight
end

function ReputationHistory:SetWeight(weight)
	if weight < 0 then
		weight = 0
	elseif weight > 1 then
		weight = 1
	end

	if weight == moduleData.weight then
		return
	end
	
	moduleData.weight = weight
	
	self:Taint()
end

function ReputationHistory:GetTimeFrame()
	return moduleData.timeframe
end

function ReputationHistory:SetTimeFrame(timeframe)
	if timeframe < 0 then
		timeframe = 0
	end

	if timeframe == moduleData.timeframe then
		return
	end
	
	moduleData.timeframe = timeframe
	
	self:Taint()
end

-- helper
function ReputationHistory:Taint()
	for faction, data in pairs(moduleData.factions) do
		data.tainted = true
	end
	
	return false
end

function ReputationHistory:IsTainted()
	for faction, data in pairs(moduleData.factions) do
		if moduleData.factions[faction].tainted then
			return true
		end
	end
	
	return false
end

function ReputationHistory:IsTainted(faction)
	return moduleData.factions[faction] and moduleData.factions[faction].tainted or false
end

function ReputationHistory:HasNoFactions()
	return next(moduleData.factions) == nil
end

function ReputationHistory:GetFactionCount()
	local count = 0
  
	for _ in pairs(moduleData.factions) do 
		count = count + 1 
	end
  
	return count
end

function ReputationHistory:GuildFactionAvailable()
	if not IsInGuild() then
		return false
	end

	local available = true
	
	for index, id in Factions:IterateAllFactions() do
		local name, _, _, _, _, _, _, _, isHeader, _, hasRep = Factions:GetFactionInfo(id)
		
		if not isHeader and hasRep and name == CHAT_MSG_GUILD then
			available = false
		end
	end
	
	-- restore folding state of factions in ui list
	Factions:RestoreUI()
	
	return available
end

-- test
function ReputationHistory:Debug(msg)
	Addon:Debug("(ReputationHistory) " .. tostring(msg))
end
