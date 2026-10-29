local _, helpers = ...

local NugRunning = CreateFrame("Frame","NugRunning", UIParent)

NugRunning:SetScript("OnEvent", function(self, event, ...)
    return self[event](self, event, ...)
end)

local L = setmetatable({}, {
    __index = function(t, k)
        return k
    end,
    __call = function(t,k) return t[k] end,
})
helpers.L = L
NugRunning.L = L

--- Compatibility with Classic
local apiLevel = math.floor(select(4,GetBuildInfo())/10000)
local isClassic = apiLevel <= 3
local isBC = apiLevel == 2
local isMainline = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE -- WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
-- local isClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC

--[[
local UnitSpellHaste = UnitSpellHaste
if apiLevel <= 2 then UnitSpellHaste = function() return 0 end end
if apiLevel == 3 then
    local GetCombatRatingBonus = GetCombatRatingBonus
    local CR_HASTE_SPELL = CR_HASTE_SPELL
    UnitSpellHaste = function() return GetCombatRatingBonus(CR_HASTE_SPELL) end
end
local GlobalGetSpecialization = C_SpecializationInfo and C_SpecializationInfo.GetSpecialization or _G.GetSpecialization
local GetSpecialization = apiLevel <= 3 and function() return nil end or GlobalGetSpecialization
]]
local LoadAddOn = LoadAddOn or C_AddOns.LoadAddOn


local NRunDB = nil
local config = NugRunningConfig
local spells = config.spells
local activations = config.activations
local cooldowns = config.cooldowns
local itemcooldowns = config.itemcooldowns
local event_timers = config.event_timers
local nameplates


local DeprecatedUnitAura = function(unitToken, index, filter)
    local auraData = C_UnitAuras.GetAuraDataByIndex(unitToken, index, filter);
    if not auraData then
        return nil;
    end

    return AuraUtil.UnpackAuraData(auraData);
end

local UnitAura = UnitAura or DeprecatedUnitAura

NugRunning.timers = alltimers
NugRunning.helpers = helpers

local defaultFont = "AlegreyaSans-Medium"
local defaultShowLocalNames = false
do
    local locale = GetLocale()
    if locale == "zhTW" or locale == "zhCN" or locale == "koKR" then
        defaultFont = LibStub("LibSharedMedia-3.0").DefaultMedia["font"]
        defaultShowLocalNames = true
        -- "預設" - zhTW
        -- "默认" - zhCN
        -- "기본 글꼴" - koKR
    end
end

local defaults = {
    anchors = {
        main = {
            point = "CENTER",
            parent = "UIParent",
            to = "CENTER",
            x = 0,
            y = 0,
        },
        secondary = {
            point = "CENTER",
            parent = "UIParent",
            to = "CENTER",
            x = -200,
            y = 0,
        },
    },
    groups = {
        player = { order = 1, name = "player", gap = 10, alpha = 1, anchor = "main" },
        target = { order = 2, name = "target", gap = 10, alpha = 1, anchor = "main"},
        buffs = { order = 3, name = "buffs", gap = 25, alpha = 1, anchor = "main"},
        offtargets = { order = 4, name = "offtargets", gap = 6, alpha = .7, anchor = "main"},
        procs = { order = 1, name = "procs", gap = 10, alpha = .8, anchor = "secondary"},
    },
    growth = "up",
    width = 150,
    height = 20,
    np_height = 7,
    np_width = 74,
    np_xoffset = 0,
    np_yoffset = 0,
    cooldownsEnabled = true,
    missesEnabled = true,
    targetTextEnabled = false,
    spellTextEnabled = true,
    shortTextEnabled = true,
    swapTarget = true,
    localNames = defaultShowLocalNames,
    totems = true,
    leaveGhost = true,
    nameplates = true,
    preghost = true,
    dotpower = true,
    dotticks = true,
    textureName = "Aluminium",
    nptextureName = "Aluminium",
    nameFont = { font = defaultFont, size = 10, alpha = 0.5, outline = false },
    timeFont = { font = defaultFont, size = 8, alpha = 1, outline = false },
    stackFont = { font = defaultFont, size = 12, outline = true },
}


