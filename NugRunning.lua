NugRunning = CreateFrame("Frame","NugRunning")

NugRunning:SetScript("OnEvent", function(self, event, ...)
	self[event](self, event, ...)
end)

NugRunning:RegisterEvent("ADDON_LOADED")

local TrackSpells = NugRunningConfig
local MAX_TIMERS = 15
NugRunning.MAX_TIMERS = MAX_TIMERS
local timers = {}
NugRunning.timers = timers
local queue = {}
local char
local user = "Default"

local bit_band = bit.band
local UnitAura = UnitAura

GetHastedDuration = function(casttime)
    local haste = GetCombatRatingBonus(CR_HASTE_SPELL)/100 + 1
    if UnitAura("player",GetSpellInfo(3738),nil,"HELPFUL") then haste = haste * 1.05 end -- Wrath of air totem
    if UnitAura("player",GetSpellInfo(64368),nil,"HELPFUL") then haste = haste * 1.20 end --Eradication
    if UnitAura("player",GetSpellInfo(2825),nil,"HELPFUL") or UnitAura("player",GetSpellInfo(32182),nil,"HELPFUL") then haste = haste * 1.30 end --Bloodlust
    return (casttime / haste)
end

function NugRunning.ADDON_LOADED(self,event,arg1)
    if arg1 == "NugRunning" then
        
        NugRunningDB = NugRunningDB or {}
        NugRunningDB.opts = NugRunningDB.opts or {}
        NugRunningDB.opts["Default"] = NugRunningDB.opts["Default"] or {}
        if NugRunningDB.opts[UnitName("player").."@"..GetRealmName()] then user = UnitName("player").."@"..GetRealmName() end
        NugRunningDB.opts[user].pos = NugRunningDB.opts[user].pos or {}
        NugRunningDB.opts[user].pos.point = NugRunningDB.opts[user].pos.point or "CENTER"
        NugRunningDB.opts[user].pos.parent = NugRunningDB.opts[user].pos.parent or "UIParent"
        NugRunningDB.opts[user].pos.to = NugRunningDB.opts[user].pos.to or "CENTER"
        NugRunningDB.opts[user].pos.x = NugRunningDB.opts[user].pos.x or 0
        NugRunningDB.opts[user].pos.y = NugRunningDB.opts[user].pos.y or 0
        NugRunningDB.opts[user].width = NugRunningDB.opts[user].width or 150
        NugRunningDB.opts[user].height = NugRunningDB.opts[user].height or 20
        NugRunningDB.opts[user].growth = NugRunningDB.opts[user].growth or "up"
        NugRunningDB.opts[user].nonTargetOpacity = NugRunningDB.opts[user].nonTargetOpacity or 0.7
        NugRunningDB.opts[user].cooldownsEnabled = (NugRunningDB.opts[user].cooldownsEnabled  == nil and true) or NugRunningDB.opts[user].cooldownsEnabled
        NugRunningDB.opts[user].spellTextEnabled = (NugRunningDB.opts[user].spellTextEnabled == nil and true) or NugRunningDB.opts[user].spellTextEnabled
        NugRunningDB.opts[user].shortTextEnabled = (NugRunningDB.opts[user].shortTextEnabled == nil and true) or NugRunningDB.opts[user].shortTextEnabled
        NugRunningDB.opts[user].localNames   = (NugRunningDB.opts[user].localNames == nil and false) or NugRunningDB.opts[user].localNames
        NugRunning:SetupArrange()
        
        NugRunning:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
        
        NugRunning:RegisterEvent("PLAYER_TALENT_UPDATE") -- changing between dualspec
        NugRunning:RegisterEvent("GLYPH_UPDATED")
        NugRunning:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
        NugRunning.ACTIVE_TALENT_GROUP_CHANGED = NugRunning.ReInitSpells
        NugRunning.GLYPH_UPDATED = NugRunning.ReInitSpells
        NugRunning.PLAYER_TALENT_UPDATE = NugRunning.ReInitSpells
        
        NugRunning:RegisterEvent("PLAYER_TARGET_CHANGED")        
        
        NugRunning:RegisterEvent("UNIT_COMBO_POINTS")
        NugRunning:RegisterEvent("UNIT_AURA")
        
        if NugRunningDB.opts[user].cooldownsEnabled then
            NugRunning:RegisterEvent("SPELL_UPDATE_COOLDOWN")
        end
        
        NugRunning:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_SHOW")
        NugRunning:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_HIDE")
        
        if select(2,UnitClass("player")) == "SHAMAN" then
            NugRunning:InitTotems()
        end
        
        NugRunning.anchor = NugRunning.CreateAnchor()
        local pos = NugRunningDB.opts[user].pos
        NugRunning.anchor:SetPoint(pos.point, pos.parent, pos.to, pos.x, pos.y)
        for i=1,MAX_TIMERS do
            timers[i] = NugRunning.CreateTimer(NugRunningDB.opts[user].width,NugRunningDB.opts[user].height)
        end
        
        SLASH_NUGRUNNING1= "/nugrunning"
        SLASH_NUGRUNNING2= "/nrun"
        SlashCmdList["NUGRUNNING"] = NugRunning.SlashCmd
    end
