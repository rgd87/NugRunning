local _, helpers = ...
local Spell = helpers.Spell
local Cooldown = helpers.Cooldown
local Activation = helpers.Activation
local EventTimer = helpers.EventTimer
local Anchor = helpers.Anchor
local Talent = helpers.Talent
local Glyph = helpers.Glyph
local GetCP = helpers.GetCP
local _,class = UnitClass("player")

NugRunningConfig.texture = "Interface\\AddOns\\NugRunning\\statusbar"
NugRunningConfig.nameFont = { font = "Fonts\\FRIZQT__.TTF", size = 10 }
NugRunningConfig.timeFont = { font = "Fonts\\FRIZQT__.TTF", size = 8 }
NugRunningConfig.stackFont = { font = "Fonts\\FRIZQT__.TTF", size = 10 }

NugRunningConfig.colors = {}
local colors = NugRunningConfig.colors
colors["RED"] = { 0.8, 0, 0}
colors["LRED"] = { 1,0.4,0.4}
colors["CURSE"] = { 0.6, 0, 1 }
colors["PINK"] = { 1, 0.3, 0.6 }
colors["TEAL"] = { 0.32, 0.52, 0.82 }
colors["TEAL2"] = {38/255, 221/255, 163/255}
colors["ORANGE"] = { 1, 124/255, 33/255 }
colors["FIRE"] = {1,80/255,0}
colors["LBLUE"] = {149/255, 121/255, 214/255}
colors["GOLD"] = {1,0.7,0.5}
colors["LGREEN"] = { 0.63, 0.8, 0.35 }
colors["PURPLE"] = { 187/255, 75/255, 128/255 }
colors["FROZEN"] = { 65/255, 110/255, 1 }
colors["CHILL"] = { 0.6, 0.6, 1}
colors["BLACK"] = {0.4,0.4,0.4}
colors["WOO"] = {151/255, 86/255, 168/255}
colors["WOO2"] = {80/255, 83/255, 150/255}
colors["BROWN"] = { 192/255, 77/255, 48/255}
colors["DEFAULT_DEBUFF"] = { 0.8, 0.1, 0.7}
colors["DEFAULT_BUFF"] = { 1, 0.4, 0.2}

local _, race = UnitRace("player")
if race == "Troll" then Spell( 26297 ,{ name = "Berserking", duration = 10 }) end --Troll Racial
if race == "Orc" then Spell({ 33702,33697,20572 },{ name = "Blood Fury", duration = 15 }) end --Orc Racial


if class == "WARLOCK" then
Spell( 74434 ,{ name = "Soulburn",duration = 20, color = colors.CURSE })

Spell( 348 ,{ name = "Immolate", recast_mark = 1.5, duration = 15, priority = 10, ghost = true, color = colors.RED, init = function(self)self.duration = 15 + Talent(85105)*3 end })
Spell( 34936 ,{ name = "Backlash", duration = 8, shine = true, color = colors.CURSE })
Spell( 80240 ,{ name = "Havoc", duration = 15, color = colors.WOO, target = "player" })

Spell( 108683 ,{ name = "Fire and Brimstone", short = "FnB", timeless = true, color = colors.ORANGE })
Cooldown( 17962, { name = "Conflagrate", ghost = true, recharging = true, priority = 5, color = colors.LRED })

Spell( 122355,{ name = "Molten Core",duration = 30, shine = true, color = colors.PURPLE })
-- REMOVED_DOSE event is not fired for molten core, so it's stuck at 3

Cooldown( 105174, { name = "Hand of Gul'dan",  color = colors.CURSE, recharging = true, replaces = 124916 })
Cooldown( 124916, { name = "Chaos Wave",  color = colors.CURSE, recharging = true, replaces = 105174 })
-- Spell( 47960 ,{ name = "Shadowflame", duration = 6, multiTarget = true })

