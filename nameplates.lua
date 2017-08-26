local NugRunning = NugRunning
function NugRunning:DoNameplates()

local next = next
local table_remove = table.remove

local makeicon = true
local enableLines = true
local confignp = NugRunningConfig.nameplates
local Nplates
local plates = {}

local oldTargetGUID
local guidmap = {}

local GetNamePlateForUnit = C_NamePlate.GetNamePlateForUnit

NugRunningNameplates = CreateFrame("Frame")
local NugRunningNameplates = NugRunningNameplates

NugRunningNameplates:RegisterEvent("NAME_PLATE_CREATED")
NugRunningNameplates:RegisterEvent("NAME_PLATE_UNIT_ADDED")
NugRunningNameplates:RegisterEvent("NAME_PLATE_UNIT_REMOVED")

local playerNameplate
local activeNameplates = {}

function NugRunningNameplates.NAME_PLATE_CREATED(self, event, frame)
    frame.timers = {}
    frame:GetChildren().BuffFrame:Hide()
end

function NugRunningNameplates.NAME_PLATE_UNIT_ADDED(self, event, unit)
    activeNameplates[unit] = true
    local pGUID = UnitGUID(unit)
    local frame = GetNamePlateForUnit(unit)
    if pGUID == UnitGUID("player") then playerNameplate = frame end
    local guidTimers = NugRunning:GetTimersByDstGUID(pGUID)
    NugRunningNameplates:UpdateNPTimers(frame, guidTimers)
end

function NugRunningNameplates.NAME_PLATE_UNIT_REMOVED(self, event, unit)
    activeNameplates[unit] = nil
    local frame = GetNamePlateForUnit(unit)
    for _, timer in ipairs(frame.timers) do
        timer:Hide()
    end
end

local MiniOnUpdate = function(self, time)
    self._elapsed = self._elapsed + time
    if self._elapsed < 0.02 then return end
    self._elapsed = 0

    local endTime = self.endTime
    local beforeEnd = endTime - GetTime()

    self:SetValue(beforeEnd + self.startTime)
end

function NugRunningNameplates:EnableLines(state)
    enableLines = state
end

local backdrop = {
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        tile = true, tileSize = 0,
        insets = {left = -1, right = -1, top = -1, bottom = -1},
    }

