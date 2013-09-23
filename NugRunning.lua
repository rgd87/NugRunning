-- Last code revision was in 4.0 beta, since then a lot of new features and workarounds has been made,
-- I made them to be temporary but they remained and became important even if blizzard will fix combat log bug.
-- So it's all crap now and needs a rewrite.
local _, helpers = ...

NugRunning = CreateFrame("Frame","NugRunning")

NugRunning:SetScript("OnEvent", function(self, event, ...)
    return self[event](self, event, ...)
end)

local NRunDB
local config = NugRunningConfig
local nameplates
local MAX_TIMERS = 20
local check_event_timers
local playerGUID
local alltimers = {}
local active = {}
local free = {}
local Scouter
setmetatable(active,{ __newindex = function(t,k,v)
    rawset(free,k,nil)
    rawset(t,k,v)
end})
setmetatable(free,{ __newindex = function(t,k,v)
    if k.opts then
        if k.opts.with_cooldown then 
            local cd_opts = k.opts.with_cooldown
            config.cooldowns[cd_opts.id] = cd_opts
            NugRunning:SPELL_UPDATE_COOLDOWN()
        else
            if k.opts.ghost and not k.isGhost then return k:BecomeGhost() end
            if k.isGhost and not k.expiredGhost then return end
        end
    end
    k:Hide()
    rawset(active,k,nil)
    rawset(t,k,v)
    NugRunning:ArrangeTimers()
end})
local leaveGhost = true

local gettimer = function(self,spellID,dstGUID,timerType)
    if type(spellID) == "number" then
        for timer in pairs(self) do 
            if  timer.spellID == spellID and
                timer.dstGUID == dstGUID and
                timer.timerType == timerType then
                return timer;
            end
        end
    else -- comparing by opts table, instead of
        for timer in pairs(self) do 
            if  timer.opts == spellID and
                timer.dstGUID == dstGUID and
                timer.timerType == timerType then
                return timer;
            end
        end
    end
end
local IsPlayerSpell = IsPlayerSpell
local GetSpellInfo_ = GetSpellInfo
local GetSpellInfo = setmetatable({},{
    __call = function(self, id)
    local info = self[id]
    if not info then
        info = { GetSpellInfo_(id) }
        self[id] = info
    end
    return unpack(info)
    end
})

local GetSpellCooldown = GetSpellCooldown
local GetSpellCharges = GetSpellCharges
local GetSpecialization = GetSpecialization
local bit_band = bit.band
local UnitAura = UnitAura
local UnitGUID = UnitGUID
local table_wipe = table.wipe
local COMBATLOG_OBJECT_AFFILIATION_MASK = COMBATLOG_OBJECT_AFFILIATION_MASK
local AFFILIATION_MINE = COMBATLOG_OBJECT_AFFILIATION_MINE
local AFFILIATION_PARTY_OR_RAID = COMBATLOG_OBJECT_AFFILIATION_RAID + COMBATLOG_OBJECT_AFFILIATION_PARTY
local AFFILIATION_OUTSIDER = COMBATLOG_OBJECT_AFFILIATION_OUTSIDER


local ssSnapshot = {}
local ssPending = {}
local ssPendingTarget
local ssPendingTimestamp = GetTime()

local lastCastSpellID

NugRunning.active = active
NugRunning.free = free
NugRunning.timers = alltimers
NugRunning.gettimer = gettimer
NugRunning.helpers = helpers


local defaults = {
    anchors = {
        main = {
            point = "CENTER",
            parent = "UIParent",
            to = "CENTER",
            x = 0,
            y = 0,
        },
        secondary = {
            point = "CENTER",
            parent = "UIParent",
            to = "CENTER",
            x = -200,
            y = 0,
        },
    },
    growth = "up",
    width = 150,
    height = 20,
    cooldownsEnabled = true,
    missesEnabled = true,
    targetTextEnabled = false,
    spellTextEnabled = true,
    shortTextEnabled = true,
    swapTarget = true,
    localNames = false,
    totems = true,
    leaveGhost = false,
    nameplates = false,
    dotpower = true,
    dotticks = true,
}

local function SetupDefaults(t, defaults)
    for k,v in pairs(defaults) do
        if type(v) == "table" then
            if t[k] == nil then
                t[k] = CopyTable(v)
            else
                SetupDefaults(t[k], v)
            end
        else
            if t[k] == nil then t[k] = v end
        end
    end
end
local function RemoveDefaults(t, defaults)
    for k, v in pairs(defaults) do
        if type(t[k]) == 'table' and type(v) == 'table' then
            RemoveDefaults(t[k], v)
            if next(t[k]) == nil then
                t[k] = nil
            end
        elseif t[k] == v then
            t[k] = nil
        end
    end
    return t
end


NugRunning:RegisterEvent("PLAYER_LOGIN")
NugRunning:RegisterEvent("PLAYER_LOGOUT")
function NugRunning.PLAYER_LOGIN(self,event,arg1)
    NRunDB_Global = NRunDB_Global or {}
    NRunDB_Char = NRunDB_Char or {}
    NRunDB_Global.charspec = NRunDB_Global.charspec or {}
    user = UnitName("player").."@"..GetRealmName()
    if NRunDB_Global.charspec[user] then
        NRunDB = NRunDB_Char
    else
        NRunDB = NRunDB_Global
    end
    NugRunning.db = NRunDB

    --migration
    if not NRunDB.anchors then
        NRunDB.anchors = {}
        if NRunDB.anchor then
            NRunDB.anchors.main = NRunDB.anchor
            NRunDB.anchor = nil
        end
        if NRunDB.anchor2 then
            NRunDB.anchors.secondary = NRunDB.anchor2
            NRunDB.anchor2 = nil
        end
    end
    SetupDefaults(NRunDB, defaults)

    leaveGhost = NRunDB.leaveGhost

    NugRunning:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        
    NugRunning:RegisterEvent("PLAYER_TALENT_UPDATE") -- changing between dualspec
    NugRunning:RegisterEvent("GLYPH_UPDATED")
    NugRunning:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
    NugRunning.ACTIVE_TALENT_GROUP_CHANGED = NugRunning.ReInitSpells
    NugRunning.GLYPH_UPDATED = NugRunning.ReInitSpells
    NugRunning.PLAYER_TALENT_UPDATE = NugRunning.ReInitSpells
    
    NugRunning:RegisterEvent("UNIT_COMBO_POINTS")
    
    NugRunning:RegisterEvent("PLAYER_TARGET_CHANGED")
    -- NugRunning:RegisterEvent("UNIT_AURA")
        
    if NRunDB.cooldownsEnabled then
        NugRunning:RegisterEvent("SPELL_UPDATE_COOLDOWN")
    end

    if NRunDB.nameplates then
        local found
        for _, opts in pairs(config) do
            if opts.nameplates then found = true; break end
        end
        if found then
            NugRunning:DoNameplates()
            nameplates = NugRunningNameplates
        end
    end
    
    --NugRunning:RegisterEvent("SPELL_UPDATE_USABLE")
    NugRunning:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW")
    NugRunning:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_HIDE")


    if next(NugRunningConfig.event_timers) then check_event_timers = true end
    playerGUID = UnitGUID("player")

    NugRunning.anchors = {}
    for name, opts in pairs(NugRunningConfig.anchors) do
        local anchor = NugRunning:CreateAnchor(name, opts)
        NugRunning.anchors[name] = anchor
    end

    NugRunning:SetupArrange()

    for i=1,MAX_TIMERS do
        local timer = NugRunning:CreateTimer()
        free[timer] = true
    end

    local _,class = UnitClass("player")
    if (class == "WARLOCK" or class == "PRIEST") and NRunDB.dotpower then
        Scouter = LibStub("LibScouter-1.0")
        Scouter.RegisterCallback(NugRunning, "POWER_LEVEL_CHANGED", NugRunning.POWER_LEVEL_CHANGED)
    end
        
    SLASH_NUGRUNNING1= "/nugrunning"
    SLASH_NUGRUNNING2= "/nrun"
    SlashCmdList["NUGRUNNING"] = NugRunning.SlashCmd
    
    if NRunDB.totems and NugRunning.InitTotems then NugRunning:InitTotems() end