end

function NugRunning.COMBAT_LOG_EVENT_UNFILTERED( self, event, timestamp, eventType, srcGUID, srcName, srcFlags, dstGUID, dstName, dstFlags, spellID, spellName, spellSchool, auraType, amount, a1,a2,a3)
    local isSrcPlayer = (bit.band(srcFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) == COMBATLOG_OBJECT_AFFILIATION_MINE)
--~     if isSrcPlayer then
--~         print (spellID, spellName, eventType)
--~     end
    
    if TrackSpells[spellID] then
        local isSrcPlayer = (bit_band(srcFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) == COMBATLOG_OBJECT_AFFILIATION_MINE)
        local opts = TrackSpells[spellID]
        if not isSrcPlayer and opts.anySource then
                --srcGUID = UnitGUID("player")
                isSrcPlayer = true
        end
        if opts.target and dstGUID ~= UnitGUID(opts.target) then return end
        if isSrcPlayer then
            if eventType == "SPELL_AURA_REFRESH" or eventType == "SPELL_AURA_APPLIED_DOSE" then
                self:RefreshTimer(srcGUID, dstGUID, dstName, dstFlags, spellID, spellName, opts, auraType, nil, amount)
                return
            elseif eventType == "SPELL_AURA_APPLIED" then
                self:ActivateTimer(srcGUID, dstGUID, dstName, dstFlags, spellID, spellName, opts, auraType)
                return
            elseif eventType == "SPELL_AURA_REMOVED" then
                self:DeactivateTimer(srcGUID, dstGUID, spellID, spellName, opts, auraType)
                return
            elseif eventType == "SPELL_AURA_REMOVED_DOSE" then
                self:RemoveDose(nil, dstGUID, spellID, spellName, amount)
                return
            end   
        end
    end

    
    
    if eventType == "UNIT_DIED" or eventType == "UNIT_DESTROYED" then
        self:DeactivateTimersOnDeath(dstGUID)
    end
end

function NugRunning.SPELL_ACTIVATION_OVERLAY_GLOW_SHOW(self,event, spellID)
    if TrackSpells.activations[spellID] then
        local opts = TrackSpells.activations[spellID]
        if opts.showid then spellID = opts.showid end
        self:ActivateTimer(UnitGUID("player"),UnitGUID("player"), UnitName("player"), nil, spellID, opts.localname, opts, "ACTIVATION", opts.duration)
    end
end
function NugRunning.SPELL_ACTIVATION_OVERLAY_GLOW_HIDE(self,event, spellID)
    if TrackSpells.activations[spellID] then
        local opts = TrackSpells.activations[spellID]
        if opts.showid then spellID = opts.showid end
        self:DeactivateTimer(UnitGUID("player"),UnitGUID("player"), spellID, nil, opts, "ACTIVATION")
    end
end

-- cooldowns
function NugRunning.SPELL_UPDATE_COOLDOWN(self,event)
    for spellID,opts in pairs(TrackSpells.cooldowns) do
        local startTime, duration, enabled = GetSpellCooldown(opts.localname)
        local timer
        if opts.timer and (opts.timer.spellID == spellID) then timer = opts.timer end
        if duration and duration > 1.5 then
            if not timer or not timer.active then
                opts.timer = self:ActivateTimer(UnitGUID("player"),UnitGUID("player"), UnitName("player"), nil, spellID, opts.localname, opts, "COOLDOWN", duration + startTime - GetTime())
            end
        elseif timer and (timer.active and opts.resetable) then
            timer.active = false
            timer:Hide()
            opts.timer = nil
        end
    end
end

