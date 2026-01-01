print(pickup)
if pickup == nil then
    pickup = false
end
print(pickup)
---
repeat wait() until game:IsLoaded()

if game.PlaceId == 7922773201 then
    wait(1)
    local args = {
        [1] = "SlotClick";
        [2] = game.Players.LocalPlayer:WaitForChild("PlayerGui", 9e9)
            :WaitForChild("StartPlaceMenu", 9e9)
            :WaitForChild("Slots", 9e9)
            :WaitForChild("ScrollingFrame", 9e9)
            :WaitForChild("slot1", 9e9);
    }

    game:GetService("ReplicatedStorage"):WaitForChild("InputMainMenu", 9e9):FireServer(unpack(args))

    local args2 = {
        [1] = "QuickPlay";
    }

    game:GetService("ReplicatedStorage"):WaitForChild("InputMainMenu", 9e9):FireServer(unpack(args2))
else


    local Webhook = 'https://discord.com/api/webhooks/1456209792732496072/wbKOswpDJt5CEjqNRKVTpFIT0_o2b6EANsNjm4DliAoau8xBonaeRUWlKc2qrNymEWzQ'
    local Requests = game.ReplicatedStorage:WaitForChild("Requests")
    local InteractRemote = Requests:WaitForChild("Interact")

    local ReplicatedStorage = game:GetService('ReplicatedStorage')	
    local Players = game:GetService('Players')
    local HttpService = game:GetService('HttpService')

    local ServerTP = ReplicatedStorage:WaitForChild('ServerTP')
    local LocalPlayer = Players.LocalPlayer
    local PlayerGUI = LocalPlayer.PlayerGui
    local HUD = PlayerGUI:WaitForChild('HUD')
    repeat task.wait() until LocalPlayer.Character
    task.wait(0.5)
    local Input = LocalPlayer:WaitForChild('Backpack'):WaitForChild('Input')




	local function pick(pos)
		local radius = 5
		local closestModel
		local closestDist = math.huge

		for _, obj in ipairs(workspace:GetChildren()) do
			if obj:IsA("Model") and obj.PrimaryPart then
				local dist = (obj.PrimaryPart.Position - pos).Magnitude
				if dist < closestDist and dist <= radius then
					closestDist = dist
					closestModel = obj
				end
			end
		end

		if closestModel then
			InteractRemote:FireServer(closestModel, nil)
		end
	end

	local TweenService = game:GetService("TweenService")

    local RunService = game:GetService("RunService")
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





	Input:FireServer('usemove',{
		["HotbarGui"] = PlayerGUI.HUD.Hotbar.Bar["1"],
		["mousehit"] = CFrame.new(1,1,1)
	})

	local NotifyWebhook = function(msg)
		local Message = {
			["content"] = tostring(msg),
			["embeds"] = {{
				["description"] = 'Job ID = '..game.JobId..' username = '..LocalPlayer.Name..' profile = https://www.roblox.com/users/'..LocalPlayer.UserId..'/profile '.. 'servername = '..workspace:GetAttribute('ServerName'),
				["type"] = "rich",
				["color"] = tonumber(0xFF0000),
				["footer"] = {
					["text"] = 'panda'
				}

			}}
		}
		request({
			Url = Webhook,
			Method = 'POST',
			Headers = {
				['Content-Type'] = 'application/json'
			},
			Body = game:GetService('HttpService'):JSONEncode(Message)
		});
	end

	local Trisu_Folder = isfolder("raikoufinalstandshit")
	local Trisu_Settings = isfile("raikoufinalstandshit/Settings.json")

	if Trisu_Folder then
		if not Trisu_Settings then
			local Table = {}
			for _,ServerID in pairs(ReplicatedStorage.Servers:GetChildren()) do
				if ServerID.Name == game.JobId then
					Table[ServerID.Name] = true
				else
					Table[ServerID.Name] = false
				end
			end
			writefile("raikoufinalstandshit/Settings.json", HttpService:JSONEncode(Table))
		end
	else
		local Table = {}
		for _,ServerID in pairs(ReplicatedStorage.Servers:GetChildren()) do
			if ServerID.Name == game.JobId then
				Table[ServerID.Name] = true
			else
				Table[ServerID.Name] = false
			end
		end
		makefolder("raikoufinalstandshit")
		writefile("raikoufinalstandshit/Settings.json",HttpService:JSONEncode(Table))
	end


	local function Teleport()
		if not isfile("raikoufinalstandshit/Settings.json") then return end
		
		local Settings = HttpService:JSONDecode(readfile("raikoufinalstandshit/Settings.json"))

		local ChosenID
		for ServerID, Visited in pairs(Settings) do
			if not Visited then
				ChosenID = ServerID
				Settings[ServerID] = true
				break
			end
		end

		if not ChosenID then
			warn("resetting list")

			for ServerID in pairs(Settings) do
				Settings[ServerID] = false
			end

			writefile("raikoufinalstandshit/Settings.json", HttpService:JSONEncode(Settings))
			return Teleport()
		end

		writefile("raikoufinalstandshit/Settings.json", HttpService:JSONEncode(Settings))

		local FoundServer = ReplicatedStorage.Servers:FindFirstChild(ChosenID)
		if not FoundServer then
			warn("Server ID not found:", ChosenID)
			return Teleport()
		end

		for i = 1, 5 do
			ServerTP:FireServer(FoundServer)
			task.wait(0.25)
		end

		print("Teleport request sent:", ChosenID)
		task.wait(2)
		Teleport()
	end


	task.spawn(function()
		local Found = false
		local RecieveRemote = PlayerGUI:WaitForChild('RadarGui'):WaitForChild('Recieve')

		RecieveRemote.OnClientEvent:Connect(function(Arg1,Arg2)
			local Table1,Table2 

			Table1 = Arg1 or {}
			Table2 = Arg2 or {}

			for _, v26 in ipairs({Table1, Table2}) do
				for _, v27 in v26 do
					Found = true
					NotifyWebhook('dragon radar found ball trying to teleport')
					print(v27)
					noclip()
					game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(v27)
                    repeat task.wait() until game:IsLoaded()
                    if pickup == true then
                        task.wait(2)
                        pick(v27)
                        task.wait(0.2)
                        pick(v27)
                        game.Players.LocalPlayer.Character:BreakJoints()
                        game.Players.LocalPlayer.CharacterAdded:Wait():WaitForChild("HumanoidRootPart")
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
end
