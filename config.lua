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
local Cast = helpers.Cast
local Anchor = helpers.Anchor
local Talent = helpers.Talent
local Glyph = helpers.Glyph
local GetCP = helpers.GetCP
local _,class = UnitClass("player")

NugRunningConfig.texture = "Interface\\AddOns\\NugRunning\\statusbar"
-- NugRunningConfig.texture = "Interface\\TargetingFrame\\UI-StatusBar"
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
colors["RED2"] = { 1, 0, 0}
-- colors["RED3"] = { 183/255, 58/255, 93/255}
colors["LRED"] = { 1,0.4,0.4}
colors["DRED"] = { 0.55,0,0}
colors["CURSE"] = { 0.6, 0, 1 }
colors["PINK"] = { 1, 0.3, 0.6 }
colors["PINK2"] = { 1, 0, 0.5 }
colors["PINK3"] = { 226/255, 35/255, 103/255 }
colors["PINKIERED"] = { 206/255, 4/256, 56/256 }
colors["TEAL"] = { 0.32, 0.52, 0.82 }
colors["TEAL2"] = {38/255, 221/255, 163/255}
colors["TEAL3"] = {52/255, 172/255, 114/255}
colors["DTEAL"] = {15/255, 78/255, 60/255}
colors["ORANGE"] = { 1, 124/255, 33/255 }
colors["ORANGE2"] = { 1, 66/255, 0 }
colors["FIRE"] = {1,80/255,0}
colors["LBLUE"] = {149/255, 121/255, 214/255}
colors["DBLUE"] = { 50/255, 34/255, 151/255 }
colors["GOLD"] = {1,0.7,0.5}
colors["LGREEN"] = { 0.63, 0.8, 0.35 }
colors["GREEN"] = {0.3, 0.9, 0.3}
colors["DGREEN"] = { 0, 0.35, 0 }
colors["PURPLE"] = { 187/255, 75/255, 128/255 }
colors["PURPLE2"] = { 188/255, 37/255, 186/255 }
colors["REJUV"] = { 1, 0.2, 1}
colors["PURPLE3"] = { 64/255, 48/255, 109/255 }
colors["PURPLE4"] = { 121/255, 29/255, 57/255 }
colors["DPURPLE"] = {74/255, 14/255, 85/255}
colors["DPURPLE2"] = {113/255, 17/255, 119/255}
colors["CHIM"] = {199/255, 130/255, 255/255}
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

local DotSpell = function(id, opts)
    if type(opts.duration) == "number" then
        local m = opts.duration*0.3 - 0.2
        opts.recast_mark = m
        opts.overlay = {0, m, 0.25}
    end
    return Spell(id,opts)
end
helpers.DotSpell = DotSpell

local _, race = UnitRace("player")
if race == "Troll" then Spell( 26297 ,{ name = "Berserking", duration = 10 }) end --Troll Racial
if race == "Orc" then Spell({ 33702,33697,20572 },{ name = "Blood Fury", duration = 15 }) end --Orc Racial

Spell( 2825  ,{ name = "Bloodlust", duration = 40, priority = -100, color = colors.DRED, shine = true, affiliation = "raid", target = "player" })
Spell( 32182 ,{ name = "Heroism", duration = 40, priority = -100, color = colors.DRED, shine = true, affiliation = "raid", target = "player" })
Spell( 80353 ,{ name = "Time Warp", duration = 40, priority = -100, color = colors.DRED, shine = true, affiliation = "raid", target = "player" })

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
--so all values are just 1s less than 50% of base duration without haste to be safe
--Immolate
Spell( 157736,{ name = "", recast_mark = 7.2, overlay = {0, 7.2, 0.2},  duration = 15, nameplates = true, priority = 10, ghost = true, color = colors.RED })


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
Spell( 603 ,{ name = "", duration = 60, recast_mark = 29, overlay = {0,29, 0.2}, nameplates = true,  ghost = true, priority = 6, color = colors.WOO })
-- REMOVED_DOSE event is not fired for molten core, so it's stuck at 3

Cooldown( 105174, { name = "Hand of Gul'dan",  ghost = true, shinerefresh = true, color = colors.CURSE })
-- Cooldown( 124916, { name = "Chaos Wave",  color = colors.CURSE })
-- Spell( 47960 ,{ name = "Shadowflame", duration = 6, multiTarget = true })

Spell( 104773,{ name = "Unending Resolve",duration = 12, color = colors.WOO2 })
Spell( 113860 ,{ name = "Dark Soul: Misery",duration = 20, short = "DarkSoul", color = colors.PINKIERED })
Spell( 113861 ,{ name = "Dark Soul: Knowledge",duration = 20, short = "DarkSoul", color = colors.PINKIERED })
Spell( 113858 ,{ name = "Dark Soul: Instability",duration = 20, short = "DarkSoul", color = colors.PINKIERED })


Spell( 137587,{ name = "Kil'Jaeden's Cunning", duration = 8, shine = true, color = colors.LGREEN })
Spell( 108508,{ name = "Mannoroth's Fury", duration = 10, shine = true, color = colors.LGREEN })


Spell( 86211 ,{ name = "Soul Swap", duration = 20, shine = true, color = colors.BLACK })
-- Spell( 17941 ,{ name = "Nightfall", duration = 10, shine = true, color = colors.CURSE })
Spell( 103103 ,{ name = "Drain Soul", tick = 1, overlay = {"tick", "tickend"},  priority = 14, duration = 4, color = colors.CURSE, target = "target" })

--Haunt, recast mark is for execute phase. 3s is cast time + travel time from 30+yd range
local normalize_dots_to = nil--26
-- local haunt_overlay = {0,8, 0.15}
--Haunt
Spell( 48181 ,{ name = "",duration = 12, priority = 8, recast_mark = 3, ghost = true, nameplates = true, color = colors.TEAL })
-- 8s second overlay is for haunt duration
Spell( 157698 ,{ name = "Haunting Spirits", color = colors.PURPLE, scale = .8, glowtime = 5,  duration = 30 })


--Unstable Affliction
Spell( 30108 ,{ name = "", duration = 15, recast_mark = 6.75, overlay = {0, 6.75, 0.2},  priority = 10,  fixedlen = normalize_dots_to, nameplates = true, ghost = true, color = colors.RED })

--Agony
Spell( 980 ,{ name = "", duration = 24, recast_mark = 11.75, overlay = {0, 11.75, 0.2},  fixedlen = normalize_dots_to, nameplates = true, _ignore_applied_dose = true, ghost = true, priority = 6, color = colors.WOO })

--Corruption (2nd is a Soulburn SoC Corruption) --87389
local patch50400 = select(4,GetBuildInfo()) >= 50400

-- 172 - original id, 146739 - ptr 5.4 for both soc corruption and normal
if patch50400 then
    Spell( 146739 ,{ name = "", duration = 18, recast_mark = 8.7, overlay = {0,8.7, 0.2}, priority = 9, fixedlen = normalize_dots_to, nameplates = true, ghost = true, color = colors.PINK })
else
    Spell( 172 ,{ name = "", duration = 18, tick = 3, priority = 9, overlay = {0,8, 0.2},  fixedlen = normalize_dots_to, nameplates = true, ghost = true, color = colors.PINK })
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

-- Spell( 109466 ,{ name = "Curse of Enfeeblement",duration = 30, color = colors.CURSE, short = "CoEnf" })
-- Spell( 18223 ,{ name = "Curse of Exhaustion", duration = 30, pvpduration = 8, color = colors.CURSE, short = "CoEx" })
-- Spell( {1490, 104225},{ name = "Curse of Elements", duration = 300, affiliation = "any", singleTarget = true, glowtime = 15, color = colors.CURSE, pvpduration = 120, short = "CoE" })
--aoe version
-- Spell( 104225 ,{ name = "Curse of Elements",duration = 300, glowtime = 15, color = colors.CURSE, pvpduration = 120, short = "CoE", multiTarget = true })
Spell( 60478 ,{ name = "Doomguard", duration = 60 })

Spell( 6358 ,{ name = "Seduction",duration = 30, pvpduration = 8 })
Spell( 89766 ,{ name = "Axe Toss", color = colors.BROWN, duration = 4 })

Spell( 6789 ,{ name = "Mortal Coil", duration = 3 })
Spell( 5484 ,{ name = "Howl of Terror", duration = 20, pvpduration = 8, multiTarget = true })
Spell( 110913 ,{ name = "Dark Bargain", duration = 10 })
Spell( 108416 ,{ name = "Sacrificial Pact", duration = 10 })
Spell( 30283 ,{ name = "Shadowfury", duration = 3, multiTarget = true })