local helpful = "HELPFUL|PLAYER"
local harmful = "HARMFUL|PLAYER"
function NugRunning.ActivateTimer(self,srcGUID,dstGUID,dstName,dstFlags, spellID, spellName, opts, timerType, override)  -- duration override
    local time
    local multiTargetGUID
    if opts.multiTarget then
        multiTargetGUID = dstGUID
        dstGUID = nil
    end

    local timer
    local spellTimersActive = 0
    for i=1,MAX_TIMERS do
        if timers[i].spellID == spellID and timers[i].timerType == timerType and timers[i].active then
            if timers[i].dstGUID == dstGUID then
                if multiTargetGUID then timers[i].targets[multiTargetGUID] = true end
                self:RefreshTimer(srcGUID, dstGUID, dstName, dstFlags, spellID, spellName, opts, timerType, override)
                return
            end
            spellTimersActive = spellTimersActive + 1
        end
    end
    if opts.maxtimers and spellTimersActive >= opts.maxtimers and UnitGUID("target") ~= dstGUID then return end
    
    
    --get empty timer
    if not timer then
        for i=1,MAX_TIMERS do
            if not timers[i].active then
                timer = timers[i]
                break
            end
        end
        if not timer then return end
    end
    
    
    if opts.init and not opts.init_done then
        opts:init()
        opts.init_done = true
    end
    
    
    --duration & queue
    if override then time = override
    else
        if timerType == "BUFF" then timer.filter = helpful end
        if timerType == "DEBUFF" then timer.filter = harmful end
        if notPlayerSrc then timer.filter = string.sub (timer.filter, 1 , 7) end
        time = NugRunning.SetTime(dstFlags, opts)
        local _guid = opts.shout and UnitGUID("player") or (dstGUID or multiTargetGUID)
        NugRunning.QueueAura(spellID, _guid, timerType, timer)
    end
    
    
    timer.active = true
    timer.srcGUID = srcGUID
    timer.dstGUID = dstGUID
    if multiTargetGUID then
        timer.targets[multiTargetGUID] = true
    end
    timer.spellID = spellID
    --timer.spellName = spellName
    timer.timerType = timerType
    timer.timeless = opts.timeless
    timer.icon:SetTexture(select(3,GetSpellInfo(spellID)))
    timer.startTime = GetTime()
    timer.endTime = timer.startTime + time
    timer.bar:SetMinMaxValues(timer.startTime,timer.endTime)
    if opts.onrefresh then
        opts.onrefresh(timer, opts)
    end
    
    timer.group = opts.group
    --update mark
    timer.recast_mark = opts.recast_mark

    timer.mark:Update()
    
    --text
    if NugRunningDB.opts[user].spellTextEnabled then
        if NugRunningDB.opts[user].localNames then
            timer.spellText:SetText(spellName)
        elseif NugRunningDB.opts[user].shortTextEnabled and opts.short then
            timer.spellText:SetText(opts.short)
        else
            timer.spellText:SetText(opts.name)
        end
    else
        timer.spellText:SetText("")
    end
    if opts.textfunc and type(opts.textfunc) == "function" then timer.spellText:SetText(opts.textfunc(spellName,dstName)) end
    
    --stacks
    timer.stacks = 0
    timer.stacktext:SetText(timer.stacks)
    if timer.stacks > 1 then
        if not timer.stacktext:IsVisible() then
            timer.stacktext:Show()
        end
    else
        timer.stacktext:Hide()
    end
    
    --color
    if not opts.color then
        if timerType == "BUFF" then
            opts.color = { 1, 0.4, 0.2}
        elseif timerType == "COOLDOWN" then
            opts.color = { 0.7, 1, 0.7}
        else
            opts.color = { 0.8, 0.1, 0.7}
        end
    end
    timer.bar:SetStatusBarColor(unpack(opts.color))
    timer.bar.bg:SetVertexColor(opts.color[1] * 0.5, opts.color[2] * 0.5, opts.color[3] * 0.5)
    
    timer:Show()
    if not timer.animIn:IsPlaying() then timer.animIn:Play() end
    if opts.shine and not timer.shine:IsPlaying() then timer.shine:Play() end
    self:ArrangeTimers()
    
    return timer
end

function NugRunning.RefreshTimer(self,srcGUID,dstGUID,dstName,dstFlags, spellID, spellName, opts, timerType, override, amount)
    local time
    local multiTargetGUID
    if opts.multiTarget then
        multiTargetGUID = dstGUID
        dstGUID = nil
    end
    local timer
    for i=1,MAX_TIMERS do
        if timers[i].dstGUID == dstGUID and timers[i].spellID == spellID and timers[i].timerType == timerType and timers[i].active then
            timer = timers[i]
            break
        end
    end
    
    if not timer then
        self:ActivateTimer(srcGUID, dstGUID or multiTargetGUID, dstName, dstFlags, spellID, spellName, opts, timerType)
        return
    end

    if timerType ~= "COOLDOWN" then
        time = NugRunning.SetTime(dstFlags, opts)
        if not dstGUID then
            if timer.queued and GetTime() < timer.queued + 0.9 then
                return
            end
        end
        local _guid = opts.shout and UnitGUID("player") or (dstGUID or multiTargetGUID)
        timer.queued = NugRunning.QueueAura(spellID, _guid, timerType, timer)
    end
    if not time then return end
    
    
    timer.startTime = GetTime()
    timer.endTime = timer.startTime + time
    timer.bar:SetMinMaxValues(timer.startTime,timer.endTime)
    if opts.onrefresh then
        opts.onrefresh(timer, opts)
    end
    
    timer.mark:Update()
    
    if amount then
        timer.stacks = amount
        timer.stacktext:SetText(timer.stacks)
        if timer.stacks > 1 then
            if not timer.stacktext:IsVisible() then
                timer.stacktext:Show()
            end
        else
            timer.stacktext:Hide()
        end
    end
    if opts.shinerefresh and not timer.shine:IsPlaying() then timer.shine:Play() end
    self:ArrangeTimers()
