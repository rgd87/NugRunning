-----------------------------------------------------------------------------------
-- It's a better idea to edit userconfig.lua in NugRunningUserConfig addon folder
-- CONFIG GUIDE: https://github.com/rgd87/NugRunning/wiki/NugRunningUserConfig
-----------------------------------------------------------------------------------
local _, helpers = ...
local Spell = helpers.Spell
local ModSpell = helpers.ModSpell
local Cooldown = helpers.Cooldown
local Activation = helpers.Activation
local EventTimer = helpers.EventTimer
local Anchor = helpers.Anchor
local Talent = helpers.Talent
local Glyph = helpers.Glyph
local GetCP = helpers.GetCP
local _,class = UnitClass("player")

NugRunningConfig.texture = "Interface\\AddOns\\NugRunning\\statusbar"
NugRunningConfig.nameFont = { font = "Interface\\AddOns\\NugRunning\\Calibri.ttf", size = 10, alpha = 0.5 }
NugRunningConfig.timeFont = { font = "Interface\\AddOns\\NugRunning\\Calibri.ttf", size = 8, alpha = 1 }
NugRunningConfig.stackFont = { font = "Interface\\AddOns\\NugRunning\\Calibri.ttf", size = 12 }
NugRunningConfig.dotpowerFont = { font = "Interface\\AddOns\\NugRunning\\Calibri.ttf", size = 8, alpha = .6 }

NugRunningConfig.nameplates.width = 70
NugRunningConfig.nameplates.height = 7
NugRunningConfig.nameplates.x_offset = 0
NugRunningConfig.nameplates.y_offset = 0

NugRunningConfig.anchors = {
    main = {
        { name = "player", gap = 10, alpha = 1 },
        { name = "target", gap = 10, alpha = 1},
        { name = "buffs", gap = 25, alpha = 1},
        { name = "offtargets", gap = 6, alpha = .7},
    },
    secondary = {
        { name = "procs", gap = 10, alpha = .8},
    },
}

NugRunningConfig.colors = {}
local colors = NugRunningConfig.colors
colors["RED"] = { 0.8, 0, 0}
colors["LRED"] = { 1,0.4,0.4}
colors["DRED"] = { 0.55,0,0}
colors["CURSE"] = { 0.6, 0, 1 }
colors["PINK"] = { 1, 0.3, 0.6 }
colors["PINKIERED"] = { 206/255, 4/256, 56/256 }
colors["TEAL"] = { 0.32, 0.52, 0.82 }
colors["TEAL2"] = {38/255, 221/255, 163/255}
colors["ORANGE"] = { 1, 124/255, 33/255 }
colors["FIRE"] = {1,80/255,0}
colors["LBLUE"] = {149/255, 121/255, 214/255}
colors["DBLUE"] = { 50/255, 34/255, 151/255 }
colors["GOLD"] = {1,0.7,0.5}
colors["LGREEN"] = { 0.63, 0.8, 0.35 }
colors["GREEN"] = {0.3, 0.9, 0.3}
colors["DGREEN"] = { 0, 0.35, 0 }
colors["PURPLE"] = { 187/255, 75/255, 128/255 }
colors["PURPLE2"] = { 188/255, 37/255, 186/255 }
colors["PURPLE3"] = { 64/255, 48/255, 109/255 }
colors["DPURPLE"] = {74/255, 14/255, 85/255}
colors["FROZEN"] = { 65/255, 110/255, 1 }
colors["CHILL"] = { 0.6, 0.6, 1}
colors["BLACK"] = {0.35,0.35,0.35}
colors["WOO"] = {151/255, 86/255, 168/255}
colors["WOO2"] = {80/255, 83/255, 150/255}
colors["WOO2DARK"] = {30/255, 30/255, 65/255}
colors["BROWN"] = { 192/255, 77/255, 48/255}
colors["DBROWN"] = { 118/255, 69/255, 50/255}
colors["MISSED"] = { .15, .15, .15}
colors["DEFAULT_DEBUFF"] = { 0.8, 0.1, 0.7}
colors["DEFAULT_BUFF"] = { 1, 0.4, 0.2}



local _, race = UnitRace("player")
if race == "Troll" then Spell( 26297 ,{ name = "Berserking", duration = 10 }) end --Troll Racial
if race == "Orc" then Spell({ 33702,33697,20572 },{ name = "Blood Fury", duration = 15 }) end --Orc Racial

Spell({2825, 32182, 80353} ,{ name = "Bloodlust", duration = 40, priority = -100, color = colors.DRED, shine = true, affiliation = "raid", target = "player" })

-- local CASTER_POTIONS = function(specmask)
--         Spell( 105702 ,{ name = "Potion", specmask = specmask, group = "procs", color = colors.GREEN, duration = 25 }) -- Intellect
--         Spell( 137592 ,{ name = "Tempus Repit", specmask = specmask, affiliation = "any", color = colors.ORANGE, target= "player", group = "procs", duration = 10 })
--         Spell( 104993 ,{ name = "Jade Spirit", specmask = specmask, affiliation = "any", color = colors.LGREEN, target= "player", group = "procs", duration = 10 })
--         Spell( 96230 ,{ name = "Springs", specmask = specmask, color = colors.LGREEN, group = "procs", duration = 10 })
--         Spell( 127923 ,{ name = "Trinket1", specmask = specmask, group = "procs", duration = 10 })
--         Spell( 126659 ,{ name = "Haste", specmask = specmask, group = "procs", duration = 20 }) -- Sha of Fear trinket
--         Spell( 138703 ,{ name = "Haste", specmask = specmask, group = "procs", duration = 10 }) -- 522 Valor trinker
--         Spell( 128985 ,{ name = "Relic of Yu'lon", specmask = specmask, color = colors.LGREEN, group = "procs", duration = 15 })
--         Spell( 104510 ,{ name = "WS: Mastery", specmask = specmask, group = "procs", duration = 10 })
--         Spell( 104509 ,{ name = "WS: Crit", specmask = specmask, group = "procs", duration = 10 })
--         Spell( 104423 ,{ name = "WS: Haste", specmask = specmask, group = "procs", duration = 10 })
-- end



if class == "WARLOCK" then
Spell( 74434 ,{ name = "Soulburn",duration = 20, color = colors.CURSE })
Spell( 111400 ,{ name = "Burning Rush",duration = 20, timeless = true, color = colors.PURPLE2 })
--I can't know for sure what base debuff duration was because of haste,
--so all values are just 1s less than 50% of base duration without haste to be safe
--Immolate
Spell( {348, 108686},{ name = "", tick = 3, overlay = {0, 6.5, 0.2}, showpower = true, duration = 15, nameplates = true, priority = 10, ghost = true, color = colors.RED })

Spell( 34936 ,{ name = "Backlash", duration = 8, shine = true, color = colors.CURSE })

local c1 = colors.DPURPLE
local c2 = colors.PURPLE2
local backdraft_stackcolor = { c1, c1, c2,c2,c2,c2}
Spell( 117828 ,{ name = "Backdraft", duration = 15, shine = true, priority = -4, shinerefresh = true, stackcolor = backdraft_stackcolor }) --, charged = true, maxcharge = 3


Spell( 104232 ,{ name = "Rain of Fire", duration = 8, priority = -5, shine = true, color = colors.PURPLE, target = "player" })
Spell( 80240 ,{ name = "Havoc", nameplates = true, duration = 15, color = colors.LRED, target = "player" })

Spell( 108683 ,{ name = "Fire and Brimstone", short = "FnB", timeless = true, color = colors.CURSE })
Cooldown( 17962, { name = "Conflagrate", ghost = true, priority = 5, color = colors.PINK })

Spell( 122355,{ name = "Molten Core",duration = 30, shine = true, color = colors.PURPLE })
--Doom
Spell( 603 ,{ name = "", duration = 60, tick = 15, overlay = {0,29, 0.2}, nameplates = true, showpower = true, ghost = true, priority = 6, color = colors.WOO })
-- REMOVED_DOSE event is not fired for molten core, so it's stuck at 3

Cooldown( 105174, { name = "Hand of Gul'dan",  ghost = true, shinerefresh = true, color = colors.CURSE })
-- Cooldown( 124916, { name = "Chaos Wave",  color = colors.CURSE })
-- Spell( 47960 ,{ name = "Shadowflame", duration = 6, multiTarget = true })

Spell( 104773,{ name = "Unending Resolve",duration = 12, color = colors.WOO2 })
Spell( 113860 ,{ name = "Dark Soul: Misery",duration = 20, short = "DarkSoul", color = colors.PINKIERED })
Spell( 113861 ,{ name = "Dark Soul: Knowledge",duration = 20, short = "DarkSoul", color = colors.PINKIERED })
Spell( 113858 ,{ name = "Dark Soul: Instability",duration = 20, short = "DarkSoul", color = colors.PINKIERED })

