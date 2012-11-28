--[================[
LibScouter-1.0 
Vegeta, what does the scouter say about his power level?
Caclulates a single value of spell damage/attack power equivalent from other stats and buffs

Usage:
    local Scouter = LibStub("LibScouter-1.0")
    print(Scouter:GetPowerLevel())
    Scouter.RegisterCallback(self, "POWER_LEVEL_CHANGED", function(event, plevel)
        print(event, plevel)
    end)
--]================]


local MAJOR, MINOR = "LibScouter-1.0", 1
local lib = LibStub:NewLibrary(MAJOR, MINOR)
if not lib then return end


lib.callbacks = lib.callbacks or LibStub("CallbackHandler-1.0"):New(lib)
lib.frame = lib.frame or CreateFrame("Frame")

lib.data = lib.data or {}

local f = lib.frame
local callbacks = lib.callbacks

-- local RatingCoefs = {
--     parry = 880,
--     dodge = 880,
--     mastery = 600.00000,
--     crit = 600.00000,
--     haste = 425,
--     expertise = 340.00000,
--     hit = 340.00000,
-- }

local classSpecs = {}
local class = select(2,UnitClass("player"))
if      class == "WARLOCK" then
    classSpecs = {
        [1] = { --Affliction
            powerType = "SPELL",
            haste = 0.695, -- That's a scaling factors relative to spell damage or attack power (not Intellect)
            crit = 0.475,  -- They're calculated from stat weights on wowhead, which are complete bullshit very often
            mastery = 0.75,-- So... now you know.
            main = 0.8,--How spellpower or attack power compares to main stat (int, str, agi)
            buffs = {},
        },
        [2] = { --Demonology
            powerType = "SPELL",
            haste = 0.5,
            crit = 0.5,
            mastery = 0.54,
            main = 0.8,
            buffs = {},
        },
        [3] = { --Destruction
            powerType = "SPELL",
            haste = 0.57,
            crit = 0.53,
            mastery = 0.50,
            main = 0.8,
            buffs = {},
        },
    }
elseif  class == "WARRIOR" then
    classSpecs = {
        [1] = { --Arms
            powerType = "MELEE",
            haste = 0.673,
            crit = 1.142,
            mastery = 0.897,
            main = 0.5,
            buffs = {},
        },
        [2] = { --Fury
            powerType = "MELEE",
            haste = 0.51,
            crit = 1.55,
            mastery = 0.72,
            main = 0.5,
            buffs = {},
        },
        [3] = { --Protection
            powerType = "MELEE",
            haste = 0.1,
            crit = 0.5,
            mastery = 0.1,
            main = 0.5,
            buffs = {},
        },
    }
elseif  class == "PRIEST" then
    classSpecs = {
        [1] = { --Discipline
            powerType = "SPELL",
            haste = 0.62,
            crit = 0.74,
            mastery = 0.68,
            main = 0.8,
            buffs = {},
        },
        [2] = { --Holy
            powerType = "SPELL",
            haste = 0.76,
            crit = 0.50,
            mastery = 0.63,
            main = 0.8,
            buffs = {},
        },
        [3] = { --Shadow
            powerType = "SPELL",
            haste = 0.76,
            crit = 0.60,
            mastery = 0.50,
            main = 0.8,
            buffs = {},
        },
    }
end

-------------------------------------
-- BasePower functions
-------------------------------------
function lib.GetBaseSpellPower()
    return GetSpellBonusDamage(2) -- 2 = holy school
end
function lib.GetBaseMeleePower()
    local base, posBuff, negBuff = UnitAttackPower("player")
    return base+posBuff+negBuff
end
function lib.GetBaseRangedPower()
    local base, posBuff, negBuff = UnitRangedAttackPower("player")
    return base+posBuff+negBuff
end
--- BaseHaste ------------------------
function lib.GetBaseSpellHaste()
    return UnitSpellHaste("player") -- 2 = holy school
end
function lib.GetBaseMeleeHaste()
    return GetMeleeHaste()
end
function lib.GetBaseRangedHaste()
    return GetRangedHaste()
end
--- BaseCrit ------------------------
function lib.GetBaseSpellCrit()
    return GetSpellCritChance(2)
end
function lib.GetBaseMeleeCrit()
    return GetCritChance()
end
function lib.GetBaseRangedCrit()
    return GetRangedCritChance()
end
--- BaseMastery ------------------------
function lib.GetBaseMastery()
    local mastery, bonusCoeff = GetMasteryEffect();
    -- local masteryBonus = GetCombatRatingBonus(CR_MASTERY) * bonusCoeff;
    return mastery