end

function NugRunning.RemoveDose(self,srcGUID,dstGUID, spellID, spellName, amount)
    local timer
    for i=1,MAX_TIMERS do
        if timers[i].active and timers[i].dstGUID == dstGUID and timers[i].spellID == spellID and timers[i].timerType == timerType then
            timer = timers[i]
            break
        end
    end
    if not timer then return end
    timer.stacks = amount
    timer.stacktext:SetText(timer.stacks)
    if timer.stacks > 1 then
        if not timer.stacktext:IsVisible() then
            timer.stacktext:Show()
        end
    else
        timer.stacktext:Hide()
    end
end

function NugRunning.DeactivateTimer(self,srcGUID,dstGUID, spellID, spellName, opts, timerType)
    local timer, multiTargetGUID
    if opts.multiTarget then
        multiTargetGUID = dstGUID
        dstGUID = nil
    end
    for i=1,MAX_TIMERS do
        if timers[i].active and timers[i].srcGUID == srcGUID and timers[i].dstGUID == dstGUID and timers[i].spellID == spellID and timers[i].timerType == timerType then
            timer = timers[i]
            if multiTargetGUID then
                timer.targets[multiTargetGUID] = nil
                if next(timer.targets) then return end
            end
            timer.active = false
            timer:Hide()
            self:ArrangeTimers()
--~             if not timer.animOut:IsPlaying() then timer.animOut:Play() end
            return
        end
    end
end

function NugRunning.DeactivateTimersOnDeath(self,dstGUID)
    local timer
    for i=1,MAX_TIMERS do
        if timers[i].active and timers[i].dstGUID == dstGUID then
            timer = timers[i]
            timer.active = false
            timer:Hide()
            self:ArrangeTimers()
        end
    end
end




local prevGUID
local xOffset = 0
local yOffset = 4
local point
local to
local ySign
local nonTargetOpacity
function NugRunning.SetupArrange(self)
    point = ( NugRunningDB.opts[user].growth == "down" and "TOPLEFT" ) or "BOTTOMLEFT"
    to = ( NugRunningDB.opts[user].growth == "down" and "BOTTOMLEFT" ) or "TOPLEFT"
    ySign = ( NugRunningDB.opts[user].growth == "down" and -1 ) or 1
    nonTargetOpacity = NugRunningDB.opts[user].nonTargetOpacity
end
local active = {}
local playerTimers = {}
local targetTimers = {}
function NugRunning.ArrangeTimers(self)
    while next(active) do table.remove(active) end
    while next(playerTimers) do table.remove(playerTimers) end
    while next(targetTimers) do table.remove(targetTimers) end
    for i=1,MAX_TIMERS do
        if timers[i].active then
            table.insert(active,timers[i])
        end
    end
    table.sort(active,function(a,b) return (a.endTime > b.endTime) end)
    local sorted = {}
    
    local targetGUID = UnitGUID("target")
    local playerGUID = UnitGUID("player")
--~     , aoe = {}
    for i,timer in ipairs(active) do
        if timer.group then
            sorted[timer.group] = sorted[timer.group] or {}
            table.insert(sorted[timer.group],timer)
        elseif timer.dstGUID == targetGUID then table.insert(targetTimers,timer)
        elseif timer.dstGUID == playerGUID then table.insert(playerTimers,timer)
        elseif timer.dstGUID == nil then
            if timer.timerType == "BUFF" then
                table.insert(playerTimers,timer)
            else
                table.insert(targetTimers,timer)
            end
--~             table.insert(sorted.aoe,timer)
        else
            sorted[timer.dstGUID] = sorted[timer.dstGUID] or {}
            table.insert(sorted[timer.dstGUID],timer)
        end
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
    
    
--~     for i,timer in ipairs(sorted.aoe) do
--~         timer:SetAlpha(1)
--~         timer:SetPoint(point,prev or self.anchor,( prev and to ) or "TOPRIGHT", xOffset, (yOffset+gap)*ySign)
--~         prev = timer
--~         prevGUID = timer.dstGUID
--~         gap = 0
--~     end
--~     gap = prev and 10 or 0
    

    for target in pairs(sorted) do
            for i,timer in ipairs(sorted[target]) do
                if timer.timerType == "DEBUFF" then
--~                  or ( timer.timerType == "BUFF" and timer.dstGUID) 
                    timer:SetAlpha(nonTargetOpacity)
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
end


