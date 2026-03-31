task.wait(10)
repeat
    task.wait(1)
until game:IsLoaded() and _G.Horst_SetDescription

local DelaySendLog = 10

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Remotes = ReplicatedStorage:WaitForChild("Remotes")
local RemoteEvents = ReplicatedStorage:WaitForChild("RemoteEvents")

local Client = Players.LocalPlayer
local Folder_Data = Client.Data
local HakiRemote = RemoteEvents.HakiRemote
local ObservationHakiRemote = RemoteEvents.ObservationHakiRemote 
local GetTotalStats = Remotes.GetTotalStats

local DataRaceClan = {}
for i , v in getgc(true) do
	if typeof(v) == "table" and rawget(v , "StoredItems") then
		DataRaceClan = v
	end
end

local DataSave = {
	Sword = {} ,
	Melee = {} ,
	Items = {}
}
local QuantityData = {
	Sword = 0 ,
	Melee = 0 ,
	Items = 0
}
local CountData = {
	Sword = 0 ,
	Melee = 0 ,
	Items = 0
}

local HasHaki = false
local HasHakiObservation = false

_G.LoadedOnEvent_Inventory = _G.LoadedOnEvent_Inventory or false
_G.LoadedOnEvent_Haki = _G.LoadedOnEvent_Haki or false
_G.LoadedOnEvent_HakiObservation = _G.LoadedOnEvent_HakiObservation or false

_G.FuncUpdateInventory = function(k , c)
	_G.LoadedOnEvent_Inventory = true
	if DataSave[k] then
		CountData[k] = #c
		DataSave[k] = {}
		for _ , v in c do
			if v and rawget(v , "name") and rawget(v , "quantity") then
				table.insert(DataSave[k] , v.name)
				QuantityData[v.name] = v.quantity
			end
		end
	end
end

_G.FuncUpdateHaki = function(j , v)
	_G.LoadedOnEvent_Haki = true
	if j == "Status" and v and typeof(v) == "table" then

		HasHaki = v.hasHaki
	end
end

_G.FuncUpdateHakiObservation = function(j , v)
	_G.LoadedOnEvent_HakiObservation = true
	if j == "Status" and v and typeof(v) == "table" then
		HasHakiObservation = v.hasObsHaki
	end
end

if not _G.LoadedOnEvent_Inventory then
	Remotes.UpdateInventory.OnClientEvent:Connect(function(k , c)
		_G.FuncUpdateInventory(k , c)
	end)
end

if not _G.LoadedOnEvent_Haki then
	HakiRemote.OnClientEvent:Connect(function(j , v)
		_G.FuncUpdateHaki(j , v)
	end)
end

if not _G.LoadedOnEvent_HakiObservation then
	ObservationHakiRemote.OnClientEvent:Connect(function(j , v)
		_G.FuncUpdateHakiObservation(j , v)
	end)
end

local function GetSwordSlot()
	local CurrentSword ;
	repeat
		task.wait()
	until #DataSave.Sword > 0
	if #DataSave.Sword > 0 then
		for _ , v in {
			Client.Backpack:GetChildren() ,
			Client.Character:GetChildren()
		} do
			for _ , v1 in v do
				if v1.ClassName == "Tool" and table.find(DataSave.Sword , v1.Name) then
					CurrentSword = v1
				end
			end
		end
	end
	return CurrentSword
end

local function CheckHasItemInventory(Item , _type)
	repeat
		task.wait()
	until #DataSave.Sword >= CountData.Sword and #DataSave.Melee >= CountData.Melee and #DataSave.Items >= CountData.Items
	local TblMap = {
		["Sword"] = DataSave.Sword ,
		["Melee"] = DataSave.Melee ,
		["Items"] = DataSave.Items
	}
	for _ , v in pairs(TblMap[_type]) do
		if v:lower():find(Item:lower()) then
			return true , v , QuantityData[v]
		end
	end
	return false , nil , 0
end

local function mark(v)
	return v and "✅" or "❌"
end

local function SendLog(...)
    print(...)
    _G.Horst_SetDescription(...)
    return true
end

_G.Core = true

task.spawn(function()
	while _G.Core do task.wait()
        xpcall(function()
            Remotes.RequestInventory:FireServer()
            HakiRemote:FireServer("GetStatus")
            ObservationHakiRemote:FireServer("GetStatus")
            local Result_TotalStats = GetTotalStats:InvokeServer()

            task.wait(1)
            local Level = Folder_Data.Level.Value -- Level
            local Success5 , SukunaV2 , Count1 = CheckHasItemInventory("Strongest In History" , "Melee") -- SukunaV2
            local Success4 , Ichigo , Count2 = CheckHasItemInventory("Ichigo" , "Sword") -- Ichigo
            local SwordSlot = GetSwordSlot() -- SwordSlot
            local Money = Folder_Data.Money.Value -- Money
            local Gems = Folder_Data.Gems.Value -- Gems
            local Race = DataRaceClan.EquippedRace  -- Race
            local Clan = DataRaceClan.EquippedClan -- Clan
            local Trait = DataRaceClan.EquippedTrait -- Trait
            local DamageTotal = Result_TotalStats.DamageTotal -- DamageTotal
            local LuckTotal = Result_TotalStats.LuckTotal -- LuckTotal
            local HasHakiObservation = HasHakiObservation -- HasHakiObservation
            local HasHaki = HasHaki -- HasHak

            local Success1 , Cosmetic_Crate , Count3 = CheckHasItemInventory("Cosmetic Crate" , "Items") -- Cosmetic_Crate
            local Success2 , Secret_Crate , Count4 = CheckHasItemInventory("Secret Crate" , "Items") -- Secret_Crate
            local Success3 , Aura_Crate , Count5 = CheckHasItemInventory("Aura Crate" , "Items") -- Aura_Crate
            local log = string.format(
                "[Lv:%d] 💰%d 💎%d | DMG:%s ; LUCK:%s | 🧬 Race:%s / Clan:%s / Trait:%s | ⚔️ %s | Ichigo:%s(%d) Sukuna:%s(%d) | 🎁 Cosmic:%s(%d) Secret:%s(%d) Aura:%s(%d) | ⚡ Obs:%s Haki:%s",
                Level or 0,
                Money or 0,
                Gems or 0,

                tostring(DamageTotal or 0),
                tostring(LuckTotal or 0),

                tostring(Race or "None"),
                tostring(Clan or "None"),
                tostring(Trait or "None"),

                tostring(SwordSlot or "None"),

                mark(Ichigo), Count2 or 0,
                mark(SukunaV2), Count1 or 0,

                mark(Cosmetic_Crate), Count3 or 0,
                mark(Secret_Crate), Count4 or 0,
                mark(Aura_Crate), Count5 or 0,

                mark(HasHakiObservation),
                mark(HasHaki)
            )
            SendLog(log)
        end , warn)
        task.wait(DelaySendLog or 10)
	end
end)