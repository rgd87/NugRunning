NugRunningGUI = CreateFrame("Frame","NugRunningGUI")
local NugRunning = NugRunning
local L = NugRunning.L

-- NugRunningGUI:SetScript("OnEvent", function(self, event, ...)
    -- self[event](self, event, ...)
-- end)
-- NugRunningGUI:RegisterEvent("ADDON_LOADED")

local AceGUI = LibStub("AceGUI-3.0")

local LSM = LibStub("LibSharedMedia-3.0")

local newFeatureIcon = "|TInterface\\OptionsFrame\\UI-OptionsFrame-NewFeatureIcon:0:0:0:-1|t"
local GetSpellInfo = NugRunning.helpers.GetSpellInfo
local GetSpellTexture = NugRunning.helpers.GetSpellTexture

function NugRunningGUI.SlashCmd(msg)
    NugRunningGUI.frame:Show()
end

local sortfunc = function(a,b)
    if a.order == b.order then
        return a.value < b.value
    else
        return a.order < b.order
    end
end

function NugRunningGUI.GenerateCategoryTree(self, isGlobal, category)
    local _,class = UnitClass("player")
    local custom = isGlobal and NugRunningConfigCustom["GLOBAL"] or NugRunningConfigCustom[class]

    local t = {}

    for spellID, opts in pairs(NugRunningConfigMerged[category]) do
        if not NugRunningConfigMerged.spellClones[spellID] or category == "event_timers" then
            if (isGlobal and opts.global) or (not isGlobal and not opts.global) and not opts._hidden then
                -- local name = (opts.name == "" or not opts.name) and (GetSpellInfo(spellID) or "Unknown") or opts.name
                local name = GetSpellInfo(spellID) or opts.name or "Unknown"
                local custom_opts = custom[category] and custom[category][spellID]
                local status
                local order = 5
                if not custom_opts or not next(custom_opts) then
                    status = nil
                elseif custom_opts.disabled then
                    status = "|cffff0000[D] |r"
                    order = 6
                elseif not NugRunningConfig[category][spellID] then
                    status = "|cff33ff33[A] |r"
                    order = 1
                else
                    status = "|cffffaa00[M] |r"
                    order = 2
                end
                local text = status and status..name or name
                local texture = opts.isItem and select(5,GetItemInfoInstant(spellID)) or  GetSpellTexture(spellID)
                table.insert(t, {
                    value = spellID,
                    text = text,
                    icon = texture,
                    order = order,
                })
            end
        end
    end
    table.sort(t, sortfunc)
    return t
end


local SpellForm
local CooldownForm
local NewTimerForm


function NugRunningGUI.CreateNewTimerForm(self)
    local Form = AceGUI:Create("InlineGroup")
    Form:SetFullWidth(true)
    -- Form:SetHeight(0)
    Form:SetLayout("Flow")
    Form.opts = {}
    Form.controls = {}

    Form.ShowNewTimer = function(self, category)
        assert(category)
        local Frame = NugRunningGUI.frame
        local class = self.class

        Frame.rpane:Clear()
        if not SpellForm then
            SpellForm = NugRunningGUI:CreateSpellForm()
        end
        local opts = {}
        if class == "GLOBAL" then opts.global = true end
        NugRunningGUI:FillForm(SpellForm, class, category, nil, opts, true)
        Frame.rpane:AddChild(SpellForm)
    end

    local newspell = AceGUI:Create("Button")
    newspell:SetText(L"New Spell")
    newspell:SetFullWidth(true)
    newspell:SetCallback("OnClick", function(self, event)
        self.parent:ShowNewTimer("spells")
    end)
    Form:AddChild(newspell)
    Form.controls.newspell = newspell

    local newcooldown = AceGUI:Create("Button")
    newcooldown:SetText(L"New Cooldown")
    newcooldown:SetFullWidth(true)
    newcooldown:SetCallback("OnClick", function(self, event)
        self.parent:ShowNewTimer("cooldowns")
    end)
    Form:AddChild(newcooldown)
    Form.controls.newcooldown = newcooldown

    return Form
end

local tooltipOnEnter = function(self, event)
    GameTooltip:SetOwner(self.frame, "ANCHOR_TOPLEFT")
    GameTooltip:SetText(self.tooltipText, nil, nil, nil, nil, 1);
    GameTooltip:Show();
end
local tooltipOnLeave = function(self, event)
    GameTooltip:Hide();
end
local function AddTooltip(widget, tooltipText)
    widget.tooltipText = tooltipText
    widget:SetCallback("OnEnter", tooltipOnEnter)
    widget:SetCallback("OnLeave", tooltipOnLeave)
end

local clean = function(delta, default_opts, property, emptyValue)
    if delta[property] == emptyValue and default_opts[property] == nil then delta[property] = nil end
end

