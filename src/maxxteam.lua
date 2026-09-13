--[[
    maxxteam.lua — Library
    INJECTOR-COMPATIBLE BUILD
    Load with: loadstring(game:HttpGet("https://raw.githubusercontent.com/.../maxxteam.lua"))()
]]

--============================================================
-- INJECTOR WRAPPER (для либы — только регистрация в getgenv)
--============================================================

local __MAX_ENV = (getgenv and getgenv()) or _G or shared

if __MAX_ENV.__MAXXTEAM_LIB and __MAX_ENV.__MAXXTEAM_LIB_VER == "v5" then
    return __MAX_ENV.__MAXXTEAM_LIB
end

--============================================================
-- SERVICES
--============================================================

local Players       = game:GetService("Players")
local TweenService  = game:GetService("TweenService")
local UIS           = game:GetService("UserInputService")
local RunService    = game:GetService("RunService")

local player = Players.LocalPlayer

local pg = player:FindFirstChildOfClass("PlayerGui")
    or player:WaitForChild("PlayerGui", 10)

if not pg then
    warn("[maxxteam] PlayerGui not found, library aborted.")
    return nil
end

--============================================================
-- LIBRARY
--============================================================

local Library = {}
Library.__index = Library

local D = {
    Name = "maxxteam",
    Version = "v5",
    ToggleKey = Enum.KeyCode.RightShift,
    Size = Vector2.new(940, 590),
    Accent = Color3.fromRGB(45, 125, 255),
    Accent2 = Color3.fromRGB(80, 175, 255),
    Bg = Color3.fromRGB(8, 10, 14),
    Panel = Color3.fromRGB(13, 17, 24),
    Text = Color3.fromRGB(235, 240, 248),
    Muted = Color3.fromRGB(135, 146, 164),
    Border = Color3.fromRGB(34, 42, 56)
}

--============================================================
-- HELPERS
--============================================================

local function n(class, props, parent)
    local x = Instance.new(class)
    for k, v in pairs(props or {}) do
        x[k] = v
    end
    x.Parent = parent
    return x
end

local function co(x, r)
    n("UICorner", { CornerRadius = UDim.new(0, r) }, x)
end

local function st(x, c, t)
    n("UIStroke", { Color = c, Transparency = t or 0, Thickness = 1 }, x)
end

