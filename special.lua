local _, helpers = ...

local NugRunning = NugRunning
local class = select(2,UnitClass("player"))


local active = NugRunning.active
local free = NugRunning.free
local gettimer = NugRunning.gettimer
local UnitGUID = UnitGUID
local bit_band = bit.band
local CombatLogGetCurrentEventInfo = CombatLogGetCurrentEventInfo
local AFFILIATION_MINE = COMBATLOG_OBJECT_AFFILIATION_MINE

local function Overpower()

    local INVSLOT_OFFHAND = INVSLOT_OFFHAND
    local function IsShieldEquipped()
        local itemLink = GetInventoryItemLink("player", INVSLOT_OFFHAND)
        if itemLink then
            local _, _, _, itemEquipLoc = GetItemInfoInstant(itemLink)
            return itemEquipLoc == "INVTYPE_SHIELD"
        end
    end

    local IsInBattleStance = function() return GetShapeshiftForm() == 1 end

    local function OnDodge()
        if not IsShieldEquipped() or IsInBattleStance() then
            local spellID = 7384
            local playerGUID = UnitGUID("player")
            local timer = gettimer(active,spellID, playerGUID, "COOLDOWN")
            if timer then
                timer.scheduledGhost = 5
            end
            NugRunning:SPELL_ACTIVATION_OVERLAY_GLOW_SHOW(nil, 7384)
        end
    end
    
    local function OnSpent()
        NugRunning:SPELL_ACTIVATION_OVERLAY_GLOW_HIDE(nil, 7384)
    end

    local f = CreateFrame("Frame", nil)
    f:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    f:SetScript("OnEvent", function(self, event)
        local timestamp, eventType, hideCaster,
        srcGUID, srcName, srcFlags, srcFlags2,
        dstGUID, dstName, dstFlags, dstFlags2,
        arg1, arg2, arg3, arg4 = CombatLogGetCurrentEventInfo()

        if (bit_band(srcFlags, AFFILIATION_MINE) == AFFILIATION_MINE) then
            if eventType == "SWING_MISSED" or eventType == "SPELL_MISSED" then
                local missedType
                if eventType == "SWING_MISSED" then
                    missedType = arg1
                elseif eventType == "SPELL_MISSED" then
                    missedType = arg4
                end
                if missedType == "DODGE" then
                    -- print("----------------->DODGED", eventType, "from", srcName, bit_band(srcFlags, AFFILIATION_MINE) == AFFILIATION_MINE)
                    OnDodge()
                end

            end

            if arg1 == 7384 and eventType == "SPELL_CAST_SUCCESS" then
                OnSpent()
            end
        end
    end)
end

function NugRunning.SetupSpecialTimers()
    if class  == "WARRIOR" then
        Overpower()
    end
end