function NugRunningGUI.CreateCommonForm(self)
    local Form = AceGUI:Create("ScrollFrame")
    Form:SetFullWidth(true)
    -- Form:SetHeight(0)
    Form:SetLayout("Flow")
    Form.opts = {}
    Form.controls = {}




    local save = AceGUI:Create("Button")
    save:SetText(L"Save")
    save:SetRelativeWidth(0.5)
    save:SetCallback("OnClick", function(self, event)
        local p = self.parent
        local class = p.class
        local category = p.category
        local spellID = p.id
        local opts = p.opts

        if not spellID then -- make new timer
            spellID = tonumber(self.parent.controls.spellID:GetText())
            if not spellID or not tonumber(spellID) then
                --invalid spell id string
                return
            end

            if category == "itemcooldowns" then
                if not GetItemInfoInstant(spellID) then return end -- item doesn't exist
            else
                if not GetSpellInfo(spellID) then return end -- spell doesn't exist
            end

            if not opts.name then
                if opts.isItem then
                    opts.name = GetItemInfo(spellID) or "Item"
                else
                    opts.name = GetSpellInfo(spellID)
                end
            end

            opts.spellID = nil
        end

        if category == "event_timers" and (opts.event == "" or not opts.event) then
            return
        end

        local default_opts = NugRunningConfig[category][spellID]
        if default_opts then
            clean(opts, default_opts, "short", false)
            -- clean(opts, default_opts, "ghost", false)
            -- clean(opts, default_opts, "preghost", false)
            -- clean(opts, default_opts, "scale", 1)
            clean(opts, default_opts, "nameplates", false)
            clean(opts, default_opts, "group", "default")
            clean(opts, default_opts, "fixedlen", false)
            -- clean(opts, default_opts, "effect", "NONE")
            -- clean(opts, default_opts, "ghosteffect", "NONE")
            clean(opts, default_opts, "clones", false)
            clean(opts, default_opts, "event", false)
        end
        -- PRESAVE = p.opts
        local delta = CopyTable(opts)
        delta.timer = nil -- important, clears runtime data

        -- remove clones of the previous version of the spell
        local oldOriginalSpell = NugRunningConfigMerged[category][spellID]
        if oldOriginalSpell and oldOriginalSpell.clones then
            for i, additionalSpellID in ipairs(oldOriginalSpell.clones) do
                NugRunningConfigMerged[category][additionalSpellID] = nil
                NugRunningConfigMerged.spellClones[additionalSpellID] = nil
            end
        end
        ----------

        if default_opts then
            if delta.clones then NugRunning.RemoveDefaultsPreserve(delta.clones, default_opts.clones) end
            NugRunning.RemoveDefaults(delta, default_opts)
            NugRunningConfigMerged[category][spellID] = CopyTable(default_opts)
            -- if delta.disabled then
                -- NugRunningConfigMerged[category][spellID] = nil
            -- else
            NugRunning.MergeTable(NugRunningConfigMerged[category][spellID], delta, true)
            -- end
        else
            NugRunningConfigMerged[category][spellID] = delta
            delta.isAdded = true
        end

        -- fill up spell clones of the new version
        local originalSpell = NugRunningConfigMerged[category][spellID]
        if originalSpell.clones then
            originalSpell.clones[spellID] = nil -- Removing possible input of original spell ID into clone list
            for i, additionalSpellID in ipairs(originalSpell.clones) do
                NugRunningConfigMerged[category][additionalSpellID] = originalSpell
                NugRunningConfigMerged.spellClones[additionalSpellID] = true
            end
        end
        ----------

        NugRunningConfigCustom[class] = NugRunningConfigCustom[class] or {}
        NugRunningConfigCustom[class][category] = NugRunningConfigCustom[class][category] or {}
        if not next(delta) then delta = nil end
        NugRunningConfigCustom[class][category][spellID] = delta

        NugRunningGUI.frame.tree:UpdateSpellTree()
        NugRunningGUI.frame.tree:SelectByPath(class, category, spellID)
    end)
    Form:AddChild(save)

    local delete = AceGUI:Create("Button")
    delete:SetText(L"Delete")
    save:SetRelativeWidth(0.45)
    delete:SetCallback("OnClick", function(self, event)
        local p = self.parent
        local class = p.class
        local category = p.category
        local spellID = p.id
        -- local opts = p.opts
        if NugRunningConfigCustom[class][category] then
            NugRunningConfigCustom[class][category][spellID] = nil
        end
        NugRunningConfigMerged[category][spellID] = NugRunningConfig[category][spellID]

        NugRunningGUI.frame.tree:UpdateSpellTree()
        NugRunningGUI.frame.tree:SelectByPath(class, category, spellID)
    end)
    Form.controls.delete = delete
    Form:AddChild(delete)

    local spellID = AceGUI:Create("EditBox")
    spellID:SetLabel(L"Spell ID")
    spellID:SetDisabled(true)
    spellID:DisableButton(true)
    spellID:SetRelativeWidth(0.2)
    spellID:SetCallback("OnTextChanged", function(self, event, value)
        local v = tonumber(value)
        if (v and v > 0 and GetSpellInfo(v)) or self.parent.opts.isItem then
            self.parent.opts["spellID"] = v
            self.editbox:SetTextColor(1,1,1)
        else
            self.editbox:SetTextColor(1,0,0)
        end
        if value == "" then self.parent.opts["spellID"] = nil end
    end)
    -- spellID:SetHeight(32)
    -- spellID.alignoffset = 30
    Form.controls.spellID = spellID
    Form:AddChild(spellID)

    local disabled = AceGUI:Create("CheckBox")
    disabled:SetLabel(L"Disabled")
    disabled:SetRelativeWidth(0.4)
    disabled:SetCallback("OnValueChanged", function(self, event, value)
        if value == false then value = nil end
        self.parent.opts["disabled"] = value
    end)
    -- disabled.alignoffset = 10
    -- disabled:SetHeight(36)
    Form.controls.disabled = disabled
    Form:AddChild(disabled)

    local short = AceGUI:Create("EditBox")
    short:SetLabel(L"Short Name")
    short:SetDisabled(true)
    -- short:SetFullWidth(true)
    short:SetRelativeWidth(0.29)
    short:SetCallback("OnEnterPressed", function(self, event, value)
        if value == "" then
            self.parent.opts["short"] = false
        else
            self.parent.opts["short"] = value
        end
    end)
    -- short.alignoffset = 60
    -- short:SetHeight(32)
    Form.controls.short = short
    Form:AddChild(short)
    AddTooltip(short, "Shortened label, overrides full name")

    local name = AceGUI:Create("EditBox")
    name:SetLabel(L"Name")
    -- name:SetFullWidth(true)
    name:SetRelativeWidth(0.7)
    name:SetCallback("OnEnterPressed", function(self, event, value)
        self.parent.opts["name"] = value
    end)
    -- name:SetHeight(32)
    Form.controls.name = name
    Form:AddChild(name)
    AddTooltip(name, "Custom timer label.\nLeave blank to hide.")


    local fixedlen = AceGUI:Create("EditBox")
    fixedlen:SetLabel(L"Fixed Duration")
    fixedlen:SetRelativeWidth(0.2)
    fixedlen:DisableButton(true)
    fixedlen:SetCallback("OnTextChanged", function(self, event, value)
        local v = tonumber(value)
        if v and v > 0 then
            self.parent.opts["fixedlen"] = v
        elseif value == "" then
            self.parent.opts["fixedlen"] = false
            self:SetText("")
        end
    end)
    Form.controls.fixedlen = fixedlen
    Form:AddChild(fixedlen)
    AddTooltip(fixedlen, L"Set static timer max duration to align timer decay speed with other timers")


    --[[
    local scale = AceGUI:Create("Slider")
    scale:SetLabel(L"Scale")
    scale:SetDisabled(true)
    scale:SetSliderValues(0.3, 2, 0.05)
    scale:SetRelativeWidth(1)
    scale:SetCallback("OnValueChanged", function(self, event, value)
        local v = tonumber(value)
        if v and v >= 0.3 and v <= 2 then
            self.parent.opts["scale"] = v
        else
            self.parent.opts["scale"] = 1
            self:SetText(self.parent.opts.scale or "1")
        end
    end)
    Form.controls.scale = scale
    Form:AddChild(scale)
    AddTooltip(scale, L"Vertical timer scale")
    ]]

    local color = AceGUI:Create("ColorPicker")
    color:SetLabel(L"Color")
    color:SetRelativeWidth(1)
    color:SetHasAlpha(false)
    color:SetCallback("OnValueChanged", function(self, event, r,g,b,a)
        self.parent.opts["color"] = {r,g,b}
    end)
    Form.controls.color = color
    Form:AddChild(color)



    --[[
    local ghost = AceGUI:Create("EditBox")
    ghost:SetLabel(L"Ghost")
    ghost:SetDisabled(true)
    ghost:SetRelativeWidth(0.17)
    ghost:DisableButton(true)
    ghost:SetCallback("OnTextChanged", function(self, event, value)
        local v = tonumber(value)
        if v then
            self.parent.opts["ghost"] = v
            if v == 3 then self.parent.opts["ghost"] = true end
        elseif value == "" then
            self.parent.opts["ghost"] = false
            self:SetText("")
        end
    end)
    Form.controls.ghost = ghost
    Form:AddChild(ghost)
    AddTooltip(ghost, L"Timer remains for X seconds after expiring")

    local preghost = AceGUI:Create("CheckBox")
    preghost:SetLabel(L"PreGhost")
    preghost:SetDisabled(true)
    preghost:SetRelativeWidth(0.74)
    preghost:SetCallback("OnValueChanged", function(self, event, value)
        self.parent.opts["preghost"] = value
    end)
    Form.controls.preghost = preghost
    Form:AddChild(preghost)
    AddTooltip(preghost, L"Create empty bar when switching to target without existing timer")
    ]]

    local nameplates = AceGUI:Create("CheckBox")
    nameplates:SetLabel(L"Show on Nameplates".."   (NYI)")
    nameplates:SetDisabled(true)
    nameplates:SetRelativeWidth(1)
    nameplates:SetCallback("OnValueChanged", function(self, event, value)
        self.parent.opts["nameplates"] = value
    end)
    Form.controls.nameplates = nameplates
    Form:AddChild(nameplates)
    AddTooltip(nameplates, L"Mirror timer on nameplates.\nMay need /reload to enable nameplate functionality.")


    local effectsList = {
        ["NONE"] = "<NONE>"
    }
    local effectsOrder = { "NONE" }
    for k,v in pairs(NugRunningConfig.effects) do
        effectsList[k] = k
        table.insert(effectsOrder, k)
    end

    --[[
    local effect = AceGUI:Create("Dropdown")
    effect:SetLabel(L"3D Effect")
    effect:SetDisabled(true)
    effect:SetList(effectsList, effectsOrder)
    effect:SetRelativeWidth(0.34)
    effect:SetCallback("OnValueChanged", function(self, event, value)
        self.parent.opts["effect"] = value
    end)
    Form.controls.effect = effect
    Form:AddChild(effect)
    AddTooltip(effect, L"Show 3D effect near timer")

    local ghosteffect = AceGUI:Create("Dropdown")
    ghosteffect:SetLabel(L"Ghost 3D Effect")
    ghosteffect:SetDisabled(true)
    ghosteffect:SetList(effectsList, effectsOrder)
    ghosteffect:SetRelativeWidth(0.34)
    ghosteffect:SetCallback("OnValueChanged", function(self, event, value)
        self.parent.opts["ghosteffect"] = value
    end)
    Form.controls.ghosteffect = ghosteffect
    Form:AddChild(ghosteffect)
    AddTooltip(ghosteffect, L"Effect during ghost phase")
    ]]


    local clones = AceGUI:Create("EditBox")
    clones:SetLabel(L"Additional Spell IDs")
    clones:SetRelativeWidth(0.9)
    clones:SetCallback("OnEnterPressed", function(self, event, value)
        local cloneList = {}
        for spellID in string.gmatch(value, "%d+") do
            table.insert(cloneList, tonumber(spellID))
        end
        if next(cloneList) then
            self.parent.opts["clones"] = cloneList
        else
            self.parent.opts["clones"] = false
            self:SetText("")
        end
    end)
    Form.controls.clones = clones
    Form:AddChild(clones)
    AddTooltip(clones, L"Spell ID list of clones / spell ranks" )

    -- Frame:AddChild(Form)
    -- Frame.top = Form
    return Form