function NugRunningNameplates:CreateNameplateTimer(frame)
    local parented = confignp.parented
    local f = CreateFrame("StatusBar")
    if parented then f:SetParent(frame) end
    f:SetStatusBarTexture([[Interface\AddOns\NugRunning\statusbar]], "OVERLAY")
    local w = confignp.width
    local h = confignp.height
    local xo = confignp.x_offset
    local yo = confignp.y_offset
    f:SetWidth(w)
    f:SetHeight(h)

    if makeicon then
        local icon = f:CreateTexture("ARTWORK")
        -- icon:SetTexCoord(.1, .9, .1, .9)
        -- icon:SetHeight(h); icon:SetWidth(h)
        icon:SetTexCoord(.1, .9, .3, .7)
        icon:SetHeight(h); icon:SetWidth(2*h)
        icon:SetPoint("TOPRIGHT", f, "TOPLEFT",0,0)
        -- backdrop.insets.left = -h -1
        backdrop.insets.left = -(h*2) -1
        f.icon = icon
    end

    f:SetBackdrop(backdrop)
    f:SetBackdropColor(0,0,0,0.7)

    local bg = f:CreateTexture("BACKGROUND", nil, -5)
    bg:SetTexture([[Interface\AddOns\NugRunning\statusbar]])
    bg:SetAllPoints(f)
    f.bg = bg

    f._elapsed = 0
    f:SetScript("OnUpdate", MiniOnUpdate)

    if not next(frame.timers) then
        f:SetPoint("BOTTOM", frame, "TOP", 0+xo,-7+yo)
    else
        local prev = frame.timers[#frame.timers]
        f:SetPoint("BOTTOM", prev, "TOP", 0,1)
    end
    table.insert(frame.timers, f)
    return f
end

function NugRunningNameplates:CreateNameplateLine(frame)
    local line = frame:CreateLine(nil, "ARTWORK")
    line:SetTexture("Interface\\AddOns\\NugRunning\\white")
    line:SetStartPoint("CENTER", frame.UnitFrame.healthBar, 0,0)
    line:SetEndPoint("CENTER", UIParent, 100,200)
    line:SetThickness(0.5)
    line:SetVertexColor(1,0.3,0.3)
    line:Hide()

    frame.nrunLine = line
    return line
end

function NugRunningNameplates:Update(targetTimers, guidTimers, targetSwapping)
    if targetSwapping then
        local tGUID = UnitGUID("target")
        if tGUID then
            guidTimers[tGUID] = targetTimers
        end
    end

    for unit in pairs(activeNameplates) do
        local np = GetNamePlateForUnit(unit)
        if np then
            local guid = UnitGUID(unit)
            local optUnit
            if guid == UnitGUID("target") then optUnit = "target" end
            local nrunTimers = guidTimers[guid]
            self:UpdateNPTimers(np, nrunTimers, optUnit)
        end
    end
end

function NugRunningNameplates:UpdateNPTimers(np, nrunTimers, nameplateUnit)
    if nrunTimers then
        local i = 1
        while i <= #nrunTimers do
            local timer = nrunTimers[i]
            if not timer.opts.nameplates or timer.isGhost then
                table_remove(nrunTimers, i)
            else
                i = i + 1
            end
        end

        local max = math.max(#nrunTimers, #np.timers)
        for i=1, max do
            local npt = np.timers[i]
            local nrunt = nrunTimers[i]
            if not npt then npt = self:CreateNameplateTimer(np) end
            if not nrunt  then
                npt:Hide()
            else
                npt.startTime = nrunt.startTime
                npt.endTime = nrunt.endTime
                npt:SetMinMaxValues(nrunt.bar:GetMinMaxValues())
                local r,g,b = nrunt.bar:GetStatusBarColor()
                npt:SetStatusBarColor(r,g,b)
                npt.bg:SetVertexColor(r*.4,g*.4,b*.4)
                if npt.icon then
                    npt.icon:SetTexture(nrunt.icon:GetTexture())
                end
                npt:Show()
            end

        end

        if np ~= playerNameplate and enableLines then
            local line = np.nrunLine or self:CreateNameplateLine(np)
            local guidFirstTimer = nrunTimers[1]
            -- GUIDFIRST = guidFirstTimer
            line:SetEndPoint("LEFT", guidFirstTimer, 0,0)
            line:Show()
            if nameplateUnit == "target" then
                line:SetThickness(1)
                line:SetVertexColor(1,0,0)
            else
                line:SetThickness(.5)
                line:SetVertexColor(1,.3,.3)
            end
            if not guidFirstTimer then line:Hide() end
        elseif np.nrunLine then
            np.nrunLine:Hide()
        end
    else
        for _, timer in ipairs(np.timers) do
            timer:Hide()
        end
        if np.nrunLine then np.nrunLine:Hide() end
    end
end


NugRunningNameplates:SetScript("OnEvent", function(self, event, ...)
    return self[event](self, event, ...)
end)

-- function NugRunningNameplates:ADDON_LOADED(event, name)
function NugRunningNameplates:PLAYER_ENTERING_WORLD(event)
    if  TidyPlates and TidyPlates.PlateHandler and
        TidyPlates.PlateHandler:HasScript("OnUpdate")
    then
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")

        local FrameSetAlpha = NugRunningNameplates.SetAlpha
        TidyPlates.PlateHandler:HookScript("OnUpdate", function()
            for frame in pairs(plates) do
                for _,timer in ipairs(frame.timers) do
                    FrameSetAlpha(timer, frame.alpha or 1)
                end
            end
        end)
    end
end

NugRunningNameplates:RegisterEvent("PLAYER_ENTERING_WORLD")



end
