local class = select(2,UnitClass("player"))


local active = NugRunning.active
local free = NugRunning.free
local UnitGUID = UnitGUID

if class == "DEATHKNIGHT" then

    local infect
    if class  == "DEATHKNIGHT" then
        local FF = { id = 55095 }
        local BP = { id = 55078 }
        FF.name = GetSpellInfo(FF.id)
        BP.name = GetSpellInfo(BP.id)
        FF.opts = NugRunningConfig[FF.id]
        BP.opts = NugRunningConfig[BP.id]
        NugRunningConfig[BP.id] = nil
        NugRunningConfig[FF.id] = nil
        
        infect = { FF, BP}
    end
    -- if class  == "WARRIOR" then
    --     local rend = { id = 94009 }
    --     rend.name = GetSpellInfo(rend.id)
    --     rend.opts = NugRunningConfig[rend.id]
    --     NugRunningConfig[rend.id] = nil
        
    --     infect = { rend }
    -- end
    NugRunning.infect = infect

    local prevTargetGUID
    local dismon_onevent = function(self, event, unit)
        if unit and unit ~= "target" then return end
        for _, spell in ipairs(infect) do
            local _, _, _, _, _, duration, expirationTime = UnitAura("target",spell.name, nil,"HARMFUL|PLAYER")
            if duration then
                if event == "PLAYER_TARGET_CHANGED" or spell.expirationTime ~= expirationTime then
                spell.expirationTime = expirationTime
                --print ("Updating "..spell.name)
                if not spell.timer then
                    spell.timer = NugRunning:ActivateTimer(UnitGUID("player"), UnitGUID("target"), UnitName("target"), nil, spell.id, spell.name, spell.opts, "DEBUFF")
                    spell.timer.dontfree = true
                end
                if not spell.timer then return end
                active[spell.timer] = true
                spell.timer.dstGUID = UnitGUID("target")
                spell.timer:SetTime(expirationTime - duration, expirationTime)
                spell.timer:SetAlpha(1)
                spell.timer:Show()
                NugRunning:ArrangeTimers()
                end
            elseif spell.timer then
                active[spell.timer] = nil
                spell.timer:Hide()
                NugRunning:ArrangeTimers()
            end
        end
    end
    local DisMon = CreateFrame("Frame",nil,UIParent)
    DisMon:RegisterEvent("UNIT_AURA")
    DisMon:RegisterEvent("PLAYER_TARGET_CHANGED")
    DisMon:SetScript("OnEvent", dismon_onevent)


end -- end infect

if class == "WARRIOR" then
    local overpower_id = 7384
    local op_opts = NugRunningConfig[overpower_id]
    NugRunningConfig[overpower_id] = nil

    local op_timer
    local op_frame = CreateFrame("Frame")
    local old = false
    --[[op_frame.CheckFury = function(self)
        if IsSpellKnown(23881) then -- Bloodthirst, Raging Blow becomes known only after event is fired
            self:RegisterEvent("UNIT_AURA")
        else
            self:UnregisterEvent("UNIT_AURA")
            if enrage_timer then
                active[enrage_timer] = nil
                enrage_timer:Hide()
                NugRunning:ArrangeTimers()
            end
        end
    end]]

    op_frame:SetScript("OnEvent",function(self, event, unit)
        --if event == "ACTIVE_TALENT_GROUP_CHANGED" or event == "PLAYER_TALENT_UPDATE" then
        --    return self:CheckFury()
        --end
        --if unit ~= "player" then return end
        local new = IsUsableSpell(overpower_id)
        if new ~= old then
            old = new
            if new then
                    op_timer = NugRunning:ActivateTimer(UnitGUID("player"), UnitGUID("player"),
                                     UnitName("plyer"), nil,
                                     overpower_id, GetSpellInfo(overpower_id), op_opts, "COOLDOWN")
            else
                NugRunning:DeactivateTimer(UnitGUID("player"), UnitGUID("player"), overpower_id,  GetSpellInfo(overpower_id), op_opts, "COOLDOWN")
            end
        end
    end)

    hooksecurefunc(NugRunning,"PLAYER_LOGIN",function(self,event)
        --[[op_frame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
        op_frame:RegisterEvent("PLAYER_TALENT_UPDATE")
        op_frame:CheckFury()]]
        op_frame:RegisterEvent"SPELL_UPDATE_USABLE"
    end)

end

