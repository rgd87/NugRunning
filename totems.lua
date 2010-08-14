local MAX_TIMERS = NugRunning.MAX_TIMERS
local timers = NugRunning.timers

local totems = {}
totems[1] = { name = "Fire", color = {0.8, 0, 0} }
totems[2] = { name = "Earth", color = { 0.63, 0.8, 0.35 } }
totems[3] = { name = "Water", color = {149/255, 121/255, 214/255}}
totems[4] = { name = "Air", color = {1,1,1}}

function NugRunning.InitTotems( self )

function NugRunning.UpdateTotem( self, totemid, name, startTime, duration, icon )

    local time
    local opts = totems[totemid]
    local dstGUID = UnitGUID("player")
    local spellID = "totem"..totemid
    local srcGUID = dstGUID
--~     if override then time = override end
--~     if not time then return end
    
    local timer
    for i=1,MAX_TIMERS do
        if timers[i].active and  timers[i].spellID == spellID then
            timer = timers[i]
        end
    end
    if not timer then
        for i=1,MAX_TIMERS do
            if not timers[i].active then
                timer = timers[i]
                break
            end
        end
        if not timer then return end
    end
    
    timer.active = true
    timer.srcGUID = srcGUID
    timer.dstGUID = dstGUID
    timer.spellID = spellID
    timer.spellName = spellName
    timer.timerType = "TOTEM"
    local tex = icon
    timer.icon:SetTexture(tex)
    timer.startTime = startTime
    timer.endTime = timer.startTime + duration
    
    timer.refresh_time = opts.refresh_time
    timer.mark:Update()
    
    timer.bar:SetMinMaxValues(timer.startTime,timer.endTime)
--~     timer.spellText:SetText(name)
    timer.spellText:SetText("")
    if opts.textfunc and type(opts.textfunc) == "function" then timer.spellText:SetText(opts.textfunc(spellName,dstName)) end
    
    timer.stacks = 0
    timer.stacktext:Hide()
    
    local color = opts.color
    timer.bar:SetStatusBarColor(color[1],color[2],color[3])
    timer.bar.bg:SetVertexColor(color[1] * 0.5, color[2] * 0.5, color[3] * 0.5)
    
--~     print("==activate==")
--~     print(timer.spellID)
--~     print(timer.spellName)
--~     print(timer.srcGUID)
--~     print(timer.dstGUID)
    
    timer:Show()
    self:ArrangeTimers()
    
end



function NugRunning.DeactivateTotem( self, totemid)
--~     local time
    local opts = totems[totemid]
--~     local dstGUID = UnitGUID("player")
    local spellID = "totem"..totemid
--~     local srcGUID = dstGUID
--~     if override then time = override end
--~     if not time then return end
    
    local timer
    for i=1,MAX_TIMERS do
        if timers[i].active and  timers[i].spellID == spellID then
            timer = timers[i]
        end
    end
    if not timer then return end
    timer.active = false
    timer:Hide()
end


function NugRunning.PLAYER_TOTEM_UPDATE (self, event) 
--~     for totemId=1,4 do
    for totemId, opts in ipairs(totems) do
        local haveTotem, name, startTime, duration, icon = GetTotemInfo(totemId)
        if haveTotem then
            self:UpdateTotem(totemId, name, startTime, duration, icon)
        else
            self:DeactivateTotem(totemId )
        end
    end
end


NugRunning:RegisterEvent("PLAYER_TOTEM_UPDATE")


end