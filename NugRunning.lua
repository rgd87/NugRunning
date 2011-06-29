NugRunning = CreateFrame("Frame","NugRunning")

NugRunning:SetScript("OnEvent", function(self, event, ...)
	self[event](self, event, ...)
end)

NRunDB = {}
local config = NugRunningConfig
local MAX_TIMERS = 15
local alltimers = {}
local active = {}
local free = {}
setmetatable(active,{ __newindex = function(t,k,v)
    rawset(free,k,nil)
    rawset(t,k,v)
end})
setmetatable(free,{ __newindex = function(t,k,v)
    if k.opts and k.opts.ghost and not k.isGhost then return k:BecomeGhost() end
    if k.isGhost and not k.expiredGhost then return end
    k:Hide()
    rawset(active,k,nil)
    rawset(t,k,v)
end})
local gettimer = function(self,spellID,dstGUID,timerType)
    for timer in pairs(self) do 
        if  timer.spellID == spellID and
            timer.dstGUID == dstGUID and
            timer.timerType == timerType then
            return timer;
        end
    end
end

local bit_band = bit.band
local UnitAura = UnitAura

NugRunning.active = active
NugRunning.free = free
NugRunning.timers = alltimers

NugRunning:RegisterEvent("PLAYER_LOGIN")
function NugRunning.PLAYER_LOGIN(self,event,arg1)
    
    NRunDB_Global = NRunDB_Global or {}
    NRunDB_Char = NRunDB_Char or {}
    NRunDB_Global.charspec = NRunDB_Global.charspec or {}
    user = UnitName("player").."@"..GetRealmName()
    if NRunDB_Global.charspec[user] then
        setmetatable(NRunDB,{__index = function(t,k) return NRunDB_Char[k] end, __newindex = function(t,k,v) rawset(NRunDB_Char,k,v) end})
    else
        setmetatable(NRunDB,{__index = function(t,k) return NRunDB_Global[k] end, __newindex = function(t,k,v) rawset(NRunDB_Global,k,v) end})
    end
    NRunDB.anchor = NRunDB.anchor or {}
    NRunDB.anchor.point = NRunDB.anchor.point or "CENTER"
    NRunDB.anchor.parent = NRunDB.anchor.parent or "UIParent"
    NRunDB.anchor.to = NRunDB.anchor.to or "CENTER"
    NRunDB.anchor.x = NRunDB.anchor.x or 0
    NRunDB.anchor.y = NRunDB.anchor.y or 0
    NRunDB.growth = NRunDB.growth or "up"
    NRunDB.width = NRunDB.width or 150
    NRunDB.height = NRunDB.height or 20
    NRunDB.fontscale = NRunDB.fontscale or 1
    NRunDB.nonTargetOpacity = NRunDB.nonTargetOpacity or 0.7
    NRunDB.cooldownsEnabled = (NRunDB.cooldownsEnabled  == nil and true) or NRunDB.cooldownsEnabled
    NRunDB.spellTextEnabled = (NRunDB.spellTextEnabled == nil and true) or NRunDB.spellTextEnabled
    NRunDB.shortTextEnabled = (NRunDB.shortTextEnabled == nil and true) or NRunDB.shortTextEnabled
    NRunDB.swapTarget = (NRunDB.swapTarget == nil and true) or NRunDB.swapTarget
    NRunDB.localNames   = (NRunDB.localNames == nil and false) or NRunDB.localNames
    NRunDB.CustomSpells = NRunDB.CustomSpells or {}
    NRunDB.totems = (NRunDB.totems == nil and true) or NRunDB.totems
    for id,opts in pairs(NRunDB.CustomSpells) do
        NugRunningConfig[id] = opts
    end
    NugRunning:SetupArrange()
        
    NugRunning:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        
    NugRunning:RegisterEvent("PLAYER_TALENT_UPDATE") -- changing between dualspec
    NugRunning:RegisterEvent("GLYPH_UPDATED")
    NugRunning:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
    NugRunning.ACTIVE_TALENT_GROUP_CHANGED = NugRunning.ReInitSpells
    NugRunning.GLYPH_UPDATED = NugRunning.ReInitSpells
    NugRunning.PLAYER_TALENT_UPDATE = NugRunning.ReInitSpells
    
    NugRunning:RegisterEvent("UNIT_COMBO_POINTS")
    
    NugRunning:RegisterEvent("PLAYER_TARGET_CHANGED")
    NugRunning:RegisterEvent("UNIT_AURA")
        
    if NRunDB.cooldownsEnabled then
        NugRunning:RegisterEvent("SPELL_UPDATE_COOLDOWN")
    end
        
    NugRunning:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW")
    NugRunning:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_HIDE")
        
        
    NugRunning.anchor = NugRunning.CreateAnchor()
    local pos = NRunDB.anchor
    NugRunning.anchor:SetPoint(pos.point, pos.parent, pos.to, pos.x, pos.y)
    for i=1,MAX_TIMERS do
        local timer = NugRunning:CreateTimer()
        free[timer] = true
    end
        
    SLASH_NUGRUNNING1= "/nugrunning"
    SLASH_NUGRUNNING2= "/nrun"
    SlashCmdList["NUGRUNNING"] = NugRunning.SlashCmd
    
    if NRunDB.totems and NugRunning.InitTotems then NugRunning:InitTotems() end
