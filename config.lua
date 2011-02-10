local _, helpers = ...
local AddSpell = helpers.AddSpell
local AddCooldown = helpers.AddCooldown
local AddActivation = helpers.AddActivation
local Talent = helpers.Talent
local Glyph = helpers.Glyph
local _,class = UnitClass("player")

--[[
GUIDE:
        Settings:
            duration - kinda neccesary, but if possible accurate duration will be scanned from target, mouseover, player for buffs and arena 1-5, focus for debuffs.
                       only if spell is applied to something out of these unit ids then this value is used.
        
            [optional]
            name     - text on the progress bar
            color    - RGB of bar color for spell
            short    - short name for spell. works if short text is enabled
            pvpduration - same as duration, but for enemy players 
            recast_mark - creates a mark that will shine when spell should be recasted. For example 3.5 for haunt is roughly travel time at 30yds + cast 
            multiTarget - for aoe spells
            timeless - progress bar is empty and won't disappear until game event occured and duration serves for bar sorting
            shine    - shine animation when applied
            shinerefresh - when refreshed
            
]]

local colors = {
    RED = { 0.8, 0, 0},
    LRED = { 1,0.4,0.4},
    CURSE = { 0.6, 0, 1 },
    PINK = { 1, 0.3, 0.6 },
    TEAL = { 0.32, 0.52, 0.82 },
    ORANGE = { 1, 124/255, 33/255 },
    FIRE = {1,80/255,0},
    LBLUE = {149/255, 121/255, 214/255},
    LGREEN = { 0.63, 0.8, 0.35 },
    PURPLE = { 187/255, 75/255, 128/255 },
    FROZEN = { 65/255, 110/255, 1 },
    CHILL = { 0.6, 0.6, 1},
    BLACK = {0.4,0.4,0.4},
    WOO = {151/255, 86/255, 168/255},
}
NugRunningConfig.colors = colors


local useTrinkets = true
local procTrinkets = false
local stackingTrinkets = false
if useTrinkets then
    AddSpell({ 33702,33697,20572 },{ name = "Blood Fury", duration = 15 }) --Orc Racial
    AddSpell( 26297 ,{ name = "Berserking", duration = 10 }) --Troll Racial
	AddSpell({ 54861 },{ name = "Nitro", duration = 5 })
	AddSpell({ 91376 },{ name = "Mark", duration = 15 })
end
if procTrinkets then
    --AddSpell( 60437 ,{ name = "Grim Toll", duration = 10 })
end
if stackingTrinkets then
    --AddSpell( 65006 ,{ name = "EotBM",duration = 10 }) --Eye of the Broodmother
end


if class == "WARLOCK" then
--AddSpell( 70840 ,{ name = "Devious Minds",duration = 10, target = "player", color = colors.LRED }) -- t10 4pc proc
AddSpell( 74434 ,{ name = "Soulburn",duration = 20, color = colors.CURSE })

AddSpell( 348 ,{ name = "Immolate", recast_mark = 1.5, duration = 15, ghost = true, color = colors.RED })
AddSpell( 34936 ,{ name = "Backlash",duration = 8, shine = true, color = colors.CURSE })
AddSpell( 47283 ,{ name = "Soulfire!",duration = 8, shine = true, color = colors.LRED })
AddSpell( 85383 ,{ name = "Imp Soul Fire",duration = 8, ghost = true, priority = 4, recast_mark = 3,short = "SoulFire", color = colors.BLACK })
AddSpell( 80240 ,{ name = "Bane of Havoc",duration = 300, color = colors.WOO, short = "Havoc" })
AddSpell( 30283 ,{ name = "Shadowfury",duration = 3, multiTarget = true })
AddSpell( 47960 ,{ name = "Shadowflame",duration = 6, multiTarget = true })
AddCooldown( 50796, { name = "Chaos Bolt", ghost = true, priority = 3, color = colors.LBLUE })
AddCooldown( 17962, { name = "Conflagrate", ghost = true, priority = 5, color = colors.LRED })

AddSpell({ 47383,71162,71165 },{ name = "Molten Core",duration = 18, shine = true, color = colors.PURPLE })
-- REMOVED_DOSE event is not fired for molten core, so it's stuck at 3
AddSpell({ 63167,63165 },{ name = "Decimation",duration = 8, color = colors.LBLUE })
AddCooldown( 71521, { name = "Hand of Gul'dan",  color = colors.LRED })
AddSpell( 79459 ,{ name = "Demon Soul: Imp",duration = 30, short = "DemonSoul", color = colors.CURSE })
AddSpell( 79460 ,{ name = "Demon Soul: Felhunter",duration = 20, short = "DemonSoul", color = colors.CURSE })
AddSpell( 79463 ,{ name = "Demon Soul: Succubus",duration = 20, short = "DemonSoul", color = colors.CURSE })
AddSpell( 79462 ,{ name = "Demon Soul: Felguard",duration = 20, short = "DemonSoul", color = colors.CURSE })
AddSpell( 79462 ,{ name = "Demon Soul: Voidwalker",duration = 15, short = "Misdirect", color = colors.CURSE })