Spell( 5782 ,{ name = "Fear", duration = 20, nameplates = true, pvpduration = 8 })
Spell( 118699 ,{ name = "Blood Fear", duration = 20, pvpduration = 8 })
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
-- Spell( 89485 ,{ name = "Inner Focus", shine = true, color = colors.LBLUE, timeless = true, duration = 0.1 })
-- Spell( 49694,59000 ,{ name = "Improved Spirit Tap",duration = 8 })
-- Spell( 15271 ,{ name = "Spirit Tap",duration = 15 })
DotSpell( 589 ,{ name = "Shadow Word: Pain", short = "", duration = 18, ghost = true, nameplates = true, priority = 9, color = colors.PURPLE,  })

EventTimer({ event = "SPELL_SUMMON", spellID = 123040, name = "Mindbender", group = "buffs", duration = 15, priority = -10, color = colors.BLACK })
EventTimer({ event = "SPELL_SUMMON", spellID = 34433, name = "Shadowfiend", group = "buffs", duration = 12, priority = -10, color = colors.BLACK })

DotSpell( 34914 ,{ name = "Vampiric Touch", short = "", ghost = true, nameplates = true,  priority = 10, duration = 15, color = colors.RED,  })
Spell( 158831 ,{ name = "Devouring Plague",duration = 6, priority = 8, nameplates = true, color = colors.WOO, short = "Plague" })
DotSpell( 155361 ,{ name = "Void Entropy", duration = 60, priority = 7, nameplates = true, color = colors.CURSE })
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

Spell( 155274 ,{ name = "Saving Grace", duration = 10, color = colors.DRED })


Spell( 9484 ,{ name = "Shackle Undead",duration = 50, pvpduration = 8, short = "Shackle" })
Spell( 15487 ,{ name = "Silence",duration = 5, color = colors.PINK })

Spell( 64044 ,{ name = "Psychic Horror", duration = 3, pvpduration = 4 })
Spell( 8122 ,{ name = "Psychic Scream", duration = 8, multiTarget = true })
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


-- helpers.TrackItemSet("Shadow_T15", {
--     96674, 96675, 96676, 96677, 96678, --heroic
--     95300, 95301, 95302, 95303, 95304, --normal
--     95930, 95931, 95932, 95933, 95934, --lfr
-- })
-- helpers.RegisterSetBonusCallback("Shadow_T15", 2,
--     function()
--         scanner = scanner or CreateFrame("Frame", nil, UIParent)
--         scanner:SetScript("OnUpdate", scannerOnUpdate)
--     end, 
--     function()
--         scanner:SetScript("OnUpdate", nil)
--     end
-- )

end


if class == "ROGUE" then
Spell( 1966  ,{ name = "Feint", duration = 5, priority = -1, shine = true, shinerefresh = true, color = colors.LBLUE })
Spell( 2983  ,{ name = "Sprint", shine = true, duration = 8 })
Spell( 5277  ,{ name = "Evasion", color = colors.PINK, duration = 15 })
Spell( 31224 ,{ name = "Cloak of Shadows", color = colors.CURSE, duration = 5, short = "CloS" })
Spell( 73651 ,{ name = "Recuperate", shinerefresh = true, color = colors.LGREEN ,duration = function() return (6 * GetCP()) end })
Spell( 5171  ,{ name = "Slice and Dice", shinerefresh = true, fixedlen = 24, short = "SnD", color = colors.PURPLE,
    duration = function() return (6 + GetCP()*6) end,
}) -- SnD fixedlen set to match Rupture maximum duration
Spell( 122233,{ name = "Crimson Tempest", short = "Tempest", color = colors.RED, duration = 12, multiTarget = true })
    
Spell( 1833  ,{ name = "Cheap Shot", duration = 4, color = colors.LRED })
Spell( 408   ,{ name = "Kidney Shot", shine = true, duration = function() return 1+GetCP() end, color = colors.LRED })
Spell( 1776  ,{ name = "Gouge", color = colors.PINK, duration = 4 })
Spell( 2094  ,{ name = "Blind",duration = 60, pvpduration = 8, color = {0.20, 0.80, 0.2} })

-- Spell( 113746 ,{ name = "Weakened Armor", short = "WeakArmor", priority = -10, anySource = true, singleTarget = true, color = colors.BROWN, duration = 30 })

-- Spell( 51722 ,{ name = "Dismantle",duration = 10,color = colors.LRED }) --removed
Spell( 6770  ,{ name = "Sap",duration = 60, color = colors.LBLUE })

Spell( 1943  ,{ name = "Rupture", shinerefresh = true, fixedlen = 24, color = colors.RED,
    duration = function() return (4 + GetCP() * 4) end,
})
Spell( 703   ,{ name = "Garrote", color = colors.RED, duration = 18 })
Spell( 1330  ,{ name = "Silence", color = colors.PINK, duration = 3 })

--Spell( 3409 ,{ name = "Crippling Poison", color = { 192/255, 77/255, 48/255}, duration = 12, short = "Crippling" })

Spell( 32645 ,{ name = "Envenom", color = { 0, 0.65, 0}, duration = function() return (1+GetCP()) end })
Spell( 79140 ,{ name = "Vendetta", shine = true, color = colors.CURSE, duration = 20 })
Spell( 121153,{ name = "Blindside", shine = true, color = colors.TEAL, duration = 10 })

Spell( 137573,{ name = "Burst of Speed", short = "Burst", shine = true, duration = 4 })
Spell( 14183 ,{ name = "Premeditation",duration = 20, color = colors.CURSE })                    
Spell( 74002 ,{ name = "Combat Insight", shine = true, shinerefresh = true, duration = 10, color = colors.CURSE })

Spell( 84745 ,{ name = "Shallow Insight", short = "1x Insight", shine = true, color = colors.CURSE, group = "buffs", duration = 15 })
Spell( 84746 ,{ name = "Moderate Insight", short = "2x Insight", shine = true, color = colors.CURSE, group = "buffs", duration = 15 })
Spell( 84747 ,{ name = "Deep Insight", short = "3x Insight", shine = true, color = colors.CURSE, group = "buffs", duration = 15 })
Spell( 13750 ,{ name = "Adrenaline Rush",duration = 15, color = colors.LRED })
Spell( 13877 ,{ name = "Blade Flurry",duration = 15, color = colors.LRED, timeless = true })

DotSpell( 84617 ,{ name = "Revealing Strike", duration = 24, color = colors.WOO })
Spell( 51690 ,{ name = "Killing Spree", duration = 3, shine = true, color = colors.RED  })
Spell( 51690 ,{ name = "Internal Bleeding", duration = 12, color = colors.DRED  })
Cooldown( 152150 ,{ name = "Death from Above", color = colors.DBROWN  })

Spell( 51713 ,{ name = "Shadow Dance",duration = 8, color = colors.BLACK })
-- Spell( 89775 ,{ name = "Hemo",duration = 60, color = colors.CURSE })
-- Spell( 91021 ,{ name = "Find Weakness", duration = 10, color =  colors.LRED })

--Spell( 1784 ,{ name = "Stealth", color = colors.CURSE, timeless = true, duration = 0.1})
Spell( 114018,{ name = "Shroud of Concealment", short = "Shroud", color = colors.BLACK, duration = 15 })

Spell( 152151,{ name = "Shadow Reflection", recast_mark = 8, overlay = { 0, 8}, short = "Reflection", color = colors.CURSE, duration = 16 })

EventTimer({ event = "SPELL_CAST_SUCCESS", spellID = 1725, name = "Distract", color = colors.PURPLE, duration = 10 })
EventTimer({ event = "SPELL_CAST_SUCCESS", spellID = 76577, name = "Smoke Bomb", color = colors.BLACK, duration = 5 })
end

