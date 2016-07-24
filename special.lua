local class = select(2,UnitClass("player"))


local active = NugRunning.active
local free = NugRunning.free
local UnitGUID = UnitGUID

if class  == "WARRIOR" then

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
        end)

        rampage_frame:RegisterEvent("SPELLS_CHANGED")
        rampage_frame:CheckFury()

    end)

end


if class == "WARLOCK" then

    hooksecurefunc(NugRunning,"PLAYER_LOGIN",function(self,event)

        local cf = CreateFrame"Frame"

        local corruptionID = 146739
        local corruptionName = GetSpellInfo(corruptionID)
        local corruption_opts = NugRunningConfig[corruptionID]
        if not corruption_opts then return end
        NugRunningConfig[corruptionID] = nil

        local timer = NugRunning:CreateTimer()
        table.remove(NugRunning.timers)
        timer.stacktext:Hide()
        timer.bar:SetValue(100)
        timer:SetScript("OnUpdate",nil)
        timer.dstGUID = UnitGUID("player")
        timer.srcGUID = UnitGUID("player")
        timer.startTime = 0
        timer.endTime = 1
        timer.dontfree = true
        timer.priority = corruption_opts.priority
        timer:VScale(0.5)
        timer.opts = { name = corruption_opts.name, color = corruption_opts.color }

        -- timer:ToInfinite()
        timer:UpdateMark()
        timer:SetCount(1)
        local texture = GetSpellTexture(corruptionID)
        timer:SetIcon(texture)
        timer:SetColor(unpack(corruption_opts.color))


        cf:RegisterEvent("SPELLS_CHANGED")
        -- cf:RegisterEvent("PLAYER_REGEN_DISABLED")


        local function IsAbsolutelyCorrupted(unit)
            if not UnitExists("target") then return false end
            local name = UnitAura(unit, corruptionName, nil, "HARMFUL|PLAYER")
            if name then return true end
        end

        cf:SetScript("OnEvent", function(self, event)
            if event == "SPELLS_CHANGED" then
                if IsPlayerSpell(196103) then
                    NugRunningConfig[corruptionID] = nil
                    cf:RegisterUnitEvent("UNIT_AURA", "target")
                    cf:RegisterEvent("PLAYER_TARGET_CHANGED")
                else
                    NugRunning.active[timer] = nil
                    timer:Hide()
                    cf:UnregisterEvent("UNIT_AURA")
                    cf:UnregisterEvent("PLAYER_TARGET_CHANGED")

                    NugRunningConfig[corruptionID] = corruption_opts
                end
            elseif event == "PLAYER_TARGET_CHANGED" or event == "UNIT_AURA" then
                if IsAbsolutelyCorrupted("target") then
                    timer.dstGUID = UnitGUID("target")
                    if not NugRunning.active[timer] then
                        timer:Show()
                        NugRunning.active[timer] = true
                    end
                else
                    NugRunning.active[timer] = nil
                    timer:Hide()
                end
                NugRunning:ArrangeTimers()
            -- elseif event == "PLAYER_REGEN_DISABLED" then
                -- local a = 1
            end
        end)

    end)

--     spell.timer = NugRunning:ActivateTimer(UnitGUID("player"), UnitGUID("player"), UnitName("player"), nil, spell.id, GetSpellInfo(spell.id), spell, "DEBUFF")
--     spell.timer:Hide()
--     active[spell.timer] = nil
--     spell.timer.dontfree = true
end

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