end

function NugRunning.PLAYER_LOGOUT(self, event)
    RemoveDefaults(NRunDB, defaults)
end

--------------------
-- CLEU dispatcher
--------------------
function NugRunning.COMBAT_LOG_EVENT_UNFILTERED( self, event, timestamp, eventType, hideCaster,
                srcGUID, srcName, srcFlags, srcFlags2,
                dstGUID, dstName, dstFlags, dstFlags2,
                spellID, spellName, spellSchool, auraType, amount)

    if NugRunningConfig[spellID] then
        local affiliationStatus = (bit_band(srcFlags, AFFILIATION_MINE) == AFFILIATION_MINE)
        local opts = NugRunningConfig[spellID]
        if not affiliationStatus and opts.affiliation then
            affiliationStatus = (bit_band(srcFlags, COMBATLOG_OBJECT_AFFILIATION_MASK) <= opts.affiliation)
        end
        if opts.target and dstGUID ~= UnitGUID(opts.target) then return end
        if affiliationStatus then
            if eventType == "SPELL_AURA_REFRESH" then
                return self:RefreshTimer(srcGUID, dstGUID, dstName, dstFlags, spellID, spellName, opts, auraType, nil, amount)
            elseif eventType == "SPELL_AURA_APPLIED_DOSE" then
                return self:RefreshTimer(srcGUID, dstGUID, dstName, dstFlags, spellID, spellName, opts, auraType, nil, amount, opts._ignore_applied_dose)
            elseif eventType == "SPELL_AURA_APPLIED" then
                return self:ActivateTimer(srcGUID, dstGUID, dstName, dstFlags, spellID, spellName, opts, auraType)
            elseif eventType == "SPELL_AURA_REMOVED" then
                return self:DeactivateTimer(srcGUID, dstGUID, spellID, spellName, opts, auraType)
            elseif eventType == "SPELL_AURA_REMOVED_DOSE" then
                return self:RemoveDose(srcGUID, dstGUID, spellID, spellName, auraType, amount)
            elseif eventType == "SPELL_MISSED" then
                if NRunDB.missesEnabled then
                    return self:ActivateTimer(srcGUID, dstGUID, dstName, dstFlags, spellID, spellName, opts, "MISSED", auraType) -- auraType = missType in this case
                end
            elseif eventType == "SPELL_CAST_SUCCESS" then
                lastCastSpellID = spellID
            end
        end
    end

    if check_event_timers then
        if NugRunningConfig.event_timers[eventType] then
            local affiliationStatus = (bit_band(srcFlags, AFFILIATION_MINE) == AFFILIATION_MINE)
            local evs = NugRunningConfig.event_timers[eventType]
            for i, opts in ipairs(evs) do
                if affiliationStatus or (opts.affiliation and bit_band(srcFlags, COMBATLOG_OBJECT_AFFILIATION_MASK) <= opts.affiliation ) then
                    if spellID == opts.spellID then
                        if opts.action then
                            opts.action(active, srcGUID, dstGUID, spellID)
                        else
                            return self:ActivateTimer(playerGUID, playerGUID, dstName, nil, spellID, spellName, opts, "EVENT", opts.duration)
                        end
                    end
                end
            end
        end
    end

    if eventType == "UNIT_DIED" or eventType == "UNIT_DESTROYED" then
        self:DeactivateTimersOnDeath(dstGUID)
    end
end

---------------------------------
-- ACTIVATION OVERLAY & USABLE
---------------------------------

--function NugRunning.SPELL_UPDATE_USABLE(self, event)
--end
function NugRunning.SPELL_ACTIVATION_OVERLAY_GLOW_SHOW(self,event, spellID)
    if NugRunningConfig.activations[spellID] then
        local opts = NugRunningConfig.activations[spellID]
        if not opts.for_cd then
            if opts.showid then spellID = opts.showid end
            self:ActivateTimer(UnitGUID("player"),UnitGUID("player"), UnitName("player"), nil, spellID, opts.localname, opts, "ACTIVATION", opts.duration)
        else
            local timer = gettimer(active,spellID,UnitGUID("player"),"COOLDOWN")
            if timer then timer:SetAlpha(1) end
        end
    end
end
function NugRunning.SPELL_ACTIVATION_OVERLAY_GLOW_HIDE(self,event, spellID)
    if NugRunningConfig.activations[spellID] then
        local opts = NugRunningConfig.activations[spellID]
        if not opts.for_cd then
            if opts.showid then spellID = opts.showid end
            self:DeactivateTimer(UnitGUID("player"),UnitGUID("player"), spellID, nil, opts, "ACTIVATION")
        else
            local timer = gettimer(active,spellID,UnitGUID("player"),"COOLDOWN")
            if timer then timer:SetAlpha(0.5) end
        end
    end
end

---------------------------
--   COOLDOWNS

local function GetSpellCooldownCharges(spellID)
    local startTime, duration, enabled = GetSpellCooldown(spellID)
    local charges, maxCharges, chargeStart, chargeDuration = GetSpellCharges(spellID)
    if charges and charges ~= maxCharges then
        startTime = chargeStart
        duration = chargeDuration
    end
    return startTime, duration, enabled, charges, maxCharges
end

