function NugRunning:DoNameplates()

local next = next
local table_remove = table.remove

local makeicon = true
local confignp = NugRunningConfig.nameplates
local Nplates
local plates = {}

local oldTargetGUID
local guidmap = {}

local function OnHide(frame)
    local frame_guid = frame.guid
    if frame_guid then
        guidmap[frame_guid] = nil
        frame.guid = nil
        if frame_guid == oldTargetGUID then
            oldTargetGUID = nil
        end
    end
    for _, timer in ipairs(frame.timers) do
        timer:Hide()
    end
end

local function HookFrames(...)
    for index=1,select("#", ...) do
        local frame = select(index, ...)
        local region = frame:GetRegions()
        local fname = frame:GetName()
        if  not plates[frame] and
            fname and string.find(fname, "NamePlate")
        then
            -- local hp, cb = frame:GetChildren()
            -- local threat, hpborder, overlay, oldname, oldlevel, bossicon, raidicon, elite = frame:GetRegions()
            -- local _, cbborder, cbshield, cbicon = cb:GetRegions()
            
            -- 5.1 format
            local f = frame --nameplateframe
            f.barFrame, f.nameFrame = f:GetChildren()
            -- f.barFrame.threat, f.barFrame.border, f.barFrame.highlight, f.barFrame.level, f.barFrame.boss, f.barFrame.raid, f.barFrame.dragon = f.barFrame:GetRegions()
            f.nameFrame.name = f.nameFrame:GetRegions()
            -- f.barFrame.healthbar, f.barFrame.castbar = f.barFrame:GetChildren()
            -- f.barFrame.healthbar.texture =  f.barFrame.healthbar:GetRegions()
            -- f.barFrame.castbar.texture, f.barFrame.castbar.border, f.barFrame.castbar.shield, f.barFrame.castbar.icon =  f.barFrame.castbar:GetRegions()
            frame.name = f.nameFrame.name
            frame.timers = {}
            -- frame.healthBar = healthBar
            -- frame.castBar = castBar
            plates[frame] = true
            frame:HookScript("OnHide", OnHide)
        end
    end
end

NugRunningNameplates = CreateFrame("Frame")
NugRunningNameplates:SetScript('OnUpdate', function(self, elapsed)
    if(WorldFrame:GetNumChildren() ~= Nplates) then
        Nplates = WorldFrame:GetNumChildren()
        HookFrames(WorldFrame:GetChildren())
    end
    if UnitExists("target") then
        local targetGUID = UnitGUID("target")
        for frame in pairs(plates) do
            if frame:IsShown() then
                if frame:GetAlpha() == 1 and
                    (UnitName("target") == frame.name:GetText()) and
                    targetGUID ~= oldTargetGUID then
                        guidmap[targetGUID] =  frame
                        frame.guid = targetGUID
                        oldTargetGUID = targetGUID
                        local guidTimers = NugRunning:GetTimersByDstGUID(targetGUID)
                        NugRunningNameplates:UpdateNPTimers(frame, guidTimers)
                        return
                        -- frame.name:SetText(targetGUID)
                end
            end
        end
    else
        oldTargetGUID = nil
    end
end)

local MiniOnUpdate = function(self, time)
    self._elapsed = self._elapsed + time
    if self._elapsed < 0.02 then return end
    self._elapsed = 0

    local endTime = self.endTime
    local beforeEnd = endTime - GetTime()

    self:SetValue(beforeEnd + self.startTime)
end

local backdrop = {
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
        tile = true, tileSize = 0,
        insets = {left = -1, right = -1, top = -1, bottom = -1},
    }

function NugRunningNameplates:CreateNameplateTimer(frame)
    local f = CreateFrame("StatusBar", nil, frame)
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

function NugRunningNameplates:Update(targetTimers, guidTimers, targetSwapping)
    if targetSwapping then
        local tGUID = UnitGUID("target")
        if tGUID then
            guidTimers[tGUID] = targetTimers
        end
    end
    for guid, np in pairs(guidmap) do
        local nrunTimers = guidTimers[guid]
        self:UpdateNPTimers(np, nrunTimers)
    end
end

function NugRunningNameplates:UpdateNPTimers(np, nrunTimers)
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
    else
        for _, timer in ipairs(np.timers) do
            timer:Hide()
        end
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