local MergeTable = helpers.MergeTable
local RemoveDefaultsPreserve = helpers.RemoveDefaultsPreserve
local RemoveDefaults = helpers.RemoveDefaults
local SetupDefaults = helpers.SetupDefaults
NugRunning.SetupDefaults = SetupDefaults
NugRunning.RemoveDefaults = RemoveDefaults
NugRunning.RemoveDefaultsPreserve = RemoveDefaultsPreserve
NugRunning.MergeTable = MergeTable


NugRunning:RegisterEvent("PLAYER_LOGIN")
NugRunning:RegisterEvent("PLAYER_LOGOUT")
function NugRunning.PLAYER_LOGIN(self,event,arg1)
    NRunDB_Global = NRunDB_Global or {}
    NRunDB_Char = NRunDB_Char or {}
    NRunDB_Global.charspec = NRunDB_Global.charspec or {}
    local user = UnitName("player").."@"..GetRealmName()
    if NRunDB_Global.charspec[user] then
        NRunDB = NRunDB_Char
    else
        NRunDB = NRunDB_Global
    end
    NugRunning.db = NRunDB

    SetupDefaults(NRunDB, defaults)

    NugRunningConfigCustom = NugRunningConfigCustom or {}

    NugRunningConfigMerged = CopyTable(NugRunningConfig)

    local _, class = UnitClass("player")
    local categories = {"spells", "cooldowns", "activations", "casts"}
    if not NugRunningConfigCustom[class] then NugRunningConfigCustom[class] = {} end

    local function fixRemovedDefaultSpells(customConfig, defaultConfig)
        if not (customConfig and defaultConfig) then return end
        local toRemove = {}
        for spellID, opts in pairs(customConfig) do
            local dopts = defaultConfig[spellID]
            if not dopts and not opts.name then
                table.insert(toRemove, spellID)
            elseif opts.name then -- then it's a is probably an added spell
                opts.isAdded = true -- making sure it's marked as added
            end
        end
        for _, spellID in ipairs(toRemove) do
            customConfig[spellID] = nil
        end
    end

    local globalConfig = NugRunningConfigCustom["GLOBAL"]
    if globalConfig then
        for _, category in ipairs(categories) do
            fixRemovedDefaultSpells(globalConfig[category], config[category])
        end
    end
    MergeTable(NugRunningConfigMerged, globalConfig)
    local classConfig = NugRunningConfigCustom[class]
    if classConfig then
        for _, category in ipairs(categories) do
            fixRemovedDefaultSpells(classConfig[category], config[category])
        end
    end
    MergeTable(NugRunningConfigMerged, classConfig)
    config = NugRunningConfigMerged
    spells = config.spells
    activations = config.activations
    cooldowns = config.cooldowns
    itemcooldowns = config.itemcooldowns
    event_timers = config.event_timers

    -- filling up ranks for spells and casts
    local cloneIDs = {}
    local rankCategories = { "spells", "casts" }
    local tempTable = {}
    for _, category in ipairs(rankCategories) do
        table.wipe(tempTable)
        for spellID, opts in pairs(config[category]) do
            if not cloneIDs[spellID] and opts.clones then
                opts.clones[spellID] = nil -- Removing possible input of original spell ID into clone list
                for i, additionalSpellID in ipairs(opts.clones) do
                    tempTable[additionalSpellID] = opts
                    cloneIDs[additionalSpellID] = spellID
                end
            end
        end
        for spellID, opts in pairs(tempTable) do
            config[category][spellID] = opts
        end
    end
    config.spellClones = cloneIDs


    NugRunning:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

    NugRunning:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
    if not isClassic then NugRunning:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED") end
    NugRunning.ACTIVE_TALENT_GROUP_CHANGED = NugRunning.ReInitSpells
    -- NugRunning:RegisterEvent("PLAYER_TALENT_UPDATE")
    -- NugRunning.PLAYER_TALENT_UPDATE = NugRunning.ReInitSpells
    NugRunning.CHARACTER_POINTS_CHANGED = NugRunning.ReInitSpells
    NugRunning.SPELLS_CHANGED = NugRunning.ReInitSpells
    NugRunning:RegisterEvent("CHARACTER_POINTS_CHANGED")
    NugRunning:RegisterEvent("SPELLS_CHANGED")

    NugRunning:ReInitSpells()


    if NRunDB.nameplates then
        --[[
        local found
        for _, opts in pairs(config.spells) do
            if opts.nameplates then found = true; break end
        end
        if found then
            NugRunning:DoNameplates()
            nameplates = NugRunningNameplates
        end
        ]]
    end



    --[[
    NugRunning.anchors = {}
    for name, opts in pairs(NRunDB.anchors) do
        local anchor = NugRunning:CreateAnchor(name, opts)
        NugRunning.anchors[name] = anchor
    end
    ]]

    SLASH_NUGRUNNING1= "/nugrunning"
    SLASH_NUGRUNNING2= "/nrun"
    SlashCmdList["NUGRUNNING"] = NugRunning.SlashCmd


    local f = CreateFrame('Frame', nil, SettingsPanel or InterfaceOptionsFrame)
    f:SetScript('OnShow', function(self)
        self:SetScript('OnShow', nil)
        LoadAddOn('NugRunningOptions')
    end)
