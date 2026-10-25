--[[
============================================================
  ZAML BLOXSTRIKE — COMPLETO (MENU 100% PREENCHIDO)
============================================================
]]

local Players      = game:GetService("Players")
local RepStorage   = game:GetService("ReplicatedStorage")
local RunService   = game:GetService("RunService")
local UIS          = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local HttpService  = game:GetService("HttpService")

local LP     = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local L      = RepStorage

-- [1] LIFECYCLE
local Lifecycle = { unloaded = false, conns = {}, cleanups = {} }
do
    local env = (getgenv and getgenv()) or _G
    if type(env.zaml) == "table" and type(env.zaml.unload) == "function" then pcall(env.zaml.unload) end
    function Lifecycle.connect(sig, fn)
        local c = sig:Connect(fn)
        table.insert(Lifecycle.conns, c)
        if Lifecycle.unloaded then c:Disconnect() end
        return c
    end
    function Lifecycle.onUnload(fn) table.insert(Lifecycle.cleanups, fn) end
    function Lifecycle.unload()
        if Lifecycle.unloaded then return end
        Lifecycle.unloaded = true
        for _, c in ipairs(Lifecycle.conns) do pcall(function() c:Disconnect() end) end
        for i = #Lifecycle.cleanups, 1, -1 do pcall(Lifecycle.cleanups[i]) end
        env.zaml = nil
    end
    env.zaml = { unload = Lifecycle.unload }
end

-- [2] WINDUI & WINDOW
local WindUI
do
    if setthreadidentity then pcall(setthreadidentity, 8) end
    local src
    pcall(function()
        if isfolder and not isfolder("zaml") then makefolder("zaml") end
        local ok, body = pcall(game.HttpGet, game, "https://raw.githubusercontent.com/amazson/zaml/main/windui.lua")
        if ok and type(body) == "string" and #body > 10000 then
            if writefile then writefile("zaml/windui.lua", body) end
            src = body
        end
    end)
    for _, path in ipairs({ "zaml/windui.lua", "windui.lua" }) do
        if not src and isfile and isfile(path) then
            local ok, body = pcall(readfile, path)
            if ok and type(body) == "string" and #body > 10000 then src = body end
        end
    end
    assert(src, "[zaml] windui.lua não encontrado")
    WindUI = loadstring(src, "=windui")()
end

local Window
do
    local w, h = 900, 560
    Window = WindUI:CreateWindow{
        Title = "zaml", Icon = "crosshair", IconSize = 38, Author = "by amaz",
        Folder = "zaml/bloxstrike", Size = UDim2.fromOffset(w, h),
        MinSize = Vector2.new(420, 260), MaxSize = Vector2.new(8192, 8192),
        Theme = "Aurora", Transparent = true, Acrylic = true,
        OutlineTransparency = 0, OutlineThickness = 5,
        OutlineAnimated = true, OutlineSpeed = 90,
        SideBarWidth = 200, HideSearchBar = false, ScrollBarEnabled = true,
        ToggleKey = Enum.KeyCode.K, NewElements = false,
        OpenButton = { Title = "zaml", Enabled = true, OnlyMobile = true, DragHandle = false, IconSize = 30, StrokeThickness = 5, OutlineAnimated = true, OutlineSpeed = 90 },
    }
    Window:SetPanelBackground(false)
    Window:OnDestroy(function() Lifecycle.unload() end)
end