AddSpell( 86211 ,{ name = "Soul Swap",duration = 20, shine = true, color = colors.BLACK })
AddSpell( 17941 ,{ name = "Nightfall",duration = 10, shine = true, color = colors.CURSE })
AddSpell( 64371 ,{ name = "Eradication",duration = 10, color = colors.CURSE })
AddSpell( 30108 ,{ name = "Unstable Affliction", priority = 10, duration = 15, ghost = true, recast_mark = 1.5, color = colors.RED, short = "UA" })
AddSpell( 48181 ,{ name = "",duration = 12, priority = 8, ghost = true, recast_mark = 3, color = colors.TEAL }) --Haunt
AddSpell( 172 ,{ name = "Corruption", priority = 9, ghost = true, color = colors.PINK, duration = 18 })
AddSpell( 980 ,{ name = "Bane of Agony",duration = 24, ghost = true, priority = 6, color = colors.WOO, short = "Agony", init = function(self)self.duration = 24 + Glyph(56241)*4 end })
AddSpell( 603 ,{ name = "Bane of Doom", ghost = true, duration = 60, color = colors.WOO, short = "Doom" })
AddSpell( 1120 ,{ name = "Drain Soul",duration = 15, color = colors.LRED })
AddSpell( 27243 ,{ name = "Seed of Corruption",duration = 15, color = colors.LRED, short = "SoC" })

AddSpell( 1714 ,{ name = "Curse of Tongues",duration = 30, color = colors.CURSE, pvpduration = 12, short = "CoT" })
AddSpell( 702 ,{ name = "Curse of Weakness",duration = 120, color = colors.CURSE, short = "Weakness" })
AddSpell( 18223 ,{ name = "Curse of Exhaustion",duration = 12, color = colors.CURSE, short = "CoEx" })
AddSpell( 1490 ,{ name = "Curse of Elements",duration = 300, color = colors.CURSE, pvpduration = 120, short = "CoE" })
-- JINX ID 85547

AddSpell( 24259 ,{ name = "Spell Lock",duration = 3, color = colors.PINK })
AddSpell( 6358 ,{ name = "Seduction",duration = 15, pvpduration = 10 })
AddSpell( 17767 ,{ name = "Consume Shadows", duration = 6, color = colors.PURPLE, short = "Consume" })
AddSpell( 30153 ,{ name = "Intercept",duration = 3 })
AddSpell( 7812 ,{ name = "Sacrifice",duration = 30, color = colors.PURPLE })
--
AddSpell( 5782 ,{ name = "Fear", duration = 20, pvpduration = 10 })
AddSpell( 5484 ,{ name = "Howl of Terror", duration = 8, multiTarget = true })                    
AddSpell( 710 ,{ name = "Banish", duration = 30 })
--AddCooldown( 59164, { name = "HAUNT",  color = colors.LRED })
end
   

if class == "PRIEST" then
-- BUFFS
AddSpell( 139 ,{ name = "Renew", shinerefresh = true, color = colors.LGREEN, duration = 15 })
AddSpell( 17 ,{ name = "Power Word: Shield", shinerefresh = true, duration = 30, color = colors.LRED, short = "PW:S" })
AddSpell( 41635 ,{ name = "Prayer of Mending", shinerefresh = true, duration = 30, color = colors.RED, textfunc = function(timer) return timer.dstName end })
AddSpell( 33151 ,{ name = "Surge of Light",duration = 10 })
AddSpell( 47788 ,{ name = "Guardian Spirit", shine = true, duration = 10, color = colors.LBLUE, short = "Guardian" })
AddSpell( 33206 ,{ name = "Pain Suppression",shine = true, duration = 8, color = colors.LBLUE })
AddSpell( 586 ,{ name = "Fade",duration = 10 })
AddSpell( 89485 ,{ name = "Inner Focus", shine = true, color = colors.LBLUE, timeless = true, duration = 0.1 })
-- AddSpell( 49694,59000 ,{ name = "Improved Spirit Tap",duration = 8 })
-- AddSpell( 15271 ,{ name = "Spirit Tap",duration = 15 })
AddSpell( 47585 ,{ name = "Dispersion",duration = 6, color = colors.PURPLE })
--~ AddSpell( 47753 ,{ name = "Divine Aegis", duration = 12 })
AddSpell({ 59889,59888,59887 },{ name = "Borrowed Time", duration = 6 })
-- DEBUFFS
AddSpell( 589 ,{ name = "Shadow Word: Pain",duration = 18, ghost = true, priority = 9, color = colors.PURPLE, refreshed = true, short = "SW:Pain" })
AddSpell( 34914 ,{ name = "Vampiric Touch", recast_mark = 1.5, ghost = true, priority = 10, duration = 15, color = colors.RED, short = "VampTouch", hasted = true })
AddSpell( 2944 ,{ name = "Devouring Plague",duration = 24, ghost = true, priority = 8, color = colors.WOO, short = "Plague", hasted = true })
AddSpell( 9484 ,{ name = "Shackle Undead",duration = 50, pvpduration = 10, short = "Shackle" })
AddSpell( 15487 ,{ name = "Silence",duration = 5, color = colors.PINK })
AddSpell( 95799 ,{ name = "Empowered Shadow",recast_mark = 1.5, ghost = true, priority = 5, short = "Empowered", duration = 10, color = colors.BLACK })
--AddSpell( 15286 ,{ name = "Vampiric Embrace",duration = 300, color = colors.CURSE, short = "VampEmbrace" })
AddSpell( 8122 ,{ name = "Psychic Scream",duration = 8, multiTarget = true })
--AddSpell( 15407, { name = "Mind Flay",  color = colors.CURSE, duration = 3 })

