NugRunningConfig = {}
NugRunningConfig.cooldowns = {}
local _,class = UnitClass("player")






local Talent = function (spellID)
    local spellName
    if type(spellID) == "number" then 
        spellName = GetSpellInfo(spellID)
    elseif type(spellID) == "string" then
        spellName = spellID
    end
    local numTabs = GetNumTalentTabs()
    for t=1, numTabs do
        local numTalents = GetNumTalents(t)
        for i=1, numTalents do
            local name, _,_,_, rank = GetTalentInfo(t, i)
            if spellName == name then
                return rank
            end
        end
    end
    return 0
end

local Glyph = function (gSpellID)
    for i = 1, GetNumGlyphSockets() do
        if select(3,GetGlyphSocketInfo(i,GetActiveTalentGroup()) ) == gSpellID then return 1 end
    end
    return 0
end






local function AddSpell( ids, opts)
    local spelldata = opts
    for _, i in ipairs(ids) do
        NugRunningConfig[i] = spelldata
    end
end
-- spellID to get localized spellname and it's icon. so just one rank of spell is enough
local function AddCooldown( id, opts)
    if type(id) == "table" then id = id[1] end
    opts.localname = GetSpellInfo(id)
--~     print (id)
--~     print (opts.localname)
    if not opts.localname then return end -- cata quickfix
    NugRunningConfig.cooldowns[id] = opts
end

--[[
GUIDE:
    AddSpell({ commaseparated list of spell ids which can be found on wowhead }, { settings })
        Settings:
            duration - kinda neccesary, but if possible accurate duration will be scanned from target, mouseover, player for buffs and arena 1-5, focus for debuffs.
                       only if spell is applied to something out of these unit ids then this value is used.
        
            [optional]
            name     - text on the progress bar, if omitted localized spell name will display.
            color    - RGB of bar color for spell
            short    - short name for spell. works if short text is enabled
            pvpduration - same as duration, but for enemy players 
            recast_mark - creates a mark that will shine when spell should be recasted. For example 3.5 for haunt is roughly travel time at 30yds + cast 
            maxtimers - won't create any more timers for this spell if their destination is not your target
            tick     - interval between ticks in seconds. Only used to align dots with refresh from another spell. So far used only for corruption
            multiTarget - true for aoe spells
            textfunc - called on creation, setting text on progress bar. Example: function(spellName, dstName) return dstName end
]]

local colors = {
    RED = { 0.8, 0, 0},
    LRED = { 1,0.4,0.4},
    CURSE = { 0.6, 0, 1 },
    PINK = { 1, 0.3, 0.6 },
    TEAL = { 0.32, 0.52, 0.82 },
    ORANGE = { 1, 124/255, 33/255 },
    LBLUE = {149/255, 121/255, 214/255},
    LGREEN = { 0.63, 0.8, 0.35 },
    PURPLE = { 187/255, 75/255, 128/255 },
    FROZEN = { 65/255, 110/255, 1 },
    CHILL = { 0.6, 0.6, 1},
    BLACK = {0.4,0.4,0.4}
}



local useTrinkets = true
local procTrinkets = false
local stackingTrinkets = false
if useTrinkets then
    AddSpell({ 33702,33697,20572 },{ name = "Blood Fury", duration = 15 }) --Orc Racial
    AddSpell({ 26297 },{ name = "Berserking", duration = 10 }) --Troll Racial
    
    --Ulduar
        AddSpell({ 64800 },{ name = "Wrathstone", duration = 20 })
        AddSpell({ 64712 },{ name = "Living Flame", duration = 20 })
end
if procTrinkets then
    AddSpell({ 60494 },{ name = "Dying Curse", duration = 10 }) --Dying Curse
    AddSpell({ 60064 },{ name = "Sundial", duration = 10 }) --Sundial of the Exiled
    AddSpell({ 60065 },{ name = "Mirror", duration = 10 }) --Mirror of Truth
    AddSpell({ 60437 },{ name = "Grim Toll", duration = 10 })
    AddSpell({ 65014 },{ name = "Infuser", duration = 10 }) -- Pyrite Infuser
    AddSpell({ 64790 },{ name = "YoggBlood", duration = 10 }) --Blood of the Old God
    AddSpell({ 64713 },{ name = "FotHeavens", duration = 10 }) --Flame of the Heavens
end
if stackingTrinkets then
    AddSpell({ 60525 },{ name = "Dragon Figurine",duration = 10 }) --Majestic Dragon Figurine
    AddSpell({ 65006 },{ name = "EotBM",duration = 10 }) --Eye of the Broodmother
    AddSpell({ 60486 },{ name = "Dragon Soul",duration = 10 }) --Illustration of the Dragon Soul
