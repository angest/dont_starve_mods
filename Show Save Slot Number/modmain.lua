local ANCHOR_MIDDLE = GLOBAL.ANCHOR_MIDDLE
local CAPY_DLC = GLOBAL.CAPY_DLC
local CONTROL_ACCEPT = GLOBAL.CONTROL_ACCEPT
local Image = GLOBAL.require "widgets/image"
local IsDLCInstalled = GLOBAL.IsDLCInstalled
local JapaneseOnPS4 = GLOBAL.JapaneseOnPS4
local LoadGameScreen = GLOBAL.require "screens/loadgamescreen"
local PORKLAND_DLC = GLOBAL.PORKLAND_DLC
local REIGN_OF_GIANTS = GLOBAL.REIGN_OF_GIANTS
local STRINGS = GLOBAL.STRINGS
local Text = GLOBAL.require "widgets/text"
local TheInput = GLOBAL.TheInput
local TITLEFONT = GLOBAL.TITLEFONT
local UIAnim = GLOBAL.require "widgets/uianim"
local Widget = GLOBAL.require "widgets/widget"

local function HasDLC()
    return IsDLCInstalled(REIGN_OF_GIANTS) or
        IsDLCInstalled(CAPY_DLC) or
        IsDLCInstalled(PORKLAND_DLC)
end

