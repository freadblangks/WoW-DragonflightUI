local DF = LibStub('AceAddon-3.0'):GetAddon('DragonflightUI')
local L = LibStub("AceLocale-3.0"):GetLocale("DragonflightUI")
local mName = 'Config'
local Module = DF:NewModule(mName, 'AceConsole-3.0', 'AceHook-3.0')

Mixin(Module, DragonflightUIModulesMixin)

local defaults = {
    profile = {
        modules = {
            ['Actionbar'] = true,
            ['Bossframe'] = false,
            ['Buffs'] = true,
            ['Castbar'] = true,
            ['Chat'] = false,
            ['Darkmode'] = false,
            ['Minimap'] = true,
            ['UI'] = true,
            ['Unitframe'] = true,
            ['Utility'] = false
        },
        bestnumber = 42
    }
}
Module:SetDefaults(defaults)

local function getDefaultStr(key, sub)
    return Module:GetDefaultStr(key, sub)
end

local function setDefaultValues()
    Module:SetDefaultValues()
end

local function setDefaultSubValues(sub)
    Module:SetDefaultSubValues(sub)
end

local function getOption(info)
    return Module:GetOption(info)
end

local function setOption(info, value)
    Module:SetOption(info, value)
end

local modulesOptions = {
    type = 'group',
    name = 'DragonflightUI - ' .. mName,
    get = getOption,
    set = setOption,
    args = {
        Actionbar = {
            type = 'toggle',
            name = 'Actionbar',
            desc = L["ModuleTooltipActionbar"] .. getDefaultStr('Actionbar', 'modules'),
            order = 1
        },
        Castbar = {
            type = 'toggle',
            name = 'Castbar',
            desc = L["ModuleTooltipCastbar"] .. getDefaultStr('Castbar', 'modules'),
            order = 3,
            new = false
        },
        Chat = {
            type = 'toggle',
            name = 'Chat',
            desc = L["ModuleTooltipChat"] .. getDefaultStr('Chat', 'modules'),
            order = 4
        },
        Buffs = {
            type = 'toggle',
            name = 'Buffs',
            desc = L["ModuleTooltipBuffs"] .. getDefaultStr('Buffs', 'modules'),
            order = 2.1,
            new = false
        },
        Darkmode = {
            type = 'toggle',
            name = 'Darkmode',
            desc = L["ModuleTooltipDarkmode"] .. getDefaultStr('Darkmode', 'modules'),
            order = 4.1,
            new = true
        },
        Minimap = {
            type = 'toggle',
            name = 'Minimap',
            desc = L["ModuleTooltipMinimap"] .. getDefaultStr('Minimap', 'modules'),
            order = 5
        },
        UI = {
            type = 'toggle',
            name = 'UI',
            desc = L["ModuleTooltipUI"] .. getDefaultStr('UI', 'modules'),
            order = 6,
            new = false
        },
        Unitframe = {
            type = 'toggle',
            name = 'Unitframe',
            desc = L["ModuleTooltipUnitframe"] .. getDefaultStr('Unitframe', 'modules'),
            order = 7
        },
        Utility = {
            type = 'toggle',
            name = 'Utility',
            desc = L["ModuleTooltipUtility"] .. getDefaultStr('Utility', 'modules'),
            order = 8,
            new = false
        }
    }
}

if DF.Cata then
    local moreOptions = {
        Bossframe = {
            type = 'toggle',
            name = 'Bossframe',
            desc = L["ModuleTooltipBossframe"] .. getDefaultStr('Bossframe', 'modules'),
            order = 2,
            new = false
        }
    }

    for k, v in pairs(moreOptions) do modulesOptions.args[k] = v end
end

function Module:OnInitialize()
    DF:Debug(self, 'Module ' .. mName .. ' OnInitialize()')
    self.db = DF.db:RegisterNamespace(mName, defaults)

    -- self:SetEnabledState(DF:GetModuleEnabled(mName))
    self:SetEnabledState(true)
    self:SetWasEnabled(true)

    DF.ConfigModule = self
    DF:RegisterModuleOptions(mName, modulesOptions)
end

function Module:OnEnable()
    DF:Debug(self, 'Module ' .. mName .. ' OnEnable()')
    if DF.Wrath then
        Module:Wrath()
    else
        Module:Era()
    end

    Module:ApplySettings()

    DF.ConfigModule:RegisterOptionScreen('General', 'Modules', {
        name = 'Modules',
        sub = 'modules',
        options = modulesOptions,
        default = function()
            setDefaultSubValues('modules')
        end
    })

    self:SecureHook(DF, 'RefreshConfig', function()
        -- print('RefreshConfig', mName)
        Module:ApplySettings()
    end)
end

function Module:OnDisable()
end

function Module:ApplySettings()
    local db = Module.db.profile

    local modules = db.modules

    DF:EnableModule('Profiles')

    for k, v in pairs(modules) do
        -- print(k, v)

        local dfmod = DF:GetModule(k)
        if dfmod then
            if v and not dfmod:GetWasEnabled() then
                if k ~= 'Darkmode' then DF:EnableModule(k) end
            elseif not v and dfmod:GetWasEnabled() then
                DF:Print("Already loaded module was deactivated, please '/reload' !")
            end
        end
    end

    if modules['Darkmode'] then DF:EnableModule('Darkmode') end
end

function Module:GetModuleEnabled(module)
    return self.db.profile.modules[module]
end