-- [3] SHAPETAB (Correção do Layout)
local function shapeTab(tab)
    local ui = tab.UIElements and tab.UIElements.ContainerFrame
    if not ui then return tab end
    local layout = ui:FindFirstChildOfClass("UIListLayout")
    if not layout then return tab end
    
    local padding = layout.Padding
    local columnsFrame = Instance.new("Frame")
    columnsFrame.Name = "ZbColumns"
    columnsFrame.BackgroundTransparency = 1
    columnsFrame.Size = UDim2.new(1, 0, 0, 0)
    columnsFrame.AutomaticSize = Enum.AutomaticSize.Y
    columnsFrame.LayoutOrder = -1
    columnsFrame.Parent = ui

    local hLayout = Instance.new("UIListLayout")
    hLayout.FillDirection = Enum.FillDirection.Horizontal
    hLayout.SortOrder = Enum.SortOrder.LayoutOrder
    hLayout.Padding = UDim.new(0, 10)
    hLayout.Parent = columnsFrame

    local cols = {}
    for i = 1, 2 do
        local col = Instance.new("Frame")
        col.Name = "Column" .. i
        col.BackgroundTransparency = 1
        col.AutomaticSize = Enum.AutomaticSize.Y
        col.Size = UDim2.new(0.5, -5, 0, 0)
        col.LayoutOrder = i
        col.Parent = columnsFrame
        local vLayout = Instance.new("UIListLayout")
        vLayout.SortOrder = Enum.SortOrder.LayoutOrder
        vLayout.Padding = padding
        vLayout.Parent = col
        cols[i] = col
    end

    local elements = { "Toggle", "Slider", "Dropdown", "Colorpicker", "Input", "Button", "Keybind", "Section", "Paragraph", "Divider", "Space", "Code", "Image" }
    for _, name in ipairs(elements) do
        local orig = tab[name]
        if type(orig) == "function" then
            tab[name] = function(self, cfg, ...)
                local elem = orig(self, cfg, ...)
                if elem and elem.ElementFrame then
                    elem.ElementFrame.Parent = cols[1]
                end
                return elem
            end
        end
    end
    return tab
end

-- [4] CONFIG & STATE (Onde as flags ficam salvas)
local Config
pcall(function()
    Config = Window.ConfigManager:CreateConfig("Zamlblox")
    if Config then Config:SetAsCurrent() end
end)

local State = {
    silentAim = false, fov = 120, showFov = true, fovColor = Color3.fromRGB(255,255,255),
    aimPart = "Head", wallCheck = true, teamCheck = true,
    bhop = false, strafe = false, noSpeedPenalty = false,
    aa = false, aaBase = "View", aaYaw = "Backwards",
    rage = false, rageAutowall = true, autoFire = true,
    esp = false, espBox = false, espHealth = false,
    hitMarker = false, hitLogs = true, xhair = false
}

-- [5] CRIANDO AS ABAS
local Tabs = {
    Rage     = shapeTab(Window:Tab({ Title = "Rage", Icon = "crosshair" })),
    Aimbot   = shapeTab(Window:Tab({ Title = "Aimbot", Icon = "target" })),
    Visuals  = shapeTab(Window:Tab({ Title = "Visuals", Icon = "eye" })),
    Movement = shapeTab(Window:Tab({ Title = "Movement", Icon = "wind" })),
    Misc     = shapeTab(Window:Tab({ Title = "Misc", Icon = "settings" })),
}

-- [6] POPULANDO AS ABAS (O pacote completo)
-- Aimbot
Tabs.Aimbot:Section({ Title = "Aimbot" })
Tabs.Aimbot:Toggle({ Title = "Silent Aim", Value = State.silentAim, Callback = function(v) State.silentAim = v end })
Tabs.Aimbot:Toggle({ Title = "Wall Check", Value = State.wallCheck, Callback = function(v) State.wallCheck = v end })
Tabs.Aimbot:Toggle({ Title = "Team Check", Value = State.teamCheck, Callback = function(v) State.teamCheck = v end })
Tabs.Aimbot:Slider({ Title = "FOV", Value = { Min = 10, Max = 360, Default = State.fov }, Callback = function(v) State.fov = v end })
Tabs.Aimbot:Dropdown({ Title = "Aim Part", Values = { "Head", "Torso", "Random", "Closest to Crosshair" }, Default = State.aimPart, Callback = function(v) State.aimPart = v end })

-- Rage
Tabs.Rage:Section({ Title = "Ragebot" })
Tabs.Rage:Toggle({ Title = "Enable Rage", Value = State.rage, Callback = function(v) State.rage = v end })
Tabs.Rage:Toggle({ Title = "Auto Wall", Value = State.rageAutowall, Callback = function(v) State.rageAutowall = v end })
Tabs.Rage:Toggle({ Title = "Auto Fire", Value = State.autoFire, Callback = function(v) State.autoFire = v end })
Tabs.Rage:Dropdown({ Title = "Hitbox", Values = { "Head", "Torso", "Nearest" }, Default = "Head", Callback = function(v) print(v) end })