function NugRunning.PLAYER_TARGET_CHANGED(self)
    self:ArrangeTimers()
end

function NugRunning.UNIT_COMBO_POINTS(self,event,unit)
    if unit ~= "player" then return end
    self.cpWas = self.cpNow or 0
    self.cpNow = GetComboPoints(unit);
end





local TimerOnUpdate = function(self,time)
        if self.active then
            self.OnUpdateCounter = (self.OnUpdateCounter or 0) + time
            if self.OnUpdateCounter < 0.05 then return end
            self.OnUpdateCounter = 0

            if self.timeless then
                self.bar:SetValue(0)
                self.timeText:SetText("")
                return 
            end
            
            local beforeEnd = self.endTime - GetTime()

            if beforeEnd <= 0 then
                self:Hide()
                self.active = false
                NugRunning:ArrangeTimers()
--~                 if not self.animOut:IsPlaying() then self.animOut:Play() end
                while next(self.targets) do
                    self.targets[next(self.targets)] = nil
                end
                return               
            end
            
            self.bar:SetValue(beforeEnd + self.startTime)
            self.timeText:SetFormattedText("%.1f",beforeEnd)
            if self.threshold and beforeEnd < self.threshold and beforeEnd > self.threshold-0.1 then
                self.mark:Shine()
            end
        end
    end
function NugRunning.CreateTimer(width, height)

    local backdrop = {
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 0,
        insets = {left = -2, right = -2, top = -2, bottom = -2},
    }

    local f = CreateFrame("Frame",nil,UIParent)
    f.active = false
    f:SetWidth(width)
    f:SetHeight(height)
    
    f:SetBackdrop(backdrop)
	f:SetBackdropColor(0, 0, 0, 0.7)
--~ 	f:SetBackdropBorderColor(.3, .3, .3, 1)
    
    local ic = CreateFrame("Frame",nil,f)
    ic:SetPoint("TOPLEFT",f,"TOPLEFT", 0, 0)
    ic:SetPoint("BOTTOMRIGHT",f,"BOTTOMLEFT", height, 0)
    ic:SetFrameStrata("HIGH")
    local ict = ic:CreateTexture(nil,"ARTWORK",0)
    ict:SetTexCoord(.07, .93, .07, .93)
    ict:SetAllPoints(ic)
    f.icon = ict
    
    f.stacktext = ic:CreateFontString(nil, "OVERLAY");
    f.stacktext:SetFont("Fonts\\FRIZQT__.TTF",10,"OUTLINE")
    f.stacktext:SetHeight(ic:GetHeight())
    f.stacktext:SetJustifyH("RIGHT")
    f.stacktext:SetVertexColor(1,1,1)
    f.stacktext:SetPoint("RIGHT", ic, "RIGHT",1,-5)
    
    
--~     local color = { 1, 0.5 , 0.2}
    f.bar = CreateFrame("StatusBar",nil,f)
    f.bar:SetFrameStrata("MEDIUM")
--~     f.bar:SetWidth(width-height-1)
--~     f.bar:SetHeight(height)
    f.bar:SetStatusBarTexture("Interface\\AddOns\\NugRunning\\statusbar")
    f.bar:GetStatusBarTexture():SetDrawLayer("ARTWORK")
--~     f.bar:SetStatusBarColor(color[1],color[2],color[3])
    f.bar:SetPoint("BOTTOMLEFT",f.icon,"BOTTOMRIGHT",1,0)
    f.bar:SetPoint("TOPRIGHT",f,"TOPRIGHT",0,0)
    
    f.bar.bg = f.bar:CreateTexture(nil, "BORDER")
	f.bar.bg:SetAllPoints(f.bar)
	f.bar.bg:SetTexture("Interface\\AddOns\\NugRunning\\statusbar")
--~     f.bar.bg:SetVertexColor(color[1] * .5, color[2] * .5, color[3] * .5)
    
    f.timeText = f.bar:CreateFontString();
    f.timeText:SetFont("Fonts\\FRIZQT__.TTF",8)
--~     f.timeText:SetWidth(width/4)
--~     f.timeText:SetHeight(width)
    f.timeText:SetJustifyH("RIGHT")
    f.timeText:SetVertexColor(1,1,1)
    f.timeText:SetPoint("TOPRIGHT", f.bar, "TOPRIGHT",-6,0)
    f.timeText:SetPoint("BOTTOMLEFT", f.bar, "BOTTOMLEFT",0,0)
    
    f.spellText = f.bar:CreateFontString();
    f.spellText:SetFont("Fonts\\FRIZQT__.TTF",height/2)
    f.spellText:SetWidth(width/4*3 -12)
    f.spellText:SetHeight(height/2+1)
    f.spellText:SetJustifyH("CENTER")
    f.spellText:SetVertexColor(1,1,1)
    f.spellText:SetPoint("LEFT", f.bar, "LEFT",6,0)
    
    
    local at = ic:CreateTexture(nil,"OVERLAY")
    at:SetTexture([[Interface\SpellActivationOverlay\IconAlert]])
    at:SetTexCoord(0.00781250,0.50781250,0.27734375,0.52734375)