-- Enrage Timer
--[[
if class  == "WARRIOR" then

    local enrageIDs = {
        [12880] = true, --enrage
        [18499] = true, --berserker rage
    }
    local enrage_name = GetSpellInfo(12880)
    local RB_ID = 85288
    local enrage_opts = NugRunningConfig[RB_ID]
    NugRunningConfig[RB_ID] = nil

    local enrage_timer
    local enrage_frame = CreateFrame("Frame")
    enrage_frame.CheckFury = function(self)
        if IsSpellKnown(23881) then -- Bloodthirst, Raging Blow becomes known only after event is fired
            self:RegisterEvent("UNIT_AURA")
        else
            self:UnregisterEvent("UNIT_AURA")
            if enrage_timer then
                active[enrage_timer] = nil
                enrage_timer:Hide()
                NugRunning:ArrangeTimers()
            end
        end
    end

    enrage_frame:SetScript("OnEvent",function(self, event, unit)
        if event == "ACTIVE_TALENT_GROUP_CHANGED" or event == "PLAYER_TALENT_UPDATE" then
            return self:CheckFury()
        end
        if unit ~= "player" then return end
        local longest = 0
        local longestDuration
        for i=1, 100 do
            local _,_,_,_,_, duration, expires, _,_,_, spellID = UnitAura("player",i,"HELPFUL")
            if not spellID then break end
            if enrageIDs[spellID] then
                if expires > longest then
                    longest = expires
                    longestDuration = duration
                end
            end
        end
        
        if longest > 0 then
            if not enrage_timer then
                enrage_timer = NugRunning:ActivateTimer(UnitGUID("player"), UnitGUID("player"),
                                 UnitName("plyer"), nil,
                                 12880, enrage_name, enrage_opts, "BUFF")
                enrage_timer.dontfree = true
            end
            if not enrage_timer then return end
            active[enrage_timer] = true
            enrage_timer.dstGUID = UnitGUID("target")
            enrage_timer:SetTime(longest - longestDuration, longest)
            enrage_timer:SetAlpha(1)
            enrage_timer:Show()
            NugRunning:ArrangeTimers()
        elseif enrage_timer then
            active[enrage_timer] = nil
            enrage_timer:Hide()
            NugRunning:ArrangeTimers()
        end
    end)

    hooksecurefunc(NugRunning,"PLAYER_LOGIN",function(self,event)
        enrage_frame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
        enrage_frame:RegisterEvent("PLAYER_TALENT_UPDATE")
        enrage_frame:CheckFury()
    end)

end
]]


if class == "WARLOCK" then

local active = NugRunning.active
local free = NugRunning.free

local spellIDs = {
    [1120] = true
}
local spell = NugRunningConfig[1120]
NugRunningConfig[1120] = nil
if not spell then return end
spell.id = 1120


hooksecurefunc(NugRunning,"PLAYER_LOGIN",function(self,event)
    spell.timer = NugRunning:ActivateTimer(UnitGUID("player"), UnitGUID("player"), UnitName("player"), nil, spell.id, GetSpellInfo(spell.id), spell, "DEBUFF")
    spell.timer:Hide()
    active[spell.timer] = nil
    spell.timer.dontfree = true
end)

local faketimer = {}
faketimer.filter = "HARMFUL" --|PLAYER"
faketimer.fixedoffset = 0
faketimer.opts = {}
faketimer.spellID = 1120
faketimer.SetTime = function(self,s,e)
    spell.fullduration = e - s
    spell.ticktime = spell.fullduration / 6
    spell.timer:SetTime(s,s+spell.ticktime)
    active[spell.timer] = true
    spell.timer:Show()
    NugRunning:ArrangeTimers()
end
faketimer.SetCount = function() end
local t1, realTickTime

hooksecurefunc(NugRunning,"COMBAT_LOG_EVENT_UNFILTERED",
function( self, event, timestamp, eventType, hideCaster,
            srcGUID, srcName, srcFlags, srcFlags2,
            dstGUID, dstName, dstFlags, dstFlags2,
            spellID, spellName, spellSchool, auraType, amount)
    if spellIDs[spellID] then
        local isSrcPlayer = (bit.band(srcFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) == COMBATLOG_OBJECT_AFFILIATION_MINE)
        if isSrcPlayer and dstGUID ~= srcGUID then
            if eventType == "SPELL_AURA_APPLIED" then
                spell.timer.dstGUID = dstGUID
                spell.timer.dstName = dstName
                NugRunning.QueueAura(spellID, dstGUID, auraType, faketimer )
                spell.ticks = 6
                t1 = GetTime()
                realTickTime = nil
            elseif eventType == "SPELL_PERIODIC_DAMAGE" then
                local now = GetTime()
                if not realTickTime then realTickTime = now - t1 end
                spell.timer:SetTime(now, now + realTickTime)
                NugRunning:ArrangeTimers()
            elseif eventType == "SPELL_AURA_REMOVED" then
                active[spell.timer] = nil
                spell.timer:Hide()
                NugRunning:ArrangeTimers()
            end
        end
    end
end)

end