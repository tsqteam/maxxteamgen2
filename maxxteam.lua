-- maxxteam lib, injector build
-- load: loadstring(game:HttpGet(".../maxxteam.lua"))()

local env = (getgenv and getgenv()) or _G or shared
if env.__maxxteam_lib and env.__maxxteam_ver == "v5" then return env.__maxxteam_lib end

local Players = game:GetService('Players')
local TweenService = game:GetService('TweenService')
local UIS = game:GetService('UserInputService')
local RunService = game:GetService('RunService')

local me = Players.LocalPlayer
local pg = me:FindFirstChildOfClass('PlayerGui') or me:WaitForChild('PlayerGui', 10)
if not pg then warn('[maxxteam] no PlayerGui'); return nil end

local lib = {}
lib.__index = lib

local blue = Color3.fromRGB(38, 111, 218)
local blue2 = Color3.fromRGB(67, 143, 255)
local bg = Color3.fromRGB(10, 12, 16)
local panel = Color3.fromRGB(15, 18, 24)
local panel2 = Color3.fromRGB(19, 23, 30)
local text = Color3.fromRGB(224, 228, 235)
local dim = Color3.fromRGB(126, 134, 148)

local function mk(c, p, par)
    local o = Instance.new(c)
    for k,v in pairs(p or {}) do o[k] = v end
    o.Parent = par
    return o
end

local function corner(o, r)
    mk('UICorner', {CornerRadius=UDim.new(0,r or 7)}, o)
end

local function tween(o, t, props)
    return TweenService:Create(o, TweenInfo.new(t or .18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), props)
end