Spell( 86211 ,{ name = "Soul Swap", duration = 20, shine = true, color = colors.BLACK })
-- Spell( 17941 ,{ name = "Nightfall", duration = 10, shine = true, color = colors.CURSE })
Spell( 103103 ,{ name = "Malefic Grasp", tick = 1, overlay = {"tick", "tickend"}, showpower = true, priority = 14, duration = 4, color = colors.CURSE, target = "target" })
Spell( 1120 ,{ name = "Drain Soul", short = "", tick = 2, overlay = {"tick", "end"}, tickshine = true, target = "target", priority = 14, showpower = true, duration = 15, color = colors.CURSE })

--Haunt, recast mark is for execute phase. 3s is cast time + travel time from 30+yd range
local normalize_dots_to = nil--26
-- local haunt_overlay = {0,8, 0.15}
--Haunt
Spell( 48181 ,{ name = "",duration = 12, priority = 8, recast_mark = 3, ghost = true, nameplates = true, color = colors.TEAL })
-- 8s second overlay is for haunt duration
--Unstable Affliction
Spell( 30108 ,{ name = "", duration = 15, tick = 3, priority = 10, showpower = true, overlay = {0,6.5, 0.2}, fixedlen = normalize_dots_to, nameplates = true, ghost = true, color = colors.RED })

--Agony
Spell( 980 ,{ name = "", duration = 24, tick = 3, overlay = {0, 11, 0.2}, showpower = true, fixedlen = normalize_dots_to, nameplates = true, _ignore_applied_dose = true, ghost = true, priority = 6, color = colors.WOO })

--Corruption (2nd is a Soulburn SoC Corruption) --87389
local patch50400 = select(4,GetBuildInfo()) >= 50400

-- 172 - original id, 146739 - ptr 5.4 for both soc corruption and normal
if patch50400 then
    Spell( 146739 ,{ name = "", duration = 18, tick = 3, priority = 9, overlay = {0,8, 0.2}, showpower = true, fixedlen = normalize_dots_to, nameplates = true, ghost = true, color = colors.PINK })
else
    Spell( 172 ,{ name = "", duration = 18, tick = 3, priority = 9, overlay = {0,8, 0.2}, showpower = true, fixedlen = normalize_dots_to, nameplates = true, ghost = true, color = colors.PINK })
    Spell( 87389 ,{ name = "Corruption", multiTarget = true, color = colors.WOO2, duration = 18 })
end



Spell( {27243, 114790} ,{ name = "Seed of Corruption",duration = 18, nameplates = true,  color = colors.LRED, short = "SoC" })


EventTimer({ spellID = 86121, event = "SPELL_CAST_SUCCESS",
    action = function(active, srcGUID, dstGUID, spellID )
        NugRunning:SoulSwapStore(active, srcGUID, dstGUID, spellID )
    end})

EventTimer({ spellID = 86213, event = "SPELL_CAST_SUCCESS",
    action = function(active, srcGUID, dstGUID, spellID )
        NugRunning:SoulSwapUsed(active, srcGUID, dstGUID, spellID )
    end})


if not patch50400 then
EventTimer({ spellID = 77799, event = "SPELL_DAMAGE",
    action = function(active, srcGUID, dstGUID, spellID)
        for timer in pairs(active) do
            if timer.dstGUID == dstGUID 
                and (timer.spellID == 172 or timer.spellID == 30108 or timer.spellID == 348 ) --corr, ua, immo
            then
                local self = NugRunning
                local plevel = self:GetPowerLevel()
                timer.powerLevel = plevel
                self:UpdateTimerPower(timer, plevel)
            end
        end
    end})
end

--touch of chaos refresh dotpower
EventTimer({ spellID = 103964, event = "SPELL_DAMAGE",
    action = function(active, srcGUID, dstGUID, spellID)
        for timer in pairs(active) do
            if timer.dstGUID == dstGUID and timer.spellID == 172 then
                local self = NugRunning
                local plevel = self:GetPowerLevel()
                timer.powerLevel = plevel
                self:UpdateTimerPower(timer, plevel)
            end
        end
    end})


if not patch50400 then
--void ray
EventTimer({ spellID = 115422, event = "SPELL_DAMAGE",
    action = function(active, srcGUID, dstGUID, spellID)
        for timer in pairs(active) do
            if timer.dstGUID == dstGUID and timer.spellID == 172 then
                local self = NugRunning
                timer.endTime = timer.endTime + 4
                if timer.endTime - timer.startTime > 27 then
                    timer.endTime = timer.startTime + 27
                end
                local plevel = self:GetPowerLevel()
                timer.powerLevel = plevel
                self:UpdateTimerPower(timer, plevel)
            end
        end
    end})
end

Spell( 109466 ,{ name = "Curse of Enfeeblement",duration = 30, color = colors.CURSE, short = "CoEnf" })
Spell( 18223 ,{ name = "Curse of Exhaustion", duration = 30, pvpduration = 8, color = colors.CURSE, short = "CoEx" })
Spell( {1490, 104225},{ name = "Curse of Elements", duration = 300, affiliation = "any", singleTarget = true, glowtime = 15, color = colors.CURSE, pvpduration = 120, short = "CoE" })
--aoe version
-- Spell( 104225 ,{ name = "Curse of Elements",duration = 300, glowtime = 15, color = colors.CURSE, pvpduration = 120, short = "CoE", multiTarget = true })
Spell( 60478 ,{ name = "Doomguard", duration = 60 })

Spell( 24259 ,{ name = "Spell Lock",duration = 3, color = colors.PINK })
Spell( 6358 ,{ name = "Seduction",duration = 30, pvpduration = 8 })
Spell( 89766 ,{ name = "Axe Toss", color = colors.BROWN, duration = 4 })

Spell( 6789 ,{ name = "Mortal Coil", duration = 3 })
Spell( 5484 ,{ name = "Howl of Terror", duration = 20, pvpduration = 8, multiTarget = true })
Spell( 110913 ,{ name = "Dark Bargain", duration = 10 })
Spell( 108416 ,{ name = "Sacrificial Pact", duration = 10 })
Spell( 30283 ,{ name = "Shadowfury", duration = 3, multiTarget = true })

Spell( 5782 ,{ name = "Fear", duration = 20, nameplates = true, pvpduration = 8 })
Spell( 118699 ,{ name = "Blood Fear", duration = 20, pvpduration = 8 })
Spell( 104045 ,{ name = "Sleep", duration = 20, pvpduration = 8 })
Spell( 710 ,{ name = "Banish", nameplates = true, duration = 30 })
end
   
if class == "PRIEST" then
-- BUFFS
Spell( 139 ,{ name = "Renew", shinerefresh = true, color = colors.LGREEN, duration = 12 })
Spell( 17 ,{ name = "Power Word: Shield", short = "PW:Shield", shinerefresh = true, duration = 15, color = colors.LRED })
Spell( 41635 ,{ name = "Prayer of Mending", shinerefresh = true, duration = 30, color = colors.RED, textfunc = function(timer) return timer.dstName end })
Spell( 47788 ,{ name = "Guardian Spirit", shine = true, duration = 10, color = colors.LBLUE, short = "Guardian" })
Spell( 33206 ,{ name = "Pain Suppression",shine = true, duration = 8, color = colors.LBLUE })
Spell( 586 ,{ name = "Fade",duration = 10 })
Spell( 89485 ,{ name = "Inner Focus", shine = true, color = colors.LBLUE, timeless = true, duration = 0.1 })
-- Spell( 49694,59000 ,{ name = "Improved Spirit Tap",duration = 8 })
-- Spell( 15271 ,{ name = "Spirit Tap",duration = 15 })
Spell( 589 ,{ name = "Shadow Word: Pain", short = "", tick = 3, tickshine = true, overlay = { "tick", "end", 0.3}, duration = 18, ghost = true, nameplates = true, priority = 9, color = colors.PURPLE, showpower = true, })

EventTimer({ event = "SPELL_SUMMON", spellID = 123040, name = "Mindbender", group = "buffs", duration = 15, priority = -10, color = colors.BLACK })
EventTimer({ event = "SPELL_SUMMON", spellID = 34433, name = "Shadowfiend", group = "buffs", duration = 12, priority = -10, color = colors.BLACK })

Spell( 34914 ,{ name = "Vampiric Touch", short = "", tick = 3, tickshine = true, overlay = { "tick", "end", 0.3}, ghost = true, nameplates = true,  priority = 10, duration = 15, color = colors.RED, showpower = true, })
Spell( 2944 ,{ name = "Devouring Plague",duration = 6, priority = 8, nameplates = true, color = colors.WOO, short = "Plague" })
Spell( 47585 ,{ name = "Dispersion",duration = 6, color = colors.PURPLE })
-- Spell( 15286 ,{ name = "Vampiric Embrace",duration = 15, color = colors.CURSE, short = "VampEmbrace" })