Spell( 104773,{ name = "Unending Resolve",duration = 12, color = colors.WOO2 })
Spell( 113860 ,{ name = "Dark Soul: Misery",duration = 20, short = "DarkSoul", color = colors.CURSE })
Spell( 113861 ,{ name = "Dark Soul: Knowledge",duration = 20, short = "DarkSoul", color = colors.CURSE })
Spell( 113858 ,{ name = "Dark Soul: Instability",duration = 20, short = "DarkSoul", color = colors.CURSE })

Spell( 86211 ,{ name = "Soul Swap", duration = 20, shine = true, color = colors.BLACK })
Spell( 17941 ,{ name = "Nightfall", duration = 10, shine = true, color = colors.CURSE })
Spell( 103103 ,{ name = "Malefic Grasp", priority = 14, duration = 15, color = colors.CURSE, target = "target" })
Spell( 30108 ,{ name = "Unstable Affliction", priority = 10, duration = 15, ghost = true, recast_mark = 1.3, color = colors.RED, short = "UA" })
Spell( 48181 ,{ name = "",duration = 12, priority = 8, ghost = true, recast_mark = 3, color = colors.TEAL }) --Haunt
Spell( 172 ,{ name = "Corruption", priority = 9, ghost = true, color = colors.PINK, duration = 18 })
Spell( 980 ,{ name = "Agony",duration = 24, ghost = true, priority = 6, color = colors.WOO })
Spell( 1120 ,{ name = "Drain Soul",duration = 15, color = colors.LRED })
Spell( 27243 ,{ name = "Seed of Corruption",duration = 18, color = colors.LRED, short = "SoC" })

Spell( 109466 ,{ name = "Curse of Enfeeblement",duration = 30, color = colors.CURSE, short = "CoEnf" })
Spell( 18223 ,{ name = "Curse of Exhaustion", duration = 30, pvpduration = 8, color = colors.CURSE, short = "CoEx" })
Spell( 1490 ,{ name = "Curse of Elements",duration = 300, glowtime = 15, color = colors.CURSE, pvpduration = 120, short = "CoE" })
-- JINX ID 85547p

Spell( 60478 ,{ name = "Doomguard", duration = 60 })

Spell( 24259 ,{ name = "Spell Lock",duration = 3, color = colors.PINK })
Spell( 6358 ,{ name = "Seduction",duration = 30, pvpduration = 8 })
Spell( 89766 ,{ name = "Axe Toss", color = colors.BROWN, duration = 4 })

Spell( 6789 ,{ name = "Mortal Coil", duration = 3 })
Spell( 5484 ,{ name = "Howl of Terror", duration = 20, pvpduration = 8, multiTarget = true })
Spell( 110913 ,{ name = "Dark Bargain", duration = 10 })
Spell( 108416 ,{ name = "Sacrificial Pact", duration = 10 })
Spell( 30283 ,{ name = "Shadowfury", duration = 3, multiTarget = true })

Spell( 5782 ,{ name = "Fear", duration = 20, pvpduration = 8 })
Spell( 118699 ,{ name = "Blood Fear", duration = 20, pvpduration = 8 })
Spell( 104045 ,{ name = "Sleep", duration = 20, pvpduration = 8 })
Spell( 710 ,{ name = "Banish", duration = 30 })
end
   

if class == "PRIEST" then
-- BUFFS
Spell( 139 ,{ name = "Renew", shinerefresh = true, color = colors.LGREEN, duration = 12 })
Spell( 17 ,{ name = "Power Word: Shield", shinerefresh = true, duration = 15, color = colors.LRED, short = "PW:S" })
Spell( 41635 ,{ name = "Prayer of Mending", shinerefresh = true, duration = 30, color = colors.RED, textfunc = function(timer) return timer.dstName end })
Spell( 47788 ,{ name = "Guardian Spirit", shine = true, duration = 10, color = colors.LBLUE, short = "Guardian" })
Spell( 33206 ,{ name = "Pain Suppression",shine = true, duration = 8, color = colors.LBLUE })
Spell( 586 ,{ name = "Fade",duration = 10 })
Spell( 89485 ,{ name = "Inner Focus", shine = true, color = colors.LBLUE, timeless = true, duration = 0.1 })
-- Spell( 49694,59000 ,{ name = "Improved Spirit Tap",duration = 8 })
-- Spell( 15271 ,{ name = "Spirit Tap",duration = 15 })
Spell( 589 ,{ name = "Shadow Word: Pain",duration = 18, ghost = true, priority = 9, color = colors.PURPLE, refreshed =true, short = "SW:Pain" })