end
--- Damage Multiplier ---------------
function lib.GetDamageMultiplier()
    local minDamage, maxDamage, minOffHandDamage, maxOffHandDamage, physicalBonusPos, physicalBonusNeg, percent = UnitDamage("player")
    return percent
end


local GetPower = lib.GetBaseSpellPower
local GetHaste = lib.GetBaseSpellHaste
local GetCrit = lib.GetBaseSpellCrit
local GetMastery = lib.GetBaseMastery
local GetMul = lib.GetDamageMultiplier
local weightCrit, weightHaste, weightMastery = .6, .6, .6
local mainStatRatio = 0.5


function lib:SetupForSpec(spec)
    if spec.powerType == "SPELL" then
        GetPower = lib.GetBaseSpellPower
        GetCrit = lib.GetBaseSpellCrit
        GetHaste = lib.GetBaseSpellHaste
    elseif spec.powerType == "MELEE" then
        GetPower = lib.GetBaseMeleePower
        GetCrit = lib.GetBaseMeleeCrit
        GetHaste = lib.GetBaseMeleeHaste
    elseif spec.powerType == "RANGED" then
        GetPower = lib.GetBaseRangedPower
        GetCrit = lib.GetBaseRangedCrit
        GetHaste = lib.GetBaseRangedHaste
    end
    weightCrit = spec.crit
    weightHaste = spec.haste
    weightMastery = spec.mastery
    mainStatRatio = spec.main
end

local function GetHasteScaling()
    return 1 + (GetHaste()/100 * weightHaste)
end
local function GetCritScaling()
    return 1 + (GetCrit()/100 * weightCrit)
end
local function GetMasteryScaling()
    return 1 + (GetMastery()/100 * weightMastery)
end

function lib:GetPowerLevel(nomul)
    local base = GetPower()
    local haste = GetHasteScaling()
    local crit = GetCritScaling()
    local mastery = GetMasteryScaling()
    local mul = nomul and 1 or GetMul()
    -- print("base", base, "haste", haste, "crit", crit, "mastery", mastery)
    return math.floor(base*haste*crit*mastery*mul*mainStatRatio)
end

local previousPowerLevel
local QueuedUpdate = function(self)
    self:SetScript("OnUpdate", nil)
    local pl = lib:GetPowerLevel()
    if pl ~= previousPowerLevel then
        previousPowerLevel = pl
        callbacks:Fire("POWER_LEVEL_CHANGED", pl)
    end
end

function callbacks.OnUsed()
    -- print("OnUsed")
    lib.frame:RegisterEvent("SPELLS_CHANGED")
    lib.OnEvent(lib.frame, "SPELLS_CHANGED")
end

function callbacks.OnUnused()
    -- print("OnUnused")
    lib.frame:UnregisterAllEvents()
end

-- f:RegisterEvent("SPELLS_CHANGED")
lib.OnEvent = function(self, event, ...)
    -- print(event)
    if event == "SPELLS_CHANGED" then
        local spec = GetSpecialization()
        local specData = classSpecs[spec]
        if specData then
            lib:SetupForSpec(specData)
            -- self:RegisterUnitEvent("UNIT_LEVEL", "player");
            self:RegisterUnitEvent("UNIT_STATS", "player");
            self:RegisterUnitEvent("UNIT_RANGEDDAMAGE", "player");
            self:RegisterUnitEvent("UNIT_ATTACK_POWER", "player");
            self:RegisterUnitEvent("UNIT_RANGED_ATTACK_POWER", "player");
            self:RegisterUnitEvent("UNIT_ATTACK", "player");
            self:RegisterUnitEvent("UNIT_SPELL_HASTE", "player");
            self:RegisterUnitEvent("UNIT_DAMAGE", "player");
            self:RegisterUnitEvent("UNIT_ATTACK_SPEED", "player");
            self:RegisterUnitEvent("UNIT_MAXHEALTH", "player");
            self:RegisterUnitEvent("UNIT_AURA", "player");
            self:RegisterEvent("SPELL_POWER_CHANGED");
            self:RegisterEvent("SKILL_LINES_CHANGED");
            self:RegisterEvent("COMBAT_RATING_UPDATE");
            self:RegisterEvent("MASTERY_UPDATE");
            self:RegisterEvent("BAG_UPDATE")
            self:SetScript("OnUpdate", QueuedUpdate)
        else
            self:UnregisterAllEvents()
            self:RegisterEvent("SPELLS_CHANGED")
        end
    else
        self:SetScript("OnUpdate", QueuedUpdate)
    end
end
f:SetScript("OnEvent", lib.OnEvent)