local function T(x, d, p)
    local q = TweenService:Create(
        x,
        TweenInfo.new(d, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
        p
    )
    q:Play()
    return q
end

local function merge(a, b)
    local o = {}
    for k, v in pairs(a) do o[k] = v end
    for k, v in pairs(b or {}) do o[k] = v end
    return o
end

local function safeCall(fn, ...)
    if type(fn) ~= "function" then return end
    local ok, err = pcall(fn, ...)
    if not ok then
        warn("[maxxteam] callback error:", err)
    end
end

--============================================================
-- CONSTRUCTOR
--============================================================

function Library.new(opt)
    local s = setmetatable({}, Library)
    s.C = merge(D, opt)
    s.Tabs = {}
    s.Con = {}
    s.Opened = true
    s.Minimized = false
    s.Particles = true
    s.Animations = true
    s.Destroyed = false
    s:Build()
    return s
end

function Library:con(sig, fn)
    local c = sig:Connect(fn)
    table.insert(self.Con, c)
    return c
end

--============================================================
-- BUILD
--============================================================

function Library:Build()
    -- cleanup предыдущего инжекта
    local old = pg:FindFirstChild(self.C.Name)
    if old then old:Destroy() end

    local g = n("ScreenGui", {
        Name = self.C.Name,
        ResetOnSpawn = false,
        IgnoreGuiInset = true,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        DisplayOrder = 999
    }, pg)
    self.Gui = g

    local root = n("Frame", {
        AnchorPoint = Vector2.new(.5, .5),
        Position = UDim2.fromScale(.5, .5),
        Size = UDim2.fromOffset(self.C.Size.X, self.C.Size.Y),
        BackgroundTransparency = 1
    }, g)
    self.Root = root

    self.Scale = n("UIScale", { Scale = .94 }, root)

    local sh = n("Frame", {
        Position = UDim2.fromOffset(-10, 10),
        Size = UDim2.new(1, 20, 1, 20),
        BackgroundColor3 = Color3.new(0, 0, 0),
        BackgroundTransparency = .5,
        ZIndex = 0
    }, root)
    co(sh, 22)
    self.Shadow = sh

    local m = n("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundColor3 = self.C.Bg,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 2
    }, root)
    co(m, 18)
    st(m, self.C.Border, .2)
    self.Main = m

    local glow = n("Frame", {
        Position = UDim2.fromOffset(-80, -80),
        Size = UDim2.fromOffset(300, 300),
        BackgroundColor3 = self.C.Accent,
        BackgroundTransparency = .95,
        ZIndex = 3
    }, m)
    co(glow, 150)

    local top = n("Frame", {
        Size = UDim2.new(1, 0, 0, 64),
        BackgroundColor3 = Color3.fromRGB(10, 13, 18),
        BorderSizePixel = 0,
        ZIndex = 10,
        Active = true
    }, m)
    co(top, 18)

    n("Frame", {
        Position = UDim2.fromOffset(0, 32),
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = Color3.fromRGB(10, 13, 18),
        BorderSizePixel = 0,
        ZIndex = 10
    }, top)

    local logo = n("Frame", {
        Position = UDim2.fromOffset(18, 19),
        Size = UDim2.fromOffset(26, 26),
        BackgroundColor3 = self.C.Accent,
        BorderSizePixel = 0,
        ZIndex = 12
    }, top)
    co(logo, 8)
    st(logo, self.C.Accent2, .15)

    n("TextLabel", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = "m",
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBold,
        TextSize = 14,
        ZIndex = 13
    }, logo)

    n("TextLabel", {
        Position = UDim2.fromOffset(56, 10),
        Size = UDim2.fromOffset(200, 24),
        BackgroundTransparency = 1,
        Text = self.C.Name,
        TextColor3 = self.C.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 16,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 12
    }, top)

    n("TextLabel", {
        Position = UDim2.fromOffset(57, 34),
        Size = UDim2.fromOffset(100, 16),
        BackgroundTransparency = 1,
        Text = self.C.Version,
        TextColor3 = self.C.Muted,
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 12
    }, top)

    local status = n("Frame", {
        AnchorPoint = Vector2.new(.5, 0),
        Position = UDim2.new(.5, 0, 0, 18),
        Size = UDim2.fromOffset(105, 28),
        BackgroundColor3 = self.C.Panel,
        BorderSizePixel = 0,
        ZIndex = 12
    }, top)
    co(status, 10)
    st(status, self.C.Border, .35)

    local dot = n("Frame", {
        Position = UDim2.fromOffset(10, 10),
        Size = UDim2.fromOffset(7, 7),
        BackgroundColor3 = Color3.fromRGB(65, 220, 125),
        BorderSizePixel = 0,
        ZIndex = 13
    }, status)
    co(dot, 5)

    n("TextLabel", {
        Position = UDim2.fromOffset(24, 0),
        Size = UDim2.new(1, -24, 1, 0),
        BackgroundTransparency = 1,
        Text = "ready",
        TextColor3 = self.C.Muted,
        Font = Enum.Font.GothamMedium,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 13
    }, status)

    local ctr = n("Frame", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -14, 0, 14),
        Size = UDim2.fromOffset(82, 36),
        BackgroundTransparency = 1,
        ZIndex = 20
    }, top)

    local min = n("TextButton", {
        Size = UDim2.fromOffset(36, 32),
        BackgroundColor3 = self.C.Panel,
        BorderSizePixel = 0,
        Text = "—",
        TextColor3 = self.C.Muted,
        Font = Enum.Font.GothamBold,
        TextSize = 15,
        AutoButtonColor = false,
        ZIndex = 21
    }, ctr)
    co(min, 9)

    local cls = n("TextButton", {
        Position = UDim2.fromOffset(42, 0),
        Size = UDim2.fromOffset(36, 32),
        BackgroundColor3 = self.C.Panel,
        BorderSizePixel = 0,
        Text = "×",
        TextColor3 = self.C.Muted,
        Font = Enum.Font.GothamBold,
        TextSize = 17,
        AutoButtonColor = false,
        ZIndex = 21
    }, ctr)
    co(cls, 9)

    local drag = n("Frame", {
        Size = UDim2.new(1, -100, 1, 0),
        BackgroundTransparency = 1,
        Active = true,
        ZIndex = 11
    }, top)

    local body = n("Frame", {
        Position = UDim2.fromOffset(0, 64),
        Size = UDim2.new(1, 0, 1, -64),
        BackgroundTransparency = 1,
        ZIndex = 5
    }, m)
    self.Body = body

    local side = n("Frame", {
        Position = UDim2.fromOffset(14, 14),
        Size = UDim2.new(0, 180, 1, -28),
        BackgroundColor3 = Color3.fromRGB(10, 13, 18),
        BorderSizePixel = 0,
        ZIndex = 7
    }, body)
    co(side, 14)
    st(side, self.C.Border, .38)

    n("TextLabel", {
        Position = UDim2.fromOffset(16, 14),
        Size = UDim2.new(1, -32, 0, 18),
        BackgroundTransparency = 1,
        Text = "navigation",
        TextColor3 = self.C.Muted,
        Font = Enum.Font.GothamMedium,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 8
    }, side)

    local tabs = n("ScrollingFrame", {
        Position = UDim2.fromOffset(10, 42),
        Size = UDim2.new(1, -20, 1, -52),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex = 8
    }, side)
    n("UIListLayout", { Padding = UDim.new(0, 7) }, tabs)
    self.TabList = tabs

    local content = n("Frame", {
        Position = UDim2.fromOffset(208, 14),
        Size = UDim2.new(1, -222, 1, -28),
        BackgroundColor3 = Color3.fromRGB(9, 12, 17),
        BorderSizePixel = 0,
        ClipsDescendants = true,
        ZIndex = 7
    }, body)
    co(content, 14)
    st(content, self.C.Border, .38)

    self.Pages = n("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        ZIndex = 8
    }, content)

    self.ParticlesLayer = n("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        ClipsDescendants = true,
        ZIndex = 9
    }, content)

    self:setupDrag(drag)
    self:setupControls(min, cls)

    -- particles
    for i = 1, 15 do
        local p = n("Frame", {
            Position = UDim2.fromScale(math.random(), math.random()),
            Size = UDim2.fromOffset(math.random(2, 5), math.random(2, 5)),
            BackgroundColor3 = i % 3 == 0 and self.C.Accent2 or self.C.Accent,
            BackgroundTransparency = .6 + math.random() * 0.18,
            BorderSizePixel = 0,
            ZIndex = 9
        }, self.ParticlesLayer)
        co(p, 9)
        self.ParticlesData = self.ParticlesData or {}
        self.ParticlesData[p] = {
            s = math.random(7, 18) / 1000,
            d = math.random(-15, 15) / 10000
        }
    end

    local phase = 0

    self:con(RunService.RenderStepped, function(dt)
        phase += dt

        if self.Animations and glow.Parent then
            glow.Position = UDim2.fromOffset(
                -80 + math.sin(phase * .55) * 60,
                -80 + math.cos(phase * .43) * 45
            )
        end

        for p, d in pairs(self.ParticlesData or {}) do
            if p.Parent then
                p.Visible = self.Particles
                if self.Particles and self.Animations then
                    local q = p.Position
                    local y = q.Y.Scale - d.s * dt
                    local x = q.X.Scale + d.d * math.sin(os.clock()) * dt
                    if y < -.05 then
                        y = 1.05
                        x = math.random()
                    end
                    p.Position = UDim2.fromScale(x, y)
                end
            end
        end
    end)

    self.Scale.Scale = .94
    T(self.Scale, .35, { Scale = 1 })

    self:Notify({
        Title = "maxxteam",
        Content = "v5 loaded",
        Duration = 2.2
    })
