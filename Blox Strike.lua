--[[
============================================================
  ZAML BLOXSTRIKE — VERSÃO COMPLETA E DEFINITIVA
  Estrutura: CORE > LIFECYCLE > WINDUI > UI > STATE > FUNCS
  Discord: https://discord.gg/76tHHGBrfz | @ronzy.exe
============================================================
]]

--============================================================
-- [1] CORE & LIFECYCLE
--============================================================
local Players      = game:GetService("Players")
local RepStorage   = game:GetService("ReplicatedStorage")
local RunService   = game:GetService("RunService")
local UIS          = game:GetService("UserInputService")
local ContextAct   = game:GetService("ContextActionService")
local TweenService = game:GetService("TweenService")
local HttpService  = game:GetService("HttpService")

local LP     = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local L      = RepStorage

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

--============================================================
-- [2] WINDUI LOADER
--============================================================
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
    local fn = loadstring(src, "=windui")
    WindUI = fn()
end

--============================================================
-- [3] WINDOW
--============================================================
local Window
do
    local w, h = 900, 560
    pcall(function()
        if isfile and isfile("zaml/bloxstrike/window.json") then
            local data = HttpService:JSONDecode(readfile("zaml/bloxstrike/window.json"))
            if tonumber(data.w) and tonumber(data.h) then
                w, h = math.max(data.w, 420), math.max(data.h, 260)
            end
        end
    end)
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

--============================================================
-- [4] SHAPETAB (A INJEÇÃO DE UI)
--============================================================
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
                    elem.ElementFrame.Parent = cols[1] -- joga tudo na coluna 1
                end
                return elem
            end
        end
    end
    return tab
end

--============================================================
-- [5] CONFIG & STATE
--============================================================
local Config
pcall(function()
    Config = Window.ConfigManager:CreateConfig("Zamlblox")
    if Config then Config:SetAsCurrent() end
end)

local State = {
    silentAim = false, fov = 120, showFov = true, fovColor = Color3.fromRGB(255, 255, 255),
    aimPart = "Head", wallCheck = true, teamCheck = true,
    bhop = false, strafe = false, noSpeedPenalty = false,
    aa = false, aaBase = "View", aaYaw = "Backwards",
    rage = false, rageAutowall = true
}

--============================================================
-- [6] TABS & UI POPULATION
--============================================================
local Tabs = {
    Rage     = shapeTab(Window:Tab({ Title = "Rage", Icon = "crosshair" })),
    Aimbot   = shapeTab(Window:Tab({ Title = "Aimbot", Icon = "target" })),
    Visuals  = shapeTab(Window:Tab({ Title = "Visuals", Icon = "eye" })),
    Movement = shapeTab(Window:Tab({ Title = "Movement", Icon = "wind" })),
    Misc     = shapeTab(Window:Tab({ Title = "Misc", Icon = "settings" })),
}

-- Aimbot
Tabs.Aimbot:Section({ Title = "Aimbot Config" })
Tabs.Aimbot:Toggle({ Title = "Silent Aim", Value = State.silentAim, Callback = function(v) State.silentAim = v end })
Tabs.Aimbot:Slider({ Title = "FOV", Value = { Min = 10, Max = 360, Default = State.fov }, Callback = function(v) State.fov = v end })
Tabs.Aimbot:Dropdown({ Title = "Aim Part", Values = { "Head", "Torso", "Random" }, Default = State.aimPart, Callback = function(v) State.aimPart = v end })
Tabs.Aimbot:Toggle({ Title = "Wall Check", Value = State.wallCheck, Callback = function(v) State.wallCheck = v end })

-- Movement
Tabs.Movement:Section({ Title = "Movement Config" })
Tabs.Movement:Toggle({ Title = "Bunny Hop", Value = State.bhop, Callback = function(v) State.bhop = v end })
Tabs.Movement:Toggle({ Title = "Auto Strafe", Value = State.strafe, Callback = function(v) State.strafe = v end })
Tabs.Movement:Toggle({ Title = "No Speed Penalty", Value = State.noSpeedPenalty, Callback = function(v) State.noSpeedPenalty = v end })