Spell( 34914 ,{ name = "Vampiric Touch", recast_mark = 1.5, ghost = true, priority = 10, duration = 15, color = colors.RED, short = "VampTouch", hasted = true })
Spell( 2944 ,{ name = "Devouring Plague",duration = 6, priority = 8, color = colors.WOO, short = "Plague" })
Spell( 47585 ,{ name = "Dispersion",duration = 6, color = colors.PURPLE })
--Spell( 15286 ,{ name = "Vampiric Embrace",duration = 15, color = colors.CURSE, short = "VampEmbrace" })

--~ Spell( 47753 ,{ name = "Divine Aegis", duration = 12 })
Spell( 59889,{ name = "Borrowed Time", duration = 6 })
-- DEBUFFS

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
EventTimer({ event = "SPELL_ENERGIZE", spellID = 47755, name = "Rapture", color = colors.BLACK, duration = 12 })
--Spell( 15407, { name = "Mind Flay",  color = colors.CURSE, duration = 3 })

--Old Shadow Orbs
-- Spell( 77487 ,{ name = "",duration = 60, charged = true, maxcharge = 3, shine = true, shinerefresh = true, priority = -3, color = colors.WOO })

Cooldown( 8092, { name = "Mind Blast",  color = colors.CURSE })
Cooldown( 32379, { name = "Shadow Word: Death", ghost = true, short = "SW:Death",  color = colors.PURPLE })

Spell( 81781 ,{ name = "Power Word: Barrier", short = "PW: Barrier", duration = 25, color = {1,0.7,0.5} }) -- duration actually used here, invisible aura applied

-- Spell( 81208 ,{ name = "Chakra: Serenity", short = "Serenity", color = colors.WOO, shine = true, timeless = true, duration = 9999 })
-- Spell( 81206 ,{ name = "Chakra: Sanctuary", color = colors.WOO2, short = "Sanctuary", shine = true, timeless = true, duration = 9999 })
-- Spell( 81209 ,{ name = "Chakra: Chastise", short = "Chastise", color = colors.RED, shine = true, timeless = true, duration = 9999 })
Spell( 88625 ,{ name = "Holy Word: Chastise", color = colors.LRED, short = "HW: Chastise", duration = 3 })

Spell( 81661 ,{ name = "Evangelism",duration = 15, color = colors.ORANGE, stackcolor = {
                                [1] = {0.7,0,0},
                                [2] = {1,0.6,0.2},
                                [3] = {1,1,0.4},
                                [4] = {0.8,1,0.5},
                                [5] = {0.7,1,0.2},
                            } })
--Spell( 81700 ,{ name = "Archangel",duration = 18, color = colors.CURSE })

--Spell({ 63731,63735 } ,{ name = "Serendipity",duration = 20, color = {0.4,0.4,0.9} })
end


if class == "ROGUE" then
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

-- Spell( 113746 ,{ name = "Weakened Armor", short = "WeakArmor", anySource = true, color = colors.BROWN, duration = 30 })

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
Spell( 121153 ,{ name = "Blindside", shine = true, color = colors.BLACK, duration = 10 })

Spell( 108212,{ name = "Burst of Speed", short = "Burst", shine = true, duration = 4 })
Spell( 115197,{ name = "Partial Paralysis", short = "Rooted", shine = true, color = colors.BROWN, duration = 4 })
Spell( 14183 ,{ name = "Premeditation",duration = 20, color = colors.CURSE })                    
Spell( 74002 ,{ name = "Combat Insight", shine = true, shinerefresh = true, duration = 10, color = colors.CURSE })