end

--============================================================
-- DRAG
--============================================================

function Library:setupDrag(d)
    local on = false
    local start
    local pos

    self:con(d.InputBegan, function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then
            on = true
            start = i.Position
            pos = self.Root.Position
        end
    end)

    self:con(UIS.InputChanged, function(i)
        if on and (
            i.UserInputType == Enum.UserInputType.MouseMovement
            or i.UserInputType == Enum.UserInputType.Touch
        ) then
            local z = i.Position - start
            self.Root.Position = UDim2.new(
                pos.X.Scale,
                pos.X.Offset + z.X,
                pos.Y.Scale,
                pos.Y.Offset + z.Y
            )
        end
    end)

    self:con(UIS.InputEnded, function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then
            on = false
        end
    end)
end

--============================================================
-- CONTROLS
--============================================================

function Library:setupControls(mi, cl)
    -- оба варианта: MouseButton1Click + Activated (Activated работает не везде)
    self:con(mi.MouseButton1Click, function()
        self:SetMinimized(not self.Minimized)
    end)

    self:con(cl.MouseButton1Click, function()
        self:SetOpen(false)
    end)

    self:con(UIS.InputBegan, function(i, p)
        if not p and i.KeyCode == self.C.ToggleKey then
            self:SetOpen(not self.Opened)
        end
    end)