end



if class == "WARLOCK" then
AddSpell({ 70840 },{ name = "Devious Minds",duration = 10, target = "player", color = colors.LRED }) -- t10 4pc proc
-- BUFFS
AddSpell({ 74434 },{ name = "Soulburn",duration = 20, color = {1,0.7,0.1} })
AddSpell({ 86211 },{ name = "Soul Swap",duration = 20, color = colors.BLACK })
AddSpell({ 63321 },{ name = "Life Tap",duration = 20, color = colors.PURPLE })
AddSpell({ 34936 },{ name = "Backlash",duration = 8 })
AddSpell({ 47283 },{ name = "Soulfire!",duration = 8, color = colors.LRED })
--~ AddSpell({ 54274,54276,54277 },{ name = "Backdraft",duration = 15 })
AddSpell({ 17941 },{ name = "Nightfall",duration = 10, color = colors.CURSE })
AddSpell({ 47383,71162,71165 },{ name = "Molten Core",duration = 18, color = colors.PURPLE })

AddSpell({ 63167,63165 },{ name = "Decimation",duration = 8, color = colors.LBLUE })

AddSpell({ 64371 },{ name = "Eradication",duration = 10, color = colors.CURSE })

AddSpell({ 27243 },{ name = "Seed of Corruption",duration = 15, color = colors.LRED, short = "SoC" })
-- DEBUFFS
AddSpell({348 },{ name = "Immolate", recast_mark = "gcd", duration = 15, color = colors.RED })
AddSpell({ 30108 },{ name = "Unstable Affliction",duration = 15, recast_mark = "gcd", color = colors.RED, short = "UA" })
AddSpell({ 172 },{ name = "Corruption", color = colors.PINK, duration = 18, init = function(self)
                                                        self.hasted = (Glyph(70947) ~= 0) end })
AddSpell({ 980 },{ name = "Bane of Agony",duration = 24, color = colors.CURSE, short = "Agony", init = function(self)self.duration = 24 + Glyph(56241)*4 end })
AddSpell({ 603 },{ name = "Bane of Doom",duration = 60, color = colors.CURSE, short = "Doom" })
AddSpell({ 80240 },{ name = "Bane of Havoc",duration = 300, color = colors.CURSE, short = "Havoc" })
AddSpell({ 1714 },{ name = "Curse of Tongues",duration = 30, color = colors.PURPLE, pvpduration = 12, short = "CoT" })
AddSpell({ 702 },{ name = "Curse of Weakness",duration = 120, color = colors.PURPLE, short = "Weakness" })
AddSpell({ 18223 },{ name = "Curse of Exhaustion",duration = 12, color = colors.PURPLE, short = "CoEx" })
AddSpell({ 1490,85547 },{ name = "Curse of Elements",duration = 300, color = colors.PURPLE, pvpduration = 120, short = "CoE" })

AddSpell({ 48181 },{ name = "",duration = 12, recast_mark = 3, color = colors.TEAL }) --Haunt
AddSpell({ 30283 },{ name = "Shadowfury",duration = 3, multiTarget = true })
AddSpell({ 47960,61291 },{ name = "Shadowflame",duration = 8, multiTarget = true })
--PET SPELLS
AddSpell({ 24259 },{ name = "Spell Lock",duration = 3, color = colors.PINK })
AddSpell({ 6358 },{ name = "Seduction",duration = 15, pvpduration = 10 })
AddSpell({ 17767,17850,17851,17852,17853,17854,27272,47987,47988 },{ name = "Consume Shadows", duration = 6, color = colors.PURPLE, short = "Consume" })
AddSpell({ 30153,30195,30197,47995 },{ name = "Intercept",duration = 3 })
AddSpell({ 7812,19438,19440,19441,19442,19443,27273,47985,47986 },{ name = "Sacrifice",duration = 30, color = colors.PURPLE })
--
AddSpell({ 5782 },{ name = "Fear", duration = 20, pvpduration = 10 })
--~ AddSpell({ 6213 },{ name = "Fear", duration = 15, pvpduration = 10 })
--~ AddSpell({ 6215 },{ name = "Fear", duration = 20, pvpduration = 10 })
--
AddSpell({ 5484 },{ name = "Howl of Terror", duration = 8, multiTarget = true })                    
--~ AddSpell({ 17928 },{ name = "Howl of Terror", duration = 8, multiTarget = true })

AddSpell({ 710 },{ name = "Banish", duration = 30 })
--~ AddSpell({ 18647 },{ name = "Banish", duration = 30 })