end

function NugRunningGUI.CreateSpellForm(self)
    local topgroup = NugRunningGUI:CreateCommonForm()

    return topgroup
end

local ReverseLookup = function(self, effect)
    if not effect then return end
    for k,v in pairs(self) do
        if v == effect then
            return k
        end
    end
end
local fillAlpha = function(rgb)
    local r,g,b,a = unpack(rgb)
    a = a or 1
    return r,g,b,a
end

function NugRunningGUI.FillForm(self, Form, class, category, id, opts, isEmptyForm)
    Form.opts = opts
    Form.class = class
    Form.category = category
    Form.id = id

    if category == "itemcooldowns" then
        opts.isItem = true
    end

    local controls = Form.controls
    controls.spellID:SetText(id or "")
    controls.spellID:SetDisabled(not isEmptyForm)
    controls.disabled:SetValue(opts.disabled)
    controls.disabled:SetDisabled(isEmptyForm)

    controls.name:SetText(opts.name or "")
    controls.short:SetText(opts.short)
    -- controls.scale:SetValue(opts.scale or 1)

    --[[
    if opts.ghost then
        local numeric = opts.ghost == true and 3 or opts.ghost
        controls.ghost:SetText(numeric)
    else
        controls.ghost:SetText()
    end
    controls.preghost:SetValue(opts.preghost)
    ]]

    controls.color:SetColor(fillAlpha(opts.color or {0.8, 0.1, 0.7} ))

    controls.nameplates:SetValue(opts.nameplates)

    controls.fixedlen:SetText(opts.fixedlen)

    -- controls.effect:SetValue(opts.effect or "NONE")
    -- controls.ghosteffect:SetValue(opts.ghosteffect or "NONE")

    local clonesText
    if opts.clones then
        clonesText = table.concat(opts.clones, ", ")
    end
    controls.clones:SetText(clonesText)


    if id and not NugRunningConfig[category][id] then
        controls.delete:SetDisabled(false)
        controls.delete:SetText(L"Delete")
    elseif NugRunningConfigCustom[class] and  NugRunningConfigCustom[class][category] and NugRunningConfigCustom[class][category][id] then
        controls.delete:SetDisabled(false)
        controls.delete:SetText(L"Restore")
    else
        controls.delete:SetDisabled(true)
        controls.delete:SetText(L"Restore")
    end


    if category == "spells" then
        -- controls.maxtimers:SetDisabled(false)
        -- controls.singleTarget:SetDisabled(false)
        -- controls.multiTarget:SetDisabled(false)
        -- controls.nameplates:SetDisabled(false)
        -- controls.hide_until:SetDisabled(true)
        controls.clones:SetDisabled(false)
        -- controls.timeless:SetDisabled(false)
        -- controls.charged:SetDisabled(false)
    else
        -- controls.maxtimers:SetDisabled(true)
        -- controls.singleTarget:SetDisabled(true)
        -- controls.multiTarget:SetDisabled(true)
        -- controls.nameplates:SetDisabled(true)
        -- controls.hide_until:SetDisabled(false)
        controls.clones:SetDisabled(true)
        -- controls.timeless:SetDisabled(true)
        -- controls.charged:SetDisabled(true)
    end

    if category == "event_timers" then
        -- controls.event:SetDisabled(false)
        controls.clones:SetDisabled(false)
    else
        -- controls.event:SetDisabled(true)
    end

    if category == "itemcooldowns" then
        controls.spellID:SetLabel(L"Item ID")
    else
        controls.spellID:SetLabel(L"Spell ID")
    end

end