end

function Library:SetOpen(v)
    self.Opened = v == true

    if self.Opened then
        self.Gui.Enabled = true
        self.Scale.Scale = .95
        T(self.Scale, .2, { Scale = 1 })
    else
        T(self.Scale, .18, { Scale = .95 })
        task.delay(.18, function()
            if not self.Opened and not self.Destroyed and self.Gui then
                self.Gui.Enabled = false
            end
        end)
    end
end

function Library:SetMinimized(v)
    self.Minimized = v == true

    if self.Minimized then
        self.Body.Visible = false
        T(self.Main, .22, {
            Size = UDim2.fromOffset(self.C.Size.X, 64)
        })
    else
        self.Body.Visible = true
        T(self.Main, .22, {
            Size = UDim2.fromOffset(self.C.Size.X, self.C.Size.Y)
        })
    end
end

function Library:SetParticlesEnabled(v)
    self.Particles = v == true
end

function Library:SetAnimationsEnabled(v)
    self.Animations = v == true
end

--============================================================
-- TABS
--============================================================

function Library:CreateTab(name, icon)
    local t = { Library = self, Name = name, Elements = {} }
    self.Tabs[name] = t

    local b = n("TextButton", {
        Size = UDim2.new(1, 0, 0, 42),
        BackgroundColor3 = Color3.fromRGB(10, 13, 18),
        BorderSizePixel = 0,
        AutoButtonColor = false,
        Text = "",
        ZIndex = 10
    }, self.TabList)
    co(b, 10)

    local ib = n("Frame", {
        Position = UDim2.fromOffset(8, 8),
        Size = UDim2.fromOffset(26, 26),
        BackgroundColor3 = Color3.fromRGB(19, 24, 33),
        BorderSizePixel = 0,
        ZIndex = 11
    }, b)
    co(ib, 8)

    n("TextLabel", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Text = icon or name:sub(1, 1):upper(),
        TextColor3 = self.C.Muted,
        Font = Enum.Font.GothamBold,
        TextSize = 10,
        ZIndex = 12
    }, ib)

    local tx = n("TextLabel", {
        Position = UDim2.fromOffset(44, 0),
        Size = UDim2.new(1, -50, 1, 0),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = self.C.Muted,
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 11
    }, b)

    local page = n("Frame", {
        Size = UDim2.fromScale(1, 1),
        BackgroundTransparency = 1,
        Visible = false,
        ZIndex = 10
    }, self.Pages)

    n("TextLabel", {
        Position = UDim2.fromOffset(22, 18),
        Size = UDim2.new(1, -44, 0, 28),
        BackgroundTransparency = 1,
        Text = name,
        TextColor3 = self.C.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 22,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 13
    }, page)

    local search = n("TextBox", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -22, 0, 18),
        Size = UDim2.fromOffset(190, 34),
        BackgroundColor3 = Color3.fromRGB(13, 17, 24),
        BorderSizePixel = 0,
        PlaceholderText = "search...",
        PlaceholderColor3 = self.C.Muted,
        Text = "",
        TextColor3 = self.C.Text,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        ClearTextOnFocus = false,
        ZIndex = 14
    }, page)
    co(search, 10)
    st(search, self.C.Border, .3)

    local scroll = n("ScrollingFrame", {
        Position = UDim2.fromOffset(22, 68),
        Size = UDim2.new(1, -44, 1, -90),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 2,
        CanvasSize = UDim2.new(),
        AutomaticCanvasSize = Enum.AutomaticSize.Y,
        ZIndex = 12
    }, page)
    n("UIListLayout", { Padding = UDim.new(0, 9) }, scroll)

    t.Button = b
    t.Page = page
    t.Scroll = scroll
    t.Search = search

    self:con(b.MouseButton1Click, function()
        self:SetTab(name)
    end)

    self:con(search:GetPropertyChangedSignal("Text"), function()
        local q = search.Text:lower()
        for _, e in ipairs(t.Elements) do
            if e.Root and e.Root.Parent then
                e.Root.Visible = q == ""
                    or tostring(e.Search):lower():find(q, 1, true) ~= nil
            end
        end
    end)

    if not self.CurrentTab then
        self:SetTab(name)
    end

    return t