function NugRunning.SPELL_UPDATE_COOLDOWN(self,event)
    for spellID,opts in pairs(NugRunningConfig.cooldowns) do
        if not opts.check_known or IsPlayerSpell(spellID) then -- Eh, no continue in Lua

        local startTime, duration, enabled, charges, maxCharges = GetSpellCooldownCharges(spellID) 

        local timer
        if opts.timer and (opts.timer.spellID == spellID) then
            timer = opts.timer
        elseif opts.replaces then
            timer = gettimer(active, opts.replaces, UnitGUID("player"), "COOLDOWN")
        end
        if duration then
            if duration <= 1.5 then
                if timer and (active[timer] and opts.resetable) then
                    local oldcdrem = timer.endTime - GetTime()
                    if oldcdrem > duration or oldcdrem < 0 then
                        if not timer.isGhost then
                            free[timer] = true
                            if timer.isGhost and not timer.shine:IsPlaying() then timer.shine:Play() end
                            opts.timer = nil
                        end
                    end
                end
            else
                    if not active[timer] or timer.isGhost then
                        local mdur = opts.minduration
                        if not mdur or duration > mdur then
                            timer = self:ActivateTimer(UnitGUID("player"),UnitGUID("player"), UnitName("player"), nil, spellID, opts.localname, opts, "COOLDOWN", duration + startTime - GetTime())
                        end
                        if timer then
                            timer.cd_startTime = startTime
                            timer.cd_duration = duration
                            opts.timer = timer
                        end
                    else
                        -- print("1", spellID, startTime, duration)
                        if timer.cd_startTime ~= startTime or timer.cd_duration ~= duration then
                            timer.cd_startTime = startTime
                            timer.fixedoffset = timer.opts.fixedlen and duration - timer.opts.fixedlen or 0
                            timer:SetTime(startTime +  timer.fixedoffset, startTime + duration)
                        -- elseif timer.cd_duration ~= duration then
                        end

                        if opts.replaces then
                            local name,_, texture = GetSpellInfo(spellID)
                            timer:SetIcon(texture)
                            timer:SetName(self:MakeName(opts, name, timer.dstName) )
                            if opts.color then timer:SetColor(unpack(opts.color)) end
                        end
                        opts.timer = timer
                    end
                    if charges and timer then 
                        opts.timer:SetCount(maxCharges-charges)
                    end
            end
        end

        end
    end
end

local helpful = "HELPFUL"
local harmful = "HARMFUL"
function NugRunning.ActivateTimer(self,srcGUID,dstGUID,dstName,dstFlags, spellID, spellName, opts, timerType, override, amount, from_unitaura)  -- duration override
    if timerType == "MISSED" then
        if override == "IMMUNE" then return end
        opts = { duration = 3, color = NugRunningConfig.colors.MISSED, scale = .8, priority = opts.priority or 100501, shine = true }
    end

    if opts.specmask then
        local spec = GetSpecialization()
        if spec then
            spec = 0xF*math.pow(0x10, spec-1)
            if bit_band(opts.specmask, spec) ~= spec then return end
        end
    end
    local multiTargetGUID
    if opts.multiTarget then multiTargetGUID = dstGUID; dstGUID = nil; end

    if opts.with_cooldown then
        local cd_opts = opts.with_cooldown
        config.cooldowns[cd_opts.id] = nil
        for timer in pairs(active) do
            if timer.opts == cd_opts then
                free[timer] = true
                timer:Hide()
            end
        end
        cd_opts.timer = nil
    end

    -- if timer.opts.idgroup then
    --     spellID = timer.opts.idgroup[1]
    -- end
    local timer = gettimer(active, opts,dstGUID,timerType) -- finding timer by opts table id
    if timer then
        -- spellID = timer.spellID -- swapping current id for existing timer id in case they're different
                                -- refresh will be searching by spellID again
        if multiTargetGUID then timer.targets[multiTargetGUID] = true end
        return self:RefreshTimer(srcGUID, dstGUID or multiTargetGUID, dstName, dstFlags, spellID, spellName, opts, timerType, override)
    end
    
    timer = next(free)
    if not timer then return end
    active[timer] = true
    if timer.isGhost then timer:SetScript("OnUpdate",NugRunning.TimerFunc) end

    if opts.init and not opts.init_done then
        opts:init()
        opts.init_done = true
    end
    if not from_unitaura then
        if opts.tick and NRunDB.dotticks then
            timer.tickPeriod = opts.tick > 0 and (opts.tick/(1+(UnitSpellHaste("player")/100))) or math.abs(opts.tick)
            timer.mark.fullticks = nil
        else
            timer.tickPeriod = nil
        end

        local plevel = self:GetPowerLevel()
        if ssPendingTimestamp > GetTime() - 0.3 and ssPendingTarget == dstGUID and ssPending[spellID] then
            timer.powerLevel = ssPending[spellID].powerLevel
            timer.tickPeriod = ssPending[spellID].tickPeriod
            ssPending[spellID] = nil
        else
            timer.powerLevel = plevel
        end
        
        self:UpdateTimerPower(timer, plevel)
    end
    timer.srcGUID = srcGUID
    timer.dstGUID = dstGUID
    timer.dstName = dstName
    if multiTargetGUID then timer.targets[multiTargetGUID] = true end
    timer.spellID = spellID
    timer.timerType = timerType
    timer:SetIcon(select(3,GetSpellInfo(opts.showid or spellID)))
    timer.opts = opts
    timer.onupdate = opts.onupdate
        
    local time
    if timerType == "MISSED" then
        time = opts.duration
    elseif override then time = override
    else
        time = NugRunning.SetDefaultDuration(dstFlags, opts, timer)
        -- print( "DEFAULT TIME", spellName, time, timerType)
        if timerType == "BUFF" or timerType == "DEBUFF" then
            local _guid = multiTargetGUID or dstGUID
            NugRunning.QueueAura(spellID, _guid, timerType, timer)
        end
    end
    if timerType == "BUFF"
        then timer.filter = "HELPFUL"
        else timer.filter = "HARMFUL"
    end

    if timer.VScale then
        local scale = opts.scale
        if scale then
            timer:VScale(scale)
        else
            timer:VScale(1)
        end
    end

    timer.priority = opts.priority or 0
    local now = GetTime()
    timer.fixedoffset = opts.fixedlen and time - opts.fixedlen or 0

    if not opts.color then
        if timerType == "DEBUFF" then opts.color = NugRunningConfig.colors.DEFAULT_DEBUFF
        else opts.color = NugRunningConfig.colors.DEFAULT_BUFF end
    end
    timer:SetColor(unpack(opts.color))

    amount = amount or 1
    if opts.charged then
        timer:ToInfinite()
        timer:SetMinMaxCharge(0,opts.maxcharge)
        timer:SetCharge(amount)
        timer:UpdateMark()
    elseif opts.timeless then
        timer:ToInfinite()
        timer:UpdateMark()
        timer:SetCount(amount)
    else
        timer:SetTime(now + timer.fixedoffset, now + time)
        timer:SetCount(amount)
    end
    timer.count = amount
    
    if opts.textfunc and type(opts.textfunc) == "function" then
        nameText = opts.textfunc(timer)
    elseif timerType == "MISSED" then
        nameText = override:sub(1,1)..override:sub(2):lower()
    else
        nameText = NugRunning:MakeName(opts, spellName, dstName)
    end
    if timer.SetName then timer:SetName(nameText) end

    if timer.glow:IsPlaying() then timer.glow:Stop() end
    timer:Show()
    if not timer.animIn:IsPlaying() and not from_unitaura then timer.animIn:Play() end
    timer.shine.tex:SetAlpha(0)
    if opts.shine and not timer.shine:IsPlaying() then timer.shine:Play() end
    
    self:ArrangeTimers()
    return timer
end