Spell( 84745 ,{ name = "Shallow Insight", short = "1x Insight", shine = true, color = colors.CURSE, duration = 15 })
Spell( 84746 ,{ name = "Moderate Insight", short = "2x Insight", shine = true, color = colors.CURSE, duration = 15 })
Spell( 84747 ,{ name = "Deep Insight", short = "3x Insight", shine = true, color = colors.CURSE, duration = 15 })
Spell( 13750 ,{ name = "Adrenaline Rush",duration = 15, color = colors.LRED })
Spell( 13877 ,{ name = "Blade Flurry",duration = 15, color = colors.LRED })

Spell( 51713 ,{ name = "Shadow Dance",duration = 8, color = colors.BLACK })
-- Spell( 89775 ,{ name = "Hemo",duration = 60, color = colors.CURSE })
-- Spell( 91021 ,{ name = "Find Weakness", duration = 10, color =  colors.LRED })

--Spell( 1784 ,{ name = "Stealth", color = colors.CURSE, timeless = true, duration = 0.1})
Spell( 114018,{ name = "Shroud of Concealment", short = "Shroud", color = colors.CURSE, duration = 15 })
Spell( 114842,{ name = "Shadow Walk", color = colors.PINK, duration = 6 })

EventTimer({ event = "SPELL_CAST_SUCCESS", spellID = 1725, name = "Distract", color = colors.PURPLE, duration = 10 })
end

if class == "WARRIOR" then
Spell( 6673 ,{ name = "Battle Shout", multiTarget = true, glowtime = 10, shout = true, color = colors.PURPLE, duration = 120,init = function(self)self.duration = (120 + Glyph(58385)*120) * (1+Talent(12321) * 0.25)  end })
Spell( 469 ,{ name = "Commanding Shout", multiTarget = true, glowtime = 10, short = "CommShout", shout = true, color = colors.PURPLE, duration = 120, init = function(self)self.duration = (120 + Glyph(68164)*120) * (1+Talent(12321) * 0.25)  end })
Spell( 2565 ,{ name = "Shield Block", color = colors.WOO2, duration = 6 })
Spell( 85730 ,{ name = "Deadly Calm", duration = 10 })
Spell( 12328 ,{ name = "Sweeping Strikes", color = colors.LRED, short = "Sweeping", duration = 10 })

-- Spell( 86346 ,{ name = "Colossus Smash", color = colors.BROWN, duration = 6 })
Cooldown( 86346 ,{ name = "Colossus Smash", ghost = true, color = colors.BLACK, resetable = true, duration = 20 })
Spell( 85288, { name = "Enraged", shine = true, showid = 14202, color = colors.RED, duration = 10 })
Spell( 676  ,{ name = "Disarm", color = colors.BROWN, duration = 10 })
Spell( 1715 ,{ name = "Hamstring", ghost = true, color = colors.PURPLE, duration = 15, pvpduration = 8 })

-- Spell( 12809 ,{ name = "Concussion Blow", color = { 1, 0.3, 0.6 }, duration = 5 })
Spell( 355 ,{ name = "Taunt", duration = 3 })
Spell( 113746 ,{ name = "Weakened Armor", short = "WeakArmor", anySource = true, color = colors.BROWN, duration = 30 })
Spell( 1160 ,{ name = "Demoralizing Shout", short = "DemoShout", anySource = true, color = {0.3, 0.9, 0.3}, duration = 30, multiTarget = true })
Spell( 115798 ,{ name = "Weakened Blows", short = "WeakBlows", anySource = true, color = {149/255, 121/255, 214/255}, duration = 30, multiTarget = true })
Spell( 122510 ,{ name = "Ultimatum", shine = true, timeless = true, color = colors.CURSE, duration = 0.1 })
Cooldown( 6572, { name = "Revenge", color = colors.WOO, fixedlen = 6, ghost = true })
Activation( 6572, { name = "RevengeActivation", for_cd = true })