--[[ function Module:SetModuleEnabled(module, value)
    print('SetModuleEnabled', module, value)
    local old = self.db.profile.modules[module]
    self.db.profile.modules[module] = value
    if old ~= value then
        if value then
            DF:EnableModule(module)
            print('true')
        else
            DF:DisableModule(module)
            print('false')
        end
        self:Print('/reload')
    end
end ]]

function Module:AddMainMenuButton()
    hooksecurefunc('GameMenuFrame_UpdateVisibleButtons', function(self)
        -- print('GameMenuFrame_UpdateVisibleButtons')
        local blizzHeight = self:GetHeight()

        self:SetHeight(blizzHeight + 22)

        Module.UpdateMainMenuButtons()
    end)

    local btn = CreateFrame('Button', 'DragonflightUIMainMenuButton', GameMenuFrame, 'UIPanelButtonTemplate')
    btn:SetSize(145, 21)
    btn:SetText('DragonflightUI')
    Module.MainMenuButton = btn

    Module.UpdateMainMenuButtons = function()
        local btn = Module.MainMenuButton

        -- TODO:
        -- 'Interface action failed because of an AddOn' when infight and clicking DF Menu button    
        local storeIsRestricted = IsTrialAccount();
        if (C_StorePublic.IsEnabled() and C_StorePublic.HasPurchaseableProducts() and not storeIsRestricted) then
            btn:SetPoint('TOP', GameMenuButtonStore, 'BOTTOM', 0, -16)
        else
            btn:SetPoint('TOP', GameMenuButtonHelp, 'BOTTOM', 0, -16)
        end

        GameMenuButtonOptions:SetPoint('TOP', btn, 'BOTTOM', 0, -1)
    end
    Module.UpdateMainMenuButtons()

    btn:SetScript('OnClick', function()
        ---@diagnostic disable-next-line: missing-parameter
        Module.ToggleConfigFrame()
        -- HideUIPanel(GameMenuFrame)
    end)
end

function Module:AddConfigFrame()
    local config = CreateFrame('Frame', 'DragonflightUIConfigFrame', UIParent, 'DragonflightUIConfigFrameTemplate')
    Module.ConfigFrame = config
    -- config:Show()

    if DF.Cata then
        config:InitQuickKeybind()
    else
        config:InitQuickKeybind()
    end

    _G['DragonflightUIConfigFrame'] = config
    tinsert(UISpecialFrames, 'DragonflightUIConfigFrame')

    Module:RegisterChatCommand('dragonflight', 'SlashCommand')
    Module:RegisterChatCommand('df', 'SlashCommand')

    Module:RegisterChatCommand('kb', 'ToggleQuickKeybindMode')

    -- Module:AddTestConfig()
end

function Module:AddTestConfig()
    local options = {
        name = 'WhatsNew',
        get = function(info)
            return false
        end,
        args = {
            configSize = {type = 'header', name = 'Size', order = 1},
            tog = {type = 'toggle', name = 'toggle me', order = 42},
            selectTest = {
                type = 'select',
                name = 'selectTest',
                desc = 'testing',
                values = {
                    ['TOP'] = 'TOP',
                    ['RIGHT'] = 'RIGHT',
                    ['BOTTOM'] = 'BOTTOM',
                    ['LEFT'] = 'LEFT',
                    ['TOPRIGHT'] = 'TOPRIGHT',
                    ['TOPLEFT'] = 'TOPLEFT',
                    ['BOTTOMLEFT'] = 'BOTTOMLEFT',
                    ['BOTTOMRIGHT'] = 'BOTTOMRIGHT',
                    ['CENTER'] = 'CENTER'
                },
                order = 69
            },
            steptog = {type = 'toggle', name = 'toggle me steptoggler', order = 666}
        }
    }
    local config = {name = 'WhatsNew', options = options}
    Module:RegisterOptionScreen('General', 'WhatsNew', config)
end

function Module:ToggleConfigFrame()
    local configFrame = Module.ConfigFrame

    if configFrame:IsShown() then
        configFrame:Hide()
    else
        configFrame:Show()

        if not InCombatLockdown() then
            HideUIPanel(GameMenuFrame)
            HideUIPanel(SettingsPanel)
        end
    end
end

function Module:SlashCommand()
    Module:ToggleConfigFrame()
end

function Module:ToggleQuickKeybindMode()
    local configFrame = Module.ConfigFrame

    if not configFrame then return end

    if configFrame.QuickKeybind:IsShown() then
        configFrame:ShowQuickKeybind(false)
    else
        configFrame:ShowQuickKeybind(true)
        configFrame:Hide()

        if not InCombatLockdown() then
            HideUIPanel(GameMenuFrame)
            HideUIPanel(SettingsPanel)
        end
    end
end

function Module:RegisterOptionScreen(cat, sub, data)
    -- print('RegisterOptionScreen', cat, sub)
    local config = Module.ConfigFrame

    config.DFCategoryList:SetDisplayData(cat, sub, data)
end

local frame = CreateFrame('FRAME', 'DragonflightUIConfigFrame', UIParent)

function frame:OnEvent(event, arg1)
    -- print('event', event)
    if event == 'PLAYER_ENTERING_WORLD' then end
end
frame:SetScript('OnEvent', frame.OnEvent)

function Module:Wrath()
    Module:AddConfigFrame()
    Module:AddMainMenuButton()

    frame:RegisterEvent('PLAYER_ENTERING_WORLD')
end

function Module:Era()
    Module:Wrath()
end