AddCooldown( 8092, { name = "Mind Blast",  color = colors.CURSE })
AddCooldown( 32379, { name = "Shadow Word: Death", short = "SWD",  color = colors.RED })

AddSpell( 81781 ,{ name = "Power Word: Barrier", short = "PW: Barrier", duration = 25, color = {1,0.7,0.5} }) -- duration actually used here, invisible aura applied

--AddSpell( 77487 ,{ name = "Shadow Orb",duration = 60, color = colors.CURSE })
--AddSpell( 87718 ,{ name = "Dark Evangelism",duration = 15, color = colors.CURSE })
--AddSpell( 87153 ,{ name = "Dark Archangel",duration = 18, color = colors.CURSE })

AddSpell( 88688 ,{ name = "Surge of Light", color = colors.LRED, duration = 10 })
AddSpell( 14751 ,{ name = "Chakra", color = colors.CURSE, timeless = true, duration = 0.1 })
AddSpell( 81208 ,{ name = "Chakra: Serenity", short = "Serenity", color = colors.WOO, shine = true, shinerefresh = true, duration = 30 })
AddSpell( 81206 ,{ name = "Chakra: Sanctuary", color = colors.CURSE, short = "Sanctuary", shine = true, duration = 30 })
AddSpell( 81209 ,{ name = "Chakra: Chastise", short = "Chastise", color = colors.RED, shine = true, duration = 30 })
AddSpell( 88682 ,{ name = "Holy Word: Aspire", color = {1,0.7,0.5}, short = "HW: Aspire", duration = 18 })
AddSpell( 88625 ,{ name = "Holy Word: Chastise", color = colors.LRED, short = "HW: Chastise", duration = 18 })

AddSpell( 81661 ,{ name = "Evangelism",duration = 15, color = colors.ORANGE, stackcolor = {
                                [1] = {0.7,0,0},
                                [2] = {1,0.6,0.2},
                                [3] = {1,1,0.4},
                                [4] = {0.8,1,0.5},
                                [5] = {0.7,1,0.2},
                            } })
--AddSpell( 81700 ,{ name = "Archangel",duration = 18, color = colors.CURSE })

--AddSpell( 63731 ,{ name = "Serendipity",duration = 20, color = {0.4,0.4,0.9} })
end


if class == "ROGUE" then
-- BUFFS
AddSpell( 32645 ,{ name = "Envenom", color = { 0, 0.65, 0}, duration = function() return (1+NugRunning.cpWas) end })

AddSpell( 2983 ,{ name = "Sprint", shine = true, duration = 15 })
AddSpell( 5277 ,{ name = "Evasion", color = colors.PINK, duration = 15 })
AddSpell( 31224 ,{ name = "Cloak of Shadows", color = colors.CURSE, duration = 5, short = "CloS" })
AddSpell( 14183 ,{ name = "Premeditation",duration = 20, color = colors.CURSE })                    
AddSpell( 74002 ,{ name = "Combat Insight", shine = true, shinerefresh = true, duration = 6, color = colors.CURSE })
AddSpell( 73651 ,{ name = "Recuperate", shinerefresh = true, color = colors.LGREEN ,duration = function() return (6 * NugRunning.cpWas) end })
AddSpell( 5171 ,{ name = "Slice and Dice", shinerefresh = true,  short = "SnD", color = colors.PURPLE,  duration = function() return (6 + NugRunning.cpWas*3)*(1+Talent(14165)*0.25) end  })
    
-- DEBUFFS
AddSpell( 1833 ,{ name = "Cheap Shot", duration = 4, color = colors.LRED })
AddSpell( 408 ,{ name = "Kidney Shot", shine = true, duration = 5,color = colors.LRED })
AddSpell( 1776 ,{ name = "Gouge", color = colors.PINK, duration = 4, init = function(self)self.duration = 4 + Talent(13741)*1 end })
AddSpell( 2094 ,{ name = "Blind",duration = 10, color = {0.20, 0.80, 0.2} })
AddSpell( 8647 ,{ name = "Expose Armor", shinerefresh = true, color = colors.LBLUE, duration = function() return NugRunning.cpWas * 10 end })
AddSpell( 51722 ,{ name = "Dismantle",duration = 10,color = colors.LRED })
AddSpell( 6770 ,{ name = "Sap",duration = 60, color = colors.LBLUE })

AddSpell( 1943 ,{ name = "Rupture", shinerefresh = true, color = colors.RED, duration = function() return (6 + NugRunning.cpWas * 2) + Glyph(56801)*4 end})
AddSpell( 703 ,{ name = "Garrote", color = colors.RED, duration = 18 })
AddSpell( 1330 ,{ name = "Silence", color = colors.PINK, duration = 3 })

