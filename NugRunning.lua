local addonName, helpers = ...

local NugRunning = CreateFrame("Frame","NugRunning", UIParent)

NugRunning:SetScript("OnEvent", function(self, event, ...)
    return self[event](self, event, ...)
end)

local L = helpers.L
NugRunning.L = L

local isForever = WOW_PROJECT_ID == WOW_PROJECT_CAMELOT
local isClassic = WOW_PROJECT_ID == WOW_PROJECT_CLASSIC
local isMainline = WOW_PROJECT_ID == WOW_PROJECT_MAINLINE

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
local simplePandemic = true
local pixelperfect = helpers.pixelperfect

local DeprecatedUnitAura = function(unitToken, index, filter)
    local auraData = C_UnitAuras.GetAuraDataByIndex(unitToken, index, filter);
    if not auraData then
        return nil;
    end

    return AuraUtil.UnpackAuraData(auraData);
end

local UnitAura = UnitAura or DeprecatedUnitAura

local CVBuffBars = {}
local CVCooldownFrames = {}
NugRunning.timers = CVBuffBars
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
local LSM = LibStub("LibSharedMedia-3.0")

LSM:Register("statusbar", "Aluminium", [[Interface\AddOns\NugRunning\statusbar.tga]])
LSM:Register("font", "AlegreyaSans-Medium", [[Interface\AddOns\NugRunning\AlegreyaSans-Medium.ttf]],  GetLocale() ~= "enUS" and 15)

local defaults = {
    --[[
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
    ]]
    growth = "up",
    width = 150,
    height = 28,
    simplePandemic = true,
    borderType = "ROUNDED",
    np_height = 7,
    np_width = 74,
    np_xoffset = 0,
    np_yoffset = 0,
    -- localNames = defaultShowLocalNames,
    nameplates = true,
    textureName = "Aluminium",
    nptextureName = "Aluminium",
    nameFont = { font = defaultFont, size = 11, alpha = 0.5, outline = false },
    timeFont = { font = defaultFont, size = 14, alpha = 1, outline = false },
    stackFont = { font = defaultFont, size = 15, outline = true },
}


local MergeTable = helpers.MergeTable
local RemoveDefaultsPreserve = helpers.RemoveDefaultsPreserve
local RemoveDefaults = helpers.RemoveDefaults
local SetupDefaults = helpers.SetupDefaults
NugRunning.SetupDefaults = SetupDefaults
NugRunning.RemoveDefaults = RemoveDefaults
NugRunning.RemoveDefaultsPreserve = RemoveDefaultsPreserve
NugRunning.MergeTable = MergeTable

NugRunning:RegisterEvent("ADDON_LOADED")
NugRunning:RegisterEvent("COOLDOWN_VIEWER_DATA_LOADED")
NugRunning:RegisterEvent("PLAYER_LOGOUT")
function NugRunning.ADDON_LOADED(self,event, loadedAddon)
    if loadedAddon ~= addonName then return end
    self:UnregisterEvent("ADDON_LOADED")

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

function NugRunning:COOLDOWN_VIEWER_DATA_LOADED(event)
    self:Init()
end
function NugRunning:Init()
    self:InstallBarHooks(BuffBarCooldownViewer)
    self:InstallCooldownHooks(EssentialCooldownViewer)
    self:InstallCooldownHooks(UtilityCooldownViewer)
    self:InstallCooldownHooks(BuffIconCooldownViewer)
end


