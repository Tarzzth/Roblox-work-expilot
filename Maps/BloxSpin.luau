-- local args = {
-- 	13,
-- 	"open_crate",
-- 	workspace:WaitForChild("Map"):WaitForChild("Tiles"):WaitForChild("GunShopTile"):WaitForChild("PatriotWeapons"):WaitForChild("Interior"):WaitForChild("Crates"):WaitForChild("Weapon Crate"):WaitForChild("CrateOptions"):WaitForChild("Basic"),
-- 	"money"
-- }
-- game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Get"):InvokeServer(unpack(args))

-- 2026-03-17 21:15:43.005 [warning] [ROBLOX] {
--   amount = 5,
--   combined = 0.5388542107490479,
--   expected_cost = 40,
--   item_type = "throwable",
--   name = "Mug",
--   probability = 0.09164727041895897,
--   weight = 0.025
-- }
local Players = game:GetService("Players")

local PathfindingService = game:GetService("PathfindingService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Remotes = ReplicatedStorage.Remotes
local Get = Remotes.Get

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
    if gui then
        if _type == "bank" then
            for _, v in gui:GetDescendants() do
                if v:IsA("TextLabel") and v.Text:lower():find("bank balance") then
                    local rawText = v.Text
                    local numberText = rawText:gsub("[^%d]", "")
                    return tonumber(numberText) or 0
                end
            end
        elseif _type == "hand" then
            for _, v in gui:GetDescendants() do
                if v:IsA("TextLabel") and v.Text:lower():find("hand balance") then
                    local rawText = v.Text
                    local numberText = rawText:gsub("[^%d]", "")
                    return tonumber(numberText) or 0
                end
            end
        end
    end
    return 0
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
            local speed = speed or 20
            local startTime = tick()

            while moved < dist and not Stopwalk and _G.Core do
                Humanoid.WalkSpeed = speed
                local TeleportDetected_ = TeleportDetected()
                if TeleportDetected_ then
                    local clip = root:FindFirstChild("CarClip")
                    if clip then clip:Destroy() end
                    task.wait(0.15)
                    Stopwalk = true
                    MoveTo(model, destination , speed)
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

-- workspace.Map.Tiles.GunShopTile.PatriotWeapons.Interior.Crates["Weapon Crate"].CrateOptions.Basic
-- local A = workspace.Map.Tiles.GunShopTile.PatriotWeapons.Interior.Crates["Weapon Crate"].CrateOptions.Basic --Legendary
-- warn(dump(_Remote.OpenCate(A)))

for _, v in pairs(workspace:GetDescendants()) do
    if v.Name == "DoorSystem" then v:Destroy() end
    if v.Name == "VehicleBlockers" then v:Destroy() end
end

local PosMark = {
    ["WeaponCase"] = Vector3.new(-227, 255, -231)
}

local function AutoCore()
    local Money = GetMoney("hand")
    local RootPart = GetHumanoidRootPart(Client.Character)
    if not RootPart then return end
    if Money >= Current_Case:GetAttribute("price") then
        local distance_WeaponCase = (RootPart.Position - PosMark["WeaponCase"]).Magnitude
        if distance_WeaponCase < 5 then
            local Result = _Remote.OpenCate(Current_Case)
        else
            MoveTo(PosMark["WeaponCase"] , 30)
        end
    end
end 

-- _G.Core = not _G.Core
-- warn("Is:", _G.Core)
-- while _G.Core do task.wait()
--     _Remote.sprint()
--     -- MoveTo(Vector3.new(-227, 255, -229) , 30)
--     AutoCore()
-- end

-- ออโต้เก็บของเข้าตู้เชฟ

-- path ตู้เชฟ workspace.Map.Tiles.UnassignedTile:GetChildren()[8].TrapHouse2.Interior.SafeBeacon

-- local args = {
-- 	123,
-- 	"request_change_item_location",
-- 	"{edea5988-8e61-4308-8be2-b5b8f9497c9b}",
-- 	"safe"
-- }
-- game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Get"):InvokeServer(unpack(args))

_Remote.request_change_item_location("{edea5988-8e61-4308-8be2-b5b8f9497c9b}" , "safe")