AddCooldown( 50796, { name = "Chaos Bolt",  color = colors.LBLUE })
AddCooldown( 17962, { name = "Conflagrate",  color = colors.LRED })
AddCooldown( 71521, { name = "Hand of Gul'dan",  color = colors.LRED })
--AddCooldown( 59164, { name = "HAUNT",  color = colors.LRED })
end
   

if class == "PRIEST" then
-- BUFFS
AddSpell({ 139,6074,6075,6076,6077,6078,10927,10928,10929,25315,25221,25222,48067,48068 },{ name = "Renew", color = colors.LGREEN, duration = 15 })
AddSpell({ 17,592,600,3747,6065,6066,10898,10899,10900,10901,25217,25218,48065,48066 },{ name = "Power Word: Shield", duration = 30, maxtimers = 3, color = colors.LRED, short = "PW:S" })
AddSpell({ 41635,48110,48111 },{ name = "Prayer of Mending",duration = 30, color = colors.RED, textfunc = function(spellName, dstName) return dstName end })
AddSpell({ 33151 },{ name = "Surge of Light",duration = 10 })
AddSpell({ 63725,63724,34754 },{ name = "Holy Concentration",duration = 8 })
AddSpell({ 47788 },{ name = "Guardian Spirit",duration = 10, color = colors.LBLUE, short = "Guardian" })
AddSpell({ 33206 },{ name = "Pain Suppression",duration = 8, color = colors.LBLUE })
AddSpell({ 586 },{ name = "Fade",duration = 10 })
-- AddSpell({ 49694,59000 },{ name = "Improved Spirit Tap",duration = 8 })
-- AddSpell({ 15271 },{ name = "Spirit Tap",duration = 15 })
AddSpell({ 47585 },{ name = "Dispersion",duration = 6, color = colors.PURPLE })
--~ AddSpell({ 47753 },{ name = "Divine Aegis", duration = 12 })
AddSpell({ 59891,59890,59889,59888,59887 },{ name = "Borrowed Time", duration = 6 })
-- DEBUFFS
AddSpell({ 589,594,970,992,2767,10892,10893,10894,25367,25368,48124,48125 },{ name = "Shadow Word: Pain",duration = 18, color = colors.PURPLE, refreshed = true, tick = 3, short = "SW:Pain" })
AddSpell({ 34914,34916,34917,48159,48160 },{ name = "Vampiric Touch", recast_mark = "gcd", duration = 15, color = colors.RED, short = "VampTouch", hasted = true })
AddSpell({ 2944,19276,19277,19278,19279,19280,25467,48299,48300 },{ name = "Devouring Plague",duration = 24, color = colors.CURSE, short = "Plague", hasted = true })
AddSpell({ 9484,9485,10955 },{ name = "Shackle Undead",duration = 50, pvpduration = 10, short = "Shackle" })
AddSpell({ 15487 },{ name = "Silence",duration = 5, color = colors.PINK })
--AddSpell({ 15286 },{ name = "Vampiric Embrace",duration = 300, color = colors.CURSE, short = "VampEmbrace" })
AddSpell({ 8122,8124,10888,10890 },{ name = "Psychic Scream",duration = 8, multiTarget = true })

AddCooldown( 8092, { name = "Mind Blast",  color = colors.LRED })

end


if class == "ROGUE" then
-- BUFFS
AddSpell({ 57993 },{ name = "Envenom", color = { 0, 0.65, 0}, duration = function() return (1+NugRunning.cpWas) end })

AddSpell({ 2983,8696,11305 },{ name = "Sprint",duration = 15 })
AddSpell({ 5277,26669 },{ name = "Evasion", color = colors.PINK, duration = 15 })
AddSpell({ 31224 },{ name = "Cloak of Shadows", color = colors.CURSE, duration = 5, short = "CloS" })
AddSpell({ 14183 },{ name = "Premeditation",duration = 20, color = colors.CURSE })
AddSpell({ 13750 },{ name = "Adrenaline Rush",duration = 15, color = colors.LRED })
AddSpell({ 63848 },{ name = "Hunger For Blood", short="Hunger", duration = 60, color = colors.ORANGE })
AddSpell({ 13877 },{ name = "Blade Flurry",duration = 15, color = colors.LRED })
AddSpell({ 51713 },{ name = "Shadow Dance",duration = 10, color = colors.LRED })
--AddSpell({ 58427 },{ name = "Overkill", duration = 20, color =  colors.RED })                    
                
AddSpell({ 5171,6774 },{ name = "Slice and Dice", short = "SnD", color = colors.PURPLE,  duration = function() 
    if Talent(51664)>3 then NugRunning.cpWas = 5 end
    return (((6 + NugRunning.cpWas *3) + Glyph(56810)*4) * (1+Talent(14165)*0.25))
    end })
    
