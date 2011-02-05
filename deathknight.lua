-- Special DK sauce
local class = select(2,UnitClass("player"))
if class  ~= "DEATHKNIGHT" and class ~= "WARRIOR" then return end

local infect
local active = NugRunning.active
local free = NugRunning.free
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
if class  == "WARRIOR" then
    local rend = { id = 94009 }
    rend.name = GetSpellInfo(rend.id)
    rend.opts = NugRunningConfig[rend.id]
    NugRunningConfig[rend.id] = nil
    
    infect = { rend }
end
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