end

function Library:SetTab(name)
    local t = self.Tabs[name]
    if not t then return end
    self.CurrentTab = t

    for _, x in pairs(self.Tabs) do
        local a = x == t
        x.Page.Visible = a
        x.Button.BackgroundColor3 = a
            and Color3.fromRGB(22, 29, 41)
            or Color3.fromRGB(10, 13, 18)

        local label = x.Button:FindFirstChildOfClass("TextLabel")
        if label then
            label.TextColor3 = a and self.C.Text or self.C.Muted
        end
    end
end

function Library:add(tab, root, text)
    table.insert(tab.Elements, {
        Root = root,
        Search = text or ""
    })
end

--============================================================
-- COMPONENTS
--============================================================

function Library:Section(tab, text)
    local r = n("TextLabel", {
        Size = UDim2.new(1, 0, 0, 24),
        BackgroundTransparency = 1,
        Text = text:upper(),
        TextColor3 = self.C.Muted,
        Font = Enum.Font.GothamBold,
        TextSize = 9,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 13
    }, tab.Scroll)
    self:add(tab, r, text)
    return r
end

function Library:Label(tab, text)
    local r = n("TextLabel", {
        Size = UDim2.new(1, 0, 0, 44),
        BackgroundColor3 = self.C.Panel,
        BorderSizePixel = 0,
        Text = text,
        TextColor3 = self.C.Muted,
        Font = Enum.Font.Gotham,
        TextSize = 11,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 13
    }, tab.Scroll)
    co(r, 12)
    st(r, self.C.Border, .4)
    n("UIPadding", {
        PaddingLeft = UDim.new(0, 14),
        PaddingRight = UDim.new(0, 14)
    }, r)
    self:add(tab, r, text)
    return r
end

function Library:Button(tab, o)
    local r = n("Frame", {
        Size = UDim2.new(1, 0, 0, 64),
        BackgroundColor3 = self.C.Panel,
        BorderSizePixel = 0,
        ZIndex = 13
    }, tab.Scroll)
    co(r, 12)
    st(r, self.C.Border, .4)
    self:add(tab, r, (o.Name or "button") .. " " .. (o.Description or ""))

    n("TextLabel", {
        Position = UDim2.fromOffset(14, 9),
        Size = UDim2.new(1, -145, 0, 20),
        BackgroundTransparency = 1,
        Text = o.Name or "button",
        TextColor3 = self.C.Text,
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 14
    }, r)

    n("TextLabel", {
        Position = UDim2.fromOffset(14, 30),
        Size = UDim2.new(1, -145, 0, 25),
        BackgroundTransparency = 1,
        Text = o.Description or "",
        TextColor3 = self.C.Muted,
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 14
    }, r)

    local b = n("TextButton", {
        AnchorPoint = Vector2.new(1, .5),
        Position = UDim2.new(1, -12, .5, 0),
        Size = UDim2.fromOffset(105, 34),
        BackgroundColor3 = self.C.Accent,
        BorderSizePixel = 0,
        Text = "run",
        TextColor3 = Color3.new(1, 1, 1),
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        AutoButtonColor = false,
        ZIndex = 15
    }, r)
    co(b, 9)

    self:con(b.MouseButton1Click, function()
        safeCall(o.Callback)
    end)

    return r