-- DEBUFFS
AddSpell({ 1833 },{ name = "Cheap Shot",duration = 4, color = colors.LRED })
AddSpell({ 408 },{ name = "Kidney Shot",duration = 5,color = colors.LRED })
AddSpell({ 8643 },{ name = "Kidney Shot",duration = 6,color = colors.LRED })
AddSpell({ 1776 },{ name = "Gouge", color = colors.PINK, duration = 4, init = function(self)self.duration = 4 + Talent(13741)*0.5 end })
AddSpell({ 2094 },{ name = "Blind",duration = 10, color = {0.20, 0.80, 0.2} })
AddSpell({ 8647 },{ name = "Expose Armor", color = colors.LBLUE, duration = function() return NugRunning.cpWas * 6 + Glyph(56803)*12 end })
AddSpell({ 51722 },{ name = "Dismantle",duration = 10,color = colors.LRED })

AddSpell({ 6770 },{ name = "Sap",duration = 25, color = colors.LBLUE })
AddSpell({ 2070 },{ name = "Sap",duration = 35, color = colors.LBLUE })
AddSpell({ 11297 },{ name = "Sap",duration = 45, color = colors.LBLUE })
AddSpell({ 51724 },{ name = "Sap",duration = 60, color = colors.LBLUE })

AddSpell({ 1943,8639,8640,11273,11274,11275,26867,48671,48672 },{ name = "Rupture", color = colors.RED, duration = function() return (6 + NugRunning.cpWas * 2) + Glyph(56801)*4 end})
AddSpell({ 703,8631,8632,8633,11289,11290,26839,26884,48675,48676,42964 },{ name = "Garrote", color = colors.RED, duration = 18 })
AddSpell({ 1330 },{ name = "Silence", color = colors.PINK, duration = 3 })

--AddSpell({ 2818,2819,11353,11354,25349,26968,27187,57969,57970}, { name = "Deadly Poison", color = { 0.1, 0.75, 0.1}, duration = 12, short = "Deadly"})
AddSpell({ 3409 },{ name = "Crippling Poison", color = { 192/255, 77/255, 48/255}, duration = 12, short = "Crippling" })

end

if class == "WARRIOR" then
AddSpell({ 6673,5242,6192,11549,11550,11551,25289,2048,47436 },{ name = "Battle Shout", multiTarget = true, shout = true, color = colors.PURPLE, duration = 120,init = function(self)self.duration = (120 + Glyph(58385)*120) * (1+Talent(12321) * 0.25)  end })
AddSpell({ 469, 47439, 47440 },{ name = "Commanding Shout", multiTarget = true, short = "CommShout", shout = true, color = colors.PURPLE, duration = 120, init = function(self)self.duration = (120 + Glyph(68164)*120) * (1+Talent(12321) * 0.25)  end })
AddSpell({ 2565 },{ name = "Shield Block", duration = 10 })
AddSpell({ 50227 },{ name = "Slam!", color = colors.LRED, duration = 5 })

AddSpell({ 1715 },{ name = "Hamstring", color = { 192/255, 77/255, 48/255}, duration = 15, pvpduration = 10 })
AddSpell({ 772,6546,6547,6548,11572,11573,11574,25208,46845,47465 },{ name = "Rend", color = colors.RED, duration = 15,
    init = function(self)self.duration = 15 + Glyph(58385)*6 end })
AddSpell({ 46968 },{ name = "Shockwave", color = { 0.6, 0, 1 }, duration = 4, multiTarget = true })
AddSpell({ 12809 },{ name = "Concussion Blow", color = { 1, 0.3, 0.6 }, duration = 5 })
AddSpell({ 355 },{ name = "Taunt", duration = 3 })
AddSpell({ 58567 },{ name = "Sunder Armor", short = "Sunder", anySource = true, color = { 1, 0.2, 0.2}, duration = 30 })
AddSpell({ 1160,6190,11554,11555,11556,25202,25203,47437 },{ name = "Demoralizing Shout", anySource = true, short = "DemoShout", color = {0.3, 0.9, 0.3}, duration = 30, multiTarget = true })
AddSpell({ 6343,8198,8204,8205,11580,11581,25264,47501,47502 },{ name = "Thunder Clap", anySource = true, color = {149/255, 121/255, 214/255}, duration = 30, multiTarget = true })
--~ AddSpell({ 56112 },{ name = "Furious Attacks", duration = 10 })
AddSpell({ 52437 },{ name = "Sudden Death", color = colors.LRED, duration = 10 })
AddSpell({ 60503 },{ name = "", recast_mark = 3, color = colors.RED, duration = 9 }) -- Overpower proc