local hookedViewers = {}
function NugRunning:InstallBarHooks(viewer)
    -- Viewer becomes visible/hidden when CDM gets turned on in the blizz settings or during fresh login cold start
    -- COLD START:
    -- COOLDOWN_VIEWER_DATA_LOADED
    -- 2x OnAcquireItemFrame
    -- THEN Viewer Frame gets Shown
    -- 4x OnAcquireItemFrame

    -- RELOAD START:
    -- COOLDOWN_VIEWER_DATA_LOADED
    -- Viewer is already Shown and enabled
    -- So have to style the existing bars

    -- Also these bars never get :Released()
    -- They're essentially reserved once and then always stay "active" in the Frame Pool
    -- Even if not active in the CDM
    -- That's why viewer.itemFramePool:EnumerateActive() iterates over all frames
    -- viewer:HookScript("OnShow", function(self)
    --     print("Show()")
    -- end)

    -- viewer:HookScript("OnHide", function(self)
    --     print("Hide()")
    -- end)

    -- BuffBarCooldownViewer is always loaded and pesent on launch, even if disabled in the Settings
    if BuffBarCooldownViewer then
        -- print("Installing hooks on", viewer:GetName())
        hooksecurefunc(BuffBarCooldownViewer, "OnAcquireItemFrame", function(self, itemFrame)
            -- print(string.format("|cff00ffff%s|r", "DIRECT OnAcquireItemFrame"))
            NugRunning:StyleBarItemFrame(itemFrame)
        end)

        -- hooksecurefunc(BuffBarCooldownViewerMixin, "OnAcquireItemFrame", function(self, frame)
        --     print(string.format("|cff00ff00%s|r", "MIXIN"))
        --     print(self:GetName(), frame:GetName())
        -- end)

        for itemFrame in viewer.itemFramePool:EnumerateActive() do
            -- print(string.format("|cff00ffff%s|r", "Styling"), itemFrame)
            NugRunning:StyleBarItemFrame(itemFrame)
        end


        -- Reanchor Vanilla Pandemic Frame (they come from a separate frame pool)
        -- https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_CooldownViewer/CooldownViewer.lua#L2130
        hooksecurefunc(BuffBarCooldownViewer, "AnchorPandemicStateFrame", function(self, pandemicFrame, itemFrame)
            -- print(itemFrame, "AnchorPandemicStateFrame")
            if simplePandemic then
                pandemicFrame.Texture:Hide()
                pandemicFrame.Border:Hide()
            else
                -- pandemicFrame.Texture:Show()
                pandemicFrame.Texture:Hide()
                -- pandemicFrame.Texture:SetAlpha(0.5)
                pandemicFrame.Border:Show()
                -- pandemicFrame.Border:SetAlpha(0.5)

                local offset = pixelperfect(9, itemFrame)
                pandemicFrame:SetPoint("TOPLEFT", itemFrame.Bar, "TOPLEFT", -offset, offset);
	            pandemicFrame:SetPoint("BOTTOMRIGHT", itemFrame.Bar, "BOTTOMRIGHT", offset, -offset);
            end
        end)
        -- hooksecurefunc(BuffBarCooldownViewer, "HidePandemicStateFrame", function(self, itemFrame)
        --     print(itemFrame, "HidePandemicStateFrame")
        -- end)
        -- hooksecurefunc(BuffBarCooldownViewer, "SetupPandemicStateFrameForItem", function(self, itemFrame)
        --     print(itemFrame, "SetupPandemicStateFrameForItem")
        -- end)
        hookedViewers[viewer] = true
    end
end


local function GetRectTexCoords(rectX, rectY, rectWidth, rectHeight)
    local left   = rectX / 1
    local right  = (rectX + rectWidth) / 1
    local top    = rectY / 1
    local bottom = (rectY + rectHeight) / 1

    return left, right, top, bottom
end


local function UpdateFrameBorder(self, borderType)
    local border = self.Border or self:CreateTexture(nil, "BACKGROUND")
    self.Border = border
    if borderType == "2PX" then
        border:SetDrawLayer("BACKGROUND", -2)
        local offset = pixelperfect(2, self)
        border:SetTexture("Interface\\BUTTONS\\WHITE8X8")
        border:SetTextureSliceMargins(0,0,0,0)
        border:SetVertexColor(0,0,0, 0.5)
        border:SetPoint("TOPLEFT", -offset, offset)
        border:SetPoint("BOTTOMRIGHT", offset, -offset)

    elseif borderType == "1PX" then
        border:SetDrawLayer("BACKGROUND", -2)
        local offset = pixelperfect(1, self)
        border:SetTexture("Interface\\BUTTONS\\WHITE8X8")
        border:SetTextureSliceMargins(0,0,0,0)
        border:SetVertexColor(0,0,0, 1)
        border:SetPoint("TOPLEFT", -offset, offset)
        border:SetPoint("BOTTOMRIGHT", offset, -offset)

    elseif borderType == "ROUNDED" then
        border:SetDrawLayer("OVERLAY", 3)
        local offset = pixelperfect(1, self)
        border:SetTexture("Interface\\AddOns\\NugRunning\\border_rounded")
        border:SetVertexColor(0,0,0, 1)
        border:SetTextureSliceMargins(5,5,5,5)
        border:SetPoint("TOPLEFT", -offset, offset)
        border:SetPoint("BOTTOMRIGHT", offset, -offset)

    elseif borderType == "STATUSBAR" then
        border:SetDrawLayer("OVERLAY", 3)
        local offset = pixelperfect(3, self)
        border:SetTexture("Interface\\AddOns\\NugRunning\\border_statusbar_slicing")
        border:SetVertexColor(1,1,1, 1)
        border:SetTextureSliceMargins(5,5,5,5)
        border:SetPoint("TOPLEFT", -offset, offset)
        border:SetPoint("BOTTOMRIGHT", offset, -offset)

    elseif borderType == "STATUSBARDARK" then
        border:SetDrawLayer("OVERLAY", 3)
        local offset = pixelperfect(3, self)
        border:SetTexture("Interface\\AddOns\\NugRunning\\border_statusbar_slicing")
        border:SetVertexColor(0.7,0.7,0.7, 1)
        border:SetTextureSliceMargins(5,5,5,5)
        border:SetPoint("TOPLEFT", -offset, offset)
        border:SetPoint("BOTTOMRIGHT", offset, -offset)
    end