Spell( 123254, { name = "Twist of Fate",duration = 10, group = "buffs", priority = -10, color = colors.CURSE, specmask = 0x0FF })
Spell( 81700, { name = "Archangel",duration = 18, group = "buffs", priority = -9, color = colors.PINKIERED })
-- Spell( 47753 ,{ name = "Divine Aegis", duration = 12 })
Spell( 59889,{ name = "Borrowed Time", duration = 6, group = "buffs" })
-- DEBUFFS
Spell( 109964 ,{ name = "Spirit Shell", duration = 15, priority = -20, color = colors.PURPLE2 })
-- Spell( 114908 ,{ name = "Spirit Shell", duration = 15, color = colors.PURPLE2 }) --shield effect

Spell( 87160 ,{ name = "Surge of Darkness", duration = 10, color = colors.LRED })
Spell( 87160 ,{ name = "Surge of Darkness", duration = 10, color = colors.LRED })
Spell( 114255,{ name = "Surge of Light", duration = 20, color = colors.LRED })
Spell( 112833,{ name = "Spectral Guise", duration = 6, color = colors.CURSE })
Spell( 123266,{ name = "Divine Insight", duration = 10, color = colors.BLACK }) -- discipline
Spell( 123267,{ name = "Divine Insight", duration = 10, color = colors.BLACK }) -- holy
Spell( 124430,{ name = "Divine Insight", duration = 12, color = colors.BLACK }) -- shadow


Spell( 9484 ,{ name = "Shackle Undead",duration = 50, pvpduration = 8, short = "Shackle" })
Spell( 15487 ,{ name = "Silence",duration = 5, color = colors.PINK })

Spell( 113792 ,{ name = "Psychic Terror",duration = 30, pvpduration = 8 })
Spell( 8122 ,{ name = "Psychic Scream",duration = 8, multiTarget = true })
-- Spell( 64044 ,{ name = "Psychic Horror",duration = 1, multiTarget = true })

--Rapture
EventTimer({ event = "SPELL_ENERGIZE", spellID = 47755, priority = -10, name = "Rapture", color = colors.DPURPLE, duration = 12 })
Spell( {15407, 129197}, { name = "Mind Flay", short = "", tick = 1, overlay = {"tick", "tickend"}, color = colors.CURSE, priority = 11, duration = 3 })

--Old Shadow Orbs
-- Spell( 77487 ,{ name = "",duration = 60, charged = true, maxcharge = 3, shine = true, shinerefresh = true, priority = -3, color = colors.WOO })

Cooldown( 8092, { name = "Mind Blast", recast_mark = 1.5, color = colors.CURSE, resetable = true, ghost = true })
Cooldown( 32379, { name = "Shadow Word: Death", short = "SW:Death",  color = colors.PURPLE, resetable = true  })
    
EventTimer({ event = "SPELL_CAST_SUCCESS", spellID = 62618, name = "PW:Barrier", duration = 10, color = colors.GOLD })
-- Spell( 81782 ,{ name = "Power Word: Barrier", short = "PW: Barrier", duration = 25, color = {1,0.7,0.5} }) -- duration actually used here, invisible aura applied

-- Spell( 81208 ,{ name = "Chakra: Serenity", short = "Serenity", color = colors.WOO, shine = true, timeless = true, duration = 9999 })
-- Spell( 81206 ,{ name = "Chakra: Sanctuary", color = colors.WOO2, short = "Sanctuary", shine = true, timeless = true, duration = 9999 })
-- Spell( 81209 ,{ name = "Chakra: Chastise", short = "Chastise", color = colors.RED, shine = true, timeless = true, duration = 9999 })
-- Spell( 88625 ,{ name = "Holy Word: Chastise", color = colors.LRED, short = "HW: Chastise", duration = 3 })
Cooldown( 88625 ,{ name = "Holy Word: Chastise", color = colors.CURSE, short = "Chastise", resetable = true })

Cooldown( 47540 ,{ name = "Penance", priority = 15, color = colors.CURSE })
-- Spell( 14914 ,{ name = "Holy Fire", priority = 14.1, color = colors.PINK, ghost = 3, duration = 7 }) --holy fire
Cooldown( 14914 ,{ name = "", overlay = {0,3}, priority = 14, color = colors.PINK }) --holy fire
Spell( 81661 ,{ name = "Evangelism",duration = 15, group = "buffs", priority = 10, color = colors.ORANGE, stackcolor = {
                                [1] = colors.DRED,
                                [2] = colors.DRED,
                                [3] = colors.DRED,
                                [4] = colors.RED,
                                [5] = {1,0,0},
                            } })
--Spell( 81700 ,{ name = "Archangel",duration = 18, color = colors.CURSE })

--Spell({ 63731,63735 } ,{ name = "Serendipity",duration = 20, color = {0.4,0.4,0.9} })




    local targettable = {
       "target",
       "focus",
       "mouseover",
       "boss1",
       "boss2",
       "boss3",
       "boss4",
       "boss5",
       "arena1",
       "arena2",
       "arena3",
       "arena4",
       "arena5",
    }

    local scanner
    local _elapsed = 0
    local function scannerOnUpdate(self, time)
        _elapsed = _elapsed + time
        if _elapsed < 0.1 then return end
        _elapsed = 0

        for _, unitID in ipairs(targettable) do
            if UnitExists(unitID) then
               if not UnitIsUnit(unitID, "target") then
                    NugRunning.UpdateUnitAuras(unitID)
               else
                    NugRunning.UpdateUnitAuras("target")
               end
            end
         end
    end

    helpers.TrackItemSet("Shadow_T15", {
        96674, 96675, 96676, 96677, 96678, --heroic
        95300, 95301, 95302, 95303, 95304, --normal
        95930, 95931, 95932, 95933, 95934, --lfr
    })
    helpers.RegisterSetBonusCallback("Shadow_T15", 2,
        function()
            scanner = scanner or CreateFrame("Frame", nil, UIParent)
            scanner:SetScript("OnUpdate", scannerOnUpdate)
        end, 
        function()
            scanner:SetScript("OnUpdate", nil)
        end
    )

end


if class == "ROGUE" then
Spell( 1966 ,{ name = "Feint", duration = 5, priority = -1, shine = true, shinerefresh = true, color = colors.LBLUE })
Spell( 2983 ,{ name = "Sprint", shine = true, duration = 8 })
Spell( 5277 ,{ name = "Evasion", color = colors.PINK, duration = 15 })
Spell( 31224 ,{ name = "Cloak of Shadows", color = colors.CURSE, duration = 5, short = "CloS" })
Spell( 73651 ,{ name = "Recuperate", shinerefresh = true, color = colors.LGREEN ,duration = function() return (6 * GetCP()) end })
Spell( 5171 ,{ name = "Slice and Dice", shinerefresh = true, fixedlen = 24, short = "SnD", color = colors.PURPLE,
    duration = function() return (6 + GetCP()*6) end,
}) -- SnD fixedlen set to match Rupture maximum duration
Spell( 122233 ,{ name = "Crimson Tempest", short = "Tempest", color = colors.RED, duration = 12, multiTarget = true })
    
Spell( 1833 ,{ name = "Cheap Shot", duration = 4, color = colors.LRED })
Spell( 408 ,{ name = "Kidney Shot", shine = true, duration = function() return 1+GetCP() end, color = colors.LRED })
Spell( 1776 ,{ name = "Gouge", color = colors.PINK, duration = 4 })
Spell( 2094 ,{ name = "Blind",duration = 60, pvpduration = 8, color = {0.20, 0.80, 0.2} })

-- Spell( 113746 ,{ name = "Weakened Armor", short = "WeakArmor", priority = -10, anySource = true, singleTarget = true, color = colors.BROWN, duration = 30 })

Spell( 51722 ,{ name = "Dismantle",duration = 10,color = colors.LRED })
Spell( 6770 ,{ name = "Sap",duration = 60, color = colors.LBLUE })

Spell( 1943 ,{ name = "Rupture", shinerefresh = true, fixedlen = 24, color = colors.RED, fixedlen = 16,
    duration = function() return (4 + GetCP() * 4) end,
})
Spell( 703 ,{ name = "Garrote", color = colors.RED, duration = 18 })
Spell( 1330 ,{ name = "Silence", color = colors.PINK, duration = 3 })

--Spell( 3409 ,{ name = "Crippling Poison", color = { 192/255, 77/255, 48/255}, duration = 12, short = "Crippling" })

Spell( 32645 ,{ name = "Envenom", color = { 0, 0.65, 0}, duration = function() return (1+GetCP()) end })
Spell( 79140 ,{ name = "Vendetta", shine = true, color = colors.CURSE, duration = 20 })
Spell( 121153 ,{ name = "Blindside", shine = true, color = colors.TEAL, duration = 10 })