end

function Library:Toggle(tab, o)
    local state = o.Default == true

    local r = n("Frame", {
        Size = UDim2.new(1, 0, 0, 64),
        BackgroundColor3 = self.C.Panel,
        BorderSizePixel = 0,
        ZIndex = 13
    }, tab.Scroll)
    co(r, 12)
    st(r, self.C.Border, .4)
    self:add(tab, r, (o.Name or "toggle") .. " " .. (o.Description or ""))

    n("TextLabel", {
        Position = UDim2.fromOffset(14, 9),
        Size = UDim2.new(1, -90, 0, 20),
        BackgroundTransparency = 1,
        Text = o.Name or "toggle",
        TextColor3 = self.C.Text,
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 14
    }, r)

    n("TextLabel", {
        Position = UDim2.fromOffset(14, 30),
        Size = UDim2.new(1, -90, 0, 25),
        BackgroundTransparency = 1,
        Text = o.Description or "",
        TextColor3 = self.C.Muted,
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 14
    }, r)

    local b = n("TextButton", {
        AnchorPoint = Vector2.new(1, .5),
        Position = UDim2.new(1, -14, .5, 0),
        Size = UDim2.fromOffset(48, 26),
        BackgroundColor3 = state and self.C.Accent or Color3.fromRGB(29, 35, 46),
        BorderSizePixel = 0,
        Text = "",
        AutoButtonColor = false,
        ZIndex = 15
    }, r)
    co(b, 13)

    local k = n("Frame", {
        AnchorPoint = Vector2.new(0, .5),
        Position = state and UDim2.new(1, -22, .5, 0) or UDim2.new(0, 4, .5, 0),
        Size = UDim2.fromOffset(18, 18),
        BackgroundColor3 = Color3.new(1, 1, 1),
        BorderSizePixel = 0,
        ZIndex = 16
    }, b)
    co(k, 9)

    local function set(v, fire)
        state = v == true
        T(b, .15, {
            BackgroundColor3 = state and self.C.Accent or Color3.fromRGB(29, 35, 46)
        })
        T(k, .15, {
            Position = state and UDim2.new(1, -22, .5, 0) or UDim2.new(0, 4, .5, 0)
        })
        if fire then
            safeCall(o.Callback, state)
        end
    end

    self:con(b.MouseButton1Click, function()
        set(not state, true)
    end)

    return {
        Set = function(_, v) set(v, true) end,
        Get = function() return state end
    }
end

function Library:Slider(tab, o)
    local min = o.Min or 0
    local max = o.Max or 100
    local val = math.clamp(o.Default or min, min, max)

    local r = n("Frame", {
        Size = UDim2.new(1, 0, 0, 78),
        BackgroundColor3 = self.C.Panel,
        BorderSizePixel = 0,
        ZIndex = 13
    }, tab.Scroll)
    co(r, 12)
    st(r, self.C.Border, .4)
    self:add(tab, r, (o.Name or "slider") .. " " .. (o.Description or ""))

    n("TextLabel", {
        Position = UDim2.fromOffset(14, 9),
        Size = UDim2.new(1, -100, 0, 20),
        BackgroundTransparency = 1,
        Text = o.Name or "slider",
        TextColor3 = self.C.Text,
        Font = Enum.Font.GothamMedium,
        TextSize = 12,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 14
    }, r)

    local vl = n("TextLabel", {
        AnchorPoint = Vector2.new(1, 0),
        Position = UDim2.new(1, -14, 0, 9),
        Size = UDim2.fromOffset(70, 20),
        BackgroundTransparency = 1,
        Text = tostring(val),
        TextColor3 = self.C.Accent2,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Right,
        ZIndex = 14
    }, r)

    n("TextLabel", {
        Position = UDim2.fromOffset(14, 30),
        Size = UDim2.new(1, -28, 0, 16),
        BackgroundTransparency = 1,
        Text = o.Description or "",
        TextColor3 = self.C.Muted,
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 14
    }, r)

    local bar = n("Frame", {
        Position = UDim2.fromOffset(14, 55),
        Size = UDim2.new(1, -28, 0, 6),
        BackgroundColor3 = Color3.fromRGB(29, 35, 46),
        BorderSizePixel = 0,
        Active = true,
        ZIndex = 15
    }, r)
    co(bar, 4)

    local fill = n("Frame", {
        Size = UDim2.fromScale((val - min) / (max - min), 1),
        BackgroundColor3 = self.C.Accent,
        BorderSizePixel = 0,
        ZIndex = 16
    }, bar)
    co(fill, 4)

    local drag = false

    local function set(v, fire)
        val = math.clamp(v, min, max)
        local a = (val - min) / (max - min)
        fill.Size = UDim2.fromScale(a, 1)
        vl.Text = tostring(math.floor(val * 100) / 100)
        if fire then
            safeCall(o.Callback, val)
        end
    end

    local function upd(i)
        set(
            min + (max - min) * math.clamp(
                (i.Position.X - bar.AbsolutePosition.X) / bar.AbsoluteSize.X,
                0,
                1
            ),
            true
        )
    end

    self:con(bar.InputBegan, function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then
            drag = true
            upd(i)
        end
    end)

    self:con(UIS.InputChanged, function(i)
        if drag and (
            i.UserInputType == Enum.UserInputType.MouseMovement
            or i.UserInputType == Enum.UserInputType.Touch
        ) then
            upd(i)
        end
    end)

    self:con(UIS.InputEnded, function(i)
        if i.UserInputType == Enum.UserInputType.MouseButton1
            or i.UserInputType == Enum.UserInputType.Touch then
            drag = false
        end
    end)

    return {
        Set = function(_, v) set(v, true) end,
        Get = function() return val end
    }