--~     at:SetTexture([[Interface\AchievementFrame\UI-Achievement-IconFrame]])
--~     at:SetTexCoord(0,0.5625,0,0.5625)
    at:SetWidth(height*1.8)
    at:SetHeight(height*1.8)
    at:SetPoint("CENTER",f.icon,"CENTER",0,0)
    at:SetAlpha(0)
    
    local sag = at:CreateAnimationGroup()
    local sa1 = sag:CreateAnimation("Alpha")
    sa1:SetChange(1)
    sa1:SetDuration(0.3)
    sa1:SetOrder(1)
    local sa2 = sag:CreateAnimation("Alpha")
    sa2:SetChange(-1)
    sa2:SetDuration(0.5)
    sa2:SetSmoothing("OUT")
    sa2:SetOrder(2)
    
    f.shine = sag
    
    
    local aag = f:CreateAnimationGroup()
    local aa1 = aag:CreateAnimation("Scale")
    aa1:SetOrigin("BOTTOM",0,0)
    aa1:SetScale(1,0.1)
    aa1:SetDuration(0)
    aa1:SetOrder(1)
    local aa2 = aag:CreateAnimation("Scale")
    aa2:SetOrigin("BOTTOM",0,0)
    aa2:SetScale(1,10)
    aa2:SetDuration(0.15)
    aa2:SetOrder(2)
--~     local aa1 = aag:CreateAnimation("Translation")
--~     aa1:SetOffset(40,0)
--~     aa1:SetDuration(0)
--~     aa1:SetOrder(1)
--~     local aa2 = aag:CreateAnimation("Translation")
--~     aa2:SetOffset(-40,0)
--~     aa2:SetDuration(1)
--~     aa2:SetOrder(2)    
    f.animIn = aag
    
--~     local dag = f:CreateAnimationGroup()
--~     local da1 = dag:CreateAnimation("Alpha")
--~     da1:SetChange(-1)
--~     da1:SetDuration(1)
--~     da1:SetOrder(1)
--~     local da2 = dag:CreateAnimation("Translation")
--~     da2:SetOffset(-50,0)
--~     da2:SetDuration(1)
--~     da2:SetOrder(1)
--~     
--~     dag:SetScript("OnFinished",function(self)
--~         self:GetParent().active = false
--~         self:GetParent():Hide()
--~         NugRunning:ArrangeTimers()
--~     end)
--~     
--~     f.animOut = dag

    
    
    f.mark = NugRunning.CreateMark(f)
    f.targets = {}
    f:SetScript("OnUpdate",TimerOnUpdate)
    f:Hide()