Spell( 108212,{ name = "Burst of Speed", short = "Burst", shine = true, duration = 4 })
Spell( 115197,{ name = "Partial Paralysis", short = "Rooted", shine = true, color = colors.BROWN, duration = 4 })
Spell( 14183 ,{ name = "Premeditation",duration = 20, color = colors.CURSE })                    
Spell( 74002 ,{ name = "Combat Insight", shine = true, shinerefresh = true, duration = 10, color = colors.CURSE })

Spell( 84745 ,{ name = "Shallow Insight", short = "1x Insight", shine = true, color = colors.CURSE, duration = 15 })
Spell( 84746 ,{ name = "Moderate Insight", short = "2x Insight", shine = true, color = colors.CURSE, duration = 15 })
Spell( 84747 ,{ name = "Deep Insight", short = "3x Insight", shine = true, color = colors.CURSE, duration = 15 })
Spell( 13750 ,{ name = "Adrenaline Rush",duration = 15, color = colors.LRED })
Spell( 13877 ,{ name = "Blade Flurry",duration = 15, color = colors.LRED })

Spell( 121471 ,{ name = "Shadow Blades", duration = 12, color = colors.CURSE, shine = true })

Spell( 51713 ,{ name = "Shadow Dance",duration = 8, color = colors.BLACK })
-- Spell( 89775 ,{ name = "Hemo",duration = 60, color = colors.CURSE })
-- Spell( 91021 ,{ name = "Find Weakness", duration = 10, color =  colors.LRED })

--Spell( 1784 ,{ name = "Stealth", color = colors.CURSE, timeless = true, duration = 0.1})
Spell( 114018,{ name = "Shroud of Concealment", short = "Shroud", color = colors.CURSE, duration = 15 })
Spell( 114842,{ name = "Shadow Walk", color = colors.PINK, duration = 6 })

EventTimer({ event = "SPELL_CAST_SUCCESS", spellID = 1725, name = "Distract", color = colors.PURPLE, duration = 10 })
end

if class == "WARRIOR" then
Spell( 6673 ,{ name = "Battle Shout", target = "player", glowtime = 10, priority = -10, color = colors.DPURPLE, duration = 120 })
Spell( 469 ,{ name = "Commanding Shout", target = "player", priority = -10, glowtime = 10, short = "CommShout", color = colors.DPURPLE, duration = 120 })
Spell( 132404 ,{ name = "Shield Block", color = colors.WOO2, group = "buffs", priority = - 9, duration = 6, priority = 4, })
Spell( 112048 ,{ name = "Shield Barrier", ghost = 1.3, group = "buffs", priority = -8, color = colors.WOO, priority = 4, duration = 6 })
-- Spell( 85730 ,{ name = "Deadly Calm", group = "buffs", duration = 10 })
Spell( 12328 ,{ name = "Sweeping Strikes", priority = 6, ghost = 1, color = colors.BLACK, short = "Sweeping", duration = 10 })
-- Spell( 115767 ,{ name = "Deep Wounds", color = colors.DRED, duration = 15, singleTarget = true })

Spell( 20511 ,{ name = "Intimidating Shout", short = "Fear", duration = 8, multiTarget = true })

Spell( 86346 ,{ name = "Colossus Smash", shine = true, priority = -100500, color = colors.PURPLE2, duration = 6 }) --debuff
Cooldown( 86346 ,{ name = "Colossus Smash", priority = 8, ghost = true, color = colors.WOO, resetable = true, duration = 20 })

Spell( 676  ,{ name = "Disarm", color = colors.BROWN, duration = 10 })
Spell( 1715 ,{ name = "Hamstring", ghost = true, color = colors.PURPLE, duration = 15, pvpduration = 8 })

-- Spell( 12809 ,{ name = "Concussion Blow", color = { 1, 0.3, 0.6 }, duration = 5 })
Spell( 355 ,{ name = "Taunt", duration = 3 })
-- Spell( 113746 ,{ name = "Weakened Armor", specmask = 0xF00, short = "WeakArmor", priority = -10, affiliation = "any", singleTarget = true, color = colors.BROWN, duration = 30 })
-- Demo shout also applies self-buff (id 125565), but it doesn't appear in combat log
Spell( 1160 ,{ name = "Demoralizing Shout", short = "DemoShout", shine = true, group = "buffs", color = colors.BLACK, duration = 30, multiTarget = true })
Spell( 115798 ,{ name = "Weakened Blows", ghost = 3, specmask = 0xF00, short = "WeakBlows", priority = -20, anySource = true, singleTarget = true, color = {149/255, 121/255, 214/255}, duration = 30 })
Spell( 122510 ,{ name = "Ultimatum", shine = true, color = colors.TEAL, glowtime = 10, duration = 10, priority = 11, scale = .7 })
Cooldown( 6572, { name = "Revenge", priority = 5, color = colors.PURPLE, resetable = true, fixedlen = 9, ghost = true })
-- Activation( 6572, { name = "RevengeActivation", for_cd = true })

Spell( 55694, { name = "Enraged Regeneration", short = "Regen", color = colors.LGREEN, duration = 5 })
Spell( 132168 ,{ name = "Shockwave", color = colors.CURSE, shine = true, duration = 4, multiTarget = true, })
Cooldown( 46968 ,{ name = "Shockwave", overlay = {0, 1.5}, fixedlen = 9, ghost = 2, priority = 2, color = colors.WOO2 })
--can't use with_cooldown on shockwave, because without effect applied first it's not working.
--but shockwave still needs to be used on cooldown
--old enrage Spell( 85288, { name = "Enraged", shine = true, showid = 14202, color = colors.RED, duration = 10 })
Spell( 12880 ,{ name = "Enrage", color = colors.DPURPLE, group = "buffs", specmask = 0x0FF, priority = -7, shine = true, shinerefresh = true, duration =6 })

Spell( 12323 ,{ name = "Piercing Howl", multiTarget = true, duration = 15 })
Spell( 107566 ,{ name = "Staggering Shout", duration = 5 })
Spell( 105771, { name = "Warbringer", duration = 3 })
Spell( 107574, { name = "Avatar", shine = true, group = "buffs",  color = colors.TEAL, duration = 30 })
Spell( 132169, { name = "Storm Bolt", color = colors.TEAL2, duration = 3})

--banners are totems actually
Spell( 114192, { name = "Mocking Banner", color = colors.PURPLE2, duration = 20})
EventTimer({ spellID = 114207, event = "SPELL_CAST_SUCCESS", group = "buffs", affiliation = "raid", name = "Skull Banner", duration = 10, color = colors.RED })
EventTimer({ spellID = 114203, event = "SPELL_CAST_SUCCESS", group = "buffs", name = "Demoralizing Banner", affiliation = "raid", short = "DemoBanner", duration = 15, color = colors.BLACK })
Spell( 1719, { name = "Recklessness", color = colors.LRED, group = "buffs", duration = 20})
Spell( 64382, { name = "Shattering Throw", short = "Shattering", color = colors.TEAL, group = "buffs", duration = 10})
-- Cooldown( 107570, { name = "Storm Bolt", color = colors.TEAL2 })
Spell( 12292, { name = "Bloodbath", priority = -8, group = "buffs", color = colors.PINKIERED, duration = 12, })
    --with_cooldown = { id = 12292, name = "Bloodbath", priority = -8, glowtime = 5, color = colors.DRED }    })

--Spell( 56112 ,{ name = "Furious Attacks", duration = 10 })
--Activation( 5308, { name = "Execute", shine = true, timeless = true, color = colors.CURSE, duration = 0.1 })

Cooldown( 12294, { name = "Mortal Strike", tick = -1.5, tickshine = true, overlay = {"tick", "end"}, priority = 10, short = "", check_known = true, fixedlen = 9, ghost = true,  color = colors.CURSE })
-- these popups are for visual confirmation that cast went in
EventTimer({ spellID = 1464, event = "SPELL_CAST_SUCCESS", priority = 12, name = "Slam", duration = 0.5, color = colors.PINK })
EventTimer({ spellID = 1680, event = "SPELL_CAST_SUCCESS", priority = 12, name = "Whirlwind", duration = 0.5, color = colors.PINK })
EventTimer({ spellID = 5308, event = "SPELL_CAST_SUCCESS", priority = 12, name = "Execute", duration = 0.5, color = colors.PINK })
EventTimer({ spellID = 20243, event = "SPELL_CAST_SUCCESS", priority = 12, name = "Devastate", duration = 0.5, color = colors.PINK })
EventTimer({ spellID = 100130, event = "SPELL_CAST_SUCCESS", priority = 12, name = "Wild Strike", duration = 0.9, color = colors.PINK })