function NugRunningGUI.Create(self, name, parent )
    -- Create a container frame
    -- local Frame = AceGUI:Create("Frame")
    -- Frame:SetTitle("NugRunningGUI")
    -- Frame:SetWidth(500)
    -- Frame:SetHeight(440)
    -- Frame:EnableResize(false)
    -- -- f:SetStatusText("Status Bar")
    -- -- Frame:SetParent(InterfaceOptionsFramePanelContainer)
    -- Frame:SetLayout("Flow")
    -- Frame:Hide()

    local Frame = AceGUI:Create("BlizOptionsGroup")
    Frame:SetName(name, parent)
    Frame:SetTitle(L"NugRunning Spell List")
    Frame:SetLayout("Fill")
    -- Frame:SetHeight(500)
    -- Frame:SetWidth(700)
    -- Frame:Show()



    -- local gr = AceGUI:Create("InlineGroup")
    -- gr:SetLayout("Fill")
    -- -- gr:SetWidth(600)
    -- -- gr:SetHeight(600)
    -- Frame:AddChild(gr)
    --
    -- local setcreate = AceGUI:Create("Button")
    -- setcreate:SetText("Save")
    -- -- setcreate:SetWidth(100)
    -- gr:AddChild(setcreate)
    -- if true then
        -- return Frame
    -- end


    -- local Frame = CreateFrame("Frame", "NugRunningOptions", UIParent) -- InterfaceOptionsFramePanelContainer)
    -- -- Frame:Hide()
    -- Frame.name = "NugRunningOptions"
    -- Frame.children = {}
    -- Frame:SetWidth(400)
    -- Frame:SetHeight(400)
    -- Frame:SetPoint("CENTER", UIParent, "CENTER",0,0)
    -- Frame.AddChild = function(self, child)
    -- 	table.insert(self.children, child)
    -- 	child:SetParent(self)
    -- end
    -- InterfaceOptions_AddCategory(Frame)


    -- local topgroup = AceGUI:Create("InlineGroup")
    -- topgroup:SetFullWidth(true)
    -- -- topgroup:SetHeight(0)
    -- topgroup:SetLayout("Flow")
    -- Frame:AddChild(topgroup)
    -- Frame.top = topgroup
    --
    -- local setname = AceGUI:Create("EditBox")
    -- setname:SetWidth(240)
    -- setname:SetText("NewSet1")F
    -- setname:DisableButton(true)
    -- topgroup:AddChild(setname)
    -- topgroup.label = setname
    --
    -- local setcreate = AceGUI:Create("Button")
    -- setcreate:SetText("Save")
    -- setcreate:SetWidth(100)
    -- setcreate:SetCallback("OnClick", function(self) NugRunningGUI:SaveSet() end)
    -- setcreate:SetCallback("OnEnter", function() Frame:SetStatusText("Create new/overwrite existing set") end)
    -- setcreate:SetCallback("OnLeave", function() Frame:SetStatusText("") end)
    -- topgroup:AddChild(setcreate)
    --
    -- local btn4 = AceGUI:Create("Button")
    -- btn4:SetWidth(100)
    -- btn4:SetText("Delete")
    -- btn4:SetCallback("OnClick", function() NugRunningGUI:DeleteSet() end)
    -- topgroup:AddChild(btn4)
    -- -- Frame.rpane:AddChild(btn4)
    -- -- Frame.rpane.deletebtn = btn4



    local treegroup = AceGUI:Create("TreeGroup") -- "InlineGroup" is also good
    -- treegroup:SetParent(InterfaceOptionsFramePanelContainer)
    -- treegroup.name = "NugRunningOptions"
    -- treegroup:SetFullWidth(true)
    -- treegroup:SetTreeWidth(200, false)
    -- treegroup:SetLayout("Flow")
    treegroup:SetFullHeight(true) -- probably?
    treegroup:SetFullWidth(true) -- probably?
    treegroup:EnableButtonTooltips(false)
    treegroup:SetCallback("OnGroupSelected", function(self, event, group)
        local path = {}
        for match in string.gmatch(group, '([^\001]+)') do
            table.insert(path, match)
        end

        local class, category, spellID = unpack(path)
        if not spellID or not category then
            Frame.rpane:Clear()
            if not NewTimerForm then
                NewTimerForm = NugRunningGUI:CreateNewTimerForm()
            end
            NewTimerForm.class = class
            Frame.rpane:AddChild(NewTimerForm)
            if class == "GLOBAL" then
                NewTimerForm.controls.newcooldown:SetDisabled(true)
            else
                NewTimerForm.controls.newcooldown:SetDisabled(false)
            end

            return
        end

        spellID = tonumber(spellID)
        local opts
        if not NugRunningConfigCustom[class] or not NugRunningConfigCustom[class][category] or not NugRunningConfigCustom[class][category][spellID] then
            opts = {}
        else
            opts = CopyTable(NugRunningConfigCustom[class][category][spellID])
        end
        NugRunning.SetupDefaults(opts, NugRunningConfig[category][spellID])

        -- if category == "spells" then
        Frame.rpane:Clear()
        if not SpellForm then
            SpellForm = NugRunningGUI:CreateSpellForm()
        end
        NugRunningGUI:FillForm(SpellForm, class, category, spellID, opts)
        Frame.rpane:AddChild(SpellForm)

        -- end
    end)

    Frame.rpane = treegroup
    Frame.tree = treegroup

    treegroup.UpdateSpellTree = function(self)
        local lclass, class = UnitClass("player")
        local classIcon = "Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes"
        local classCoords = CLASS_ICON_TCOORDS[class]

        local t = {
            {
                value = "GLOBAL",
                text = L"Global",
                icon = "Interface\\Icons\\spell_holy_resurrection",
                children = {
                    {
                        value = "spells",
                        text = "Spells",
                        icon = "Interface\\Icons\\spell_shadow_manaburn",
                        children = NugRunningGUI:GenerateCategoryTree(true, "spells")
                    },
                    -- {
                    -- 	value = "cooldowns",
                    -- 	text = "Cooldowns",
                    -- 	icon = "Interface\\Icons\\spell_nature_astralrecal",
                    -- 	children = NugRunningGUI:GenerateCategoryTree(true, "cooldowns")
                    -- },
                    -- {
                    -- 	value = "casts",
                    -- 	text = "Casts",
                    -- 	icon = "Interface\\Icons\\spell_deathvortex",
                    -- 	children = NugRunningGUI:GenerateCategoryTree(true, "casts")
                    -- },
                },
            },
            {
                value = class,
                text = lclass,
                icon = classIcon,
                iconCoords = classCoords,
                children = {
                    {
                        value = "spells",
                        text = "Spells",
                        icon = "Interface\\Icons\\spell_shadow_manaburn",
                        children = NugRunningGUI:GenerateCategoryTree(false,"spells")
                    },
                    {
                        value = "cooldowns",
                        text = "Cooldowns",
                        icon = "Interface\\Icons\\spell_nature_astralrecal",
                        children = NugRunningGUI:GenerateCategoryTree(false,"cooldowns")
                    },
                }
            },
        }
        self:SetTree(t)
        return t
    end


    local t = treegroup:UpdateSpellTree()

    Frame:AddChild(treegroup)



    local categories = {"spells", "cooldowns" }
    for i,group in ipairs(t) do -- expand all groups
        if group.value ~= "GLOBAL" then
            treegroup.localstatus.groups[group.value] = true
            for _, cat in ipairs(categories) do
                treegroup.localstatus.groups[group.value.."\001"..cat] = true
            end
        end
    end
    -- TREEG = treegroup


    Frame.rpane.Clear = function(self)
        for i, child in ipairs(self.children) do
            child:SetParent(UIParent)
            child.frame:Hide()
        end
        table.wipe(self.children)
    end



    -- local commonForm = NugRunningGUI:CreateCommonForm()
    -- Frame.rpane:AddChild(commonForm)
    local _, class = UnitClass("player")
    Frame.tree:SelectByPath(class)



    -- Frame:Hide()

    return Frame