end

function NugRunning.PLAYER_LOGOUT(self, event)
    RemoveDefaults(NRunDB, defaults)
end

local hookedViewers = {}


function NugRunning.MakeName(self, opts, spellName, dstName)
    if NRunDB.targetTextEnabled and dstName ~= UnitName("player") then
        return dstName
    elseif NRunDB.spellTextEnabled then
        if NRunDB.localNames then
            return spellName
        elseif NRunDB.shortTextEnabled and opts.short then
            return opts.short
        else
            return opts.name
        end
    else
        return ""
    end
end


function NugRunning.ReInitSpells(self,event,arg1)
    --[[
    for id,opts in pairs(spells) do
        if type(opts) == "table" and opts.init then
            opts:init()
            opts.init_done = true
        end
    end
    for id, opts in pairs(event_timers) do
        if opts.init then
            opts:init()
            opts.init_done = true
        end
    end
    for id,opts in pairs(cooldowns) do
        if opts.init then
            opts:init()
            opts.init_done = true
        end
    end
    ]]
end


local function Colorize(hexColor, text)
    return "|cff" .. tostring(hexColor or 'ffffff') .. tostring(text) .. "|r"
end

local ParseOpts = function(str)
    local t = {}
    local capture = function(k,v)
        t[k:lower()] = tonumber(v) or v
        return ""
    end
    str:gsub("(%w+)%s*=%s*%[%[(.-)%]%]", capture):gsub("(%w+)%s*=%s*(%S+)", capture)
    return t
end

local function InterfaceOptionsFrame_OpenToCategory(categoryIDOrFrame)
	if type(categoryIDOrFrame) == "table" then
		local categoryID = categoryIDOrFrame.name;
		return Settings.OpenToCategory(categoryID);
	else
		local AceConfigDialog = LibStub("AceConfigDialog-3.0", true)
		local categoryID = AceConfigDialog and AceConfigDialog.BlizOptionsIDMap and AceConfigDialog.BlizOptionsIDMap[categoryIDOrFrame]
        return Settings.OpenToCategory(categoryID)
	end
end

