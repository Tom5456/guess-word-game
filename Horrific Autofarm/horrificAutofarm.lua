--vars
local plr = game.Players.LocalPlayer
local plrGui = plr.PlayerGui
-- make platforms
function newPlatform(returnInstance: boolean): CFrame | Instance
	local platform = Instance.new("Part")
	platform.Position = Vector3.new(math.random(240, 580), math.random(120, 550), math.random(240, 580))
	platform.Size = Vector3.new(20, 1, 20)
	platform.Anchored = true
	platform.Parent = game.Workspace
	local plrFrame = CFrame.new(
		Vector3.new(platform.Position.X, platform.Position.Y + 3, platform.Position.Z),
		Vector3.new(0, 0, 0)
	)
	if returnInstance then
		return platform
	else
		return plrFrame
	end
end
function randomPlatform()
	for _, v in pairs(getconnections(plr.Character.HumanoidRootPart:GetPropertyChangedSignal("CFrame"))) do
		v:Disable()
	end
	local original = plr.Character.HumanoidRootPart.CFrame
	local platform = newPlatform(true)
	plr.Character.HumanoidRootPart.CFrame = platform.Position + Vector3.new(0, 3, 0)
	task.wait(0.5)
	platform:Destroy()
	plr.Character.HumanoidRootPart.CFrame = original
	for _, v in pairs(getconnections(plr.Character.HumanoidRootPart:GetPropertyChangedSignal("CFrame"))) do
		v:Enable()
	end
end
local plrFrame = newPlatform()
-- avoid stuff
game.Workspace.ChildAdded:Connect(function(child) -- expensive
	if child.Name == "GasterBlaster" then
		child:Destroy()
	elseif child.Name == "Meteor" or child.Name == "coal" then
		randomPlatform()
	elseif child.Name == "Firework" then
		if (child.Fireworks.Position - plr.Character.HumanoidRootPart.Position).Magnitude < 20 then
			randomPlatform()
		end
	end
end)
-- mode voting
plrGui.VoteMode:GetPropertyChangedSignal("Enabled"):Connect(function()
	local options = {}
	for _, v in pairs(plrGui.VoteMode.Frame.Options_Pool:GetChildren()) do
		pcall(function()
			if v.Visible == true then
				table.insert(options, v.Name)
			end
		end)
	end
	for _, v in pairs(options) do
		if v == "Rapid" or v == "OnePlate" or v == "1hp" then -- prefer rapid or oneplate because they're short
			game.ReplicatedStorage.VoteGameMode:FireServer(v)
		end
	end
end)
-- put player on platforms
plr.Character.HumanoidRootPart.CFrame = plrFrame
plr.Character.HumanoidRootPart:GetPropertyChangedSignal("CFrame"):Connect(function()
	plr.Character.HumanoidRootPart.CFrame = plrFrame
end)
plr.CharacterAdded:Connect(function(char)
	char:WaitForChild("HumanoidRootPart"):GetPropertyChangedSignal("CFrame"):Connect(function()
		char.HumanoidRootPart.CFrame = plrFrame
	end)
end)
-- anti afk
local vu = game:GetService("VirtualUser")
game:GetService("Players").LocalPlayer.Idled:connect(function()
	vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
	task.wait(1)
	vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
end)
--serverhopping
game.Players.PlayerRemoving:Connect(function()
	if #game.Players:GetPlayers() == 1 then
		local servers = game.HttpService:JSONDecode(
			game:HttpGet("https://games.roblox.com/v1/games/263761432/servers/Public?sortOrder=Asc&limit=100")
		)
		for i, v in pairs(servers.data) do
			if v.playing ~= v.maxPlayers then
				game:GetService("TeleportService"):TeleportToPlaceInstance(game.PlaceId, v.id)
				syn.queue_on_teleport('game:IsLoaded:Wait() loadstring(game:HttpGet("https://raw.githubusercontent.com/swatTurret/roblox-scripts/main/Horrific%20Autofarm/horrificAutofarm.lua",true))()')
				return
			end
		end
	end
end)
