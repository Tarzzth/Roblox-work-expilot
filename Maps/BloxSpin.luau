
_G.Configs = _G.Configs or {}
local CoreSpeed = 29
local Players = game:GetService("Players")
local PathfindingService = game:GetService("PathfindingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")

local UI = require(ReplicatedStorage.Modules.Core.UI)

local Current_Case = Workspace.Map.Tiles.GunShopTile.PatriotWeapons.Interior.Crates["Weapon Crate"].CrateOptions.Basic -- Legendary

local Client = Players.LocalPlayer

local Net = require(ReplicatedStorage.Modules.Core.Net)
local _Remote = {} ; _Remote.__index = _Remote

local function TeleportDetected()
    for _, v in pairs(Client.PlayerGui.Notifications.Frame:GetChildren()) do
        if v.Name == "Notification" and (v.Text == "Teleport detected" or v.Text == "Anti noclip triggered") then
            return v
        end
    end
    return false
end

local function GetHumanoid(Character)
    if Character then
        return Character:FindFirstChildOfClass("Humanoid")
    end
end

local function GetHumanoidRootPart(Character)
    if Character then
        return Character:FindFirstChild("HumanoidRootPart")
    end
end

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

local function RemoveDoor()
    for _, v in pairs(workspace:GetDescendants()) do
        if v.Name == "DoorSystem" or v.Name == "VehicleBlockers" then v:Destroy() end
    end
end

_Remote.OpenCate = function(CrateOption)
    return Net.get("open_crate" , CrateOption , "money")
end

_Remote.sprint = function()
    return Net.send("set_sprinting_1" , true)
end

_Remote.request_change_item_location = function(uuid , location)
    return Net.send("request_change_item_location" , uuid , location)
end

local Stopwalk = false
local function MoveTo(destination , speed)
    Stopwalk = true
	Stopwalk = false

	local root = Client.Character.PrimaryPart
	if not root then return end
	local path = PathfindingService:CreatePath({
		AgentRadius = 1.5,
        AgentHeight = 5.5,
        AgentCanJump = true,
        AgentMaxSlope = 45
	})

	path:ComputeAsync(root.Position, destination)

	if path.Status ~= Enum.PathStatus.Success then
		warn("[DriveTo] Pathfinding failed:", path.Status , destination)
        return
	end

    local Humanoid = GetHumanoid(Client.Character)
	local waypoints = path:GetWaypoints()
	for _, waypoint in ipairs(waypoints) do
        if Humanoid then

            if Stopwalk then return end
            local startPos = root.Position
            local targetPos = waypoint.Position + Vector3.new(0, 4.5, 0)
            local dir = (targetPos - startPos).Unit
            local dist = (targetPos - startPos).Magnitude

            local moved = 0 
            local speed = speed or CoreSpeed
            local startTime = tick()

            while moved < dist and not Stopwalk and _G.Core do
                Humanoid.WalkSpeed = speed
                local TeleportDetected_ = TeleportDetected()
                if TeleportDetected_ then
                    local clip = root:FindFirstChild("CarClip")
                    if clip then clip:Destroy() end
                    task.wait(0.15)
                    Stopwalk = true
                    MoveTo(destination , speed)
                    return
                end

                task.wait()

                if not root:FindFirstChild("CarClip") then
                    local bv = Instance.new("BodyVelocity")
                    bv.Name = "CarClip"
                    bv.MaxForce = Vector3.new(1e5, 1e5, 1e5)
                    bv.P = 1250
                    bv.Velocity = Vector3.zero
                    bv.Parent = root
                end

                if waypoint.Action == Enum.PathWaypointAction.Jump then
                    local jumpPos = root.Position + Vector3.new(0, 6, 0)
                    root.CFrame = CFrame.lookAt(jumpPos, jumpPos + dir)
                    task.wait(0.15)
                end

                local dt = tick() - startTime
                moved = math.min(dt * speed, dist)

                local newPos = startPos + dir * moved
                root.CFrame = CFrame.lookAt(newPos, newPos + dir)
            end
        end
	end

	local clip = root:FindFirstChild("CarClip")
	if clip then clip:Destroy() end
	return true
end

RemoveDoor()

local PosMark = {
    ["WeaponCase"] = Vector3.new(-227, 255, -231)
}

local function GetKeepItem()
    local ItemsScrollingFrame = UI.get("ItemsScrollingFrame")
    if ItemsScrollingFrame then
        for _ , v in ItemsScrollingFrame:GetChildren() do
            local ItemName = v:FindFirstChild("ItemName")
            if ItemName and ItemName.Text:lower():find(unpack(_G.Configs.Items):lower()) then
                return v
            end
        end
    end
    return false
end

local function GetNearSafe()
    local Safes = {}
    local DistanceList = {}
    for _ , v in Workspace.Map.Tiles:GetDescendants() do 
        if v.Name == "SafeBeacon" then
            local Distance = (v:GetPivot().Position - GetHumanoidRootPart(Client.Character).Position).Magnitude
            table.insert(DistanceList , Distance)
            Safes[Distance] = v
        end
    end
    return Safes[math.min(unpack(DistanceList))]
end

local function AutoCore()
    local Money = GetMoney("hand")
    local RootPart = GetHumanoidRootPart(Client.Character)
    if not RootPart then return end

    local Keepitem = GetKeepItem()

    if Keepitem then
        local SafeBeacon = GetNearSafe()
        local distance_safe = (RootPart.Position - SafeBeacon:GetPivot().Position).Magnitude
        if not SafeBeacon then return end
        repeat task.wait()
            MoveTo(SafeBeacon:GetPivot().Position , CoreSpeed)
            distance_safe = (RootPart.Position - SafeBeacon:GetPivot().Position).Magnitude
        until not _G.Core or not Keepitem or not SafeBeacon or distance_safe <= 5
        task.wait(1)
        _Remote.request_change_item_location(Keepitem.Name , "safe")
    else
        if Money >= Current_Case:GetAttribute("price") then
            local distance_WeaponCase = (RootPart.Position - PosMark["WeaponCase"]).Magnitude
            repeat task.wait()
                MoveTo(PosMark["WeaponCase"] , CoreSpeed)
                distance_WeaponCase = (RootPart.Position - PosMark["WeaponCase"]).Magnitude
            until not _G.Core or distance_WeaponCase <= 5
            task.wait(1)
            _Remote.OpenCate(Current_Case)
        else
            warn("[Auto] : Not enough money")
            task.wait(1)
        end
    end
    return
end

_G.Core = true

warn("Workspace:", _G.Core)
task.spawn(function()
    while _G.Core do task.wait(0.25)
        _Remote.sprint()
        AutoCore()
    end
end)