end

local GetFontSettings = function(labelName)
	local s = NugRunning.db[labelName]
    if not s then return defaultFont, 14, 1, "OUTLINE" end
	return LSM:Fetch("font", s.font), s.size, s.alpha, s.outline
end


function NugRunning:UpdateAllCVBuffBars()
    for itemFrame in pairs(CVBuffBars) do
        NugRunning:StyleBarItemFrame(itemFrame, true) -- force re-styling
    end
end


local function ChangeToCustomBarColor(frame)
    local spellID = frame:GetBaseSpellID() -- Just use this one
    if not issecretvalue(spellID) and spellID then
        local opts = spells[spellID]
        if opts then
            frame.Bar.BarBG2:SetTexture("Interface\\BUTTONS\\WHITE8X8")
            local color = opts.color
            if color then
                frame.Bar.BarBG2:SetVertexColor(unpack(color))
                frame.Bar.Pip:SetVertexColor(unpack(color))
                return true
            end
        end
    end
end

function NugRunning:StyleBarItemFrame(frame, force)
    if CVBuffBars[frame] and not force then return end
    -- if frame.isNugRunningStyled and not force then return end
    CVBuffBars[frame] = true
    frame.isNugRunningStyled = true

    -- /dump BuffBarCooldownViewer.itemFramePool:EnumerateActive()()


    -- Whole bar item fram is 220x30
    -- https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_CooldownViewer/CooldownViewer.xml#L209
    -- Icon is 30x30 anchored to LEFT
    -- Bar is 19px height, anchored to Icon's RIGHT +2, and to the parent frame's RIGHT
    -- Bar Vanilla Bar Width is 220 - 30 - 2 = 188

    local texture = LSM:Fetch("statusbar", NugRunning.db.textureName)
    local white = "Interface\\BUTTONS\\WHITE8X8"

    local bar = frame.Bar
    local icon = frame.Icon

    local height = pixelperfect(self.db.height, frame)
    -- print("bar scale", bar:GetEffectiveScale())
    -- print("viewer scale", bar:GetParent():GetEffectiveScale())
    bar:SetHeight(height)

    simplePandemic = self.db.simplePandemic


    local centerSpellNameText = true

    local nameText = bar.Name
    local nameFont, nameSize, nameAlpha, nameOutline = GetFontSettings("nameFont")
    nameText:SetFont(nameFont, nameSize, nameOutline and "OUTLINE" or nil)
    nameText:SetAlpha(nameAlpha or 1)

    if centerSpellNameText then
        nameText:SetWidth(bar:GetWidth()*0.8)
        nameText:SetJustifyH("CENTER")
        nameText:ClearAllPoints()
        nameText:SetPoint("CENTER", bar, "CENTER", 0, 0)
    end


    local timeText = bar.Duration
    local timeFont, timeSize, timeAlpha, timeOutline = GetFontSettings("timeFont")
    timeText:SetFont(timeFont, timeSize, timeOutline and "OUTLINE" or nil)
    timeText:SetJustifyH("RIGHT")
    timeText:SetAlpha(timeAlpha or 1)

    local stackText = icon.Applications
    local stackFont, stackSize = GetFontSettings("stackFont")
    stackText:SetFont(stackFont, stackSize, "OUTLINE")
    stackText:ClearAllPoints()
    stackText:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT",2,4)


    bar:SetStatusBarTexture(white)
    bar:SetStatusBarColor(1,1,1, 0.2)
    local barTex = bar:GetStatusBarTexture()
    barTex:SetBlendMode("ADD")

    -- bar.BarBG:ClearAllPoints()
    -- bar.BarBG:SetAllPoints(bar)
    -- bar.BarBG:SetTexture(texture)
    -- bar.BarBG:SetVertexColor(0.2, 0.2, 0.2)
    -- Just hiding the vanilla background because it's weird
    bar.BarBG:Hide()

    bar.Pip:SetBlendMode("ADD")
    bar.Pip:SetDrawLayer("OVERLAY", 5)
    bar.Pip:SetTexture("Interface\\AddOns\\NugRunning\\spark")
    bar.Pip:SetHeight(height)
    bar.Pip:SetWidth(height)
    bar.Pip:SetVertexColor(1,0.8,0.5)
    bar.Pip:ClearAllPoints()
    bar.Pip:SetPoint("CENTER", barTex, "RIGHT", 0,0)

    local shaded = bar._NRShaded or bar:CreateTexture(nil, "ARTWORK")
    shaded:SetTexture(white)
    shaded:SetVertexColor(0,0,0, 0.6)
    shaded:SetPoint("BOTTOMLEFT", barTex, "BOTTOMRIGHT", 0, 0)
    shaded:SetPoint("TOPRIGHT", bar, "TOPRIGHT", 0, 0)
    bar._NRShaded = shaded

    if simplePandemic then
        local pandemicOverlay = bar.NRPandemic or bar:CreateTexture(nil, "ARTWORK")
        -- pandemicOverlay:SetTexture(white)
        -- pandemicOverlay:SetBlendMode("ADD")
        -- pandemicOverlay:SetVertexColor(1,0,0, 0.35)
        -- pandemicOverlay:SetAllPoints(barTex)
        pandemicOverlay:SetVertexColor(1,0,0)
        pandemicOverlay:SetWidth(5)
        pandemicOverlay:SetPoint("TOPRIGHT", icon, "TOPLEFT",0,0)
        pandemicOverlay:SetPoint("BOTTOMRIGHT", icon, "BOTTOMLEFT",0,0)

        pandemicOverlay:SetTexture("Interface\\AddOns\\NugRunning\\border_rounded")
        pandemicOverlay:SetTexCoord(0, 0.08, 0, 1)
        pandemicOverlay:Show()
        bar.NRPandemic = pandemicOverlay
        -- pandemicOverlay:SetPoint("BOTTOMLEFT", bar, "BOTTOMLEFT", 0, 0)
        -- pandemicOverlay:SetPoint("BOTTOMRIGHT", barTex, "BOTTOMRIGHT", 0, 0)
    else
        if bar.NRPandemic then bar.NRPandemic:Hide() end
    end



    UpdateFrameBorder(bar, self.db.borderType)
    -- UpdateFrameBorder(bar, "2PX")



    local iconTexture, maskTexture, overlayTex = icon:GetRegions()
    maskTexture:Hide()
    overlayTex:Hide()
    iconTexture:SetTexCoord(0.05, 0.95, 0.05, 0.95)



    local bg2 = bar.BarBG2 or bar:CreateTexture(nil, "BACKGROUND")
    bg2:SetAllPoints(bar)
    -- bg2:SetVertexColor(0.2, 0.2, 0.2)
    local coords = { 0.519, 0.590, 0.001, 0.050 }
    bg2:SetTexCoord(GetRectTexCoords(unpack(coords)))
    bar.BarBG2 = bg2


    local overlay = bar.TextureOverlay or bar:CreateTexture(nil, "OVERLAY")
    overlay:SetAllPoints(bar)
    overlay:SetTexture(texture)
    overlay:SetBlendMode("MOD")
    bar.TextureOverlay = overlay

    -- local mask = bar:CreateMaskTexture(nil, "OVERLAY", nil, 4)
    -- mask:SetAtlas("UI-CooldownManager-PandemicBorderBar-Mask", nil, nil, nil, "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
    -- mask:SetAllPoints(bar)
    -- bar:GetStatusBarTexture():AddMaskTexture(mask)
    -- bar.BarBG2:AddMaskTexture(mask)
    -- bar.Mask = mask
    -- <MaskTexture parentKey="Mask" atlas="UI-CooldownManager-PandemicBorderBar-Mask" vWrapMode="CLAMPTOBLACKADDITIVE" hWrapMode="CLAMPTOBLACKADDITIVE" setAllPoints="true">
    --     <MaskedTextures>
    --         <MaskedTexture childKey="Texture"/>
    --     </MaskedTextures>
    -- </MaskTexture>

    frame.DebuffBorder.Texture:SetAtlas("ui-debuff-border-poison-noicon")
    frame.DebuffBorder.Texture:SetVertexColor(0.5, 0.5, 0.5)
    frame.DebuffBorder.Texture:SetDesaturated(true)
    frame.DebuffBorder.Texture:ClearAllPoints()
    local offset = pixelperfect(2, frame)
    frame.DebuffBorder.Texture:SetPoint("TOPLEFT", -offset, offset)
    frame.DebuffBorder.Texture:SetPoint("BOTTOMRIGHT", offset, -offset)



    -- Never repeat hooks even if forced restyle
    if force then return end

    hooksecurefunc(frame, "RefreshIconBorder", function(self)
        if not self.DebuffBorder then return end
        -- self.DebuffBorder:Hide()
        self.DebuffBorder:Show()
    end)


    --[[
    hooksecurefunc(frame, "RefreshCooldownInfo", function(self)
        local pipTexture = self:GetPipTexture()
        local barFrame = self.Bar
        if pipTexture:IsShown() then -- Bar isn't infinite
            local spellID = frame:GetBaseSpellID()
            local opts = spells[spellID]
            if opts then
                if opts.duration then
                    barFrame:SetMinMaxValues(0, opts.duration)
                end
            end
        end
    end)
    ]]

    hooksecurefunc(frame, "ShowPandemicStateFrame", function(self)
        -- self.DebuffBorder.Texture:SetAtlas("ui-debuff-border-bleed-noicon")
        -- self.DebuffBorder.Texture:SetVertexColor(1,1,1)
        -- self.DebuffBorder.Texture:SetDesaturated(false)

        if simplePandemic and self.Bar.NRPandemic then
            self.Bar.NRPandemic:Show()
            -- self.Bar.Pip:SetVertexColor(1,0.3,0.3)
        end
    end)
    hooksecurefunc(frame, "HidePandemicStateFrame", function(self)
        -- self.DebuffBorder.Texture:SetAtlas("ui-debuff-border-poison-noicon")
        -- self.DebuffBorder.Texture:SetVertexColor(0.5, 0.5, 0.5)
        -- self.DebuffBorder.Texture:SetDesaturated(true)

        if simplePandemic and self.Bar.NRPandemic then
            self.Bar.NRPandemic:Hide()
            -- self.Bar.Pip:SetVertexColor(1,0.8,0.5)
        end
    end)

    --[[
    hooksecurefunc(frame, "SetBarContent", function(self, barContent)
        local iconFrame = self:GetIconFrame();

        if barContent == Enum.CooldownViewerBarContent.IconAndName then
            self:GetBarFrame():SetPoint("LEFT", iconFrame, "RIGHT", 1, 0);
        elseif barContent == Enum.CooldownViewerBarContent.IconOnly then
            self:GetBarFrame():SetPoint("LEFT", iconFrame, "RIGHT", 1, 0);
        -- elseif barContent == Enum.CooldownViewerBarContent.NameOnly then
            -- self:GetBarFrame():SetPoint("LEFT", iconFrame, "LEFT", 0, 0);
        end
    end)]]


    hooksecurefunc(icon.Icon, "SetTexture", function(self, textureID)
        local frame = self:GetParent():GetParent()

        if NugRunning.debug then
        -- print("ID", spellID, issecretvalue(spellID), frame.Bar.Name:GetText())
        -- print("frame.spellID", frame.spellID, issecretvalue(frame.spellID))
        -- print("frame.auraSpellID", frame.auraSpellID, issecretvalue(frame.auraSpellID)) -- This becomes secret value
        -- print("frame.cooldownID", frame.cooldownID, issecretvalue(frame.cooldownID))
        -- print("frame:GetSpellID()", frame:GetSpellID(), issecretvalue(frame:GetSpellID()), frame.Bar.Name:GetText())
            print("frame:GetBaseSpellID()", frame:GetBaseSpellID(), issecretvalue(frame:GetBaseSpellID()), C_Spell.GetSpellName(frame:GetBaseSpellID()))
        -- print("SetTexture", textureID, issecretvalue(textureID))
        end

        if ChangeToCustomBarColor(frame) then return end

        frame.Bar.BarBG2:SetVertexColor(1,1,1,1)
        frame.Bar.Pip:SetVertexColor(1,0.8,0.5)
        frame.Bar.BarBG2:SetTexture(textureID)
    end)

    hooksecurefunc(icon.Icon, "SetAtlas", function(self, assetID)
        local frame = self:GetParent():GetParent()

        if ChangeToCustomBarColor(frame) then return end

        frame.Bar.BarBG2:SetVertexColor(1,1,1,1)
        frame.Bar.Pip:SetVertexColor(1,0.8,0.5)
        frame.Bar.BarBG2:SetAtlas(assetID)
    end)
end





--[[
local function UpdateIconFrameBorder(self, borderType)
    local border = self.Border or self:CreateTexture(nil, "BACKGROUND")
    self.Border = border
    if borderType == "2PX" then
        border:SetDrawLayer("BACKGROUND", -2)
        local offset = pixelperfect(2, self)
        border:SetTexture("Interface\\BUTTONS\\WHITE8X8")
        border:SetTextureSliceMargins(0,0,0,0)
        border:SetVertexColor(0,0,0, 0.5)
        border:SetPoint("TOPLEFT", -offset, offset)
        border:SetPoint("BOTTOMRIGHT", offset, -offset)

    elseif borderType == "1PX" then
        border:SetDrawLayer("BACKGROUND", -2)
        local offset = pixelperfect(1, self)
        border:SetTexture("Interface\\BUTTONS\\WHITE8X8")
        border:SetTextureSliceMargins(0,0,0,0)
        border:SetVertexColor(0,0,0, 1)
        border:SetPoint("TOPLEFT", -offset, offset)
        border:SetPoint("BOTTOMRIGHT", offset, -offset)

    elseif borderType == "ROUNDED" then
        border:SetDrawLayer("OVERLAY", 3)
        local offset = pixelperfect(1, self)
        border:SetTexture("Interface\\AddOns\\NugRunning\\border_rounded")
        border:SetVertexColor(0,0,0, 1)
        border:SetTextureSliceMargins(5,5,5,5)
        border:SetPoint("TOPLEFT", -offset, offset)
        border:SetPoint("BOTTOMRIGHT", offset, -offset)

    elseif borderType == "STATUSBAR" then
        border:SetDrawLayer("OVERLAY", 3)
        local offset = pixelperfect(3, self)
        border:SetTexture("Interface\\AddOns\\NugRunning\\border_statusbar_slicing")
        border:SetVertexColor(1,1,1, 1)
        border:SetTextureSliceMargins(5,5,5,5)
        border:SetPoint("TOPLEFT", -offset, offset)
        border:SetPoint("BOTTOMRIGHT", offset, -offset)

    elseif borderType == "STATUSBARDARK" then
        border:SetDrawLayer("OVERLAY", 3)
        local offset = pixelperfect(3, self)
        border:SetTexture("Interface\\AddOns\\NugRunning\\border_statusbar_slicing")
        border:SetVertexColor(0.7,0.7,0.7, 1)
        border:SetTextureSliceMargins(5,5,5,5)
        border:SetPoint("TOPLEFT", -offset, offset)
        border:SetPoint("BOTTOMRIGHT", offset, -offset)
    end
end
]]

-- local countdownFont = CreateFont("NugRunningCVCountdownFont")
-- countdownFont:SetFont(LSM:Fetch("font", "Skurri"), 30, "OUTLINE")


function NugRunning:StyleCooldownItemFrame(frame, force)
    if CVCooldownFrames[frame] and not force then return end
    -- if frame.isNugRunningStyled and not force then return end
    CVCooldownFrames[frame] = true
    frame.isNugRunningStyled = true

    -- /dump EssentialCooldownViewer.itemFramePool:EnumerateActive()()

    local white = "Interface\\BUTTONS\\WHITE8X8"


    local iconTexture, maskTexture, overlayTex = frame:GetRegions()
    maskTexture:Hide()
    overlayTex:Hide()

    iconTexture:SetTexCoord(0.05, 0.95, 0.05, 0.95)

    -- Standard Cooldown Frame
    -- https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_FrameXMLUtil/Mainline/Cooldown.xml


    -- Need a separate frame for border to put it above cooldown frame on the framelevel
    local borderFrame = frame.Border or CreateFrame("Frame", nil, frame)
    borderFrame:SetAllPoints(frame)
    borderFrame:SetFrameLevel(6)
    frame.Border = borderFrame
    UpdateFrameBorder(borderFrame, "STATUSBAR")

    local cooldown = frame.Cooldown
    cooldown:SetUseCircularEdge(false)
    cooldown:SetSwipeTexture("", 0,0,0, 0.64) -- default cooldown values
    cooldown:SetEdgeTexture("Interface\\AddOns\\NugRunning\\ActiveEdge")
    -- cooldown:SetEdgeTexture("Interface\\Cooldown\\edge")
    -- cooldown:SetEdgeTexture("")
    -- cooldown:SetCountdownFont("NugRunningCVCountdownFont")
    -- cooldown:SetHideCountdownNumbers(true)

    -- cooldown:SetDrawBling(true)


    -- local bar = frame.Bar or CreateFrame("StatusBar", nil, frame)
    -- bar:SetStatusBarTexture(white)
    -- bar:SetStatusBarColor(1,1,1,0.3)
    -- frame.Bar = bar

    local activeAuraOverlay = frame.activeAuraOverlay or frame:CreateTexture(nil, "OVERLAY", nil, 4)
    activeAuraOverlay:SetTexture("Interface\\AddOns\\NugRunning\\AuraHighlight.tga")
    activeAuraOverlay:SetBlendMode("ADD")
    activeAuraOverlay:SetVertexColor(0,1,0)
    activeAuraOverlay:SetAlpha(0.25)
    -- activeAuraOverlay:SetAlpha(0)
    activeAuraOverlay:SetAllPoints(frame)
    frame.activeAuraOverlay = activeAuraOverlay

    local activeAuraOverlayBorder = frame.activeAuraOverlayBorder or frame:CreateTexture(nil, "OVERLAY", nil, 4)
    activeAuraOverlayBorder:SetTexture("Interface\\AddOns\\NugRunning\\ThinBorder")
    -- activeAuraOverlayBorder:SetBlendMode("ADD")
    activeAuraOverlayBorder:SetVertexColor(0,1,0)
    activeAuraOverlayBorder:SetAlpha(1)
    activeAuraOverlayBorder:SetTextureSliceMargins(5,5,5,5)

    -- activeAuraOverlayBorder:SetAllPoints(frame)
    local offset = pixelperfect(4, frame)
    activeAuraOverlayBorder:SetPoint("TOPLEFT", frame, "TOPLEFT", -offset, offset);
    activeAuraOverlayBorder:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", offset, -offset);
    frame.activeAuraOverlayBorder = activeAuraOverlayBorder


    -- Never repeat hooks even if forced restyle
    if force then return end

    -- hooksecurefunc(frame, "RefreshIconBorder", function(self)
    -- end)


    -- https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_CooldownViewer/CooldownViewer.lua#L1412


    hooksecurefunc(frame.Cooldown, "SetCooldown", function(self)
        self.isActive = true
    end)
    hooksecurefunc(frame.Cooldown, "Clear", function(self)
        self.isActive = false
    end)

    local viewer = frame:GetParent()
    if viewer == BuffIconCooldownViewer then
        hooksecurefunc(frame, "RefreshCooldownInfo", function(self)
            local cooldownFrame = self:GetCooldownFrame();

            local spellID = self:GetBaseSpellID()
            local spellName = C_Spell.GetSpellName(spellID)

            local expirationTime, duration, timeMod, paused = self:GetCooldownValues();
            -- print(expirationTime, duration, timeMod, paused, spellID, spellName)
        end)
    else
        -- CooldownViewerCooldownItemMixin:CheckCacheCooldownValuesFromAura(timeNow)
        -- https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_CooldownViewer/CooldownViewer.lua#L854
        hooksecurefunc(frame, "RefreshSpellCooldownInfo", function(self)
            local cooldownFrame = self:GetCooldownFrame();

            local spellID = self:GetBaseSpellID()
            local spellName = C_Spell.GetSpellName(spellID)

            -- cooldownFrame:Hide()

            local isActive = cooldownFrame.isActive -- Which we get from cooldown frame hooks

            self.activeAuraOverlay:Hide()
            self.activeAuraOverlayBorder:Hide()

            local bar = self.Bar
            if isActive then
                local isAuraOrTotem = self.cooldownSwipeColor == CooldownViewerConstants.ITEM_AURA_COLOR

                local r,g,b,a = self.cooldownSwipeColor.r, self.cooldownSwipeColor.g, self.cooldownSwipeColor.b, self.cooldownSwipeColor.a
                if isAuraOrTotem then
                    r,g,b = 0,1,0
                    if self.pandemicActive then
                        r,b,b = 1,0,0
                    end
                    cooldownFrame:SetDrawEdge(true);
                    cooldownFrame:SetEdgeColor(r,g,b, 1)
                    cooldownFrame:SetSwipeColor(0,0,0, 0.8);
                    self.activeAuraOverlayBorder:SetVertexColor(r,g,b)
                    cooldownFrame:SetReverse(true)
                    cooldownFrame:SetUseCircularEdge(false)
                    self.activeAuraOverlay:Show()
                    self.activeAuraOverlayBorder:Show()
                else
                    cooldownFrame:SetDrawEdge(false);
                    cooldownFrame:SetReverse(false)
                end

                -- print("cooldownSwipeColor", issecretvalue(self.cooldownSwipeColor), issecretvalue(self.cooldownSwipeColor.r))
                -- cooldownFrame:SetDrawSwipe(self.cooldownShowSwipe);
                -- cooldownFrame:SetUseAuraDisplayTime(self.cooldownUseAuraDisplayTime);
                -- bar:SetStatusBarColor(r,g,b,a)
                -- CooldownFrame_Set(cooldownFrame, self.cooldownStartTime, self.cooldownDuration, self.cooldownEnabled, self.cooldownShowDrawEdge, self.cooldownModRate);
            --     local durationObj = C_DurationUtil.CreateDuration()
            --     durationObj:SetTimeFromStart(self.cooldownStartTime, self.cooldownDuration, self.cooldownModRate)
            --     bar:SetTimerDuration(durationObj)
            --     bar:Show()
            -- else
            --     bar:Hide()
            end
        end)
    end



    -- hooksecurefunc(frame, "ShowPandemicStateFrame", function(self)
    --     self.pandemicActive = true
    --     self.activeAuraOverlay:Show()
    --     self.activeAuraOverlayBorder:Show()
    --     self.activeAuraOverlay:SetVertexColor(1,0,0)
    --     self.activeAuraOverlayBorder:SetVertexColor(1,0,0)
    --     self.Cooldown:SetEdgeColor(1,0,0, 1)
    -- end)
    -- hooksecurefunc(frame, "HidePandemicStateFrame", function(self)
    --     self.pandemicActive = false
    --     local isAuraOrTotem = self.cooldownSwipeColor == CooldownViewerConstants.ITEM_AURA_COLOR
    --     if isAuraOrTotem then
    --         self.activeAuraOverlay:SetVertexColor(0,1,0)
    --         self.activeAuraOverlayBorder:SetVertexColor(0,1,0)
    --         self.Cooldown:SetEdgeColor(0,1,0, 1)
    --     else
    --         self.activeAuraOverlay:Hide()
    --         self.activeAuraOverlayBorder:Hide()
    --     end
    -- end)

    --[[
    hooksecurefunc(frame, "SetBarContent", function(self, barContent)
        local iconFrame = self:GetIconFrame();

        if barContent == Enum.CooldownViewerBarContent.IconAndName then
            self:GetBarFrame():SetPoint("LEFT", iconFrame, "RIGHT", 1, 0);
        elseif barContent == Enum.CooldownViewerBarContent.IconOnly then
            self:GetBarFrame():SetPoint("LEFT", iconFrame, "RIGHT", 1, 0);
        -- elseif barContent == Enum.CooldownViewerBarContent.NameOnly then
            -- self:GetBarFrame():SetPoint("LEFT", iconFrame, "LEFT", 0, 0);
        end
    end)]]


    -- hooksecurefunc(icon.Icon, "SetTexture", function(self, textureID)
    -- end)

    -- hooksecurefunc(icon.Icon, "SetAtlas", function(self, assetID)
    -- end)
end





function NugRunning:InstallCooldownHooks(viewer)
    if viewer then
        -- print("Installing hooks on", viewer:GetName())
        hooksecurefunc(viewer, "OnAcquireItemFrame", function(self, itemFrame)
            -- print(string.format("|cff00ffff%s|r", "DIRECT OnAcquireItemFrame"))
            NugRunning:StyleCooldownItemFrame(itemFrame)
        end)

        for itemFrame in viewer.itemFramePool:EnumerateActive() do
            -- print(string.format("|cff00ffff%s|r", "Styling"), itemFrame)
            NugRunning:StyleCooldownItemFrame(itemFrame)
        end


        -- Reanchor Vanilla Pandemic Frame (they come from a separate frame pool)
        -- https://github.com/Gethe/wow-ui-source/blob/live/Interface/AddOns/Blizzard_CooldownViewer/CooldownViewer.lua#L2130
        hooksecurefunc(viewer, "AnchorPandemicStateFrame", function(self, pandemicFrame, itemFrame)
            pandemicFrame.FX:Hide()
            -- pandemicFrame.Border:Hide()
            pandemicFrame.Border.Border:SetTexture("Interface\\AddOns\\NugRunning\\ThinBorder")
            pandemicFrame.Border.Border:SetVertexColor(1,0,0)

            local offset = pixelperfect(3, itemFrame)
            pandemicFrame:SetPoint("TOPLEFT", itemFrame, "TOPLEFT", -offset, offset);
            pandemicFrame:SetPoint("BOTTOMRIGHT", itemFrame, "BOTTOMRIGHT", offset, -offset);
            pandemicFrame:SetFrameLevel(9);
        end)
        -- hooksecurefunc(viewer, "HidePandemicStateFrame", function(self, itemFrame)
        --     print(itemFrame, "HidePandemicStateFrame")
        -- end)
        -- hooksecurefunc(viewer, "SetupPandemicStateFrameForItem", function(self, itemFrame)
        --     print(itemFrame, "SetupPandemicStateFrameForItem")
        -- end)
        hookedViewers[viewer] = true
    end
end

















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

NugRunning.Commands = {
    ["gui"] = function(v)
        LoadAddOn('NugRunningOptions')
        if _G.NugRunningOptions.categoryID and not InCombatLockdown() then
            Settings.OpenToCategory(_G.NugRunningOptions.categoryID)
        end
    end,

    ["listauras"] = function(v)
        local unit = v
        local h = false
        for i=1, 100 do
            local aura = C_UnitAuras.GetAuraDataByIndex(unit, i, "HELPFUL")
            if not aura then break end
            if not h then print("BUFFS:"); h = true; end
            print(string.format("    %s (id: %d) Duration: %s", aura.name, aura.spellId, aura.duration or "none" ))
        end
        h = false
        for i=1, 100 do
            local aura = C_UnitAuras.GetAuraDataByIndex(unit, i, "HARMFUL")
            if not aura then break end
            if not h then print("DEBUFFS:"); h = true; end
            print(string.format("    %s (id: %d) Duration: %s", aura.name, aura.spellId, aura.duration or "none" ))
        end
    end,
    --[[
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
        ]]

    ["set"] = function(v)
        local p = ParseOpts(v)
        NRunDB.width = p["width"] or NRunDB.width
        NRunDB.height = p["height"] or NRunDB.height
    end,
    ["debug"] = function()
        if not NugRunning.debug then
            NugRunning.debug = true
            print("[NugRunning] Enabled CDM Bar spell ID logging")
        else
            NugRunning.debug = false
            print("[NugRunning] Disabled CDM Bar spell ID logging")
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