NugRunning.Commands = {
    ["unlock"] = function()
        for name, anchor in pairs(NugRunning.anchors) do
            anchor:Show()
        end
        NugRunning:Unlock()
    end,
    ["lock"] = function()
        for name, anchor in pairs(NugRunning.anchors) do
            anchor:Hide()
        end
        for _,timer in ipairs(alltimers) do
            if not timer:IsActive() then
                timer:Hide()
            end
        end
        NugRunning.unlocked = nil
    end,
    ["gui"] = function(v)
        LoadAddOn('NugRunningOptions')
        InterfaceOptionsFrame_OpenToCategory("NugRunning")
        InterfaceOptionsFrame_OpenToCategory("NugRunning")
    end,
    ["listauras"] = function(v)
        local unit = v
        local h = false
        for i=1, 100 do
            local name, _,_,_,duration,_,_,_,_, spellID = UnitAura(unit, i, "HELPFUL")
            if not name then break end
            if not h then print("BUFFS:"); h = true; end
            print(string.format("    %s (id: %d) Duration: %s", name, spellID, duration or "none" ))
        end
        h = false
        for i=1, 100 do
            local name, _,_,_,duration,_,_,_,_, spellID = UnitAura(unit, i, "HARMFUL")
            if not name then break end
            if not h then print("DEBUFFS:"); h = true; end
            print(string.format("    %s (id: %d) Duration: %s", name, spellID, duration or "none" ))
        end

    end,
    ["reset"] = function()
        for name, anchor in pairs(NRunDB.anchors) do
            anchor.point = "CENTER"
            anchor.parent = "UIParent"
            anchor.to = "CENTER"
            anchor.x = 0
            anchor.y = 0
            local pos = anchor
            if NugRunning.anchors[name] then
                NugRunning.anchors[name]:SetPoint(pos.point, pos.parent, pos.to, pos.x, pos.y)
            end
        end
    end,
    ["clear"] = function()
        NugRunning:ClearTimers(true)
    end,
    ["charspec"] = function()
        local user = UnitName("player").."@"..GetRealmName()
        if NRunDB_Global.charspec[user] then NRunDB_Global.charspec[user] = nil
        else NRunDB_Global.charspec[user] = true
        end
        print ("NRun: "..(NRunDB_Global.charspec[user] and "Enabled" or "Disabled").." character specific options. Will take effect after /reload")
    end,
    ["cooldowns"] = function()
        if NRunDB.cooldownsEnabled then
            NugRunning:UnregisterEvent("SPELL_UPDATE_COOLDOWN")
            if NugRunning.cooldownTicker then NugRunning.cooldownTicker:Cancel() end
        else
            NugRunning:RegisterEvent("SPELL_UPDATE_COOLDOWN")
            NugRunning.cooldownTicker = C_Timer.NewTicker(1, function()
                NugRunning:SPELL_UPDATE_COOLDOWN("PERIODIC_COOLDOWN_UPDATE", true)
            end)
        end
        NRunDB.cooldownsEnabled = not NRunDB.cooldownsEnabled
        print("NRun cooldowns "..(NRunDB.cooldownsEnabled and "enabled" or "disabled"))
    end,
    ["targettext"] = function()
        NRunDB.targetTextEnabled = not NRunDB.targetTextEnabled
        print("NRun target name text "..(NRunDB.targetTextEnabled and "enabled" or "disabled"))
    end,
    ["spelltext"] = function()
        NRunDB.spellTextEnabled = not NRunDB.spellTextEnabled
        print("NRun spell text "..(NRunDB.spellTextEnabled and "enabled" or "disabled"))
    end,
    ["leaveghost"] = function()
        NRunDB.leaveGhost = not NRunDB.leaveGhost
        print("NRun leaveghost "..(NRunDB.leaveGhost and "enabled" or "disabled"))
    end,
    ["shorttext"] = function()
        NRunDB.shortTextEnabled = not NRunDB.shortTextEnabled
        print("NRun short spell text "..(NRunDB.shortTextEnabled and "enabled" or "disabled"))
    end,
    ["localnames"] = function()
        NRunDB.localNames = not NRunDB.localNames
        print("NRun localized spell names "..(NRunDB.localNames and "enabled" or "disabled"))
    end,
    ["misses"] = function()
        NRunDB.missesEnabled = not NRunDB.missesEnabled
        print("NRun miss timers "..(NRunDB.missesEnabled and "enabled" or "disabled"))
    end,
    ["swaptarget"] = function()
        NRunDB.swapTarget = not NRunDB.swapTarget
        NugRunning:SetupArrange()
        NugRunning:ArrangeTimers()
        print("Target swapping turned "..(NRunDB.swapTarget and "on" or "off"))
    end,
    ["totems"] = function()
        NRunDB.totems = not NRunDB.totems
        print("Totems turned "..(NRunDB.swapTarget and "on" or "off")..". Will take effect after /reload")
    end,
    ["nameplates"] = function()
        NRunDB.nameplates = not NRunDB.nameplates
        print("Nameplates turned "..(NRunDB.nameplates and "on" or "off")..". Will take effect after /reload")
    end,
    ["dotticks"] = function()
        NRunDB.dotticks = not NRunDB.dotticks
        print("Dot ticks turned "..(NRunDB.dotticks and "on" or "off")..". Will take effect after /reload")
    end,
    ["dotpower"] = function()
        NRunDB.dotpower = not NRunDB.dotpower
        print("Dotpower turned "..(NRunDB.dotpower and "on" or "off")..". Will take effect after /reload")
    end,

    ["listgroups"] = function(v)
        print("|cffffaaaaNugRunning Groups:|r")
        local sortedGroups = NugRunning:MakeSortedGroupsTable()
        for anchorName, opts in pairs(NRunDB.anchors) do
            local hdr = string.format("Anchor: |cff33ff33%s|r", anchorName)
            if opts.growth then
                hdr = hdr .. string.format(" : growth=%s", opts.growth)
            end
            print(hdr)

            local groups = sortedGroups[anchorName]
            if groups then
                for i, g in ipairs(groups) do
                    local color = "ffffff"
                    if protectedGroups[g.name] then color = "888888" end

                    print(string.format("    <%d> %s : gap=%d alpha=%.2f order=%d",i, Colorize(color,g.name), g.gap, g.alpha, g.order))
                end
            end
        end
    end,


    ["set"] = function(v)
        local p = ParseOpts(v)
        NRunDB.width = p["width"] or NRunDB.width
        NRunDB.height = p["height"] or NRunDB.height
        local aname = p["anchor"]
        if aname then
            local growth = p["growth"]
            if NRunDB.anchors[aname] and growth then
                NRunDB.anchors[aname].growth = growth
            end
        else
            NRunDB.growth = p["growth"] or NRunDB.growth
        end
        for i,timer in ipairs(alltimers) do
            timer:Resize(NRunDB.width, NRunDB.height)

        end
        if NugRunning.unlocked  then
            NugRunning:Unlock()
        elseif NRunDB.growth then
            for i,timer in ipairs(alltimers) do timer:ClearAllPoints() end
            NugRunning:SetupArrange()
            NugRunning:ArrangeTimers()
        end
    end,
    ["debug"] = function()
        if not NugRunning.debug then
            NugRunning.debug = CreateFrame("Frame")
            NugRunning.debug:SetScript("OnEvent",function( self, event )
                local timestamp, eventType, hideCaster,
                srcGUID, srcName, srcFlags, srcFlags2,
                dstGUID, dstName, dstFlags, dstFlags2,
                spellID, spellName, spellSchool, auraType, amount = CombatLogGetCurrentEventInfo()
                local isSrcPlayer = (bit_band(srcFlags, COMBATLOG_OBJECT_AFFILIATION_MINE) == COMBATLOG_OBJECT_AFFILIATION_MINE)
                if isSrcPlayer then
                    if string.sub(eventType, 1, 5) == "SPELL" then
                        print ("ID:", spellID, string.format("|cffff8800%s|r",spellName), eventType, srcFlags, srcGUID,"|cff00ff00==>|r", dstGUID, dstFlags, amount)
                    else
                        print ("ID:", spellID, spellName, eventType, srcFlags, srcGUID,"|cff00ff00==>|r", dstGUID, dstFlags, amount)
                    end
                end
            end)
        end
        if not NugRunning.debug.enabled then
            NugRunning.debug:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
            NugRunning.debug.enabled = true
            print("[NugRunning] Enabled combat log event display")
        else
            NugRunning.debug:UnregisterAllEvents()
            NugRunning.debug.enabled = false
            print("[NugRunning] Disabled combat log event display")
        end
    end,
}

