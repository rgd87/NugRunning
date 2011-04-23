local CreateMark = function(self)
        local m = CreateFrame("Frame",nil,self)
        m:SetParent(self)
        m:SetWidth(16)
        m:SetHeight(self:GetHeight()*0.9)
        m:SetFrameLevel(4)
        m:SetAlpha(0.6)
        
        local texture = m:CreateTexture(nil, "OVERLAY")
		texture:SetTexture("Interface\\AddOns\\NugRunning\\mark")
        texture:SetVertexColor(1,1,1,0.3)
        texture:SetAllPoints(m)
        m.texture = texture
        
        
        local spark = m:CreateTexture(nil, "OVERLAY")
		spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
        spark:SetAlpha(0)
        spark:SetWidth(20)
        spark:SetHeight(m:GetWidth()*4)
        spark:SetPoint("CENTER",m)
		spark:SetBlendMode('ADD')
        m.spark = spark
        
        local ag = spark:CreateAnimationGroup()
        local a1 = ag:CreateAnimation("Alpha")
        a1:SetChange(1)
        a1:SetDuration(0.2)
        a1:SetOrder(1)
        local a2 = ag:CreateAnimation("Alpha")
        a2:SetChange(-1)
        a2:SetDuration(0.4)
        a2:SetOrder(2)
        
        m.shine = ag

        return m
end


local TimerMarkUpdate = function(self)
    if self.opts.recast_mark then
        local pos = self.opts.recast_mark / (self.endTime - self.startTime) * self.bar:GetWidth()
        self.mark:SetPoint("CENTER",self.bar,"LEFT",pos,0)
        self.mark:Show()
        self.mark.texture:Show()
    else
        self.mark:Hide()
    end    
end
local TimerOnUpdate = function(self,time)
    self.OnUpdateCounter = (self.OnUpdateCounter or 0) + time
    if self.OnUpdateCounter < 0.05 then return end
    self.OnUpdateCounter = 0

    if self.opts.timeless then
        return 
    end

    local beforeEnd = self.endTime - GetTime()

    if beforeEnd <= 0 then
        if not self.dontfree then
        while next(self.targets) do self.targets[next(self.targets)] = nil end
        NugRunning.free[self] = true
        NugRunning:ArrangeTimers()
        return
        end
    end
    
    if self.opts.glowtime and beforeEnd < self.opts.glowtime then
        if not self.glow:IsPlaying() then self.glow:Play() end
    end

    self.bar:SetValue(beforeEnd + self.startTime)
    self.timeText:SetFormattedText("%.1f",beforeEnd)
    if self.opts.recast_mark and beforeEnd < self.opts.recast_mark and beforeEnd > self.opts.recast_mark-0.1 then
        self.mark.shine:Play()
    end
end
NugRunning.TimerFunc = TimerOnUpdate
local TimerSetTime = function(self,s,e)
    self.startTime = s
    self.endTime = e
    self.bar:SetMinMaxValues(s,e)
    self:MarkUpdate()
end
local TimerMakeTimeless = function(self, flag)
    local prio = flag and self.opts.duration or 300000
    self.bar:SetMinMaxValues(0,100)
    self.bar:SetValue(0)
    self.startTime = GetTime(); self.endTime = self.startTime + prio;
    self.timeText:SetText("")
end
local TimerSetCharge = function(self,val, min, max)
    if min and max then self.bar:SetMinMaxValues(min,max) end
    self.bar:SetValue(val)
end
local StackTextUpdate = function(self,amount)
    if not amount then return end
    if self.opts.stackcolor then
        self:SetColor(unpack(self.opts.stackcolor[amount]))
    end
    self.stacktext:SetText(amount)
    if amount > 1 then self.stacktext:Show()
    else self.stacktext:Hide() end
end
local SpellTextUpdate = function(self)
    if NRunDB.spellTextEnabled then
        if NRunDB.localNames then
            self.spellText:SetText(spellName)
        elseif NRunDB.shortTextEnabled and self.opts.short then
            self.spellText:SetText(self.opts.short)
        else
            self.spellText:SetText(self.opts.name)
        end
    else
        self.spellText:SetText("")
    end
    if self.opts.textfunc and type(self.opts.textfunc) == "function" then self.spellText:SetText(self.opts.textfunc(self)) end
end
local TimerSetColor = function(self,r,g,b)
    self.bar:SetStatusBarColor(r,g,b)
    self.bar.bg:SetVertexColor(r*.5, g*.5, b*.5)
end
local TimerOnSettingsChanged = function (self)
    local width = NRunDB.width
    local height = NRunDB.height
    local fontscale = NRunDB.fontscale
    self:SetWidth(width)
    self:SetHeight(height)
    self.icon:GetParent():SetWidth(height)
    self.icon:GetParent():SetHeight(height)
    self.shine:GetParent():SetWidth(height*1.8)
    self.shine:GetParent():SetHeight(height*1.8)
    self.bar:SetWidth(width-height-1)
    self.bar:SetHeight(height)
    self.timeText:SetFont("Fonts\\FRIZQT__.TTF",height*.4*fontscale)
    self.spellText:SetFont("Fonts\\FRIZQT__.TTF",height*.5*fontscale)
    self.spellText:SetWidth(self.bar:GetWidth()*0.8)
    self.stacktext:SetFont("Fonts\\FRIZQT__.TTF",height*.5*fontscale,"OUTLINE")
