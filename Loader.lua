local Env = getgenv and getgenv()
local Isfunctionhook = Env.isfunctionhooked or function()
    warn("isfunctionhooked Not Supported")
    return false
end

local Kick = function(a)
    game.Players.LocalPlayer.Kick(a)
end

local CLient_abnormal = false
if Isfunctionhook(game.HttpGet) then
    CLient_abnormal = true
    Kick("Client ผิดปกติ game.HttpGet")
end

if Isfunctionhook(loadstring) then
    CLient_abnormal = true
    Kick("Client ผิดปกติ loadstring")
end

if _G.WhatMap == "" or not _G.WhatMap then
    CLient_abnormal = true
    Kick("Client ไม่มี WhatMap")
end

if not CLient_abnormal then
    local WhatMap = _G.WhatMap
    local pathVersion = "https://raw.githubusercontent.com/Tarzzth/Roblox-work-expilot/refs/heads/main/Version.luau"
    local VersionData = loadstring(game:HttpGet(pathVersion))()
    local CoreGui = game:GetService("StarterGui")

    if VersionData[_G.Map] then
        CoreGui:SetCore("SendNotification", {
            Title = "Running Script by tarrzth";
            Text = "ขอบคุณที่ใช้งาน Version: "..VersionData[_G.Map] ;
            Duration = 5;
            -- --Callback here
            -- Button1 = "Yes";
            -- Button2 = "No";
        })
    end


    print("--------------------------------------------------")
    warn("Start Script By - tarrzth")
    print("--------------------------------------------------")

    local path = "https://raw.githubusercontent.com/Tarzzth/Roblox-work-expilot/refs/heads/main/Maps/"..WhatMap..".luau"
    loadstring(path)()
end