end

local function MakeGeneralOptions()
    local iconOpts = {
        type = 'group',
        name = L"NugRunning Icon Settings",
        order = 1,
        args = {
            enableIconStyling = {
                name = L"Style CDM Icons",
                type = "toggle",
                width = 2.5,
                confirm = true,
                confirmText = "Changing this setting requires a UI reload to take effect. Do you want to continue?",
                get = function(info) return NugRunning.db.shouldStyleIcons end,
                set = function(info, v)
                    NugRunning.db.shouldStyleIcons = not NugRunning.db.shouldStyleIcons
                    ReloadUI()
                end,
                order = 0,
            },
            iconSettings = {
                type = "group",
                name = "CDM Icon Settings",
                guiInline = true,
                disabled = function() return not NugRunning.db.shouldStyleIcons end,
                order = 1.8,
                args = {
                    dynamicLayout = {
                        name = L"Dynamic Layout for BuffIcons"..newFeatureIcon,
                        desc = L"Stacks the active elements on top of each other without leaving the gaps for inactive",
                        type = "toggle",
                        width = "full",
                        confirm = true,
                        confirmText = "Warning: Requires UI reloading.",
                        get = function(info) return NugRunning.db.viewerSettings["BuffIconCooldownViewer"].dynamicLayout end,
                        set = function(info, v)
                            NugRunning.db.viewerSettings["BuffIconCooldownViewer"].dynamicLayout = not NugRunning.db.viewerSettings["BuffIconCooldownViewer"].dynamicLayout
                            ReloadUI()
                        end,
                        order = 0,
                    },
                    borderTypeIcon = {
                        type = "select",
                        name = L"Border Type",
                        order = 1,
                        get = function(info) return NugRunning.db.borderTypeIcon end,
                        set = function(info, value)
                            NugRunning.db.borderTypeIcon = value
                            NugRunning:UpdateAllCVCooldownIcons()
                        end,
                        values = {
                            ["NONE"] = "None",
                            ["1PX"] = "1px Border",
                            ["2PX"] = "2px Border",
                            ["ROUNDED"] = "Rounded Border",
                            ["STATUSBAR"] = "StatusBar Border",
                            ["STATUSBARDARK"] = "StatusBar Border (Dark)",
                            ["THINBORDER"] = "Thin Border",
                        },
                    },

                    disableIconDebuffBorder = {
                        name = L"Disable Dispel Type Border",
                        type = "toggle",
                        width = 1.2,
                        get = function(info) return NugRunning.db.disableIconDebuffBorder end,
                        set = function(info, v)
                            NugRunning.db.disableIconDebuffBorder = not NugRunning.db.disableIconDebuffBorder
                            NugRunning:UpdateAllCVCooldownIcons()
                        end,
                        order = 3,
                    },

                    activeAuraColor = {
                        name = L"Active Aura Color",
                        type = 'color',
                        order = 4,
                        width = 0.9,
                        get = function(info)
                            local r,g,b = unpack(NugRunning.db.activeAuraColor)
                            return r,g,b
                        end,
                        set = function(info, r, g, b)
                            NugRunning.db.activeAuraColor = {r,g,b,1}
                        end,
                    },



                    CCFonts = {
                        type = "group",
                        name = L"Countdown Font",
                        guiInline = true,
                        order = 5,
                        args = {
                            cooldownFont = {
                                type = "select",
                                name = L"Font",
                                order = 1,
                                get = function(info) return NugRunning.db.cooldownFont.font end,
                                set = function(info, value)
                                    NugRunning.db.cooldownFont.font = value
                                    NugRunning:UpdateCooldownFontObjects()
                                end,
                                values = LSM:HashTable("font"),
                                dialogControl = "LSM30_Font",
                            },
                            cooldownFontSize = {
                                name = L"Size",
                                width = 0.70,
                                type = "range",
                                get = function(info) return NugRunning.db.cooldownFont.size end,
                                set = function(info, v)
                                    NugRunning.db.cooldownFont.size = v
                                    NugRunning:UpdateCooldownFontObjects()
                                end,
                                min = 3,
                                max = 40,
                                step = 1,
                                order = 2,
                            },
                            cooldownFontAlpha = {
                                name = L"Alpha",
                                width = 0.70,
                                type = "range",
                                get = function(info) return NugRunning.db.cooldownFont.alpha end,
                                set = function(info, v)
                                    NugRunning.db.cooldownFont.alpha = v
                                    NugRunning:UpdateCooldownFontObjects()
                                end,
                                min = 0,
                                max = 1,
                                step = 0.01,
                                order = 3,
                            },
                            cooldownFontOutline = {
                                name = L"Outline",
                                width = 0.5,
                                type = "toggle",
                                get = function(info) return NugRunning.db.cooldownFont.outline end,
                                set = function(info, v)
                                    NugRunning.db.cooldownFont.outline = not NugRunning.db.cooldownFont.outline
                                    NugRunning:UpdateCooldownFontObjects()
                                end,
                                order = 3.1,
                            },
                        },
                    },
                    hideCooldownAbove = {
                        type = "select",
                        name = L"Hide Count Above",
                        order = 6,
                        get = function(info) return NugRunning.db.hideCooldownAbove end,
                        set = function(info, value)
                            NugRunning.db.hideCooldownAbove = value
                            NugRunning:InitializeFormatters()
                            NugRunning:UpdateAllCVCooldownIcons()
                        end,
                        values = {
                            ["SHORT"] = "3s",
                            ["MID"] = "10s",
                            ["LONG"] = "30s",
                            ["FULL"] = "Never Hide",
                        },
                    },

                    iconLayoutSettingsBuffIcons = {
                        type = "group",
                        name = "Static Box Size",
                        desc = L"This fixes the issue with CDM growing in all directions when you add more elements to it",
                        guiInline = true,
                        order = 7.3,
                        args = {
                            staticSize1 = {
                                name = L"EssentialCooldownViewer",
                                desc = L"This fixes the issue with CDM growing in all directions when you add more elements to it",
                                type = "toggle",
                                width = 3,
                                get = function(info) return NugRunning.db.viewerSettings["EssentialCooldownViewer"].staticSize end,
                                set = function(info, v)
                                    NugRunning.db.viewerSettings["EssentialCooldownViewer"].staticSize = not NugRunning.db.viewerSettings["EssentialCooldownViewer"].staticSize
                                    NugRunning:ToggleCDM()
                                end,
                                order = 7.1,
                            },
                            staticSize2 = {
                                name = L"UtilityCooldownViewer",
                                desc = L"This fixes the issue with CDM growing in all directions when you add more elements to it",
                                type = "toggle",
                                width = 3,
                                get = function(info) return NugRunning.db.viewerSettings["UtilityCooldownViewer"].staticSize end,
                                set = function(info, v)
                                    NugRunning.db.viewerSettings["UtilityCooldownViewer"].staticSize = not NugRunning.db.viewerSettings["UtilityCooldownViewer"].staticSize
                                    NugRunning:ToggleCDM()
                                end,
                                order = 7.2,
                            },
                            staticSize3 = {
                                name = L"BuffIconCooldownViewer",
                                desc = L"This fixes the issue with CDM growing in all directions when you add more elements to it",
                                type = "toggle",
                                width = 3,
                                get = function(info) return NugRunning.db.viewerSettings["BuffIconCooldownViewer"].staticSize end,
                                set = function(info, v)
                                    NugRunning.db.viewerSettings["BuffIconCooldownViewer"].staticSize = not NugRunning.db.viewerSettings["BuffIconCooldownViewer"].staticSize
                                    NugRunning:ToggleCDM()
                                end,
                                order = 7.3,
                            },
                        },
                    },
                },
            },
        }
    }
    local barOpts = {
        type = 'group',
        name = L"NugRunning Bar Settings",
        order = 1,
        args = {
            enableBarStyling = {
                name = L"Style CDM Bars",
                type = "toggle",
                width = 2.5,
                confirm = true,
                confirmText = "Changing this setting requires a UI reload to take effect. Do you want to continue?",
                get = function(info) return NugRunning.db.shouldStyleBars end,
                set = function(info, v)
                    NugRunning.db.shouldStyleBars = not NugRunning.db.shouldStyleBars
                    ReloadUI()
                end,
                order = 2,
            },
            barLayoutSettings = {
                type = "group",
                name = "CDM Bar Layout Tweaks",
                guiInline = true,
                order = 2.1,
                args = {
                    dynamicLayout = {
                        name = L"Dynamic Layout"..newFeatureIcon,
                        desc = L"Stacks the active elements on top of each other without leaving the gaps for inactive",
                        type = "toggle",
                        width = "full",
                        confirm = true,
                        confirmText = "Warning: Requires UI reloading.",
                        get = function(info) return NugRunning.db.viewerSettings["BuffBarCooldownViewer"].dynamicLayout end,
                        set = function(info, v)
                            NugRunning.db.viewerSettings["BuffBarCooldownViewer"].dynamicLayout = not NugRunning.db.viewerSettings["BuffBarCooldownViewer"].dynamicLayout
                            ReloadUI()
                        end,
                        order = 1,
                    },
                    staticSize = {
                        name = L"Static Box Size",
                        desc = L"This fixes the issue with CDM growing in all directions when you add more elements to it",
                        type = "toggle",
                        width = 1,
                        get = function(info) return NugRunning.db.viewerSettings["BuffBarCooldownViewer"].staticSize end,
                        set = function(info, v)
                            NugRunning.db.viewerSettings["BuffBarCooldownViewer"].staticSize = not NugRunning.db.viewerSettings["BuffBarCooldownViewer"].staticSize
                            NugRunning:ToggleCDM()
                        end,
                        order = 1.8,
                    },
                    growthDirection = {
                        type = "select",
                        name = L"Growth Direction",
                        order = 3,
                        desc = "Set the statusbar texture.",
                        get = function(info)
                            return NugRunning.db.viewerSettings["BuffBarCooldownViewer"].growthDirection
                        end,
                        set = function(info, value)
                            NugRunning.db.viewerSettings["BuffBarCooldownViewer"].growthDirection = value
                            NugRunning:ToggleCDM()
                        end,
                        values = {
                            ["UP"] = L"Up",
                            ["DOWN"] = L"Down",
                        },
                    },

                },
            },
            barSettings = {
                type = "group",
                name = "CDM Bar Settings",
                guiInline = true,
                order = 2.2,
                args = {
                    texture = {
                        type = "select",
                        name = L"Texture",
                        order = 0.5,
                        desc = "Set the statusbar texture.",
                        get = function(info) return NugRunning.db.textureName end,
                        set = function(info, value)
                            NugRunning.db.textureName = value
                            NugRunning:UpdateAllCVBuffBars()
                        end,
                        values = LSM:HashTable("statusbar"),
                        dialogControl = "LSM30_Statusbar",
                    },
                    --[[
                    width = {
                        name = L"Width",
                        type = "range",
                        get = function(info) return NugRunning.db.width end,
                        set = function(info, v)
                            NugRunning.db.width = v
                            for i,timer in ipairs(NugRunning.timers) do
                                timer:Resize(NugRunning.db.width, NugRunning.db.height)
                            end
                        end,
                        min = 80,
                        max = 400,
                        step = 1,
                        order = 1,
                    },
                    ]]
                    height = {
                        name = L"Height",
                        type = "range",
                        get = function(info) return NugRunning.db.height end,
                        set = function(info, v)
                            NugRunning.db.height = v
                            NugRunning:UpdateAllCVBuffBars()
                        end,
                        min = 10,
                        max = 30,
                        step = 1,
                        order = 2,
                    },
                    --[[
                    growth = {
                        name = L"Growth Direction",
                        type = 'select',
                        order = 3,
                        values = {
                            up = "Up",
                            down = "Down",
                        },
                        get = function(info) return NugRunning.db.growth end,
                        set = function( info, v )
                            NugRunning.db.growth = v
                            for i,timer in ipairs(NugRunning.timers) do
                                timer:ClearAllPoints()
                            end
                            NugRunning:SetupArrange()
                            NugRunning:ArrangeTimers()
                        end,
                    },
                    ]]
                    borderType = {
                        type = "select",
                        name = L"Border Type",
                        order = 3,
                        get = function(info) return NugRunning.db.borderType end,
                        set = function(info, value)
                            NugRunning.db.borderType = value
                            NugRunning:UpdateAllCVBuffBars()
                        end,
                        values = {
                            ["1PX"] = "1px Border",
                            ["2PX"] = "2px Border",
                            ["ROUNDED"] = "Rounded Border",
                            ["STATUSBAR"] = "StatusBar Border",
                            ["STATUSBARDARK"] = "StatusBar Border (Dark)",
                        },
                    },
                    simplePandemic = {
                        name = L"Simple Pandemic Display",
                        type = "toggle",
                        width = 2.5,
                        desc = L"Shows an indicator on the side instead of glowing the whole bar",
                        get = function(info) return NugRunning.db.simplePandemic end,
                        set = function(info, v)
                            NugRunning.db.simplePandemic = not NugRunning.db.simplePandemic
                            NugRunning:UpdateAllCVBuffBars()
                        end,
                        order = 4,
                    },
                    activeAuraColor = {
                        name = L"Default Bar Color",
                        type = 'color',
                        order = 6,
                        width = 3,
                        get = function(info)
                            local r,g,b = unpack(NugRunning.db.defaultBarColor)
                            return r,g,b
                        end,
                        set = function(info, r, g, b)
                            NugRunning.db.defaultBarColor = {r,g,b,1}
                        end,
                    },
                    enableFixedDurations = {
                        name = L"Enable Fixed Durations",
                        type = "toggle",
                        width = 2.5,
                        desc = L"Allows to set a static max duration on a timer for a spell. And if that's the same duration across several timers they will all have the same decay speed",
                        confirm = true,
                        confirmText = "Warning: Requires UI reloading.",
                        get = function(info) return NugRunning.db.enableFixedDurations end,
                        set = function(info, v)
                            NugRunning.db.enableFixedDurations = not NugRunning.db.enableFixedDurations
                            ReloadUI()
                        end,
                        order = 5,
                    },
                },
            },
            --[[
            nameplate_sizeSettings = {
                type = "group",
                name = L"Nameplate Bars",
                guiInline = true,
                order = 3,
                args = {
                    texture = {
                        type = "select",
                        name = L"Texture",
                        order = 0.5,
                        desc = "Set the statusbar texture.",
                        get = function(info) return NugRunning.db.nptextureName end,
                        set = function(info, value)
                            NugRunning.db.nptextureName = value
                            NugRunning:UpdateAllNameplateTextures()
                        end,
                        values = LSM:HashTable("statusbar"),
                        dialogControl = "LSM30_Statusbar",
                    },
                    width = {
                        name = L"Nameplate Width",
                        type = "range",
                        get = function(info) return NugRunning.db.np_width end,
                        set = function(info, v)
                            NugRunning.db.np_width = v
                            if NugRunningNameplates then NugRunningNameplates:Resize() end
                        end,
                        min = 50,
                        max = 200,
                        step = 1,
                        order = 1,
                    },
                    height = {
                        name = L"Nameplate Height",
                        type = "range",
                        get = function(info) return NugRunning.db.np_height end,
                        set = function(info, v)
                            NugRunning.db.np_height = v
                            if NugRunningNameplates then NugRunningNameplates:Resize() end
                        end,
                        min = 3,
                        max = 50,
                        step = 1,
                        order = 2,
                    },
                    xoffset = {
                        name = L"Nameplate X Offset",
                        type = "range",
                        get = function(info) return NugRunning.db.np_xoffset end,
                        set = function(info, v)
                            NugRunning.db.np_xoffset = v
                            if NugRunningNameplates then NugRunningNameplates:Resize() end
                        end,
                        min = -100,
                        max = 100,
                        step = 1,
                        order = 3,
                    },
                    yoffset = {
                        name = L"Nameplate Y Offset",
                        type = "range",
                        get = function(info) return NugRunning.db.np_yoffset end,
                        set = function(info, v)
                            NugRunning.db.np_yoffset = v
                            if NugRunningNameplates then NugRunningNameplates:Resize() end
                        end,
                        min = -100,
                        max = 100,
                        step = 1,
                        order = 3,
                    },
                },
            },
            ]]
            fonts = {
                type = "group",
                name = L"Bar Fonts",
                guiInline = true,
                order = 6,
                args = {
                    namefont = {
                        type = "select",
                        name = L"Name Font",
                        order = 1,
                        get = function(info) return NugRunning.db.nameFont.font end,
                        set = function(info, value)
                            NugRunning.db.nameFont.font = value
                            NugRunning:UpdateAllCVBuffBars()
                        end,
                        values = LSM:HashTable("font"),
                        dialogControl = "LSM30_Font",
                    },
                    nameSize = {
                        name = L"Name Size",
                        width = 0.70,
                        type = "range",
                        get = function(info) return NugRunning.db.nameFont.size end,
                        set = function(info, v)
                            NugRunning.db.nameFont.size = v
                            NugRunning:UpdateAllCVBuffBars()
                        end,
                        min = 3,
                        max = 40,
                        step = 1,
                        order = 2,
                    },
                    nameAlpha = {
                        name = L"Name Alpha",
                        width = 0.70,
                        type = "range",
                        get = function(info) return NugRunning.db.nameFont.alpha end,
                        set = function(info, v)
                            NugRunning.db.nameFont.alpha = v
                            NugRunning:UpdateAllCVBuffBars()
                        end,
                        min = 0,
                        max = 1,
                        step = 0.01,
                        order = 3,
                    },
                    nameOutline = {
                        name = L"Outline",
                        width = 0.5,
                        type = "toggle",
                        get = function(info) return NugRunning.db.nameFont.outline end,
                        set = function(info, v)
                            NugRunning.db.nameFont.outline = not NugRunning.db.nameFont.outline
                            NugRunning:UpdateAllCVBuffBars()
                        end,
                        order = 3.1,
                    },

                    timefont = {
                        type = "select",
                        name = L"Time Font",
                        order = 4,
                        get = function(info) return NugRunning.db.timeFont.font end,
                        set = function(info, value)
                            NugRunning.db.timeFont.font = value
                            NugRunning:UpdateAllFonts()
                        end,
                        values = LSM:HashTable("font"),
                        dialogControl = "LSM30_Font",
                    },
                    timeSize = {
                        name = L"Time Size",
                        width = 0.7,
                        type = "range",
                        get = function(info) return NugRunning.db.timeFont.size end,
                        set = function(info, v)
                            NugRunning.db.timeFont.size = v
                            NugRunning:UpdateAllCVBuffBars()
                        end,
                        min = 3,
                        max = 40,
                        step = 1,
                        order = 5,
                    },
                    timeAlpha = {
                        name = L"Time Alpha",
                        width = 0.7,
                        type = "range",
                        get = function(info) return NugRunning.db.timeFont.alpha end,
                        set = function(info, v)
                            NugRunning.db.timeFont.alpha = v
                            NugRunning:UpdateAllCVBuffBars()
                        end,
                        min = 0,
                        max = 1,
                        step = 0.01,
                        order = 6,
                    },
                    timeOutline = {
                        name = L"Outline",
                        width = 0.5,
                        type = "toggle",
                        get = function(info) return NugRunning.db.timeFont.outline end,
                        set = function(info, v)
                            NugRunning.db.timeFont.outline = not NugRunning.db.timeFont.outline
                            NugRunning:UpdateAllCVBuffBars()
                        end,
                        order = 6.1,
                    },

                    stackfont = {
                        type = "select",
                        name = L"Stack Font",
                        order = 7,
                        get = function(info) return NugRunning.db.stackFont.font end,
                        set = function(info, value)
                            NugRunning.db.stackFont.font = value
                            NugRunning:UpdateAllCVBuffBars()
                        end,
                        values = LSM:HashTable("font"),
                        dialogControl = "LSM30_Font",
                    },
                    stackSize = {
                        name = L"Stack Size",
                        type = "range",
                        get = function(info) return NugRunning.db.stackFont.size end,
                        set = function(info, v)
                            NugRunning.db.stackFont.size = v
                            NugRunning:UpdateAllCVBuffBars()
                        end,
                        min = 3,
                        max = 40,
                        step = 1,
                        order = 8,
                    },
                    stackAlpha = {
                        name = L"Stack Alpha",
                        type = "range",
                        get = function(info) return NugRunning.db.stackFont.alpha end,
                        set = function(info, v)
                            NugRunning.db.stackFont.alpha = v
                            NugRunning:UpdateAllCVBuffBars()
                        end,
                        min = 0,
                        max = 1,
                        step = 0.01,
                        order = 9,
                    },
                },
            },
            --[[
            timerOptions = {
                type = "group",
                name = L"Timers",
                guiInline = true,
                order = 1.2,
                args = {

                    spellText = {
                        name = L"Show Spell Names",
                        type = "toggle",
                        desc = L"Display spell name on timers",
                        get = function(info) return NugRunning.db.spellTextEnabled end,
                        set = function(info, v)
                            NugRunning.db.spellTextEnabled = not NugRunning.db.spellTextEnabled
                            NugRunning.db.targetTextEnabled = false
                        end,
                        order = 1,
                    },
                    targetNameText = {
                        name = L"Show Target Names",
                        type = "toggle",
                        get = function(info) return NugRunning.db.targetTextEnabled end,
                        set = function(info, v)
                            NugRunning.db.targetTextEnabled = not NugRunning.db.targetTextEnabled
                            NugRunning.db.spellTextEnabled = false
                        end,
                        order = 1,
                    },
                    localNames = {
                        name = L"Localized Spell Names",
                        type = "toggle",
                        desc = L"Ignore custom names and always show native spell names",
                        get = function(info) return NugRunning.db.localNames end,
                        set = function(info, v) NugRunning.db.localNames = not NugRunning.db.localNames end,
                        order = 2,
                    },
                    misses = {
                        name = L"Misses",
                        type = "toggle",
                        desc = L"Show short notification when spell is resisted/missed",
                        get = function(info) return NugRunning.db.missesEnabled end,
                        set = function(info, v) NugRunning.db.missesEnabled = not NugRunning.db.missesEnabled end,
                        order = 3,
                    },
                    nameplates = {
                        name = L"Nameplate Timers",
                        type = "toggle",
                        desc = L"Mirror flagged spell timers on nameplates",
                        confirm = true,
                        confirmText = "Warning: Requires UI reloading.",
                        get = function(info) return NugRunning.db.nameplates end,
                        set = function(info, v)
                            NugRunning.db.nameplates = not NugRunning.db.nameplates
                            ReloadUI()
                        end,
                        order = 4,
                    },
                    cooldowns = {
                        name = L"Cooldowns",
                        type = "toggle",
                        get = function(info) return NugRunning.db.cooldownsEnabled end,
                        set = function(info, v) NugRunning.Commands.cooldowns() end,
                        order = 6,
                    },
                    swapTargets = {
                        name = L"Fixed Target Group"..newFeatureIcon,
                        type = "toggle",
                        width = "full",
                        desc = L"Switch between target indicator or fixed position",
                        get = function(info) return NugRunning.db.swapTarget end,
                        set = function(info, v)
                            NugRunning.db.swapTarget = not NugRunning.db.swapTarget
                            NugRunning:SetupArrange()
                            NugRunning:ArrangeTimers()
                        end,
                        order = 8,
                    },
                },
            },
            ]]
            debug = {
                name = L"Toggle CDM Bar Spell ID display",
                type = "execute",
                width = "double",
                desc = L"Print spell IDs associated with CDM Bars in chat",
                func = function() NugRunning.Commands.debug() end,
                order = 7,
            },
        },
    }


    local mainOpts = {
        type = 'group',
        name = "Help",
        order = 1,
        args = {
            msg = {
                name = L"In Forever/Midnight NugRunning functions by making changes to Blizzard's Cooldown Manager.\n\n",
                type = "description",
                fontSize = "medium",
                width = "full",
                order = 1,
            },
            cdmToggle = {
                name = L"Enable Cooldown Manager",
                width = "full",
                type = "toggle",
                get = function(info) return GetCVar("cooldownViewerEnabled") == "1" end,
                set = function(info, v)
                    SetCVar("cooldownViewerEnabled", v and "1" or "0")
                end,
                order = 3.1,
            },
        },
    }


    local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")


    AceConfigRegistry:RegisterOptionsTable("NugRunningMain", mainOpts)
    AceConfigRegistry:RegisterOptionsTable("NugRunningIcons", iconOpts)
    AceConfigRegistry:RegisterOptionsTable("NugRunningBars", barOpts)

    local AceConfigDialog = LibStub("AceConfigDialog-3.0")

    local mainFrame, mainCategoryID = AceConfigDialog:AddToBlizOptions("NugRunningMain", "NugRunning")
    local panelFrame1, categoryID1 = AceConfigDialog:AddToBlizOptions("NugRunningIcons", "Icon Style", "NugRunning")
    local panelFrame2, categoryID2 = AceConfigDialog:AddToBlizOptions("NugRunningBars", "Buff Bars Style", "NugRunning")

    return mainFrame, mainCategoryID
