-- Special DK sauce
local class = select(2,UnitClass("player"))
if class  == "DEATHKNIGHT" or class == "WARRIOR"then

local TrackSpells = NugRunningConfig
local infect
if class  == "DEATHKNIGHT" then
    local FF = { id = 55095 }
    local BP = { id = 55078 }
    FF.name = GetSpellInfo(FF.id)
    BP.name = GetSpellInfo(BP.id)
    --FF.opts = setmetatable({ multiTarget = false, group = false, onrefresh = false, name = "FF"}, { __index = function(t,k) return TrackSpells[FF.id][k] end })
    --BP.opts = setmetatable({ multiTarget = false, group = false, onrefresh = false, name = "BP"}, { __index = function(t,k) return TrackSpells[BP.id][k] end })
    FF.opts = TrackSpells[FF.id]
    BP.opts = TrackSpells[BP.id]
    TrackSpells[BP.id] = nil
    TrackSpells[FF.id] = nil
    
    infect = { FF, BP }
end
if class  == "WARRIOR" then
    local rend = { id = 94009 }
    rend.name = GetSpellInfo(rend.id)
    rend.opts = TrackSpells[rend.id]
    TrackSpells[rend.id] = nil
    
    infect = { rend }
end



local dismon_onevent = function(self, event, unit)
    if unit and unit ~= "target" then return end
    for _, spell in ipairs(infect) do
        local _, _, _, _, _, duration, expirationTime = UnitAura("target",spell.name, nil,"HARMFUL|PLAYER")
        if duration then
            if spell.timer and ( spell.timer.spellID ~= spell.id or not spell.timer:IsVisible() ) then spell.timer = nil end
            if not spell.timer then
                spell.timer = NugRunning:ActivateTimer(UnitGUID("player"), UnitGUID("target"), UnitName("target"), nil, spell.id, spell.name, spell.opts, "DEBUFF")
            end
            if not spell.timer then return end
            spell.timer.dstGUID = UnitGUID("target")
            spell.timer.endTime = expirationTime
            spell.timer.startTime = expirationTime - duration
            spell.timer.bar:SetMinMaxValues(spell.timer.startTime,spell.timer.endTime)
            spell.timer:SetAlpha(1)
--~             NugRunning:ArrangeTimers()
        else
            if spell.timer and spell.timer.id == spell.id then
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