--~     if true then
--~         f.bar:SetWidth(0)
--~         f.bar:SetAlpha(0)
--~         f:SetWidth(height)
--~         f.timeText = f:CreateFontString(nil, "OVERLAY");
--~         f.timeText:SetFont("Fonts\\FRIZQT__.TTF",19) --font size here
--~         f.timeText:SetWidth(height*2)
--~         f.timeText:SetHeight(height)
--~         f.timeText:SetJustifyH("LEFT")
--~         f.timeText:SetVertexColor(1,1,1)
--~         f.timeText:SetPoint("LEFT", f.icon, "RIGHT",6,0)
--~     end
    return f
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
                NugRunningDB.opts[user].pos.point = point
                NugRunningDB.opts[user].pos.parent = "UIParent"
                NugRunningDB.opts[user].pos.to = to
                NugRunningDB.opts[user].pos.x = x
                NugRunningDB.opts[user].pos.y = y
    end)
    return f
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
      |cff00ff00/nrun localnames|r: toggle localized spell names
      |cff00ff00/nrun set|r width=120 height=20 growth=up/down nontargetopacity=0.7: W & H of timers
      |cff00ff00/nrun setpos|r point=CENTER parent=UIParent to=CENTER x=0 y=0]]
    )end
    if k == "unlock" then
        NugRunning.anchor:Show()
        local prev
        for i,timer in ipairs(timers) do
            timer:Show()
            local point, to
            local xOffset, yOffset, ySign = 0, 4, 1
            if NugRunningDB.opts[user].growth == "down" then
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
        return
    end
    if k == "lock" then
        NugRunning.anchor:Hide()
        for i,timer in ipairs(timers) do
            if not timer.active then
                timer:Hide()
            end
        end
        return
    end
    if k == "reset" then
        NugRunningDB.opts[user].pos.point = "CENTER"
        NugRunningDB.opts[user].pos.parent = "UIParent"
        NugRunningDB.opts[user].pos.to = "CENTER"
        NugRunningDB.opts[user].pos.x = 0
        NugRunningDB.opts[user].pos.y = 0
        local pos = NugRunningDB.opts[user].pos
        NugRunning.anchor:SetPoint(pos.point, pos.parent, pos.to, pos.x, pos.y)
    end
    if k == "clear" then
        NugRunning:ClearTimers(true)
    end
    if k == "charopts" then
        if not NugRunningDB.opts[UnitName("player").."@"..GetRealmName()] then
            user = UnitName("player").."@"..GetRealmName()
            print ("NRun character specific options enabled",0.7,1,0.7)
        
        else
            user = UnitName("player").."@"..GetRealmName()
            NugRunningDB.opts[user] = nil
            user = "Default"
            print ("NRun character specific options disabled",1,0.7,0.7)
        end
            print (user)
            NugRunningDB.opts[user] = {}
            NugRunningDB.opts[user].posX = NugRunningDB.opts["Default"].posX
            NugRunningDB.opts[user].posY = NugRunningDB.opts["Default"].posY
            NugRunningDB.opts[user].height = NugRunningDB.opts["Default"].height
            NugRunningDB.opts[user].width = NugRunningDB.opts["Default"].width
            NugRunningDB.opts[user].growth = NugRunningDB.opts["Default"].growth
            NugRunningDB.opts[user].nonTargetOpacity = NugRunningDB.opts["Default"].nonTargetOpacity
            NugRunningDB.opts[user].cooldownsEnabled = NugRunningDB.opts["Default"].cooldownsEnabled
            NugRunningDB.opts[user].spellTextEnabled = NugRunningDB.opts["Default"].spellTextEnabled
            NugRunningDB.opts[user].shortTextEnabled = NugRunningDB.opts["Default"].shortTextEnabled
            NugRunning.anchor:SetPoint("TOPLEFT", UIParent, "TOPLEFT",NugRunningDB.opts[user].posX,NugRunningDB.opts[user].posY)
        return
    end
    if k == "cooldowns" then
        if NugRunningDB.opts[user].cooldownsEnabled then
            NugRunning:UnregisterEvent("SPELL_UPDATE_COOLDOWN")
            print("NRun Cooldowns disabled")
        else
            NugRunning:RegisterEvent("SPELL_UPDATE_COOLDOWN")
            print("NRun Cooldowns enabled")
        end
        NugRunningDB.opts[user].cooldownsEnabled = not NugRunningDB.opts[user].cooldownsEnabled
        return
    end
    if k == "spelltext" then
        NugRunningDB.opts[user].spellTextEnabled = not NugRunningDB.opts[user].spellTextEnabled
        print("NRun spell text "..(NugRunningDB.opts[user].spellTextEnabled and "enabled" or "disabled"),0.7,0.7,1)
    end
    if k == "shorttext" then
        NugRunningDB.opts[user].shortTextEnabled = not NugRunningDB.opts[user].shortTextEnabled
        print("NRun short spell text "..(NugRunningDB.opts[user].shortTextEnabled and "enabled" or "disabled"),0.7,0.7,1)
    end
    if k == "localnames" then
        NugRunningDB.opts[user].localNames = not NugRunningDB.opts[user].localNames
        print("NRun localized spell names "..(NugRunningDB.opts[user].localNames and "enabled" or "disabled"),0.7,0.7,1)
    end
    if k == "set" then
        local p = ParseOpts(v)
        NugRunningDB.opts[user].width = p["width"] or NugRunningDB.opts[user].width
        NugRunningDB.opts[user].height = p["height"] or NugRunningDB.opts[user].height
        NugRunningDB.opts[user].growth = p["growth"] or NugRunningDB.opts[user].growth
        NugRunningDB.opts[user].nonTargetOpacity = p["nontargetopacity"] or NugRunningDB.opts[user].nonTargetOpacity
        for i,timer in ipairs(timers) do
            timer:ClearAllPoints()
        end
        NugRunning.RefreshFrameSettings(NugRunningDB.opts[user].width,NugRunningDB.opts[user].height)
        NugRunning:SetupArrange()
        NugRunning:ArrangeTimers()
    end
    if k == "setpos" then
        local p = ParseOpts(v)
        NugRunningDB.opts[user].pos.point = p["point"] or NugRunningDB.opts[user].pos.point
        NugRunningDB.opts[user].pos.parent = p["parent"] or NugRunningDB.opts[user].pos.parent
        NugRunningDB.opts[user].pos.to = p["to"] or NugRunningDB.opts[user].pos.to
        NugRunningDB.opts[user].pos.x = p["x"] or NugRunningDB.opts[user].pos.x
        NugRunningDB.opts[user].pos.y = p["y"] or NugRunningDB.opts[user].pos.y
        local pos = NugRunningDB.opts[user].pos
        NugRunning.anchor:SetPoint(pos.point, pos.parent, pos.to, pos.x, pos.y)
    end