Spell( 55694, { name = "Enraged Regeneration", short = "Regen", color = colors.LGREEN, duration = 5 })
Spell( 46968 ,{ name = "Shockwave", color = colors.CURSE, shine = true, duration = 4, multiTarget = true })
Spell( 12323 ,{ name = "Piercing Howl", color = colors.PURPLE, duration = 5 })
Spell( 107566 ,{ name = "Staggering Shout", duration = 5 })
Spell( 105771, { name = "Warbringer", duration = 3 })
Spell( 107574, { name = "Avatar", shine = true, color = colors.TEAL, duration = 20 })
Spell( 107570, { name = "Storm Bolt", color = { 1, 0.3, 0.6 }, duration = 3})
-- Cooldown( 107570, { name = "Storm Bolt", color = colors.TEAL })

--Spell( 56112 ,{ name = "Furious Attacks", duration = 10 })
--Activation( 5308, { name = "Execute", shine = true, timeless = true, color = colors.CURSE, duration = 0.1 })

Cooldown( 12294, { name = "Mortal Strike", short = "", check_known = true, recast_mark = 1.5, fixedlen = 9, ghost = true,  color = colors.CURSE })

-- special timer
Spell( 7384, { name = "Overpower", short = "", shine = true, color = colors.RED, recast_mark = 4.5, duration = 9})
--Activation( 7384, { name = "Overpower", short = "", shine = true, color = colors.RED, recast_mark = 4.5, duration = 9})
-- Spell( 60503 ,{ name = "", recast_mark = 4, color = colors.RED, duration = 9 }) -- Taste for blood: new id 125831

Cooldown( 23881, { name = "Bloodthirst", short = "", check_known = true, ghost = true, recast_mark = 1.5, fixedlen = 6,  color = colors.CURSE })
Spell( 46916 ,{ name = "Bloodsurge", shine = true, color = colors.LRED, duration = 10 })

Spell( 131116 ,{ name = "Raging Blow", shine = true, color = colors.WOO, duration = 12 })
--Cooldown( 85288, { name = "Raging Blow", ghost = true,  color = colors.WOO })
--Activation( 85288, { name = "Enraged", for_cd = true })
-- it's enrage timer config


Cooldown( 1680, { name = "Whirlwind", color = colors.LBLUE })
Spell( 12975, { name = "Last Stand", color = colors.BLACK, duration = 20 })
Spell( 871, { name = "Shield Wall", color = colors.WOO2, duration = 12 })
Cooldown( 23922, { name = "Shield Slam", short = "", check_known = true, recast_mark = 1.5, ghost = true,  color = colors.CURSE, resetable = true })
--Activation( 23922, { name = "Slam!", shine = true, timeless = true, color = colors.CURSE, duration = 0.1 })

-- Cooldown( 78, { name = "Heroic Strike", short = "Heroic", fixedlen = 6, ghost = true })
-- Cooldown( 6343, { name = "Thunder Clap", short = "Clap", ghost = true })



Spell( 32216, { name = "Victory Rush", color = colors.PINK, duration = 20})

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

Spell( 125195 ,{ name = "Tigereye Brew", color = colors.BLACK, duration = 120 }) --stacks
Spell( 116740 ,{ name = "Tigereye Brew", color = colors.BLACK, duration = 15 }) --activation

Cooldown( 107428, { name = "Rising Sun Kick", short = "RSK", color = colors.PURPLE })

Spell( 119611 ,{ name = "Renewing Mist", color = colors.LGREEN, duration = 18 })
Spell( 116849 ,{ name = "Life Cocoon", color = colors.PURPLE, duration = 12 })
Spell( 116680 ,{ name = "Thunder Focus Tea", color = colors.CURSE, duration = 30 })
Spell( 118674 ,{ name = "Vital Mists", color = colors.BLACK, duration = 30 })


