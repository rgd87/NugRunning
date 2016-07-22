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

if class  == "WARRIOR" then

    -- local enrageIDs = {
    --     [12880] = true, --enrage
    --     [18499] = true, --berserker rage
    -- }
    -- local enrage_name = GetSpellInfo(12880)
    -- local RB_ID = 85288

    hooksecurefunc(NugRunning,"PLAYER_LOGIN",function(self,event)
        local rampageID = 184367
        local rampage_opts = NugRunningConfig[rampageID]
        if not rampage_opts then return end
        local rampageCost = 85
        NugRunningConfig[rampageID] = nil

        local timer = NugRunning:CreateTimer()
        table.remove(NugRunning.timers)
        timer.stacktext:Hide()
        timer:SetScript("OnUpdate",nil)
        timer.unit = "player"
        timer.dstGUID = UnitGUID("player")
        timer.srcGUID = UnitGUID("player")
        timer.dontfree = true
        timer.priority = rampage_opts.priority
        timer.opts = rampage_opts

        -- local timer = f
        timer:ToInfinite()
        timer:UpdateMark()
        timer:SetCount(1)
        local texture = GetSpellTexture(rampageID)
        timer:SetIcon(texture)
        timer:SetColor(unpack(rampage_opts.color))


        local lastPositiveUpdate = 0
        local lastRageValue = UnitPower("player")


        local rampage_frame = CreateFrame("Frame")
        rampage_frame.timer = f
        rampage_frame.CheckFury = function(self)
            if GetSpecialization() == 2 and IsPlayerSpell(184367) then
                rampageCost = IsPlayerSpell(202922) and 70 or 85 -- carnage
                timer.bar:SetMinMaxValues(0, rampageCost)
                self:RegisterEvent("UNIT_POWER_FREQUENT")
                self:RegisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_HIDE")
            else
                self:UnregisterEvent("UNIT_POWER_FREQUENT")
                self:UnregisterEvent("SPELL_ACTIVATION_OVERLAY_GLOW_HIDE")
                if timer then
                    active[timer] = nil
                    timer:Hide()
                    NugRunning:ArrangeTimers()
                end
            end
        end

        rampage_frame:SetScript("OnUpdate", function(self, time)
            self._elapsed = (self._elapsed or 0) + time
            if self._elapsed < 0.2 then return end
            self._elapsed = 0

            if lastPositiveUpdate + 5 < GetTime() and UnitPower("player") ~= UnitPowerMax("player") then
                NugRunning.active[timer] = nil
                timer:Hide()
                NugRunning:ArrangeTimers()
                self:Hide()
            end
        end)

        rampage_frame:SetScript("OnEvent",function(self, event, unit)
            if event == "SPELLS_CHANGED" then
                return self:CheckFury()
            end

            if event == "SPELL_ACTIVATION_OVERLAY_GLOW_HIDE" and unit == rampageID then
                if timer.shine:IsPlaying() then timer.shine:Stop() end
                if timer.glow:IsPlaying() then timer.glow:Stop() end
                -- timer:VScale(0.6)
                timer.bar:SetValue(100)
                timer:SetColor(unpack(rampage_opts.color))
            end

            if unit ~= "player" then return end

            local rage = UnitPower("player")
            if lastRageValue < rage then
                lastPositiveUpdate = GetTime()
                self:Show() -- show rampage_frame and start it's on update loop

                local p = rampageCost-UnitPower("player")

                -- if p > 20 then
                --     timer:VScale(0.6)
                -- else
                --     timer:VScale(1)
                -- end
    
                if p <= 0 then
                    if not timer.shine:IsPlaying() then timer.shine:Play() end
                    if not timer.glow:IsPlaying() then timer.glow:Play() end
                    timer.bar:SetValue(100)
                    timer:SetColor(unpack(rampage_opts.color2))
                else
                    if timer.shine:IsPlaying() then timer.shine:Stop() end
                    if timer.glow:IsPlaying() then timer.glow:Stop() end
                    timer.bar:SetValue(p)
                    timer:SetColor(NugRunning.GetGradientColor(rampage_opts.color2, rampage_opts.color, (p/rampageCost)^0.7 ))
                end

                if not NugRunning.active[timer] then
                    timer:Show()
                    NugRunning.active[timer] = true
                    NugRunning:ArrangeTimers()
                end
            end
            lastRageValue = rage

            -- NugRunning.active[timer] = true
            -- NugRunning:ArrangeTimers()
            -- if longest > 0 then
            --     if not enrage_timer then
            --         timer = NugRunning:ActivateTimer(UnitGUID("player"), UnitGUID("player"),
            --                          UnitName("plyer"), nil,
            --                          12880, rampage_name, rampage_opts, "BUFF")
            --         timer.dontfree = true
            --     end
            --     if not timer then return end
            --     active[timer] = true
            --     timer.dstGUID = UnitGUID("target")
            --     timer:SetTime(longest - longestDuration, longest)
            --     timer:SetAlpha(1)
            --     timer:Show()
            --     NugRunning:ArrangeTimers()
            -- elseif timer then
            --     active[timer] = nil
            --     timer:Hide()
            --     NugRunning:ArrangeTimers()
            -- end
        end)

        rampage_frame:RegisterEvent("SPELLS_CHANGED")
        rampage_frame:CheckFury()

    end)

end


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