-- Visuals
Tabs.Visuals:Section({ Title = "Render" })
Tabs.Visuals:Toggle({ Title = "Show FOV Circle", Value = State.showFov, Callback = function(v) State.showFov = v end })
Tabs.Visuals:Colorpicker({ Title = "FOV Color", Default = State.fovColor, Callback = function(v) State.fovColor = v end })

-- Rage
Tabs.Rage:Section({ Title = "Ragebot" })
Tabs.Rage:Toggle({ Title = "Enable Rage", Value = State.rage, Callback = function(v) State.rage = v end })
Tabs.Rage:Toggle({ Title = "Auto Wall", Value = State.rageAutowall, Callback = function(v) State.rageAutowall = v end })

-- Misc
Tabs.Misc:Section({ Title = "Anti-Aim" })
Tabs.Misc:Toggle({ Title = "Enable AA", Value = State.aa, Callback = function(v) State.aa = v end })
Tabs.Misc:Button({ Title = "Unload Script", Callback = function() Lifecycle.unload() end })

--============================================================
-- [7] MOTOR: ENTITIES & AIM
--============================================================
local Entities = { cache = {}, lastFetch = -1 }
function Entities.getAll()
    local now = os.clock()
    if now - Entities.lastFetch < 0.2 then return Entities.cache end
    Entities.lastFetch = now
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do table.insert(list, p) end
    Entities.cache = list
    return list
end

local Aim = {}
local aimRay = RaycastParams.new()
aimRay.FilterType = Enum.RaycastFilterType.Exclude
function Aim.visible(part, char)
    if not State.wallCheck then return true end
    local origin = Camera.CFrame.Position
    aimRay.FilterDescendantsInstances = { LP.Character, Camera }
    local r = workspace:Raycast(origin, part.Position - origin, aimRay)
    return r == nil or r.Instance:IsDescendantOf(char)
end

function Aim.toScreen(pos)
    local v, on = Camera:WorldToViewportPoint(pos)
    if not on then return nil end
    return Vector2.new(v.X, v.Y)
end

function Aim.findTarget()
    local center = Camera.ViewportSize / 2
    local best, bestD = nil, State.fov
    for _, p in ipairs(Entities.getAll()) do
        local char = p.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            local inst = root:FindFirstChild(State.aimPart) or root:FindFirstChild("Head")
            if inst then
                local screen = Aim.toScreen(inst.Position)
                if screen then
                    local d = (screen - center).Magnitude
                    if d < bestD and Aim.visible(inst, root) then
                        best, bestD = inst, d
                    end
                end
            end
        end
    end
    return best
end

--============================================================
-- [8] OVERLAY (FOV)
--============================================================
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

--============================================================
-- [9] HOOKS & MOVEMENT (Speed Penalty Fix)
--============================================================
function applySpeedPenaltyHook()
    local target
    for _, v in ipairs(getgc(true)) do
        if type(v) == "table" then
            local ok, acc = pcall(rawget, v, "_accumulatorSeconds")
            if ok and type(acc) == "number" and type(rawget(v, "_options")) == "table" then
                target = v; break
            end
        end
    end
    local opts = target and target._options
    if not opts then return end

    local origScoped = opts.ResolveScopedState
    local origBase = opts.ResolveBaseMoveSpeed
    
    if origScoped then
        opts.ResolveScopedState = function(...)
            if not Lifecycle.unloaded and State.noSpeedPenalty then return false end
            return origScoped(...)
        end
    end
    if origBase then
        opts.ResolveBaseMoveSpeed = function(...)
            local speed, extra = origBase(...)
            if not Lifecycle.unloaded and State.noSpeedPenalty and type(speed) == "number" and speed > 0 then
                speed = math.max(speed, 19.5)
            end
            return speed, extra
        end
    end
end
applySpeedPenaltyHook()

return {
    Window = Window,
    Lifecycle = Lifecycle,
    State = State,
    unload = Lifecycle.unload
}