Spell( 115213 ,{ name = "Avert Harm", duration = 15 })
Spell( 115307 ,{ name = "Shuffle", color = colors.RED, duration = 6 })
Spell( 116330 ,{ name = "Dizzying Haze", color = colors.PURPLE, duration = 15, multiTarget = true })
Spell( 123727 ,{ name = "Dizzying Haze", color = colors.PURPLE, duration = 15, multiTarget = true }) -- from Keg Smash
Spell( 128939 ,{ name = "Evusive Brew", duration = 30, color = colors.BLACK })
Spell( 115308 ,{ name = "Evusive Brew", duration = 15, color = colors.BLACK })
Cooldown( 115295, { name = "Guard", color = colors.GOLD })
Cooldown( 121253, { name = "Keg Smash", color = colors.CURSE })
-- Spell( 115798 ,{ name = "Weakened Blows", short = "WeakBlows", anySource = true, color = {149/255, 121/255, 214/255}, duration = 30, multiTarget = true })


Spell( 124081 ,{ name = "Zen Sphere", duration = 16, color = { 1, 0.2, 1} })
Spell( 119381 ,{ name = "Leg Sweep", duration = 5, color = colors.RED })
Spell( 122783 ,{ name = "Diffuse Magic", duration = 6, color = colors.CURSE })
end

if class == "DEATHKNIGHT" then
Spell( 55095 ,{ name = "Frost Fever", color = colors.CHILL, duration = 21, init = function(self)self.duration = 21 + Talent(49036)*4 end })
Spell( 55078 ,{ name = "Blood Plague", color = colors.PURPLE, duration = 21, init = function(self)self.duration = 21 + Talent(49036)*4 end })

--BLOOD
Spell( 81130 ,{ name = "Scarlet Fever", duration = 30, color = colors.LRED })
Spell( 73975 ,{ name = "Necrotic Strike", duration = 10, color = colors.WOO })
Spell( 55233 ,{ name = "Vampiric Blood", duration = 10, color = colors.RED })
Spell( 81256 ,{ name = "Dancing Rune Weapon", duration = 12, color = colors.RED })
--Spell( 49222 ,{ name = "Bone Shield", duration = 300, color = colors.WOO2 })

--FROST
Spell( 57330 ,{ name = "Horn of Winter", duration = 120, shout = true, glowtime = 8, color = colors.CURSE, multiTarget = true, short = "Horn", init = function(self)self.duration = 120 + Glyph(58680)*60 end })
Spell( 45524 ,{ name = "Chains of Ice", duration = 8, color = colors.CHILL })
Spell( 49203 ,{ name = "Hungering Cold", duration = 10, color = colors.FROZEN, multiTarget = true })
Spell( 48792 ,{ name = "Icebound Fortitude", duration = 12 })
Spell( 51124 ,{ name = "Killing Machine", duration = 30 })
Spell( 59052 ,{ name = "Freezing Fog", duration = 15 })
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
Spell( 70940,{ name = "Divine Guardian", duration = 6, multiTarget = true, short = "DGuardian", color = colors.GOLD})
Spell( 1022 ,{ name = "Hand of Protection",duration = 10, short = "HoProt", color = colors.WOO2 })
Spell( 1044 ,{ name = "Hand of Freedom",duration = 6, short = "Freedom" })
Spell( 10326 ,{ name = "Turn Evil",duration = 20, pvpduration = 8, color = colors.LGREEN })

Spell( 53563 ,{ name = "Beacon of Light",duration = 300, short = "Beacon",color = colors.RED })
Spell( 54428 ,{ name = "Divine Plea",duration = 15, short = "Plea" })
-- Spell( 31842 ,{ name = "Divine Favor",duration = 20, short = "Favor" })
Spell( 20066 ,{ name = "Repentance",duration = 60, pvpduration = 8, color = colors.LBLUE })
Spell( 853 ,{ name = "Hammer of Justice", duration = 6, short = "HoJ", color = colors.FROZEN })
--Spell( 31803 ,{ name = "Censure",duration = 15, color = colors.RED})
-- Spell( 85696 ,{ name = "Zealotry",duration = 20 })