end

function NugRunning.COMBAT_LOG_EVENT_UNFILTERED( self, event, timestamp, eventType, hideCaster,
                srcGUID, srcName, srcFlags, srcFlags2,
                dstGUID, dstName, dstFlags, dstFlags2,
                spellID, spellName, spellSchool, auraType, amount)

    if NugRunningConfig[spellID] then
        local isSrcPlayer = (bit_band(srcFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) == COMBATLOG_OBJECT_AFFILIATION_MINE)
        local opts = NugRunningConfig[spellID]
        if not isSrcPlayer and opts.anySource then
                isSrcPlayer = true
        end
        if opts.target and dstGUID ~= UnitGUID(opts.target) then return end
        if isSrcPlayer then
            if eventType == "SPELL_AURA_REFRESH" or eventType == "SPELL_AURA_APPLIED_DOSE" then
                return self:RefreshTimer(srcGUID, dstGUID, dstName, dstFlags, spellID, spellName, opts, auraType, nil, amount)
            elseif eventType == "SPELL_AURA_APPLIED" then
                return self:ActivateTimer(srcGUID, dstGUID, dstName, dstFlags, spellID, spellName, opts, auraType)
            elseif eventType == "SPELL_AURA_REMOVED" then
                return self:DeactivateTimer(srcGUID, dstGUID, spellID, spellName, opts, auraType)
            elseif eventType == "SPELL_AURA_REMOVED_DOSE" then
                return self:RemoveDose(srcGUID, dstGUID, spellID, spellName, auraType, amount)
            end
        end
    end

    if eventType == "UNIT_DIED" or eventType == "UNIT_DESTROYED" then
        self:DeactivateTimersOnDeath(dstGUID)
    end
end

function NugRunning.SPELL_ACTIVATION_OVERLAY_GLOW_SHOW(self,event, spellID)
    if NugRunningConfig.activations[spellID] then
        local opts = NugRunningConfig.activations[spellID]
        if opts.showid then spellID = opts.showid end
        self:ActivateTimer(UnitGUID("player"),UnitGUID("player"), UnitName("player"), nil, spellID, opts.localname, opts, "ACTIVATION", opts.duration)
    end
end
function NugRunning.SPELL_ACTIVATION_OVERLAY_GLOW_HIDE(self,event, spellID)
    if NugRunningConfig.activations[spellID] then
        local opts = NugRunningConfig.activations[spellID]
        if opts.showid then spellID = opts.showid end
        self:DeactivateTimer(UnitGUID("player"),UnitGUID("player"), spellID, nil, opts, "ACTIVATION")
    end