AddCooldown( 12294, { name = "Mortal Strike",  color = colors.LBLUE })
AddCooldown( 23881, { name = "Bloodthirst",  color = colors.LBLUE })
AddCooldown( 23922, { name = "Shield Slam",  color = colors.LBLUE, resetable = true })
AddCooldown( 1680, { name = "Whirlwind" })
--~ AddCooldown( 6572, { name = "Revenge" })
end

if class == "DEATHKNIGHT" then
AddSpell({ 55095 },{ name = "Frost Fever", color = colors.CHILL, duration = 15, init = function(self)self.duration = 15 + Talent(49036)*3 end })
AddSpell({ 55078 },{ name = "Blood Plague", color = colors.PURPLE, duration = 15, init = function(self)self.duration = 15 + Talent(49036)*3 end })

--AddSpell({ 49194 },{ name = "Unholy Blight", color = colors.TEAL, duration = 20, init = function(self)self.duration = 20 + Glyph(63332)*10 end })
AddSpell({ 47805 },{ name = "Chains of Ice", color = colors.FROZEN, duration = 10 })
AddSpell({ 47476 },{ name = "Strangulate", duration = 5 })
AddSpell({ 48792 },{ name = "Icebound Fortitude", duration = 12, init = function(self)self.duration = 12 + Talent(50187)*2 end })
AddSpell({ 49016 },{ name = "Hysteria", duration = 30 })
AddSpell({ 51209 },{ name = "Hungering Cold", duration = 10, color = colors.FROZEN, multiTarget = true })
AddSpell({ 57330,57623 },{ name = "Horn of Winter", duration = 120, shout = true, color = colors.CURSE, multiTarget = true, short = "Horn", init = function(self)self.duration = 120 + Glyph(58680)*60 end })

AddSpell({ 51124 },{ name = "Killing Machine", duration = 30 })
AddSpell({ 59052 },{ name = "Freezing Fog", duration = 15 })
end

if class == "MAGE" then
-- BUFFS
AddSpell({ 12472 },{ name = "Icy Veins",duration = 20 })
AddSpell({ 12042 },{ name = "Arcane Power",duration = 15, short = "APwr" })
AddSpell({ 44401 },{ name = "Missile Barrage",duration = 15, color = colors.LRED, short = "Missiles!" })
AddSpell({ 48108 },{ name = "Hot Streak",duration = 10, color = colors.LRED, short = "Pyro!" })
AddSpell({ 57761 },{ name = "Brain Freeze",duration = 15, color = colors.LRED, short = "Fireball!" })
AddSpell({ 11426,13031,13032,13033,27134,33405,43038,43039,45740 },{ name = "Ice Barrier",duration = 60, color = colors.LGREEN })
--~ AddSpell({ 66 },{ name = "Fading",duration = 3 - NugRunning.TalentInfo(31574) })
AddSpell({ 32612 },{ name = "Invisibility",duration = 20 })
AddSpell({ 36032 },{ name = "Arcane Blast",duration = 10, color = colors.RED })
--~ AddSpell({ 55342 },{ name = "Mirror Image",duration = 30 })
AddSpell({ 45438 },{ name = "Ice Block",duration = 10 })
AddSpell({ 12536 },{ name = "Clearcast",duration = 15, color = colors.PURPLE })
--~ AddSpell({ 54741 },{ name = "Firestarter",duration = 10 })
-- DEBUFFS
AddSpell({ 22959 },{ name = "Improved Scorch",duration = 30, recast_mark = 2.5, color = colors.RED, short = "Scorch" })
AddSpell({ 44457,55359,55360 },{ name = "Living Bomb",duration = 12, color = colors.ORANGE, short = "Bomb" })
AddSpell({ 31589 },{ name = "Slow", duration = 15, pvpduration = 10 })
AddSpell({ 122,865,6131,10230,27088,42917 },{ name = "Frost Nova",duration = 8, short = "FrNova", color = colors.FROZEN, multiTarget = true })
AddSpell({ 12494 },{ name = "Frostbite",duration = 5, color = colors.FROZEN })
AddSpell({ 33395 },{ name = "Freeze",duration = 8, color = colors.FROZEN })
--~ AddSpell({ 12579 },{ name = "Winter's Chill",duration = 15, short = "WChill", maxtimers = 0 }) -- ignored if applied on nontargeted units
AddSpell({ 44544 },{ name = "Fingers of Frost",duration = 15, color = colors.FROZEN, short = "FoF" })
AddSpell({ 55080 },{ name = "Shattered Barrier",duration = 8, color = colors.FROZEN, short = "Shattered" })
AddSpell({ 44572 },{ name = "Deep Freeze",duration = 5 })
AddSpell({ 18469 },{ name = "Silenced",duration = 2, color = colors.PINK }) -- imp CS
AddSpell({ 55021 },{ name = "Silenced",duration = 4, color = colors.PINK }) -- imp CS
---
AddSpell({ 118 },{ name = "Polymorph", duration = 20, color = colors.LGREEN, pvpduration = 10, short = "Poly" })
AddSpell({ 12824 },{ name = "Polymorph", duration = 30, color = colors.LGREEN, pvpduration = 10, short = "Poly" })
AddSpell({ 12825 },{ name = "Polymorph", duration = 40, color = colors.LGREEN, pvpduration = 10, short = "Poly" })
AddSpell({ 61305,28272,61721,12826,61025,61780,28271 },{ name = "Polymorph", duration = 50, color = colors.LGREEN, pvpduration = 10, short = "Poly" })
--AOE
AddSpell({ 120,8492,10159,10160,10161,27087,42930,42931 },{ name = "Cone of Cold", duration = 8, color = colors.CHILL, short = "CoC", multiTarget = true })
AddSpell({ 2120,2121,8422,8423,10215,10216,27086,42925,42926 },{ name = "Flamestrike", duration = 8, multiTarget = true })
AddSpell({ 11113,13018,13019,13020,13021,27133,33933,42944,42945,44920 },{ name = "Blast Wave", color = colors.CHILL, duration = 6, multiTarget = true })
AddSpell({ 31661,33041,33042,33043,42949,42950 },{ name = "Dragon's Breath", duration = 5, color = colors.ORANGE, short = "Breath", multiTarget = true })