-- special timer
-- Spell( 7384, { name = "Overpower", overlay = {0,-4.5, 0.15}, priority = 11, shine = true, shinerefresh = true, color = colors.PINKIERED, recast_mark = -4.5, duration = 9})
--Activation( 7384, { name = "Overpower", short = "", shine = true, color = colors.RED, recast_mark = 4.5, duration = 9})
-- Spell( 125831 ,{ name = "Taste for Blood", glowtime = 5, shinerefresh = true, shine = true, color = colors.TEAL, duration = 15 }) -- Taste for blood
Spell( 60503 ,{ name = "Overpower", priority = 9, overlay = {0,7, 0.3}, fixenlen = 9, shinerefresh = true, shine = true, color = colors.PINKIERED, duration = 12 }) -- Taste for blood

-- 1s mark for bloodsurged wild strike gcd
-- 1.5s mark for 2nd gcd
-- 3s mark for 1st gcd
Cooldown( 23881, { name = "Bloodthirst", tick = -1.5, tickshine = true, overlay = {"tick", "end"}, short = "", priority = 10, check_known = true, ghost = true, fixedlen = 6,  color = colors.CURSE })
Spell( 46916 ,{ name = "Bloodsurge", shine = true, priority = 8, color = colors.TEAL, duration = 10 })

Spell( 131116 ,{ name = "Raging Blow", priority = 9, fixedlen = 9, shine = true, shinerefresh = true, duration = 12, stackcolor = {
                                                                                                [1] = colors.RED,
                                                                                                [2] = {1,0,0},
                                                                                            },
                                                                            -- onupdate = function(self)
                                                                            --     local now = GetTime()
                                                                            --     local colcd = 0
                                                                            --         local start, duration = GetSpellCooldown(86346)
                                                                            --         if duration > 1.5 then
                                                                            --             colcd = (start+duration) - now
                                                                            --         end
                                                                            --     local _, _, _, rbstacks = UnitBuff("player",  GetSpellInfo(131116))
                                                                            --     if colcd > 3 and colcd < 14 and rbstacks == 2 then
                                                                            --         -- self:SetAlpha(1)
                                                                            --         if not self.glow:IsPlaying() then self.glow:Play() end
                                                                            --     else
                                                                            --         -- self:SetAlpha(0.3)
                                                                            --         if self.glow:IsPlaying() then self.glow:Stop() end
                                                                            --     end
                                                                            -- end
                                                                                })
--Cooldown( 85288, { name = "Raging Blow", ghost = true,  color = colors.WOO })
--Activation( 85288, { name = "Enraged", for_cd = true })
-- it's enrage timer config


-- Cooldown( 1680, { name = "Whirlwind", color = colors.LBLUE })
Spell( 12975, { name = "Last Stand", color = colors.BLACK, duration = 20, group = "buffs" })
Spell( 97463, { name = "Rallying Cry", color = colors.BLACK, target = "player", duration = 10, group = "buffs" })
Spell( 118038, { name = "Die by the Sword", short = "DbtS", color = colors.BLACK, duration = 8, group = "buffs" })
Spell( 871, { name = "Shield Wall", color = colors.WOO2, duration = 12, group = "buffs" })
Cooldown( 23922, { name = "Shield Slam", tick = -1.5, tickshine = true, overlay = {"tick", "end"}, short = "", priority = 10, check_known = true, fixedlen = 9, ghost = true,  color = colors.CURSE, resetable = true })
--Activation( 23922, { name = "Slam!", shine = true, timeless = true, color = colors.CURSE, duration = 0.1 })

-- Cooldown( 78, { name = "Heroic Strike", short = "Heroic", fixedlen = 6, ghost = true })
Cooldown( 6343, { name = "Thunder Clap", ghost = 0.5, short = "", scale = 0.6, specmask = 0xF00, overlay = {0, 1.5}, color = colors.PINKIERED, fixedlen = 9, priority = 9.5 })
EventTimer({ spellID = 6343, event = "SPELL_CAST_SUCCESS", name = "Deep Wounds", specmask = 0x00F, color = colors.DRED, multiTarget = true, priority = -15, duration = 15 })



Spell( 32216, { name = "Victory Rush", group = "buffs", priority = -9, color = colors.PURPLE, duration = 20})

-- Spell( 7922, { name = "Charge", duration = 1 })
end

if class == "MONK" then
-- Spell( 120086, { name = "Fists of Fury", color = colors.BLUE, duration = 4 })
Spell( 120954, { name = "Fortifying Brew", color = colors.WOO2, duration = 20 })
Spell( 117368, { name = "Grapple Weapon", short = "Disarm", color = colors.BROWN, duration = 10 })
Spell( 115078, { name = "Paralysis", color = colors.PURPLE, duration = 30, pvpduration = 8 })
Spell( 115546 ,{ name = "Provoke", short = "Taunt", duration = 3 })
Spell( 115072, { name = "Expel Harm", color = colors.TEAL })

Spell( 118864 ,{ name = "CB: Tiger Palm", short = "Tiger Palm", color = colors.WOO, duration = 15 })
Spell( 116768 ,{ name = "CB: Blackout Kick", short = "Blackout Kick", color = colors.PINK, duration = 15 })

Spell( 125195 ,{ name = "Tigereye Brew", priority = -10, color = colors.BLACK, duration = 120 }) --stacks
Spell( 116740 ,{ name = "Tigereye Brew", color = colors.BLACK, duration = 15 }) --activation

Spell( 125359, { name = "Tiger Power", priority = -9, color = colors.PURPLE2, duration = 20 })
Spell( 127722, { name = "Serpent's Zeal", priority = -8, color = colors.PINK, duration = 30 })

Cooldown( 107428, { name = "Rising Sun Kick", short = "Rising Sun", color = colors.PURPLE })

Spell( 119611 ,{ name = "Renewing Mist", color = colors.LGREEN, target = "player", duration = 18 })
-- Spell( 115151 ,{ name = "Renewing Mist", color = colors.TEAL2 })
Spell( 115867 ,{ name = "Mana Tea", priority = -10, duration = 120, color = colors.BLACK })
Cooldown( 123761 ,{ name = "Mana Tea", color = colors.CURSE })
Spell( 116849 ,{ name = "Life Cocoon", color = colors.PURPLE, duration = 12 })

Cooldown( 116680 ,{ name = "Thunder Focus Tea", color = colors.CURSE, overlay = {0, 15}, recast_mark = 15 })
-- Spell( 116680 ,{ name = "Thunder Focus Tea", color = colors.CURSE, duration = 30 })
Spell( 118674 ,{ name = "Vital Mists", color = colors.BLACK, duration = 30 })
NugRunningConfig.totems[1] = { name = "Statue", color = colors.DPURPLE, priority = - 100, hideName = true }


Spell( 115213 ,{ name = "Avert Harm", duration = 15 })
Spell( 115307 ,{ name = "Shuffle", color = colors.RED, duration = 6 })
Spell( 116330 ,{ name = "Dizzying Haze", color = colors.PURPLE, duration = 15, multiTarget = true })
Spell( 123727 ,{ name = "Dizzying Haze", color = colors.PURPLE, duration = 15, multiTarget = true }) -- from Keg Smash
Spell( 128939 ,{ name = "Elusive Brew", priority = -10, duration = 30, color = colors.BLACK })
Spell( 115308 ,{ name = "Elusive Brew", duration = 15, color = colors.BLACK })
Cooldown( 115295, { name = "Guard", color = colors.GOLD })
Cooldown( 121253, { name = "Keg Smash", color = colors.CURSE })
Spell( 115798 ,{ name = "Weakened Blows", short = "WeakBlows", specmask = 0x00F, priority = -20, affiliation = "any", singleTarget = true, color = {149/255, 121/255, 214/255}, duration = 30 })

Spell( 124081 ,{ name = "Zen Sphere", duration = 16, color = { 1, 0.2, 1} })
Spell( 119381 ,{ name = "Leg Sweep", duration = 5, color = colors.RED, multiTarget = true })
Spell( 122783 ,{ name = "Diffuse Magic", duration = 6, color = colors.CURSE })
end

if class == "DEATHKNIGHT" then
Spell( 55095 ,{ name = "Frost Fever", color = colors.CHILL, priority = 10, singleTarget = true, duration = 30 })
Spell( 55078 ,{ name = "Blood Plague", color = colors.PURPLE, priority = 9, singleTarget = true, duration = 30 })
Spell( 43265 ,{ name = "Death and Decay", short = "DnD", color = colors.RED, duration = 10, target = "player" })
-- Cooldown( 43265 ,{ name = "Death and Decay", color = colors.GOLD, minduration = 15 })

Spell({114866, 130735, 130736}, { name = "Soul Reaper", color = colors.BLACK, duration = 5 })
Spell( 73975 ,{ name = "Necrotic Strike", duration = 10, color = colors.WOO })