function NugRunning.RefreshTimer(self,srcGUID,dstGUID,dstName,dstFlags, spellID, spellName, opts, timerType, override, amount, noshine)
    local multiTargetGUID
    if opts.multiTarget then multiTargetGUID = dstGUID; dstGUID = nil; end

    local timer = gettimer(active, opts or spellID,dstGUID,timerType)
    if not timer then
        return self:ActivateTimer(srcGUID, dstGUID or multiTargetGUID, dstName, dstFlags, spellID, spellName, opts, timerType)
    end
    if timerType == "COOLDOWN" and not timer.isGhost then return timer end
    if timer.isGhost then
        timer:SetScript("OnUpdate",NugRunning.TimerFunc)
        timer.isGhost = nil
        if not opts.color then
        if timerType == "DEBUFF" then opts.color = { 0.8, 0.1, 0.7}
        else opts.color = { 1, 0.4, 0.2} end
        end
        timer:SetColor(unpack(opts.color))
    end

    local time
    if override then time = override
    else
        if dstGUID then
            time = NugRunning.SetDefaultDuration(dstFlags, opts, timer)
        end
        if timerType == "BUFF" or timerType == "DEBUFF" then
            if not dstGUID then
                if timer.queued and GetTime() < timer.queued + 0.9 then
                    return
                end
            end
            local _guid = dstGUID or multiTargetGUID
            timer.queued = NugRunning.QueueAura(spellID, _guid, timerType, timer)
        end
    end
    if amount and opts.charged then
        timer:SetCharge(amount)
    elseif not opts.timeless then
        local now = GetTime()
        timer.fixedoffset = opts.fixedlen and time - opts.fixedlen or 0
        if time then timer:SetTime(now + timer.fixedoffset, now + time) end
        timer:SetCount(amount)
    end
    timer.count = amount

    if not noshine then
        if opts.tick and NRunDB.dotticks then
            timer.tickPeriod = opts.tick > 0 and (opts.tick/(1+(UnitSpellHaste("player")/100))) or math.abs(opts.tick)
            timer.mark.fullticks = nil
        else
            timer.tickPeriod = nil
        end

        local plevel = self:GetPowerLevel()
        if ssPendingTimestamp > GetTime() - 0.3 and ssPendingTarget == dstGUID and ssPending[spellID] then
            timer.powerLevel = ssPending[spellID].powerLevel
            timer.tickPeriod = ssPending[spellID].tickPeriod
            ssPending[spellID] = nil
        else
            timer.powerLevel = plevel
        end
        self:UpdateTimerPower(timer, plevel)
    end

    timer:UpdateMark()

    if timer.glow:IsPlaying() then timer.glow:Stop() end
    if not noshine and opts.shinerefresh and not timer.shine:IsPlaying() then timer.shine:Play() end

    self:ArrangeTimers()
    return timer
end

function NugRunning.RemoveDose(self,srcGUID,dstGUID, spellID, spellName, timerType, amount)
    for timer in pairs(active) do
        if  timer.spellID == spellID
        and timer.dstGUID == dstGUID
        and timer.timerType == timerType
        and timer.srcGUID == srcGUID
        then
            if timer.opts.charged then
                timer:SetCharge(amount)
            else
                timer:SetCount(amount)
            end
            timer.count = amount
        end
    end
end

function NugRunning.DeactivateTimer(self,srcGUID,dstGUID, spellID, spellName, opts, timerType)
    local multiTargetGUID
    if opts.multiTarget then multiTargetGUID = dstGUID; dstGUID = nil; end
    for timer in pairs(active) do
        if  timer.spellID == spellID
        and timer.dstGUID == dstGUID
        and timer.timerType == timerType
        and timer.srcGUID == srcGUID
        then
            if multiTargetGUID then
                timer.targets[multiTargetGUID] = nil
                if next(timer.targets) then return end
            end
            free[timer] = true
            self:ArrangeTimers()
            return
        end
    end
end

local function free_noghost(timer)
    timer._elapsed = 2.5
    free[timer] = true
end
function NugRunning.DeactivateTimersOnDeath(self,dstGUID)
    for timer in pairs(active) do
        if NugRunningConfig[timer.spellID] then
        if not timer.dstGUID then -- clearing guid from multi target list just in case
            timer.targets[dstGUID] = nil
            if not next(timer.targets) then free_noghost(timer) end
        elseif timer.dstGUID == dstGUID then free_noghost(timer) end
        end
    end
end

function NugRunning.SetDefaultDuration(dstFlags, opts, timer )
    if opts.pvpduration
        and bit.band(dstFlags, COMBATLOG_FILTER_HOSTILE_PLAYERS) == COMBATLOG_FILTER_HOSTILE_PLAYERS
        then return opts.pvpduration
    end
    return ((type(opts.duration) == "function" and opts.duration(timer, opts)) or opts.duration)
end

function NugRunning.MakeName(self, opts, spellName, dstName)
    if NRunDB.targetTextEnabled and dstName ~= UnitName("player") then
        return dstName
    elseif NRunDB.spellTextEnabled then
        if NRunDB.localNames then
            return spellName
        elseif NRunDB.shortTextEnabled and opts.short then
            return opts.short
        else
            return opts.name
        end
    else
        return ""
    end
end

------------------------------
-- UNIT_AURA Duration Queue
------------------------------
-- to get precise duration value from unitID, if it's available, after combat log event
-- 5.0 changes: UnitAura now returns correct info at the time of CLEU SPELL_AURA_APPLIED event
--              So, spells are no longer queued.

local debuffUnits = {"target","mouseover","arena1","arena2","arena3","arena4","arena5","focus"}
local buffUnits = {"player","target","mouseover"}

do
    local queue = setmetatable({}, { __mode = "k" })
    NugRunning.queueFrame = CreateFrame("Frame")
    NugRunning.queueFrame:RegisterEvent("UNIT_AURA")
    NugRunning.queueFrame:SetScript('OnEvent', function(qframe, event, unit)
        if not queue[unit] then return end
        for spellID, timer in pairs(queue[unit]) do
            if NugRunning:GetUnitAuraData(unit, timer, spellID) then
                queue[unit][spellID] = nil
                timer._queued = nil
            elseif timer._queued and timer._queued + 0.4 < GetTime() then
                queue[unit][spellID] = nil
                timer._queued = nil
            end
        end

        if not next(queue[unit]) then queue[unit] = nil end
    end)
    function NugRunning.QueueAura(spellID, dstGUID, auraType, timer )
        local unit
        local auraUnits = (auraType == "DEBUFF") and debuffUnits or buffUnits
        for _,unitID in ipairs(auraUnits) do
            if dstGUID == UnitGUID(unitID) then
                unit = unitID
                break
            end
        end
        if not unit then return nil end

        if not NugRunning:GetUnitAuraData(unit, timer, spellID) then
            -- print("queueing", select(1,GetSpellInfo(spellID)))
            queue[unit] = queue[unit] or {}
            queue[unit][spellID] = timer
            timer._queued = GetTime()
        end
    end
end