end

-- cooldowns
function NugRunning.SPELL_UPDATE_COOLDOWN(self,event)
    for spellID,opts in pairs(NugRunningConfig.cooldowns) do
        local startTime, duration, enabled = GetSpellCooldown(opts.localname)
        local timer
        if opts.timer and (opts.timer.spellID == spellID) then timer = opts.timer end
        if duration and duration > 1.5 then
            if not active[timer] or timer.isGhost then
                opts.timer = self:ActivateTimer(UnitGUID("player"),UnitGUID("player"), UnitName("player"), nil, spellID, opts.localname, opts, "COOLDOWN", duration + startTime - GetTime())
            end
        elseif timer and (active[timer] and opts.resetable) then
            if not timer.isGhost then
                free[timer] = true
                opts.timer = nil
            end
        end
    end
end

local helpful = "HELPFUL|PLAYER"
local harmful = "HARMFUL|PLAYER"
function NugRunning.ActivateTimer(self,srcGUID,dstGUID,dstName,dstFlags, spellID, spellName, opts, timerType, override)  -- duration override
    local multiTargetGUID
    if opts.multiTarget then multiTargetGUID = dstGUID; dstGUID = nil; end
    
    local timer = gettimer(active,spellID,dstGUID,timerType)
    if timer then
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
        
    local time
    if override then time = override
    else
        time = NugRunning.SetDefaultDuration(dstFlags, opts)
        if timerType == "BUFF" or timerType == "DEBUFF" then
            if timerType == "BUFF"
            then timer.filter = helpful
            else timer.filter = harmful
            end
            local _guid = opts.shout and UnitGUID("player") or (multiTargetGUID or dstGUID)
            NugRunning.QueueAura(spellID, _guid, timerType, timer)
        end
    end
    
    timer.srcGUID = srcGUID
    timer.dstGUID = dstGUID
    timer.dstName = dstName
    if multiTargetGUID then timer.targets[multiTargetGUID] = true end
    timer.spellID = spellID
    timer.timerType = timerType
    timer.icon:SetTexture(select(3,GetSpellInfo(spellID)))
    timer.opts = opts
    timer.priority = opts.priority
    local now = GetTime()
    timer.fixedoffset = opts.fixedlen and time - opts.fixedlen or 0
    if timer.SetName then timer:SetName() end
    if not opts.timeless then
        if timer.SetTime then timer:SetTime(now + timer.fixedoffset, now + time) end
        if timer.SetCount then timer:SetCount(1) end
    else
        timer:MakeTimeless( (not opts.charged) )
        if timer.SetCount then timer:SetCount(1) end
    end
    if opts.charged then
        timer:SetCharge(1,0,opts.maxcharge)
    end
    
    if not opts.color then
    if timerType == "DEBUFF" then opts.color = { 0.8, 0.1, 0.7}
    else opts.color = { 1, 0.4, 0.2} end
    end
    timer:SetColor(unpack(opts.color))
    if timer.glow:IsPlaying() then timer.glow:Stop() end
    timer:Show()
    if not timer.animIn:IsPlaying() then timer.animIn:Play() end
    if opts.shine and not timer.shine:IsPlaying() then timer.shine:Play() end
    
    self:ArrangeTimers()
    return timer
end

