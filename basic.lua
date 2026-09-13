-- example usage of maxxteam, injector build
-- load after maxxteam.lua

local env = (getgenv and getgenv()) or _G or shared
local maxxteam = env.__maxxteam_lib

if not maxxteam then
    local ok, res = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/tsqteam/maxxteamgen2/refs/heads/main/src/maxxteam.lua"))()
    end)
    if ok and res then maxxteam = res end
end

if not maxxteam then
    warn('[basic] maxxteam lib not found')
    return
end

local ui = maxxteam.new({ subtitle = 'example / v5' })

local main = ui:CreateTab('main','M')
local player = ui:CreateTab('player','P')
local visual = ui:CreateTab('visuals','V')
local config = ui:CreateTab('config','C')

ui:Section(main,'quick test')
ui:Button(main,{Name='test notification',Description='just checks that callbacks work',Callback=function()
    ui:Notify({Title='maxxteam',Content='button works'})
end})

ui:Toggle(main,{Name='particles',Default=true,Callback=function(v) ui:SetParticlesEnabled(v) end})
ui:Toggle(main,{Name='animations',Default=true,Callback=function(v) ui:SetAnimationsEnabled(v) end})
local slider=ui:Slider(main,{Name='test value',Min=0,Max=100,Default=45,Callback=function(v) print('value:',v) end})

ui:Section(player,'player')
ui:Button(player,{Name='print player',Callback=function() print('hello',game.Players.LocalPlayer.Name) end})

ui:Section(visual,'visuals')
ui:Label(visual,'nothing fancy here. this page is only a demo.')

ui:Section(config,'window')
ui:Button(config,{Name='hide window',Callback=function() ui:SetOpen(false) end})
ui:Button(config,{Name='destroy ui',Callback=function() ui:Destroy() end})