function NugRunning.SetUnitAuraValues(self, timer, spellID, name, rank, icon, count, dispelType, duration, expirationTime, caster, isStealable, shouldConsolidate, aura_spellID, canApplyAura, isBossDebuff, value1, absorb, value3)
            if aura_spellID then
                if aura_spellID == spellID and NugRunning.UnitAffiliationCheck(caster, timer.opts.affiliation) then
                    if timer.opts.charged then
                        timer:SetCharge(count)
                    elseif not timer.opts.timeless then
                        timer.fixedoffset = timer.opts.fixedlen and duration - timer.opts.fixedlen or 0
                        local oldExpTime = timer.endTime
                        timer:SetTime(expirationTime - duration + timer.fixedoffset,expirationTime)
                        timer:SetCount(count)
                        if oldExpTime and oldExpTime + 3 < expirationTime then
                            -- if opts.tick and NRunDB.dotticks then
                            --     timer.tickPeriod = opts.tick > 0 and (opts.tick/(1+(UnitSpellHaste("player")/100))) or math.abs(opts.tick)
                            --     timer.mark.fullticks = nil
                            -- else
                            --     timer.tickPeriod = nil
                            -- end

                            local plevel = self:GetPowerLevel()
                            if ssPendingTimestamp > GetTime() - 0.3 and ssPendingTarget == dstGUID and ssPending[spellID] then
                                timer.powerLevel = ssPending[spellID].powerLevel
                                timer.tickPeriod = ssPending[spellID].tickPeriod
                                ssPending[spellID] = nil
                            else
                                timer.powerLevel = plevel
                            end

                            self:UpdateTimerPower(timer, plevel)
                        end
                    end
                    if type(absorb) == "number" and absorb > 0
                        then timer.absorb = absorb
                        else timer.absorb = nil
                    end

                    local name = GetSpellInfo(spellID)
                    -- print("GOT DATA!>>  ", name, duration)

                    return true
                    -- break
                end
            end
end

function NugRunning.GetUnitAuraData(self, unit, timer, spellID)
        for auraIndex=1,100 do
            -- local name, _,_, count, _, duration, expirationTime, caster, _,_, aura_spellID, _, _, _, absorb = UnitAura(unit, auraIndex, timer.filter)
            return NugRunning:SetUnitAuraValues(timer, spellID, UnitAura(unit, auraIndex, timer.filter))
        end
end

local math_floor = math.floor
local round = function(v) return math_floor(v+.1) end
-----------------------------------
-- Timer internal functionality
-----------------------------------
function NugRunning.TimerFunc(self,time)
    self._elapsed = self._elapsed + time
    if self._elapsed < 0.02 then return end
    self._elapsed = 0

    local opts = self.opts
    if opts.timeless or opts.charged then return end

    local endTime = self.endTime
    local beforeEnd = endTime - GetTime()

    if beforeEnd <= 0 then
        if not self.dontfree then
            table_wipe(self.targets)
            NugRunning.free[self] = true
            return
        end
    end

    self:Update(beforeEnd)

    local glowtime = opts.glowtime
    if glowtime and beforeEnd < glowtime then
        if self.glow and not self.glow:IsPlaying() then self.glow:Play() end
    end

    local rm = opts.recast_mark
    if rm and beforeEnd < rm and beforeEnd > rm-0.1 then
        self.mark.shine:Play()
    end

    local tickPeriod = self.tickPeriod
    if tickPeriod then
        local fullticks = round(beforeEnd/tickPeriod)
        if self.mark.fullticks ~= fullticks then
            local closestTickTime = fullticks*tickPeriod
            self:UpdateMark(closestTickTime)

            if self.mark.fullticks and self.opts.tickshine then
                self.mark.shine:Play()
            else
                self.mark.spark:CatchUp()
            end

            self.mark.fullticks = fullticks
        end
    end

    local timer_onupdate = self.onupdate
    if timer_onupdate then timer_onupdate(self) end
end

function NugRunning.GhostExpire(self)
    self:SetScript("OnUpdate", NugRunning.TimerFunc)
    self.expiredGhost = true
    free[self] = true
    self.isGhost = nil
end
function NugRunning.GhostFunc(self,time)
    self._elapsed = self._elapsed + time
    if self._elapsed < self.ghost_duration then return end
    if leaveGhost and (
            UnitAffectingCombat("player")
            and (self.dstGUID == UnitGUID("target") or self.dstGUID == playerGUID)
            and not self.ghost_noleave
            ) then return end

    NugRunning.GhostExpire(self)
end
local TimerBecomeGhost = function(self)
    self.expiredGhost = nil
    self.isGhost = true
    self:SetPowerStatus(nil)
    self:ToGhost()
    local opts = self.opts
    if type(opts.ghost) == "number" then
        self.ghost_duration = opts.ghost
        self.ghost_noleave = true
    else
        self.ghost_duration = 3
        self.ghost_noleave = nil
    end
    self._elapsed = 0
    self:SetScript("OnUpdate", NugRunning.GhostFunc)
end

--[======[local Timer_is_type = function(self, ...)
    local t = self.timerType
    local len = select("#", ...)
    if len == 0 then return true end
    for i=1,len do
    --for _,v in ipairs(...) do
        if t == select(i, ...) then return true end
    end
    return false
end

local Timer_matches = function(self, spellID, srcGUID, dstGUID, ...)
    return (
        (not spellID or self.spellID == spellID) and
        (not srcGUID or self.dstGUID == dstGUID) and
        (not srcGUID or self.srcGUID == srcGUID) --and
        --self:is_type(...)
    )
end]======]


function NugRunning.CreateTimer(self)
    local w = NugRunningConfig.width or NRunDB.width
    local h = NugRunningConfig.height or NRunDB.height

    local f = NugRunning.ConstructTimerBar(w,h)
    f._elapsed = 0
    f._width = w
    f._height = h 

    f.prototype = NugRunning[f.prototype or "TimerBar"]

    local mtFrameMethods = getmetatable(f).__index
    setmetatable(f, { __index = function(t,k)
                                    if t.prototype[k] then return t.prototype[k] end
                                    return mtFrameMethods[k]
                                end})

    f:SetScript("OnUpdate", NugRunning.TimerFunc)
    
    f.BecomeGhost = TimerBecomeGhost
    -- f.is_type = Timer_is_type
    -- f.matches = Timer_matches
    
    f.targets = {}
    f:Hide()
    table.insert(alltimers,f)
    
    return f
end