-- 4.2 hack
local h = CreateFrame("Frame")
h:SetScript("OnEvent",function(self, event, unit)
    if unit ~= "target" and unit ~= "player" then return end
    local targetGUID = UnitGUID(unit)
    local targetName = UnitName(unit)
    local playerGUID = UnitGUID("player")
    for timer in pairs(active) do 
        if  timer.dstGUID == targetGUID then
            for i=1,100 do
                local name, _,_, count, _, duration, expirationTime, caster, _,_, aura_spellID = UnitAura(unit, GetSpellInfo(timer.spellID), nil, timer.filter)
                if  caster == "player" and
                    timer.spellID == aura_spellID and
                    GetTime() + duration - expirationTime < 0.1
                    then
--~                     print (GetTime() + duration - expirationTime)
                    NugRunning:RefreshTimer(playerGUID,targetGUID,targetName,nil, timer.spellID, timer.spellName, timer.opts, timer.timerType, duration, count)
                
                end
            end
        end
    end
end)
h:RegisterEvent("UNIT_AURA")

function NugRunning.RefreshTimer(self,srcGUID,dstGUID,dstName,dstFlags, spellID, spellName, opts, timerType, override, amount)
    local multiTargetGUID
    if opts.multiTarget then multiTargetGUID = dstGUID; dstGUID = nil; end
    
    local timer = gettimer(active,spellID,dstGUID,timerType)
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
        time = NugRunning.SetDefaultDuration(dstFlags, opts)
        if timerType == "BUFF" or timerType == "DEBUFF" then
            if not dstGUID then
                if timer.queued and GetTime() < timer.queued + 0.9 then
                    return
                end
            end
            local _guid = opts.shout and UnitGUID("player") or (dstGUID or multiTargetGUID)
            timer.queued = NugRunning.QueueAura(spellID, _guid, timerType, timer)
        end
    end
    
    if not opts.timeless then 
        local now = GetTime()
        if timer.SetTime and time then timer:SetTime(now + timer.fixedoffset, now + time) end
        if timer.SetCount then timer:SetCount(amount) end
    end
    if amount and opts.charged then
        timer:SetCharge(amount)
    end

    if opts.shinerefresh and not timer.shine:IsPlaying() then timer.shine:Play() end
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
            timer:SetCount(amount)
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
    timer.OnUpdateCounter = 2.5
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

function NugRunning.SetDefaultDuration(dstFlags, v )
    if v.pvpduration
        and bit.band(dstFlags, COMBATLOG_FILTER_HOSTILE_PLAYERS) == COMBATLOG_FILTER_HOSTILE_PLAYERS
        then return v.pvpduration
    end
    return ((type(v.duration) == "function" and v.duration()) or v.duration)
end

local debuffUnits = {"target","mouseover","arena1","arena2","arena3","arena4","arena5","focus"}
local buffUnits = {"player","target","mouseover"}
local queue = {}
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
    queue[unit] = queue[unit] or {}
    queue[unit][spellID] = timer
    return GetTime()
end
function NugRunning.UNIT_AURA (self,event,unit)
    if not queue[unit] then return end
    for spellID, timer in pairs(queue[unit]) do
        local name, _,_, count, _, duration, expirationTime, caster, _,_, aura_spellID = UnitAura(unit, GetSpellInfo(spellID), nil, timer.filter)
        if name then
            if not timer.opts.timeless then
                if timer.SetTime then timer:SetTime(expirationTime - duration + timer.fixedoffset,expirationTime) end
                if timer.SetCount then timer:SetCount(count) end
            end
            if timer.opts.charged then
                timer:SetCharge(count)
            end
            queue[unit][spellID] = nil
        elseif timer.queued and timer.queued + 0.4 < GetTime() then
            queue[unit][spellID] = nil
        end
    end
    if not next(queue[unit]) then queue[unit] = nil end
end
function NugRunning.PLAYER_TARGET_CHANGED(self)
    self:ArrangeTimers()
end
local GhostFunc = function(self,time)
    self.OnUpdateCounter = (self.OnUpdateCounter or 0) + time
    if self.OnUpdateCounter < 3 then return end
    self:SetScript("OnUpdate",NugRunning.TimerFunc)
    self.expiredGhost = true
    free[self] = true
    self.isGhost = nil
    NugRunning:ArrangeTimers()
