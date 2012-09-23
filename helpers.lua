local _, helpers = ...

NugRunningConfig = {}
NugRunningConfig.anchors = {}
NugRunningConfig.cooldowns = {}
NugRunningConfig.activations = {}
NugRunningConfig.event_timers = {}
NugRunningConfig.totems = {}

helpers.Talent = function (spellID)
    -- local spellName
    -- if type(spellID) == "number" then 
    --     spellName = GetSpellInfo(spellID)
    -- elseif type(spellID) == "string" then
    --     spellName = spellID
    -- end
    return IsSpellKnown(spellID) and 1 or 0
    -- local numTabs = GetNumTalentTabs()
    -- for t=1, numTabs do
    --     local numTalents = GetNumTalents(t)
    --     for i=1, numTalents do
    --         local name, _,_,_, rank = GetTalentInfo(t, i)
    --         if spellName == name then
    --             return rank
    --         end
    --     end
    -- end
    -- return 0
end
helpers.GetCP = function()
    if not NugRunning.cpNow then return GetComboPoints("player") end
    return NugRunning.cpWas > NugRunning.cpNow and NugRunning.cpWas or NugRunning.cpNow
end
helpers.Glyph = function (gSpellID)
    for i = 1, GetNumGlyphSockets() do
        if select(4,GetGlyphSocketInfo(i,GetActiveSpecGroup()) ) == gSpellID then return 1 end
    end
    return 0
end

local function apply_overrides(opts, mods)
    if not opts or not mods then return end
    for k,v in pairs(mods) do
        opts[k] = v
    end
end


helpers.Anchor = function(name, opts)
    NugRunningConfig.anchors[name] = opts
end

helpers.Spell = function(id, opts)
    if opts.singletarget then opts.target = "target" end
    if type(id) == "table" then
        -- opts.idgroup = {}
        for _, i in ipairs(id) do
            if opts and not GetSpellInfo(i) then print(string.format("nrun: misssing spell #%d (%s)",i,opts.name)) return end
            NugRunningConfig[i] = opts
            -- opts.idgroup[i] = true
        end
    else
        if opts and not GetSpellInfo(id) then print(string.format("nrun: misssing spell #%d (%s)",id,opts.name)) return end
        NugRunningConfig[id] = opts
    end
end
helpers.AddSpell = helpers.Spell
helpers.ModSpell = function(id, mods)
    if type(id) == "table" then
        for _, i in ipairs(id) do
            apply_overrides(NugRunningConfig[i], mods)
        end
    else
        apply_overrides(NugRunningConfig[id], mods)
    end
end

helpers.Cooldown = function(id, opts)
    if type(id) == "table" then id = id[1] end
    if opts then 
        opts.localname = GetSpellInfo(id)
        if not opts.localname then print("nrun: misssing spell #"..id) return end
    end
    NugRunningConfig.cooldowns[id] = opts
end
helpers.AddCooldown = helpers.Cooldown
helpers.ModCooldown = function(id, mods)
    if type(id) == "table" then id = id[1] end
    apply_overrides(NugRunningConfig.cooldowns[id], mods)
end

helpers.Activation = function(id, opts)
    if opts then
        opts.localname = GetSpellInfo(id)
        if not opts.localname then print("nrun: misssing spell #"..id) return end
    end
    NugRunningConfig.activations[id] = opts
end
helpers.AddActivation = helpers.Activation
helpers.ModActivation = function(id, mods)
    apply_overrides(NugRunningConfig.activations[id], mods)
end

helpers.EventTimer = function( opts )
    if not opts.event then print(string.format("nrun: missing combat log event (#%s)", opts.spellID)); return end
    if not opts.duration then print(string.format("nrun: duration is required for event timers(#%s)", opts.spellID)); return end
    if not opts.name then opts.name = "" end
    if not NugRunningConfig.event_timers[opts.event] then NugRunningConfig.event_timers[opts.event] = {} end
    table.insert(NugRunningConfig.event_timers[opts.event], opts)
end
helpers.AddEventTimer = helpers.EventTimer

helpers.WipeColors = function()
    local L = { NugRunningConfig, NugRunningConfig.activations, NugRunningConfig.cooldowns }
    for _,T in ipairs(L) do
        print (T)
        for id, opts in pairs(T) do
            opts.color = nil
        end
    end
    for event,T in pairs(NugRunningConfig.event_timers) do
        for _, opts in pairs(T) do
            opts.color = nil
        end
    end
end

helpers.RemoveAll = function()
    NugRunningConfig = {}
    NugRunningConfig.cooldowns = {}
    NugRunningConfig.activations = {}
    NugRunningConfig.event_timers = {}
end