--AddSpell( 2818, { name = "Deadly Poison", color = { 0.1, 0.75, 0.1}, duration = 12, short = "Deadly"})
--AddSpell( 3409 ,{ name = "Crippling Poison", color = { 192/255, 77/255, 48/255}, duration = 12, short = "Crippling" })
--AddSpell( 51693 ,{ name = "Waylay", color = { 192/255, 77/255, 48/255}, duration = 8 })

AddSpell( 14177 ,{ name = "Cold Blood", shine = true, color = colors.TEAL, timeless = true, duration = 0.1})
AddSpell( 79140 ,{ name = "Vendetta", shine = true, color = colors.CURSE, duration = 30 })
AddSpell( 79126 ,{ name = "Groggy", shine = true, color = colors.BLACK, duration = 8 })
--AddSpell( 58427 ,{ name = "Overkill", duration = 20, color =  colors.LRED })

AddSpell( 84745 ,{ name = "Shallow Insight", short = "1x Insight", shine = true, color = colors.CURSE, duration = 15 })
AddSpell( 84746 ,{ name = "Moderate Insight", short = "2x Insight", shine = true, color = colors.CURSE, duration = 15 })
AddSpell( 84747 ,{ name = "Deep Insight", short = "3x Insight", shine = true, color = colors.CURSE, duration = 15 })
AddSpell( 13750 ,{ name = "Adrenaline Rush",duration = 15, color = colors.LRED })
AddSpell( 13877 ,{ name = "Blade Flurry",duration = 15, color = colors.LRED })

AddSpell( 51713 ,{ name = "Shadow Dance",duration = 10, color = colors.BLACK })
AddSpell( 16511 ,{ name = "Hemo",duration = 60, color = colors.CURSE })

--AddSpell( 1784 ,{ name = "Stealth", color = colors.CURSE, timeless = true, duration = 0.1})
-- 1725, { name = "Distract", color = colors.PURPLE, duration = 10 })

end

if class == "WARRIOR" then
AddSpell( 6673 ,{ name = "Battle Shout", multiTarget = true, shout = true, color = colors.PURPLE, duration = 120,init = function(self)self.duration = (120 + Glyph(58385)*120) * (1+Talent(12321) * 0.25)  end })
AddSpell( 469 ,{ name = "Commanding Shout", multiTarget = true, short = "CommShout", shout = true, color = colors.PURPLE, duration = 120, init = function(self)self.duration = (120 + Glyph(68164)*120) * (1+Talent(12321) * 0.25)  end })
AddSpell( 2565 ,{ name = "Shield Block", duration = 10 })
AddSpell( 85730 ,{ name = "Deadly Calm", duration = 10 })
AddSpell( 12328 ,{ name = "Sweeping Strikes", color = colors.LRED, short = "Sweeping", duration = 10 })

--~ AddSpell( 86346 ,{ name = "Colossus Smash", color = colors.BLACK, duration = 6 })
AddSpell( 1715 ,{ name = "Hamstring", ghost = true, color = { 192/255, 77/255, 48/255}, duration = 15, pvpduration = 10 })
AddSpell( 23694 ,{ name = "Imp Hamstring", shine = true, color = colors.LRED, duration = 5 })
AddSpell( 85388 ,{ name = "Throwdown", color = colors.LRED, duration = 5 })
AddSpell( 94009 ,{ name = "Rend", color = colors.RED, duration = 15 })   -- like DKs frost fever & plague
AddSpell( 46968 ,{ name = "Shockwave", color = { 0.6, 0, 1 }, shine = true, duration = 4, multiTarget = true })
AddSpell( 12809 ,{ name = "Concussion Blow", color = { 1, 0.3, 0.6 }, duration = 5 })
AddSpell( 355 ,{ name = "Taunt", duration = 3 })
AddSpell( 58567 ,{ name = "Sunder Armor", short = "Sunder", anySource = true, color = { 1, 0.2, 0.2}, duration = 30 })
AddSpell( 1160 ,{ name = "Demoralizing Shout", anySource = true, short = "DemoShout", color = {0.3, 0.9, 0.3}, duration = 30, multiTarget = true })
AddSpell( 6343 ,{ name = "Thunder Clap", anySource = true, color = {149/255, 121/255, 214/255}, duration = 30, multiTarget = true })
--~ AddSpell( 56112 ,{ name = "Furious Attacks", duration = 10 })
AddActivation( 5308, { name = "Execute", shine = true, timeless = true, color = colors.CURSE, duration = 0.1 })

AddCooldown( 12294, { name = "Mortal Strike", ghost = true,  color = colors.CURSE })
AddSpell( 52437 ,{ name = "Reset", shine = true, color = colors.BLACK, timeless = true, duration = 0.1 })
--AddActivation( 86346, { name = "Reset", shine = true,  color = colors.BLACK, duration = 0.1 })
AddCooldown( 86346 ,{ name = "Colossus Smash", ghost = true, color = colors.BLACK, resetable = true, duration = 20 })
--AddActivation( 7384, { name = "Overpower", shine = true, color = colors.LBLUE, duration = 6})
AddSpell( 60503 ,{ name = "", recast_mark = 4, color = colors.RED, duration = 9 }) -- Taste for blood
--AddSpell( 90806 ,{ name = "Executioneer", color = colors.WOO, duration = 30 })

