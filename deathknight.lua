-- Special DK sauce
if select(2,UnitClass("player")) == "DEATHKNIGHT" then

local TrackSpells = NugRunningConfig
local FF = { id = 55095 }
local BP = { id = 55078 }
FF.name = GetSpellInfo(FF.id)
BP.name = GetSpellInfo(BP.id)
--~ FF.opts = setmetatable({ multiTarget = false, group = false, onrefresh = false, name = "FF"}, { __index = function(t,k) return TrackSpells[FF.id][k] end })
--~ BP.opts = setmetatable({ multiTarget = false, group = false, onrefresh = false, name = "BP"}, { __index = function(t,k) return TrackSpells[BP.id][k] end })
local FFBP = { FF, BP }
FF.opts = TrackSpells[FF.id]
BP.opts = TrackSpells[BP.id]
TrackSpells[BP.id] = nil
TrackSpells[FF.id] = nil

local dismon_onevent = function(self, event, unit)
    if unit and unit ~= "target" then return end
    for _, spell in ipairs(FFBP) do
        local _, _, _, _, _, duration, expirationTime = UnitAura("target",spell.name, nil,"HARMFUL|PLAYER")
        if duration then
            if not spell.timer then
                spell.timer = spell.timer or NugRunning:ActivateTimer(UnitGUID("player"), UnitGUID("target"), UnitName("target"), nil, spell.id, spell.name, spell.opts, "DEBUFF")
            end
            if not spell.timer then return end
            spell.timer.dstGUID = UnitGUID("target")
            spell.timer.endTime = expirationTime
            spell.timer.startTime = expirationTime - duration
            spell.timer.bar:SetMinMaxValues(spell.timer.startTime,spell.timer.endTime)
            spell.timer:SetAlpha(1)
--~             NugRunning:ArrangeTimers()
        else
            if spell.timer then
            spell.timer.active = false
            spell.timer:Hide()
            spell.timer = nil
            NugRunning:ArrangeTimers()
            end
        end
    end
end
local DisMon = CreateFrame("Frame",nil,UIParent)
DisMon:RegisterEvent("UNIT_AURA")
DisMon:RegisterEvent("PLAYER_TARGET_CHANGED")
DisMon:SetScript("OnEvent", dismon_onevent)


end