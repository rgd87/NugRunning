local class = select(2,UnitClass("player"))


local active = NugRunning.active
local free = NugRunning.free

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
        
        local SF = { id = 81130 }
        SF.name = GetSpellInfo(SF.id)
        SF.opts = NugRunningConfig[SF.id]
        NugRunningConfig[SF.id] = nil
        
        infect = { FF, BP, SF }
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