function lib.new(opts)
    opts = opts or {}
    local self = setmetatable({}, lib)
    self.tabs = {}
    self.current = nil
    self.open = true
    self.min = false
    self.particles = opts.particles ~= false
    self.anims = opts.animations ~= false
    self._stuff = {}
    self._conns = {}

    -- kill old instance if re-injected
    local old = pg:FindFirstChild('maxxteam')
    if old then old:Destroy() end

    local gui = mk('ScreenGui', {Name='maxxteam', ResetOnSpawn=false, IgnoreGuiInset=true, ZIndexBehavior=Enum.ZIndexBehavior.Sibling, DisplayOrder=999}, pg)
    self.Gui = gui

    local root = mk('Frame', {
        Name='Root', AnchorPoint=Vector2.new(.5,.5), Position=UDim2.fromScale(.5,.5),
        Size=UDim2.fromOffset(opts.width or 720, opts.height or 440),
        BackgroundColor3=bg, BorderSizePixel=0, ClipsDescendants=true
    }, gui)
    corner(root, 10)
    self.Main = root

    local edge = mk('Frame',{Name='Edge',Position=UDim2.fromOffset(0,0),Size=UDim2.new(1,0,1,0),BackgroundTransparency=1},root)
    corner(edge,10)
    mk('UIStroke',{Color=Color3.fromRGB(42,50,64),Transparency=.28,Thickness=1},edge)

    local top = mk('Frame',{Name='Top',Size=UDim2.new(1,0,0,52),BackgroundColor3=Color3.fromRGB(12,15,20),BorderSizePixel=0},root)
    local title = mk('TextLabel',{Name='Title',BackgroundTransparency=1,Position=UDim2.fromOffset(18,8),Size=UDim2.fromOffset(220,22),Font=Enum.Font.SourceSansSemibold,Text='maxxteam',TextColor3=text,TextSize=19,TextXAlignment=Enum.TextXAlignment.Left},top)
    local sub = mk('TextLabel',{BackgroundTransparency=1,Position=UDim2.fromOffset(19,29),Size=UDim2.fromOffset(250,16),Font=Enum.Font.SourceSans,Text=opts.subtitle or 'ui library',TextColor3=dim,TextSize=12,TextXAlignment=Enum.TextXAlignment.Left},top)

    local mini = mk('TextButton',{Name='Min',AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-45,0,13),Size=UDim2.fromOffset(28,26),BackgroundColor3=panel2,BorderSizePixel=0,Text='—',TextColor3=dim,Font=Enum.Font.Arial,TextSize=15,AutoButtonColor=false},top)
    corner(mini,5)
    local close = mk('TextButton',{Name='Close',AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-12,0,13),Size=UDim2.fromOffset(28,26),BackgroundColor3=panel2,BorderSizePixel=0,Text='×',TextColor3=dim,Font=Enum.Font.Arial,TextSize=18,AutoButtonColor=false},top)
    corner(close,5)

    local body = mk('Frame',{Name='Body',Position=UDim2.fromOffset(0,52),Size=UDim2.new(1,0,1,-52),BackgroundTransparency=1},root)
    local side = mk('Frame',{Name='Side',BackgroundColor3=Color3.fromRGB(12,15,20),BorderSizePixel=0},body)
    side.Size=UDim2.new(0,154,1,0)
    local line=mk('Frame',{BackgroundColor3=Color3.fromRGB(28,34,43),BorderSizePixel=0,Position=UDim2.new(1,-1,0,0),Size=UDim2.new(0,1,1,0)},side)
    local list=mk('ScrollingFrame',{Name='Tabs',BackgroundTransparency=1,Position=UDim2.fromOffset(10,12),Size=UDim2.new(1,-20,1,-24),BorderSizePixel=0,ScrollBarThickness=0,CanvasSize=UDim2.new()},side)
    local ll=mk('UIListLayout',{Padding=UDim.new(0,5),SortOrder=Enum.SortOrder.LayoutOrder},list)
    ll:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function() list.CanvasSize=UDim2.fromOffset(0,ll.AbsoluteContentSize.Y+4) end)

    local content=mk('Frame',{Name='Content',Position=UDim2.fromOffset(154,0),Size=UDim2.new(1,-154,1,0),BackgroundColor3=Color3.fromRGB(9,11,15),BorderSizePixel=0,ClipsDescendants=true},body)
    self.Content=content

    local fx=mk('Frame',{Name='FX',Size=UDim2.fromScale(1,1),BackgroundTransparency=1,ClipsDescendants=true},content)
    self.fx=fx
    local dots={}
    for i=1,18 do
        local d=mk('Frame',{Size=UDim2.fromOffset(math.random(1,3),math.random(1,3)),Position=UDim2.fromScale(math.random(),math.random()),BackgroundColor3=blue2,BackgroundTransparency=.78,BorderSizePixel=0},fx)
        corner(d,8)
        dots[#dots+1]=d
    end
    self.dots=dots

    local pages=mk('Frame',{Name='Pages',Size=UDim2.fromScale(1,1),BackgroundTransparency=1},content)
    self.Pages=pages

    local drag=false
    local dragStart, startPos
    self._conns[#self._conns+1] = top.InputBegan:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then
            drag=true; dragStart=i.Position; startPos=root.Position
        end
    end)
    self._conns[#self._conns+1] = UIS.InputChanged:Connect(function(i)
        if drag and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then
            local d=i.Position-dragStart
            root.Position=UDim2.new(startPos.X.Scale,startPos.X.Offset+d.X,startPos.Y.Scale,startPos.Y.Offset+d.Y)
        end
    end)
    self._conns[#self._conns+1] = UIS.InputEnded:Connect(function(i)
        if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then drag=false end
    end)

    self._conns[#self._conns+1] = mini.MouseButton1Click:Connect(function() self:SetMinimized(not self.min) end)
    self._conns[#self._conns+1] = close.MouseButton1Click:Connect(function() self:SetOpen(false) end)
    self._conns[#self._conns+1] = UIS.InputBegan:Connect(function(i,gp)
        if not gp and i.KeyCode==Enum.KeyCode.RightShift then self:SetOpen(not self.open) end
    end)

    self._render=RunService.RenderStepped:Connect(function(dt)
        if not self.Gui or not self.Gui.Parent then return end
        if self.particles then
            for n,d in ipairs(dots) do
                local p=d.Position
                d.Position=UDim2.fromScale(p.X.Scale, (p.Y.Scale-dt*(.008+n%3*.002))%1)
            end
        end
    end)

    return self
end

function lib:CreateTab(name, icon)
    local page=mk('ScrollingFrame',{Name=name,Size=UDim2.fromScale(1,1),BackgroundTransparency=1,BorderSizePixel=0,ScrollBarThickness=3,ScrollBarImageColor3=Color3.fromRGB(65,74,90),Visible=false,CanvasSize=UDim2.new()},self.Pages)
    local pad=mk('UIPadding',{PaddingTop=UDim.new(0,18),PaddingLeft=UDim.new(0,18),PaddingRight=UDim.new(0,18),PaddingBottom=UDim.new(0,18)},page)
    local grid=mk('UIListLayout',{Padding=UDim.new(0,9),SortOrder=Enum.SortOrder.LayoutOrder},page)
    grid:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(function() page.CanvasSize=UDim2.fromOffset(0,grid.AbsoluteContentSize.Y+36) end)

    local b=mk('TextButton',{Name=name,Size=UDim2.new(1,0,0,35),BackgroundColor3=panel2,BackgroundTransparency=1,BorderSizePixel=0,Text='',AutoButtonColor=false},self.Gui.Root.Body.Side.Tabs)
    corner(b,6)
    local ic=mk('TextLabel',{BackgroundTransparency=1,Position=UDim2.fromOffset(10,0),Size=UDim2.fromOffset(22,35),Font=Enum.Font.Arial,Text=icon or '•',TextColor3=dim,TextSize=14},b)
    local tx=mk('TextLabel',{BackgroundTransparency=1,Position=UDim2.fromOffset(34,0),Size=UDim2.new(1,-42,1,0),Font=Enum.Font.SourceSans,Text=name,TextColor3=dim,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left},b)
    local tab={Name=name,Page=page,Button=b,Items={},Search=function() end,Library=self}
    table.insert(self.tabs,tab)
    b.MouseButton1Click:Connect(function() self:SetTab(tab) end)
    if not self.current then self:SetTab(tab) end
    return tab
end

function lib:SetTab(tab)
    if not tab then return end
    self.current=tab
    for _,x in ipairs(self.tabs) do
        local on=x==tab
        x.Page.Visible=on
        x.Button.BackgroundTransparency=on and .08 or 1
        for _,lbl in ipairs(x.Button:GetChildren()) do
            if lbl:IsA('TextLabel') and lbl.Text==x.Name then
                lbl.TextColor3=on and text or dim
            end
        end
    end
end

local function titleLine(parent, s)
    local t=mk('TextLabel',{Size=UDim2.new(1,0,0,24),BackgroundTransparency=1,Font=Enum.Font.SourceSansSemibold,Text=s,TextColor3=text,TextSize=16,TextXAlignment=Enum.TextXAlignment.Left},parent)
    return t
end

function lib:Section(tab, name)
    local f=mk('Frame',{Name='Section',Size=UDim2.new(1,0,0,24),BackgroundTransparency=1},tab.Page)
    titleLine(f,name)
    return f
end

function lib:Label(tab, textValue)
    local l=mk('TextLabel',{Name='Label',Size=UDim2.new(1,0,0,25),BackgroundTransparency=1,Font=Enum.Font.SourceSans,Text=textValue,TextColor3=dim,TextSize=14,TextXAlignment=Enum.TextXAlignment.Left},tab.Page)
    return l
end

function lib:Button(tab, data)
    data=data or {}
    local b=mk('TextButton',{Name=data.Name or 'button',Size=UDim2.new(1,0,0,42),BackgroundColor3=panel2,BorderSizePixel=0,AutoButtonColor=false,Text='',LayoutOrder=data.LayoutOrder or 0},tab.Page)
    corner(b,7)
    local st=mk('UIStroke',{Color=Color3.fromRGB(32,39,50),Transparency=.25,Thickness=1},b)
    local t=mk('TextLabel',{BackgroundTransparency=1,Position=UDim2.fromOffset(13,0),Size=UDim2.new(1,-26,1,0),Font=Enum.Font.SourceSansSemibold,Text=data.Name or 'button',TextColor3=text,TextSize=15,TextXAlignment=Enum.TextXAlignment.Left},b)
    if data.Description then
        t.Size=UDim2.new(1,-26,0,21); t.Position=UDim2.fromOffset(13,4)
        mk('TextLabel',{BackgroundTransparency=1,Position=UDim2.fromOffset(13,22),Size=UDim2.new(1,-26,0,15),Font=Enum.Font.Arial,Text=data.Description,TextColor3=dim,TextSize=11,TextXAlignment=Enum.TextXAlignment.Left},b)
        b.Size=UDim2.new(1,0,0,48)
    end
    b.MouseButton1Click:Connect(function()
        tween(b,.08,{BackgroundColor3=Color3.fromRGB(30,37,49)}):Play()
        task.delay(.09,function() if b.Parent then tween(b,.14,{BackgroundColor3=panel2}):Play() end end)
        if data.Callback then
            local ok,err = pcall(data.Callback)
            if not ok then warn('[maxxteam] button cb:',err) end
        end
    end)
    return b
end

function lib:Toggle(tab, data)
    data=data or {}
    local val=data.Default==true
    local b=mk('TextButton',{Name=data.Name or 'toggle',Size=UDim2.new(1,0,0,46),BackgroundColor3=panel2,BorderSizePixel=0,AutoButtonColor=false,Text=''},tab.Page)
    corner(b,7)
    local tx=mk('TextLabel',{BackgroundTransparency=1,Position=UDim2.fromOffset(13,0),Size=UDim2.new(1,-75,1,0),Font=Enum.Font.SourceSansSemibold,Text=data.Name or 'toggle',TextColor3=text,TextSize=15,TextXAlignment=Enum.TextXAlignment.Left},b)
    local box=mk('Frame',{AnchorPoint=Vector2.new(1,.5),Position=UDim2.new(1,-13,.5,0),Size=UDim2.fromOffset(38,20),BackgroundColor3=Color3.fromRGB(34,39,48),BorderSizePixel=0},b)
    corner(box,10)
    local ball=mk('Frame',{Position=UDim2.fromOffset(3,3),Size=UDim2.fromOffset(14,14),BackgroundColor3=Color3.fromRGB(178,185,196),BorderSizePixel=0},box)
    corner(ball,8)
    local obj={Button=b,Value=val}
    local function paint()
        tween(box,.16,{BackgroundColor3=val and blue or Color3.fromRGB(34,39,48)}):Play()
        tween(ball,.16,{Position=val and UDim2.fromOffset(21,3) or UDim2.fromOffset(3,3),BackgroundColor3=val and Color3.new(1,1,1) or Color3.fromRGB(178,185,196)}):Play()
    end
    function obj:Set(v)
        val=not not v; obj.Value=val; paint()
        if data.Callback then
            local ok,err = pcall(data.Callback,val)
            if not ok then warn('[maxxteam] toggle cb:',err) end
        end
    end
    function obj:Get() return val end
    b.MouseButton1Click:Connect(function() obj:Set(not val) end)
    paint()
    return obj
end

function lib:Slider(tab, data)
    data=data or {}
    local lo=data.Min or 0; local hi=data.Max or 100; local val=data.Default or lo
    local f=mk('Frame',{Name=data.Name or 'slider',Size=UDim2.new(1,0,0,62),BackgroundColor3=panel2,BorderSizePixel=0},tab.Page)
    corner(f,7)
    local label=mk('TextLabel',{BackgroundTransparency=1,Position=UDim2.fromOffset(13,7),Size=UDim2.new(1,-70,0,20),Font=Enum.Font.SourceSansSemibold,Text=data.Name or 'slider',TextColor3=text,TextSize=15,TextXAlignment=Enum.TextXAlignment.Left},f)
    local number=mk('TextLabel',{AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-13,0,7),Size=UDim2.fromOffset(50,20),BackgroundTransparency=1,Font=Enum.Font.Arial,TextColor3=dim,TextSize=13,Text=tostring(val),TextXAlignment=Enum.TextXAlignment.Right},f)
    local bar=mk('Frame',{Position=UDim2.new(0,13,0,38),Size=UDim2.new(1,-26,0,5),BackgroundColor3=Color3.fromRGB(35,41,51),BorderSizePixel=0},f)
    corner(bar,4)
    local fill=mk('Frame',{Size=UDim2.new(0,0,1,0),BackgroundColor3=blue,BorderSizePixel=0},bar)
    corner(fill,4)
    local knob=mk('Frame',{AnchorPoint=Vector2.new(.5,.5),Position=UDim2.new(0,0,.5,0),Size=UDim2.fromOffset(12,12),BackgroundColor3=Color3.fromRGB(228,233,241),BorderSizePixel=0},bar)
    corner(knob,8)
    local obj={Value=val}
    local function set(v, cb)
        val=math.clamp(v,lo,hi); obj.Value=val
        local q=(val-lo)/(hi-lo == 0 and 1 or hi-lo)
        fill.Size=UDim2.new(q,0,1,0); knob.Position=UDim2.new(q,0,.5,0); number.Text=tostring(math.floor(val*100+.5)/100)
        if cb and data.Callback then
            local ok,err = pcall(data.Callback,val)
            if not ok then warn('[maxxteam] slider cb:',err) end
        end
    end
    function obj:Set(v) set(v,true) end
    function obj:Get() return val end
    local down=false
    local function mouse(x)
        set(lo+(hi-lo)*math.clamp((x-bar.AbsolutePosition.X)/bar.AbsoluteSize.X,0,1),true)
    end
    bar.InputBegan:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then down=true; mouse(i.Position.X) end end)
    UIS.InputChanged:Connect(function(i) if down and (i.UserInputType==Enum.UserInputType.MouseMovement or i.UserInputType==Enum.UserInputType.Touch) then mouse(i.Position.X) end end)
    UIS.InputEnded:Connect(function(i) if i.UserInputType==Enum.UserInputType.MouseButton1 or i.UserInputType==Enum.UserInputType.Touch then down=false end end)
    set(val,false)
    return obj
end

function lib:Notify(data)
    data=data or {}
    local holder=self.Gui:FindFirstChild('Notifications')
    if not holder then
        holder=mk('Frame',{Name='Notifications',AnchorPoint=Vector2.new(1,1),Position=UDim2.new(1,-18,1,-18),Size=UDim2.fromOffset(310,400),BackgroundTransparency=1},self.Gui)
        local ll=mk('UIListLayout',{VerticalAlignment=Enum.VerticalAlignment.Bottom,HorizontalAlignment=Enum.HorizontalAlignment.Right,Padding=UDim.new(0,7)},holder)
    end
    local n=mk('Frame',{Size=UDim2.fromOffset(290,62),BackgroundColor3=Color3.fromRGB(16,20,27),BorderSizePixel=0},holder)
    corner(n,7)
    mk('Frame',{Size=UDim2.new(0,3,1,0),BackgroundColor3=blue,BorderSizePixel=0},n)
    mk('TextLabel',{BackgroundTransparency=1,Position=UDim2.fromOffset(13,7),Size=UDim2.new(1,-24,0,20),Font=Enum.Font.SourceSansSemibold,Text=data.Title or 'maxxteam',TextColor3=text,TextSize=15,TextXAlignment=Enum.TextXAlignment.Left},n)
    mk('TextLabel',{BackgroundTransparency=1,Position=UDim2.fromOffset(13,28),Size=UDim2.new(1,-24,0,26),Font=Enum.Font.SourceSans,Text=data.Content or '',TextColor3=dim,TextSize=12,TextWrapped=true,TextXAlignment=Enum.TextXAlignment.Left},n)
    n.Position=UDim2.new(1,25,0,0)
    tween(n,.2,{Position=UDim2.new(0,0,0,0)}):Play()
    task.delay(data.Duration or 3,function()
        if n and n.Parent then
            tween(n,.18,{BackgroundTransparency=1,Position=UDim2.new(1,25,0,0)}):Play()
            task.wait(.2)
            if n and n.Parent then n:Destroy() end
        end
    end)
end

function lib:SetOpen(v)
    self.open=not not v
    if self.open then
        self.Gui.Enabled=true
        self.Main.Visible=true
        self.Main.BackgroundTransparency=1
        tween(self.Main,.18,{BackgroundTransparency=0}):Play()
    else
        tween(self.Main,.14,{BackgroundTransparency=1}):Play()
        task.delay(.15,function() if not self.open and self.Gui then self.Gui.Enabled=false end end)
    end
end

function lib:SetMinimized(v)
    self.min=not not v
    local body=self.Main:FindFirstChild('Body')
    if self.min then
        body.Visible=false
        tween(self.Main,.2,{Size=UDim2.fromOffset(720,52)}):Play()
    else
        body.Visible=true
        tween(self.Main,.2,{Size=UDim2.fromOffset(720,440)}):Play()
    end
end

function lib:SetParticlesEnabled(v)
    self.particles=not not v
    for _,d in ipairs(self.dots) do d.Visible=self.particles end
end
function lib:SetAnimationsEnabled(v) self.anims=not not v end

function lib:Destroy()
    if self._render then self._render:Disconnect() end
    for _,c in ipairs(self._conns or {}) do pcall(function() c:Disconnect() end) end
    if self.Gui then self.Gui:Destroy() end
    table.clear(self)
end

env.__maxxteam_lib = lib
env.__maxxteam_ver = "v5"

return lib