local _, helpers = ...

NugRunningConfig = {}
NugRunningConfig.cooldowns = {}
NugRunningConfig.activations = {}
NugRunningConfig.event_timers = {}

helpers.Talent = function (spellID)
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
helpers.GetCP = function()
    if not NugRunning.cpNow then return GetComboPoints("player") end
    return NugRunning.cpWas > NugRunning.cpNow and NugRunning.cpWas or NugRunning.cpNow
end
helpers.Glyph = function (gSpellID)
    for i = 1, GetNumGlyphSockets() do
        if select(4,GetGlyphSocketInfo(i,GetActiveTalentGroup()) ) == gSpellID then return 1 end
    end
    return 0
end

helpers.AddSpell = function(id, opts)
    if type(id) == "table" then
        for _, i in ipairs(id) do
            if not GetSpellInfo(i) then print(string.format("nrun: misssing spell #%d (%s)",i,opts.name)) return end
            NugRunningConfig[i] = opts
        end
    else
        if not GetSpellInfo(id) then print(string.format("nrun: misssing spell #%d (%s)",id,opts.name)) return end
        NugRunningConfig[id] = opts
    end
end
helpers.AddCooldown = function(id, opts)
    if type(id) == "table" then id = id[1] end
    opts.localname = GetSpellInfo(id)
    if not opts.localname then print("nrun: misssing spell #"..id) return end
    NugRunningConfig.cooldowns[id] = opts
end

helpers.AddActivation = function(id, opts)
    opts.localname = GetSpellInfo(id)
    if not opts.localname then print("nrun: misssing spell #"..id) return end
    NugRunningConfig.activations[id] = opts
end

helpers.AddEventTimer = function( opts )
    if not opts.event then print(string.format("nrun: missing combat log event (#%s)", opts.spellID)); return end
    if not opts.duration then print(string.format("nrun: duration is required for event timers(#%s)", opts.spellID)); return end
    if not opts.name then opts.name = "" end
    if not NugRunningConfig.event_timers[opts.event] then NugRunningConfig.event_timers[opts.event] = {} end
    table.insert(NugRunningConfig.event_timers[opts.event], opts)
end