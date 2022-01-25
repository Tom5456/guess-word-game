local platform = Instance.new("Part")
platform.Position = Vector3.new(math.random(240, 580), math.random(120, 550), math.random(240, 580))
platform.Size = Vector3.new(20, 1, 20)
platform.Anchored = true
platform.Parent = game.Workspace
local plrFrame = CFrame.new(Vector3.new(platform.Position.X, platform.Position.Y + 3, platform.Position.Z), Vector3.new(0, 0, 0))
game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = plrFrame
game.Players.LocalPlayer.Character.HumanoidRootPart:GetPropertyChangedSignal("CFrame"):Connect(function()
	game.Players.LocalPlayer.Character.HumanoidRootPart.CFrame = plrFrame
end)
game.Players.LocalPlayer.CharacterAdded:Connect(function(char)
	char:WaitForChild("HumanoidRootPart"):GetPropertyChangedSignal("CFrame"):Connect(function()
		char.HumanoidRootPart.CFrame = plrFrame
	end)
end)