if class == "WARRIOR" then
-- Spell( 6673 ,{ name = "Battle Shout", target = "player", glowtime = 10, priority = -10, color = colors.DPURPLE, duration = 120 })
-- Spell( 469 ,{ name = "Commanding Shout", target = "player", priority = -10, glowtime = 10, short = "CommShout", color = colors.DPURPLE, duration = 120 })
Spell( 132404 ,{ name = "Shield Block", color = colors.WOO2, shine = true, group = "buffs", priority = - 9, duration = 6 })
Spell( 169667 ,{ name = "Shield Charge", shine = true, color = colors.PURPLE2, group = "buffs", priority = - 9, duration = 6 })
Cooldown( 2565 ,{ name = "", priority = 9.9, fixedlen = 9, scale = .5, ghost = true, color = colors.DPURPLE, }) -- shield block cd
Cooldown( 156321 ,{ name = "", priority = 9.9, fixedlen = 9, scale = .5, ghost = true, color = colors.DPURPLE, }) -- shield charge cd
Spell( 112048 ,{ name = "Shield Barrier", ghost = 1.3, group = "buffs", priority = -8, color = colors.WOO, duration = 6 })
-- Spell( 85730 ,{ name = "Deadly Calm", group = "buffs", duration = 10 })
Spell( 12328 ,{ name = "Sweeping Strikes", priority = 9, ghost = 1, color = colors.DBROWN, short = "Sweeping", duration = 10 })
-- Spell( 115767 ,{ name = "Deep Wounds", color = colors.DRED, duration = 15, singleTarget = true })

-- Spell( 20511 ,{ name = "Intimidating Shout", short = "Fear", duration = 8, multiTarget = true }) --removed

DotSpell( 772 ,{ name = "Rend", color = colors.RED, duration = 18, ghost = true })
Spell( {167105, 86346} ,{ name = "Colossus Smash", shine = true, priority = -100500, color = colors.PURPLE2, duration = 6 }) --debuff
--different versions of spell for arms and fury
Cooldown( 167105,{ name = "Colossus Smash", priority = 9.5, overlay = {0,"gcd",.3}, scale = .7, check_known = true, ghost = true, color = colors.PINKIERED, resetable = true, duration = 20 })
Cooldown( 86346 ,{ name = "Colossus Smash", priority = 9.5, overlay = {0,"gcd",.3}, scale = .7, check_known = true, ghost = true, color = colors.PINKIERED, resetable = true, duration = 20 })

-- Spell( 676  ,{ name = "Disarm", color = colors.BROWN, duration = 10 }) --removed
Spell( 1715 ,{ name = "Hamstring", ghost = true, color = colors.PURPLE, duration = 15, pvpduration = 8 })

-- Spell( 12809 ,{ name = "Concussion Blow", color = { 1, 0.3, 0.6 }, duration = 5 })
-- Spell( 355 ,{ name = "Taunt", duration = 3 })
-- Spell( 113746 ,{ name = "Weakened Armor", specmask = 0xF00, short = "WeakArmor", priority = -10, affiliation = "any", singleTarget = true, color = colors.BROWN, duration = 30 })
-- Demo shout also applies self-buff (id 125565), but it doesn't appear in combat log
Spell( 1160 ,{ name = "Demoralizing Shout", short = "DemoShout", shine = true, group = "buffs", color = colors.BLACK, duration = 10, multiTarget = true })
Spell( 122510 ,{ name = "Ultimatum", shine = true, color = colors.TEAL, glowtime = 10, duration = 10, priority = 11, scale = .7 })
Cooldown( 6572 ,{ name = "Revenge", priority = 5, color = colors.PURPLE, resetable = true, fixedlen = 9, ghost = true })
-- Activation( 6572, { name = "RevengeActivation", for_cd = true })

Spell( 55694 ,{ name = "Enraged Regeneration", short = "Regen", color = colors.LGREEN, duration = 5 })
Spell( 132168 ,{ name = "Shockwave", color = colors.CURSE, shine = true, duration = 4, multiTarget = true, })
Cooldown( 46968 ,{ name = "Shockwave", fixedlen = 9, ghost = 3, priority = 2, color = colors.WOO2DARK, color2 = colors.PINK2 })
Cooldown( 107570 ,{ name = "Storm Bolt", fixedlen = 9, ghost = 3, priority = 2, color = colors.WOO2DARK, color2 = colors.PINK2 })
Cooldown( 118000 ,{ name = "Dragon Roar", fixedlen = 9, ghost = 3, priority = 2, color = colors.WOO2DARK, color2 = colors.PINK2, hide_until = 15 })
--can't use with_cooldown on shockwave, because without effect applied first it's not working.
--but shockwave still needs to be used on cooldown
--old enrage Spell( 85288, { name = "Enraged", shine = true, showid = 14202, color = colors.RED, duration = 10 })
Spell( 12880 ,{ name = "Enrage", color = colors.DPURPLE, group = "buffs", specmask = 0x0FF, priority = -7, shine = true, shinerefresh = true, duration =6 })

Spell( 12323 ,{ name = "Piercing Howl", multiTarget = true, duration = 15 })
Spell( 107566 ,{ name = "Staggering Shout", duration = 5 })
-- Spell( 105771 ,{ name = "Charge Root", duration = 3 }) 
Spell( 107574 ,{ name = "Avatar", shine = true, group = "buffs",  color = colors.TEAL2, duration = 30 })
Spell( 132169 ,{ name = "Storm Bolt", color = colors.TEAL2, duration = 3})

--banners are totems actually
Spell( 114192 ,{ name = "Mocking Banner", color = colors.PURPLE2, duration = 20})
-- EventTimer({ spellID = 114207, event = "SPELL_CAST_SUCCESS", group = "buffs", affiliation = "raid", name = "Skull Banner", duration = 10, color = colors.RED })
-- EventTimer({ spellID = 114203, event = "SPELL_CAST_SUCCESS", group = "buffs", name = "Demoralizing Banner", affiliation = "raid", short = "DemoBanner", duration = 15, color = colors.BLACK })
Spell( 1719 ,{ name = "Recklessness", color = colors.LRED, group = "buffs", duration = 20})
Spell( 64382 ,{ name = "Shattering Throw", short = "Shattering", color = colors.TEAL, group = "buffs", duration = 10})
-- Cooldown( 107570, { name = "Storm Bolt", color = colors.TEAL2 })
Spell( 12292 ,{ name = "Bloodbath", priority = -8, group = "buffs", color = colors.PINKIERED, duration = 12, })
    --with_cooldown = { id = 12292, name = "Bloodbath", priority = -8, glowtime = 5, color = colors.DRED }    })


Spell( 52437, { name = "Sudden Death", priority = 11, scale = .8, glowtime = 10, shine = true, color = colors.RED2, duration = 10 })
Spell( 169686, { name = "Exquisite Proficiency", duration = 6, priority = -5, stackcolor = {
                                                                            [1] = { .3, 0, 0},
                                                                            [2] = { .4, 0, 0},
                                                                            [3] = { .6, 0, 0},
                                                                            [4] = { .8, 0, 0},
                                                                            [5] = { 1, 0, 0},
                                                                            [6] = { 1, 0, 0},
                                                                        }})



--Spell( 56112 ,{ name = "Furious Attacks", duration = 10 })
--Activation( 5308, { name = "Execute", shine = true, timeless = true, color = colors.CURSE, duration = 0.1 })

Cooldown( 12294, { name = "Mortal Strike", tick = 1.5, tickshine = true, overlay = {"tick", "end"}, priority = 10, short = "", check_known = true, fixedlen = 9, ghost = true,  color = colors.CURSE })
-- these popups are for visual confirmation
EventTimer({ spellID = 1464, event = "SPELL_CAST_SUCCESS", priority = 12, name = "Slam", duration = 0.5, color = colors.PINK })
EventTimer({ spellID = 1680, event = "SPELL_CAST_SUCCESS", priority = 12, name = "Whirlwind", duration = 0.5, color = colors.PINK })
EventTimer({ spellID = 5308, event = "SPELL_CAST_SUCCESS", priority = 12, name = "Execute", duration = 0.5, color = colors.PINK })
EventTimer({ spellID = 20243, event = "SPELL_CAST_SUCCESS", priority = 12, name = "Devastate", duration = 0.5, color = colors.PINK })
EventTimer({ spellID = 100130, event = "SPELL_CAST_SUCCESS", priority = 12, name = "Wild Strike", duration = 0.5, color = colors.PINK })
EventTimer({ spellID = 78, event = "SPELL_CAST_SUCCESS", priority = 12.1, name = "Heroic Strike", scale = .7, duration = 0.5, shine = true, color = colors.ORANGE2 })
EventTimer({ spellID = -1, event = "SPELL_CAST_SUCCESS", priority = 12, name = "Bloodthirst", duration = 0.5, color = colors.PINK,
        init = function(self) if IsSpellKnown(169683) then self.spellID = 23881 else self.spellID = -1 end end})