--BLOOD
Spell( 56222 ,{ name = "Taunt", duration = 3 })
Spell( 55233 ,{ name = "Vampiric Blood", duration = 10, color = colors.RED })
Spell( 81256 ,{ name = "Dancing Rune Weapon", duration = 12, color = colors.BROWN })
--Spell( 49222 ,{ name = "Bone Shield", duration = 300, color = colors.WOO2 })

Spell( 81141 ,{ name = "Crimson Scourge", duration = 15, color = colors.LRED })
Spell( 50421 ,{ name = "Scent of Blood", duration = 30, color = colors.WOO2 })

--FROST
Spell( 57330 ,{ name = "Horn of Winter", target = "player", duration = 120, glowtime = 8, color = colors.CURSE, short = "Horn" })
Spell( 45524 ,{ name = "Chains of Ice", duration = 8, color = colors.CHILL })
Spell( 48792 ,{ name = "Icebound Fortitude", duration = 12 })
Spell( 51124 ,{ name = "Killing Machine", duration = 30, color = colors.LRED, shine = true })
Spell( 59052 ,{ name = "Freezing Fog", duration = 15, color = colors.WOO2, shine = true })

Spell( 49039 ,{ name = "Lichborne", duration = 10, color = colors.BLACK })

--UNHOLY
Spell( 91342 ,{ name = "Shadow Infusion", shinerefresh = true, duration = 30, color = colors.LGREEN, short = "Infusion" })
Spell( 63560 ,{ name = "Dark Transformation", shine = true, duration = 30, color = colors.LGREEN, short = "Monstrosity" })
Spell( 81340 ,{ name = "Sudden Doom", shine = true, duration = 10, color = colors.CURSE })
Spell( 47476 ,{ name = "Strangulate", duration = 5 })
Spell( 91800 ,{ name = "Gnaw", duration = 3, color = colors.RED })
Spell( 91797 ,{ name = "Monstrous Blow", duration = 4, color = colors.RED, short = "Gnaw" })
Spell( 49016 ,{ name = "Unholy Frenzy", duration = 30, color = colors.LRED })
Spell( 48707 ,{ name = "Anti-Magic Shell", duration = 5, short = "Shell", color = colors.LGREEN })

Spell( 50461 ,{ name = "Anti-Magic Zone", color = colors.GOLD, duration = 10, multiTarget = true })
Spell( 116888 ,{ name = "Purgatory", color = colors.LGREEN, duration = 3, shine = true })
Spell( 108194 ,{ name = "Asphyxiate", color = colors.PINK, duration = 5 })
Spell( 96268 ,{ name = "Death's Advance", color = colors.PINK, duration = 6, shine = true })
Spell( 114851 ,{ name = "Blood Charge", color = colors.DRED, duration = 24 })

Spell( 115018 ,{ name = "Desecrated Ground", color = colors.BLACK, duration = 10, multiTarget = true }) -- untested
end

if class == "MAGE" then
--ARCANE
Spell( 80353 ,{ name = "Time Warp", shine = true, target = "player", duration = 40, color = colors.WOO2 })
Spell({ 118,61305,28271,28272,61721,61780 },{ name = "Polymorph", duration = 50, color = colors.LGREEN, pvpduration = 8, short = "Poly" })
Spell( 12042 ,{ name = "Arcane Power",duration = 15, short = "APwr", color = colors.PINK })
--~ Spell( 66 ,{ name = "Fading",duration = 3 - NugRunning.TalentInfo(31574) })
Spell( 36032 ,{ name = "Arcane Charge",duration = 10, color = colors.CURSE })
Cooldown( 44425 ,{ name = "Arcane Barrage", color = colors.RED })
Spell( 79683 ,{ name = "Arcane Missiles!", shine = true, duration = 20, color = colors.WOO })
--~ Spell( 55342 ,{ name = "Mirror Image",duration = 30 })
--~ Spell( 44413 ,{ name = "Incanter's Absorption",duration = 10, color = colors.LRED, short = "Absorb" })

-- Spell( 12536 ,{ name = "Clearcast",duration = 15, color = colors.BLACK })
Spell( 31589 ,{ name = "Slow", duration = 15, pvpduration = 8 })
Spell( 55021 ,{ name = "Silenced",duration = 4, color = colors.PINK }) -- imp CS
--FIRE
Spell( 48108 ,{ name = "Hot Streak",duration = 10, shine = true, color = colors.CURSE, short = "Pyro!" })
Spell( 11113 ,{ name = "Blast Wave", color = colors.CHILL, duration = 3, multiTarget = true })
Spell( 31661 ,{ name = "Dragon's Breath", duration = 5, color = colors.ORANGE, short = "Breath", multiTarget = true })
Spell( 2120 ,{ name = "Flamestrike", duration = 8, color = colors.PURPLE, multiTarget = true })
Cooldown( 84714, { name = "Frozen Orb", color = colors.WOO})
--Cooldown( 2136, { name = "Fire Blast", resetable = true, color = colors.LRED})
Cooldown( 108853, { name = "Infeno Blast", color = colors.LRED})

--FROST
Spell( 12472 ,{ name = "Icy Veins",duration = 20 })
Spell( 82691 ,{ name = "Ring of Frost", shine = true, color = colors.FROZEN, multiTarget = true, duration = 12, pvpduration = 8 }) -- it's not multi target, but... it can spam
Spell( 122 ,{ name = "Frost Nova",duration = 8, short = "FrNova", color = colors.FROZEN, multiTarget = true })
Spell( 33395 ,{ name = "Freeze",duration = 8, color = colors.FROZEN })
Spell( 44544 ,{ name = "Fingers of Frost", shine = true, duration = 15, color = colors.FROZEN, short = "FoF" })
Spell( 57761 ,{ name = "Brain Freeze", shine = true, duration = 15, color = colors.LRED })

Spell( 45438 ,{ name = "Ice Block",duration = 10 })
Spell( 44572 ,{ name = "Deep Freeze",duration = 5 })
Spell( 120 ,{ name = "Cone of Cold", duration = 8, color = colors.CHILL, short = "CoC", multiTarget = true })

--talents
Spell( 12043 ,{ name = "Presence of Mind", shine = true, timeless = true, duration = 0.1, color = colors.CURSE, short = "PoM" })
Spell( 11426 ,{ name = "Ice Barrier",duration = 60, color = colors.LGREEN })
Spell( 108839 ,{ name = "Ice Floes", duration = 10, color = colors.CURSE })
Spell( 115610 ,{ name = "Temporal Shield", duration = 4, color = colors.LGREEN })
Spell( 102051 ,{ name = "Frostjaw", duration = 8, pvpduration = 4,  color = colors.PINK })

Spell( 32612 ,{ name = "Invisibility",duration = 20 })
Spell( 110960 ,{ name = "Greater Invisibility", duration = 20, color = colors.CURSE })

Spell( 116257 ,{ name = "Invoker's Energy", priority = -5, duration = 40, color = colors.DPURPLE })
Spell( 116014, { name = "Rune of Power", timeless = true, duration = 1, color = colors.DPURPLE, priority = -50 })

Spell( 112948 ,{ name = "Frost Bomb", duration = 5, color = colors.CURSE })
Spell( 44457 ,{ name = "Living Bomb",duration = function(self, opts) 
            local targetGUID = UnitGUID("target")
            if self.dstGUID == targetGUID then return 12 end
            local origin_timer = NugRunning.gettimer(NugRunning.active, 44457, targetGUID, "DEBUFF")
            if origin_timer then
                return origin_timer.endTime - GetTime()
            else
                return 12
            end
        end,
        ghost = true, color = colors.RED, short = "Bomb" })
Spell( 114923 ,{ name = "Nether Tempest", duration = 12, color = colors.PURPLE })

end

if class == "PALADIN" then

--Spell( 53657 ,{ name = "Judgements of the Pure", short = "JotP", duration = 100500, color = colors.LBLUE })
Spell( 84963 ,{ name = "Inquisition",duration = 12, fixedlen = 12,  color = colors.PURPLE })  -- 10 * CP
Spell( 31884 ,{ name = "Avenging Wrath",duration = 20, short = "AW", color = colors.FIRE })
Spell( 498 ,{ name = "Divine Protection",duration = 10, short = "DProt", color = colors.BLACK })
Spell( 642 ,{ name = "Divine Shield",duration = 8, short = "DShield", color = colors.BLACK })
Spell( 31850,{ name = "Ardent Defender",duration = 10, color = colors.BLACK})
Spell( 31821,{ name = "Devotion Aura", duration = 6, multiTarget = true, color = colors.GOLD})
Spell( 1022 ,{ name = "Hand of Protection",duration = 10, short = "HoProt", color = colors.WOO2 })
Spell( 1044 ,{ name = "Hand of Freedom",duration = 6, short = "Freedom" })
Spell( 10326 ,{ name = "Turn Evil",duration = 20, pvpduration = 8, color = colors.LGREEN })
Spell( 105421 ,{ name = "Blinding Light",duration = 6, color = colors.DRED, multiTarget= true })


