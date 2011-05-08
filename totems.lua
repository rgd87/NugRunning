if select(2,UnitClass("player")) ~= "SHAMAN" then return end

NugRunning.InitTotems = function(self)
    
    local active = NugRunning.active
    local free = NugRunning.free
    
    local totems = {}
    totems[1] = { name = "Fire", color = {1,80/255,0} }
    totems[2] = { name = "Earth", color = {74/255, 142/255, 42/255} }
    totems[3] = { name = "Water", color = { 65/255, 110/255, 1 } }
    totems[4] = { name = "Air", color = { 0.6, 0, 1 }}
    
    local UpdateTotem = function( id, opts, name, startTime, duration, icon )
        local timer = opts.timer
        timer:SetTime(startTime,startTime+duration)
        opts.name = name
        timer:SetName(name)
        timer:SetColor(unpack(opts.color))
        timer.icon:SetTexture(icon)
        active[timer] = true
        timer:Show()
    end

    NugRunning.PLAYER_TOTEM_UPDATE = function (self, event) 
        for id, opts in ipairs(totems) do
            local broken_haveTotem, name, startTime, duration, icon = GetTotemInfo(id)
            local haveTotem = (GetTotemTimeLeft(id) > 0)
            if haveTotem then
                UpdateTotem(id, opts, name, startTime, duration, icon)
            else
                active[opts.timer] = nil
                opts.timer:Hide()
            end
        end
        NugRunning:ArrangeTimers()
    end
    
    for id, opts in ipairs(totems) do
        opts.timer = next(free)
        free[opts.timer] = nil
        opts.timer.dontfree = true
        opts.timer.opts = opts
    end
    NugRunning:RegisterEvent("PLAYER_TOTEM_UPDATE")

end