end




local function MakeHelp()
    local opt = {
        type = 'group',
        name = "Help",
        order = 1,
        args = {
            msg = {
                name = L"NugRunning provides commands to list spellIDs of all current auras.\n/nrun listauras target\n/nrun listauras player\n/nrun debug - toggle combat log event display in chat\nSpell ID next to SPELL_CAST_SUCCESS is the one to use for cooldowns\nWoW Classic doesn't have spell IDs in combat log",
                type = "description",
                fontSize = "medium",
                width = "full",
                order = 1,
            },
            msg2 = {
                name = L"To move timer groups to different anchors use '/nrun groupset' command. /nrun help for more info",
                type = "description",
                fontSize = "medium",
                width = "full",
                order = 2,
            },
        },
    }
    return opt
end



local function InterfaceOptions_AddCategory(frame, addOn, position)
	-- cancel is no longer a default option. May add menu extension for this.
	frame.OnCommit = frame.okay;
	frame.OnDefault = frame.default;
	frame.OnRefresh = frame.refresh;

	if frame.parent then
		local category = Settings.GetCategory(frame.parent);
		local subcategory, layout = Settings.RegisterCanvasLayoutSubcategory(category, frame, frame.name, frame.name);
		subcategory.ID = frame.name;
		return subcategory, category;
	else
		local category, layout = Settings.RegisterCanvasLayoutCategory(frame, frame.name, frame.name);
		category.ID = frame.name;
		Settings.RegisterAddOnCategory(category);
		return category;
	end
end

do
    local f = CreateFrame('Frame', "NugRunningOptions", InterfaceOptionsFrame)
    local panelFrame, categoryID = MakeGeneralOptions() -- makes the root category now
    f.general = panelFrame
    f.categoryID = categoryID
    -- f.help = MakeHelp()


    local parentCategory = Settings.GetCategory(categoryID);
    local panel = NugRunningGUI:Create("Spell List", "NugRunning")
    local subcategory, layout = Settings.RegisterCanvasLayoutSubcategory(parentCategory, panel.frame, panel.frame.name);
end