-- Spell( 53563 ,{ name = "Beacon of Light", duration = 300, timeless = true, priority = -20, short = "Beacon",color = colors.RED })
Spell( 54428 ,{ name = "Divine Plea",duration = 15, short = "Plea" })
-- Spell( 31842 ,{ name = "Divine Favor",duration = 20, short = "Favor" })
Spell( 20066 ,{ name = "Repentance",duration = 60, pvpduration = 8, color = colors.LBLUE })
Spell( 853 ,{ name = "Hammer of Justice", duration = 6, short = "HoJ", color = colors.FROZEN })
Spell( 105593 ,{ name = "Fist of Justice", duration = 6, short = "FoJ", color = colors.FROZEN })
--Spell( 31803 ,{ name = "Censure",duration = 15, color = colors.RED})
-- Spell( 85696 ,{ name = "Zealotry",duration = 20 })
Spell( 2812 ,{ name = "Denounce", duration = 4, color = colors.GREEN })

Spell( 115798 ,{ name = "Weakened Blows", specmask = 0x0F0, short = "WeakBlows", priority = -20, affiliation = "any", singleTarget = true, color = {149/255, 121/255, 214/255}, duration = 30 })

Cooldown( 35395 ,{ name = "Crusader Strike", ghost = true, short = "Crusader", priority = 2, fixedlen = 6, color = colors.CURSE, recast_mark = 1.5 })
Cooldown( 20271 ,{ name = "Judgement", ghost = true, fixedlen = 6, priority = 1, color = colors.RED })
Cooldown( 24275 ,{ name = "Hammer of Wrath", short = "HWrath", color = colors.TEAL })
Cooldown( 119072, { name = "Holy Wrath", color = colors.BROWN })
Cooldown( 26573 ,{ name = "Consecration", color = colors.LBLUE })

Spell( 114637 ,{ name = "Bastion of Glory", short = "Bastion", duration = 20, priority = -15, color = colors.DRED })
-- Spell( 132403 ,{ name = "Shield of the Righteous", short = "SotR", duration = 3, priority = 10, color = colors.DPURPLE })

--Spell( 94686 ,{ name = "Crusader", duration = 15 })
Spell( 59578 ,{ name = "Exorcism", shine = true, color = colors.LRED, duration = 15 }) -- Art of War
--Activation( 879 ,{ name = "Exorcism", shine = true, color = colors.ORANGE, duration = 15 })
--Activation( 84963 ,{ name = "Hand of Light", shine = true, showid = 85256, short = "Light", color = colors.PINK, duration = 8 })

Spell( 62124 ,{ name = "Taunt", duration = 3 })
-- Spell( 85416 ,{ name = "Reset", shine = true, timeless = true, duration = 0.1, color = colors.BLACK })
--Activation( 31935 ,{ name = "Reset", shine = true, timeless = true, duration = 0.1, color = colors.BLACK })
Cooldown( 31935 ,{ name = "Avenger's Shield", resetable = true, duration = 15, short = "Avenger", color = colors.BLACK, ghost = true })


Spell( 85499 ,{ name = "Speed of Light", short = "Speed", duration = 7 })
Spell( 114250 ,{ name = "Selfless Healer", short = "Selfless", duration = 15 })
Spell( 114163 ,{ name = "Eternal Flame", duration = 30, color = colors.LGREEN })
Spell( 20925 ,{ name = "Sacred Shield", color = colors.WOO2, duration = 30 })
Spell( 90174 ,{ name = "Divine Purpose", shine = true, short = "DPurpose", color = colors.PINK, duration = 8 })
Cooldown( 114165 ,{ name = "Holy Prism", color = colors.BLACK })
Spell( {114916, 114917} ,{ name = "Execution Sentence", ghost = true, short = "Execution", color = colors.BLACK, duration = 10 })
end

if class == "DRUID" then
Spell( 339 ,{ name = "Entangling Roots",duration = 30 })
-- Spell( 113746 ,{ name = "Weakened Armor", short = "WeakArmor", priority = -10, affiliation = "any", singleTarget = true, color = colors.BROWN, duration = 30 })

Spell( 48391 ,{ name = "Owlkin Frenzy", duration = 10 })
-- Spell( 48517 ,{ name = "Solar Eclipse", timeless = true, duration = 0.1, short = "Solar", color = colors.ORANGE }) -- Wrath boost
-- Spell( 48518 ,{ name = "Lunar Eclipse", timeless = true, duration = 0.1, short = "Lunar", color = colors.LBLUE }) -- Starfire boost
Spell( 78675,{ name = "Solar Beam", duration = 10, color = colors.GOLD, target = "player" })
Spell( 2637 ,{ name = "Hibernate",duration = 40, pvpduration = 8 })
Spell( 33786 ,{ name = "Cyclone", duration = 6 })
Spell( 8921 ,{ name = "Moonfire",duration = 12, ghost = true, color = colors.PURPLE, init = function(self) self.duration = 12 + Talent(57810)*2 end })
Spell( 93402 ,{ name = "Sunfire",duration = 12, ghost = true, color = colors.ORANGE, init = function(self) self.duration = 12 + Talent(57810)*2 end })
Spell( 5570 ,{ name = "Insect Swarm",duration = 12, ghost = true, color = colors.LGREEN, init = function(self) self.duration = 12 + Talent(57810)*2 end })
Spell( 93400 ,{ name = "Shooting Stars", shine = true, duration = 12, color = colors.CURSE })
Cooldown( 78674 ,{ name = "Starsurge", resetable = true, ghost = true, color = colors.CURSE })

Spell( {106951, 50334} ,{ name = "Berserk", duration = 15 })
--cat
Spell( 9005 ,{ name = "Pounce", duration = 4, color = colors.PINK })
Spell( 9007 ,{ name = "Pounce Bleed", color = colors.RED, duration = 18 })
Spell( 33876 ,{ name = "Mangle", color = colors.CURSE, duration = 60 })
Spell( 1822 ,{ name = "Rake", duration = 15, color = colors.LRED })
Spell( 1079 ,{ name = "Rip",duration = 16, color = colors.RED })
Spell( 22570 ,{ name = "Maim", color = colors.PINK, duration = function() return GetCP() end })
Cooldown(5217, { name = "Tiger's Fury", color = colors.LBLUE})
Spell( 52610 ,{ name = "Savage Roar", color = colors.PURPLE, duration = function() return (12 + GetCP() * 6) end })
Spell( 127538 ,{ name = "Savage Roar", color = colors.PURPLE, duration = 12 }) -- glyphed version
Spell( 1850 ,{ name = "Dash", duration = 15 })
-- Spell( 81022 ,{ name = "Stampede", duration = 8 })
--bear
Spell( 132402 ,{ name = "Savage Defense", duration = 6, color = colors.WOO2 })
Spell( 115798 ,{ name = "Weakened Blows", specmask = 0x0F00, short = "WeakBlows", priority = -20, affiliation = "any", singleTarget = true, color = {149/255, 121/255, 214/255}, duration = 30 })
Spell( 106922 ,{ name = "Might of the Ursoc", duration = 20, color = colors.BLACK })
Spell( 99 ,{ name = "Disorienting Roar", short = "Disorient", duration = 3, multiTarget = true })
Spell( 6795 ,{ name = "Taunt", duration = 3 })
Spell( 33745 ,{ name = "Lacerate", duration = 15, color = colors.RED })
-- Spell( 5209 ,{ name = "Challenging Roar", shine = true, duration = 6, multiTarget = true })
Spell( 45334 ,{ name = "Wild Charge",duration = 4, color = colors.LRED }) --bear
Spell( 5211 ,{ name = "Bash",duration = 5, shine = true, color = colors.PINK })
Cooldown( 77758, { name = "Thrash", color = colors.LBLUE })
Cooldown( 33745 ,{ name = "Lacerate", color = colors.PURPLE })
Cooldown( 33878 ,{ name = "Mangle", resetable = true, color = colors.CURSE })
Spell( 93622 ,{ name = "Reset", shine = true, color = colors.CURSE, duration = 5 })
Spell( 102795 ,{ name = "Bear Hug", duration = 3, color = colors.RED })

Spell( 102359 ,{ name = "Mass Entanglement", duration = 20, color = colors.BROWN })
Spell( 102351 ,{ name = "Cenarion Ward",duration = 30, color = colors.WOO2 })
Spell( 102352 ,{ name = "Cenarion Ward",duration = 6, color = colors.TEAL })