end

--============================================================
-- NOTIFY
--============================================================

function Library:Notify(o)
    local holder = self.Gui:FindFirstChild("Notifications")
        or n("Frame", {
            Name = "Notifications",
            AnchorPoint = Vector2.new(1, 1),
            Position = UDim2.new(1, -18, 1, -18),
            Size = UDim2.fromOffset(310, 360),
            BackgroundTransparency = 1,
            ZIndex = 100
        }, self.Gui)

    if not holder:FindFirstChildOfClass("UIListLayout") then
        n("UIListLayout", {
            Padding = UDim.new(0, 8),
            VerticalAlignment = Enum.VerticalAlignment.Bottom,
            HorizontalAlignment = Enum.HorizontalAlignment.Right
        }, holder)
    end

    local r = n("Frame", {
        Size = UDim2.fromOffset(290, 62),
        BackgroundColor3 = Color3.fromRGB(12, 16, 23),
        BorderSizePixel = 0,
        ZIndex = 101
    }, holder)
    co(r, 12)
    st(r, self.C.Border, .25)

    n("TextLabel", {
        Position = UDim2.fromOffset(14, 8),
        Size = UDim2.new(1, -28, 0, 18),
        BackgroundTransparency = 1,
        Text = o.Title or "notification",
        TextColor3 = self.C.Text,
        Font = Enum.Font.GothamBold,
        TextSize = 11,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 102
    }, r)

    n("TextLabel", {
        Position = UDim2.fromOffset(14, 28),
        Size = UDim2.new(1, -28, 0, 27),
        BackgroundTransparency = 1,
        Text = o.Content or "",
        TextColor3 = self.C.Muted,
        Font = Enum.Font.Gotham,
        TextSize = 10,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        ZIndex = 102
    }, r)

    task.delay(o.Duration or 3, function()
        if r and r.Parent then
            local anim = T(r, .18, {
                BackgroundTransparency = 1,
                Position = UDim2.fromOffset(25, 0)
            })
            anim.Completed:Wait()
            if r and r.Parent then
                r:Destroy()
            end
        end
    end)
end

--============================================================
-- DESTROY
--============================================================

function Library:Destroy()
    self.Destroyed = true

    for _, c in ipairs(self.Con) do
        pcall(function() c:Disconnect() end)
    end

    if self.Gui then
        self.Gui:Destroy()
    end
end

--============================================================
-- REGISTER GLOBALLY + RETURN
--============================================================

__MAX_ENV.__MAXXTEAM_LIB = Library
__MAX_ENV.__MAXXTEAM_LIB_VER = "v5"

return Library