--~ AddCooldown( 2136, { name = "Fire Blast", color = colors.LRED})
end

if class == "PALADIN" then
AddSpell({ 20184 },{ name = "JoJustice",duration = 20, color = colors.CHILL })
--~ AddSpell({ 20185 },{ name = "JoLight",duration = 20, color = colors.PINK })
--~ AddSpell({ 20186 },{ name = "JoWisdom",duration = 20, color = colors.LBLUE })
AddSpell({ 31884 },{ name = "Avenging Wrath",duration = 20, short = "AW" })
AddSpell({ 498 },{ name = "Divine Protection",duration = 12, short = "DProt" })
AddSpell({ 642 },{ name = "Divine Shield",duration = 12, short = "DShield" })
AddSpell({ 1022, 5599, 10278 },{ name = "Hand of Protection",duration = 10, short = "HoProt" })
AddSpell({ 1044 },{ name = "Hand of Freedom",duration = 6, short = "Freedom" })
AddSpell({ 10326 },{ name = "Turn Evil",duration = 20, pvpduration = 10, color = colors.LGREEN })
--AddSpell({ 20925,20927,20928,27179,48951,48952 },{ name = "Holy Shield",duration = 10, color = colors.RED })
AddSpell({ 53563 },{ name = "Beacon of Light",duration = 60, short = "Beacon",color = colors.RED })
AddSpell({ 54428 },{ name = "Divine Plea",duration = 15, short = "Plea" })
AddSpell({ 53601 },{ name = "Sacred Shield",duration = 30 })
AddSpell({ 31842 },{ name = "Divine Illumination",duration = 15, short = "Illum" })
AddSpell({ 53489,59578 },{ name = "The Art of War",duration = 15, short = "TAoW" })
AddSpell({ 20066 },{ name = "Repentance",duration = 60, pvpduration = 10 })
AddSpell({ 853,5588,5589,10308 },{ name = "Hammer of Justice",duration = 6, short = "HoJ", color = colors.FROZEN })
AddSpell({ 31803 },{ name = "Holy Vengeance",duration = 15, color = colors.RED})


AddCooldown( 20925 ,{ name = "Holy Shield", color = colors.RED })
AddCooldown( 24275 ,{ name = "HoW", color = colors.TEAL })
AddCooldown( 879 ,{ name = "Exorcism", color = colors.ORANGE })
AddCooldown( 20271 ,{ name = "Judgement", color = colors.LRED })
AddCooldown( 26573 ,{ name = "Consecration", color = colors.CURSE })

AddCooldown( 35395 ,{ name = "Crusader Strike", color = colors.RED })
AddCooldown( 53385 ,{ name = "Divine Storm", color = colors.PURPLE })

AddCooldown( 53595 ,{ name = "HotR", color = colors.RED })
AddCooldown( 53600 ,{ name = "SoR", color = colors.PURPLE })


end

