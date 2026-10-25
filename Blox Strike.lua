--[[
============================================================
  ZAML BLOXSTRIKE — SCRIPT COMPLETO E ORGANIZADO
  Estrutura: CORE > LIFECYCLE > WINDUI > THEMES > WINDOW > CONFIG
           > STATE > ENTITIES > AIM > MOVEMENT > ANTIAIM > HOOKS
           > KEYBINDS > HITLOG > RENDER > TABS > BOOT
  Discord: https://discord.gg/76tHHGBrfz | @ronzy.exe
============================================================
]]

--============================================================
-- [1] CORE — serviços e referências
--============================================================
local Players      = game:GetService("Players")
local RepStorage   = game:GetService("ReplicatedStorage")
local RunService   = game:GetService("RunService")
local UIS          = game:GetService("UserInputService")
local ContextAct   = game:GetService("ContextActionService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")
local HttpService  = game:GetService("HttpService")
local GuiService   = game:GetService("GuiService")
local Debris       = game:GetService("Debris")

local LP     = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local L      = RepStorage

--============================================================
-- [2] LIFECYCLE — conexões, cleanups, unload
--============================================================
local Lifecycle = { unloaded = false, conns = {}, cleanups = {} }

do
    local function patchEnv(env)
        local orig = type(env) == "table" and rawget(env, "gethui")
        if type(orig) ~= "function" or rawget(env, "zamlhui") then return end
        local ok, hui = pcall(orig)
        if not (ok and typeof(hui) == "Instance" and hui:IsA("LayerCollector")) then return end
        rawset(env, "zamlhui", true)
        rawset(env, "gethui", function()
            local h = orig()
            if typeof(h) == "Instance" and h:IsA("LayerCollector") then
                return h.Parent or game:GetService("CoreGui")
            end
            return h
        end)
    end
    pcall(patchEnv, getfenv and getfenv(1))
    pcall(patchEnv, getgenv and getgenv())
end