end
NugRunning.BarFrame = function(f)
    local width = NRunDB.width
    local height = NRunDB.height
    local fontscale = NRunDB.fontscale
    local backdrop = {
        bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", tile = true, tileSize = 0,
        insets = {left = -2, right = -2, top = -2, bottom = -2},
    }
    
    f.SetColor = TimerSetColor
    f.SetName = SpellTextUpdate
    f.SetCount = StackTextUpdate
    f.SetTime = TimerSetTime
    f.MakeTimeless = TimerMakeTimeless
    f.SetCharge = TimerSetCharge
    f.MarkUpdate = TimerMarkUpdate
    f.OnSettingsChanged = TimerOnSettingsChanged
    
    f:SetWidth(width)
    f:SetHeight(height)
    
    f:SetBackdrop(backdrop)
	f:SetBackdropColor(0, 0, 0, 0.7)
    
    local ic = CreateFrame("Frame",nil,f)
    ic:SetPoint("TOPLEFT",f,"TOPLEFT", 0, 0)
    ic:SetWidth(height)
    ic:SetHeight(height)
    local ict = ic:CreateTexture(nil,"ARTWORK",0)
    ict:SetTexCoord(.07, .93, .07, .93)
    ict:SetAllPoints(ic)
    f.icon = ict
    
    f.stacktext = ic:CreateFontString(nil, "OVERLAY");
    f.stacktext:SetFont("Fonts\\FRIZQT__.TTF",height*.5*fontscale,"OUTLINE")
    f.stacktext:SetJustifyH("RIGHT")
    f.stacktext:SetVertexColor(1,1,1)
    f.stacktext:SetPoint("RIGHT", ic, "RIGHT",1,-5)
    
    f.bar = CreateFrame("StatusBar",nil,f)
    f.bar:SetFrameStrata("MEDIUM")
    f.bar:SetStatusBarTexture("Interface\\AddOns\\NugRunning\\statusbar")
    f.bar:GetStatusBarTexture():SetDrawLayer("ARTWORK")
    f.bar:SetHeight(height)
    f.bar:SetWidth(width - height - 1)
    f.bar:SetPoint("TOPRIGHT",f,"TOPRIGHT",0,0)
    
    f.bar.bg = f.bar:CreateTexture(nil, "BORDER")
	f.bar.bg:SetAllPoints(f.bar)
	f.bar.bg:SetTexture("Interface\\AddOns\\NugRunning\\statusbar")
    
    f.timeText = f.bar:CreateFontString();
    f.timeText:SetFont("Fonts\\FRIZQT__.TTF",height*.4*fontscale)
    f.timeText:SetJustifyH("RIGHT")
    f.timeText:SetVertexColor(1,1,1)
    f.timeText:SetPoint("RIGHT", f.bar, "RIGHT",-6,0)
    
    f.spellText = f.bar:CreateFontString();
    f.spellText:SetFont("Fonts\\FRIZQT__.TTF",height*.5*fontscale)
    f.spellText:SetWidth(f.bar:GetWidth()*0.8)
    f.spellText:SetHeight(height/2+1)
    f.spellText:SetJustifyH("CENTER")
    f.spellText:SetPoint("LEFT", f.bar, "LEFT",6,0)
    f.spellText.SetName = SpellTextUpdate
    
    
    local at = ic:CreateTexture(nil,"OVERLAY")
    at:SetTexture([[Interface\SpellActivationOverlay\IconAlert]])
    at:SetTexCoord(0.00781250,0.50781250,0.27734375,0.52734375)
    --at:SetTexture([[Interface\AchievementFrame\UI-Achievement-IconFrame]])
    --at:SetTexCoord(0,0.5625,0,0.5625)
    at:SetWidth(height*1.8)
    at:SetHeight(height*1.8)
    at:SetPoint("CENTER",f.icon,"CENTER",0,0)
    at:SetAlpha(0)
    
    local sag = at:CreateAnimationGroup()
    local sa1 = sag:CreateAnimation("Alpha")
    sa1:SetChange(1)
    sa1:SetDuration(0.3)
    sa1:SetOrder(1)
    local sa2 = sag:CreateAnimation("Alpha")
    sa2:SetChange(-1)
    sa2:SetDuration(0.5)
    sa2:SetSmoothing("OUT")
    sa2:SetOrder(2)
    
    f.shine = sag
    
    
    local aag = f:CreateAnimationGroup()
    local aa1 = aag:CreateAnimation("Scale")
    aa1:SetOrigin("BOTTOM",0,0)
    aa1:SetScale(1,0.1)
    aa1:SetDuration(0)
    aa1:SetOrder(1)
    local aa2 = aag:CreateAnimation("Scale")
    aa2:SetOrigin("BOTTOM",0,0)
    aa2:SetScale(1,10)
    aa2:SetDuration(0.15)
    aa2:SetOrder(2)
    
    local glow = f:CreateAnimationGroup()
    local ga1 = glow:CreateAnimation("Alpha")
    ga1:SetChange(-0.5)
    ga1:SetDuration(0.25)
    ga1:SetOrder(1)
    glow:SetLooping("BOUNCE")
    f.glow = glow
    
    f.animIn = aag

    f:SetScript("OnUpdate",TimerOnUpdate)    
    
    f.mark = CreateMark(f)
--~     if nobars then
--~         f.bar:SetWidth(0)
--~         f.bar:SetAlpha(0)
--~         f:SetWidth(height)
--~         f.timeText = f:CreateFontString(nil, "OVERLAY");
--~         f.timeText:SetFont("Fonts\\FRIZQT__.TTF",height*.7) --font size here
--~         f.timeText:SetJustifyH("LEFT")
--~         f.timeText:SetVertexColor(1,1,1)
--~         f.timeText:SetPoint("LEFT", f.icon, "RIGHT",6,0)
--~     end
    return f
end