if class == "DRUID" then
AddSpell({ 774,1058,1430,2090,2091,3627,8910,9839,9840,9841,25299,26981,26982,48440,48441 },{ name = "Rejuvenation",duration = 15, color = { 1, 0.2, 1}, init = function(self)self.duration = 15 + Talent(57865)*3 end })
AddSpell({ 8936,8938,8939,8940,8941,9750,9856,9857,9858,26980,48442,48443 },{ name = "Regrowth",duration = 21, color = { 198/255, 233/255, 80/255}, init = function(self)self.duration = 21 + Talent(57865)*6 end })
AddSpell({ 33763,48450,48451 },{ name = "Lifebloom", duration = 7, init = function(self)self.duration = 7 + Talent(57865)*2 end })
AddSpell({ 2893 },{ name = "Abolish Poison", duration = 12 })
AddSpell({ 48438,53248,53249,53251 },{ name = "Wild Growth", duration = 7, multiTarget = true, color = colors.LGREEN })
AddSpell({ 29166 },{ name = "Innervate",duration = 10 })

AddSpell({ 22812 },{ name = "Barkskin",duration = 12 })
AddSpell({ 52610 },{ name = "Savage Roar",duration = function() return (9 + NugRunning.cpWas * 5) end })
AddSpell({ 1850,9821,33357 },{ name = "Dash", duration = 15 })

--~ AddSpell({ 48391 },{ name = "Owlkin Frenzy", duration = 10 })
AddSpell({ 48517 },{ name = "Solar Eclipse", duration = 15, short = "Solar", color = colors.ORANGE }) -- Wrath boost
AddSpell({ 48518 },{ name = "Lunar Eclipse", duration = 15, short = "Lunar", color = colors.FROZEN }) -- Starfire boost
AddSpell({ 50334 },{ name = "Berserk", duration = 15 })
AddSpell({ 16870 },{ name = "Clearcasting", duration = 15 })

AddSpell({ 8921,8924,8925,8926,8927,8928,8929,9833,9834,9835,26987,26988,48462,48463 },{ name = "Moonfire",duration = 9, color = colors.PURPLE, init = function(self)self.duration = 9 + Talent(57865)*3 end })
AddSpell({ 5570,24974,24975,24976,24977,27013,48468 },{ name = "Insect Swarm",duration = 12, color = colors.RED, init = function(self)self.duration = 12 + Talent(57865)*2 end })
AddSpell({ 339,1062,5195,5196,9852,9853,26989,53308 },{ name = "Entangling Roots",duration = 27 })

AddSpell({ 33786 },{ name = "Cyclone", duration = 6 })
AddSpell({ 770,16857 },{ name = "Faerie Fire",duration = 300,pvpduration = 40, color = colors.CURSE }) --second is feral
AddSpell({ 99,1735,9490,9747,9898,26998,48559,48560 },{ name = "Demoralizing Roar", short = "DemoRoar", color = {0.3, 0.9, 0.3}, duration = 30, multiTarget = true })
AddSpell({ 6795 },{ name = "Growl", duration = 3 })
AddSpell({ 16979 },{ name = "Feral Charge",duration = 4 })
AddSpell({ 1079,9492,9493,9752,9894,9896,27008,49799,49800 },{ name = "Rip",duration = 12, color = colors.RED, init = function(self)self.duration = 12 + Glyph(54818)*4 end })
AddSpell({ 5209 },{ name = "Challenging Roar", duration = 6, multiTarget = true })
AddSpell({ 5211,6798,8983 },{ name = "Bash",duration = 4, init = function(self)self.duration = 4 + Talent(16940)*0.5 end })
AddSpell({ 9005,9823,9827,27006,49803 },{ name = "Pounce", duration = 3, color = colors.PINK, init = function(self)self.duration = 3 + Talent(16940)*0.5 end })
AddSpell({ 9007,9824,9826,27007,49804 },{ name = "Pounce Bleed", duration = 18 })
AddSpell({ 1822,1823,1824,9904,27003,48573,48574 },{ name = "Rake", duration = 9, color = colors.PURPLE })
AddSpell({ 33878,33986,33987,48563,48564 },{ name = "Mangle", duration = 60 })
AddSpell({ 33876,33982,33983,48565,48566 },{ name = "Mangle", duration = 60 })
AddSpell({ 22570,49802 },{ name = "Maim", duration = function() return NugRunning.cpWas end })
AddSpell({ 33745,48567,48568 },{ name = "Lacerate", duration = 15, color = colors.RED })

AddSpell({ 2637 },{ name = "Hibernate",duration = 20 })
AddSpell({ 18657 },{ name = "Hibernate",duration = 30 })
AddSpell({ 18658 },{ name = "Hibernate",duration = 40, pvpduration = 10 })

AddCooldown(6793,  { name = "Tiger's Fury", color = colors.FROZEN})

end

if class == "HUNTER" then
AddSpell({ 56453 },{ name = "Lock and Load", duration = 12, color = colors.LRED })
AddSpell({ 19574 },{ name = "Bestial Wrath", duration = 18, color = colors.LRED })