Cooldown( 35395 ,{ name = "Crusader Strike", ghost = true, short = "Crusader", color = colors.CURSE, recast_mark = 1.5, fixedlen = 8 })
Cooldown( 20271 ,{ name = "Judgement", ghost = true, color = colors.RED })
Spell( 20925 ,{ name = "Holy Shield", color = colors.WOO2, duration = 10 })
Cooldown( 24275 ,{ name = "HoWrath", color = colors.TEAL })
-- Cooldown( 2812, { name = "Holy Wrath", color = colors.BROWN })
-- Cooldown( 26573 ,{ name = "Consecration", color = colors.LBLUE })
Cooldown( 20473 ,{ name = "Holy Shock", color = colors.PINK })


--Spell( 94686 ,{ name = "Crusader", duration = 15 })
Spell( 59578 ,{ name = "Exorcism", shine = true, color = colors.LRED, duration = 15 }) -- Art of War
--Activation( 879 ,{ name = "Exorcism", shine = true, color = colors.ORANGE, duration = 15 })
--Activation( 84963 ,{ name = "Hand of Light", shine = true, showid = 85256, short = "Light", color = colors.PINK, duration = 8 })
Spell( 90174 ,{ name = "Hand of Light", shine = true, showid = 85256, short = "Light", color = colors.PINK, duration = 8 })

Spell( 62124 ,{ name = "Taunt", duration = 3 })
-- Spell( 85416 ,{ name = "Reset", shine = true, timeless = true, duration = 0.1, color = colors.BLACK })
--Activation( 31935 ,{ name = "Reset", shine = true, timeless = true, duration = 0.1, color = colors.BLACK })
Cooldown( 31935 ,{ name = "Avenger's Shield", resetable = true, duration = 15, short = "Avenger", color = colors.BLACK, ghost = true })
end

if class == "DRUID" then
Spell( 339 ,{ name = "Entangling Roots",duration = 30 })
-- Spell( 113746 ,{ name = "Weakened Armor", short = "WeakArmor", anySource = true, color = colors.BROWN, duration = 30 })

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

Spell( 106951 ,{ name = "Berserk", duration = 15 })
--cat
Spell( 9005 ,{ name = "Pounce", duration = 4, color = colors.PINK })
Spell( 9007 ,{ name = "Pounce Bleed", color = colors.RED, duration = 18 })
Spell( 33876 ,{ name = "Mangle", color = colors.CURSE, duration = 60 })
Spell( 1822 ,{ name = "Rake", duration = 15, color = colors.LRED })
Spell( 1079 ,{ name = "Rip",duration = 16, color = colors.RED })
Spell( 22570 ,{ name = "Maim", color = colors.PINK, duration = function() return GetCP() end })
Cooldown(5217, { name = "Tiger's Fury", color = colors.LBLUE})
Spell( 52610 ,{ name = "Savage Roar", color = colors.PURPLE, duration = function() return (12 + GetCP() * 6) end })
Spell( 1850 ,{ name = "Dash", duration = 15 })
-- Spell( 81022 ,{ name = "Stampede", duration = 8 })
--bear
Spell( 62606 ,{ name = "Savage Defense", duration = 6, color = colors.WOO2 })
-- Spell( 115798 ,{ name = "Weakened Blows", short = "WeakBlows", anySource = true, color = {149/255, 121/255, 214/255}, duration = 30, multiTarget = true })
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
Spell( 17116 ,{ name = "Nature's Swiftness", timeless = true, duration = 0.1, color = colors.TEAL, short = "NS" })
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
Spell( 51755 ,{ name = "Camouflage", duration = 60, target = "player", color = colors.CURSE })
Spell( 19263 ,{ name = "Deterrence", duration = 5, color = colors.LBLUE })

Spell( 19615 ,{ name = "Frenzy", duration = 10, color = colors.CURSE })
Spell( 82654 ,{ name = "Widow Venom", duration = 30, color = { 0.1, 0.75, 0.1} })

Spell( 56453 ,{ name = "Lock and Load", duration = 12, color = colors.LRED })
Spell( 19574 ,{ name = "Bestial Wrath", duration = 18, color = colors.LRED })

Spell( 136 ,{ name = "Mend Pet", duration = 10, color = colors.LGREEN })