AddCooldown( 23881, { name = "Bloodthirst", ghost = true,  color = colors.CURSE })
AddSpell( 46916 ,{ name = "Bloodsurge", shine = true, color = colors.LRED, duration = 10 })
AddActivation( 85288, { name = "Enraged", shine = true, timeless = true, showid = 14202,color = colors.RED, duration = 0.1 })
AddCooldown( 85288, { name = "Raging Blow", ghost = true,  color = colors.WOO })
AddCooldown( 1680, { name = "Whirlwind", color = colors.LBLUE })

AddCooldown( 23922, { name = "Shield Slam", ghost = true,  color = colors.CURSE, resetable = true })
--AddActivation( 23922, { name = "Slam!", shine = true, timeless = true, color = colors.CURSE, duration = 0.1 })
AddSpell( 50227 ,{ name = "Slam!", shine = true, timeless = true, color = colors.CURSE, duration = 0.1 })
--AddCooldown( 6572, { name = "Revenge" })
AddSpell( 32216, { name = "Victory Rush", color = colors.PURPLE, duration = 20})
end

if class == "DEATHKNIGHT" then
AddSpell( 55095 ,{ name = "Frost Fever", color = colors.CHILL, duration = 21, init = function(self)self.duration = 21 + Talent(49036)*4 end })
AddSpell( 55078 ,{ name = "Blood Plague", color = colors.PURPLE, duration = 21, init = function(self)self.duration = 21 + Talent(49036)*4 end })

--BLOOD
AddSpell( 81130 ,{ name = "Scarlet Fever", duration = 30, color = colors.LRED })
AddSpell( 73975 ,{ name = "Necrotic Strike", duration = 30, color = colors.WOO })
AddSpell( 55233 ,{ name = "Vampiric Blood", duration = 10, color = colors.RED })
AddSpell( 81256 ,{ name = "Dancing Rune Weapon", duration = 12, color = colors.RED })

--FROST
AddSpell( 57330 ,{ name = "Horn of Winter", duration = 120, shout = true, color = colors.CURSE, multiTarget = true, short = "Horn", init = function(self)self.duration = 120 + Glyph(58680)*60 end })
AddSpell( 45524 ,{ name = "Chains of Ice", duration = 8, color = colors.CHILL })
AddSpell( 51209 ,{ name = "Hungering Cold", duration = 10, color = colors.FROZEN, multiTarget = true })
AddSpell( 48792 ,{ name = "Icebound Fortitude", duration = 12 })
AddSpell( 51124 ,{ name = "Killing Machine", duration = 30 })
AddSpell( 59052 ,{ name = "Freezing Fog", duration = 15 })
AddSpell( 49039 ,{ name = "Lichborne", duration = 10, color = colors.BLACK })

--UNHOLY
AddSpell( 91342 ,{ name = "Shadow Infusion", shinerefresh = true, duration = 30, color = colors.LGREEN, short = "Infusion" })
AddSpell( 63560 ,{ name = "Dark Transformation", shine = true, duration = 30, color = colors.LGREEN, short = "Monstrosity" })
AddSpell( 81340 ,{ name = "Sudden Doom", shine = true, duration = 10, color = colors.CURSE })
AddSpell( 47476 ,{ name = "Strangulate", duration = 5 })
AddSpell( 91800 ,{ name = "Gnaw", duration = 3, color = colors.RED })
AddSpell( 91797 ,{ name = "Monstrous Blow", duration = 4, color = colors.RED, short = "Gnaw" })
AddSpell( 49016 ,{ name = "Unholy Frenzy", duration = 30, color = colors.LRED })
AddSpell( 48707 ,{ name = "Anti-Magic Shell", duration = 5, short = "Shell", color = colors.LGREEN })

end

if class == "MAGE" then
--ARCANE
AddSpell( 80353 ,{ name = "Time Warp", shine = true, target = "player", duration = 40, color = colors.RED })
AddSpell({ 118,61305,28271,28272,61721,61780 },{ name = "Polymorph", duration = 50, color = colors.LGREEN, pvpduration = 10, short = "Poly" })
AddSpell( 12042 ,{ name = "Arcane Power",duration = 15, short = "APwr", color = colors.PINK })
--~ AddSpell( 66 ,{ name = "Fading",duration = 3 - NugRunning.TalentInfo(31574) })
AddSpell( 32612 ,{ name = "Invisibility",duration = 20 })
AddSpell( 12043 ,{ name = "Presence of Mind", shine = true, timeless = true, duration = 0.1, color = colors.CURSE, short = "PoM" })
AddSpell( 36032 ,{ name = "Arcane Blast",duration = 6, color = colors.CURSE })
AddCooldown( 44425 ,{ name = "Arcane Barrage", color = colors.RED })
AddSpell( 79683 ,{ name = "Arcane Missiles!", shine = true, duration = 20, color = colors.WOO })
--~ AddSpell( 55342 ,{ name = "Mirror Image",duration = 30 })
--~ AddSpell( 44413 ,{ name = "Incanter's Absorption",duration = 10, color = colors.LRED, short = "Absorb" })

