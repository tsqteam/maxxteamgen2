# maxxteam v5

Standalone Roblox Lua UI library.

## structure
```text
maxxteam-v5/
├── src/maxxteam.lua
├── examples/basic.lua
└── README.md
```

## install
Put `src/maxxteam.lua` into a `ModuleScript` named `maxxteam` inside `ReplicatedStorage`.
Use the library from a `LocalScript` (for example `StarterPlayerScripts`).

## basic
```lua
local RS=game:GetService("ReplicatedStorage")
local Maxxteam=require(RS:WaitForChild("maxxteam"))

local UI=Maxxteam.new()
local Main=UI:CreateTab("main","M")
local Player=UI:CreateTab("player","P")

Main.Library:Section(Main,"quick actions")

Main.Library:Button(Main,{
 Name="test notification",
 Description="Tests the button callback.",
 Callback=function()
  UI:Notify({Title="test",Content="button works",Duration=2})
 end
})

local toggle=Main.Library:Toggle(Main,{
 Name="particles",
 Description="Enable or disable particles.",
 Default=true,
 Callback=function(v) UI:SetParticlesEnabled(v) end
})

local slider=Player.Library:Slider(Player,{
 Name="test value",
 Description="Example slider.",
 Min=0,Max=100,Default=50,
 Callback=function(v) print("value",v) end
})
```

## API

### tabs
```lua
local Tab=UI:CreateTab("main","M")
UI:SetTab("main")
```

### section / label
```lua
Tab.Library:Section(Tab,"quick actions")
Tab.Library:Label(Tab,"some information")
```

### button
```lua
Tab.Library:Button(Tab,{
 Name="run test",
 Description="Does something.",
 Callback=function()
   print("clicked")
 end
})
```

### toggle
```lua
local x=Tab.Library:Toggle(Tab,{
 Name="enabled",
 Description="Boolean setting.",
 Default=false,
 Callback=function(enabled)
   print(enabled)
 end
})

x:Set(true)
print(x:Get())
```

### slider
```lua
local x=Tab.Library:Slider(Tab,{
 Name="speed",
 Description="Numeric value.",
 Min=0,Max=100,Default=25,
 Callback=function(value)
   print(value)
 end
})
x:Set(75)
print(x:Get())
```

### notifications
```lua
UI:Notify({
 Title="maxxteam",
 Content="hello",
 Duration=3
})
```

### window
`RightShift` toggles the UI by default.
```lua
UI:SetOpen(true)
UI:SetOpen(false)
UI:SetMinimized(true)
UI:SetMinimized(false)
UI:Destroy()
```

### effects
```lua
UI:SetParticlesEnabled(false)
UI:SetParticlesEnabled(true)
UI:SetAnimationsEnabled(false)
UI:SetAnimationsEnabled(true)
```

## test features included
The library itself contains working testable controls: buttons, toggles, sliders, search, notifications, particles, animation toggle support, minimize, close/open and dragging.

## GitHub
Upload the folder as a repository. In Roblox, you normally keep the ModuleScript copy inside Studio. GitHub is useful as the source/versioning location.

The library is a UI framework and does not provide exploit/cheat functionality.
