local u, L, O = game:GetService'Players', game:GetService'ReplicatedStorage', game:GetService'RunService'
local _ = u.LocalPlayer

do
    local function d(aa)
        local ab = type(aa) == 'table' and rawget(aa, 'gethui')

        if type(ab) ~= 'function' or rawget(aa, 'zamlhui') then
            return
        end

        local ac, ad = pcall(ab)

        if not (ac and (typeof(ad) == 'Instance' and ad:IsA'LayerCollector')) then
            return
        end

        rawset(aa, 'zamlhui', true)
        rawset(aa, 'gethui', function()
            local ae = ab()

            if typeof(ae) == 'Instance' and ae:IsA'LayerCollector' then
                return ae.Parent or game:GetService'CoreGui'
            end

            return ae
        end)
    end

    pcall(d, getfenv and getfenv(1))
    pcall(d, getgenv and getgenv())
end

local aa = {
    unloaded = false,
    conns = {},
    cleanups = {},
}

do
    local ab = getgenv and getgenv() or _G

    if type(ab.zaml) == 'table' and type(ab.zaml.unload) == 'function' then
        pcall(ab.zaml.unload)
    end
    if type(ab.__zamlbloxUnload) == 'function' then
        pcall(ab.__zamlbloxUnload)
    end

    function aa.connect(ac, ad)
        local ae, af = ac:Connect(ad), aa.conns

        af[#af + 1] = ae

        if #af % 200 == 0 then
            local ag = {}

            for ah, ai in ipairs(af)do
                if ai.Connected then
                    ag[#ag + 1] = ai
                end
            end

            aa.conns = ag
        end
        if aa.unloaded then
            ae:Disconnect()
        end

        return ae
    end
    function aa.onUnload(ac)
        aa.cleanups[#aa.cleanups + 1] = ac
    end
    function aa.unload()
        if aa.unloaded then
            return
        end

        aa.unloaded = true

        for ac, ad in ipairs(aa.conns)do
            pcall(function()
                ad:Disconnect()
            end)
        end

        aa.conns = {}

        for ac = #aa.cleanups, 1, -1 do
            pcall(aa.cleanups[ac])
        end

        aa.cleanups = {}

        if type(ab.zaml) == 'table' and ab.zaml.unload == aa.unload then
            ab.zaml = nil
        end
    end

    ab.__zamlbloxUnload = nil
    ab.zaml = {
        unload = aa.unload,
    }
end

local ab = true

do
    local ac, ad = 'ZamlbloxHubHandle', {}

    pcall(function()
        ad[#ad + 1] = game:GetService'CoreGui'
    end)
    pcall(function()
        if gethui then
            ad[#ad + 1] = gethui()
        end
    end)

    for ae, af in ipairs(ad)do
        local ag = af:FindFirstChild(ac)

        if ag and ag:IsA'BindableFunction' then
            pcall(function()
                ag:Invoke()
            end)
            pcall(function()
                ag:Destroy()
            end)
        end
    end

    if setthreadidentity then
        pcall(setthreadidentity, 8)
    end

    local ae = Instance.new'BindableFunction'

    ae.Name = ac
    ae.OnInvoke = function()
        aa.unload()
    end
    ae.Parent = ad[1]

    aa.onUnload(function()
        pcall(function()
            ae:Destroy()
        end)
    end)
end
do
    local ac = {
        WindUI = true,
        ['WindUI/Notifications'] = true,
        ['WindUI/Dropdowns'] = true,
        ['WindUI/Tooltips'] = true,
        ZamlNametags = true,
        ZamlbloxOverlay = true,
        ZamlbloxKeybinds = true,
        ZamlbloxBindPopup = true,
        ZamlbloxNametags = true,
        ZamlbloxSpectators = true,
    }

    local function E(ad)
        if not ad then
            return
        end

        for ae, af in ipairs(ad:GetChildren())do
            if ac[af.Name] then
                pcall(function()
                    af:Destroy()
                end)
            end
        end
    end

    pcall(function()
        E(gethui and gethui())
    end)
    pcall(function()
        E(game:GetService'CoreGui')
    end)
    pcall(function()
        E(_:FindFirstChildOfClass'PlayerGui')
    end)
end

pcall(function()
    if setthreadidentity then
        pcall(setthreadidentity, 8)
    end
    if not (isfolder and (listfiles and (makefolder and isfile))) then
        return
    end

    for ac, ad in ipairs{
        'zaml',
        'zaml/bloxstrike',
        'WindUI',
        'WindUI/zaml',
    }do
        if not isfolder(ad) then
            makefolder(ad)
        end
    end

    if isfile'zaml/bloxstrike/.migrated' then
        return
    end

    local ac = 'Zamlblox'

    local function E(ad, ae)
        if not isfolder(ad) then
            return
        end
        if not isfolder(ae) then
            makefolder(ae)
        end

        for af, ag in ipairs(listfiles(ad))do
            local ah = (ag:gsub('\\', '/')):match'[^/]+$'

            if isfolder(ag) then
                E(ad .. ('/' .. ah), ae .. ('/' .. ah))
            elseif not isfile(ae .. ('/' .. ah)) then
                pcall(function()
                    writefile(ae .. ('/' .. ah), readfile(ag))
                end)
            end
        end
    end

    E(ac, 'zaml/bloxstrike')
    E('WindUI/' .. ac, 'WindUI/zaml/bloxstrike')
    writefile('zaml/bloxstrike/.migrated', '1')
end)

local ac

do
    if setthreadidentity then
        pcall(setthreadidentity, 8)
    end

    local ad

    pcall(function()
        if not isfolder'zaml' then
            makefolder'zaml'
        end

        local ae, af = pcall(game.HttpGet, game, 'https://raw.githubusercontent.com/amazson/zaml/main/windui.lua')

        if ae and (type(af) == 'string' and #af > 10000) then
            writefile('zaml/windui.lua', af)

            ad = af
        end
        if not isfile'zaml/zaml.png' then
            local ag, ah = pcall(game.HttpGet, game, 'https://raw.githubusercontent.com/amazson/zaml/main/zaml.png')

            if ag and (type(ah) == 'string' and ah:sub(2, 4) == 'PNG') then
                writefile('zaml/zaml.png', ah)
            end
        end
    end)

    for ae, af in ipairs{
        'zaml/windui.lua',
        'windui.lua',
    }do
        if not ad and (isfile and isfile(af)) then
            local ag, ah = pcall(readfile, af)

            if ag and (type(ah) == 'string' and #ah > 10000) then
                ad = ah
            end
        end
    end

    if not ad then
        error'[zaml] windui.lua not found next to script'
    end

    local ae, af = loadstring(ad, '=windui')

    if not ae then
        error('[zaml] windui loadstring failed: ' .. tostring(af))
    end

    local ag, ah = pcall(ae)

    if not ag then
        error('[zaml] windui exec failed: ' .. tostring(ah))
    end

    ac = ah
end

(function()
    local function d(ad)
        return Color3.fromHex(ad)
    end
    local function E(ad, ae, af)
        return ac:Gradient({
            ['0'] = {
                Color = d(ad),
                Transparency = 0,
            },
            ['100'] = {
                Color = d(ae),
                Transparency = 0,
            },
        }, {Rotation = af})
    end

    local ad = {
        {
            name = 'Pink',
            bg = {
                '#1A0A14',
                '#2B0D22',
            },
            panel = {
                '#1F0C19',
                '#2A1024',
            },
            accent = {
                '#F472B6',
                '#DB2777',
            },
            text = '#FFEAF5',
            muted = '#C98BAE',
            icon = '#F9A8D4',
            element = '#2A1222',
            hover = '#3A1830',
        },
        {
            name = 'Yellow',
            bg = {
                '#15120A',
                '#221A06',
            },
            panel = {
                '#1A160B',
                '#241D0A',
            },
            accent = {
                '#FACC15',
                '#CA8A04',
            },
            text = '#FFF9E0',
            muted = '#C9B77A',
            icon = '#FDE68A',
            element = '#262011',
            hover = '#332B16',
        },
        {
            name = 'White',
            bg = {
                '#FAFAFA',
                '#E9E9EE',
            },
            panel = {
                '#FFFFFF',
                '#F4F4F5',
            },
            accent = {
                '#27272A',
                '#71717A',
            },
            text = '#09090B',
            muted = '#71717A',
            icon = '#3F3F46',
            element = '#FFFFFF',
            hover = '#F1F1F3',
            light = true,
        },
        {
            name = 'Black',
            bg = {
                '#000000',
                '#0A0A0A',
            },
            panel = {
                '#050505',
                '#0D0D0D',
            },
            accent = {
                '#FFFFFF',
                '#71717A',
            },
            text = '#FFFFFF',
            muted = '#8A8A8A',
            icon = '#D4D4D8',
            element = '#111111',
            hover = '#1C1C1C',
        },
        {
            name = 'Orange',
            bg = {
                '#170C05',
                '#261206',
            },
            panel = {
                '#1C0F07',
                '#26150A',
            },
            accent = {
                '#FB923C',
                '#EA580C',
            },
            text = '#FFF1E6',
            muted = '#C9977A',
            icon = '#FDBA74',
            element = '#28170C',
            hover = '#361F11',
        },
        {
            name = 'Lime',
            bg = {
                '#0A1306',
                '#122008',
            },
            panel = {
                '#0D1709',
                '#13210B',
            },
            accent = {
                '#A3E635',
                '#16A34A',
            },
            text = '#F1FFE6',
            muted = '#9DBB82',
            icon = '#BEF264',
            element = '#16220F',
            hover = '#1F2E15',
        },
        {
            name = 'Cyan',
            bg = {
                '#051317',
                '#072029',
            },
            panel = {
                '#07171C',
                '#0A2029',
            },
            accent = {
                '#22D3EE',
                '#0891B2',
            },
            text = '#E6FCFF',
            muted = '#7FB3BF',
            icon = '#67E8F9',
            element = '#0E222A',
            hover = '#142E38',
        },
        {
            name = 'Ocean',
            bg = {
                '#050B1A',
                '#0A1733',
            },
            panel = {
                '#08101F',
                '#0C1730',
            },
            accent = {
                '#60A5FA',
                '#2563EB',
            },
            text = '#E8F0FF',
            muted = '#8497C9',
            icon = '#93C5FD',
            element = '#101B33',
            hover = '#172545',
        },
        {
            name = 'Grape',
            bg = {
                '#0F0719',
                '#1C0D33',
            },
            panel = {
                '#130A1F',
                '#1B0F2E',
            },
            accent = {
                '#C084FC',
                '#7C3AED',
            },
            text = '#F5EDFF',
            muted = '#A68CC9',
            icon = '#D8B4FE',
            element = '#1D1230',
            hover = '#281A42',
        },
        {
            name = 'Mint',
            bg = {
                '#06130E',
                '#0A2019',
            },
            panel = {
                '#081711',
                '#0B2018',
            },
            accent = {
                '#6EE7B7',
                '#10B981',
            },
            text = '#E9FFF6',
            muted = '#86BFA8',
            icon = '#A7F3D0',
            element = '#0F2219',
            hover = '#152E23',
        },
        {
            name = 'Lavender',
            bg = {
                '#0F0C1A',
                '#1A1530',
            },
            panel = {
                '#131020',
                '#1A162D',
            },
            accent = {
                '#DDD6FE',
                '#A78BFA',
            },
            text = '#F4F1FF',
            muted = '#A59CC9',
            icon = '#C4B5FD',
            element = '#1C1830',
            hover = '#262040',
        },
        {
            name = 'Sunset',
            bg = {
                '#170812',
                '#260A14',
            },
            panel = {
                '#1B0B14',
                '#240D18',
            },
            accent = {
                '#FB923C',
                '#EC4899',
            },
            text = '#FFEFEA',
            muted = '#C98E9A',
            icon = '#FDA4AF',
            element = '#2A1220',
            hover = '#38182A',
        },
        {
            name = 'Synthwave',
            bg = {
                '#12061F',
                '#07142A',
            },
            panel = {
                '#150A24',
                '#0B1530',
            },
            accent = {
                '#FF2BD6',
                '#22D3EE',
            },
            text = '#F9EDFF',
            muted = '#A38CC9',
            icon = '#F0ABFC',
            element = '#1E1233',
            hover = '#2A1A45',
        },
        {
            name = 'Ice',
            bg = {
                '#08111A',
                '#0E1B29',
            },
            panel = {
                '#0B141F',
                '#101C2A',
            },
            accent = {
                '#E0F2FE',
                '#38BDF8',
            },
            text = '#F0F9FF',
            muted = '#8FB0C9',
            icon = '#BAE6FD',
            element = '#13202E',
            hover = '#1B2C3D',
        },
    }

    for ae, af in ipairs(ad)do
        local ag, ah = af.accent[1], af.accent[2]
        local ai = {
            Name = af.name,
            Accent = E(af.panel[1], af.panel[2], 90),
            Dialog = E(af.panel[1], af.panel[2], 90),
            Background = E(af.bg[1], af.bg[2], 135),
            Text = d(af.text),
            Placeholder = d(af.muted),
            Icon = d(af.icon),
            Button = E(ag, ah, 45),
            Toggle = E(ag, ah, 45),
            Checkbox = E(ag, ah, 45),
            Slider = d(ag),
            Primary = d(ag),
            WindowOutline = ac:Gradient({
                ['0'] = {
                    Color = d(ag),
                    Transparency = 0,
                },
                ['50'] = {
                    Color = d(ah),
                    Transparency = 0,
                },
                ['100'] = {
                    Color = d(ag),
                    Transparency = 0,
                },
            }, {Rotation = 45}),
            SliderIcon = d(af.muted),
            TabBackgroundActive = d(ag),
            TabBackgroundActiveTransparency = af.light and 0.75 or 0.82,
            TabBackgroundHover = d(ag),
            TabBackgroundHoverTransparency = af.light and 0.88 or 0.92,
            PanelBackground = d(af.light and '#000000' or '#FFFFFF'),
            PanelBackgroundTransparency = 0.95,
            ElementBackground = d(af.element),
            ElementBackgroundTransparency = 0,
            ElementBackgroundHover = d(af.hover),
            NotificationBorder = d(ag),
            NotificationBorderTransparency = 0.7,
        }

        if af.light then
            ai.TabBackground = d'#FFFFFF'
            ai.LabelBackground = d'#FFFFFF'
            ai.LabelBackgroundTransparency = 0
        end

        pcall(function()
            ac:AddTheme(ai)
        end)
    end
end)()
task.wait()

if setthreadidentity then
    pcall(setthreadidentity, 8)
end

local ad = ac:CreateWindow{
    Title = 'zaml',
    Icon = (function()
        for ad, ae in ipairs{
            'zaml/zaml.png',
            'zaml.png',
        }do
            if isfile and isfile(ae) then
                local af, ag = pcall(getcustomasset, ae)

                if af and ag then
                    return ag
                end
            end
        end

        return 'crosshair'
    end)(),
    IconSize = 38,
    Author = 'by amaz',
    Folder = 'zaml/bloxstrike',
    Size = (function()
        local ad, ae = 900, 560

        pcall(function()
            if isfile and isfile'zaml/bloxstrike/window.json' then
                local af = (game:GetService'HttpService'):JSONDecode(readfile'zaml/bloxstrike/window.json')

                if tonumber(af.w) and tonumber(af.h) then
                    ad, ae = math.max(af.w, 420), math.max(af.h, 260)
                end
            end
        end)

        return UDim2.fromOffset(ad, ae)
    end)(),
    MinSize = Vector2.new(420, 260),
    MaxSize = Vector2.new(8192, 8192),
    Theme = 'Aurora',
    Transparent = true,
    Acrylic = true,
    OutlineTransparency = 0,
    OutlineThickness = 5,
    OutlineAnimated = true,
    OutlineSpeed = 90,
    SideBarWidth = 200,
    HideSearchBar = false,
    ScrollBarEnabled = true,
    ToggleKey = Enum.KeyCode.K,
    NewElements = false,
    OpenButton = {
        Title = 'zaml',
        Enabled = true,
        OnlyMobile = true,
        DragHandle = false,
        IconSize = 30,
        StrokeThickness = 5,
        OutlineAnimated = true,
        OutlineSpeed = 90,
    },
}

ad:SetPanelBackground(false)
ad:OnDestroy(function()
    aa.unload()
end)
task.wait()

if setthreadidentity then
    pcall(setthreadidentity, 8)
end

pcall(function()
    local ae = 'WindUI/zaml/bloxstrike/config/Zamlblox.json'

    if not (isfile and isfile(ae)) then
        return
    end

    local af = (game:GetService'HttpService'):JSONDecode(readfile(ae))
    local ag = (af.__elements or af).theme
    local ah = type(ag) == 'table' and ag.value

    if type(ah) == 'table' then
        ah = ah[1]
    end
    if type(ah) == 'string' and ah ~= ac:GetCurrentTheme() then
        ac:SetTheme(ah)
    end
end)

local ae

pcall(function()
    ae = ad.ConfigManager:CreateConfig'Zamlblox'

    if ae then
        ae:SetAsCurrent()
    end
end)

local af, ag, ah, ai, aj = ae, 'Zamlblox', nil, nil, nil

local function K()
    local ak, al = pcall(function()
        return ad.ConfigManager:AllConfigs()
    end)

    al = (ak and type(al) == 'table') and al or {}

    local am = false

    for an, ao in ipairs(al)do
        if ao == ag then
            am = true

            break
        end
    end

    if not am then
        table.insert(al, ag)
    end

    table.sort(al)

    return al
end

local ak

(function()
    local al, am, an, ao, ap, aq, ar, as, at, au, av, aw = game:GetService'UserInputService', game:GetService'TweenService', game:GetService'TextService', game:GetService'HttpService', Color3.fromRGB(255, 255, 255), {}, {}, {}, {}, nil, nil, {}

    local function a(ax)
        if ax.UserInputType == Enum.UserInputType.Keyboard then
            if ax.KeyCode == Enum.KeyCode.Unknown then
                return nil
            end

            return ax.KeyCode.Name
        elseif ax.UserInputType == Enum.UserInputType.MouseButton1 then
            return 'MouseLeft'
        elseif ax.UserInputType == Enum.UserInputType.MouseButton2 then
            return 'MouseRight'
        elseif ax.UserInputType == Enum.UserInputType.MouseButton3 then
            return 'MouseMiddle'
        end

        return nil
    end

    local ax = ac:Panel{
        Name = 'ZamlbloxKeybinds',
        Title = 'keybinds',
        TitleColor = ap,
        OutlineThickness = 5,
        Size = UDim2.fromOffset(160, 80),
        Position = UDim2.new(0, 16, 0.5, -80),
        AnchorPoint = Vector2.new(0, 0),
        Visible = false,
    }

    do
        local ay = 'zaml/bloxstrike/keybinds_position.json'

        pcall(function()
            if not (isfile and isfile(ay)) then
                return
            end

            local az = ao:JSONDecode(readfile(ay))

            if type(az) ~= 'table' or not (tonumber(az.xs) and (tonumber(az.xo) and (tonumber(az.ys) and tonumber(az.yo)))) then
                return
            end

            local aA = workspace.CurrentCamera.ViewportSize
            local aB, aC = math.clamp(az.xs * aA.X + az.xo, 0, math.max(0, aA.X - 60)), math.clamp(az.ys * aA.Y + az.yo, 0, math.max(0, aA.Y - 40))

            ax.Frame.Position = UDim2.fromOffset(aB, aC)
        end)

        local az = 0

        aa.connect(ax.Frame:GetPropertyChangedSignal'Position', function()
            az = az + 1

            local aA = az

            task.delay(0.4, function()
                if aA ~= az or not writefile then
                    return
                end

                local aB = ax.Frame.Position

                pcall(function()
                    if isfolder and (makefolder and not isfolder'zaml/bloxstrike') then
                        if not isfolder'zaml' then
                            makefolder'zaml'
                        end

                        makefolder'zaml/bloxstrike'
                    end

                    writefile(ay, ao:JSONEncode{
                        xs = aB.X.Scale,
                        xo = aB.X.Offset,
                        ys = aB.Y.Scale,
                        yo = aB.Y.Offset,
                    })
                end)
            end)
        end)
    end

    aa.onUnload(function()
        if au then
            pcall(function()
                au:Destroy()
            end)
        end

        pcall(function()
            ax:Destroy()
        end)
    end)

    local ay = Instance.new'UIListLayout'

    ay.Padding = UDim.new(0, 4)
    ay.SortOrder = Enum.SortOrder.LayoutOrder
    ay.Parent = ax.Content

    local az = Instance.new'UIPadding'

    az.PaddingTop = UDim.new(0, 6)
    az.Parent = ax.Content

    local function e(aA, aB, aC)
        return (an:GetTextSize(aA, aB, aC, Vector2.new(1000, 100))).X
    end

    local aA = {}

    local function o(aB)
        if aA[aB] then
            return aA[aB]
        end

        local aC = Instance.new'Frame'

        aC.Size = UDim2.new(1, 0, 0, 18)
        aC.BackgroundTransparency = 1
        aC.LayoutOrder = aB
        aC.Parent = ax.Content

        local aD = Instance.new'TextLabel'

        aD.Size = UDim2.new(1, -56, 1, 0)
        aD.BackgroundTransparency = 1
        aD.Font = Enum.Font.GothamBold
        aD.TextSize = 14
        aD.TextColor3 = ap
        aD.TextXAlignment = Enum.TextXAlignment.Left
        aD.Parent = aC

        local aE = Instance.new'TextLabel'

        aE.Size = UDim2.new(0, 56, 1, 0)
        aE.Position = UDim2.new(1, -56, 0, 0)
        aE.BackgroundTransparency = 1
        aE.Font = Enum.Font.GothamBold
        aE.TextSize = 14
        aE.TextColor3 = ap
        aE.TextXAlignment = Enum.TextXAlignment.Right
        aE.Parent = aC
        aA[aB] = {
            row = aC,
            label = aD,
            key = aE,
        }

        return aA[aB]
    end
    local function n()
        local aB = {}

        for aC, aD in ipairs(as)do
            local aE, aF = aq[aD], ar[aD]

            if aE and aF then
                local aG

                if aE.mode == 'Always' then
                    aG = true
                elseif aE.mode == 'Hold' then
                    aG = at[aD] == true
                else
                    aG = aF.isActive and aF.isActive() or false
                end
                if aG then
                    aB[#aB + 1] = {
                        name = (tostring(aF.title or aD)):lower(),
                        key = (aE.mode == 'Always' and 'on' or tostring(aE.key)):lower(),
                    }
                end
            end
        end

        return aB
    end
    local function G()
        return ax.Frame:FindFirstChildOfClass'UIStroke'
    end

    local aB, aC, aD = false, 0, {}

    local function Y()
        for aE, aF in ipairs(aD)do
            pcall(function()
                aF:Cancel()
            end)
        end

        aD = {}
    end
    local function H(aE, aF, aG, aH, aI)
        if not aE then
            return nil
        end

        local aJ = am:Create(aE, TweenInfo.new(aF, aH or Enum.EasingStyle.Quint, aI or Enum.EasingDirection.Out), aG)

        aD[#aD + 1] = aJ

        aJ:Play()

        return aJ
    end
    local function i()
        ax.Frame.BackgroundTransparency = 0.1

        local aE = G()

        if aE then
            aE.Transparency = 0
        end
        if ax.Title then
            ax.Title.TextTransparency = 0
        end
    end
    local function B()
        local aE = ab ~= false and n() or {}

        if #aE == 0 then
            if aB then
                aB = false
                aC = aC + 1

                local aF = aC

                Y()

                for aG = 1, #aA, 1 do
                    aA[aG].row.Visible = false
                end

                if ax.Title then
                    H(ax.Title, 0.12, {TextTransparency = 1})
                end

                H(ax.Frame, 0.22, {BackgroundTransparency = 1})

                local aG = G()

                if aG then
                    H(aG, 0.22, {Transparency = 1})
                end

                local aH = H(ax.Frame, 0.28, {
                    Size = UDim2.fromOffset(0, 0),
                }, Enum.EasingStyle.Exponential, Enum.EasingDirection.InOut)

                if aH then
                    aH.Completed:Once(function()
                        if aF == aC then
                            ax:SetVisible(false)
                        end
                    end)
                else
                    ax:SetVisible(false)
                end
            end

            return
        end

        for aF = 1, #aA, 1 do
            aA[aF].row.Visible = false
        end

        local aF = e('Keybinds', 16, Enum.Font.GothamBold)

        for aG, aH in ipairs(aE)do
            local aI = o(aG)

            aI.row.Visible = true
            aI.label.Text = aH.name
            aI.label.TextColor3 = ap
            aI.key.Text = '[' .. (aH.key .. ']')
            aI.key.TextColor3 = ap
            aF = math.max(aF, (e(aH.name, 14, Enum.Font.GothamBold) + 20) + e('[' .. (aH.key .. ']'), 14, Enum.Font.GothamBold))
        end

        local aG, aH = math.clamp(aF + 28, 130, 340), (34 + #aE * 22) + 8

        aC = aC + 1

        Y()

        if not aB then
            aB = true

            ax:SetVisible(true)
            i()

            ax.Frame.Size = UDim2.fromOffset(aG, 0)
        else
            i()
        end

        H(ax.Frame, 0.2, {
            Size = UDim2.fromOffset(aG, aH),
        })
    end
    local function s(aE)
        pcall(function()
            local aF = af or ae

            if not aF then
                return
            end

            aF:Set('zamlBinds', ao:JSONEncode(aq))

            if aE ~= false then
                aF:Save()
            end
        end)
    end
    local function g(aE, aF, aG)
        aq[aE] = {
            key = aF,
            mode = aG,
        }

        local aH = ar[aE]

        if aH and (aG == 'Always' and aH.kind == 'toggle') then
            aH.setState(true)
        end

        s()
        B()
    end
    local function f(aE)
        aq[aE] = nil
        at[aE] = nil

        s()
        B()
    end

    local aE, aF, aG = nil, false, nil

    local function U()
        if aG and aG.Parent then
            return aG
        end
        if setthreadidentity then
            pcall(setthreadidentity, 8)
        end

        aG = Instance.new'ScreenGui'
        aG.Name = 'ZamlbloxBindPopup'
        aG.IgnoreGuiInset = true
        aG.ResetOnSpawn = false
        aG.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        aG.DisplayOrder = 2147483025
        aG.Parent = gethui and gethui() or game:GetService'CoreGui'

        return aG
    end

    aa.onUnload(function()
        if aG then
            pcall(function()
                aG:Destroy()
            end)
        end
    end)

    local aH = game:GetService'GuiService'

    local function m()
        return al:GetMouseLocation() - aH:GetGuiInset()
    end
    local function j(aI, aJ)
        if not (aI and (aI.Parent and aI.Visible)) then
            return false
        end

        local aK, aL = aI.AbsolutePosition, aI.AbsoluteSize

        return aJ.X >= aK.X and (aJ.X <= aK.X + aL.X and (aJ.Y >= aK.Y and aJ.Y <= aK.Y + aL.Y))
    end

    local aI = ac.Creator
    local aJ = aI and aI.Font or 'rbxassetid://12187365364'

    local function F(aK, aL)
        local aM, aN = pcall(function()
            return aI.GetThemeProperty(aK, ac.Theme)
        end)

        if aM then
            if typeof(aN) == 'Color3' then
                return aN
            end
            if type(aN) == 'table' and typeof(aN.Color) == 'ColorSequence' then
                return aN.Color.Keypoints[1].Value, aN
            end
        end

        return aL
    end
    local function t(aK)
        local aL, aM = pcall(function()
            return aI.Icon'chevron-down'
        end)

        if not (aL and (type(aM) == 'table' and aM[1])) then
            return nil
        end

        local aN = Instance.new'ImageLabel'

        aN.BackgroundTransparency = 1
        aN.Image = aM[1]
        aN.ImageRectSize = aM[2].ImageRectSize
        aN.ImageRectOffset = aM[2].ImageRectPosition
        aN.Size = UDim2.fromOffset(14, 14)
        aN.AnchorPoint = Vector2.new(1, 0.5)
        aN.Position = UDim2.new(1, -7, 0.5, 0)
        aN.Parent = aK

        return aN
    end

    local aK, aL, aM, aN, aO = 158, 36, 5, 26, 64
    local aP, aQ = (aK - aO) - aM * 3, {
        'Hold',
        'Toggle',
    }

    local function zT(aR)
        if au then
            pcall(function()
                au:Destroy()
            end)

            au = nil
        end
        if aE then
            aE:Disconnect()

            aE = nil
        end

        aF = false

        local aS = ar[aR]
        local aU = aS and aS.frame

        if typeof(aU) ~= 'Instance' then
            return
        end

        local aV, aW, aX, aY = F('Text', ap), F('Placeholder', Color3.fromRGB(160, 160, 170)), F('Primary', Color3.fromRGB(129, 140, 248)), F('ElementBackground', Color3.fromRGB(30, 30, 38))
        local aZ, a_, a0 = F('ElementBackgroundHover', aY:Lerp(ap, 0.06)), F('Background', Color3.fromRGB(16, 16, 20))

        local function c(a1, a2)
            local a3 = Instance.new'UICorner'

            a3.CornerRadius = UDim.new(0, a2)
            a3.Parent = a1
        end
        local function Q(a1, a2, a3, a4)
            local a5 = Instance.new'UIStroke'

            a5.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
            a5.Color, a5.Transparency, a5.Thickness = a2, a3, a4 or 1
            a5.Parent = a1

            return a5
        end
        local function b(a1)
            a1.BackgroundColor3 = a_
            a1.BackgroundTransparency = 0.02

            if a0 then
                local a2 = Instance.new'UIGradient'

                a2.Color = a0.Color
                a2.Rotation = tonumber(a0.Rotation) or 90
                a2.Parent = a1
            end
        end
        local function T(a1, a2, a3)
            local a4 = Instance.new'TextLabel'

            a4.BackgroundTransparency = 1
            a4.FontFace = Font.new(aJ, a3 or Enum.FontWeight.SemiBold)
            a4.TextSize = 14
            a4.TextColor3 = aV
            a4.Text = a2
            a4.TextTruncate = Enum.TextTruncate.AtEnd
            a4.Parent = a1

            return a4
        end
        local function w(a1, a2, a3)
            local a4 = Instance.new'TextButton'

            a4.AutoButtonColor = false
            a4.Text = ''
            a4.BorderSizePixel = 0
            a4.BackgroundColor3 = aY
            a4.Position = UDim2.fromOffset(a2, aM)
            a4.Size = UDim2.fromOffset(a3, aN)
            a4.Parent = a1

            c(a4, 8)
            aa.connect(a4.MouseEnter, function()
                a4.BackgroundColor3 = aZ
            end)
            aa.connect(a4.MouseLeave, function()
                a4.BackgroundColor3 = aY
            end)

            return a4
        end

        local a1 = Instance.new'Frame'

        a1.Name = 'Popup'
        a1.Size = UDim2.fromOffset(aK, aL)
        a1.BorderSizePixel = 0
        a1.Active = true

        b(a1)
        c(a1, 11)
        Q(a1, aX, 0.55, 1.2)

        local a2 = (aq[aR] and aq[aR].mode == 'Hold') and 'Hold' or 'Toggle'

        local function Z()
            local a3 = aq[aR]

            if not a3 then
                return 'none'
            end
            if a3.mode == 'Always' then
                return 'always'
            end

            return (tostring(a3.key)):lower()
        end

        local a3 = w(a1, aM, aO)
        local a4, a5 = Q(a3, aX, 1, 1.4), T(a3, Z())

        a5.Size = UDim2.fromScale(1, 1)

        local function J()
            a5.Text = Z()
            a5.TextColor3 = aq[aR] and aV or aW
        end

        J()

        local a6 = w(a1, aM * 2 + aO, aP)
        local a7 = T(a6, a2:lower())

        a7.TextXAlignment = Enum.TextXAlignment.Left
        a7.Position = UDim2.fromOffset(9, 0)
        a7.Size = UDim2.new(1, -30, 1, 0)

        local a8 = t(a6)

        if a8 then
            a8.ImageColor3 = aV
        end

        local a9, ba = 24, Instance.new'Frame'

        ba.Position = UDim2.fromOffset(aM * 2 + aO, aL + 4)
        ba.Size = UDim2.fromOffset(aP, (#aQ * a9 + (#aQ - 1) * 2) + 8)
        ba.BorderSizePixel = 0
        ba.Visible = false
        ba.Active = true
        ba.Parent = a1

        b(ba)
        c(ba, 10)
        Q(ba, aX, 0.55, 1.2)

        local bb = {}

        local function s()
            for bc, bd in pairs(bb)do
                local be = bc == a2

                bd.btn.BackgroundColor3 = be and aX or aZ
                bd.btn.BackgroundTransparency = be and 0.8 or bd.hot and 0.4 or 1
                bd.lbl.TextTransparency = be and 0 or 0.4
            end
        end

        for bc, bd in ipairs(aQ)do
            local be = Instance.new'TextButton'

            be.AutoButtonColor = false
            be.Text = ''
            be.BorderSizePixel = 0
            be.Position = UDim2.fromOffset(4, 4 + (bc - 1) * (a9 + 2))
            be.Size = UDim2.new(1, -8, 0, a9)
            be.Parent = ba

            c(be, 7)

            local bf = T(be, bd:lower(), Enum.FontWeight.Medium)

            bf.TextXAlignment = Enum.TextXAlignment.Left
            bf.Position = UDim2.fromOffset(8, 0)
            bf.Size = UDim2.new(1, -8, 1, 0)

            local bg = {
                btn = be,
                lbl = bf,
                hot = false,
            }

            bb[bd] = bg

            aa.connect(be.MouseEnter, function()
                bg.hot = true

                s()
            end)
            aa.connect(be.MouseLeave, function()
                bg.hot = false

                s()
            end)
            aa.connect(be.MouseButton1Click, function()
                a2 = bd
                a7.Text = bd:lower()
                ba.Visible = false

                if a8 then
                    a8.Rotation = 0
                end

                s()

                local bh = aq[aR]

                if bh and (bh.mode ~= bd and bh.key ~= 'ON') then
                    g(aR, bh.key, bd)
                end
            end)
        end

        s()
        aa.connect(a6.MouseButton1Click, function()
            ba.Visible = not ba.Visible

            if a8 then
                a8.Rotation = ba.Visible and 180 or 0
            end
        end)

        local bc, bd

        local function k()
            aF = false

            if aE then
                aE:Disconnect()

                aE = nil
            end

            a4.Transparency = 1
        end
        local function zT()
            k()

            if bc then
                bc:Disconnect()

                bc = nil
            end
            if bd then
                bd:Disconnect()

                bd = nil
            end
            if au == a1 then
                au = nil
            end

            pcall(function()
                a1:Destroy()
            end)
        end

        aa.connect(a3.MouseButton1Click, function()
            if aF then
                k()
                J()

                return
            end

            ba.Visible = false

            if a8 then
                a8.Rotation = 0
            end

            aF = true
            a5.Text = '...'
            a5.TextColor3 = aV
            a4.Transparency = 0.1

            if aE then
                aE:Disconnect()
            end

            aE = aa.connect(al.InputBegan, function(be)
                local bf = be.UserInputType

                if bf == Enum.UserInputType.Keyboard then
                    if be.KeyCode == Enum.KeyCode.Escape or be.KeyCode == Enum.KeyCode.Backspace then
                        f(aR)
                    else
                        local bg = a(be)

                        if not bg then
                            return
                        end

                        g(aR, bg, a2)
                    end
                elseif bf == Enum.UserInputType.MouseButton2 or bf == Enum.UserInputType.MouseButton3 then
                    g(aR, a(be), a2)
                else
                    return
                end

                k()
                J()
            end)
        end)

        local be = U()

        a1.Parent = be
        au = a1

        local function RT()
            if not (aU.Parent and a1.Parent) then
                zT()

                return
            end

            local bf, bg, bh, bi = be.AbsolutePosition, be.AbsoluteSize, aU.AbsolutePosition, aU.AbsoluteSize
            local bj = (bh.X + bi.X) + 8

            if bj + aK > (bf.X + bg.X) - 4 then
                bj = (bh.X - aK) - 8
            end

            local bk = bh.Y + (bi.Y - aL) / 2

            a1.Position = UDim2.fromOffset(bj - bf.X, bk - bf.Y)
        end

        RT()

        bc = aa.connect(O.RenderStepped, RT)
        bd = aa.connect(al.InputBegan, function(bf)
            if au ~= a1 then
                zT()

                return
            end

            local bg = bf.UserInputType

            if bg ~= Enum.UserInputType.MouseButton1 and bg ~= Enum.UserInputType.MouseButton2 then
                return
            end
            if aF and bg == Enum.UserInputType.MouseButton2 then
                return
            end

            local bh = m()

            if not j(a1, bh) and not j(ba, bh) then
                zT()
            end
        end)
    end

    aa.connect(al.InputBegan, function(aR)
        if aR.UserInputType == Enum.UserInputType.MouseButton3 and (av and not aF) then
            zT(av)
        end
    end)
    aa.connect(al.InputBegan, function(aR, aS)
        if aF or al:GetFocusedTextBox() then
            return
        end
        if aS and aR.UserInputType ~= Enum.UserInputType.Keyboard then
            return
        end

        local aU = a(aR)

        if not aU then
            return
        end

        for aV, aW in pairs(aq)do
            if aW.key == aU and aW.mode ~= 'Always' then
                local aX = ar[aV]

                if aX then
                    if aW.mode == 'Toggle' then
                        if aX.kind == 'toggle' then
                            aX.setState(not aX.isActive())
                        else
                            aX.fire()
                        end

                        B()
                    elseif aW.mode == 'Hold' then
                        at[aV] = true

                        if aX.kind == 'toggle' then
                            aX.setState(true)
                        else
                            aX.fire()
                        end

                        B()
                    end
                end
            end
        end
    end)
    aa.connect(al.InputEnded, function(aR)
        local aS = a(aR)

        if not aS then
            return
        end

        for aU, aV in pairs(aq)do
            if aV.key == aS and (aV.mode == 'Hold' and at[aU]) then
                at[aU] = false

                local aW = ar[aU]

                if aW and aW.kind == 'toggle' then
                    aW.setState(false)
                end

                B()
            end
        end
    end)

    local aR = 0

    aa.connect(O.RenderStepped, function()
        if au and (ad.Closed or ad.Destroyed) then
            if aE then
                aE:Disconnect()

                aE = nil
            end

            pcall(function()
                au:Destroy()
            end)

            au = nil
        end

        for aS, aU in pairs(aq)do
            local aV = ar[aS]

            if aV then
                if aU.mode == 'Always' then
                    if aV.kind == 'toggle' then
                        if aV.isActive and not aV.isActive() then
                            aV.setState(true)
                        end
                    elseif aV.fire then
                        aV.fire()
                    end
                elseif aU.mode == 'Hold' and (at[aS] and (aV.kind == 'button' and aV.fire)) then
                    aV.fire()
                end
            end
        end

        if os.clock() - aR >= 0.3 then
            aR = os.clock()

            B()
        end
    end)

    ak = {}

    function ak.register(aS, aU, aV)
        if type(aU) == 'table' then
            if aV.auto then
                aU.__zbAuto = aS
            elseif aU.__zbAuto and aU.__zbAuto ~= aS then
                local aW = aU.__zbAuto

                aw[aW] = aS
                ar[aW] = nil

                for aX = #as, 1, -1 do
                    if as[aX] == aW then
                        table.remove(as, aX)
                    end
                end
            end
        end

        ar[aS] = {
            frame = aU and aU.ElementFrame,
            kind = aV.kind,
            setState = aV.setState,
            isActive = aV.isActive,
            fire = aV.fire,
            title = aV.title or aS,
        }
        as[#as + 1] = aS

        if aU and aU.ElementFrame then
            local aW = aU.ElementFrame

            aa.connect(aW.MouseEnter, function()
                av = aw[aS] or aS
            end)
            aa.connect(aW.MouseLeave, function()
                if av == aS or av == aw[aS] then
                    av = nil
                end
            end)
        end
    end
    function ak.loadBinds()
        local aS = {}

        pcall(function()
            local aU = af or ae

            if aU then
                local aV = aU:Get'zamlBinds'

                if aV and aV ~= '' then
                    local aW = ao:JSONDecode(aV)

                    if type(aW) == 'table' then
                        aS = aW
                    end
                end
            end
        end)

        aq = aS

        table.clear(at)

        for aU, aV in pairs(aq)do
            if aV.mode == 'Always' then
                local aW = ar[aU]

                if aW and (aW.kind == 'toggle' and aW.setState) then
                    aW.setState(true)
                end
            end
        end

        B()
    end
    function ak.refresh()
        B()
    end
    function ak.saveBinds(aS)
        s(aS)
    end
end)()

do
    local al, am, an, ao, ap, aq, ar, as = game:GetService'UserInputService', game:GetService'TextService', game:GetService'HttpService', {
        'Toggle',
        'Slider',
        'Dropdown',
        'Colorpicker',
        'Input',
        'Button',
        'Keybind',
        'Section',
        'Paragraph',
        'Divider',
        'Space',
        'Code',
        'Image',
    }, {
        Toggle = true,
        Slider = true,
        Dropdown = true,
        Colorpicker = true,
        Input = true,
        Button = true,
        Keybind = true,
    }, {
        Toggle = 1,
        Button = 1,
        Slider = 1.5,
        Dropdown = 1.2,
        Colorpicker = 1,
        Input = 1.2,
        Keybind = 1,
        Section = 1,
        Paragraph = 2,
    }, 440, ad.UIElements and ad.UIElements.Main
    local at, au = as and as:FindFirstAncestorOfClass'ScreenGui', Instance.new'Frame'

    au.Name = 'ZamlbloxTip'
    au.BackgroundColor3 = Color3.fromRGB(13, 13, 17)
    au.BackgroundTransparency = 0.04
    au.BorderSizePixel = 0
    au.Visible = false
    au.ZIndex = 100000
    au.Parent = at;
    (Instance.new('UICorner', au)).CornerRadius = UDim.new(0, 6)

    local av = Instance.new('UIStroke', au)

    av.Color = Color3.new(1, 1, 1)
    av.Transparency = 0.8

    local aw = Instance.new'TextLabel'

    aw.BackgroundTransparency = 1
    aw.Position = UDim2.fromOffset(8, 6)
    aw.Font = Enum.Font.GothamMedium
    aw.TextSize = 13
    aw.TextColor3 = Color3.fromRGB(230, 230, 235)
    aw.TextWrapped = true
    aw.TextXAlignment = Enum.TextXAlignment.Left
    aw.TextYAlignment = Enum.TextYAlignment.Top
    aw.ZIndex = 100001
    aw.Parent = au

    aa.onUnload(function()
        au:Destroy()
    end)

    local ax

    local function Q(ay, az)
        ax = ay

        local aA = am:GetTextSize(az, 13, Enum.Font.GothamMedium, Vector2.new(260, 1000))

        aw.Text = az
        aw.Size = UDim2.fromOffset(aA.X + 2, aA.Y + 2)
        au.Size = UDim2.fromOffset(aA.X + 18, aA.Y + 14)
        au.Visible = true
    end
    local function b(ay)
        if ax == ay then
            ax = nil
            au.Visible = false
        end
    end

    aa.connect(O.RenderStepped, function()
        if not au.Visible then
            return
        end
        if not (ax and ax:IsDescendantOf(game)) or ad.Closed then
            ax, au.Visible = nil, false

            return
        end

        local ay, az, aA, aB = al:GetMouseLocation(), at and at.AbsolutePosition or Vector2.new(0, 0), (at and at.IgnoreGuiInset) and Vector2.new(0, 0) or (game:GetService'GuiService'):GetGuiInset(), workspace.CurrentCamera.ViewportSize
        local aC, aD = math.min(ay.X + 14, (aB.X - au.AbsoluteSize.X) - 4), math.min(ay.Y + 16, (aB.Y - au.AbsoluteSize.Y) - 4)

        au.Position = UDim2.fromOffset((aC - az.X) - aA.X, (aD - az.Y) - aA.Y)
    end)

    local function a(ay, az)
        local aA = ay:FindFirstChild('TitleFrame', true)
        local aB = aA and aA:FindFirstChild'TitleFrame'
        local aC = aB and aB:FindFirstChildOfClass'TextLabel'

        if not aC then
            return false
        end

        local aD = Instance.new'UIPadding'

        aD.PaddingLeft = UDim.new(0, 22)
        aD.Parent = aC

        local aE = Instance.new'TextLabel'

        aE.Name = 'Info'
        aE.Size = UDim2.fromOffset(15, 15)
        aE.Position = UDim2.fromOffset(-22, 1)
        aE.BackgroundTransparency = 1
        aE.Font = Enum.Font.GothamBold
        aE.TextSize = 11
        aE.Text = 'i'
        aE.TextColor3 = aC.TextColor3
        aE.TextTransparency = 0.25
        aE.Active = true
        aE.ZIndex = aC.ZIndex + 1
        aE.Parent = aC;
        (Instance.new('UICorner', aE)).CornerRadius = UDim.new(1, 0)

        local aF = Instance.new('UIStroke', aE)

        aF.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        aF.Thickness = 1.2
        aF.Color = aC.TextColor3
        aF.Transparency = 0.45

        aa.connect(aC:GetPropertyChangedSignal'TextColor3', function()
            aE.TextColor3, aF.Color = aC.TextColor3, aC.TextColor3
        end)
        aa.connect(aE.MouseEnter, function()
            aE.TextTransparency, aF.Transparency = 0, 0.1

            Q(aE, az)
        end)
        aa.connect(aE.MouseLeave, function()
            aE.TextTransparency, aF.Transparency = 0.25, 0.45

            b(aE)
        end)

        return true
    end

    local ay = {}

    function ak.shapeTab(az, aA)
        if type(az) ~= 'table' or ay[az] then
            return az
        end

        local aB = {
            col = 1,
            weight = {0, 0},
        }

        ay[az] = aB

        local function M()
            if aB.cols then
                return aB.cols
            end

            local aC = az.UIElements and az.UIElements.ContainerFrame

            if not aC then
                return nil
            end

            local aD = aC:FindFirstChildOfClass'UIListLayout'

            if not aD then
                return nil
            end

            local aE, aF = aD.Padding, Instance.new'Frame'

            aF.Name = 'ZbColumns'
            aF.BackgroundTransparency = 1
            aF.Size = UDim2.new(1, 0, 0, 0)
            aF.AutomaticSize = Enum.AutomaticSize.Y
            aF.LayoutOrder = -1
            aF.Parent = aC

            local aG = Instance.new'UIListLayout'

            aG.FillDirection = Enum.FillDirection.Horizontal
            aG.SortOrder = Enum.SortOrder.LayoutOrder
            aG.Padding = UDim.new(0, 10)
            aG.Parent = aF

            local aH = {}

            for aI = 1, 2, 1 do
                local aJ = Instance.new'Frame'

                aJ.Name = 'Column' .. aI
                aJ.BackgroundTransparency = 1
                aJ.AutomaticSize = Enum.AutomaticSize.Y
                aJ.LayoutOrder = aI
                aJ.Parent = aF

                local aK = Instance.new'UIListLayout'

                aK.SortOrder = Enum.SortOrder.LayoutOrder
                aK.Padding = aE
                aK.Parent = aJ
                aH[aI] = aJ
            end

            local aI

            local function P()
                local aJ = aC.AbsoluteSize.X < ar

                if aJ == aI then
                    return
                end

                aI = aJ
                aG.FillDirection = aJ and Enum.FillDirection.Vertical or Enum.FillDirection.Horizontal

                for aK = 1, 2, 1 do
                    aH[aK].Size = aJ and UDim2.new(1, 0, 0, 0) or UDim2.new(0.5, 
-5, 0, 0)
                end
            end

            P()
            aa.connect(aC:GetPropertyChangedSignal'AbsoluteSize', P)

            aB.cols = aH

            return aH
        end

        for aC, aD in ipairs(ao)do
            local aE = az[aD]

            if type(aE) == 'function' then
                az[aD] = function(aF, aG, ...)
                    local aH, aI = type(aG) == 'table', nil

                    if aH and (ap[aD] and (type(aG.Desc) == 'string' and aG.Desc ~= '')) then
                        aI = aG.Desc
                        aG.Desc = nil
                    end

                    local aJ, aK = false, aH and aG.Callback or nil

                    if aH and aD == 'Toggle' then
                        aJ = aG.Value == true
                        aG.Callback = function(aL, ...)
                            aJ = aL == true

                            if aK then
                                return aK(aL, ...)
                            end
                        end
                    end

                    local aL = aE(aF, aG, ...)
                    local aM = type(aL) == 'table' and aL.ElementFrame

                    aa.breathe()

                    if typeof(aM) ~= 'Instance' then
                        return aL
                    end

                    local aN = M()

                    if aN then
                        if aD == 'Section' then
                            aB.col = aB.weight[2] < aB.weight[1] and 2 or 1
                        end

                        aB.weight[aB.col] = aB.weight[aB.col] + (aq[aD] or 1)
                        aM.Parent = aN[aB.col]
                    end
                    if aI and not a(aM, aI) then
                        pcall(function()
                            aL:SetDesc(aI)
                        end)
                    end
                    if aD == 'Colorpicker' and (aH and (type(aK) == 'function' and type(aL.Update) == 'function')) then
                        local aO = aL.Update

                        aL.Update = function(aP, aQ, aR, ...)
                            local aS = aO(aP, aQ, aR, ...)

                            if typeof(aQ) == 'Color3' then
                                pcall(aK, aQ, aR)
                            end

                            return aS
                        end
                    end
                    if aH and (type(aG.Title) == 'string' and (aD == 'Toggle' or aD == 'Button')) then
                        local aO = 'auto:' .. (type(aG.Flag) == 'string' and aG.Flag or tostring(aA) .. ('/' .. aG.Title))

                        if aD == 'Toggle' then
                            ak.register(aO, aL, {
                                auto = true,
                                kind = 'toggle',
                                title = aG.Title,
                                isActive = function()
                                    return aJ
                                end,
                                setState = function(aP)
                                    pcall(function()
                                        aL:Set(aP)
                                    end)

                                    if aJ ~= aP then
                                        aG.Callback(aP)
                                    end
                                end,
                            })
                        elseif type(aK) == 'function' then
                            ak.register(aO, aL, {
                                auto = true,
                                kind = 'button',
                                title = aG.Title,
                                fire = function()
                                    aK()
                                end,
                            })
                        end
                    end

                    return aL
                end
            end
        end

        return az
    end

    aa.building = true
    aa.lastBreath = os.clock()

    function aa.breathe()
        if not aa.building or os.clock() - aa.lastBreath < 0.005 or not coroutine.isyieldable() then
            return
        end

        task.wait()

        if setthreadidentity then
            pcall(setthreadidentity, 8)
        end

        aa.lastBreath = os.clock()
    end

    do
        local az

        pcall(function()
            az = require(L.Controllers.CameraController)
        end)

        local aA = false

        local function x(aB)
            if aB == aA then
                return
            end

            aA = aB

            if az and type(az.setForceLockOverride) == 'function' then
                pcall(az.setForceLockOverride, 'zaml', aB)
            else
                pcall(function()
                    al.MouseBehavior = aB and Enum.MouseBehavior.Default or Enum.MouseBehavior.LockCenter
                    al.MouseIconEnabled = aB
                end)
            end
        end

        aa.connect(O.RenderStepped, function()
            local aB = not aa.unloaded and (not ad.Closed and (not ad.Destroyed and (as ~= nil and as.Visible)))

            if aB and (aA and (al.MouseBehavior ~= Enum.MouseBehavior.Default or not al.MouseIconEnabled)) then
                aA = false
            end

            x(aB)
        end)
        aa.onUnload(function()
            x(false)
        end)

        if as then
            local aB = Instance.new'TextButton'

            aB.Name = 'ZamlbloxModal'
            aB.Size = UDim2.fromOffset(0, 0)
            aB.BackgroundTransparency = 1
            aB.Text = ''
            aB.Modal = true
            aB.Parent = as
        end
    end

    local az = ad.Tab

    ad.Tab = function(aA, aB, ...)
        local aC = az(aA, aB, ...)

        return ak.shapeTab(aC, type(aB) == 'table' and aB.Title or '?')
    end

    local aA

    if as then
        for aB, aC in ipairs(as:GetDescendants())do
            if aC:IsA'ImageLabel' and aC.Image == 'rbxassetid://120997033468887' then
                aA = aC.Parent

                break
            end
        end
    end
    if aA then
        pcall(function()
            ad:IsResizable(false)
        end)

        local aB, aC, aD = 420, 260, nil

        aa.connect(aA.InputBegan, function(aE)
            if aE.UserInputType ~= Enum.UserInputType.MouseButton1 or aD then
                return
            end

            aD = {
                mouse = al:GetMouseLocation(),
                w = as.Size.X.Offset,
                h = as.Size.Y.Offset,
                pos = as.Position,
                frozen = {},
            }

            local aF = ad.UIElements.MainBar

            if aF then
                for aG, aH in ipairs(aF:GetChildren())do
                    if aH:IsA'Frame' and not aH.Visible then
                        aD.frozen[aH] = aH.Size
                        aH.Size = UDim2.fromOffset(aH.AbsoluteSize.X, aH.AbsoluteSize.Y)
                    end
                end
            end
        end)
        aa.connect(O.RenderStepped, function()
            if not aD then
                return
            end

            local aE = al:GetMouseLocation()

            if aE == aD.last then
                return
            end

            aD.last = aE

            local aF = workspace.CurrentCamera.ViewportSize
            local aG, aH = math.clamp(aD.w + (aE.X - aD.mouse.X), aB, math.max(aB, aF.X)), math.clamp(aD.h + (aE.Y - aD.mouse.Y), aC, math.max(aC, aF.Y))

            as.Size = UDim2.fromOffset(aG, aH)
            as.Position = aD.pos + UDim2.fromOffset((aG - aD.w) / 2, (aH - aD.h) / 2)
            ad.Size = as.Size
        end)
        aa.connect(al.InputEnded, function(aE)
            if aE.UserInputType ~= Enum.UserInputType.MouseButton1 or not aD then
                return
            end

            for aF, aG in pairs(aD.frozen)do
                pcall(function()
                    aF.Size = aG
                end)
            end

            aD = nil

            pcall(function()
                if isfolder and (makefolder and not isfolder'zaml/bloxstrike') then
                    if not isfolder'zaml' then
                        makefolder'zaml'
                    end

                    makefolder'zaml/bloxstrike'
                end

                writefile('zaml/bloxstrike/window.json', an:JSONEncode{
                    w = as.Size.X.Offset,
                    h = as.Size.Y.Offset,
                })
            end)
        end)
    end
end

local al, am = hookfunction, {}

local function Q(an, ao)
    if isfunctionhooked and (restorefunction and isfunctionhooked(an)) then
        pcall(restorefunction, an)
    end

    am[#am + 1] = an

    return al(an, ao)
end

aa.onUnload(function()
    if not restorefunction then
        return
    end

    for an, ao in ipairs(am)do
        pcall(restorefunction, ao)
    end
end)

do
    local an = require(L.Components.Weapon.Classes.Bullet)

    if isfunctionhooked and (restorefunction and isfunctionhooked(an._performRaycast)) then
        pcall(restorefunction, an._performRaycast)
    end
end

local an, ao, ap, aq, ar, as, at, au, av, aw, ax = game:GetService'UserInputService', game:GetService'ContextActionService', game:GetService'TweenService', game:GetService'SoundService', game:GetService'HttpService', game:GetService'Debris', workspace.CurrentCamera, require(L.Controllers.CharacterController), require(L.Controllers.CameraController), require(L.Controllers.InventoryController), require(L.Classes.Character)

local function p()
    local ay, az = pcall(debug.getupvalue, aw.getInventorySlot, 1)

    if ay and type(az) == 'table' then
        return rawget(az, 'CurrentEquipped')
    end

    return nil
end

local ay, az, aA, aB, aC, aD = require(L.MovementV2.Simulation.Config), require(L.Database.Components.Libraries.Skins), require(L.Classes.WeaponComponent.Classes.Viewmodel), L.Database.Custom.Weapons, {
    bhop = false,
    strafe = false,
    alignDeg = 6,
    strafeMode = 'Rage',
    fastTurn = true,
    landBrake = false,
    longJump = false,
    boostJump = false,
    duckTicks = 12,
    noSpeedPenalty = false,
    speed = false,
    speedLimit = 25,
    silentAim = false,
    fov = 120,
    showFov = true,
    fovColor = Color3.fromRGB(255, 255, 255),
    aimPart = 'Head',
    wallCheck = true,
    teamCheck = true,
    minDmg = 20,
    minDmgOverride = false,
    minDmgOverrideValue = 5,
    noSpread = false,
    noRecoil = false,
    rage = false,
    rageAutoFire = true,
    rageAutowall = true,
    rageHitbox = 'Head',
    rageMaxDist = math.huge,
    rapidFire = false,
    rapidMult = 2,
    rapidUnlimited = false,
    wallbang = false,
    penMod = false,
    penValue = 10,
    originOn = false,
    originX = 0,
    originY = 0,
    originZ = 0,
    originMarker = true,
    backtrack = false,
    backtrackMs = 200,
    forwardTrack = false,
    forwardMs = 100,
    wallLimit = false,
    maxWalls = 1,
    bulletTp = false,
    bulletTpDist = 2,
    tapKill = false,
    maxTaps = 3,
    revolverAlt = true,
    doubleTap = false,
    rageRemote = true,
    killAll = false,
    killAllDelay = 0.1,
    loopKill = false,
    loopTarget = nil,
    knifeKillAll = false,
    knifeReach = 3,
    killAllWaitRound = true,
    killAllLeadMs = 100,
    rageTargetMode = 'Distance',
    preferBodyLethal = true,
    forceBody = false,
    predictMs = 0,
    rageMulti = false,
    rageSticky = false,
    rageScanHz = 30,
    missAdapt = false,
    missesToBody = 2,
    ignoreFriends = false,
    rageIndicator = false,
    aaBase = 'View',
    aaManual = nil,
    aa = false,
    aaYaw = 'Backwards',
    aaSpin = 30,
    aaJitter = 60,
    aaJitterDelay = 1,
    aaPitch = 'Down',
    aaOffShot = true,
    autoReload = false,
    instaReload = false,
    reloadSpeed = 3,
    reloadAt = 1,
    remoteReload = false,
    esp = false,
    espEnemyColor = Color3.fromRGB(255, 60, 60),
    espTeam = false,
    espTeamColor = Color3.fromRGB(60, 160, 255),
    espFill = 0.6,
    espNames = true,
    espDistance = true,
    espChams = true,
    espChamsOccluded = false,
    espBox = false,
    espBoxStyle = 'Corner',
    espBoxFill = false,
    espHealth = false,
    espHealthText = true,
    espArmor = false,
    espWeapon = false,
    espSkeleton = false,
    espHeadDot = false,
    espSnap = false,
    espSnapFrom = 'Bottom',
    espArrows = false,
    espArrowRadius = 220,
    espArrowSize = 14,
    espVisCheck = false,
    espVisColor = Color3.fromRGB(90, 255, 120),
    espMaxDist = 3000,
    espTextSize = 12,
    espFlags = false,
    espDormant = false,
    espDormantTime = 4,
    espFade = 0.35,
    espChamsMode = 'Glow',
    espColorMode = 'Enemy / Teammate',
    espTColor = Color3.fromRGB(255, 170, 60),
    espCTColor = Color3.fromRGB(80, 150, 255),
    scopeStyle = 'Line',
    scopeColor = Color3.fromRGB(255, 255, 255),
    scopeLen = 60,
    scopeGap = 12,
    scopeThick = 1,
    xhair = false,
    xhairColor = Color3.fromRGB(0, 255, 140),
    xhairLen = 6,
    xhairGap = 4,
    xhairThick = 2,
    xhairOutline = true,
    xhairT = false,
    hitMarker = false,
    hitMarkerColor = Color3.fromRGB(255, 255, 255),
    hitMarkerKill = Color3.fromRGB(255, 70, 90),
    hitMarkerTime = 0.45,
    hitMarkerWhere = 'Crosshair',
    hitMarkerAnim = 'Fade',
    hitMarkerSize = 10,
    hitMarkerShape = 'X',
    hitMarkerThick = 2,
    hitMarkerGap = 4,
    hitMarkerOutline = true,
    hitMarkerKillScale = 1.4,
    hitMarkerRise = 0,
    hitMarkerDamage = false,
    dmgNumbers = false,
    dmgColor = Color3.fromRGB(255, 220, 90),
    killFx = false,
    killFxColor = Color3.fromRGB(255, 70, 120),
    dot = false,
    dotColor = Color3.fromRGB(255, 255, 255),
    dotSize = 4,
    tracer = false,
    tracerWidth = 0.06,
    tracerLife = 1,
    impact = false,
    hitSound = false,
    hitSoundId = '3744371342',
    hitVol = 0.6,
    hitLogs = true,
    killSound = false,
    killSoundId = '3744371342',
    killVol = 1,
    skins = false,
    float = 0.001,
    statTrak = true,
    statTrakCount = 1337,
    knife = nil,
    knifeSkin = nil,
    glove = nil,
    gloveSkin = nil,
}, Color3.fromRGB(255, 80, 200)

aC.tracerStyle, aC.tracerFrom, aC.tracerRainbow, aC.tracerOnlyHits = 'Line', 'Gun', false, false
aC.impactSize, aC.impactGlow = 0.35, false

local aE = Color3.fromRGB(255, 255, 255)

local function f() end

local aF, aG, aH = nil, nil, {
    active = false,
    eye = nil,
    sentYaw = nil,
    sentPitch = nil,
}

local function U()
    return aH.active and aH.eye or at.CFrame
end
local function D(aI)
    return (aI + math.pi) % (2 * math.pi) - math.pi
end
local function m()
    return _:GetAttribute'IsPlayerChatting' or an:GetFocusedTextBox() ~= nil
end
local function j()
    local aI = workspace:GetAttribute'ServerGamemode'

    if aI == 'Casual' or aI == 'Deathmatch' then
        return ay.CasualDeathmatch or ay.Default
    elseif aI == 'Surf' then
        return ay.Surf or ay.Default
    end

    return ay.Competitive or ay.Default
end

do
    local aI, aJ = pcall(require, L.Components.Common.Participants)

    if not aI or type(aJ) ~= 'table' or type(aJ.GetAll) ~= 'function' then
        aJ = nil
    end

    local aK = getthreadidentity or syn and syn.get_thread_identity

    local function z(aL, ...)
        local aM, aN, aO = aK and aK(), pcall(aL, ...)

        if aM and setthreadidentity then
            pcall(setthreadidentity, aM)
        end

        return aN, aO
    end

    local aL = {}

    local function R(aM)
        local aN = aL[aM]

        if aN then
            return aN
        end

        aN = setmetatable({
            IsBot = true,
            UserId = 0,
        }, {
            __index = function(aO, aP)
                if aP == 'Character' then
                    local aQ, aR = z(aJ.Character, aM)

                    return aQ and aR or nil
                elseif aP == 'Name' or aP == 'DisplayName' then
                    local aQ, aR = z(aJ.Name, aM)

                    return (aQ and type(aR) == 'string') and aR or aM.Name
                elseif aP == 'Parent' then
                    return aM.Parent
                end

                return nil
            end,
        })

        function aN.GetAttribute(aO, aP)
            local aQ = aM:GetAttribute(aP)

            if aQ == nil then
                local aR, aS = z(aJ.Character, aM)

                if aR and aS then
                    aQ = aS:GetAttribute(aP)
                end
            end

            return aQ
        end

        aL[aM] = aN

        return aN
    end

    local aM, aN = (-1)

    function aa.entities()
        local aO = os.clock()

        if aN and aO - aM < 0.2 then
            return aN
        end

        aM = aO

        local aP, aQ, aR = nil, false

        if aJ then
            aQ, aR = z(aJ.GetAll)
        end
        if aQ and type(aR) == 'table' then
            aP = {}

            for aS, aU in pairs(aR)do
                if typeof(aU) == 'Instance' then
                    aP[#aP + 1] = aU:IsA'Player' and aU or R(aU)
                end
            end
        else
            aP = aa.entities()
        end

        for aS in pairs(aL)do
            if aS.Parent == nil then
                aL[aS] = nil
            end
        end

        if workspace:FindFirstChild'HordeShells' then
            aP = table.clone(aP)

            for aS, aU in ipairs(aa.liveShells())do
                aP[#aP + 1] = aa.zombie(aU)
            end
        end

        aN = aP

        return aP
    end

    local aO

    pcall(function()
        aO = require(L.Controllers.HordeController)
    end)

    function aa.liveShells()
        local aP = {}

        if aO and type(aO.GetLiveShells) == 'function' then
            local aQ, aR = z(aO.GetLiveShells)

            if aQ and type(aR) == 'table' then
                for aS, aU in pairs(aR)do
                    if typeof(aU) == 'Instance' and (aU.Parent and aU:FindFirstChild'Head') then
                        aP[#aP + 1] = aU
                    end
                end

                return aP
            end
        end

        local aQ = workspace:FindFirstChild'HordeShells'

        for aR, aS in ipairs(aQ and aQ:GetChildren() or {})do
            if aS:IsA'Model' and (aS:GetAttribute'HordeId' ~= nil and (not aS:GetAttribute'Ragdolled' and aS:FindFirstChild'Head')) then
                aP[#aP + 1] = aS
            end
        end

        return aP
    end

    local aP = setmetatable({}, {
        __mode = 'k',
    })

    function aa.zombie(aQ)
        local aR = aP[aQ]

        if aR then
            return aR
        end

        aR = {
            IsZombie = true,
            IsBot = true,
            UserId = 0,
            Name = 'zombie',
            DisplayName = 'zombie',
            Character = aQ,
            Parent = aQ.Parent,
        }

        function aR.GetAttribute(aS, aU)
            return aQ:GetAttribute(aU)
        end

        aP[aQ] = aR

        return aR
    end
    function aa.ownerOf(aQ)
        if not aQ then
            return nil
        end

        for aR, aS in ipairs(aa.entities())do
            if aS.Character == aQ then
                return aS
            end
        end

        return nil
    end
    function aa.byName(aQ)
        for aR, aS in ipairs(aa.entities())do
            if aS.Name == aQ then
                return aS
            end
        end

        return nil
    end
end

local function k(aI)
    if type(aI) == 'table' and aI.IsZombie then
        return false
    end
    if workspace:FindFirstChild'HordeShells' then
        return true
    end
    if workspace:GetAttribute'Gamemode' == 'Deathmatch' then
        return false
    end

    local aJ = _:GetAttribute'Team'

    return aJ ~= nil and aI:GetAttribute'Team' == aJ
end
local function h(aI)
    if aI == _ then
        return false
    end
    if type(aI) == 'table' and aI.IsZombie then
        return true
    end
    if workspace:FindFirstChild'HordeShells' then
        return false
    end
    if not aC.teamCheck then
        return true
    end
    if workspace:GetAttribute'Gamemode' == 'Deathmatch' then
        return true
    end

    local aJ = aI:GetAttribute'Team'

    return (aJ == 'Terrorists' or aJ == 'Counter-Terrorists') and aJ ~= _:GetAttribute'Team'
end
local function F(aI, aJ)
    local aK = aI.Character

    if not aK or aK:GetAttribute'Dead' or aK:GetAttribute'Ragdolled' then
        return nil
    end

    local aL = aK:GetAttribute'Health'

    if type(aL) == 'number' and aL <= 0 then
        return nil
    end
    if not aK:IsDescendantOf(workspace) then
        return nil
    end
    if not aK:FindFirstChild(aJ or 'Head') then
        return nil
    end

    return aK
end
local function t(aI)
    if aI == nil then
        return false
    end
    if aI:GetAttribute'Invincible' == true then
        return true
    end

    local aJ = aa.ownerOf(aI)

    return aJ ~= nil and aJ:GetAttribute'Invincible' == true
end

local aI, aJ = {}, setmetatable({}, {
    __mode = 'k',
})

local function dT(aK)
    if aK == _ or aJ[aK] ~= nil then
        return
    end

    aJ[aK] = false

    task.spawn(function()
        local aL, aM = pcall(_.IsFriendsWith, _, aK.UserId)

        aJ[aK] = aL and aM == true
    end)
end

for aK, aL in ipairs(u:GetPlayers())do
    dT(aL)
end

aa.connect(u.PlayerAdded, dT)

local function ET(aK)
    if not h(aK) or aI[aK.Name] then
        return false
    end
    if aC.ignoreFriends and aJ[aK] then
        return false
    end

    return true
end

local aK = setmetatable({}, {
    __mode = 'k',
})

local function MT(aL)
    for aM, aN in ipairs(aa.entities())do
        local aO = aN.Character

        if aO and aL:IsDescendantOf(aO) then
            return aN
        end
    end

    return nil
end
local function AT(aL)
    aL = tostring(aL or '')

    if aL:find'^rbxassetid://' then
        return aL
    end

    local aM = aL:match'%d+'

    return aM and 'rbxassetid://' .. aM or nil
end
local function zT(aL, aM)
    local aN = AT(aL)

    if not aN then
        return
    end

    local aO = Instance.new'Sound'

    aO.SoundId = aN
    aO.Volume = aM or 1
    aO.Parent = aq

    aO:Play()
    as:AddItem(aO, 6)
end

local aL = Instance.new'ScreenGui'

aL.Name = 'ZamlbloxOverlay'
aL.IgnoreGuiInset = true
aL.ResetOnSpawn = false
aL.DisplayOrder = 999
aL.Parent = gethui and gethui() or _:WaitForChild'PlayerGui'

aa.onUnload(function()
    aL:Destroy()
end)

local aM = Instance.new'Frame'

aM.AnchorPoint = Vector2.new(0.5, 0.5)
aM.Position = UDim2.fromScale(0.5, 0.5)
aM.BackgroundTransparency = 1
aM.Visible = false
aM.Parent = aL;
(Instance.new('UICorner', aM)).CornerRadius = UDim.new(1, 0)

local aN = Instance.new('UIStroke', aM)

aN.Transparency = 0.35
aN.Thickness = 1

local aO = Instance.new'Frame'

aO.AnchorPoint = Vector2.new(0.5, 0.5)
aO.Position = UDim2.fromScale(0.5, 0.5)
aO.BorderSizePixel = 0
aO.Visible = false
aO.Parent = aL;
(Instance.new('UICorner', aO)).CornerRadius = UDim.new(1, 0)

local aP = Instance.new('UIStroke', aO)

aP.Color = Color3.new(0, 0, 0)
aP.Thickness = 1

aa.connect(O.RenderStepped, function()
    aM.Visible = aC.silentAim and aC.showFov
    aM.Size = UDim2.fromOffset(aC.fov * 2, aC.fov * 2)
    aN.Color = aC.fovColor

    local aQ = p()

    aO.Visible = aC.dot and not (aQ and aQ.IsAiming)
    aO.Size = UDim2.fromOffset(aC.dotSize, aC.dotSize)
    aO.BackgroundColor3 = aC.dotColor
end)

local aQ, aR = 'ZamlbloxBhop', false

local function vT(aS)
    aC.bhop = aS

    if aS then
        ao:BindActionAtPriority(aQ, function(aU, aV)
            if aV == Enum.UserInputState.Begin then
                aR = true
            elseif aV == Enum.UserInputState.End or aV == Enum.UserInputState.Cancel then
                aR = false
            end

            return Enum.ContextActionResult.Sink
        end, false, Enum.ContextActionPriority.High.Value + 1000, Enum.KeyCode.Space)
    else
        pcall(function()
            ao:UnbindAction(aQ)
        end)

        aR = false
    end
end

aa.onUnload(function()
    pcall(function()
        ao:UnbindAction(aQ)
    end)
end)

do
    local aS, aU, aV, aW, aX, aY, aZ, a_, a0, a1 = 64, 2, 1, false, 0, false, false, 0, 0, nil

    local function v(a2, a3, a4)
        local a5, a6 = aC.speed, a1 and D(a3.LookYaw - a1) or 0

        a1 = a3.LookYaw

        if not (aC.strafe or a5) or a2.OnGround or m() then
            return
        end
        if not a5 and not an:IsKeyDown(Enum.KeyCode.Space) then
            return
        end
        if not a5 and aC.strafeMode == 'Legit' then
            if math.abs(a6) < 0.002 then
                return
            end

            a3.Move = Vector2.new(a6 > 0 and -1 or 1, 0)

            return
        end

        local a7, a8 = (an:IsKeyDown(Enum.KeyCode.D) and 1 or 0) - (an:IsKeyDown(Enum.KeyCode.A) and 1 or 0), (an:IsKeyDown(Enum.KeyCode.S) and 1 or 0) - (an:IsKeyDown(Enum.KeyCode.W) and 1 or 0)

        if a7 == 0 and a8 == 0 then
            if not a5 then
                return
            end

            a8 = -1
        end
        if type(a4) ~= 'table' then
            a4 = nil
        end

        local a9 = (a4 and typeof(a4.Velocity) == 'Vector3') and a4.Velocity or a2.GlobalVelocity
        local ba = (Vector2.new(a9.X, a9.Z)).Magnitude

        if ba < aU then
            return
        end
        if a5 and ba >= aC.speedLimit then
            a3.Move = Vector2.zero

            return
        end

        local bb, bc = D(a3.LookYaw + math.atan2(-a7, -a8)), math.atan2(-a9.X, -a9.Z)
        local bd, be = D(bb - bc), nil
        local bf = math.abs(bd) > math.rad(aC.alignDeg)

        if bf then
            be = bd > 0 and 1 or -1
        else
            aV = -aV
            be = aV
        end

        local bg = j()
        local bh = bg.MaxSpeed

        if a4 and type(a4.BaseMoveSpeed) == 'number' then
            bh = math.clamp(a4.BaseMoveSpeed, 0, bg.MaxBaseMoveSpeed or a4.BaseMoveSpeed)
        end

        local bi = 1

        if a4 and type(a4.Stamina) == 'number' then
            local bj = math.max(bg.StaminaMax or 100, 1)

            bi = math.clamp((a4.Stamina + (bg.StaminaRecoveryRate or 0) / aS) / bj, 0, 1)
        end

        local bj = 1

        if a4 and (type(a4.DuckAmount) == 'number' and type(bg.CrouchModifier) == 'number') then
            bj = 1 + (bg.CrouchModifier - 1) * math.clamp(a4.DuckAmount, 0, 1)
        end

        local bk, bl, bm = ((bh * bj) * bi) * bi, nil, nil

        if (bg.BunnyHopAirAccelerate or 0) > 0 and (bg.BunnyHopAirSpeedCap or 0) > 0 then
            bm = math.min(bk, bg.BunnyHopAirSpeedCap)
            bl = (bg.BunnyHopAirAccelerate * bm) / aS
        else
            bm = math.min(bk, bg.AirSpeedCap)
            bl = (bg.AirAccelerate * bk) / aS
        end

        local bn = math.min(bl, bm)
        local bo = math.acos(math.clamp((bm - bn) / ba, -1, 1))

        if bf and aC.fastTurn then
            local bp = math.min(bl, 2 * bm)
            local bq = math.acos(math.clamp((-bp / 2) / ba, -1, 1))
            local br = math.atan2(bp * math.sin(bq), ba + bp * math.cos(bq))

            if br <= math.abs(bd) then
                bo = bq
            end
        end

        local bp = be > 0 and bc + bo or bc - bo
        local bq = Vector3.new(-math.sin(bp), 0, -math.cos(bp))
        local br = (CFrame.Angles(0, a3.LookYaw, 0)):VectorToObjectSpace(bq)

        a3.Move = Vector2.new(math.clamp(br.X, -1, 1), math.clamp(br.Z, -1, 1))
    end
    local function K(a2)
        if not aC.aa then
            return
        end
        if aC.aaOffShot then
            local a3 = p()

            if a3 and a3.IsShooting then
                return
            end
        end

        local a3 = a2.LookYaw
        local a4 = a3

        if aC.aaBase == 'At Targets' then
            local a5, a6 = (U()).Position, nil

            for a7, a8 in ipairs(aa.entities())do
                if h(a8) then
                    local a9 = F(a8, 'HumanoidRootPart')

                    if a9 then
                        local ba = a9.HumanoidRootPart.Position - a5

                        if not a6 or ba.Magnitude < a6 then
                            a6 = ba.Magnitude
                            a4 = math.atan2(-ba.X, -ba.Z)
                        end
                    end
                end
            end
        end

        local a5 = a4

        if aC.aaManual == 'Left' then
            a5 = a4 + math.pi / 2
        elseif aC.aaManual == 'Right' then
            a5 = a4 - math.pi / 2
        elseif aC.aaManual == 'Back' then
            a5 = a4 + math.pi
        elseif aC.aaYaw == 'Backwards' then
            a5 = a4 + math.pi
        elseif aC.aaYaw == 'Sideways' then
            a5 = a4 + math.pi / 2
        elseif aC.aaYaw == 'Spin' then
            aX = D(aX + math.rad(aC.aaSpin))
            a5 = aX
        elseif aC.aaYaw == 'Jitter' then
            a_ = a_ + 1

            if a_ >= math.max(aC.aaJitterDelay, 1) then
                a_ = 0
                aY = not aY
            end

            a5 = (a4 + math.pi) + (aY and 1 or -1) * math.rad(aC.aaJitter)
        end

        a5 = D(a5)

        local a6 = a2.Move

        if typeof(a6) == 'Vector2' and a6.Magnitude > 0 then
            local a7 = (CFrame.Angles(0, a3, 0)):VectorToWorldSpace(Vector3.new(a6.X, 0, a6.Y))
            local a8 = (CFrame.Angles(0, a5, 0)):VectorToObjectSpace(a7)

            a2.Move = Vector2.new(math.clamp(a8.X, -1, 1), math.clamp(a8.Z, -1, 1))
        end

        a2.LookYaw = a5

        if aC.aaPitch == 'Down' then
            a2.VerticalLook = -1
        elseif aC.aaPitch == 'Up' then
            a2.VerticalLook = 1
        elseif aC.aaPitch == 'Jitter' then
            a0 = a0 + 1

            if a0 >= math.max(aC.aaJitterDelay, 1) then
                a0 = 0
                aZ = not aZ
            end

            a2.VerticalLook = aZ and 1 or -1
        end
    end

    local a2, a3, a4, a5, a6, a7 = require(L.MovementV2.Buttons), nil, false, false, 0, RaycastParams.new()

    a7.FilterType = Enum.RaycastFilterType.Exclude
    a3 = function(a8)
        local a9, ba = a8.HumanoidRootPart, a8.GlobalVelocity

        if not a9 or typeof(ba) ~= 'Vector3' then
            return false
        end

        local bb = Vector3.new(ba.X, 0, ba.Z)

        if bb.Magnitude < 4 then
            return false
        end

        a7.FilterDescendantsInstances = {
            _.Character,
            at,
            workspace:FindFirstChild'Debris',
        }

        local bc = (a9.Position + bb * (2 / aS)) + bb.Unit * 0.6

        return workspace:Raycast(bc, Vector3.new(0, -4.5, 0), a7) == nil
    end

    local a8, a9 = 0, 0

    local function o(ba, bb)
        if not aC.landBrake or type(bb) ~= 'table' then
            return
        end

        local bc = j()
        local bd = bc.BunnyHopPenaltyThreshold or 0

        if bd <= 0 then
            return
        end

        local be, bf = bb.Velocity, bb.Position

        if typeof(be) ~= 'Vector3' or typeof(bf) ~= 'Vector3' or be.Y > 0 then
            return
        end

        local bg, bh = math.sqrt(be.X * be.X + be.Z * be.Z), bd - 0.15

        if bg <= bh then
            return
        end

        local bi = 1 / aS

        a7.FilterDescendantsInstances = {
            _.Character,
            at,
            workspace:FindFirstChild'Debris',
        }

        local bj = bf + Vector3.new(be.X, 0, be.Z) * (4 * bi)
        local bk = workspace:Raycast(bj + Vector3.new(0, 3, 0), Vector3.new(0, -90, 0), a7)

        if not bk then
            return
        end

        local bl, bm, bn = (bf.Y - bk.Position.Y) - a8, be.Y, 0

        while bn < 48 do
            bm = bm - bc.Gravity * bi
            bl = bl + bm * bi

            if bl <= 0 then
                break
            end

            bn = bn + 1
        end

        local bo = bc.MaxSpeed

        if type(bb.BaseMoveSpeed) == 'number' then
            bo = math.clamp(bb.BaseMoveSpeed, 0, bc.MaxBaseMoveSpeed or bb.BaseMoveSpeed)
        end

        local bp = 1

        if type(bb.Stamina) == 'number' then
            bp = math.clamp((bb.Stamina + (bc.StaminaRecoveryRate or 0) * bi) / math.max(bc.StaminaMax or 100, 1), 0, 1)
        end

        local bq = (((bc.AirAccelerate * bo) * bp) * bp) * bi

        if bq <= 0.01 then
            return
        end

        local br = bg - bh

        if bn > math.ceil(br / bq) + 1 then
            return
        end

        local bs, bt = math.clamp(((bh * bh - bg * bg) - bq * bq) / ((2 * bg) * bq), 
-1, 1), math.atan2(-be.X, -be.Z)
        local bu = bt + math.acos(bs)
        local bv = Vector3.new(-math.sin(bu), 0, -math.cos(bu))
        local bw = (CFrame.Angles(0, ba.LookYaw, 0)):VectorToObjectSpace(bv)

        ba.Move = Vector2.new(math.clamp(bw.X, -1, 1), math.clamp(bw.Z, -1, 1))
    end

    local ba

    ba = Q(ax.SampleInput, function(bb, ...)
        local bc = not aa.unloaded and (not m() and (aC.bhop and aR or aC.speed))

        if not aa.unloaded and (aC.longJump and (bb.OnGround and (not m() and a3(bb)))) then
            bb.JumpPulsePending = true
            a4 = true
        end

        local bd, be = ..., ba(bb, ...)

        if aa.unloaded or be == nil then
            return be
        end
        if bc then
            local bf = bb.OnGround == true and not aW

            be.Buttons = a2.with(be.Buttons, a2.Jump, bf)
            aW = bf
        else
            aW = false
        end

        local bf = bb.OnGround == true

        if a5 and (not bf and (aC.boostJump or a4)) then
            a6 = aC.duckTicks
        end
        if bf then
            a4 = false
        end

        a5 = bf

        if a6 > 0 and not bf then
            a6 = a6 - 1
            be.Buttons = a2.with(be.Buttons, a2.Duck, true)
        elseif bf then
            a6 = 0
        end

        local bg = type(bd) == 'table' and bd.State or nil

        v(bb, be, bg)

        if bc and type(bg) == 'table' then
            if bf then
                if os.clock() - a9 > 1 and typeof(bg.Position) == 'Vector3' then
                    a9 = os.clock()
                    a7.FilterDescendantsInstances = {
                        _.Character,
                        at,
                        workspace:FindFirstChild'Debris',
                    }

                    local bh = workspace:Raycast(bg.Position + Vector3.new(0, 3, 0), Vector3.new(0, 
-12, 0), a7)

                    if bh then
                        a8 = bg.Position.Y - bh.Position.Y
                    end
                end
            else
                pcall(o, be, bg)
            end
        end
        if aC.speed and (bb.OnGround and (not m() and (typeof(be.Move) == 'Vector2' and be.Move.Magnitude == 0))) then
            be.Move = Vector2.new(0, -1)
        end

        K(be)

        aH.sentYaw, aH.sentPitch = be.LookYaw, be.VerticalLook

        return be
    end)
end

function aa.hookSpeedPenalty()
    if aa.unloaded or aa.speedPenaltyHooked then
        return
    end

    aa.speedPenaltyHooked = true

    local aS

    for aU, aV in ipairs(getgc(true))do
        if type(aV) == 'table' then
            local aW, aX = pcall(rawget, aV, '_accumulatorSeconds')

            if aW and (type(aX) == 'number' and type(rawget(aV, '_options')) == 'table') then
                aS = aV

                break
            end
        end
    end

    local aU = aS and aS._options

    if aU then
        aU.__zbScoped = rawget(aU, '__zbScoped') or aU.ResolveScopedState
        aU.__zbBaseSpeed = rawget(aU, '__zbBaseSpeed') or aU.ResolveBaseMoveSpeed

        local aV, aW, aX = aU.__zbScoped, aU.__zbBaseSpeed, ay.Default and ay.Default.MaxBaseMoveSpeed or 19.5

        if aV then
            aU.ResolveScopedState = function(...)
                if not aa.unloaded and aC.noSpeedPenalty then
                    return false
                end

                return aV(...)
            end
        end
        if aW then
            aU.ResolveBaseMoveSpeed = function(...)
                local aY, aZ = aW(...)

                if not aa.unloaded and (aC.noSpeedPenalty and (type(aY) == 'number' and aY > 0)) then
                    aY = math.max(aY, aX)
                end

                return aY, aZ
            end
        end

        aa.onUnload(function()
            if aV then
                aU.ResolveScopedState = aV
            end
            if aW then
                aU.ResolveBaseMoveSpeed = aW
            end
        end)
    else
        aa.speedPenaltyHooked = false
    end
end

do
    local aS

    aS = Q(av.setWeaponRecoil, function(aU, aV)
        if aa.unloaded or not aC.noRecoil then
            return aS(aU, aV)
        end

        return aS({
            Value = Vector3.zero,
            Damper = aU.Damper,
            Speed = aU.Speed,
        }, aV)
    end)

    local aU

    aU = Q(av.weaponKick, function(aV, aW)
        if aa.unloaded or not aC.noRecoil then
            return aU(aV, aW)
        end

        return aU({
            Value = aV.Value * 0,
            Damper = aV.Damper,
            Speed = aV.Speed,
        }, {
            Value = aW.Value * 0,
            Damper = aW.Damper,
            Speed = aW.Speed,
        })
    end)
end
do
    local aS = 2147483000
    local aU, aV = {
        WindUI = aS,
        ['WindUI/Dropdowns'] = aS + 10,
        ['WindUI/Tooltips'] = aS + 20,
        ['WindUI/Notifications'] = aS + 30,
    }, {}

    local function M()
        local aW = {
            game:GetService'CoreGui',
        }

        if gethui then
            aW[2] = gethui()
        end

        for aX, aY in ipairs(aW)do
            for aZ, a_ in ipairs(aY:GetChildren())do
                local a0 = aU[a_.Name]

                if a0 and (a_:IsA'ScreenGui' and a_.DisplayOrder ~= a0) then
                    if aV[a_] == nil then
                        aV[a_] = a_.DisplayOrder
                    end

                    a_.DisplayOrder = a0
                end
            end
        end
    end

    task.spawn(function()
        while not aa.unloaded do
            if setthreadidentity then
                pcall(setthreadidentity, 8)
            end

            pcall(M)
            task.wait(1)
        end
    end)
    aa.onUnload(function()
        for aW, aX in pairs(aV)do
            pcall(function()
                aW.DisplayOrder = aX
            end)
        end
    end)
end

local aS = Instance.new'Folder'

aS.Name = 'ZamlbloxFX'
aS.Parent = at

aa.onUnload(function()
    aS:Destroy()
end)

local aU = RaycastParams.new()

aU.FilterType = Enum.RaycastFilterType.Exclude

local function cT(aV, aW)
    if not aC.wallCheck then
        return true
    end

    local aX = (U()).Position

    aU.FilterDescendantsInstances = {
        _.Character,
        at,
    }

    local aY = workspace:Raycast(aX, aV.Position - aX, aU)

    return aY == nil or aY.Instance:IsDescendantOf(aW)
end

local aV, aW = {
    'Head',
    'UpperTorso',
    'LowerTorso',
    'LeftUpperArm',
    'LeftLowerArm',
    'LeftHand',
    'RightUpperArm',
    'RightLowerArm',
    'RightHand',
    'LeftUpperLeg',
    'LeftLowerLeg',
    'LeftFoot',
    'RightUpperLeg',
    'RightLowerLeg',
    'RightFoot',
}, {
    Head = 'Head',
    UpperTorso = 'Torso',
    LowerTorso = 'Torso',
    HumanoidRootPart = 'Torso',
    Torso = 'Torso',
    LeftUpperArm = 'Arms',
    LeftLowerArm = 'Arms',
    LeftHand = 'Arms',
    RightUpperArm = 'Arms',
    RightLowerArm = 'Arms',
    RightHand = 'Arms',
    LeftUpperLeg = 'Legs',
    LeftLowerLeg = 'Legs',
    LeftFoot = 'Legs',
    RightUpperLeg = 'Legs',
    RightLowerLeg = 'Legs',
    RightFoot = 'Legs',
}

local function bT(aX, aY)
    local aZ, a_ = at:WorldToViewportPoint(aX)

    if not a_ then
        return nil
    end

    return (Vector2.new(aZ.X, aZ.Y) - aY).Magnitude
end
local function aT()
    local aX, aY = at.ViewportSize / 2, aC.aimPart
    local aZ, a_, a0, a1 = aY == 'Closest to Crosshair' or aY == 'Random', (aC.fov)

    for a2, a3 in ipairs(aa.entities())do
        if h(a3) then
            local a4 = F(a3, 'HumanoidRootPart')

            if a4 then
                for a5, a6 in ipairs(aZ and aV or {aY})do
                    local a7 = a4:FindFirstChild(a6)

                    if a7 then
                        local a8 = bT(a7.Position, aX)

                        if a8 and (a8 < a_ and cT(a7, a4)) then
                            a0, a_, a1 = a7, a8, a4
                        end
                    end
                end
            end
        end
    end

    if aY == 'Random' and a1 then
        local a2 = {}

        for a3, a4 in ipairs(aV)do
            local a5 = a1:FindFirstChild(a4)

            if a5 and cT(a5, a1) then
                a2[#a2 + 1] = a5
            end
        end

        if #a2 > 0 then
            return a2[math.random(#a2)]
        end
    end

    return a0
end
local function TT(aX, aY, aZ)
    local a_ = Instance.new'Part'

    a_.Anchored, a_.CanCollide, a_.CanQuery, a_.CanTouch, a_.CastShadow = true, false, false, false, false
    a_.Material = Enum.Material.Neon
    a_.Color = aZ
    a_.Size = aX
    a_.CFrame = aY
    a_.Parent = aS;

    (ap:Create(a_, TweenInfo.new(aC.tracerLife, Enum.EasingStyle.Quad), {Transparency = 1})):Play()
    as:AddItem(a_, aC.tracerLife + 0.1)

    return a_
end

local aX, aY = {}, 0

function drawTracer(aZ, a_, a0)
    local a1 = aZ

    if aC.tracerFrom == 'Gun' then
        local a2 = p()
        local a3 = a2 and (a2.Viewmodel and a2.Viewmodel.Model)
        local a4 = a3 and a3:FindFirstChild('Muzzle', true)

        if a4 and a4:IsA'BasePart' then
            a1 = a4.Position
        elseif a4 and a4:IsA'Attachment' then
            a1 = a4.WorldPosition
        else
            a1 = (U() * CFrame.new(0.35, -0.35, -1.2)).Position
        end
    end

    local a2 = aD

    if aC.tracerRainbow then
        aY = (aY + 0.07) % 1
        a2 = Color3.fromHSV(aY, 0.85, 1)
    end

    local a3, a4, a5 = aC.tracerLife, aC.tracerWidth, (a_ - a1).Magnitude

    if aC.tracer and a5 > 0.5 then
        if aC.tracerStyle == 'Beam' then
            local a6 = Instance.new'Part'

            a6.Anchored, a6.CanCollide, a6.CanQuery, a6.CanTouch = true, false, false, false
            a6.Transparency, a6.Size, a6.CFrame = 1, Vector3.new(0.1, 0.1, 0.1), CFrame.new(a1)
            a6.Parent = aS

            local a7, a8 = Instance.new('Attachment', a6), Instance.new('Attachment', a6)

            a8.WorldPosition = a_

            local a9 = Instance.new'Beam'

            a9.Attachment0, a9.Attachment1 = a7, a8
            a9.Width0, a9.Width1 = a4 * 2.5, a4 * 0.6
            a9.FaceCamera = true
            a9.LightEmission, a9.LightInfluence = 1, 0
            a9.Color = ColorSequence.new(a2)
            a9.Parent = a6

            task.spawn(function()
                local ba = os.clock()

                while a6.Parent and os.clock() - ba < a3 do
                    local bb = (os.clock() - ba) / a3

                    a9.Transparency = NumberSequence.new(bb * 0.9, math.min(1, 0.3 + bb))

                    task.wait(0.03)
                end

                a6:Destroy()
            end)
        elseif aC.tracerStyle == 'Lightning' then
            local a6, a7 = math.clamp(math.floor(a5 / 4), 4, 14), (a_ - a1).Unit
            local a8 = a7:Cross(Vector3.new(0, 1, 0))

            if a8.Magnitude < 0.001 then
                a8 = Vector3.new(1, 0, 0)
            end

            a8 = a8.Unit

            local a9, ba = (a8:Cross(a7)).Unit, a1

            for bb = 1, a6, 1 do
                local bc = a1 + (a_ - a1) * (bb / a6)

                if bb < a6 then
                    bc = (bc + (a8 * (math.random() - 0.5)) * 0.9) + (a9 * (math.random() - 0.5)) * 0.9
                end

                local bd = (bc - ba).Magnitude

                if bd > 0.05 then
                    TT(Vector3.new(a4, a4, bd), CFrame.lookAt((ba + bc) / 2, bc), a2)
                end

                ba = bc
            end
        else
            TT(Vector3.new(a4, a4, a5), CFrame.lookAt((a1 + a_) / 2, a_), a2)
        end
    end
    if aC.impact and a0 then
        local a6 = aC.impactSize
        local a7 = TT(Vector3.new(a6, a6, a6), CFrame.new(a_), aE)

        if aC.impactGlow then
            local a8 = Instance.new'PointLight'

            a8.Color, a8.Range, a8.Brightness = aE, 6, 2
            a8.Parent = a7
        end
    end
end

local aZ = {
    factor = {},
    samples = {},
    meta = {},
}

do
    local a_ = 'zaml/bloxstrike/damage_calibration.json'

    pcall(function()
        if isfile and isfile(a_) then
            local a0 = ar:JSONDecode(readfile(a_))

            if type(a0) == 'table' then
                aZ.factor, aZ.samples = a0.factor or {}, a0.samples or {}
            end
        end
    end)

    local function E()
        pcall(function()
            if isfolder and (makefolder and not isfolder'zaml/bloxstrike') then
                if not isfolder'zaml' then
                    makefolder'zaml'
                end

                makefolder'zaml/bloxstrike'
            end

            writefile(a_, ar:JSONEncode{
                factor = aZ.factor,
                samples = aZ.samples,
            })
        end)
    end

    local a0, a1 = false, false

    local function z()
        a0 = true

        if a1 then
            return
        end

        a1 = true

        task.delay(10, function()
            a1 = false

            if a0 and not aa.unloaded then
                a0 = false

                E()
            end
        end)
    end

    aa.onUnload(function()
        if a0 then
            a0 = false

            E()
        end
    end)

    function aZ.key(a2, a3, a4)
        return tostring(a2) .. ('|' .. (tostring(a3) .. ('|' .. ((a4 or 0) > 0 and 'wall' or 'open'))))
    end
    function aZ.get(a2)
        return math.clamp(aZ.factor[a2] or 1, 0.6, 1.4)
    end
    function aZ.expect(a2, a3, a4)
        aZ.meta[a2] = {
            key = a3,
            raw = a4,
            at = os.clock(),
        }
    end
    function aZ.observe(a2, a3, a4)
        local a5 = aZ.meta[a2]

        aZ.meta[a2] = nil

        if not a5 or os.clock() - a5.at > 1.5 or not a5.raw or a5.raw <= 0 then
            return
        end
        if a4 and a5.raw >= a4 then
            return
        end

        local a6, a7 = math.clamp(a3 / a5.raw, 0.05, 2), (aZ.samples[a5.key] or 0) + 1
        local a8, a9 = aZ.factor[a5.key] or a6, a7 <= 3 and 1 / a7 or 0.3

        aZ.factor[a5.key] = a8 + (a6 - a8) * a9
        aZ.samples[a5.key] = a7

        z()
    end
    function aZ.reset()
        aZ.factor, aZ.samples, aZ.meta = {}, {}, {}

        z()
    end
end

local a_ = {}

do
    local a0, a1, a2, a3, a4, a5, a6, a7 = 0.8, 4, 1, 8, {
        hit = Color3.fromRGB(88, 170, 255),
        kill = Color3.fromRGB(255, 86, 110),
        miss = Color3.fromRGB(150, 150, 160),
    }, {
        Head = 'head',
        UpperTorso = 'body',
        LowerTorso = 'body',
        HumanoidRootPart = 'body',
        LeftUpperArm = 'arm',
        LeftLowerArm = 'arm',
        LeftHand = 'arm',
        RightUpperArm = 'arm',
        RightLowerArm = 'arm',
        RightHand = 'arm',
        LeftUpperLeg = 'leg',
        LeftLowerLeg = 'leg',
        LeftFoot = 'leg',
        RightUpperLeg = 'leg',
        RightLowerLeg = 'leg',
        RightFoot = 'leg',
    }, {}, Instance.new'Frame'

    a7.Name = 'ZamlbloxHitLog'
    a7.AnchorPoint = Vector2.new(0.5, 0)
    a7.Position = UDim2.new(0.5, 0, 0.5, 70)
    a7.Size = UDim2.fromOffset(0, 0)
    a7.AutomaticSize = Enum.AutomaticSize.XY
    a7.BackgroundTransparency = 1
    a7.Parent = aL

    local a8 = Instance.new('UIListLayout', a7)

    a8.Padding = UDim.new(0, 0)
    a8.HorizontalAlignment = Enum.HorizontalAlignment.Center
    a8.SortOrder = Enum.SortOrder.LayoutOrder

    local a9, ba, bb = 0, {}, {
        hit = Color3.fromRGB(255, 255, 255),
        head = Color3.fromRGB(255, 60, 60),
        kill = Color3.fromRGB(255, 60, 60),
        miss = Color3.fromRGB(255, 95, 95),
    }

    local function N(bc, bd)
        if not aC.hitLogs then
            return
        end
        if setthreadidentity then
            pcall(setthreadidentity, 8)
        end

        a9 = a9 + 1

        local be = Instance.new'TextLabel'

        be.LayoutOrder = -a9
        be.Size = UDim2.fromOffset(0, 16)
        be.AutomaticSize = Enum.AutomaticSize.X
        be.BackgroundTransparency = 1
        be.Font = Enum.Font.GothamBold
        be.TextSize = 13
        be.TextColor3 = bb[bc] or bb.hit
        be.TextStrokeColor3 = Color3.new(0, 0, 0)
        be.TextStrokeTransparency = 0.4
        be.Text = bd
        be.Parent = a7

        table.insert(ba, be)

        while#ba > a3 do
            local bf = table.remove(ba, 1)

            bf:Destroy()
        end

        task.delay(a1, function()
            if not be.Parent then
                return
            end

            (ap:Create(be, TweenInfo.new(a2, Enum.EasingStyle.Linear), {
                TextTransparency = 1,
                TextStrokeTransparency = 1,
            })):Play()
            task.delay(a2, function()
                local bf = table.find(ba, be)

                if bf then
                    table.remove(ba, bf)
                end

                be:Destroy()
            end)
        end)
    end

    local bc = {}

    pcall(function()
        local bd = require(L.Controllers.HordeController)

        aa.connect(bd.HitConfirmed, function(be, bf)
            local bg = table.remove(bc, 1)

            if not bg then
                return
            end

            local bh = be and 'head' or a5[bg.part] or 'body'

            if bh == 'head' and not … 