end

function NugRunning.RefreshFrameSettings(width,height)
    for i=1,MAX_TIMERS do
        local f = timers[i]
        f:SetWidth(width)
        f:SetHeight(height)
        f.icon:SetWidth(height)
        f.icon:SetHeight(height)
        f.bar:SetWidth(width-height)
        f.bar:SetHeight(height)
        f.timeText:SetWidth(f.bar:GetWidth()/4)
        f.timeText:SetHeight(height)
        f.spellText:SetWidth(f.bar:GetWidth()/4*3 -12)
        f.spellText:SetHeight(height/2+1)
        f.spellText:SetFont("Fonts\\FRIZQT__.TTF",f.bar:GetHeight()/2)
    end
end


function NugRunning.ReInitSpells(self,event,arg1)
    for id,opts in pairs(TrackSpells) do
        if opts.init_done then
            opts:init()
        end
    end
end

NugRunning.CreateMark = function(self)
        local m = CreateFrame("Frame",nil,self)
        m:SetParent(self)
        m:SetWidth(16)
        m:SetHeight(self:GetHeight()*0.9)
        m:SetFrameLevel(4)
        m:SetAlpha(0.6)
        
        local texture = m:CreateTexture(nil, "OVERLAY")
		texture:SetTexture("Interface\\AddOns\\NugRunning\\mark")
        texture:SetVertexColor(1,1,1,0.3)
        texture:SetAllPoints(m)
        m.texture = texture
        
        
        local spark = m:CreateTexture(nil, "OVERLAY")
		spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
        spark:SetAlpha(0)
        spark:SetWidth(20)
        spark:SetHeight(m:GetWidth()*4)
        spark:SetPoint("CENTER",m)
		spark:SetBlendMode('ADD')
        m.spark = spark
        
        m.Shine = function (self)
            if self:IsVisible() then
                if not self.spark.animating then
                    self.spark.animating = true
                    NugRunning.Shine(self.spark)
                end
            end
        end
        
        m.Update = function (self)
            if self:GetParent().recast_mark then
                local th
                local opts = self:GetParent()
                if type(opts.recast_mark) == "string" and opts.recast_mark == "gcd" then
                    th = GetHastedDuration(1.5)
                else 
                    th = opts.recast_mark
                end
                local timer = self:GetParent()
                timer.threshold = th
                local pos = th / (timer.endTime - timer.startTime) * timer.bar:GetWidth()
                self:SetPoint("CENTER",timer.bar,"LEFT",pos,0)
                self:Show()
                self.texture:Show()
            else
                self:Hide()
            end
        end

        return m
end

function NugRunning.Shine(frame)
	UIFrameFade(frame,{
        mode = "IN",
        timeToFade = 0.2,
        finishedFunc = function(frame) frame.animating = false; UIFrameFadeOut(frame, 0.8); frame:GetParent().texture:Hide() end,
        finishedArg1 = frame 
    })
end


function NugRunning.SetTime(dstFlags, v )
    if v.pvpduration then
        if (bit.band(dstFlags, COMBATLOG_FILTER_HOSTILE_PLAYERS) == COMBATLOG_FILTER_HOSTILE_PLAYERS) then
            return ((type(v.pvpduration) == "function" and v.pvpduration()) or v.pvpduration)
        end
    end
    local d = ((type(v.duration) == "function" and v.duration()) or v.duration)
    if v.hasted then
        return GetHastedDuration(d)
    else
        return d
    end
end

local debuffUnits = {"target","mouseover","arena1","arena2","arena3","arena4","arena5","focus"}
local buffUnits = {"player","target","mouseover"}

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

local name, rank, texture, count, debuffType, duration, expirationTime, caster, isStealable, shouldConsolidate, spellID
function NugRunning.UNIT_AURA (self,event,unit)
    if not queue[unit] then return end
    for spellID, timer in pairs(queue[unit]) do
        name, rank, texture, count, debuffType, duration, expirationTime, caster, isStealable, shouldConsolidate, spellID = UnitAura(unit, GetSpellInfo(spellID), nil, timer.filter)
        if not name then return end
        
        timer.endTime = expirationTime
        timer.startTime = expirationTime - duration
        timer.bar:SetMinMaxValues(timer.startTime,timer.endTime)
        timer.mark:Update()
        
        queue[unit][spellID] = nil
    end
end
function NugRunning.ClearTimers(self, keepSelfBuffs)
    local timer
    for i=1,MAX_TIMERS do
        if timers[i].active and not (keepSelfBuffs and (timers[i].dstGUID == timers[i].srcGUID)) then
            timer = timers[i]
            timer.active = false
            timer:Hide()
            self:ArrangeTimers()
        end
    end
end