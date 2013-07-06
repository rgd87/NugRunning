local class = select(2,UnitClass("player"))


local active = NugRunning.active
local free = NugRunning.free
local UnitGUID = UnitGUID

-- if class == "WARRIOR" then
--     local overpower_id = 7384
--     local op_opts = NugRunningConfig[overpower_id]
--     NugRunningConfig[overpower_id] = nil

--     local op_timer
--     local op_frame = CreateFrame("Frame")
--     local old = false
--     --[[op_frame.CheckFury = function(self)
--         if IsSpellKnown(23881) then -- Bloodthirst, Raging Blow becomes known only after event is fired
--             self:RegisterEvent("UNIT_AURA")
--         else
--             self:UnregisterEvent("UNIT_AURA")
--             if enrage_timer then
--                 active[enrage_timer] = nil
--                 enrage_timer:Hide()
--                 NugRunning:ArrangeTimers()
--             end
--         end
--     end]]

--     op_frame:SetScript("OnEvent",function(self, event, unit, spellName, rank, lineID, spellID)
--         -- if event == "ACTIVE_TALENT_GROUP_CHANGED" or event == "PLAYER_TALENT_UPDATE" then
--         --    return self:CheckFury()
--         --end
--         if event == "UNIT_SPELLCAST_SUCCEEDED" then
--             if unit ~= "player" then return end
--             if spellID == 12294 then -- Mortal Strike
--                  if op_timer and active[op_timer] then
--                     NugRunning:RefreshTimer(UnitGUID("player"), UnitGUID("player"),
--                                          UnitName("plyer"), nil,
--                                          overpower_id, GetSpellInfo(overpower_id), op_opts, "BUFF" )
--                 end
--             end
--         else -- SPELL_UPDATE_USABLE
--             local new = IsUsableSpell(overpower_id)
--             if new ~= old then
--                 old = new
--                 if new then
--                         op_timer = NugRunning:ActivateTimer(UnitGUID("player"), UnitGUID("player"),
--                                          UnitName("plyer"), nil,
--                                          overpower_id, GetSpellInfo(overpower_id), op_opts, "BUFF")
--                 else
--                     NugRunning:DeactivateTimer(UnitGUID("player"), UnitGUID("player"), overpower_id,  GetSpellInfo(overpower_id), op_opts, "BUFF")
--                 end
--             end
--         end
--     end)

--     hooksecurefunc(NugRunning,"PLAYER_LOGIN",function(self,event)
--         --[[op_frame:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
--         op_frame:RegisterEvent("PLAYER_TALENT_UPDATE")
--         op_frame:CheckFury()]]
--         op_frame:RegisterEvent"SPELL_UPDATE_USABLE"
--         op_frame:RegisterEvent"UNIT_SPELLCAST_SUCCEEDED"
--     end)

-- end

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


-- if class == "WARLOCK" then

-- local active = NugRunning.active
-- local free = NugRunning.free

-- local spellIDs = {
--     [1120] = true
-- }
-- local spell = NugRunningConfig[1120]
-- NugRunningConfig[1120] = nil
-- if not spell then return end
-- spell.id = 1120


-- hooksecurefunc(NugRunning,"PLAYER_LOGIN",function(self,event)
--     spell.timer = NugRunning:ActivateTimer(UnitGUID("player"), UnitGUID("player"), UnitName("player"), nil, spell.id, GetSpellInfo(spell.id), spell, "DEBUFF")
--     spell.timer:Hide()
--     active[spell.timer] = nil
--     spell.timer.dontfree = true
-- end)

-- local faketimer = {}
-- faketimer.filter = "HARMFUL" --|PLAYER"
-- faketimer.fixedoffset = 0
-- faketimer.opts = {}
-- faketimer.spellID = 1120
-- faketimer.SetTime = function(self,s,e)
--     spell.fullduration = e - s
--     spell.ticktime = spell.fullduration / 6
--     spell.timer:SetTime(s,s+spell.ticktime)
--     active[spell.timer] = true
--     spell.timer:Show()
--     NugRunning:ArrangeTimers()
-- end
-- faketimer.SetCount = function() end
-- local t1, realTickTime

-- hooksecurefunc(NugRunning,"COMBAT_LOG_EVENT_UNFILTERED",
-- function( self, event, timestamp, eventType, hideCaster,
--             srcGUID, srcName, srcFlags, srcFlags2,
--             dstGUID, dstName, dstFlags, dstFlags2,
--             spellID, spellName, spellSchool, auraType, amount)
--     if spellIDs[spellID] then
--         local isSrcPlayer = (bit.band(srcFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) == COMBATLOG_OBJECT_AFFILIATION_MINE)
--         if isSrcPlayer and dstGUID ~= srcGUID then
--             if eventType == "SPELL_AURA_APPLIED" then
--                 spell.timer.dstGUID = dstGUID
--                 spell.timer.dstName = dstName
--                 NugRunning.QueueAura(spellID, dstGUID, auraType, faketimer )
--                 spell.timer.powerLevel = NugRunning:GetPowerLevel()
--                 spell.ticks = 6
--                 spell.timer:SetCount(spell.ticks)
--                 t1 = GetTime()
--                 realTickTime = nil
--             elseif eventType == "SPELL_PERIODIC_DAMAGE" then
--                 local now = GetTime()
--                 if not realTickTime then realTickTime = now - t1 end
--                 spell.timer:SetTime(now, now + realTickTime)
--                 spell.ticks = spell.ticks -1
--                 spell.timer:SetCount(spell.ticks)
--                 NugRunning:ArrangeTimers()
--             elseif eventType == "SPELL_AURA_REMOVED" then
--                 active[spell.timer] = nil
--                 spell.timer:Hide()
--                 NugRunning:ArrangeTimers()
--             end
--         end
--     end
-- end)

-- end