------------------------------
-- Timer sorting & anchoring
------------------------------
do
    local xOffset = 0
    local yOffset = 4
    local point
    local to
    local ySign
    local doswap
    local anchors
    function NugRunning.SetupArrange(self)
        point = ( NRunDB.growth == "down" and "TOPLEFT" ) or "BOTTOMLEFT"
        to = ( NRunDB.growth == "down" and "BOTTOMLEFT" ) or "TOPLEFT"
        ySign = ( NRunDB.growth == "down" and -1 ) or 1
        doswap = NRunDB.swapTarget
        anchors = NugRunning.anchors
    end
    -- local playerTimers = {}
    -- local targetTimers = {}
    -- local sorted = {}
    local groups = { player = {}, target = {} }
    local guid_groups = {}
    local sortfunc = function(a,b)
        if a.priority == b.priority then
            return a.endTime > b.endTime
        else
            return a.priority < b.priority
        end
    end

    function NugRunning.ArrangeTimers(self)
        for g,tbl in pairs(groups) do
            table_wipe(tbl)
        end
        table_wipe(guid_groups)
        local playerTimers = groups.player
        local targetTimers = groups.target

        local targetGUID = UnitGUID("target")
        for timer in pairs(active) do
            local custom_group = timer.opts.group
            if custom_group then
                groups[custom_group] = groups[custom_group] or {}
                table.insert(groups[custom_group],timer)
            elseif doswap and timer.dstGUID == targetGUID then table.insert(targetTimers,timer)
            elseif timer.dstGUID == playerGUID then table.insert(playerTimers,timer)
            elseif timer.dstGUID == nil then
                if timer.timerType == "BUFF" then
                    table.insert(playerTimers,timer)
                else
                    table.insert(targetTimers,timer)
                end
            else
                guid_groups[timer.dstGUID] = guid_groups[timer.dstGUID] or {}
                table.insert(guid_groups[timer.dstGUID],timer)
            end
        end
        
        for g,tbl in pairs(groups) do
            table.sort(tbl,sortfunc)
        end
        for g,tbl in pairs(guid_groups) do
            table.sort(tbl,sortfunc)
        end

        for name, anchor in pairs(NugRunning.anchors) do
            local aopts = anchor.opts
            local prev
            local gap = 0
            for _, gopts in pairs(aopts) do
                local gname = gopts.name
                local alpha = gopts.alpha
                if gname == "offtargets" then
                    for guid, group_timers in pairs(guid_groups) do
                        for i,timer in ipairs(group_timers) do
                            local noswap_alpha = guid == targetGUID and 1 or alpha
                            timer:SetAlpha(noswap_alpha)
                            timer:SetPoint(point, prev or anchor, prev and to  or "TOPRIGHT", xOffset, (yOffset+gap)*ySign)
                            if timer.onupdate then timer:onupdate() end
                            prev = timer
                            gap = 0
                        end
                        gap = gopts.gap
                    end
                    break -- offtargets should always be the last group for anchor
                else
                    local group_timers = groups[gname]
                    if group_timers then
                    for i,timer in ipairs(group_timers) do
                        timer:SetAlpha(alpha)
                        timer:SetPoint(point, prev or anchor, prev and to  or "TOPRIGHT", xOffset, (yOffset+gap)*ySign)
                        if timer.onupdate then timer:onupdate()end
                        prev = timer
                        gap = 0
                    end
                    end
                    gap = prev and gopts.gap or 0
                end
            end
        end

        if nameplates then
            nameplates:Update(targetTimers, guid_groups, doswap)
        end
    end
    function NugRunning.GetTimersByDstGUID(self, guid) -- for nameplate updates on target
        local guidTimers = {}
        for timer in pairs(active) do
            if timer.dstGUID == guid then table.insert(guidTimers, timer) end
        end
        table.sort(guidTimers,sortfunc)
        return guidTimers
    end
end

function NugRunning.PLAYER_TARGET_CHANGED(self)
    self:ArrangeTimers()
end

function NugRunning:GetPowerLevel()
    return Scouter and Scouter:GetPowerLevel(true) or 0
end
function NugRunning:UpdateTimerPower(timer, plevel)
    local treshold = 1500
    if timer.powerLevel > plevel+treshold then
        timer:SetPowerStatus("HIGH", timer.powerLevel-plevel)
    elseif timer.powerLevel+treshold < plevel then
        timer:SetPowerStatus("LOW", timer.powerLevel-plevel)
    else
        timer:SetPowerStatus(nil)
    end
end
function NugRunning.POWER_LEVEL_CHANGED(event, plevelfull)
    local plevel = NugRunning:GetPowerLevel() -- without damage multipliers
    for timer in pairs(active) do
        if timer.opts.showpower and timer.powerLevel and not timer.isGhost then
            -- timer:SetName(timer.powerLevel)
            NugRunning:UpdateTimerPower(timer, plevel)
        else
            timer:SetPowerStatus(nil)
        end
    end
end

function NugRunning.UNIT_COMBO_POINTS(self,event,unit)
    if unit ~= "player" then return end
    self.cpWas = self.cpNow or 0
    self.cpNow = GetComboPoints(unit);
end
function NugRunning.ReInitSpells(self,event,arg1)
    for id,opts in pairs(NugRunningConfig) do
        if type(opts) == "table" and opts.init_done then
            opts:init()
        end
    end
end

------------------------------------------
-- Console Commands and related functions
------------------------------------------
function NugRunning.ClearTimers(self, keepSelfBuffs)
    for timer in pairs(active) do
        if not (keepSelfBuffs and (timer.dstGUID == timer.srcGUID)) then
            free[timer] = true
        end
    end
    self:ArrangeTimers()
end

function NugRunning.Unlock(self)
    local prev
    for i,timer in ipairs(alltimers) do
        if i > 7 then break end
        local fakeopts = {}
        if not timer.opts then timer.opts = fakeopts; timer.startTime = GetTime(); timer.endTime = GetTime()+130-(i*10); end
        timer:SetIcon("Interface\\Icons\\inv_misc_questionmark")
        timer:SetName("Test timer")
        timer:SetColor(0.4, 0.4, 0.4)
        timer:Show()
        local point, to
        local xOffset, yOffset, ySign = 0, 4, 1
        if NRunDB.growth == "down" then
            point = "TOPLEFT"
            to = "BOTTOMLEFT"
            ySign = -1
        else
            point = "BOTTOMLEFT"
            to = "TOPLEFT"
            ySign = 1
        end
        timer:ClearAllPoints()
        timer:SetPoint(point,prev or NugRunning.anchors.main, prev and to or "TOPRIGHT", xOffset,yOffset * ySign)
        prev = timer
    end
    NugRunning.unlocked = true
end


local function capturesTable()
    
end


local ParseOpts = function(str)
    local t = {}
    local capture = function(k,v)
        t[k:lower()] = tonumber(v) or v
        return ""
    end
    str:gsub("(%w+)%s*=%s*%[%[(.-)%]%]", capture):gsub("(%w+)%s*=%s*(%S+)", capture)
    return t