function NugRunning.SlashCmd(msg)
    local k,v = string.match(msg, "([%w%+%-%=]+) ?(.*)")
    if not k or k == "help" then print([[Usage:
        |cff00ff00/nrun lock|r
        |cff00ff00/nrun unlock|r
        |cff00ff00/nrun reset|r
        |cff00ff00/nrun clear|r
        |cff00ff00/nrun debug|r
        |cff00ff00/nrun charspec|r : enable character specific settings
        |cff00ff00/nrun misses|r : toggle misses (immunes, resists)
        |cff00ff00/nrun cooldowns|r : toggle showing cooldowns
        |cff00ff00/nrun spelltext|r : toggle spell text on bars
        |cff00ff00/nrun shorttext|r : toggle using short names
        |cff00ff00/nrun nameplates|r : toggle nameplate timers
        |cff00ff00/nrun localnames|r: toggle localized spell names
        |cff00ff00/nrun set|r width=150 height=20 growth=up/down
        ]]
    )end
    if NugRunning.Commands[k] then
        NugRunning.Commands[k](v)
    end

end

function NugRunning:CreateAnchor(name, opts)
    local f = CreateFrame("Frame",nil,UIParent)
    f:SetHeight(20)
    f:SetWidth(20)
    f:EnableMouse(true)
    f:SetMovable(true)
    f:Hide()

    local t = f:CreateTexture(nil,"BACKGROUND")
    t:SetTexture("Interface\\Buttons\\UI-RadioButton")
    t:SetTexCoord(0,0.25,0,1)
    t:SetAllPoints(f)

    t = f:CreateTexture(nil,"BACKGROUND")
    t:SetTexture("Interface\\Buttons\\UI-RadioButton")
    t:SetTexCoord(0.25,0.49,0,1)
    t:SetVertexColor(1, 0, 0)
    t:SetAllPoints(f)

    local label = f:CreateFontString(nil,"ARTWORK")
    label:SetFontObject("GameFontNormal")
    label:SetText(string.format("%s ->", name))
    label:SetPoint("RIGHT", f, "LEFT", 0,0)

    if not NRunDB.anchors[name] then
        NRunDB.anchors[name] = { point = "CENTER", parent ="UIParent", to = "CENTER", x = 0, y = 0}
    end
    f.db_tbl = NRunDB.anchors[name]
    f:SetScript("OnMouseDown",function(self)
        self:StartMoving()
    end)
    f:SetScript("OnMouseUp",function(self)
            local pos = self.db_tbl
            self:StopMovingOrSizing();
            local point,_,to,x,y = self:GetPoint(1)
            pos.point = point
            pos.parent = "UIParent"
            pos.to = to
            pos.x = x
            pos.y = y
    end)

    local pos = f.db_tbl
    if not _G[pos.parent] then
        pos = { point = "CENTER", parent = "UIParent", to = "CENTER", x = 0, y = 0}
    end
    f:SetPoint(pos.point, pos.parent, pos.to, pos.x, pos.y)
    return f
end