AddSpell( 12536 ,{ name = "Clearcast",duration = 15, color = colors.BLACK })
AddSpell( 31589 ,{ name = "Slow", duration = 15, pvpduration = 10 })
AddSpell( 18469 ,{ name = "Silenced",duration = 2, color = colors.PINK }) -- imp CS
AddSpell( 55021 ,{ name = "Silenced",duration = 4, color = colors.PINK }) -- imp CS
--FIRE
AddSpell( 22959 ,{ name = "Critical Mass", shinerefresh = true, duration = 30, recast_mark = 2.5, color = colors.CURSE, short = "Scorch" })
AddSpell( 64343 ,{ name = "Impact", shine = true, duration = 10, color = LRED })
AddSpell( 44457 ,{ name = "Living Bomb",duration = 12, target = "target", color = colors.PURPLE, short = "Bomb" })
AddSpell( 48108 ,{ name = "Hot Streak",duration = 10, color = colors.LRED, short = "Pyro!" })
AddSpell( 11113 ,{ name = "Blast Wave", color = colors.CHILL, duration = 3, multiTarget = true })
AddSpell( 31661 ,{ name = "Dragon's Breath", duration = 5, color = colors.ORANGE, short = "Breath", multiTarget = true })
AddSpell( 2120 ,{ name = "Flamestrike", duration = 8, multiTarget = true })
--AddCooldown( 2136, { name = "Fire Blast", resetable = true, color = colors.LRED})

--FROST
AddSpell( 12472 ,{ name = "Icy Veins",duration = 20 })
AddSpell( 82691 ,{ name = "Ring of Frost", shine = true, color = colors.FROZEN, multiTarget = true, duration = 12 }) -- it's not multi target, but... it can spam
AddSpell( 122 ,{ name = "Frost Nova",duration = 8, short = "FrNova", color = colors.FROZEN, multiTarget = true })
AddSpell( 33395 ,{ name = "Freeze",duration = 8, color = colors.FROZEN })
AddSpell( 44544 ,{ name = "Fingers of Frost", shine = true, duration = 15, color = colors.FROZEN, short = "FoF" })
AddSpell( 57761 ,{ name = "Brain Freeze", shine = true, duration = 15, color = colors.LRED, short = "Fireball!" })
AddSpell( 55080 ,{ name = "Shattered Barrier",duration = 6, color = colors.FROZEN, short = "Shattered" })
AddSpell( 11426 ,{ name = "Ice Barrier",duration = 60, color = colors.LGREEN })
AddSpell( 45438 ,{ name = "Ice Block",duration = 10 })
AddSpell( 44572 ,{ name = "Deep Freeze",duration = 5 })
AddSpell( 120 ,{ name = "Cone of Cold", duration = 8, color = colors.CHILL, short = "CoC", multiTarget = true })
AddSpell( 83302 ,{ name = "Improved Cone of Cold", duration = 4, color = colors.FROZEN, short = "ICoC", multiTarget = true })
end

if class == "PALADIN" then

AddSpell( 53657 ,{ name = "Judgements of the Pure", short = "JotP", duration = 100500, color = colors.LBLUE })
AddSpell( 84963 ,{ name = "Inquisition",duration = 10, color = colors.PURPLE })  -- 10 * CP
AddSpell( 31884 ,{ name = "Avenging Wrath",duration = 20, short = "AW" })
AddSpell( 85696 ,{ name = "Zealotry",duration = 20 })
AddSpell( 498 ,{ name = "Divine Protection",duration = 12, short = "DProt" })
AddSpell( 642 ,{ name = "Divine Shield",duration = 12, short = "DShield" })
AddSpell( 1022 ,{ name = "Hand of Protection",duration = 10, short = "HoProt" })
AddSpell( 1044 ,{ name = "Hand of Freedom",duration = 6, short = "Freedom" })
AddSpell( 10326 ,{ name = "Turn Evil",duration = 20, pvpduration = 10, color = colors.LGREEN })

AddSpell( 53563 ,{ name = "Beacon of Light",duration = 300, short = "Beacon",color = colors.RED })
AddSpell( 54428 ,{ name = "Divine Plea",duration = 15, short = "Plea" })
AddSpell( 31842 ,{ name = "Divine Favor",duration = 20, short = "Favor" })
AddSpell( 20066 ,{ name = "Repentance",duration = 60, pvpduration = 10 })
AddSpell( 853 ,{ name = "Hammer of Justice",duration = 6, short = "HoJ", color = colors.FROZEN })
--AddSpell( 31803 ,{ name = "Censure",duration = 15, color = colors.RED})

AddCooldown( 35395 ,{ name = "Crusader Strike", color = colors.RED })

AddCooldown( 20925 ,{ name = "Holy Shield", color = colors.RED })
AddCooldown( 24275 ,{ name = "HoW", color = colors.TEAL })
AddCooldown( 20271 ,{ name = "Judgement", color = colors.LRED })
AddCooldown( 26573 ,{ name = "Consecration", color = colors.CURSE })

AddCooldown( 20473 ,{ name = "Holy Shock", color = colors.PINK })


