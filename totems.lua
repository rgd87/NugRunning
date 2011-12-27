if select(2,UnitClass("player")) ~= "SHAMAN" then return end

NugRunning.InitTotems = function(self)
    
    local active = NugRunning.active
    local free = NugRunning.free
    
    local totems = NugRunningConfig.totems
    
    local UpdateTotem = function( id, opts, name, startTime, duration, icon )
        local timer = opts.timer
        timer:SetTime(startTime,startTime+duration)
        if not totems.hideNames then
            opts.name = name
            timer:SetName(name)
        else
            timer:SetName(opts.name)
        end
        timer:SetColor(unpack(opts.color))
        timer.icon:SetTexture(icon)
        active[timer] = true
        timer:Show()
    end

    NugRunning.PLAYER_TOTEM_UPDATE = function (self, event) 
        for id, opts in ipairs(totems) do
            local haveTotem, name, startTime, duration, icon = GetTotemInfo(id)
            if haveTotem then
                UpdateTotem(id, opts, name, startTime, duration, icon)
            else
                active[opts.timer] = nil
                opts.timer:Hide()
            end
        end
        NugRunning:ArrangeTimers()
    end
    
    -- reserving timers for totems
    for id, opts in ipairs(totems) do
        opts.timer = next(free)
        free[opts.timer] = nil
        opts.timer.dontfree = true
        opts.timer.opts = opts
    end
    NugRunning:RegisterEvent("PLAYER_TOTEM_UPDATE")

end