-- special timer
-- Spell( 7384, { name = "Overpower", overlay = {0,-4.5, 0.15}, priority = 11, shine = true, shinerefresh = true, color = colors.PINKIERED, recast_mark = -4.5, duration = 9})
--Activation( 7384, { name = "Overpower", short = "", shine = true, color = colors.RED, recast_mark = 4.5, duration = 9})
-- Spell( 125831 ,{ name = "Taste for Blood", glowtime = 5, shinerefresh = true, shine = true, color = colors.TEAL, duration = 15 }) -- Taste for blood
-- Spell( 60503 ,{ name = "Overpower", priority = 9, overlay = {0,7, 0.3}, fixedlen = 9, shinerefresh = true, shine = true, color = colors.PINKIERED, duration = 12 }) -- Taste for blood --removed

Cooldown( 23881, { name = "Bloodthirst", tick = 1.5, tickshine = true, overlay = {"tick", "end"}, short = "", priority = 10, check_known = true, ghost = true, fixedlen = 6,  color = colors.CURSE })
Spell( 46916 ,{ name = "Bloodsurge", shine = true, priority = 8, color = colors.TEAL, duration = 10 })

Spell( 131116 ,{ name = "Raging Blow", priority = 9, fixedlen = 9, shine = true, shinerefresh = true, duration = 12, stackcolor = {
                                                                                                [1] = colors.WOO,
                                                                                                [2] = colors.PINK3,
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

Spell( 12975, { name = "Last Stand", color = colors.BLACK, duration = 20, group = "buffs" })
Spell( 97463, { name = "Rallying Cry", color = colors.BLACK, target = "player", duration = 10, group = "buffs" })
Spell( 118038, { name = "Die by the Sword", short = "DbtS", color = colors.BLACK, duration = 8, group = "buffs" })
Spell( 871, { name = "Shield Wall", color = colors.WOO2, duration = 12, group = "buffs" })
Cooldown( 23922, { name = "Shield Slam", tick = 1.5, tickshine = true, overlay = {"tick", "end"}, short = "", priority = 10, check_known = true, fixedlen = 9, ghost = true,  color = colors.CURSE, resetable = true })

-- Cooldown( 78, { name = "Heroic Strike", short = "Heroic", fixedlen = 6, ghost = true })
Cooldown( 6343, { name = "Thunder Clap", ghost = true, short = "", scale = 0.7,overlay = {0,"gcd",.3}, specmask = 0xF00, color = colors.PINKIERED, fixedlen = 9, priority = 9.5 })
Spell( 32216, { name = "Victory Rush", group = "buffs", priority = -9, color = colors.PURPLE, duration = 20})
Cooldown( 103840, { name = "Impending Victory", priority = -4, color = colors.PURPLE, ghost = true })

Spell( 152277 ,{ name = "Ravager", color = colors.DRED, group = "buffs", duration = 10 })
-- Spell( 156288 ,{ name = "Ignite Weapon", color = colors.BROWN, priority = 3, duration = 10, ghost = true, shine = true })
Cooldown( 176289 ,{ name = "Siegebreaker", shine = true, fixedlen = 9, ghost = true, color = colors.BROWN, hide_until = 15 })

end

if class == "MONK" then
-- Spell( 120086, { name = "Fists of Fury", color = colors.BLUE, duration = 4 })
Spell( 120954, { name = "Fortifying Brew", group = "buffs", color = colors.BLACK, duration = 20 })
Spell( 115078, { name = "Paralysis", color = colors.PURPLE, duration = 30, pvpduration = 8 })
Spell( 115072, { name = "Expel Harm", color = colors.TEAL })

Spell( 118864 ,{ name = "CB: Tiger Palm", short = "Combo Breaker", scale = .8, priority = 6.1, glowtime = 15, color = colors.TEAL2, duration = 15 })
Spell( 116768 ,{ name = "CB: Blackout Kick", short = "Combo Breaker", scale = .8, priority = 6, glowtime = 15, color = colors.PINK3, duration = 15 })
Spell( 159407 ,{ name = "CB: Chi Explosion", short = "Combo Breaker", scale = .8, priority = 6, glowtime = 15, color = colors.PINK3, duration = 15 })

Spell( 115288 ,{ name = "Energizing Brew", priority = -9, scale = .7, shine = true, group = "buffs", color = colors.LGREEN, duration = 6 })
Spell( 125195 ,{ name = "Tigereye Brew", priority = -10, shinerefresh = true, color = colors.DBROWN, glowstack = 17, duration = 120 }) --stacks
Spell( 116740 ,{ name = "Tigereye Brew", color = colors.PINKIERED, priority = -10, group = "buffs", duration = 15, target = "player" }) --activation

Spell( 125359, { name = "Tiger Power", priority = 5, glowghost = true, color = colors.DPURPLE, color2 = colors.PURPLE, scale = .7, target = "player", ghost = 7, duration = 20 })
Spell( 127722, { name = "Serpent's Zeal", scale = .7, priority = 4.9, color2 = colors.PINK, color = colors.WOO2DARK, duration = 30 })

Cooldown( 107428, { name = "Rising Sun Kick",tick = 1, overlay = {"tick", "end", .35}, short = "Rising Sun", color = colors.CURSE, priority = 10, ghost = true })
Spell( 130320, { name = "Rising Sun Kick", short = "Rising Sun", color = colors.RED, ghost = true, duration = 15, singleTarget = true })

Cooldown( 115098, { name = "Chi Wave", color = { 29/255, 134/255, 83/255 }, fixedlen = 8, color2 = colors.LGREEN, priority = 6, ghost = true })

Cooldown( 152175 ,{ name = "Hurricane Strike", scale = .75, ghost = true, color = colors.WOO, fixedlen = 12, hide_until = 12 })


EventTimer({ event = "SPELL_SUMMON", spellID = 123904, name = "Xuen", group = "buffs", duration = 45, priority = -8, color = colors.CHILL })

helpers.Cast(113656, {name = "Fists of Fury", tick = 1, tickshine = true, overlay = {"tick", "end", .3}, color = colors.CURSE, priority = 10.1 })
Cooldown( 113656, { name = "Fists of Fury", fixedlen = 8, scale = .75, color = colors.WOO2DARK, color2 = colors.DBLUE, priority = 4, ghost =true })

Spell( 119611 ,{ name = "Renewing Mist", color = colors.LGREEN, target = "player", duration = 18 })
-- Spell( 115151 ,{ name = "Renewing Mist", color = colors.TEAL2 })
Spell( 115867 ,{ name = "Mana Tea", priority = -10, duration = 120, color = colors.DBROWN })
Cooldown( 123761 ,{ name = "Mana Tea", color = colors.CURSE })
Spell( 116849 ,{ name = "Life Cocoon", color = colors.PURPLE, duration = 12 })

-- Cooldown( 116680 ,{ name = "Thunder Focus Tea", color = colors.CURSE, overlay = {0, 15}, recast_mark = 15 })
Spell( 116680 ,{ name = "Thunder Focus Tea", color = colors.CURSE, duration = 30 })
Spell( 118674 ,{ name = "Vital Mists", color = colors.TEAL2, duration = 30, stackcolor = {
                                [1] = colors.DTEAL,
                                [2] = colors.DTEAL,
                                [3] = colors.DTEAL,
                                [4] = colors.DTEAL,
                                [5] = colors.TEAL2,
                            } })
NugRunningConfig.totems[1] = { name = "", color = colors.DPURPLE, priority = - 100, hideName = true }
NugRunningConfig.totems[2] = { name = "", color = colors.WOO2DARK, priority = - 100, hideName = true }
-- Spell( 138130 ,{ name = "Clone", color = colors.RED, duration = 100, timeless = true, singleTarget = true })

Spell( 128939 ,{ name = "Elusive Brew", priority = -10, scale = .8, shinerefresh = true, duration = 30, color = colors.DBROWN, glowstack = 15 })
Spell( 115308 ,{ name = "Elusive Brew", duration = 15, group = "buffs", shine = true, color = colors.PINKIERED })
Spell( 115295, { name = "Guard", priority = -10, group = "buffs", shine = true, color = colors.WOO2, duration = 30 })

Spell( 124081 ,{ name = "Zen Sphere", duration = 16, color = { 1, 0.2, 1} })
Spell( 119381 ,{ name = "Leg Sweep", duration = 5, color = colors.RED, multiTarget = true })
Spell( 122783 ,{ name = "Diffuse Magic", duration = 6, color = colors.CURSE })
Spell( 152173 ,{ name = "Serenity", duration = 10, color = colors.TEAL2, group = "buffs", priority = -10 })
Spell( 157627 ,{ name = "Breath of the Serpent", duration = 10, color = colors.TEAL2, shine = true, affiliation = "any" })

Cooldown( 121253, { name = "Keg Smash", tick = 1, overlay = {"tick", "end", .35}, ghost = true, priority = 10, color = colors.CURSE })
Spell( 115307 ,{ name = "Shuffle", short = "", ghost = 4, glow2time = 2, glowghost = true, priority = 7, fixedlen = 12, shine = true, shinerefresh = true, color = colors.TEAL3, scale = .75, duration = 6 })
Spell( 119392 ,{ name = "Charging Ox Wave", duration = 3, color = colors.CURSE, multiTarget = true, shine = true })
Cooldown( 119392 ,{ name = "Charging Ox Wave", ghost = true, priority = 2, color = colors.WOO2DARK, color2 = colors.PINK3 })
DotSpell( 123725 ,{ name = "Breath of Fire",  priority = 11, short = "", ghost = true, shine = true, color = colors.RED, multiTarget = true, duration = 8 })
Cooldown( 116847, { name = "Rushing Jade Wind", short = "", overlay = {0,1, 0.3}, scale = .7, fixedlen = 8, color = colors.PINKIERED, ghost = true, priority = 8 })

-- Cooldown( 115072, { name = "Expel Harm", color = colors.LGREEN, resetable = true, ghost = true })

EventTimer({ spellID = 108557, event = "SPELL_CAST_SUCCESS", priority = 12, name = "Jab", duration = 0.5, color = colors.PINK3 })
EventTimer({ spellID = 100784, event = "SPELL_CAST_SUCCESS", priority = 12, name = "Blackout Kick", duration = 0.5, color = colors.REJUV })
EventTimer({ spellID = 152174, event = "SPELL_CAST_SUCCESS", priority = 12, name = "Chi Explosion", duration = 0.5, color = colors.REJUV })
EventTimer({ spellID = 100787, event = "SPELL_CAST_SUCCESS", priority = 12, name = "Tiger Palm", duration = 0.5, color = colors.PINK })
EventTimer({ spellID = 137639, event = "SPELL_CAST_SUCCESS", priority = 12, name = "Spirit", duration = 0.5, color = colors.PINK })
end

if class == "DEATHKNIGHT" then
DotSpell( 55095 ,{ name = "Frost Fever", ghost = true, color = colors.CHILL, priority = 10, singleTarget = true, duration = 30 })
DotSpell( 55078 ,{ name = "Blood Plague", ghost = true, color = colors.PURPLE, priority = 9, singleTarget = true, duration = 30 })
DotSpell( 155159 ,{ name = "Necrotic Plague", ghost = true, color = colors.PURPLE, priority = 9, singleTarget = true, duration = 30 })
Spell( 43265 ,{ name = "Death and Decay", short = "DnD", color = colors.RED, duration = 10, target = "player" })
Spell( 156004 ,{ name = "Defile", color = colors.RED, duration = 10 })
-- Cooldown( 43265 ,{ name = "Death and Decay", color = colors.GOLD, minduration = 15 })

Spell({114866, 130735, 130736}, { name = "Soul Reaper", color = colors.BLACK, duration = 5 })

Spell( 77606, { name = "Dark Simulacrum", color = colors.DPURPLE, duration = 8 })

--BLOOD
-- Spell( 56222 ,{ name = "Taunt", duration = 3 })
Spell( 171049,{ name = "Rune Tap", color = colors.WOO, duration = 3})
Spell( 55233 ,{ name = "Vampiric Blood", duration = 10, color = colors.RED })
Spell( 81256 ,{ name = "Dancing Rune Weapon", duration = 12, color = colors.BROWN })
--Spell( 49222 ,{ name = "Bone Shield", duration = 300, color = colors.WOO2 })

Spell( 81141 ,{ name = "Crimson Scourge", duration = 15, color = colors.LRED })
Spell( 50421 ,{ name = "Scent of Blood", duration = 30, color = colors.WOO2 })

--FROST
-- Spell( 57330 ,{ name = "Horn of Winter", target = "player", duration = 120, glowtime = 8, color = colors.CURSE, short = "Horn" })
Spell( 45524 ,{ name = "Chains of Ice", duration = 8, color = colors.CHILL })
Spell( 48792 ,{ name = "Icebound Fortitude", duration = 12 })
Spell( 51124 ,{ name = "Killing Machine", duration = 30, color = colors.LRED, shine = true })
Spell( 59052 ,{ name = "Freezing Fog", duration = 15, color = colors.WOO2, shine = true })

Spell( 51271, { name = "Pillar of Frost", color = colors.BROWN, duration = 20, group = "buffs" })
Spell( 49039 ,{ name = "Lichborne", duration = 10, color = colors.BLACK })

--UNHOLY
Spell( 91342 ,{ name = "Shadow Infusion", shinerefresh = true, duration = 30, color = colors.LGREEN, short = "Infusion", glowstack = 5 })
Spell( 63560 ,{ name = "Dark Transformation", shine = true, duration = 30, color = colors.LGREEN, short = "Monstrosity" })
Spell( 81340 ,{ name = "Sudden Doom", shine = true, duration = 10, color = colors.CURSE })
Spell( 47476 ,{ name = "Strangulate", duration = 5 })
Spell( 91800 ,{ name = "Gnaw", duration = 3, color = colors.RED })
Spell( 91797 ,{ name = "Monstrous Blow", duration = 4, color = colors.RED, short = "Gnaw" })
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
Spell( 55342 ,{ name = "Mirror Image",duration = 40 })
Spell( 159916 ,{ name = "Amplify Magic",duration = 6, shine = true, group = "buffs" })
Cooldown( 153626 ,{ name = "Arcane Orb", color = colors.CHIM, ghost = true })

EventTimer({ event = "SPELL_SUMMON", spellID = 152087, name = "Prismatic Crystal", group = "buffs", priority = -20, duration = 10, color = colors.CHIM })
-- not shown in combat log
Spell( 116267 ,{ name = "Incanter's Flow",duration = 100500, singleTarget = true, timeless = true, charged = true, maxcharge = 5, color = colors.LRED, stackcolor = {
                                                                            [1] = { .3, 0, 0},
                                                                            [2] = { .4, 0, 0},
                                                                            [3] = { .6, 0, 0},
                                                                            [4] = { .8, 0, 0},
                                                                            [5] = { 1, 0, 0},
                                                                        }})

-- Spell( 12536 ,{ name = "Clearcast",duration = 15, color = colors.BLACK })
Spell( 31589 ,{ name = "Slow", duration = 15, pvpduration = 8 })
--FIRE

Spell( 31661 ,{ name = "Dragon's Breath", duration = 5, color = colors.ORANGE, short = "Breath", multiTarget = true })
Spell( 2120 ,{ name = "Flamestrike", duration = 8, color = colors.PURPLE, multiTarget = true })

Spell( 48107 ,{ name = "Heating Up", priority = 5.1, shine = true, glowtime = 10, duration = 10, color = colors.DPURPLE })
Spell( 48108 ,{ name = "Pyroblast", priority = 5, duration = 15, shine = true, color = colors.REJUV })
--Pyroblast
DotSpell( 11366 ,{ name = "", ghost = true, duration = 18, priority = 8, color = colors.PURPLE, singleTarget = true })
--Living Bomb
DotSpell( 44457 ,{ name = "", ghost = true, color = colors.PINKIERED, priority = 9, duration = 12, singleTarget = true })
Spell( 12654 ,{ name = "Ignite", shinerefresh = false, color = colors.DRED, priority = 1, duration = 5, singleTarget = true })
Spell( 83853 ,{ name = "Combustion", color = colors.ORANGE2, priority = 1.1, duration = 10, singleTarget = true })
Cooldown( 108853, { name = "Infeno Blast", color = colors.LRED, ghost = true })
--Cooldown( 2136, { name = "Fire Blast", resetable = true, color = colors.LRED})
EventTimer({ spellID = 153561, event = "SPELL_CAST_SUCCESS", name = "Meteor", duration = 2.9, color = colors.FIRE })
EventTimer({ spellID = 12654, event = "SPELL_PERIODIC_DAMAGE",
    action = function(active, srcGUID, dstGUID, spellID, damage )
        local ignite_timer = NugRunning.gettimer(active, spellID, dstGUID, "DEBUFF")
        if ignite_timer then
            ignite_timer:SetName(damage)
        end
    end})

--FROST
Spell( 12472 ,{ name = "Icy Veins",duration = 20 })
Spell( 82691 ,{ name = "Ring of Frost", shine = true, color = colors.FROZEN, multiTarget = true, duration = 12, pvpduration = 8 }) -- it's not multi target, but... it can spam
Spell( 122 ,{ name = "Frost Nova",duration = 8, color = colors.FROZEN, multiTarget = true })
Spell( 33395 ,{ name = "Freeze",duration = 8, color = colors.FROZEN })
Spell( 44544 ,{ name = "Fingers of Frost", shine = true, duration = 15, color = colors.FROZEN })
Spell( 57761 ,{ name = "Brain Freeze", shine = true, duration = 15, color = colors.LRED })

Spell( 45438 ,{ name = "Ice Block",duration = 10 })
Spell( 44572 ,{ name = "Deep Freeze",duration = 5 })
Spell( 120 ,{ name = "Cone of Cold", duration = 8, color = colors.CHILL, short = "CoC", multiTarget = true })
Cooldown( 153595, { name = "Comet Storm", color = colors.PURPLE2})
Cooldown( 84714, { name = "Frozen Orb", color = colors.WOO})

--talents
Spell( 157913,{ name = "Evanesce", duration = 3, color = colors.PINK })
Spell( 12043 ,{ name = "Presence of Mind", shine = true, timeless = true, duration = 0.1, color = colors.CURSE, short = "PoM" })
Spell( 11426 ,{ name = "Ice Barrier",duration = 60, color = colors.LGREEN })
Spell( 108839 ,{ name = "Ice Floes", duration = 15, color = colors.CURSE })
Spell( 115610 ,{ name = "Temporal Shield", duration = 4, color = colors.LGREEN })
Spell( 102051 ,{ name = "Frostjaw", duration = 8, pvpduration = 4,  color = colors.PINK })

Spell( 32612 ,{ name = "Invisibility",duration = 20 })
Spell( 110960 ,{ name = "Greater Invisibility", duration = 20, color = colors.CURSE })

Spell( 116014, { name = "Rune of Power", timeless = true, duration = 1, color = colors.DPURPLE, priority = -50 })

Spell( 112948 ,{ name = "Frost Bomb", duration = 12, color = colors.CURSE })
-- duration = function(self, opts) 
--             local targetGUID = UnitGUID("target")
--             if self.dstGUID == targetGUID then return 12 end
--             local origin_timer = NugRunning.gettimer(NugRunning.active, 44457, targetGUID, "DEBUFF")
--             if origin_timer then
--                 return origin_timer.endTime - GetTime()
--             else
--                 return 12
--             end
--         end,
Spell( 114923 ,{ name = "Nether Tempest", duration = 12, color = colors.PURPLE })

end

if class == "PALADIN" then

--Spell( 53657 ,{ name = "Judgements of the Pure", short = "JotP", duration = 100500, color = colors.LBLUE })
Spell( 31884 ,{ name = "Avenging Wrath",duration = 20, group = "buffs", color = colors.PURPLE2 })
Spell( 498 ,{ name = "Divine Protection",duration = 10, short = "DProt", color = colors.BLACK })
Spell( 642 ,{ name = "Divine Shield",duration = 8, short = "DShield", color = colors.BLACK })
Spell( 31850,{ name = "Ardent Defender",duration = 10, color = colors.BLACK})
Spell( 31821,{ name = "Devotion Aura", duration = 6, multiTarget = true, color = colors.GOLD})
Spell( 1022 ,{ name = "Hand of Protection",duration = 10, short = "Protection", color = colors.WOO2 })
Spell( 114039 ,{ name = "Hand of Purity",duration = 6, short = "Purity", color = colors.WOO2 })
Spell( 1044 ,{ name = "Hand of Freedom",duration = 6, short = "Freedom", color = colors.BROWN })
Spell( 10326 ,{ name = "Turn Evil",duration = 20, pvpduration = 8, color = colors.LGREEN })

--empowered seals
Spell( 156987 ,{ name = "Justice", scale = .7, group = "buffs", priority = -881, duration = 20, color = colors.DEFAULT_BUFF })
Spell( 156988 ,{ name = "Insight", scale = .7, group = "buffs", priority = -881, duration = 20, color = colors.LGREEN })
Spell( 156989 ,{ name = "Righteousness", scale = .7, group = "buffs", priority = -881, duration = 20, color = colors.PURPLE2 })
Spell( 156990 ,{ name = "Truth", scale = .7, group = "buffs", priority = -881, duration = 20, color = colors.LRED })

Spell( 152262 ,{ name = "Seraphim", color = colors.PINKIERED, shine = true, shinerefresh = true, group = "buffs", priority = -10, duration = 15 })

-- Spell( 53563 ,{ name = "Beacon of Light", duration = 300, timeless = true, priority = -20, short = "Beacon",color = colors.RED })
-- Spell( 31842 ,{ name = "Divine Favor",duration = 20, short = "Favor" })
Spell( 20066 ,{ name = "Repentance",duration = 60, pvpduration = 8, color = colors.LBLUE })
Spell( 853 ,{ name = "Hammer of Justice", duration = 6, short = "HoJ", color = colors.FROZEN })
Spell( 105593 ,{ name = "Fist of Justice", duration = 6, short = "FoJ", color = colors.FROZEN })
--Spell( 31803 ,{ name = "Censure",duration = 15, color = colors.RED})
-- Spell( 85696 ,{ name = "Zealotry",duration = 20 })
Spell( 2812 ,{ name = "Denounce", duration = 4, color = colors.GREEN })

Cooldown( 35395 ,{ name = "Crusader Strike", tick = 1.5, overlay = {"tick", "end"}, tickshine = true, ghost = true, short = "Crusader", priority = 10, fixedlen = 8, color = colors.CURSE })
Cooldown( 20271 ,{ name = "Judgement", ghost = true, fixedlen = 8, priority = 8, color = colors.PURPLE })
Cooldown( 26573 ,{ name = "Consecration", color = colors.PINKIERED, overlay = {0,"gcd",.3}, priority = 9, scale = .7, ghost = true, fixedlen = 8 })
Cooldown( 24275 ,{ name = "Hammer of Wrath", color = colors.TEAL2, fixedlen = 8, ghost = true, priority = 11 })
Cooldown( 119072, { name = "Holy Wrath", color = colors.BROWN, priority = 3, ghost = true })
Cooldown( 31935 ,{ name = "Avenger's Shield", resetable = true, fixedlen = 8, priority = 5, short = "AvShield", scale = .8, color = colors.PINK3, ghost = true })

Spell( 132403 ,{ name = "Shield of the Righteous", short = "Shield", group = "buffs", duration = 3, priority = -15, scale = .7, color = colors.PINK3 })
Spell( 114637 ,{ name = "Bastion of Glory", short = "Bastion", duration = 20, priority = -15, scale = .7, color = colors.DRED, glowstack = 5 })
-- Spell( 132403 ,{ name = "Shield of the Righteous", short = "SotR", duration = 3, priority = 10, color = colors.DPURPLE })

--Spell( 94686 ,{ name = "Crusader", duration = 15 })
Spell( 157048 ,{ name = "Final Verdict", duration = 30, color = colors.DPURPLE, timeless = true, priority = -7.5, scale = .6 })
Cooldown( 879 ,{ name = "Exorcism", fixedlen = 8, shine = true, color = colors.PINKIERED, resetable = true, ghost = 6 })
--Activation( 879 ,{ name = "Exorcism", shine = true, color = colors.ORANGE, duration = 15 })
--Activation( 84963 ,{ name = "Hand of Light", shine = true, showid = 85256, short = "Light", color = colors.PINK, duration = 8 })

-- Spell( 62124 ,{ name = "Taunt", duration = 3 })
-- Spell( 85416 ,{ name = "Reset", shine = true, timeless = true, duration = 0.1, color = colors.BLACK })
--Activation( 31935 ,{ name = "Reset", shine = true, timeless = true, duration = 0.1, color = colors.BLACK })


EventTimer({ spellID = 85256 , event = "SPELL_CAST_SUCCESS", priority = 13, name = "Templar's Verdict", duration = 0.5, color = colors.PINK })
EventTimer({ spellID = 157048, event = "SPELL_CAST_SUCCESS", priority = 13, name = "Final Verdict", duration = 0.5, color = colors.PINK })
EventTimer({ spellID = 53385 , event = "SPELL_CAST_SUCCESS", priority = 13, name = "Divine Storm", duration = 0.5, color = colors.PINK })
EventTimer({ spellID = 53600 , event = "SPELL_CAST_SUCCESS", priority = 13, name = "SHOTR", duration = 0.5, color = colors.PINK })


Spell( 85499 ,{ name = "Speed of Light", short = "Speed", duration = 7 })
Spell( 105421 ,{ name = "Blinding Light", duration = 6, multiTarget = true })
Spell( 114250 ,{ name = "Selfless Healer", short = "Selfless", duration = 15 })
Spell( 156322 ,{ name = "Eternal Flame", duration = 30, color = colors.LGREEN })
Spell( 20925 ,{ name = "Sacred Shield", color = colors.GOLD, duration = 30 })
Spell( 105809 ,{ name = "Holy Avenger", color = colors.GOLD, group = "buffs",  duration = 18 })
Spell( 90174 ,{ name = "Divine Purpose", shine = true, short = "DPurpose", color = colors.PINK, duration = 8 })
Cooldown( 114165 ,{ name = "Holy Prism", color = colors.BLACK })
Spell( {114916, 114917} ,{ name = "Execution Sentence", ghost = true, short = "Execution", color = colors.WOO2, duration = 10 })
end

if class == "DRUID" then
Spell( 339 ,{ name = "Entangling Roots",duration = 30 })
-- Spell( 113746 ,{ name = "Weakened Armor", short = "WeakArmor", priority = -10, affiliation = "any", singleTarget = true, color = colors.BROWN, duration = 30 })

-- Spell( 48517 ,{ name = "Solar Eclipse", timeless = true, duration = 0.1, short = "Solar", color = colors.ORANGE }) -- Wrath boost
-- Spell( 48518 ,{ name = "Lunar Eclipse", timeless = true, duration = 0.1, short = "Lunar", color = colors.LBLUE }) -- Starfire boost
Spell( 78675,{ name = "Solar Beam", duration = 10, color = colors.GOLD, target = "player" })
Spell( 33786 ,{ name = "Cyclone", duration = 6 })
DotSpell( 164812 ,{ name = "Moonfire",duration = 40, priority = 10, ghost = true, color = colors.PURPLE })
Spell( 171743 ,{ name = "Lunar Peak", duration = 5, priority = 9.1, scale = .7, color = colors.REJUV, glowtime = 5})
Spell( 164547 ,{ name = "Lunar Empowerment", duration = 30, priority = 9, color = colors.REJUV})
Spell( 171744 ,{ name = "Solar Peak", duration = 5, priority = 8.1, scale = .7, color = colors.ORANGE2, glowtime = 5})
Spell( 164545 ,{ name = "Solar Empowerment", duration = 30, priority = 8, color = colors.ORANGE2})
DotSpell( 164815 ,{ name = "Sunfire",duration = 24, priority = 9, ghost = true, color = colors.ORANGE })
-- Spell( 93400 ,{ name = "Shooting Stars", shine = true, duration = 12, color = colors.CURSE })
Spell( 48505 ,{ name = "Starfall", shine = true, duration = 10, color = colors.WOO2 })
Cooldown( 78674 ,{ name = "Starsurge", resetable = true, priority = 6, ghost = true, color = colors.CURSE })
Spell( 152221 ,{ name = "Stellar Flare",duration = 20, priority = 8, ghost = true, color = colors.CHIM })
Spell( 112071 ,{ name = "Celestial Alignment",duration = 15, group = "buffs", color = colors.LBLUE, priority = -20 })



DotSpell( 155625 ,{ name = "Moonfire",duration = 14, ghost = true, color = colors.PURPLE }) --cat's moonfire2
Spell( 158792 ,{ name = "Pulverize",duration = 10, ghost = true, color = colors.WOO2 })
Spell( 155835 ,{ name = "Bristling Fur",duration = 3, color = colors.WOO2 })

Spell( {106951, 50334} ,{ name = "Berserk", duration = 15 })
--cat
Spell( 163505 ,{ name = "Rake Stun", duration = 4, color = colors.PINK })
Spell( 155722 ,{ name = "Rake", duration = 15, color = colors.LRED })
Spell( 1079 ,{ name = "Rip",duration = 16, color = colors.RED })
Spell( 22570 ,{ name = "Maim", color = colors.PINK, duration = function() return GetCP() end })
Cooldown(5217, { name = "Tiger's Fury", color = colors.LBLUE})
Spell( 52610 ,{ name = "Savage Roar", color = colors.PURPLE, duration = function() return (12 + GetCP() * 6) end })
Spell( 1850 ,{ name = "Dash", duration = 15 })
-- Spell( 81022 ,{ name = "Stampede", duration = 8 })
--bear
Spell( 132402 ,{ name = "Savage Defense", duration = 6, color = colors.WOO, priority = -8 })
Spell( 22812 ,{ name = "Barkskin",duration = 12, color = colors.WOO2, priority = -9 })
Spell( 99 ,{ name = "Disorienting Roar", short = "Disorient", duration = 3, multiTarget = true })
-- Spell( 6795 ,{ name = "Taunt", duration = 3 })
Spell( 33745 ,{ name = "Lacerate", duration = 15, color = colors.RED })
-- Spell( 5209 ,{ name = "Challenging Roar", shine = true, duration = 6, multiTarget = true })
Spell( 45334 ,{ name = "Wild Charge",duration = 4, color = colors.LRED }) --bear
Spell( 5211 ,{ name = "Bash",duration = 5, shine = true, color = colors.PINK })
Cooldown( 77758, { name = "Thrash", priority = 5, color = colors.PURPLE, fixedlen = 9, ghost = true })
Cooldown( 33745 ,{ name = "Lacerate", color = colors.RED })
Cooldown( 33917, { name = "Mangle", tick = -1.5, tickshine = true, overlay = {"tick", "end"}, priority = 10, short = "", resetable = true, fixedlen = 9, ghost = true,  color = colors.CURSE })
-- Spell( 93622 ,{ name = "Reset", shine = true, color = colors.CURSE, duration = 5 })

Spell( 102359 ,{ name = "Mass Entanglement", duration = 20, color = colors.BROWN })
Spell( 102351 ,{ name = "Cenarion Ward",duration = 30, color = colors.WOO2 })
Spell( 102352 ,{ name = "Cenarion Ward",duration = 6, color = colors.TEAL })

Spell( 117679 ,{ name = "Incarnation: Tree of Life", short = "Incarnation", duration =  30, color = colors.TEAL2 })
Spell( 102558 ,{ name = "Incarnation: Son of Ursoc", short = "Incarnation", duration =  30, color = colors.TEAL2 })
Spell( 102560 ,{ name = "Incarnation: Chosen of Elune", short = "Incarnation", duration =  30, color = colors.TEAL2 })
Spell( 102543 ,{ name = "Incarnation: King of the Jungle", short = "Incarnation", duration =  30, color = colors.TEAL2 })



Spell( 102342 ,{ name = "Ironbark",duration = 12 })

Spell( 61336 ,{ name = "Survival Instincts", color = colors.BLACK, duration = 12 })
Spell( 124974 ,{ name = "Nature's Vigil", color = colors.TEAL2, duration = 30 })
Spell( 132158 ,{ name = "Nature's Swiftness", timeless = true, duration = 0.1, color = colors.TEAL, short = "NS" })
Spell( 774 ,{ name = "Rejuvenation", duration = 18, color = colors.REJUV })
Spell( 155777 ,{ name = "Germination", duration = 18, color = colors.PURPLE2 })
Spell( 8936 ,{ name = "Regrowth",duration = 6, color = { 198/255, 233/255, 80/255} })
Spell( 33763 ,{ name = "Lifebloom", shinerefresh = true, recast_mark = 3, duration = 15, color = { 0.5, 1, 0.5} })
Spell( 48438 ,{ name = "Wild Growth", duration = 7, multiTarget = true, color = colors.LGREEN })
Spell(100977,{ name = "Harmony", color = colors.BLACK, recast_mark = 2.5, duration = 10 })
Spell( 16870 ,{ name = "Clearcasting",  duration = 15 })
Spell( 155631,{ name = "Clearcasting",  duration = 5, color = colors.CHIM })
end

if class == "HUNTER" then
EventTimer({ spellID = 131894, event = "SPELL_CAST_SUCCESS", name = "A Murder of Crows", duration = 30, color = colors.LBLUE })
Spell( 51755 ,{ name = "Camouflage", duration = 60, target = "player", color = colors.CURSE })
Spell( 19263 ,{ name = "Deterrence", duration = 5, color = colors.LBLUE })

--Spell( 77769 ,{ name = "Trap Launcher", shine = true, timeless = true, duration = 0.1, color = colors.CURSE })
--Spell( 53220 ,{ name = "Steady Focus", duration = 10, color = colors.BLACK })

-- Spell( 82925 ,{ name = "Ready, Set, Aim...", short = "", duration = 30, shinerefresh = true, color = colors.LBLUE }) --removed
-- Spell( 82926 ,{ name = "Aimed Shot!", duration = 10, shine = true, color = colors.WOO2 }) --removed
Spell( 34720 ,{ name = "Thrill of the Hunt", duration = 15, shine = true, color = colors.TEAL, priority = -5 })



Spell( 118455 ,{ name = "Beast Cleave", duration = 4, target = "pet", priority = -6, color = colors.TEAL2 })
Spell( 19615 ,{ name = "Frenzy", duration = 10, target = "player", priority = -10, stackcolor = {
                                [1] = colors.DRED,
                                [2] = colors.DRED,
                                [3] = colors.DRED,
                                [4] = colors.RED,
                                [5] = {1,0,0},
                            }, glowstack = 5 })
-- Spell( 82654 ,{ name = "Widow Venom", duration = 30, color = { 0.1, 0.75, 0.1} })--removed

Spell( 168980 ,{ name = "Lock and Load", duration = 12, color = colors.LRED })
Spell( 19574 ,{ name = "Bestial Wrath", duration = 10, priority = -9, color = colors.LRED, target = "player" })
Spell( 82692 ,{ name = "Focus Fire", duration = 20, priority = -9.9, color = colors.PINKIERED })


Spell( 136 ,{ name = "Mend Pet", duration = 10, color = colors.LGREEN })

--Spell( 2974 ,{ name = "Wing Clip", duration = 10, pvpduration = 8, color = { 192/255, 77/255, 48/255} })
--Spell( 19306 ,{ name = "Counterattack", duration = 5, color = { 192/255, 77/255, 48/255} })l
DotSpell( 118253 ,{ name = "Serpent Sting", duration = 15, color = colors.PURPLE })
Spell( 5116 ,{ name = "Concussive Shot", duration = 6, color = colors.CHILL, init = function(self)self.duration = 4 + Talent(19407) end })

Spell( 24394 ,{ name = "Intimidation", duration = 3, color = colors.RED })
Spell( 19386 ,{ name = "Wyvern Sting", duration = 30, pvpduration = 8, short = "Wyvern",color = colors.LGREEN })


Spell( 3355 ,{ name = "Freezing Trap", duration = 10, pvpduration = 8, color = colors.FROZEN, init = function(self)self.duration = 20 * (1+Talent(19376)*0.1) end })

Spell( 3045 ,{ name = "Rapid Fire", duration = 15, color = colors.CURSE })

Cooldown( 34026 ,{ name = "Kill Command", color = colors.CURSE, ghost = true, tick = -1.5, tickshine = true, overlay = {"tick", "end"}, short = "", priority = 10, })

Cooldown( 53209 ,{ name = "Chimera Shot", color = { 1, 0.2, 1}, ghost = true, short = "", priority = 10, })
Cooldown( 53351 ,{ name = "Kill Shot", color = colors.PINKIERED, ghost = true, priority = 9, resetable = true })

Cooldown( 53301 ,{ name = "Explosive Shot", color = colors.PINKIERED, ghost = true, tick = -1.5, tickshine = true, overlay = {"tick", "end"}, short = "", priority = 10, })
Cooldown( 3674 ,{ name = "Black Arrow", color = colors.CURSE, ghost = true, priority = 9 })


Spell( 128405 ,{ name = "Narrow Escape", duration = 8, color = colors.BROWN, multiTarget = true })
Spell( 117526 ,{ name = "Binding Shot", duration = 5, pvpduration = 3, color = colors.RED, multiTarget = true })
Cooldown( 120679 ,{ name = "Dire Beast", recast_mark = 15, priority = 6, ghost = true, overlay = {0,15, 0.3}, color = colors.BROWN })
Cooldown( 82726 ,{ name = "Fervor", color = colors.DBLUE })

Cooldown( 130392 ,{ name = "Blink Strike", color = colors.WOO2 })
Cooldown( 109259 ,{ name = "Powershot", color = colors.WOO })
Cooldown( 117050 ,{ name = "Glaive Toss", color = colors.WOO, ghost = true, priority = 7 })
Cooldown( 120360 ,{ name = "Barrage", color = colors.WOO })

-- helpers.Cast(77767, {name = "Cobra Shot", tick = .5, overlay = {"tick", "end"}, fixedlen = 8, color = colors.GREEN, priority = 15 })

end

if class == "SHAMAN" then
-- Spell( 8056 ,{ name = "Frost Shock", duration = 8, color = colors.CHILL, short = "FrS" })

Spell( 16188 ,{ name = "Ancestal Swiftness", timeless = true, duration = 0.1, color = colors.TEAL, shine = true, short = "Swiftness" })
Spell( 61295 ,{ name = "Riptide", duration = 15, color = colors.FROZEN })
Spell( 51514 ,{ name = "Hex", duration = 50, pvpduration = 8, color = colors.CURSE })
Spell( 79206 ,{ name = "Spiritwalker's Grace", duration = 10, color = colors.LGREEN, group = "buffs" })

DotSpell( 8050 ,{ name = "Flame Shock", duration = 30, color = colors.PURPLE,
        init = function(self)
            self.singleTarget = (GetSpecialization() == 2)
        end })
Spell( 16166 ,{ name = "Elemental Mastery", duration = 20, color = colors.PINKIERED, group = "buffs" })
Spell( 77762 ,{ name = "Flame Surge", duration = 6, color = colors.TEAL2, priority = 11, scale = .7, shine = true })
Cooldown( 51505 ,{ name = "Lava Burst", color = colors.CURSE, ghost = true, priority = 10, resetable = true })
Cooldown( 165462 ,{ name = "Unleash Flame", color = colors.RED, short = "Unleash", priority = 8, ghost = true }) --elemental
Cooldown( 51490 ,{ name = "Thunderstorm", color = colors.WOO2 })
Cooldown( 61882 ,{ name = "Earthquake", color = colors.BROWN })
Cooldown( 117014 ,{ name = "Elemental Blast", priority = 9.5, ghost = true, color = colors.PURPLE2 })

Spell( 108281,{ name = "Ancestal Guidance", duration = 10, color = colors.DPURPLE, shine = true })

Spell( 30823 ,{ name = "Shamanistic Rage", duration = 15, color = colors.BLACK })
Cooldown( 60103 ,{ name = "Lava Lash", color = colors.RED, priority = 9, ghost = true, fixedlen = 10 })
Spell( 53817 ,{ name = "Maelstrom Weapon", duration = 12, priority = -5, short = "Maelstrom", stackcolor = {
                                [1] = colors.DPURPLE,
                                [2] = colors.DPURPLE,
                                [3] = colors.DPURPLE,
                                [4] = colors.DPURPLE,
                                [5] = colors.PURPLE2,
                            }, glowstack = 5 })
Cooldown( 17364 ,{ name = "Stormstrike", color = colors.CURSE, priority = 10, ghost = true, fixedlen = 10 })
Cooldown( 73680 ,{ name = "Unleash Elements", color = colors.WOO, short = "Unleash", priority = 8, ghost = true, fixedlen = 10 })
Spell( 73683,{ name = "Unleash Flame", duration = 18, color = colors.TEAL2, priority = 7.1, scale = .7 })
Cooldown( 8050 ,{ name = "Shock", color = colors.PINKIERED, priority = 7, ghost = true,
    init = function(self)
        self.fixedlen = (GetSpecialization() == 2) and 10
    end })

Spell({ 114050, 114051, 114052} ,{ name = "Ascendance", duration = 15, color = colors.PINK }) --ele, enh, resto
Spell( 108271 ,{ name = "Astral Shift", duration = 6, color = colors.BLACK })
Spell( 63685 ,{ name = "Freeze", duration = 5, color = colors.FROZEN })


-- TOTEMS
NugRunningConfig.totems[1] = { name = "Fire", color = {1,80/255,0}, hideName = false, priority = -77 }
NugRunningConfig.totems[2] = { name = "Earth", color = {74/255, 142/255, 42/255}, priority = -78 }
NugRunningConfig.totems[3] = { name = "Water", color = { 65/255, 110/255, 1}, priority = -79 }
NugRunningConfig.totems[4] = { name = "Air", color = {0.6, 0, 1}, priority = -80 }

end