AddSpell({ 136,3111,3661,3662,13542,13543,13544,27046,48989,48990,43350 },{ name = "Mend Pet", duration = 15, color = colors.LGREEN })

AddSpell({ 2974 },{ name = "Wing Clip", duration = 10, color = { 192/255, 77/255, 48/255} })
AddSpell({ 19306,20909,20910,27067,48998,48999 },{ name = "Counterattack", duration = 5, color = { 192/255, 77/255, 48/255} })
AddSpell({ 13797,14298,14299,14300,14301,27024,49053,49054 },{ name = "Immolation Trap", duration = 15, color = colors.ORANGE, init = function(self)self.duration = 15 - Glyph(56846)*6 end })
AddSpell({ 1978,13549,13550,13551,13552,13553,13554,13555,25295,27016,49000,49001 },{ name = "Serpent Sting", duration = 15, color = colors.PURPLE })
AddSpell({ 3034 },{ name = "Viper Sting", duration = 8, color = colors.LBLUE })
AddSpell({ 19503 },{ name = "Scatter Shot", duration = 4, color = colors.CHILL })
AddSpell({ 5116 },{ name = "Concussive Shot", duration = 4, color = colors.CHILL, init = function(self)self.duration = 4 + Talent(19407) end })
AddSpell({ 34490 },{ name = "Silencing Shot", duration = 3, color = colors.PINK, short = "Silence" })

AddSpell({ 53359 },{ name = "Disarmed", duration = 10, color = colors.RED }) --Chimera Shot - Scorpid
AddSpell({ 24394 },{ name = "Intimidation", duration = 3, color = colors.RED })
AddSpell({ 19386,24132,24133,27068,49011,49012 },{ name = "Wyvern Sting", duration = 8, short = "Wyvern",color = colors.RED })


AddSpell({ 3355 },{ name = "Freezing Trap", duration = 10, pvpduration = 10, color = colors.FROZEN, init = function(self)self.duration = 10 * (1+Talent(19376)*0.1) end })
AddSpell({ 14308 },{ name = "Freezing Trap", duration = 15, pvpduration = 10, color = colors.FROZEN, init = function(self)self.duration = 15 * (1+Talent(19376)*0.1) end })
AddSpell({ 14309 },{ name = "Freezing Trap", duration = 20, pvpduration = 10, color = colors.FROZEN, init = function(self)self.duration = 20 * (1+Talent(19376)*0.1) end })

AddSpell({ 1513 },{ name = "Scare Beast", duration = 10, pvpduration = 10, color = colors.CURSE })
AddSpell({ 14326 },{ name = "Scare Beast", duration = 15, pvpduration = 10, color = colors.CURSE })
AddSpell({ 14327 },{ name = "Scare Beast", duration = 20, pvpduration = 10, color = colors.CURSE })

AddCooldown( 53209 ,{ name = "Chimera Shot", color = colors.RED })
AddCooldown( 19434 ,{ name = "Aimed Shot", color = colors.LBLUE })
--AddCooldown( 2643 ,{ name = "Multi-Shot", color = colors.LBLUE })
AddCooldown( 3044 ,{ name = "Arcane Shot", color = colors.RED })
AddCooldown( 53301 ,{ name = "Explosive Shot", color = colors.RED })
AddCooldown( 3674 ,{ name = "Black Arrow", color = colors.CURSE })
end

if class == "SHAMAN" then
--~ AddSpell({ 8042,8044,8045,8046,10412,10413,10414,25454,49230,49231 },{ name = "Earth Shock", duration = 8, color = colors.ORANGE, short = "ErS" })
AddSpell({ 8056,8058,10472,10473,25464,49235,49236 },{ name = "Frost Shock", duration = 8, color = colors.CHILL, short = "FrS" })
AddSpell({ 8050,8052,8053,10447,10448,29228,25457,49232,49233 },{ name = "Flame Shock", duration = 18, color = colors.RED, short = "FlS" })


AddSpell({ 53817 },{ name = "Maelstrom Weapon", duration = 12, color = colors.PURPLE, short = "Maelstrom" })

AddCooldown( 17364 ,{ name = "Stormstrike", color = colors.CURSE, short = "SS" })
AddCooldown( 8042 ,{ name = "Shock", color = colors.LRED })
AddCooldown( 8056 ,{ name = "Shock", color = colors.LRED })
AddCooldown( 8050 ,{ name = "Shock", color = colors.LRED })
AddCooldown( 60103 ,{ name = "Lava Lash", color = colors.RED })
AddCooldown( 51505 ,{ name = "Lava Burst", color = colors.RED })

end