end
function NugRunning.CreateTimer(self)
    local f = CreateFrame("Frame",nil,UIParent)
    
    NugRunning.BarFrame(f)
    
    f.BecomeGhost = function(self)
        self.expiredGhost = nil
        self.isGhost = true
        self:SetColor(0.5,0,0)
        self.timeText:SetText("")
        self.bar:SetValue(0)
        --self:SetAlpha(0.8)
        self.OnUpdateCounter = 0
        self:SetScript("OnUpdate",GhostFunc)
    end
    
    f.targets = {}
    f:Hide()
    table.insert(alltimers,f)
    
    return f
end

local prevGUID
local xOffset = 0
local yOffset = 4
local point
local to
local ySign
local nonTargetOpacity
local doswap
function NugRunning.SetupArrange(self)
    point = ( NRunDB.growth == "down" and "TOPLEFT" ) or "BOTTOMLEFT"
    to = ( NRunDB.growth == "down" and "BOTTOMLEFT" ) or "TOPLEFT"
    ySign = ( NRunDB.growth == "down" and -1 ) or 1
    nonTargetOpacity = NRunDB.nonTargetOpacity
    doswap = NRunDB.swapTarget
end
local playerTimers = {}
local targetTimers = {}
local sortfunc = function(a,b)
    if a.priority and not b.priority then return false end
    if not a.priority and b.priority then return true end
    if a.priority and b.priority then return (a.priority < b.priority) end
    return (a.endTime > b.endTime)
end
local arrangePending
local arrangeInProgress
function NugRunning.ArrangeTimers(self)
    if arrangeInProgress then arrangePending = true; return end
    arrangePending = false
    arrangeInProgress = true -- a little synchronization
    while next(playerTimers) do table.remove(playerTimers) end
    while next(targetTimers) do table.remove(targetTimers) end

    local sorted = {}
    local targetGUID = UnitGUID("target")
    local playerGUID = UnitGUID("player")
    for timer in pairs(active) do
        if timer.opts.group then
            sorted[timer.opts.group] = sorted[timer.opts.group] or {}
            table.insert(sorted[timer.opts.group],timer)
        elseif doswap and timer.dstGUID == targetGUID then table.insert(targetTimers,timer)
        elseif timer.dstGUID == playerGUID then table.insert(playerTimers,timer)
        elseif timer.dstGUID == nil then
            if timer.timerType == "BUFF" then
                table.insert(playerTimers,timer)
            else
                table.insert(targetTimers,timer)
            end
        else
            sorted[timer.dstGUID] = sorted[timer.dstGUID] or {}
            table.insert(sorted[timer.dstGUID],timer)
        end
    end
    
    --everything here is stupdid
    table.sort(playerTimers,sortfunc)
    table.sort(targetTimers,sortfunc)
    for group,tbl in pairs(sorted) do
    table.sort(tbl,sortfunc)
    end

    local prev
    local gap = 0
    for i,timer in ipairs(playerTimers) do
        timer:SetAlpha(1)
        timer:SetPoint(point,prev or self.anchor, ( prev and to ) or "TOPRIGHT", xOffset, (yOffset+gap)*ySign)
        prev = timer
        prevGUID = timer.dstGUID
        gap = 0
    end
    gap = prev and 10 or 0
    for i,timer in ipairs(targetTimers) do
        timer:SetAlpha(1)
        timer:SetPoint(point,prev or self.anchor,( prev and to ) or "TOPRIGHT", xOffset, (yOffset+gap)*ySign)
        prev = timer
        prevGUID = timer.dstGUID
        gap = 0
    end
    gap = prev and 25 or 0    

    for target in pairs(sorted) do
            for i,timer in ipairs(sorted[target]) do
                local newalpha = (timer.dstGUID == targetGUID) and 1 or nonTargetOpacity
                if timer.timerType == "DEBUFF" then
                    timer:SetAlpha(newalpha)
                else
                    timer:SetAlpha(1)
                end
                timer:SetPoint(point,prev or self.anchor,( prev and to ) or "TOPRIGHT", xOffset, (yOffset+gap)*ySign)
                prev = timer
                prevGUID = timer.dstGUID
                gap = 0
            end
            gap = 6
    end
    
    arrangeInProgress = false
    if arrangePending then NugRunning:ArrangeTimers() end