AddSpell( 59578 ,{ name = "Exorcism", shine = true, color = colors.ORANGE, duration = 15 })
--AddActivation( 879 ,{ name = "Exorcism", shine = true, color = colors.ORANGE, duration = 15 })
--AddActivation( 84963 ,{ name = "Hand of Light", shine = true, showid = 85256, short = "Light", color = colors.PINK, duration = 8 })
AddSpell( 90174 ,{ name = "Hand of Light", shine = true, showid = 85256, short = "Light", color = colors.PINK, duration = 8 })

AddSpell( 62124 ,{ name = "Taunt", duration = 3 })
AddSpell( 85416 ,{ name = "Reset", shine = true, timeless = true, duration = 0.1, color = colors.BLACK })
--AddActivation( 31935 ,{ name = "Reset", shine = true, timeless = true, duration = 0.1, color = colors.BLACK })
AddCooldown( 31935 ,{ name = "Avenger's Shield", resetable = true, duration = 15, short = "AShield", color = colors.BLACK })
end

if class == "DRUID" then
AddSpell( 339 ,{ name = "Entangling Roots",duration = 30 })
AddSpell( 91565 ,{ name = "Faerie Fire",duration = 300, pvpduration = 40, color = colors.CURSE }) --second is feral

--AddSpell( 48391 ,{ name = "Owlkin Frenzy", duration = 10 })
AddSpell( 48517 ,{ name = "Solar Eclipse", timeless = true, duration = 0.1, short = "Solar", color = colors.ORANGE }) -- Wrath boost
AddSpell( 48518 ,{ name = "Lunar Eclipse", timeless = true, duration = 0.1, short = "Lunar", color = colors.LBLUE }) -- Starfire boost
AddSpell( 2637 ,{ name = "Hibernate",duration = 40, pvpduration = 10 })
AddSpell( 33786 ,{ name = "Cyclone", duration = 6 })
AddSpell( 8921 ,{ name = "Moonfire",duration = 12, color = colors.PURPLE, init = function(self) self.duration = 12 + Talent(57810)*2 end })
AddSpell( 93402 ,{ name = "Sunfire",duration = 12, color = colors.ORANGE, init = function(self) self.duration = 12 + Talent(57810)*2 end })
AddSpell( 5570 ,{ name = "Insect Swarm",duration = 12, color = colors.LGREEN, init = function(self) self.duration = 12 + Talent(57810)*2 end })
AddSpell( 93400 ,{ name = "Shooting Stars", shine = true, duration = 8, color = colors.CURSE })
AddCooldown( 78674 ,{ name = "Starsurge", resetable = true, color = colors.CURSE })

AddSpell( 50334 ,{ name = "Berserk", duration = 15 })
--cat
AddSpell( 9005 ,{ name = "Pounce", duration = 3, color = colors.PINK, init = function(self)self.duration = 3 + Talent(16940)*0.5 end })
AddSpell( 9007 ,{ name = "Pounce Bleed", color = colors.RED, duration = 18 })
AddSpell( 33876 ,{ name = "Mangle", color = colors.CURSE, duration = 60 })
AddSpell( 1822 ,{ name = "Rake", duration = 15, color = colors.LRED })
AddSpell( 1079 ,{ name = "Rip",duration = 16, color = colors.RED })
AddSpell( 22570 ,{ name = "Maim", color = colors.PINK, duration = function() return NugRunning.cpWas end })
AddCooldown(5217, { name = "Tiger's Fury", color = colors.LBLUE})
AddSpell( 52610 ,{ name = "Savage Roar", color = colors.PURPLE, duration = function() return (17 + NugRunning.cpWas * 5) end })
AddSpell( 1850 ,{ name = "Dash", duration = 15 })
AddSpell( 81022 ,{ name = "Stampede", duration = 8 })
--bear
AddSpell( 99 ,{ name = "Demoralizing Roar", anySource = true, short = "DemoRoar", color = {0.3, 0.9, 0.3}, duration = 30, multiTarget = true })
AddSpell( 6795 ,{ name = "Taunt", duration = 3 })
AddSpell( 33745 ,{ name = "Lacerate", duration = 15, color = colors.RED })
AddSpell( 5209 ,{ name = "Challenging Roar", shine = true, duration = 6, multiTarget = true })
AddSpell( 45334 ,{ name = "Feral Charge",duration = 4, color = colors.LRED, init = function(self)self.duration = 4 + Talent(16940)*0.5 end })
AddSpell( 5211 ,{ name = "Bash",duration = 4, shine = true, color = colors.PINK, init = function(self)self.duration = 4 + Talent(16940)*0.5 end })
AddCooldown( 77758, { name = "Thrash", color = colors.LBLUE })
AddCooldown( 33878 ,{ name = "Mangle", resetable = true, color = colors.CURSE })
AddSpell( 93622 ,{ name = "Reset", shine = true, color = colors.CURSE, duration = 5 })
AddSpell( 80951 ,{ name = "Pulverize", shinerefresh = true, color = colors.PURPLE, duration = 18 })

