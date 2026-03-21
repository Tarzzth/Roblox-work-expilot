local Env = getgenv and getgenv()

local Kick = game.Players.LocalPlayer.Kick
if _G.WhatMap == "" or not _G.WhatMap then
    Kick("Client ไม่มี WhatMap")
end

local WhatMap = _G.WhatMap
local pathVersion = "https://raw.githubusercontent.com/Tarzzth/Roblox-work-expilot/refs/heads/main/Version.luau"
local VersionData = loadstring(game:HttpGet(pathVersion))()
local CoreGui = game:GetService("StarterGui")

if VersionData[WhatMap] then
    CoreGui:SetCore("SendNotification", {
        Title = "Running Script by tarrzth";
        Text = "ขอบคุณที่ใช้งาน Version Script: "..VersionData[WhatMap].."\n Version Loader: "..VersionData.Loader ;
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
loadstring(game:HttpGet(path))()