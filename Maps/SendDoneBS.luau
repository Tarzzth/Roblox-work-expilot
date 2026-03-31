-- Version : 1.1 --
_G.MaxTotalMoney = 1000 -- จำนวนเงิน
_G.DelaySendDone = 10 -- ดีเลย์
repeat
    task.wait()
until game:IsLoaded()
task.wait(10)


local Players = game:GetService("Players")
local Client = Players.LocalPlayer
local HttpService = game:GetService("HttpService")

local _request = http_request or request or syn.request or xeno.request

local function GetMoney(_type)
    local gui = Client.PlayerGui
    local keyword = _type == "bank" and "bank balance" or "hand balance"
    if gui then
        for _, v in gui:GetDescendants() do
            if v:IsA("TextLabel") and v.Text:lower():find(keyword:lower()) then
                local rawText = v.Text
                local numberText = rawText:gsub("[^%d]", "")
                return tonumber(numberText) or 0
            end
        end
    end
    return 0
end

local function SendDone()
    local suss , mesage = pcall(function()
        _request({
            Url = "http://localhost:3030/api/accounts/finish",
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode({
                username = Client.Name
            })
        })
    end)
    if not suss then
        warn("ข้อความล้มเหลว [Send Done] : "..mesage)
    end
    return true
end

_G.CoreSendDone = true
task.spawn(function()
    while _G.CoreSendDone do task.wait()
        local Money_hand = tonumber(GetMoney("hand")) or 0
        local Money_bank = tonumber(GetMoney("bank")) or 0
        local All_Money = Money_hand + Money_bank
        if All_Money >= _G.MaxTotalMoney then
            SendDone()
        end
        task.wait(_G.DelaySendDone or 10)
    end
end)