end
function NugRunning.SlashCmd(msg)
    k,v = string.match(msg, "([%w%+%-%=]+) ?(.*)")
    if not k or k == "help" then print([[Usage:
      |cff00ff00/nrun lock|r
      |cff00ff00/nrun unlock|r
      |cff00ff00/nrun reset|r
      |cff00ff00/nrun clear|r
      |cff00ff00/nrun charopts|r : enable character specific settings
      |cff00ff00/nrun misses|r : toggle showing cooldowns
      |cff00ff00/nrun cooldowns|r : toggle showing cooldowns
      |cff00ff00/nrun targettext|r : toggle taget name text on bars
      |cff00ff00/nrun spelltext|r : toggle spell text on bars
      |cff00ff00/nrun shorttext|r : toggle using short names
      |cff00ff00/nrun swaptarget|r : static order of target debuffs
      |cff00ff00/nrun totems|r : static order of target debuffs
      |cff00ff00/nrun nameplates|r : turn on nameplates
      |cff00ff00/nrun dotticks|r : turn off dot ticks
      |cff00ff00/nrun dotpower|r : turn off dotpower feature
      |cff00ff00/nrun localnames|r: toggle localized spell names
      |cff00ff00/nrun leaveghost|r: don't hide target/player ghosts in combat
      |cff00ff00/nrun set|r width=120 height=20 fontscale=1.1 growth=up/down
      |cff00ff00/nrun setpos|r anchor=main point=CENTER parent=UIParent to=CENTER x=0 y=0]]
    )end
    if k == "unlock" then
        for name, anchor in pairs(NugRunning.anchors) do
            anchor:Show()
        end
        NugRunning:Unlock()
    end
    if k == "lock" then
        for name, anchor in pairs(NugRunning.anchors) do
            anchor:Hide()
        end
        for _,timer in ipairs(alltimers) do
            if not active[timer] then
                timer:Hide()
            end
        end
        NugRunning.unlocked = nil
    end
    if k == "listauras" then
        local unit = v
        local h = false
        for i=1, 100 do
            local name, _,_,_,_,duration,_,_,_,_, spellID = UnitAura(unit, i, "HELPFUL")
            if not name then break end
            if not h then print("BUFFS:"); h = true; end
            print(string.format("    %s (id: %d) Duration: %s", name, spellID, duration or "none" ))
        end
        h = false
        for i=1, 100 do
            local name, _,_,_,_,_,_,_,_,_, spellID = UnitAura(unit, i, "HARMFUL")
            if not name then break end
            if not h then print("DEBUFFS:"); h = true; end
            print(string.format("    %s (id: %d)", name, spellID))
        end

    end
    if k == "reset" then
        for name, anchor in pairs(NRunDB.anchors) do
            anchor.point = "CENTER"
            anchor.parent = "UIParent"
            anchor.to = "CENTER"
            anchor.x = 0
            anchor.y = 0
            local pos = anchor
            NugRunning.anchors[name]:SetPoint(pos.point, pos.parent, pos.to, pos.x, pos.y)
        end
    end
    if k == "clear" then
        NugRunning:ClearTimers(true)
    end
    if k == "charopts" then
        local user = UnitName("player").."@"..GetRealmName()
        if NRunDB_Global.charspec[user] then NRunDB_Global.charspec[user] = nil
        else NRunDB_Global.charspec[user] = true
        end
        print ("NRun: "..(NRunDB_Global.charspec[user] and "Enabled" or "Disabled").." character specific options for this toon. Will take effect after ui reload")
    end
    if k == "cooldowns" then
        if NRunDB.cooldownsEnabled then
            NugRunning:UnregisterEvent("SPELL_UPDATE_COOLDOWN")
        else
            NugRunning:RegisterEvent("SPELL_UPDATE_COOLDOWN")
        end
        NRunDB.cooldownsEnabled = not NRunDB.cooldownsEnabled
        print("NRun cooldowns "..(NRunDB.cooldownsEnabled and "enabled" or "disabled"))
    end
    if k == "targettext" then
        NRunDB.targetTextEnabled = not NRunDB.targetTextEnabled
        print("NRun target name text "..(NRunDB.targetTextEnabled and "enabled" or "disabled"))
    end
    if k == "spelltext" then
        NRunDB.spellTextEnabled = not NRunDB.spellTextEnabled
        print("NRun spell text "..(NRunDB.spellTextEnabled and "enabled" or "disabled"))
    end
    if k == "leaveghost" then
        NRunDB.leaveGhost = not NRunDB.leaveGhost
        leaveGhost = NRunDB.leaveGhost
        print("NRun leaveghost "..(NRunDB.leaveGhost and "enabled" or "disabled"))
    end
    if k == "shorttext" then
        NRunDB.shortTextEnabled = not NRunDB.shortTextEnabled
        print("NRun short spell text "..(NRunDB.shortTextEnabled and "enabled" or "disabled"))
    end
    if k == "localnames" then
        NRunDB.localNames = not NRunDB.localNames
        print("NRun localized spell names "..(NRunDB.localNames and "enabled" or "disabled"))
    end
    if k == "misses" then
        NRunDB.missesEnabled = not NRunDB.missesEnabled
        print("NRun miss timers "..(NRunDB.missesEnabled and "enabled" or "disabled"))
    end
    if k == "swaptarget" then
        NRunDB.swapTarget = not NRunDB.swapTarget
        NugRunning:SetupArrange()
        print("Target swapping turned "..(NRunDB.swapTarget and "on" or "off"))
    end
    if k == "totems" then
        NRunDB.totems = not NRunDB.totems
        print("Totems turned "..(NRunDB.swapTarget and "on" or "off")..". Will take effect after /reload")
    end
    if k == "nameplates" then
        NRunDB.nameplates = not NRunDB.nameplates
        print("Nameplates turned "..(NRunDB.nameplates and "on" or "off")..". Will take effect after /reload")
    end
    if k == "dotticks" then
        NRunDB.dotticks = not NRunDB.dotticks
        print("Dot ticks turned "..(NRunDB.dotticks and "on" or "off")..". Will take effect after /reload")
    end
    if k == "dotpower" then
        NRunDB.dotpower = not NRunDB.dotpower
        print("Dotpower turned "..(NRunDB.dotpower and "on" or "off")..". Will take effect after /reload")
    end
    if k == "set" then
        local p = ParseOpts(v)
        NRunDB.width = p["width"] or NRunDB.width
        NRunDB.height = p["height"] or NRunDB.height
        NRunDB.growth = p["growth"] or NRunDB.growth
        for i,timer in ipairs(alltimers) do
            timer:Resize(NRunDB.width, NRunDB.height)
            
        end
        if NugRunning.unlocked  then
            NugRunning:Unlock()
        elseif NRunDB.growth then
            for i,timer in ipairs(alltimers) do timer:ClearAllPoints() end
            NugRunning:SetupArrange()
            NugRunning:ArrangeTimers()
        end
    end
    if k == "setpos" then
        local p = ParseOpts(v)
        local aname = p["anchor"]
        local anchor = NRunDB.anchors[aname]
        if not anchor then print(string.format("Anchor '%s' doesn't exist", aname)) end
        anchor.point = p["point"] or anchor.point
        anchor.parent = p["parent"] or anchor.parent
        anchor.to = p["to"] or anchor.to
        anchor.x = p["x"] or anchor.x
        anchor.y = p["y"] or anchor.y
        local pos = anchor
        NugRunning.anchors[aname]:SetPoint(pos.point, pos.parent, pos.to, pos.x, pos.y)
    end
    if k == "debug" then
        if not NugRunning.debug then
            NugRunning.debug = CreateFrame("Frame")
            NugRunning.debug:SetScript("OnEvent",function( self, event, timestamp, eventType, hideCaster, 
                                                            srcGUID, srcName, srcFlags, srcFlags2,
                                                            dstGUID, dstName, dstFlags, dstFlags2,
                                                            spellID, spellName, spellSchool, auraType, amount)
                local isSrcPlayer = (bit_band(srcFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) == COMBATLOG_OBJECT_AFFILIATION_MINE)
                if isSrcPlayer then print (spellID, spellName, eventType, srcFlags, srcGUID,"->",dstGUID, amount) end
            end)
        end
        NugRunning.debug:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    end
    if k == "nodebug" then
        NugRunning.debug:UnregisterAllEvents()
    end
end