Spell( 117679 ,{ name = "Incarnation: Tree of Life", short = "Incarnation", duration =  30, color = colors.TEAL2 })
Spell( 102558 ,{ name = "Incarnation: Son of Ursoc", short = "Incarnation", duration =  30, color = colors.TEAL2 })
Spell( 102560 ,{ name = "Incarnation: Chosen of Elune", short = "Incarnation", duration =  30, color = colors.TEAL2 })
Spell( 102543 ,{ name = "Incarnation: King of the Jungle", short = "Incarnation", duration =  30, color = colors.TEAL2 })



Spell( 102342 ,{ name = "Ironbark",duration = 12 })
Spell( 22812 ,{ name = "Barkskin",duration = 12 })
Spell( 61336 ,{ name = "Survival Instincts", color = colors.BLACK, duration = 12 })
Spell( 124974 ,{ name = "Nature's Vigil", color = colors.TEAL2, duration = 30 })
Spell( 132158 ,{ name = "Nature's Swiftness", timeless = true, duration = 0.1, color = colors.TEAL, short = "NS" })
Spell( 774 ,{ name = "Rejuvenation",duration = 12, color = { 1, 0.2, 1} })
Spell( 8936 ,{ name = "Regrowth",duration = 6, color = { 198/255, 233/255, 80/255} })
Spell( 33763 ,{ name = "Lifebloom", shinerefresh = true, recast_mark = 3, duration = 10, init = function(self)self.duration = 7 + Talent(57865)*2 end, stackcolor = {
                                                                            [1] = { 0, 0.8, 0},
                                                                            [2] = { 0.2, 1, 0.2},
                                                                            [3] = { 0.5, 1, 0.5},
                                                                        }})
Spell( 48438 ,{ name = "Wild Growth", duration = 7, multiTarget = true, color = colors.LGREEN })
Spell( 29166 ,{ name = "Innervate",duration = 10 })
Spell(100977,{ name = "Harmony", color = colors.BLACK, recast_mark = 2.5, duration = 10 })
-- Spell( 16870 ,{ name = "Clearcasting",  duration = 15 })
end

if class == "HUNTER" then
EventTimer({ spellID = 131894, event = "SPELL_CAST_SUCCESS", name = "A Murder of Crows", duration = 30, color = colors.LBLUE })
Spell( 51755 ,{ name = "Camouflage", duration = 60, target = "player", color = colors.CURSE })
Spell( 19263 ,{ name = "Deterrence", duration = 5, color = colors.LBLUE })

--Spell( 77769 ,{ name = "Trap Launcher", shine = true, timeless = true, duration = 0.1, color = colors.CURSE })
--Spell( 53220 ,{ name = "Steady Focus", duration = 10, color = colors.BLACK })

Spell( 82925 ,{ name = "Ready, Set, Aim...", short = "", duration = 30, shinerefresh = true, color = colors.LBLUE })
Spell( 82926 ,{ name = "Aimed Shot!", duration = 10, shine = true, color = colors.WOO2 })

Spell( 19615 ,{ name = "Frenzy", duration = 10, target = "player", color = colors.CURSE })
Spell( 82654 ,{ name = "Widow Venom", duration = 30, color = { 0.1, 0.75, 0.1} })

Spell( 56453 ,{ name = "Lock and Load", duration = 12, color = colors.LRED })
Spell( 19574 ,{ name = "Bestial Wrath", duration = 18, color = colors.LRED })
Spell( 82692 ,{ name = "Focus Fire", duration = 20, color = colors.GOLD })


Spell( 136 ,{ name = "Mend Pet", duration = 10, color = colors.LGREEN })

--Spell( 2974 ,{ name = "Wing Clip", duration = 10, pvpduration = 8, color = { 192/255, 77/255, 48/255} })
--Spell( 19306 ,{ name = "Counterattack", duration = 5, color = { 192/255, 77/255, 48/255} })
Spell( 13797 ,{ name = "Immolation Trap", duration = 15, color = colors.ORANGE, init = function(self)self.duration = 15 - Glyph(56846)*6 end })
Spell( 118253 ,{ name = "Serpent Sting", duration = 15, color = colors.PURPLE })
Spell( 19503 ,{ name = "Scatter Shot", duration = 4, color = colors.CHILL })
Spell( 5116 ,{ name = "Concussive Shot", duration = 6, color = colors.CHILL, init = function(self)self.duration = 4 + Talent(19407) end })
Spell( 34490 ,{ name = "Silencing Shot", duration = 3, color = colors.PINK, short = "Silence" })

Spell( 24394 ,{ name = "Intimidation", duration = 3, color = colors.RED })
Spell( 19386 ,{ name = "Wyvern Sting", duration = 30, pvpduration = 8, short = "Wyvern",color = colors.RED })


Spell( 3355 ,{ name = "Freezing Trap", duration = 10, pvpduration = 8, color = colors.FROZEN, init = function(self)self.duration = 20 * (1+Talent(19376)*0.1) end })

Spell( 1513 ,{ name = "Scare Beast", duration = 20, pvpduration = 8, color = colors.CURSE })

Spell( 3045 ,{ name = "Rapid Fire", duration = 15, color = colors.CURSE })

Cooldown( 34026 ,{ name = "Kill Command", color = colors.LRED })
Cooldown( 53209 ,{ name = "Chimera Shot", color = colors.RED })
Cooldown( 53301 ,{ name = "Explosive Shot", color = colors.RED })
Cooldown( 3674 ,{ name = "Black Arrow", color = colors.CURSE })

Spell( 128405 ,{ name = "Narrow Escape", duration = 8, color = colors.BROWN, multiTarget = true })
Spell( 117526 ,{ name = "Binding Shot", duration = 5, pvpduration = 3, color = colors.RED, multiTarget = true })

Cooldown( 130392 ,{ name = "Blink Strike", color = colors.WOO })
Cooldown( 109259 ,{ name = "Powershot", color = colors.BLACK })
Cooldown( 117050 ,{ name = "Glaive Toss", color = colors.BLACK })
Cooldown( 120360 ,{ name = "Barrage", color = colors.BLACK })

end

if class == "SHAMAN" then
Spell( 8056 ,{ name = "Frost Shock", duration = 8, color = colors.CHILL, short = "FrS" })

Spell( 16188 ,{ name = "Ancestal Swiftness", timeless = true, duration = 0.1, color = colors.TEAL, shine = true, short = "Swiftness" })
Spell( 61295 ,{ name = "Riptide", duration = 15, color = colors.FROZEN })
Spell( 76780 ,{ name = "Bind Elemental", duration = 50, pvpduration = 8, color = colors.PINK })
Spell( 51514 ,{ name = "Hex", duration = 50, pvpduration = 8, color = colors.CURSE })
Spell( 79206 ,{ name = "Spiritwalker's Grace", duration = 10, color = colors.LGREEN })

Spell( 8050 ,{ name = "Flame Shock", duration = 18, color = colors.PURPLE })
Spell( 16166 ,{ name = "Elemental Mastery", duration = 30, color = colors.CURSE })
Cooldown( 8056 ,{ name = "Shock", color = colors.LRED })
Cooldown( 51505 ,{ name = "Lava Burst", color = colors.RED, resetable = true })
Spell( 77762 ,{ name = "Flame Surge", duration = 18, color = colors.FIRE, shine = true })
Cooldown( 51490 ,{ name = "Thunderstorm", color = colors.WOO2 })

Spell( 30823 ,{ name = "Shamanistic Rage", duration = 15, color = colors.BLACK })
Cooldown( 60103 ,{ name = "Lava Lash", color = colors.RED })
Spell( 53817 ,{ name = "Maelstrom Weapon", duration = 12, color = colors.PURPLE, short = "Maelstrom" })
Cooldown( 17364 ,{ name = "Stormstrike", color = colors.CURSE })
Cooldown( 73680 ,{ name = "Unleash Elements", color = colors.WOO, short = "Unleash" })

Spell({ 114050, 114051, 114052} ,{ name = "Ascendance", duration = 15, color = colors.PINK }) --ele, enh, resto
Spell( 108271 ,{ name = "Astral Shift", duration = 6, color = colors.BLACK })
Spell( 63685 ,{ name = "Freeze", duration = 5, color = colors.FROZEN })
Cooldown( 117014 ,{ name = "Elemental Blast", color = colors.BLACK })


-- TOTEMS
NugRunningConfig.totems[1] = { name = "Fire", color = {1,80/255,0}, hideName = false, priority = -77 }
NugRunningConfig.totems[2] = { name = "Earth", color = {74/255, 142/255, 42/255}, priority = -78 }
NugRunningConfig.totems[3] = { name = "Water", color = { 65/255, 110/255, 1}, priority = -79 }
NugRunningConfig.totems[4] = { name = "Air", color = {0.6, 0, 1}, priority = -80 }

end