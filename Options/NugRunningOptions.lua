NugRunningGUI = CreateFrame("Frame","NugRunningGUI")

-- NugRunningGUI:SetScript("OnEvent", function(self, event, ...)
	-- self[event](self, event, ...)
-- end)
-- NugRunningGUI:RegisterEvent("ADDON_LOADED")

local AceGUI = LibStub("AceGUI-3.0")
local COMBATLOG_OBJECT_AFFILIATION_PARTY_OR_RAID = COMBATLOG_OBJECT_AFFILIATION_RAID + COMBATLOG_OBJECT_AFFILIATION_PARTY


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
		if (isGlobal and opts.global) or (not isGlobal and not opts.global) then
			local name = (opts.name == "" or not opts.name) and (GetSpellInfo(spellID) or "Unknown") or opts.name
			local custom_opts = custom[category] and custom[category][spellID]
			local status
			local order = 5
			-- print(opts.name, custom_opts)
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
			table.insert(t, {
				value = spellID,
				text = text,
				icon = GetSpellTexture(spellID),
				order = order,
			})
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
	newspell:SetText("New Spell")
	newspell:SetFullWidth(true)
	newspell:SetCallback("OnClick", function(self, event)
		self.parent:ShowNewTimer("spells")
	end)
	Form:AddChild(newspell)
    Form.controls.newspell = newspell

	local newcooldown = AceGUI:Create("Button")
	newcooldown:SetText("New Cooldown")
	newcooldown:SetFullWidth(true)
	newcooldown:SetCallback("OnClick", function(self, event)
		self.parent:ShowNewTimer("cooldowns")
	end)
	Form:AddChild(newcooldown)
    Form.controls.newcooldown = newcooldown

	local newcast = AceGUI:Create("Button")
	newcast:SetText("New Cast")
	newcast:SetFullWidth(true)
	newcast:SetCallback("OnClick", function(self, event)
		self.parent:ShowNewTimer("casts")
	end)
	Form:AddChild(newcast)
    Form.controls.newcast = newcast

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
	save:SetText("Save")
	save:SetRelativeWidth(0.5)
	save:SetCallback("OnClick", function(self, event)
		local p = self.parent
		local class = p.class
		local category = p.category
		local spellID = p.id
		local opts = p.opts

		if not spellID then -- make new timer
			spellID = tonumber(self.parent.controls.spellID:GetText())
			if not spellID then
				--invalid spell id string
				return
			end
            if not GetSpellInfo(spellID) then
                return -- spell doesn't exist
            end

			if not opts.name then
				opts.name = GetSpellInfo(spellID)
			end
			if category == "spells" and not opts.duration then
				opts.duration = 3
			end
			opts.spellID = nil
		end

        local default_opts = NugRunningConfig[category][spellID]
        if default_opts then
            clean(opts, default_opts, "ghost", false)
            clean(opts, default_opts, "singleTarget", false)
            clean(opts, default_opts, "multiTarget", false)
            clean(opts, default_opts, "scale", 1)
            clean(opts, default_opts, "shine", false)
            clean(opts, default_opts, "shinerefresh", false)
            clean(opts, default_opts, "nameplates", false)
            clean(opts, default_opts, "group", "default")
            clean(opts, default_opts, "affiliation", COMBATLOG_OBJECT_AFFILIATION_MINE)
            clean(opts, default_opts, "fixedlen", false)
            clean(opts, default_opts, "priority", false)
            clean(opts, default_opts, "scale_until", false)
            clean(opts, default_opts, "hide_until", false)
            clean(opts, default_opts, "maxtimers", false)
            clean(opts, default_opts, "color2", false)
            clean(opts, default_opts, "arrow", false)
            clean(opts, default_opts, "overlay", false)
            clean(opts, default_opts, "tick", false)
            clean(opts, default_opts, "recast_mark", false)
            clean(opts, default_opts, "effect", "NONE")
            clean(opts, default_opts, "ghosteffect", "NONE")
        end
        if opts.overlay and (not default_opts or not default_opts.overlay) and (not opts.overlay[1] or not opts.overlay[2]) then opts.overlay = nil end
		-- PRESAVE = p.opts
		local delta = CopyTable(opts)
        delta.timer = nil -- important, clears runtime data


		if default_opts then
            NugRunning.RemoveDefaults(delta, default_opts)
			NugRunningConfigMerged[category][spellID] = CopyTable(default_opts)
            -- if delta.disabled then
                -- NugRunningConfigMerged[category][spellID] = nil
            -- else
            NugRunning.MergeTable(NugRunningConfigMerged[category][spellID], delta, true)
            -- end
		else
			NugRunningConfigMerged[category][spellID] = delta
		end

		NugRunningConfigCustom[class] = NugRunningConfigCustom[class] or {}
		NugRunningConfigCustom[class][category] = NugRunningConfigCustom[class][category] or {}
		if not next(delta) then delta = nil end
		NugRunningConfigCustom[class][category][spellID] = delta

		NugRunningGUI.frame.tree:UpdateSpellTree()
		NugRunningGUI.frame.tree:SelectByPath(class, category, spellID)
		-- POSTSAVE = delta
	end)
	Form:AddChild(save)

	local delete = AceGUI:Create("Button")
	delete:SetText("Delete")
	save:SetRelativeWidth(0.5)
	delete:SetCallback("OnClick", function(self, event)
		local p = self.parent
		local class = p.class
		local category = p.category
		local spellID = p.id
		-- local opts = p.opts

		NugRunningConfigCustom[class][category][spellID] = nil
		NugRunningConfigMerged[category][spellID] = NugRunningConfig[category][spellID]

		NugRunningGUI.frame.tree:UpdateSpellTree()
		NugRunningGUI.frame.tree:SelectByPath(class, category, spellID)
	end)
	Form.controls.delete = delete
	Form:AddChild(delete)

	local spellID = AceGUI:Create("EditBox")
	spellID:SetLabel("Spell ID")
	spellID:SetDisabled(true)
    spellID:DisableButton(true)
	spellID:SetRelativeWidth(0.2)
	spellID:SetCallback("OnTextChanged", function(self, event, value)
        local v = tonumber(value)
        if v and v > 0 and GetSpellInfo(v) then
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
	disabled:SetLabel("Disabled")
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
	short:SetLabel("Short Name")
	-- short:SetFullWidth(true)
	short:SetRelativeWidth(0.29)
	short:SetCallback("OnEnterPressed", function(self, event, value)
		self.parent.opts["short"] = value
	end)
	-- short.alignoffset = 60
	-- short:SetHeight(32)
	Form.controls.short = short
	Form:AddChild(short)
    AddTooltip(short, "Shortened label, overrides full name")

	local name = AceGUI:Create("EditBox")
	name:SetLabel("Name")
	-- name:SetFullWidth(true)
	name:SetRelativeWidth(0.5)
	name:SetCallback("OnEnterPressed", function(self, event, value)
		self.parent.opts["name"] = value
	end)
	-- name:SetHeight(32)
	Form.controls.name = name
	Form:AddChild(name)
    AddTooltip(name, "Custom timer label.\nLeave blank to hide.")

	local duration = AceGUI:Create("EditBox")
	duration:SetLabel("Duration")
	duration:SetDisabled(true)
	duration:SetRelativeWidth(0.19)
    duration:DisableButton(true)
	duration:SetCallback("OnTextChanged", function(self, event, value)
		local v = tonumber(value)
		if v and v > 0 then
			self.parent.opts["duration"] = v
        elseif value == "" then
            self.parent.opts["fixedlen"] = false
            self:SetText("")
		end
	end)
	Form.controls.duration = duration
	Form:AddChild(duration)
    AddTooltip(duration, "Duration to fallback to when it can't be retrieved from unit (very rare)")

	local fixedlen = AceGUI:Create("EditBox")
	fixedlen:SetLabel("|cff00ff00Fixed Duration|r")
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
    AddTooltip(fixedlen, "Set static timer max duration to align timer decay speed with other timers")


	local prio = AceGUI:Create("EditBox")
	prio:SetLabel("|cff55ff55Priority|r")
	-- prio:SetFullWidth(true)
	prio:SetRelativeWidth(0.15)
    prio:DisableButton(true)
	prio:SetCallback("OnTextChanged", function(self, event, value)
		local v = tonumber(value)
		if v then
			self.parent.opts["priority"] = v
        elseif value == "" then
            self.parent.opts["priority"] = false
            self:SetText("")
		end
	end)
	-- prio:SetHeight(32)
	Form.controls.priority = prio
	Form:AddChild(prio)
    AddTooltip(prio, "Positive or negative numeric value.\nDefault priority is 0.\nTimers with equal priority sorted by remaining time.")

	local group = AceGUI:Create("Dropdown")
	group:SetLabel("Group")

    local groupList = {
        default = "Default"
    }
    local groupOrder = { "default" }
    for anchor,groups in pairs(NugRunningConfig.anchors) do
        for i, group in ipairs(groups) do
            local name = group.name
            if name ~= "player" and name ~= "target" and name ~= "offtargets" then
                groupList[name] = name
                table.insert(groupOrder, name)
            end
        end
    end


	group:SetList(groupList, groupOrder)
	group:SetRelativeWidth(0.30)
	group:SetCallback("OnValueChanged", function(self, event, value)
		self.parent.opts["group"] = value
	end)
	-- group:SetHeight(32)
	Form.controls.group = group
	Form:AddChild(group)
    AddTooltip(group, "Assign to timer group")

	local scale = AceGUI:Create("Slider")
	scale:SetLabel("Scale")
	scale:SetSliderValues(0.3, 2, 0.05)
	scale:SetRelativeWidth(0.30)
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
    AddTooltip(scale, "Vertical timer scale")

	local scale_until = AceGUI:Create("EditBox")
	scale_until:SetLabel("Minimize Until")
	scale_until:SetRelativeWidth(0.22)
    scale_until:DisableButton(true)
	scale_until:SetCallback("OnTextChanged", function(self, event, value)
		local v = tonumber(value)
		if v then
			self.parent.opts["scale_until"] = v
		elseif value == "" then
			self.parent.opts["scale_until"] = false
			self:SetText("")
		end
	end)
	Form.controls.scale_until = scale_until
	Form:AddChild(scale_until)
    AddTooltip(scale_until, "Minimize until duration is less than X")

	local color = AceGUI:Create("ColorPicker")
	color:SetLabel("Color")
	color:SetRelativeWidth(0.20)
	color:SetHasAlpha(false)
	color:SetCallback("OnValueConfirmed", function(self, event, r,g,b,a)
		self.parent.opts["color"] = {r,g,b}
	end)
	Form.controls.color = color
	Form:AddChild(color)

	local color2 = AceGUI:Create("ColorPicker")
	color2:SetLabel("End Color")
	color2:SetRelativeWidth(0.20)
	color2:SetHasAlpha(false)
	color2:SetCallback("OnValueConfirmed", function(self, event, r,g,b,a)
		self.parent.opts["color2"] = {r,g,b}
	end)
	Form.controls.color2 = color2
	Form:AddChild(color2)
    AddTooltip(color2, "if present, timer color shifts from base color to end color as it's progressing")

	local c2r = AceGUI:Create("Button")
	c2r:SetText("X")
	c2r:SetRelativeWidth(0.1)
	c2r:SetCallback("OnClick", function(self, event)
		self.parent.opts["color2"] = false
		self.parent.controls.color2:SetColor(1,1,1,0)
	end)
	Form.controls.c2r = c2r
	Form:AddChild(c2r)
    AddTooltip(c2r, "Remove End Color")

	local arrow = AceGUI:Create("ColorPicker")
	arrow:SetLabel("Highlight")
	arrow:SetRelativeWidth(0.20)
	arrow:SetHasAlpha(false)
	arrow:SetCallback("OnValueConfirmed", function(self, event, r,g,b,a)
		self.parent.opts["arrow"] = {r,g,b}
	end)
	Form.controls.arrow = arrow
	Form:AddChild(arrow)
    AddTooltip(arrow, "Timer highlight mark color")

	local ar = AceGUI:Create("Button")
	ar:SetText("X")
	ar:SetRelativeWidth(0.1)
	ar:SetCallback("OnClick", function(self, event)
		self.parent.opts["arrow"] = false
		self.parent.controls.arrow:SetColor(1,1,1,0)
	end)
	Form.controls.ar = ar
	Form:AddChild(ar)
    AddTooltip(ar, "Remove Highlight Color")

    local hide_until = AceGUI:Create("EditBox")
    hide_until:SetLabel("Hide Until")
    hide_until:SetRelativeWidth(0.17)
    hide_until:DisableButton(true)
    hide_until:SetCallback("OnTextChanged", function(self, event, value)
        local v = tonumber(value)
        if v then
            self.parent.opts["hide_until"] = v
        elseif value == "" then
            self.parent.opts["hide_until"] = false
            self:SetText("")
        end
    end)
    Form.controls.hide_until = hide_until
    Form:AddChild(hide_until)
    AddTooltip(hide_until, "Hide until duration is less than X\n(Only for cooldowns)")

	local ghost = AceGUI:Create("CheckBox")
	ghost:SetLabel("Ghost")
	ghost:SetRelativeWidth(0.32)
	ghost:SetCallback("OnValueChanged", function(self, event, value)
		self.parent.opts["ghost"] = value
	end)
	Form.controls.ghost = ghost
	Form:AddChild(ghost)
    AddTooltip(ghost, "Timer remains for a short time after expiring")

	local shine = AceGUI:Create("CheckBox")
	shine:SetLabel("Shine")
	shine:SetRelativeWidth(0.32)
	shine:SetCallback("OnValueChanged", function(self, event, value)
		self.parent.opts["shine"] = value
	end)
	Form.controls.shine = shine
	Form:AddChild(shine)
    AddTooltip(shine, "Shine when created")

	local shinerefresh = AceGUI:Create("CheckBox")
	shinerefresh:SetLabel("On Refresh")
	shinerefresh:SetRelativeWidth(0.32)
	shinerefresh:SetCallback("OnValueChanged", function(self, event, value)
		self.parent.opts["shinerefresh"] = value
	end)
	Form.controls.shinerefresh = shinerefresh
	Form:AddChild(shinerefresh)
    AddTooltip(shinerefresh, "Shine when refreshed")




	local maxtimers = AceGUI:Create("EditBox")
	maxtimers:SetLabel("Max Timers")
	maxtimers:SetRelativeWidth(0.25)
    maxtimers:DisableButton(true)
	maxtimers:SetCallback("OnTextChanged", function(self, event, value)
		local v = tonumber(value)
		if v and v > 0 then
			self.parent.opts["maxtimers"] = v
            self.parent.controls.multiTarget:SetValue(false)
            self.parent.opts["multiTarget"] = false
            self.parent.controls.singleTarget:SetValue(false)
            self.parent.opts["singleTarget"] = false
		elseif value == "" then
			self.parent.opts["maxtimers"] = false
			self:SetText("")
		end
	end)
	Form.controls.maxtimers = maxtimers
	Form:AddChild(maxtimers)
    AddTooltip(maxtimers, "Maximum amount of timers that can exist.\nUsed to prevent spam.")


	local singleTarget = AceGUI:Create("CheckBox")
	singleTarget:SetLabel("Single-Target")
	singleTarget:SetRelativeWidth(0.3)
	singleTarget:SetCallback("OnValueChanged", function(self, event, value)
		self.parent.opts["singleTarget"] = value
		if value then
			self.parent.controls.multiTarget:SetValue(false)
            self.parent.opts["multiTarget"] = false
            self.parent.controls.maxtimers:SetText("")
            self.parent.opts["maxtimers"] = false
		end
	end)
	Form.controls.singleTarget = singleTarget
	Form:AddChild(singleTarget)
    AddTooltip(singleTarget, "Timer is only displayed if it's on the current target or you have no other target.\nUsed to prevent spam.")

	local multiTarget = AceGUI:Create("CheckBox")
	multiTarget:SetLabel("Multi-Target")
	multiTarget:SetRelativeWidth(0.3)
	multiTarget:SetCallback("OnValueChanged", function(self, event, value)
		self.parent.opts["multiTarget"] = value
		if value then
			self.parent.controls.singleTarget:SetValue(false)
            self.parent.opts["singleTarget"] = false
            self.parent.controls.maxtimers:SetText("")
            self.parent.opts["maxtimers"] = false
		end
	end)
	Form.controls.multiTarget = multiTarget
	Form:AddChild(multiTarget)
    AddTooltip(multiTarget, "For AoE debuffs, condensing timers from multiple targets into one.\nUsed to prevent spam.")


	local affiliation = AceGUI:Create("Dropdown")
	affiliation:SetLabel("Affiliation")
	affiliation:SetList({
		[COMBATLOG_OBJECT_AFFILIATION_MINE] = "Player",
		[COMBATLOG_OBJECT_AFFILIATION_PARTY_OR_RAID] = "Raid",
		[COMBATLOG_OBJECT_AFFILIATION_OUTSIDER] = "Any"
	}, { 1, 6, 8})
	affiliation:SetRelativeWidth(0.40)
	affiliation:SetCallback("OnValueChanged", function(self, event, value)
		if value == COMBATLOG_OBJECT_AFFILIATION_MINE then value = nil end
		self.parent.opts["affiliation"] = value
	end)
	Form.controls.affiliation = affiliation
	Form:AddChild(affiliation)
    AddTooltip(affiliation, "Limit events to self/raid/everyone")

	local nameplates = AceGUI:Create("CheckBox")
	nameplates:SetLabel("Show on Nameplates")
	nameplates:SetRelativeWidth(0.4)
	nameplates:SetCallback("OnValueChanged", function(self, event, value)
		self.parent.opts["nameplates"] = value
	end)
	Form.controls.nameplates = nameplates
	Form:AddChild(nameplates)
    AddTooltip(nameplates, "Mirror timer on nameplates.\nMay need /reload to enable nameplate functionality.")

    


	local overlay_start = AceGUI:Create("EditBox")
	overlay_start:SetLabel("Overlay Start")
	overlay_start:SetRelativeWidth(0.25)
    -- overlay_start:DisableButton(true)
	overlay_start:SetCallback("OnEnterPressed", function(self, event, value)
		local v
		if value == "tick" or value == "tickend" or value ==  "end" or value == "gcd" then
			v = value
		else
			v = tonumber(value)
			if v and v <= 0 then v = nil end
		end
		if v then
			if not self.parent.opts.overlay then
				self.parent.opts.overlay = {v, nil, 0.3, nil}
			else
				self.parent.opts.overlay[1] = v
			end
		else
			self.parent.opts["overlay"] = false
			self.parent.controls.overlay_start:SetText("")
			self.parent.controls.overlay_end:SetText("")
            self.parent.controls.overlay_haste:SetValue(false)
		end
	end)
	Form.controls.overlay_start = overlay_start
	Form:AddChild(overlay_start)
    AddTooltip(overlay_start, "Overlay marks time intervals.\nSpecial values:\ngcd\ntick")

	local overlay_end = AceGUI:Create("EditBox")
	overlay_end:SetLabel("Overlay End")
	overlay_end:SetRelativeWidth(0.25)
    -- overlay_end:DisableButton(true)
	overlay_end:SetCallback("OnEnterPressed", function(self, event, value)
		local v
		if value == "tick" or value == "tickend" or value ==  "end" or value == "gcd" then
			v = value
		else
			v = tonumber(value)
			if v and v <= 0 then v = nil end
		end
		if v then
			if not self.parent.opts.overlay then
				self.parent.opts.overlay = {nil, v, 0.3, nil}
			else
				self.parent.opts.overlay[2] = v
			end
		else
			self.parent.opts["overlay"] = false
			self.parent.controls.overlay_start:SetText("")
			self.parent.controls.overlay_end:SetText("")
            self.parent.controls.overlay_haste:SetValue(false)
		end
	end)
	Form.controls.overlay_end = overlay_end
	Form:AddChild(overlay_end)
    AddTooltip(overlay_end, "Overlay marks time intervals.\nSpecial values:\ntickend\nend")

	local overlay_haste = AceGUI:Create("CheckBox")
	overlay_haste:SetLabel("Haste Reduced")
	overlay_haste:SetRelativeWidth(0.4)
	overlay_haste:SetCallback("OnValueChanged", function(self, event, value)
		if not self.parent.opts.overlay then
			self.parent.opts.overlay = {nil, nil, 0.3, value}
		else
            self.parent.opts.overlay[4] = value
		end
	end)
	Form.controls.overlay_haste = overlay_haste
	Form:AddChild(overlay_haste)
    AddTooltip(overlay_haste, "Overlay length is reduced by haste.")

	local tick = AceGUI:Create("EditBox")
	tick:SetLabel("Tick")
	tick:SetRelativeWidth(0.15)
    tick:DisableButton(true)
	tick:SetCallback("OnTextChanged", function(self, event, value)
		local v = tonumber(value)
		if v then
			self.parent.opts["tick"] = v
			self.parent.opts["recast_mark"] = false
			self.parent.controls.recast_mark:SetText("")
		elseif value == "" then
			self.parent.opts["tick"] = false
			self:SetText("")
		end
	end)
	Form.controls.tick = tick
	Form:AddChild(tick)
    AddTooltip(tick, "Tick length.\nLeave empty to disable ticks.\nMutually exclusive with recast mark.")

	local recast_mark = AceGUI:Create("EditBox")
	recast_mark:SetLabel("Recast Mark")
	recast_mark:SetRelativeWidth(0.15)
    recast_mark:DisableButton(true)
	recast_mark:SetCallback("OnTextChanged", function(self, event, value)
		local v = tonumber(value)
		if v and v > 0 then
			self.parent.opts["recast_mark"] = v
			self.parent.opts["tick"] = false
			self.parent.controls.tick:SetText("")
		elseif value == "" then
			self.parent.opts["recast_mark"] = false
			self:SetText("")
		end
	end)
	Form.controls.recast_mark = recast_mark
	Form:AddChild(recast_mark)
    AddTooltip(recast_mark, "Place mark on a timer, that will shine when passed through")



    local effectsList = {
        ["NONE"] = "<NONE>"
    }
    local effectsOrder = { "NONE" }
    for k,v in pairs(NugRunningConfig.effects) do
        effectsList[k] = k
        table.insert(effectsOrder, k)
    end

    local effect = AceGUI:Create("Dropdown")
    effect:SetLabel("3D Effect")
    effect:SetList(effectsList, effectsOrder)
    effect:SetRelativeWidth(0.34)
    effect:SetCallback("OnValueChanged", function(self, event, value)
        self.parent.opts["effect"] = value
    end)
    Form.controls.effect = effect
    Form:AddChild(effect)
    AddTooltip(effect, "Show 3D effect near timer")

    local ghosteffect = AceGUI:Create("Dropdown")
    ghosteffect:SetLabel("Ghost 3D Effect")
    ghosteffect:SetList(effectsList, effectsOrder)
    ghosteffect:SetRelativeWidth(0.34)
    ghosteffect:SetCallback("OnValueChanged", function(self, event, value)
        self.parent.opts["ghosteffect"] = value
    end)
    Form.controls.ghosteffect = ghosteffect
    Form:AddChild(ghosteffect)
    AddTooltip(ghosteffect, "Effect during ghost phase")

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
	local controls = Form.controls
	controls.spellID:SetText(id or "")
	controls.spellID:SetDisabled(not isEmptyForm)
	controls.disabled:SetValue(opts.disabled)
	controls.disabled:SetDisabled(isEmptyForm)

	controls.name:SetText(opts.name or "")
	controls.priority:SetText(opts.priority)
	controls.group:SetValue(opts.group or "default")
	controls.short:SetText(opts.short)
	controls.duration:SetText((type(opts.duration) == "function" and "<func>") or opts.duration)
	controls.scale:SetValue(opts.scale or 1)
	controls.scale_until:SetText(opts.scale_until)
    controls.hide_until:SetText(opts.hide_until)
	controls.shine:SetValue(opts.shine)
	controls.shinerefresh:SetValue(opts.shinerefresh)

	if opts.ghost then
		controls.ghost:SetValue(true)
	else
		controls.ghost:SetValue(false)
	end
	controls.maxtimers:SetText(opts.maxtimers)
	controls.singleTarget:SetValue(opts.singleTarget)
	controls.multiTarget:SetValue(opts.multiTarget)

	controls.color:SetColor(fillAlpha(opts.color or {0.8, 0.1, 0.7} ))
	-- print(fillAlpha(opts.color2))
	controls.color2:SetColor(fillAlpha(opts.color2 or {1,1,1,0} ))
	controls.arrow:SetColor(fillAlpha(opts.arrow or {1,1,1,0} ))

	controls.affiliation:SetValue(opts.affiliation or COMBATLOG_OBJECT_AFFILIATION_MINE)
	controls.nameplates:SetValue(opts.nameplates)

	controls.tick:SetText(opts.tick)
	controls.recast_mark:SetText(opts.recast_mark)
	controls.fixedlen:SetText(opts.fixedlen)

	if opts.overlay then
		controls.overlay_start:SetText(opts.overlay[1])
		controls.overlay_end:SetText(opts.overlay[2])
		controls.overlay_haste:SetValue(opts.overlay[4])
	else
		controls.overlay_start:SetText("")
		controls.overlay_end:SetText("")
		controls.overlay_haste:SetValue(false)
	end

    controls.effect:SetValue(opts.effect or "NONE")
    controls.ghosteffect:SetValue(opts.ghosteffect or "NONE")

	if id and not NugRunningConfig[category][id] then
		controls.delete:SetDisabled(false)
		controls.delete:SetText("Delete")
	elseif NugRunningConfigCustom[class] and  NugRunningConfigCustom[class][category] and NugRunningConfigCustom[class][category][id] then
		controls.delete:SetDisabled(false)
		controls.delete:SetText("Restore")
	else
		controls.delete:SetDisabled(true)
		controls.delete:SetText("Restore")
	end


	if category == "spells" then
		controls.duration:SetDisabled(false)
		controls.maxtimers:SetDisabled(false)
		controls.singleTarget:SetDisabled(false)
		controls.multiTarget:SetDisabled(false)
		controls.affiliation:SetDisabled(false)
		controls.nameplates:SetDisabled(false)
        controls.hide_until:SetDisabled(true)
	else
		controls.duration:SetDisabled(true)
		controls.maxtimers:SetDisabled(true)
		controls.singleTarget:SetDisabled(true)
		controls.multiTarget:SetDisabled(true)
		controls.affiliation:SetDisabled(true)
		controls.nameplates:SetDisabled(true)
        controls.hide_until:SetDisabled(false)
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
	Frame:SetTitle("NugRunning Spell List")
	Frame:SetLayout("Fill")
	-- Frame:SetHeight(500)
	-- Frame:SetWidth(700)
	NRO = Frame
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
                NewTimerForm.controls.newcast:SetDisabled(true)
            else
                NewTimerForm.controls.newcooldown:SetDisabled(false)
                NewTimerForm.controls.newcast:SetDisabled(false)
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
				text = "Global",
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
					{
						value = "casts",
						text = "Casts",
						icon = "Interface\\Icons\\spell_deathvortex",
						children = NugRunningGUI:GenerateCategoryTree(false,"casts")
					},
					-- {
					-- 	value = "event_timers",
					-- 	text = "Events",
					-- 	icon = "ability_deathwing_sealarmorbreachtga",
					-- 	children = NugRunningGUI:GenerateCategoryTree("casts")
					-- }
				}
			},
		}
		self:SetTree(t)
		return t
	end


	local t = treegroup:UpdateSpellTree()

	Frame:AddChild(treegroup)



	local categories = {"spells", "cooldowns", "casts"}
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
    local opt = {
        type = 'group',
        name = "NugRunning Settings",
        order = 1,
        args = {
            -- charspec = {
            --     type = 'toggle',
            --     name = "Character-specific",
            --     desc = "Switch between global/character configuration",
            --     width = "full",
            --     order = 0,
            --     get = function(info)
            --         local user = UnitName("player").."@"..GetRealmName()
            --         return NugRunning.db_Global.charspec[user]
            --     end,
            --     set = function( info, v )
            --         NugRunning.Commands.charspec()
            --     end
            -- },
            anchors = {
                type = "group",
                name = "Anchors",
                guiInline = true,
                order = 2,
                args = {
                    unlock = {
                        name = "Unlock",
                        type = "execute",
                        -- width = "half",
                        desc = "Unlock anchor for dragging",
                        func = function() NugRunning.Commands.unlock() end,
                        order = 1,
                    },
                    lock = {
                        name = "Lock",
                        type = "execute",
                        -- width = "half",
                        desc = "Lock anchor",
                        func = function() NugRunning.Commands.lock() end,
                        order = 2,
                    },
                    reset = {
                        name = "Reset",
                        type = "execute",
                        desc = "Reset anchor",
                        func = function() NugRunning.Commands.reset() end,
                        order = 3,
                    },
                },
            }, --
            sizeSettings = {
                type = "group",
                name = " ",
                guiInline = true,
                order = 3,
                args = {
                    width = {
                        name = "Width",
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
                        step = 5,
                        order = 1,
                    },
                    height = {
                        name = "Height",
                        type = "range",
                        get = function(info) return NugRunning.db.height end,
                        set = function(info, v)
                            NugRunning.db.height = v
                            for i,timer in ipairs(NugRunning.timers) do
                                timer:Resize(NugRunning.db.width, NugRunning.db.height)
                            end
                        end,
                        min = 10,
                        max = 50,
                        step = 1,
                        order = 2,
                    },
                    growth = {
                        name = "Growth Direction",
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
                },
            },
            nameplate_sizeSettings = {
                type = "group",
                name = " ",
                guiInline = true,
                order = 3,
                args = {
                    width = {
                        name = "Nameplate Width",
                        type = "range",
                        get = function(info) return NugRunning.db.np_width end,
                        set = function(info, v)
                            NugRunning.db.np_width = v
                            NugRunningNameplates:Resize()
                        end,
                        min = 50,
                        max = 200,
                        step = 1,
                        order = 1,
                    },
                    height = {
                        name = "Nameplate Height",
                        type = "range",
                        get = function(info) return NugRunning.db.np_height end,
                        set = function(info, v)
                            NugRunning.db.np_height = v
                            NugRunningNameplates:Resize()
                        end,
                        min = 3,
                        max = 50,
                        step = 1,
                        order = 2,
                    },
                    xoffset = {
                        name = "Nameplate X Offset",
                        type = "range",
                        get = function(info) return NugRunning.db.np_xoffset end,
                        set = function(info, v)
                            NugRunning.db.np_xoffset = v
                            NugRunningNameplates:Resize()
                        end,
                        min = -100,
                        max = 100,
                        step = 1,
                        order = 3,
                    },
                    yoffset = {
                        name = "Nameplate Y Offset",
                        type = "range",
                        get = function(info) return NugRunning.db.np_yoffset end,
                        set = function(info, v)
                            NugRunning.db.np_yoffset = v
                            NugRunningNameplates:Resize()
                        end,
                        min = -100,
                        max = 100,
                        step = 1,
                        order = 3,
                    },
                },
            },
            timerOptions = {
                type = "group",
                name = "Timers",
                guiInline = true,
                order = 4,
                args = {

                    spellText = {
                        name = "Show Spell Names",
                        type = "toggle",
                        desc = "Display spell name on timers",
                        get = function(info) return NugRunning.db.spellTextEnabled end,
                        set = function(info, v) NugRunning.db.spellTextEnabled = not NugRunning.db.spellTextEnabled end,
                        order = 1,
                    },
                    localNames = {
                        name = "Localized Spell Names",
                        type = "toggle",
                        desc = "Ignore custom names and always show native spell names",
                        get = function(info) return NugRunning.db.localNames end,
                        set = function(info, v) NugRunning.db.localNames = not NugRunning.db.localNames end,
                        order = 2,
                    },
                    misses = {
                        name = "Misses",
                        type = "toggle",
                        desc = "Show short notification when spell is resisted/missed",
                        get = function(info) return NugRunning.db.missesEnabled end,
                        set = function(info, v) NugRunning.db.missesEnabled = not NugRunning.db.missesEnabled end,
                        order = 3,
                    },
                    nameplates = {
                        name = "Nameplate Timers",
                        type = "toggle",
                        desc = "Mirror flagged spell timers on nameplates",
                        get = function(info) return NugRunning.db.nameplates end,
                        set = function(info, v) NugRunning.db.nameplates = not NugRunning.db.nameplates end,
                        order = 4,
                    },
                    nameplateLines = {
                        name = "Nameplate Lines",
                        type = "toggle",
                        desc = "Draw guide lines from nameplates to main timers",
                        get = function(info) return NugRunning.db.nameplateLines end,
                        set = function(info, v)
                            NugRunning.db.nameplateLines = not NugRunning.db.nameplateLines
                            NugRunningNameplates:EnableLines(NugRunning.db.nameplateLines)
                        end,
                        order = 5,
                    },
                    totems = {
                        name = "Totems",
                        type = "toggle",
                        desc = "Display timers for totems (or other similar summons)",
                        get = function(info) return NugRunning.db.totems end,
                        set = function(info, v) NugRunning.db.totems = not NugRunning.db.totems end,
                        order = 6,
                    },
                },
            },
            debug = {
                name = "Toggle Combat Log Data",
                type = "execute",
                width = "double",
                desc = "Print occurring combat log events in chat",
                func = function() NugRunning.Commands.debug() end,
                order = 7,
            },
        },
    }

    local AceConfigRegistry = LibStub("AceConfigRegistry-3.0")
    AceConfigRegistry:RegisterOptionsTable("NugRunningGeneral", opt)

    local AceConfigDialog = LibStub("AceConfigDialog-3.0")
    local panelFrame = AceConfigDialog:AddToBlizOptions("NugRunningGeneral", "General", "NugRunning")

    return panelFrame
end










do
    local f = CreateFrame('Frame', "NugRunningOptions", InterfaceOptionsFrame)
    f.name = "NugRunning"
    InterfaceOptions_AddCategory(f);

    f.general = MakeGeneralOptions()

    NugRunningGUI.frame = NugRunningGUI:Create("Spell List", "NugRunning")
    f.spell_list = NugRunningGUI.frame.frame
    InterfaceOptions_AddCategory(f.spell_list);

    f:Hide()
    f:SetScript("OnShow", function(self)
            self:Hide();
            local list = self.spell_list
            InterfaceOptionsFrame_OpenToCategory (list)
            InterfaceOptionsFrame_OpenToCategory (list)
    end)
end
