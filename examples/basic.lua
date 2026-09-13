--[[
    basic.lua — пример использования библиотеки maxxteam
    INJECTOR-COMPATIBLE BUILD

    Загружать ПОСЛЕ maxxteam.lua.
    Если ты в Studio — используй require(ReplicatedStorage.maxxteam).
    Если ты в экзекьюторе — используй loadstring + getgenv().__MAXXTEAM_LIB.
]]

--============================================================
-- ПОЛУЧЕНИЕ БИБЛИОТЕКИ
--============================================================

local Maxxteam

-- Вариант 1: локальная библиотека в ReplicatedStorage (Studio)
do
    local RS = game:GetService("ReplicatedStorage")
    local mod = RS:FindFirstChild("maxxteam")
    if mod then
        local ok, result = pcall(require, mod)
        if ok and result then
            Maxxteam = result
        end
    end
end

-- Вариант 2: библиотека уже загружена в getgenv (инжектор)
if not Maxxteam then
    local env = (getgenv and getgenv()) or _G or shared
    if env.__MAXXTEAM_LIB then
        Maxxteam = env.__MAXXTEAM_LIB
    end
end

-- Вариант 3: подгружаем библиотеку с GitHub (инжектор, если не загружена)
if not Maxxteam then
    local URL = "https://raw.githubusercontent.com/ТВОЙ_НИК/ТВОЙ_РЕПО/main/maxxteam.lua"
    local ok, result = pcall(function()
        return loadstring(game:HttpGet(URL))()
    end)
    if ok and result then
        Maxxteam = result
    end
end

if not Maxxteam then
    warn("[basic] maxxteam library not found. Load maxxteam.lua first.")
    return
end

--============================================================
-- СОЗДАНИЕ UI
--============================================================

local UI = Maxxteam.new({ Name = "maxxteam", Version = "v5" })

local Main    = UI:CreateTab("main", "M")
local Player  = UI:CreateTab("player", "P")
local Visuals = UI:CreateTab("visuals", "V")
local Config  = UI:CreateTab("config", "C")

--============================================================
-- MAIN
--============================================================

UI:Section(Main, "quick actions")

UI:Button(Main, {
    Name = "test button",
    Description = "Tests callbacks and notifications.",
    Callback = function()
        UI:Notify({
            Title = "test",
            Content = "button works",
            Duration = 2
        })
    end
})

UI:Toggle(Main, {
    Name = "particles",
    Description = "Toggle background particles.",
    Default = true,
    Callback = function(v)
        UI:SetParticlesEnabled(v)
    end
})

UI:Toggle(Main, {
    Name = "animations",
    Description = "Toggle animated UI effects.",
    Default = true,
    Callback = function(v)
        UI:SetAnimationsEnabled(v)
    end
})

UI:Slider(Main, {
    Name = "test value",
    Description = "Example slider.",
    Min = 0,
    Max = 100,
    Default = 50,
    Callback = function(v)
        print("test value:", v)
    end
})

--============================================================
-- PLAYER
--============================================================

UI:Section(Player, "player tests")

UI:Button(Player, {
    Name = "print player",
    Description = "Prints the local player name.",
    Callback = function()
        print(game.Players.LocalPlayer.Name)
    end
})

--============================================================
-- VISUALS
--============================================================

UI:Section(Visuals, "visual tests")

UI:Label(Visuals, "Use these controls as a base for your own game UI.")

--============================================================
-- CONFIG
--============================================================

UI:Section(Config, "interface")

UI:Button(Config, {
    Name = "hide window",
    Description = "Close it; RightShift opens it again.",
    Callback = function()
        UI:SetOpen(false)
    end
})

UI:Button(Config, {
    Name = "destroy ui",
    Description = "Remove the entire interface.",
    Callback = function()
        UI:Destroy()
    end
})