function LoadGameScreen:MakeSaveTile(slotnum)
    local widget = Widget("savetile")
    widget.base = widget:AddChild(Widget("base"))

    local mode = GLOBAL.SaveGameIndex:GetCurrentMode(slotnum)
    local day = GLOBAL.SaveGameIndex:GetSlotDay(slotnum)
    local world = GLOBAL.SaveGameIndex:GetSlotWorld(slotnum)
    local character = GLOBAL.SaveGameIndex:GetSlotCharacter(slotnum)
    local DLC = GLOBAL.SaveGameIndex:GetSlotDLC(slotnum)
    local RoG = (DLC ~= nil and DLC.REIGN_OF_GIANTS ~= nil) and DLC.REIGN_OF_GIANTS or false
    local CapyDLC = (DLC ~= nil and DLC.CAPY_DLC ~= nil) and DLC.CAPY_DLC or false
    local PorkDLC = (DLC ~= nil and DLC.PORKLAND_DLC ~= nil) and DLC.PORKLAND_DLC or false

    widget.bg = widget.base:AddChild(UIAnim())
    widget.bg:GetAnimState():SetBuild("savetile")
    widget.bg:GetAnimState():SetBank("savetile")
    widget.bg:GetAnimState():PlayAnimation("anim")

    widget.portraitbg = widget.base:AddChild(Image("images/saveslot_portraits.xml", "background.tex"))
    if HasDLC() then
        widget.portraitbg:SetScale(.60, .60, 1)
        if JapaneseOnPS4() then
            widget.portraitbg:SetPosition(-120 + 20, 0, 0)
        else
            widget.portraitbg:SetPosition(-120 + 40, 0, 0)
        end
    else
        widget.portraitbg:SetScale(.65, .65, 1)
        if JapaneseOnPS4() then
            widget.portraitbg:SetPosition(-120 + 20, 2, 0)
        else
            widget.portraitbg:SetPosition(-120 + 40, 2, 0)
        end
    end
    widget.portraitbg:SetClickable(false)

    widget.portrait = widget.base:AddChild(Image())
    widget.portrait:SetClickable(false)
    if character and mode then
        local atlas = (table.contains(MODCHARACTERLIST, character) and "images/saveslot_portraits/" .. character ..
            ".xml") or "images/saveslot_portraits.xml"
        widget.portrait:SetTexture(atlas, character .. ".tex")
    else
        widget.portraitbg:Hide()
    end

    if HasDLC() then
        widget.portrait:SetScale(.60, .60, 1)
        if JapaneseOnPS4() then
            widget.portrait:SetPosition(-120 + 20, 0, 0)
        else
            widget.portrait:SetPosition(-120 + 40, 0, 0)
        end
    else
        widget.portrait:SetScale(.65, .65, 1)
        if JapaneseOnPS4() then
            widget.portrait:SetPosition(-120 + 20, 2, 0)
        else
            widget.portrait:SetPosition(-120 + 40, 2, 0)
        end
    end


    if JapaneseOnPS4() then
        widget.text = widget.base:AddChild(Text(TITLEFONT, 40 * 0.8)) -- KAJ
    else
        widget.text = widget.base:AddChild(Text(TITLEFONT, 40))
    end

    local function SetShield(shield_img)
        widget.dlcindicator = widget.base:AddChild(Image())
        widget.dlcindicator:SetClickable(false)
        widget.dlcindicator:SetTexture("images/ui.xml", shield_img)
        widget.dlcindicator:SetScale(.5, .5, 1)
        widget.dlcindicator:SetPosition(-142, 2, 0)
    end

    if character and mode then
        if PorkDLC then
            SetShield("HAMicon.tex")
        elseif RoG then
            SetShield("DLCicon.tex")
        elseif CapyDLC then
            SetShield("SWicon.tex")
        else
            SetShield("DSicon.tex")
        end

    end

    widget.text = widget.base:AddChild(Text(TITLEFONT, 40))
    widget.text:SetPosition(55, 0, 0)
    widget.text:SetRegionSize(200, 70)

    if not mode then
        widget.text:SetString(STRINGS.UI.LOADGAMESCREEN.NEWGAME)
        widget.text:SetPosition(0, 0, 0)
    elseif mode == "adventure" then
        widget.text:SetString(string.format("%d %s %d-%d", slotnum, STRINGS.UI.LOADGAMESCREEN.ADVENTURE, world, day))
    elseif mode == "survival" then
        widget.text:SetString(string.format("%d %s %d-%d", slotnum, STRINGS.UI.LOADGAMESCREEN.SURVIVAL, world, day))
    elseif mode == "cave" then
        local level = GLOBAL.SaveGameIndex:GetCurrentCaveLevel(slotnum)
        widget.text:SetString(string.format("%d %s %d", slotnum, STRINGS.UI.LOADGAMESCREEN.CAVE, level))
    elseif mode == "shipwrecked" then
        widget.text:SetString(string.format("%d %s %d-%d", slotnum, STRINGS.UI.LOADGAMESCREEN.SHIPWRECKED, world, day))
    elseif mode == "volcano" then
        widget.text:SetString(string.format("%d %s %d-%d", slotnum, STRINGS.UI.LOADGAMESCREEN.VOLCANO, world, day))
    elseif mode == "porkland" then
        widget.text:SetString(string.format("%d %s %d-%d", slotnum, STRINGS.UI.LOADGAMESCREEN.PORKLAND, world, day))
    else
        widget.text:SetString(STRINGS.UI.LOADGAMESCREEN.MODDED)
    end

    widget.text:SetVAlign(ANCHOR_MIDDLE)

    if HasDLC() then
        widget.bg:SetScale(1, .8, 1)
    else
        widget:SetScale(1, 1, 1)
    end

    widget.OnGainFocus = function(self)
        Widget.OnGainFocus(self)
        TheFrontEnd:GetSound():PlaySound("dontstarve/HUD/click_mouseover")
        if HasDLC() then
            widget.bg:SetScale(1.05, .87, 1)
        else
            widget:SetScale(1.1, 1.1, 1)
        end
        widget.bg:GetAnimState():PlayAnimation("over")
    end

    widget.OnLoseFocus = function(self)
        Widget.OnLoseFocus(self)
        widget.base:SetPosition(0, 0, 0)
        if HasDLC() then
            widget.bg:SetScale(1, .8, 1)
        else
            widget:SetScale(1, 1, 1)
        end
        widget.bg:GetAnimState():PlayAnimation("anim")
    end

    local screen = self
    widget.OnControl = function(self, control, down)
        if control == CONTROL_ACCEPT then
            if down then
                widget.base:SetPosition(0, -5, 0)
            else
                widget.base:SetPosition(0, 0, 0)
                screen:OnClickTile(slotnum)
            end
            return true
        end
    end

    widget.GetHelpText = function(self)
        local controller_id = TheInput:GetControllerID()
        local t = {}
        table.insert(t, TheInput:GetLocalizedControl(controller_id, CONTROL_ACCEPT) .. " " .. STRINGS.UI.HELP.SELECT)
        return table.concat(t, "  ")
    end

    return widget
end