do
    local env = (getgenv and getgenv()) or _G
    if type(env.zaml) == "table" and type(env.zaml.unload) == "function" then pcall(env.zaml.unload) end
    if type(env.__zamlbloxUnload) == "function" then pcall(env.__zamlbloxUnload) end

    function Lifecycle.connect(sig, fn)
        local c = sig:Connect(fn)
        local list = Lifecycle.conns
        list[#list + 1] = c
        if #list % 200 == 0 then
            local alive = {}
            for _, x in ipairs(list) do if x.Connected then alive[#alive+1] = x end end
            Lifecycle.conns = alive
        end
        if Lifecycle.unloaded then c:Disconnect() end
        return c
    end

    function Lifecycle.onUnload(fn) Lifecycle.cleanups[#Lifecycle.cleanups+1] = fn end

    function Lifecycle.unload()
        if Lifecycle.unloaded then return end
        Lifecycle.unloaded = true
        for _, c in ipairs(Lifecycle.conns) do pcall(function() c:Disconnect() end) end
        Lifecycle.conns = {}
        for i = #Lifecycle.cleanups, 1, -1 do pcall(Lifecycle.cleanups[i]) end
        Lifecycle.cleanups = {}
        if type(env.zaml) == "table" and env.zaml.unload == Lifecycle.unload then env.zaml = nil end
    end

    env.__zamlbloxUnload = nil
    env.zaml = { unload = Lifecycle.unload }
end

--============================================================
-- [3] WINDUI — loader
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
    local fn, err = loadstring(src, "=windui")
    assert(fn, "[zaml] loadstring falhou: " .. tostring(err))
    local ok, result = pcall(fn)
    assert(ok, "[zaml] exec falhou: " .. tostring(result))
    WindUI = result
end

--============================================================
-- [4] THEMES — paletas
--============================================================
do
    local function hex(s) return Color3.fromHex(s) end
    local function grad(a, b, rot)
        return WindUI:Gradient({
            ["0"]   = { Color = hex(a), Transparency = 0 },
            ["100"] = { Color = hex(b), Transparency = 0 },
        }, { Rotation = rot })
    end
    local palettes = {
        { name="Pink",     bg={"#1A0A14","#2B0D22"}, panel={"#1F0C19","#2A1024"}, accent={"#F472B6","#DB2777"}, text="#FFEAF5", muted="#C98BAE", icon="#F9A8D4", element="#2A1222", hover="#3A1830" },
        { name="Yellow",   bg={"#15120A","#221A06"}, panel={"#1A160B","#241D0A"}, accent={"#FACC15","#CA8A04"}, text="#FFF9E0", muted="#C9B77A", icon="#FDE68A", element="#262011", hover="#332B16" },
        { name="White",    bg={"#FAFAFA","#E9E9EE"}, panel={"#FFFFFF","#F4F4F5"}, accent={"#27272A","#71717A"}, text="#09090B", muted="#71717A", icon="#3F3F46", element="#FFFFFF", hover="#F1F1F3", light=true },
        { name="Black",    bg={"#000000","#0A0A0A"}, panel={"#050505","#0D0D0D"}, accent={"#FFFFFF","#71717A"}, text="#FFFFFF", muted="#8A8A8A", icon="#D4D4D8", element="#111111", hover="#1C1C1C" },
        { name="Orange",   bg={"#170C05","#261206"}, panel={"#1C0F07","#26150A"}, accent={"#FB923C","#EA580C"}, text="#FFF1E6", muted="#C9977A", icon="#FDBA74", element="#28170C", hover="#361F11" },
        { name="Lime",     bg={"#0A1306","#122008"}, panel={"#0D1709","#13210B"}, accent={"#A3E635","#16A34A"}, text="#F1FFE6", muted="#9DBB82", icon="#BEF264", element="#16220F", hover="#1F2E15" },
        { name="Cyan",     bg={"#051317","#072029"}, panel={"#07171C","#0A2029"}, accent={"#22D3EE","#0891B2"}, text="#E6FCFF", muted="#7FB3BF", icon="#67E8F9", element="#0E222A", hover="#142E38" },
        { name="Ocean",    bg={"#050B1A","#0A1733"}, panel={"#08101F","#0C1730"}, accent={"#60A5FA","#2563EB"}, text="#E8F0FF", muted="#8497C9", icon="#93C5FD", element="#101B33", hover="#172545" },
        { name="Grape",    bg={"#0F0719","#1C0D33"}, panel={"#130A1F","#1B0F2E"}, accent={"#C084FC","#7C3AED"}, text="#F5EDFF", muted="#A68CC9", icon="#D8B4FE", element="#1D1230", hover="#281A42" },
        { name="Mint",     bg={"#06130E","#0A2019"}, panel={"#081711","#0B2018"}, accent={"#6EE7B7","#10B981"}, text="#E9FFF6", muted="#86BFA8", icon="#A7F3D0", element="#0F2219", hover="#152E23" },
        { name="Lavender", bg={"#0F0C1A","#1A1530"}, panel={"#131020","#1A162D"}, accent={"#DDD6FE","#A78BFA"}, text="#F4F1FF", muted="#A59CC9", icon="#C4B5FD", element="#1C1830", hover="#262040" },
        { name="Sunset",   bg={"#170812","#260A14"}, panel={"#1B0B14","#240D18"}, accent={"#FB923C","#EC4899"}, text="#FFEFEA", muted="#C98E9A", icon="#FDA4AF", element="#2A1220", hover="#38182A" },
        { name="Synthwave",bg={"#12061F","#07142A"}, panel={"#150A24","#0B1530"}, accent={"#FF2BD6","#22D3EE"}, text="#F9EDFF", muted="#A38CC9", icon="#F0ABFC", element="#1E1233", hover="#2A1A45" },
        { name="Ice",      bg={"#08111A","#0E1B29"}, panel={"#0B141F","#101C2A"}, accent={"#E0F2FE","#38BDF8"}, text="#F0F9FF", muted="#8FB0C9", icon="#BAE6FD", element="#13202E", hover="#1B2C3D" },
    }
    for _, p in ipairs(palettes) do
        local a1, a2 = p.accent[1], p.accent[2]
        local theme = {
            Name = p.name,
            Accent = grad(p.panel[1], p.panel[2], 90),
            Dialog = grad(p.panel[1], p.panel[2], 90),
            Background = grad(p.bg[1], p.bg[2], 135),
            Text = hex(p.text), Placeholder = hex(p.muted), Icon = hex(p.icon),
            Button = grad(a1, a2, 45), Toggle = grad(a1, a2, 45), Checkbox = grad(a1, a2, 45),
            Slider = hex(a1), Primary = hex(a1),
            WindowOutline = WindUI:Gradient({
                ["0"]   = { Color = hex(a1), Transparency = 0 },
                ["50"]  = { Color = hex(a2), Transparency = 0 },
                ["100"] = { Color = hex(a1), Transparency = 0 },
            }, { Rotation = 45 }),
            SliderIcon = hex(p.muted),
            TabBackgroundActive = hex(a1),
            TabBackgroundActiveTransparency = p.light and 0.75 or 0.82,
            TabBackgroundHover = hex(a1),
            TabBackgroundHoverTransparency = p.light and 0.88 or 0.92,
            PanelBackground = hex(p.light and "#000000" or "#FFFFFF"),
            PanelBackgroundTransparency = 0.95,
            ElementBackground = hex(p.element), ElementBackgroundTransparency = 0,
            ElementBackgroundHover = hex(p.hover),
            NotificationBorder = hex(a1), NotificationBorderTransparency = 0.7,
        }
        if p.light then
            theme.TabBackground = hex("#FFFFFF")
            theme.LabelBackground = hex("#FFFFFF")
            theme.LabelBackgroundTransparency = 0
        end
        pcall(function() WindUI:AddTheme(theme) end)
    end
end

--============================================================
-- [5] WINDOW — janela principal
--============================================================
local Window
do
    if setthreadidentity then pcall(setthreadidentity, 8) end
    local icon = (function()
        for _, path in ipairs({ "zaml/zaml.png", "zaml.png" }) do
            if isfile and isfile(path) then
                local ok, asset = pcall(getcustomasset, path)
                if ok and asset then return asset end
            end
        end
        return "crosshair"
    end)()
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
        Title = "zaml", Icon = icon, IconSize = 38, Author = "by amaz",
        Folder = "zaml/bloxstrike",
        Size = UDim2.fromOffset(w, h),
        MinSize = Vector2.new(420, 260), MaxSize = Vector2.new(8192, 8192),
        Theme = "Aurora", Transparent = true, Acrylic = true,
        OutlineTransparency = 0, OutlineThickness = 5,
        OutlineAnimated = true, OutlineSpeed = 90,
        SideBarWidth = 200, HideSearchBar = false, ScrollBarEnabled = true,
        ToggleKey = Enum.KeyCode.K, NewElements = false,
        OpenButton = {
            Title = "zaml", Enabled = true, OnlyMobile = true,
            DragHandle = false, IconSize = 30, StrokeThickness = 5,
            OutlineAnimated = true, OutlineSpeed = 90,
        },
    }
    Window:SetPanelBackground(false)
    Window:OnDestroy(function() Lifecycle.unload() end)

    pcall(function()
        local path = "WindUI/zaml/bloxstrike/config/Zamlblox.json"
        if isfile and isfile(path) then
            local cfg = HttpService:JSONDecode(readfile(path))
            local t = (cfg.__elements or cfg).theme
            local v = type(t) == "table" and t.value
            if type(v) == "table" then v = v[1] end
            if type(v) == "string" and v ~= WindUI:GetCurrentTheme() then WindUI:SetTheme(v) end
        end
    end)
end

--============================================================
-- [6] CONFIG — config manager
--============================================================
local Config
pcall(function()
    Config = Window.ConfigManager:CreateConfig("Zamlblox")
    if Config then Config:SetAsCurrent() end
end)

--============================================================
-- [7] STATE — flags centralizadas
--============================================================
local State = {
    bhop=false, strafe=false, alignDeg=6, strafeMode="Rage",
    fastTurn=true, landBrake=false, longJump=false, boostJump=false,
    duckTicks=12, noSpeedPenalty=false, speed=false, speedLimit=25,
    silentAim=false, fov=120, showFov=true,
    fovColor=Color3.fromRGB(255,255,255), aimPart="Head",
    wallCheck=true, teamCheck=true, minDmg=20,
    minDmgOverride=false, minDmgOverrideValue=5, noSpread=false, noRecoil=false,
    rage=false, rageAutoFire=true, rageAutowall=true, rageHitbox="Head",
    rageMaxDist=math.huge, rapidFire=false, rapidMult=2, rapidUnlimited=false,
    wallbang=false, penMod=false, penValue=10,
    originOn=false, originX=0, originY=0, originZ=0, originMarker=true,
    backtrack=false, backtrackMs=200, forwardTrack=false, forwardMs=100,
    wallLimit=false, maxWalls=1, bulletTp=false, bulletTpDist=2,
    tapKill=false, maxTaps=3, revolverAlt=true, doubleTap=false,
    rageRemote=true, killAll=false, killAllDelay=0.1, loopKill=false,
    loopTarget=nil, knifeKillAll=false, knifeReach=3, killAllWaitRound=true,
    killAllLeadMs=100, rageTargetMode="Distance", preferBodyLethal=true,
    forceBody=false, predictMs=0, rageMulti=false, rageSticky=false,
    rageScanHz=30, missAdapt=false, missesToBody=2, ignoreFriends=false,
    rageIndicator=false,
    aaBase="View", aaManual=nil, aa=false, aaYaw="Backwards", aaSpin=30,
    aaJitter=60, aaJitterDelay=1, aaPitch="Down", aaOffShot=true,
    autoReload=false, instaReload=false, reloadSpeed=3, reloadAt=1, remoteReload=false,
    esp=false, espEnemyColor=Color3.fromRGB(255,60,60), espTeam=false,
    espTeamColor=Color3.fromRGB(60,160,255), espFill=0.6, espNames=true,
    espDistance=true, espChams=true, espChamsOccluded=false, espBox=false,
    espBoxStyle="Corner", espBoxFill=false, espHealth=false, espHealthText=true,
    espArmor=false, espWeapon=false, espSkeleton=false, espHeadDot=false,
    espSnap=false, espSnapFrom="Bottom", espArrows=false, espArrowRadius=220,
    espArrowSize=14, espVisCheck=false, espVisColor=Color3.fromRGB(90,255,120),
    espMaxDist=3000, espTextSize=12, espFlags=false, espDormant=false,
    espDormantTime=4, espFade=0.35, espChamsMode="Glow",
    espColorMode="Enemy / Teammate",
    espTColor=Color3.fromRGB(255,170,60), espCTColor=Color3.fromRGB(80,150,255),
    scopeStyle="Line", scopeColor=Color3.fromRGB(255,255,255),
    scopeLen=60, scopeGap=12, scopeThick=1,
    xhair=false, xhairColor=Color3.fromRGB(0,255,140), xhairLen=6,
    xhairGap=4, xhairThick=2, xhairOutline=true, xhairT=false,
    hitMarker=false, hitMarkerColor=Color3.fromRGB(255,255,255),
    hitMarkerKill=Color3.fromRGB(255,70,90), hitMarkerTime=0.45,
    hitMarkerWhere="Crosshair", hitMarkerAnim="Fade", hitMarkerSize=10,
    hitMarkerShape="X", hitMarkerThick=2, hitMarkerGap=4,
    hitMarkerOutline=true, hitMarkerKillScale=1.4, hitMarkerRise=0,
    hitMarkerDamage=false, dmgNumbers=false,
    dmgColor=Color3.fromRGB(255,220,90), killFx=false,
    killFxColor=Color3.fromRGB(255,70,120), dot=false,
    dotColor=Color3.fromRGB(255,255,255), dotSize=4,
    tracer=false, tracerWidth=0.06, tracerLife=1, impact=false,
    hitSound=false, hitSoundId="3744371342", hitVol=0.6, hitLogs=true,
    killSound=false, killSoundId="3744371342", killVol=1,
    skins=false, float=0.001, statTrak=true, statTrakCount=1337,
    knife=nil, knifeSkin=nil, glove=nil, gloveSkin=nil,
    tracerStyle="Line", tracerFrom="Gun", tracerRainbow=false,
    tracerOnlyHits=false, impactSize=0.35, impactGlow=false,
}

--============================================================
-- [8] ENTITIES — players, zombies, shells
--============================================================
local Entities = { cache = {}, lastFetch = -1, shellCache = setmetatable({}, {__mode="k"}) }

function Entities.getAll()
    local now = os.clock()
    if now - Entities.lastFetch < 0.2 then return Entities.cache end
    Entities.lastFetch = now
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do list[#list+1] = p end
    local horde = workspace:FindFirstChild("HordeShells")
    if horde then
        for _, shell in ipairs(horde:GetChildren()) do
            if shell:IsA("Model") and shell:GetAttribute("HordeId")
               and not shell:GetAttribute("Ragdolled") and shell:FindFirstChild("Head") then
                local proxy = Entities.shellCache[shell]
                if not proxy then
                    proxy = {
                        IsZombie=true, IsBot=true, UserId=0,
                        Name="zombie", DisplayName="zombie",
                        Character=shell, Parent=shell.Parent,
                        GetAttribute=function(_, k) return shell:GetAttribute(k) end,
                    }
                    Entities.shellCache[shell] = proxy
                end
                list[#list+1] = proxy
            end
        end
    end
    Entities.cache = list
    return list
end

function Entities.ownerOf(char)
    for _, p in ipairs(Entities.getAll()) do
        if p.Character == char then return p end
    end
end

function Entities.byName(name)
    for _, p in ipairs(Entities.getAll()) do
        if p.Name == name then return p end
    end
end

--============================================================
-- [9] AIM — wallcheck, screen, target
--============================================================
local Aim = {}
local hitboxList = {
    "Head","UpperTorso","LowerTorso",
    "LeftUpperArm","LeftLowerArm","LeftHand",
    "RightUpperArm","RightLowerArm","RightHand",
    "LeftUpperLeg","LeftLowerLeg","LeftFoot",
    "RightUpperLeg","RightLowerLeg","RightFoot",
}
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

function Aim.findTarget(isValid)
    local center = Camera.ViewportSize / 2
    local best, bestD = nil, State.fov
    for _, p in ipairs(Entities.getAll()) do
        if isValid(p) then
            local char = p.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                local partName = State.aimPart
                local parts = (partName == "Closest to Crosshair" or partName == "Random") and hitboxList or { partName }
                for _, n in ipairs(parts) do
                    local inst = root:FindFirstChild(n)
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
        end
    end
    return best
end

--============================================================
-- [10] MOVEMENT — speed penalty hook
--============================================================
local Movement = { bhopHeld = false, prevGround = false }

function Movement.applySpeedPenaltyHook()
    if Lifecycle.speedPenaltyHooked then return end
    Lifecycle.speedPenaltyHooked = true

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

    local origScoped  = opts.ResolveScopedState
    local origBase    = opts.ResolveBaseMoveSpeed
    local baseCap     = 19.5

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
                speed = math.max(speed, baseCap)
            end
            return speed, extra
        end
    end

    Lifecycle.onUnload(function()
        if origScoped then opts.ResolveScopedState = origScoped end
        if origBase then opts.ResolveBaseMoveSpeed = origBase end
    end)
end

--============================================================
-- [11] ANTIAIM — yaw, pitch, spin, jitter
--============================================================
local AntiAim = { spinAngle=0, jitterTick=0, jitterFlip=false, pitchTick=0, pitchFlip=false }

function AntiAim.resolveYaw(baseYaw)
    local s = State
    if s.aaManual == "Left"  then return baseYaw + math.pi/2 end
    if s.aaManual == "Right" then return baseYaw - math.pi/2 end
    if s.aaManual == "Back"  then return baseYaw + math.pi end
    if s.aaYaw == "Backwards" then return baseYaw + math.pi end
    if s.aaYaw == "Sideways"  then return baseYaw + math.pi/2 end
    if s.aaYaw == "Spin" then
        AntiAim.spinAngle = AntiAim.spinAngle + math.rad(s.aaSpin)
        return AntiAim.spinAngle
    end
    if s.aaYaw == "Jitter" then
        AntiAim.jitterTick = AntiAim.jitterTick + 1
        if AntiAim.jitterTick >= math.max(s.aaJitterDelay, 1) then
            AntiAim.jitterTick = 0
            AntiAim.jitterFlip = not AntiAim.jitterFlip
        end
        return (baseYaw + math.pi) + (AntiAim.jitterFlip and 1 or -1) * math.rad(s.aaJitter)
    end
    return baseYaw
end

function AntiAim.resolvePitch()
    local s = State
    if s.aaPitch == "Down" then return -1 end
    if s.aaPitch == "Up" then return 1 end
    if s.aaPitch == "Jitter" then
        AntiAim.pitchTick = AntiAim.pitchTick + 1
        if AntiAim.pitchTick >= math.max(s.aaJitterDelay, 1) then
            AntiAim.pitchTick = 0
            AntiAim.pitchFlip = not AntiAim.pitchFlip
        end
        return AntiAim.pitchFlip and 1 or -1
    end
end

--============================================================
-- [12] HOOKS — hookfunction wrappers
--============================================================
local Hooks = { originals = {} }

function Hooks.wrap(fn, replacement)
    if isfunctionhooked and restorefunction and isfunctionhooked(fn) then
        pcall(restorefunction, fn)
    end
    Hooks.originals[#Hooks.originals+1] = fn
    return hookfunction(fn, replacement)
end

Lifecycle.onUnload(function()
    if not restorefunction then return end
    for _, f in ipairs(Hooks.originals) do pcall(restorefunction, f) end
end)

--============================================================
-- [13] KEYBINDS — registro e save/load
--============================================================
local Keybinds = { bindings={}, registry={}, held={}, order={}, hovered=nil }

function Keybinds.register(id, element, opts)
    Keybinds.registry[id] = {
        frame    = element and element.ElementFrame,
        kind     = opts.kind,
        setState = opts.setState,
        isActive = opts.isActive,
        fire     = opts.fire,
        title    = opts.title or id,
    }
    Keybinds.order[#Keybinds.order+1] = id
end

function Keybinds.save()
    pcall(function()
        if Config then
            Config:Set("zamlBinds", HttpService:JSONEncode(Keybinds.bindings))
            Config:Save()
        end
    end)
end

function Keybinds.load()
    pcall(function()
        if not Config then return end
        local raw = Config:Get("zamlBinds")
        if raw and raw ~= "" then
            local data = HttpService:JSONDecode(raw)
            if type(data) == "table" then Keybinds.bindings = data end
        end
    end)
end

--============================================================
-- [14] HITLOG — fila de hits
--============================================================
local HitLog = { entries={}, counter=0, frame=nil }

function HitLog.init(parent)
    local holder = Instance.new("Frame")
    holder.Name = "ZamlbloxHitLog"
    holder.AnchorPoint = Vector2.new(0.5, 0)
    holder.Position = UDim2.new(0.5, 0, 0.5, 70)
    holder.AutomaticSize = Enum.AutomaticSize.XY
    holder.BackgroundTransparency = 1
    holder.Parent = parent
    local layout = Instance.new("UIListLayout", holder)
    layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    HitLog.frame = holder
    Lifecycle.onUnload(function() holder:Destroy() end)
end

function HitLog.push(color, text)
    if not State.hitLogs or not HitLog.frame then return end
    HitLog.counter = HitLog.counter + 1
    local label = Instance.new("TextLabel")
    label.LayoutOrder = -HitLog.counter
    label.AutomaticSize = Enum.AutomaticSize.X
    label.Size = UDim2.fromOffset(0, 16)
    label.BackgroundTransparency = 1
    label.Font = Enum.Font.GothamBold
    label.TextSize = 13
    label.TextColor3 = color
    label.TextStrokeColor3 = Color3.new(0,0,0)
    label.TextStrokeTransparency = 0.4
    label.Text = text
    label.Parent = HitLog.frame
    table.insert(HitLog.entries, label)
    while #HitLog.entries > 8 do table.remove(HitLog.entries, 1):Destroy() end
    task.delay(4, function()
        if label.Parent then
            TweenService:Create(label, TweenInfo.new(1), {
                TextTransparency = 1, TextStrokeTransparency = 1,
            }):Play()
            task.delay(1, function() label:Destroy() end)
        end
    end)
end

--============================================================
-- [15] RENDER — overlay (FOV, dot)
--============================================================
local Render = { gui=nil, fov=nil, fovStroke=nil, dot=nil }

function Render.init(parent)
    local gui = Instance.new("ScreenGui")
    gui.Name = "ZamlbloxOverlay"
    gui.IgnoreGuiInset = true
    gui.ResetOnSpawn = false
    gui.DisplayOrder = 999
    gui.Parent = parent

    local fov = Instance.new("Frame")
    fov.AnchorPoint = Vector2.new(0.5,0.5)
    fov.Position = UDim2.fromScale(0.5,0.5)
    fov.BackgroundTransparency = 1
    fov.Visible = false
    fov.Parent = gui
    Instance.new("UICorner", fov).CornerRadius = UDim.new(1,0)
    local fovStroke = Instance.new("UIStroke", fov)
    fovStroke.Transparency, fovStroke.Thickness = 0.35, 1

    local dot = Instance.new("Frame")
    dot.AnchorPoint = Vector2.new(0.5,0.5)
    dot.Position = UDim2.fromScale(0.5,0.5)
    dot.BorderSizePixel = 0
    dot.Visible = false
    dot.Parent = gui
    Instance.new("UICorner", dot).CornerRadius = UDim.new(1,0)
    Instance.new("UIStroke", dot).Color = Color3.new(0,0,0)

    Render.gui, Render.fov, Render.fovStroke, Render.dot = gui, fov, fovStroke, dot
    Lifecycle.onUnload(function() gui:Destroy() end)

    Lifecycle.connect(RunService.RenderStepped, function()
        fov.Visible = State.silentAim and State.showFov
        fov.Size = UDim2.fromOffset(State.fov * 2, State.fov * 2)
        fovStroke.Color = State.fovColor

        dot.Visible = State.dot
        dot.Size = UDim2.fromOffset(State.dotSize, State.dotSize)
        dot.BackgroundColor3 = State.dotColor
    end)
end

--============================================================
-- [16] TABS — preenche o menu com abas e controles
--============================================================
local Tabs = {
    Rage     = Window:Tab({ Title = "Rage", Icon = "crosshair" }),
    Aimbot   = Window:Tab({ Title = "Aimbot", Icon = "target" }),
    Visuals  = Window:Tab({ Title = "Visuals", Icon = "eye" }),
    Movement = Window:Tab({ Title = "Movement", Icon = "wind" }),
    Misc     = Window:Tab({ Title = "Misc", Icon = "settings" }),
    Settings = Window:Tab({ Title = "Settings", Icon = "sliders" }),
}

-- Aimbot
Tabs.Aimbot:Section({ Title = "Aimbot Config" })
Tabs.Aimbot:Toggle({ Title = "Silent Aim", Value = State.silentAim, Callback = function(v) State.silentAim = v end })
Tabs.Aimbot:Slider({ Title = "FOV", Value = { Min = 10, Max = 360, Default = State.fov }, Callback = function(v) State.fov = v end })
Tabs.Aimbot:Dropdown({ Title = "Aim Part", Values = { "Head", "Torso", "Random", "Closest to Crosshair" }, Default = State.aimPart, Callback = function(v) State.aimPart = v end })
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
Tabs.Visuals:Toggle({ Title = "Custom Crosshair", Value = State.xhair, Callback = function(v) State.xhair = v end })
Tabs.Visuals:Toggle({ Title = "Hit Marker", Value = State.hitMarker, Callback = function(v) State.hitMarker = v end })
Tabs.Visuals:Toggle({ Title = "Hit Logs", Value = State.hitLogs, Callback = function(v) State.hitLogs = v end })

-- Rage
Tabs.Rage:Section({ Title = "Ragebot" })
Tabs.Rage:Toggle({ Title = "Enable Rage", Value = State.rage, Callback = function(v) State.rage = v end })
Tabs.Rage:Toggle({ Title = "Auto Wall", Value = State.rageAutowall, Callback = function(v) State.rageAutowall = v end })

-- Misc
Tabs.Misc:Section({ Title = "Anti-Aim" })
Tabs.Misc:Toggle({ Title = "Enable Anti-Aim", Value = State.aa, Callback = function(v) State.aa = v end })
Tabs.Misc:Dropdown({ Title = "Yaw Base", Values = { "View", "At Targets" }, Default = State.aaBase, Callback = function(v) State.aaBase = v end })
Tabs.Misc:Dropdown({ Title = "Yaw Mode", Values = { "Backwards", "Sideways", "Spin", "Jitter" }, Default = State.aaYaw, Callback = function(v) State.aaYaw = v end })

-- Settings
Tabs.Settings:Section({ Title = "Config" })
Tabs.Settings:Button({ Title = "Unload Script", Callback = function() Lifecycle.unload() end })

--============================================================
-- [17] BOOT — monta tudo na ordem
--============================================================
local function boot()
    local guiParent = (gethui and gethui()) or LP:WaitForChild("PlayerGui")
    Render.init(guiParent)
    HitLog.init(Render.gui)
    Keybinds.load()
    Movement.applySpeedPenaltyHook()

    for id, b in pairs(Keybinds.bindings) do
        if b.mode == "Always" then
            local reg = Keybinds.registry[id]
            if reg and reg.kind == "toggle" and reg.setState then reg.setState(true) end
        end
    end
end

boot()

return {
    Lifecycle = Lifecycle,
    State     = State,
    Entities  = Entities,
    Aim       = Aim,
    Movement  = Movement,
    AntiAim   = AntiAim,
    Hooks     = Hooks,
    Keybinds  = Keybinds,
    HitLog    = HitLog,
    Render    = Render,
    Window    = Window,
    Config    = Config,
    unload    = Lifecycle.unload,
}