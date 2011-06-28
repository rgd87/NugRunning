if select(2,UnitClass("player")) ~= "WARLOCK" then return end

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
faketimer.filter = "HARMFUL|PLAYER"
faketimer.fixedoffset = 0
faketimer.opts = {}
faketimer.SetTime = function(self,s,e)
    spell.fullduration = e - s
    spell.ticktime = spell.fullduration / 5
    spell.timer:SetTime(s,s+spell.ticktime)
    active[spell.timer] = true
    spell.timer:Show()
    NugRunning:ArrangeTimers()
end

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
                spell.ticks = 5
            elseif eventType == "SPELL_PERIODIC_DAMAGE" then
                local now = GetTime()
                spell.timer:SetTime(now, now+spell.ticktime)
                NugRunning:ArrangeTimers()
            elseif eventType == "SPELL_AURA_REMOVED" then
                active[spell.timer] = nil
                spell.timer:Hide()
                NugRunning:ArrangeTimers()
            end
        end
    end
end)
