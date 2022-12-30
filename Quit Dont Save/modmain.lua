local GetPlayer = GLOBAL.GetPlayer
local IsGamePurchased = GLOBAL.IsGamePurchased
local PopupDialogScreen = GLOBAL.require "screens/popupdialog"
local STRINGS = GLOBAL.STRINGS
local Vector3 = GLOBAL.Vector3

local function dorestart()
    local postfadefn = function()
        if IsGamePurchased() then
            local player = GetPlayer()
            if player then
                player:PushEvent("quit", {})
            else
                StartNextInstance()
            end
        else
            ShowUpsellScreen(true)
            DEMO_QUITTING = true
        end

        inGamePlay = false
    end

    TheFrontEnd:Fade(false, 1, postfadefn)
end

local function addButtonToPauseScreen(self)
    local function quitButtonExists()
        for k, v in pairs(self.menu.items) do
            if v.text:GetString() == STRINGS.UI.PAUSEMENU.QUIT then
                return true
            end
        end
        return false
    end

    if not quitButtonExists() then
        self.menu:AddItem(STRINGS.UI.PAUSEMENU.QUIT, function()
            self.active = false
            local function doquit()
                self.parent:Disable()
                self.menu:Disable()
                dorestart()
            end

            TheFrontEnd:PushScreen(PopupDialogScreen(STRINGS.UI.PAUSEMENU.QUITTITLE, STRINGS.UI.PAUSEMENU.QUITBODY, {
                { text = STRINGS.UI.PAUSEMENU.QUITYES, cb = doquit },
                { text = STRINGS.UI.PAUSEMENU.QUITNO, cb = function() TheFrontEnd:PopScreen() end }
            }))
        end, Vector3(-160, 65, 0))
    end
end

AddClassPostConstruct("screens/pausescreen", addButtonToPauseScreen)