end








function NugRunning.UNIT_COMBO_POINTS(self,event,unit)
    if unit ~= "player" then return end
    self.cpWas = self.cpNow or 0
    self.cpNow = GetComboPoints(unit);
end
function NugRunning.ReInitSpells(self,event,arg1)
    for id,opts in pairs(NugRunningConfig) do
        if opts.init_done then
            opts:init()
        end
    end
end
function NugRunning.SettingsChanged(self)
    for _,timer in pairs(alltimers) do
        if timer.OnSettingsChanged then timer:OnSettingsChanged() end
    end
end
function NugRunning.ClearTimers(self, keepSelfBuffs)
    for timer in pairs(active) do
        if not (keepSelfBuffs and (timer.dstGUID == timer.srcGUID)) then
            free[timer] = true
        end
    end
    self:ArrangeTimers()
end







local ParseOpts = function(str)
    local fields = {}
    for opt,args in string.gmatch(str,"(%w*)%s*=%s*([%w%,%-%_%.%:%\\%']+)") do
        fields[opt:lower()] = tonumber(args) or args
    end
    return fields
end
function NugRunning.SlashCmd(msg)
    k,v = string.match(msg, "([%w%+%-%=]+) ?(.*)")
    if not k or k == "help" then print([[Usage:
      |cff00ff00/nrun lock|r
      |cff00ff00/nrun unlock|r
      |cff00ff00/nrun reset|r
      |cff00ff00/nrun clear|r
      |cff00ff00/nrun charopts|r : enable character specific settings
      |cff00ff00/nrun cooldowns|r : toggle showing cooldowns
      |cff00ff00/nrun spelltext|r : toggle spell text on bars
      |cff00ff00/nrun shorttext|r : toggle using short names
      |cff00ff00/nrun swaptarget|r : static order of target debuffs
      |cff00ff00/nrun totems|r : static order of target debuffs
      |cff00ff00/nrun localnames|r: toggle localized spell names
      |cff00ff00/nrun set|r width=120 height=20 fontscale=1.1 growth=up/down nontargetopacity=0.7: W & H of timers
      |cff00ff00/nrun setpos|r point=CENTER parent=UIParent to=CENTER x=0 y=0]]
    )end
    if k == "unlock" then
        NugRunning.anchor:Show()
        local prev
        for i,timer in ipairs(alltimers) do
            local fakeopts = {}
            if not timer.opts then timer.opts = fakeopts; timer.startTime = GetTime(); timer.endTime = GetTime()+40; end
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
            timer:SetPoint(point,prev or NugRunning.anchor,( prev and to ) or "TOPRIGHT", xOffset,yOffset * ySign)
            prev = timer
        end
    end
    if k == "lock" then
        NugRunning.anchor:Hide()
        for _,timer in ipairs(alltimers) do
            if not active[timer] then
                timer:Hide()
            end
        end
    end
    if k == "reset" then
        NRunDB.anchor.point = "CENTER"
        NRunDB.anchor.parent = "UIParent"
        NRunDB.anchor.to = "CENTER"
        NRunDB.anchor.x = 0
        NRunDB.anchor.y = 0
        local pos = NRunDB.anchor
        NugRunning.anchor:SetPoint(pos.point, pos.parent, pos.to, pos.x, pos.y)
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
    end
    if k == "spelltext" then
        NRunDB.spellTextEnabled = not NRunDB.spellTextEnabled
        print("NRun spell text "..(NRunDB.spellTextEnabled and "enabled" or "disabled"))
    end
    if k == "shorttext" then
        NRunDB.shortTextEnabled = not NRunDB.shortTextEnabled
        print("NRun short spell text "..(NRunDB.shortTextEnabled and "enabled" or "disabled"))
    end
    if k == "localnames" then
        NRunDB.localNames = not NRunDB.localNames
        print("NRun localized spell names "..(NRunDB.localNames and "enabled" or "disabled"))
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
    if k == "set" then
        local p = ParseOpts(v)
        NRunDB.width = p["width"] or NRunDB.width
        NRunDB.height = p["height"] or NRunDB.height
        NRunDB.growth = p["growth"] or NRunDB.growth
        NRunDB.fontscale = p["fontscale"] or NRunDB.fontscale
        --NRunDB.fontsize = p["fontsize"] or NRunDB.fonsize
        NRunDB.nonTargetOpacity = p["nontargetopacity"] or NRunDB.nonTargetOpacity
        for i,timer in ipairs(alltimers) do
            timer:ClearAllPoints()
        end
        NugRunning:SettingsChanged()
        NugRunning:SetupArrange()
        NugRunning:ArrangeTimers()
    end
    if k == "addspell" then
        local p = ParseOpts(v)
        if p.id and type(p.id) == "number" then
            local c = {}
            c[1] = p.cr or 1
            c[2] = p.cg or 0.3
            c[3] = p.cb or 0.6
            p.cr = nil; p.cb = nil; p.cg = nil;
            p.color = c
            p.name = p.name:gsub("_"," ")
            NRunDB.CustomSpells[p.id] = p
            NugRunningConfig[p.id] = p
        end
    end
    if k == "delspell" then
        local p = ParseOpts(v)
        if p.id and type(p.id) == "number" then
            NRunDB.CustomSpells[p.id] = nil
            NugRunningConfig[p.id] = nil
        end
    end
    if k == "listcustom" then
        for id,opts in pairs(NRunDB.CustomSpells) do
            print (string.format("%5d | %s",id,opts.name))
        end
    end
    if k == "setpos" then
        local p = ParseOpts(v)
        NRunDB.anchor.point = p["point"] or NRunDB.anchor.point
        NRunDB.anchor.parent = p["parent"] or NRunDB.anchor.parent
        NRunDB.anchor.to = p["to"] or NRunDB.anchor.to
        NRunDB.anchor.x = p["x"] or NRunDB.anchor.x
        NRunDB.anchor.y = p["y"] or NRunDB.anchor.y
        local pos = NRunDB.anchor
        NugRunning.anchor:SetPoint(pos.point, pos.parent, pos.to, pos.x, pos.y)
    end
    if k == "debug" then
        NugRunning.debug = CreateFrame("Frame")
        NugRunning.debug:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        NugRunning.debug:SetScript("OnEvent",function( self, event, timestamp, eventType, hideCaster, 
                                                        srcGUID, srcName, srcFlags, srcFlags2,
                                                        dstGUID, dstName, dstFlags, dstFlags2,
                                                        spellID, spellName, spellSchool, auraType, amount)
            local isSrcPlayer = (bit_band(srcFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) == COMBATLOG_OBJECT_AFFILIATION_MINE)
            if isSrcPlayer then print (spellID, spellName, eventType, srcGUID,"->",dstGUID, amount) end
        end)
    end
    if k == "nodebug" then
        NugRunning.debug:UnregisterAllEvents()
    end
end

function NugRunning.CreateAnchor()
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
    
    f:SetScript("OnMouseDown",function(self)
            self:StartMoving()
        end)
    f:SetScript("OnMouseUp",function(self)
            self:StopMovingOrSizing();
            local point,_,to,x,y = self:GetPoint(1)
            NRunDB.anchor.point = point
            NRunDB.anchor.parent = "UIParent"
            NRunDB.anchor.to = to
            NRunDB.anchor.x = x
            NRunDB.anchor.y = y
    end)
    return f
end