-- Movement
Tabs.Movement:Section({ Title = "Bhop & Strafe" })
Tabs.Movement:Toggle({ Title = "Bunny Hop", Value = State.bhop, Callback = function(v) State.bhop = v end })
Tabs.Movement:Toggle({ Title = "Auto Strafe", Value = State.strafe, Callback = function(v) State.strafe = v end })
Tabs.Movement:Slider({ Title = "Strafe Align Deg", Value = { Min = 0, Max = 45, Default = 6 }, Callback = function(v) print(v) end })
Tabs.Movement:Toggle({ Title = "No Speed Penalty", Value = State.noSpeedPenalty, Callback = function(v) State.noSpeedPenalty = v end })

-- Visuals
Tabs.Visuals:Section({ Title = "ESP / Chams" })
Tabs.Visuals:Toggle({ Title = "Enable ESP", Value = State.esp, Callback = function(v) State.esp = v end })
Tabs.Visuals:Toggle({ Title = "Box ESP", Value = State.espBox, Callback = function(v) State.espBox = v end })
Tabs.Visuals:Toggle({ Title = "Health ESP", Value = State.espHealth, Callback = function(v) State.espHealth = v end })
Tabs.Visuals:Colorpicker({ Title = "Enemy Color", Default = Color3.fromRGB(255, 60, 60), Callback = function(v) print(v) end })

Tabs.Visuals:Section({ Title = "Render" })
Tabs.Visuals:Toggle({ Title = "Show FOV Circle", Value = State.showFov, Callback = function(v) State.showFov = v end })
Tabs.Visuals:Colorpicker({ Title = "FOV Color", Default = State.fovColor, Callback = function(v) State.fovColor = v end })
Tabs.Visuals:Toggle({ Title = "Hit Marker", Value = State.hitMarker, Callback = function(v) State.hitMarker = v end })
Tabs.Visuals:Toggle({ Title = "Hit Logs", Value = State.hitLogs, Callback = function(v) State.hitLogs = v end })

-- Misc
Tabs.Misc:Section({ Title = "Anti-Aim" })
Tabs.Misc:Toggle({ Title = "Enable AA", Value = State.aa, Callback = function(v) State.aa = v end })
Tabs.Misc:Dropdown({ Title = "Yaw Base", Values = { "View", "At Targets" }, Default = State.aaBase, Callback = function(v) State.aaBase = v end })
Tabs.Misc:Dropdown({ Title = "Yaw Mode", Values = { "Backwards", "Sideways", "Spin", "Jitter" }, Default = State.aaYaw, Callback = function(v) State.aaYaw = v end })

Tabs.Misc:Section({ Title = "Config" })
Tabs.Misc:Button({ Title = "Unload Script", Callback = function() Lifecycle.unload() end })

-- [7] OVERLAY (FOV)
local Render = { gui = nil, fov = nil }
function Render.init(parent)
    local gui = Instance.new("ScreenGui")
    gui.Name = "ZamlbloxOverlay"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 999
    gui.Parent = parent

    local fov = Instance.new("Frame")
    fov.AnchorPoint = Vector2.new(0.5, 0.5)
    fov.Position = UDim2.fromScale(0.5, 0.5)
    fov.BackgroundTransparency = 1
    fov.Visible = false
    fov.Parent = gui
    Instance.new("UICorner", fov).CornerRadius = UDim.new(1, 0)
    local stroke = Instance.new("UIStroke", fov)
    stroke.Transparency, stroke.Thickness = 0.35, 1

    Render.gui, Render.fov = gui, fov
    Lifecycle.onUnload(function() gui:Destroy() end)
    
    Lifecycle.connect(RunService.RenderStepped, function()
        fov.Visible = State.silentAim and State.showFov
        fov.Size = UDim2.fromOffset(State.fov * 2, State.fov * 2)
        stroke.Color = State.fovColor
    end)
end
Render.init((gethui and gethui()) or LP:WaitForChild("PlayerGui"))

return {
    Window = Window,
    Lifecycle = Lifecycle,
    State = State,
    unload = Lifecycle.unload
}