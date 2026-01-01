print(pickup)
if pickup == nil then
    pickup = false
end
print(pickup)

repeat task.wait() until game:IsLoaded()

if game.PlaceId == 7922773201 then
    task.wait(1)
    local args = {
        [1] = "SlotClick";
        [2] = game.Players.LocalPlayer:WaitForChild("PlayerGui", 9e9)
            :WaitForChild("StartPlaceMenu", 9e9)
            :WaitForChild("Slots", 9e9)
            :WaitForChild("ScrollingFrame", 9e9)
            :WaitForChild("slot1", 9e9);
    }
    game:GetService("ReplicatedStorage"):WaitForChild("InputMainMenu", 9e9):FireServer(unpack(args))
    game:GetService("ReplicatedStorage"):WaitForChild("InputMainMenu", 9e9):FireServer("QuickPlay")
    return
end

local Webhook = "https://discord.com/api/webhooks/1456209792732496072/wbKOswpDJt5CEjqNRKVTpFIT0_o2b6EANsNjm4DliAoau8xBonaeRUWlKc2qrNymEWzQ"

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer
local PlayerGUI = LocalPlayer.PlayerGui
local ServerTP = ReplicatedStorage:WaitForChild("ServerTP")
local ServersFolder = ReplicatedStorage:WaitForChild("Servers")

local Requests = ReplicatedStorage:WaitForChild("Requests")
local InteractRemote = Requests:WaitForChild("Interact")

repeat task.wait() until LocalPlayer.Character
task.wait(0.5)

local Input = LocalPlayer.Backpack:WaitForChild("Input")

Input:FireServer("usemove",{
    ["HotbarGui"] = PlayerGUI.HUD.Hotbar.Bar["1"],
    ["mousehit"] = CFrame.new(1,1,1)
})

local function NotifyWebhook(msg)
    request({
        Url = Webhook,
        Method = "POST",
        Headers = {["Content-Type"] = "application/json"},
        Body = HttpService:JSONEncode({
            content = tostring(msg),
            embeds = {{
                description =
                    "Job ID = "..game.JobId..
                    " username = "..LocalPlayer.Name..
                    " profile = https://www.roblox.com/users/"..LocalPlayer.UserId.."/profile "..
                    " servername = "..tostring(workspace:GetAttribute("ServerName")),
                type = "rich",
                color = tonumber(0xFF0000),
                footer = { text = "panda" }
            }}
        })
    })
end

local function pick(pos)
    local closestModel
    local closestDist = math.huge
    for _, obj in ipairs(workspace:GetChildren()) do
        if obj:IsA("Model") and obj.PrimaryPart then
            local dist = (obj.PrimaryPart.Position - pos).Magnitude
            if dist <= 5 and dist < closestDist then
                closestDist = dist
                closestModel = obj
            end
        end
    end
    if closestModel then
        InteractRemote:FireServer(closestModel, nil)
    end
end

local noclipa
local function noclip()
    if noclipa then return end
    noclipa = RunService.Stepped:Connect(function()
        for _,v in ipairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") then
                v.CanCollide = false
            end
        end
    end)
end

local FOLDER = "raikoufinalstandshit"
local FILE = FOLDER.."/Settings.json"
if not isfolder(FOLDER) then makefolder(FOLDER) end
if not isfile(FILE) then writefile(FILE, "{}") end

local function LoadVisited()
    return HttpService:JSONDecode(readfile(FILE))
end

local function SaveVisited(t)
    writefile(FILE, HttpService:JSONEncode(t))
end

local function GetActiveJobIds()
    local result = {}
    local cursor
    repeat
        local url = "https://games.roblox.com/v1/games/"..game.PlaceId.."/servers/Public?limit=100"
        if cursor then url = url.."&cursor="..cursor end
        local res = request({Url = url, Method = "GET"})
        if not res or res.StatusCode ~= 200 then break end
        local data = HttpService:JSONDecode(res.Body)
        for _,s in ipairs(data.data) do
            result[s.id] = true
        end
        cursor = data.nextPageCursor
        task.wait(0.4)
    until not cursor
    return result
end

function Teleport()
    local active = GetActiveJobIds()
    local visited = LoadVisited()

    for id in pairs(visited) do
        if not active[id] then
            visited[id] = nil
        end
    end

    for id in pairs(active) do
        if visited[id] == nil then
            visited[id] = false
        end
    end

    local chosen
    for id, used in pairs(visited) do
        if used == false then
            chosen = id
            break
        end
    end

    if not chosen then
        for id in pairs(visited) do
            visited[id] = false
        end
        SaveVisited(visited)
        return Teleport()
    end

    local inst = ServersFolder:FindFirstChild(chosen)
    if not inst then
        visited[chosen] = true
        SaveVisited(visited)
        return Teleport()
    end

    visited[chosen] = true
    SaveVisited(visited)

    for i = 1, 5 do
        ServerTP:FireServer(inst)
        task.wait(0.25)
    end
    task.wait(2)
    Teleport()
end

local function makepart(pos)
    local part = Instance.new("Part")
    part.Size = Vector3.new(10, 1, 10)
    part.Anchored = true
    part.CanCollide = true
    part.Name = "StandPart"
    part.CFrame = CFrame.new(pos.X, pos.Y - 3, pos.Z)
    part.Parent = workspace
end

task.spawn(function()
    local Found = false
    local RecieveRemote = PlayerGUI:WaitForChild("RadarGui"):WaitForChild("Recieve")

    RecieveRemote.OnClientEvent:Connect(function(Arg1, Arg2)
        local Table1 = Arg1 or {}
        local Table2 = Arg2 or {}
        for _,tbl in ipairs({Table1, Table2}) do
            for _,pos in ipairs(tbl) do
                Found = true
                NotifyWebhook("dragon radar found ball trying to teleport")
                makepart(pos)
                noclip()
                LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(pos)
                if pickup == true then
                    task.wait(2)
                    pick(pos)
                    task.wait(0.2)
                    pick(pos)
                    LocalPlayer.Character:BreakJoints()
                    LocalPlayer.CharacterAdded:Wait():WaitForChild("HumanoidRootPart")
                    Teleport()
                end
            end
        end
    end)

    task.wait(2)
    if not Found then
        Teleport()
    end
end)