function NugRunning:CreateAnchor(name, opts)
    local f = CreateFrame("Frame",nil,UIParent)
    f:SetHeight(20)
    f:SetWidth(20)
    f:EnableMouse(true)
    f:SetMovable(true)
    f:Hide()
    
    local t = f:CreateTexture(nil,"BACKGROUND")
    t:SetTexture("Interface\\Buttons\\UI-RadioButton")
    t:SetTexCoord(0,0.25,0,1)
    t:SetAllPoints(f)
    
    t = f:CreateTexture(nil,"BACKGROUND")
    t:SetTexture("Interface\\Buttons\\UI-RadioButton")
    t:SetTexCoord(0.25,0.49,0,1)
    t:SetVertexColor(1, 0, 0)
    t:SetAllPoints(f)
    
    if not NRunDB.anchors[name] then
        NRunDB.anchors[name] = { point = "CENTER", parent ="UIParent", to = "CENTER", x = 0, y = 0}
    end
    f.db_tbl = NRunDB.anchors[name]
    f.opts = opts
    f:SetScript("OnMouseDown",function(self)
        self:StartMoving()
    end)
    f:SetScript("OnMouseUp",function(self)
            local opts = self.db_tbl
            self:StopMovingOrSizing();
            local point,_,to,x,y = self:GetPoint(1)
            opts.point = point
            opts.parent = "UIParent"
            opts.to = to
            opts.x = x
            opts.y = y
    end)

    local pos = f.db_tbl
    if not _G[pos.parent] then
        pos = { point = "CENTER", parent = "UIParent", to = "CENTER", x = 0, y = 0}
    end
    f:SetPoint(pos.point, pos.parent, pos.to, pos.x, pos.y)
    return f
end


do
    -- It updates timers with UnitAura data on UNIT_AURA and PLAYER_TARGET_CHANGED events
    -- At this point this piece already became very important,
    -- and also i can abandon hope that blizzard will fix combat log refresh someday.
    local filters = { harmful, helpful }
    local targetTimers = {}

    local h = CreateFrame("Frame")
    local hUnits = {
        ["player"] = 0,
        ["target"] = 1,
        ["focus"] = 2,
        ["mouseover"] = 2,
        ["boss1"] = 2,
        ["boss2"] = 2,
        ["arena1"] = 2,
        ["arena2"] = 2,
        ["arena3"] = 2,
        ["arena4"] = 2,
        ["arena5"] = 2,
    }

    local function UnitAffiliationCheck(unit, affiliation)
        if not affiliation then return unit == "player" end
        if unit == "player" then return true end
        if not unit then return affiliation == AFFILIATION_OUTSIDER end
        if affiliation == AFFILIATION_OUTSIDER then return true end
        if string.find(unit, "raid") then return affiliation == AFFILIATION_PARTY_OR_RAID end
        if string.find(unit, "party") then return affiliation == AFFILIATION_PARTY_OR_RAID end
    end
    NugRunning.UnitAffiliationCheck = UnitAffiliationCheck

    local last_taget_update = 0
    local function UpdateUnitAuras(unit)
            local up = hUnits[unit]
            if not up then return end
            local unitGUID = UnitGUID(unit)
            if up == 2 and UnitGUID("target") == unitGUID then return end

            local now = GetTime()
            -- if up == 1 then --throttle target updates
                -- if now - last_taget_update < 200 then return end
            -- end

            for timer in pairs(active) do 
                if  timer.dstGUID == unitGUID and
                    (timer.timerType == "BUFF" or timer.timerType == "DEBUFF")
                then
                        -- local name, _,_, count, _, duration, expirationTime, caster, _,_, aura_spellID = UnitAura(unit, GetSpellInfo(timer.spellID), nil, timer.filter)
                        NugRunning:SetUnitAuraValues(timer, timer.spellID, UnitAura(unit, GetSpellInfo(timer.spellID), nil, timer.filter))
                        -- if UnitAffiliationCheck(caster, timer.opts.affiliation) and timer.spellID == aura_spellID then
                            -- NugRunning:RefreshTimer(playerGUID,unitGUID,UnitName(unit),nil, timer.spellID, timer.spellName, timer.opts, timer.timerType, duration, count, true)
                            -- if (now + duration - expirationTime < 0.1) then
                                
                            -- else
                            -- if count and timer.count ~= count then
                                -- NugRunning:RemoveDose(playerGUID, unitGUID, aura_spellID, timer.spellName, timer.timerType, count)
                            -- end
                        -- end
                end
            end
    end
    NugRunning.UpdateUnitAuras = UpdateUnitAuras

    function NugRunning.OnAuraEvent(self, event, unit)
        if event == "UNIT_AURA" then
            return UpdateUnitAuras(unit)
        elseif event == "UPDATE_MOUSEOVER_UNIT" then
            return UnitExists("mouseover") and UpdateUnitAuras("mouseover")
        elseif event == "PLAYER_TARGET_CHANGED" then
            -- updating timers from target unit when possible
            local targetGUID = UnitGUID("target")
            if not targetGUID then return end
            table_wipe(targetTimers)
            for timer in pairs(active) do
                if timer.dstGUID == targetGUID then
                    -- if (timer.srcGUID == playerGUID or timer.opts.affiliation) then
                        table.insert(targetTimers, timer)
                    -- end
                else
                    if timer.opts.singleTarget then
                        free[timer] = true
                    end
                end
            end
            
            for _, filter in ipairs(filters) do
                for i=1,100 do
                    local name, _,_, count, _, duration, expirationTime, caster, _,_, aura_spellID = UnitAura("target", i, filter)
                    if not name then break end

                    local opts = config[aura_spellID]
                    if opts and UnitAffiliationCheck(caster, opts.affiliation) then
                        if opts.target and opts.target ~= "target" then return end
                        local found, timerType
                        -- searching in generated earlier table of player->target timers for matching spell
                        for _, timer in ipairs(targetTimers) do
                            if  timer.spellID == aura_spellID then
                                found = true
                                timerType = timer.timerType
                                break
                            end
                        end
                        local newtimer
                        if found then
                            newtimer = NugRunning:RefreshTimer(playerGUID, targetGUID, UnitName("target"), nil, aura_spellID, name, config[aura_spellID], timerType, duration, count, true)
                        else
                            timerType = filter == "HELPFUL" and "BUFF" or "DEBUFF"
                            newtimer = NugRunning:ActivateTimer(playerGUID, targetGUID, UnitName("target"), nil, aura_spellID, name, config[aura_spellID], timerType, duration, count, true)
                        end
                        if newtimer then newtimer:SetTime( expirationTime - duration + newtimer.fixedoffset, expirationTime) end
                    end
                end
            end
        end
    end
    h:SetScript("OnEvent", NugRunning.OnAuraEvent)
    h:RegisterEvent("UNIT_AURA")
    h:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
    h:RegisterEvent("PLAYER_TARGET_CHANGED")


    -- h._elapsed = 0
    -- h:SetScript("OnUpdate", function(self, time)
    --     self._elapsed = self._elapsed + time
    --     if self._elapsed < 0.2 then return end
    --     self._elapsed = 0

    --     NugRunning.OnAuraEvent(nil, "UNIT_AURA", "mouseover")
    -- end)
end


function NugRunning:SoulSwapStore(active, srcGUID, dstGUID, spellID )
    table_wipe(ssSnapshot)
    for timer in pairs(active) do
        if timer.dstGUID == dstGUID then
            if timer.opts.showpower and timer.powerLevel and not timer.isGhost then
                ssSnapshot[timer.spellID] = {}
                ssSnapshot[timer.spellID].powerLevel = timer.powerLevel
                ssSnapshot[timer.spellID].tickPeriod= timer.tickPeriod
            end
        end
    end
end

function NugRunning:SoulSwapUsed(active, srcGUID, dstGUID, spellID )
    for spellID, tbl in pairs(ssSnapshot) do
        ssPending[spellID] = tbl
    end
    table_wipe(ssSnapshot)
    ssPendingTimestamp = GetTime()
    ssPendingTarget = dstGUID
end