Spell( 2974 ,{ name = "Wing Clip", duration = 10, pvpduration = 8, color = { 192/255, 77/255, 48/255} })
Spell( 19306 ,{ name = "Counterattack", duration = 5, color = { 192/255, 77/255, 48/255} })
Spell( 13797 ,{ name = "Immolation Trap", duration = 15, color = colors.ORANGE, init = function(self)self.duration = 15 - Glyph(56846)*6 end })
Spell( 1978 ,{ name = "Serpent Sting", duration = 15, color = colors.PURPLE })
Spell( 19503 ,{ name = "Scatter Shot", duration = 4, color = colors.CHILL })
Spell( 5116 ,{ name = "Concussive Shot", duration = 6, color = colors.CHILL, init = function(self)self.duration = 4 + Talent(19407) end })
Spell( 34490 ,{ name = "Silencing Shot", duration = 3, color = colors.PINK, short = "Silence" })

Spell( 24394 ,{ name = "Intimidation", duration = 3, color = colors.RED })
Spell( 19386 ,{ name = "Wyvern Sting", duration = 30, pvpduration = 8, short = "Wyvern",color = colors.RED })


Spell( 3355 ,{ name = "Freezing Trap", duration = 10, pvpduration = 8, color = colors.FROZEN, init = function(self)self.duration = 20 * (1+Talent(19376)*0.1) end })

Spell( 1513 ,{ name = "Scare Beast", duration = 20, pvpduration = 8, color = colors.CURSE })

Spell( 3045 ,{ name = "Rapid Fire", duration = 15, color = colors.CURSE })

Cooldown( 83381 ,{ name = "Kill Command", color = colors.LRED })
Cooldown( 53209 ,{ name = "Chimera Shot", color = colors.RED })
Cooldown( 53301 ,{ name = "Explosive Shot", color = colors.RED })
Cooldown( 3674 ,{ name = "Black Arrow", color = colors.CURSE })
end

if class == "SHAMAN" then
Spell( 8056 ,{ name = "Frost Shock", duration = 8, color = colors.CHILL, short = "FrS" })

Spell( 16188 ,{ name = "Nature's Swiftness", timeless = true, duration = 0.1, color = colors.TEAL, short = "NS" })
Spell( 61295 ,{ name = "Riptide", duration = 15, color = colors.FROZEN })
Spell( 76780 ,{ name = "Bind Elemental", duration = 50, pvpduration = 8, color = colors.PINK })
Spell( 51514 ,{ name = "Hex", duration = 50, pvpduration = 8, color = colors.CURSE })
Spell( 79206 ,{ name = "Spiritwalker's Grace", duration = 10, color = colors.LGREEN })

Spell( 8050 ,{ name = "Flame Shock", duration = 18, color = colors.PURPLE, short = "FlS" })
Spell( 16166 ,{ name = "Elemental Mastery", duration = 30, color = colors.CURSE })
Cooldown( 8056 ,{ name = "Shock", color = colors.LRED })
Cooldown( 51505 ,{ name = "Lava Burst", color = colors.RED, resetable = true })

Spell( 30823 ,{ name = "Shamanistic Rage", duration = 15, color = colors.BLACK })
Cooldown( 60103 ,{ name = "Lava Lash", color = colors.RED })
Spell( 53817 ,{ name = "Maelstrom Weapon", duration = 12, color = colors.PURPLE, short = "Maelstrom" })
Cooldown( 17364 ,{ name = "Stormstrike", color = colors.CURSE })
Cooldown( 73680 ,{ name = "Unleash Elements", color = colors.WOO, short = "Unleash" })

-- TOTEMS
NugRunningConfig.totems = {}
NugRunningConfig.totems.hideNames = true
NugRunningConfig.totems[1] = { name = "Fire", color = {1,80/255,0} }
NugRunningConfig.totems[2] = { name = "Earth", color = {74/255, 142/255, 42/255} }
NugRunningConfig.totems[3] = { name = "Water", color = { 65/255, 110/255, 1} }
NugRunningConfig.totems[4] = { name = "Air", color = {0.6, 0, 1} }

end