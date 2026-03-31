-- Version : 1.1 --
repeat
    task.wait()
until game:IsLoaded()
task.wait(10)
local DelaySend = 10

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

local function SendLog(description)
    print(description)
    local suss , message = pcall(function()
        _request({
            Url = "http://localhost:3030/api/accounts/description",
            Method = "PUT",
            Headers = { ["Content-Type"] = "application/json" },
            Body = HttpService:JSONEncode({
                username = Client.Name,
                description = tostring(description)
            })
        })
    end)
    if not suss then
        warn("ข้อความล้มเหลว : "..message)
    end
    return true
end

local function GetLevelJob(Job)
    if Job == "None" then return Job end
    Job = Job == "steakhouse_cook" and "Cook" or Job
    local result = Job:gsub("[_%s%-]", ""):lower()

    for i , v in game:GetService("Players").LocalPlayer.PlayerGui.Skills.SkillsHolder.SkillsScrollingFrame:GetChildren() do
        if v:FindFirstChild("SkillTitle") then
            local Job_UI = v.SkillTitle.Text:gsub("[_%s%-]", ""):lower()
            if string.find(Job_UI , result) then
                return v.SkillTitle.Text
            end
        end
    end
    return Job
end

local GetAttr = function(...)
    return Client:GetAttribute(...)
end

_G.CoreSendLog = true
task.spawn(function()
    while _G.CoreSendLog do task.wait()
        local Money_hand = tonumber(GetMoney("hand")) or 0
        local Money_bank = tonumber(GetMoney("bank")) or 0
        local All_Money = Money_hand + Money_bank
        local Job = GetAttr("Job") == "" and "None" or GetAttr("Job")
        local Level = GetAttr("level") or 0
        local Job_Level = GetLevelJob(Job)

        SendLog(string.format("💰 Job: %s | ⭐ Lv: %d | 💵 Hand: %d | 🏦 Bank: %d | 💸 Total: %d",
                Job_Level, Level, Money_hand, Money_bank, All_Money
        ))
        task.wait(DelaySend or 10)
    end
end)