AddSpell( 22812 ,{ name = "Barkskin",duration = 12 })
AddSpell( 17116 ,{ name = "Nature's Swiftness", timeless = true, duration = 0.1, color = colors.TEAL, short = "NS" })
AddSpell( 774 ,{ name = "Rejuvenation",duration = 12, color = { 1, 0.2, 1} })
AddSpell( 8936 ,{ name = "Regrowth",duration = 6, color = { 198/255, 233/255, 80/255} })
AddSpell( 33763 ,{ name = "Lifebloom", shinerefresh = true, duration = 10, init = function(self)self.duration = 7 + Talent(57865)*2 end, stackcolor = {
                                                                            [1] = { 0, 0.8, 0},
                                                                            [2] = { 0.2, 1, 0.2},
                                                                            [3] = { 0.5, 1, 0.5},
                                                                        }})
AddSpell( 48438 ,{ name = "Wild Growth", duration = 7, multiTarget = true, color = colors.LGREEN })
AddSpell( 29166 ,{ name = "Innervate",duration = 10 })
AddSpell( 16870 ,{ name = "Clearcasting",  duration = 15 })
end

if class == "HUNTER" then
AddSpell( 51755 ,{ name = "Camouflage", duration = 60, target = "player", color = colors.CURSE })
AddSpell( 19263 ,{ name = "Deterrence", duration = 5, color = colors.LBLUE })

AddSpell( 19615 ,{ name = "Frenzy", duration = 10, color = colors.CURSE })
AddSpell( 82654 ,{ name = "Widow Venom", duration = 30, color = { 0.1, 0.75, 0.1} })

AddSpell( 56453 ,{ name = "Lock and Load", duration = 12, color = colors.LRED })
AddSpell( 19574 ,{ name = "Bestial Wrath", duration = 18, color = colors.LRED })

AddSpell( 136 ,{ name = "Mend Pet", duration = 10, color = colors.LGREEN })

AddSpell( 2974 ,{ name = "Wing Clip", duration = 10, color = { 192/255, 77/255, 48/255} })
AddSpell( 19306 ,{ name = "Counterattack", duration = 5, color = { 192/255, 77/255, 48/255} })
AddSpell( 13797 ,{ name = "Immolation Trap", duration = 15, color = colors.ORANGE, init = function(self)self.duration = 15 - Glyph(56846)*6 end })
AddSpell( 1978 ,{ name = "Serpent Sting", duration = 15, color = colors.PURPLE })
AddSpell( 19503 ,{ name = "Scatter Shot", duration = 4, color = colors.CHILL })
AddSpell( 5116 ,{ name = "Concussive Shot", duration = 4, color = colors.CHILL, init = function(self)self.duration = 4 + Talent(19407) end })
AddSpell( 34490 ,{ name = "Silencing Shot", duration = 3, color = colors.PINK, short = "Silence" })

AddSpell( 24394 ,{ name = "Intimidation", duration = 3, color = colors.RED })
AddSpell( 19386 ,{ name = "Wyvern Sting", duration = 30, pvpduration = 10, short = "Wyvern",color = colors.RED })


AddSpell( 3355 ,{ name = "Freezing Trap", duration = 10, pvpduration = 10, color = colors.FROZEN, init = function(self)self.duration = 20 * (1+Talent(19376)*0.1) end })

AddSpell( 1513 ,{ name = "Scare Beast", duration = 20, pvpduration = 10, color = colors.CURSE })

AddSpell( 3045 ,{ name = "Rapid Fire", duration = 15, color = colors.CURSE })

AddCooldown( 83381 ,{ name = "Kill Command", color = colors.LRED })
AddCooldown( 53209 ,{ name = "Chimera Shot", color = colors.RED })
AddCooldown( 53301 ,{ name = "Explosive Shot", color = colors.RED })
AddCooldown( 3674 ,{ name = "Black Arrow", color = colors.CURSE })
end

if class == "SHAMAN" then
AddSpell( 8056 ,{ name = "Frost Shock", duration = 8, color = colors.CHILL, short = "FrS" })

AddSpell( 16188 ,{ name = "Nature's Swiftness", timeless = true, duration = 0.1, color = colors.TEAL, short = "NS" })
AddSpell( 61295 ,{ name = "Riptide", duration = 15, color = colors.FROZEN })
AddSpell( 76780 ,{ name = "Bind Elemental", duration = 50, pvpduration = 10, color = colors.PINK })
AddSpell( 51514 ,{ name = "Hex", duration = 50, pvpduration = 10, color = colors.CURSE })
AddSpell( 79206 ,{ name = "Spiritwalker's Grace", duration = 10, color = colors.LGREEN })

AddSpell( 8050 ,{ name = "Flame Shock", duration = 18, color = colors.PURPLE, short = "FlS" })
AddSpell( 16166 ,{ name = "Elemental Mastery", duration = 30, color = colors.CURSE })
AddCooldown( 8056 ,{ name = "Shock", color = colors.LRED })
AddCooldown( 51505 ,{ name = "Lava Burst", color = colors.RED, resetable = true })

AddSpell( 30823 ,{ name = "Shamanistic Rage", duration = 15, color = colors.BLACK })
AddCooldown( 60103 ,{ name = "Lava Lash", color = colors.RED })
AddSpell( 53817 ,{ name = "Maelstrom Weapon", duration = 12, color = colors.PURPLE, short = "Maelstrom" })
AddCooldown( 17364 ,{ name = "Stormstrike", color = colors.CURSE })
AddCooldown( 73680 ,{ name = "Unleash Elements", color = colors.WOO, short = "Unleash" })

end