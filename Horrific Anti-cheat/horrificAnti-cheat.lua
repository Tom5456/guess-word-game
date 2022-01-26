local material = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kinlei/MaterialLua/master/Module.lua"))()
local eggs = {"Furniture", "Ornament", "Spooky", "Death", "House", "Winter", "Easter", "Autumn", "LunarBundle", "HearBalloons"}
local plr = game.Players.LocalPlayer
local plrGui = plr.PlayerGui
local cframeChange
local added
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
	cframeChange:Disconnect()
	local original = plr.Character.HumanoidRootPart.CFrame
	local platform = newPlatform(true)
	plr.Character.HumanoidRootPart.CFrame = platform.Position + Vector3.new(0, 3, 0)
	task.wait(0.5)
	platform:Destroy()
	plr.Character.HumanoidRootPart.CFrame = original
	cframeChange = game.Players.LocalPlayer.Character:WaitForChild("HumanoidRootPart"):GetPropertyChangedSignal("CFrame"):Connect(function()
		game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = plrFrame
	end)
end
local plrFrame = newPlatform()
local ui = material.Load({
	Title = "Horrific Anti-cheat",
	Style = 3,
	Theme = "Dark",
})
local items = ui.New({
	Title = "Misc",
})
local autofarm = ui.New({
	Title = "Autofarm",
})
items.Button({
	Text = "Give all items",
	Callback = function()
		for i = 1, 300, 1 do
			for _, v in pairs(eggs) do
				game.ReplicatedStorage.ShopPurchase:FireServer(1e-59, v)
			end
		end
	end,
})
items.Button({
	Text = "1000 eggs",
	Callback = function()
		for i = 1, 1000, 1 do
			game.ReplicatedStorage.ShopPurchase:FireServer(1e-59, "EggPets")
		end
	end,
})
autofarm.Toggle({
	Text = "Autofarm",
	Callback = function(state)
		if state then
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
			cframeChange = plr.Character.HumanoidRootPart:GetPropertyChangedSignal("CFrame"):Connect(function()
				plr.Character.HumanoidRootPart.CFrame = plrFrame
			end)
			added = plr.CharacterAdded:Connect(function(char)
				cframeChange:Disconnect()
				cframeChange = char:WaitForChild("HumanoidRootPart"):GetPropertyChangedSignal("CFrame"):Connect(function()
					char.HumanoidRootPart.CFrame = plrFrame
				end)
			end)
		else
			if cframeChange then cframeChange:Disconnect() end
			if added then added:Disconnect() end
			game.Players.LocalPlayer.Character.Head:Destroy()
		end
	end,
	Enabled = false,
})
