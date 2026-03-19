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

if _G.Key == "" or not _G.Key then
    CLient_abnormal = true
    Kick("Client ไม่มี Key")
end

if not CLient_abnormal then
    local WhatMap = _G.WhatMap
    local Key = _G.Key
    local DataKey = {}
    if table.find(DataKey , Key) then
        loadstring()
    end
end