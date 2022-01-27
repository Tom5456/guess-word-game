local material = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kinlei/MaterialLua/master/Module.lua"))()
local eggs = {"Furniture", "Ornament", "Spooky", "Death", "House", "Winter", "Easter", "Autumn", "LunarBundle", "HeartBalloons"}
local pets = {}
local ornaments = {}
local materials = {}
local colours = {}
local currentMaterial = "SmoothPlastic"
local reflectance = 0
local transparency = 0
local plr = game.Players.LocalPlayer
local plrGui = plr.PlayerGui
local camera = game:GetService("Workspace").CurrentCamera
local currentCamera = workspace.CurrentCamera
local cframeChange
local autofarmAdded
local gasterListener
local drawings = {}
local espStepped = {}
local espAdded
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
function esp(player)
	local line = Drawing.new("Line")
	line.Visible = false
	line.Color = Color3.fromRGB(0, 255, 0)
	line.Thickness = 1.5
	line.Transparency = 1
	local quad = Drawing.new("Quad")
	quad.Thickness = 1
	quad.Visible = false
	quad.PointA = Vector2.new()
	quad.PointB = Vector2.new()
	quad.PointC = Vector2.new()
	quad.PointD = Vector2.new()
	quad.Color = Color3.fromRGB(0, 255, 0)
	local text = Drawing.new("Text")
	text.Visible = false
	text.Size = 18
	text.Color = Color3.fromRGB(0, 255, 0)
	text.Outline = true
	text.Center = true
	text.Transparency = 1
	text.Text = player.Name
	table.insert(drawings, text)
	table.insert(drawings, quad)
	table.insert(drawings, line)
	local function draw()
		local stepped = game:GetService("RunService").RenderStepped:Connect(function()
			if player.Character ~= nil and player.Character:FindFirstChild("Humanoid") ~= nil and player.Character:FindFirstChild("HumanoidRootPart") ~= nil and player ~= game.Players.LocalPlayer and player.Character.Humanoid.Health > 0 then
                local vector, onScreen = camera:worldToViewportPoint(player.Character.HumanoidRootPart.Position)
				if onScreen then
					local head = camera:WorldToViewportPoint(player.Character.Head.Position)
					local DistanceY = math.clamp((Vector2.new(head.X, head.Y) - Vector2.new(vector.X, vector.Y)).magnitude, 2, math.huge)
					line.From = Vector2.new(currentCamera.ViewportSize.X / 2, currentCamera.ViewportSize.Y / 2)
					line.To = Vector2.new(vector.X, vector.Y)
					line.Visible = true
					quad.PointA = Vector2.new(vector.X + DistanceY, vector.Y - DistanceY*2)
					quad.PointB = Vector2.new(vector.X - DistanceY, vector.Y - DistanceY*2)
					quad.PointC = Vector2.new(vector.X - DistanceY, vector.Y + DistanceY*2)
					quad.PointD = Vector2.new(vector.X + DistanceY, vector.Y + DistanceY*2)
					quad.Visible = true
					text.Position = Vector2.new(head.X, head.Y)
					text.Visible = true
				else
					line.Visible = false
					quad.Visible = false
					text.Visible = false
				end
			else
				line.Visible = false
				quad.Visible = false
				text.Visible = false
			end
		end)
		table.insert(espStepped, stepped)
	end
	coroutine.wrap(draw)()
end
local plrFrame = newPlatform()
local ui = material.Load({
	Title = "Horrific Anti-cheat",
	Style = 3,
	Theme = "Dark",
})
local items = ui.New({
	Title = "Cosmetics",
})
local gameStuff = ui.New({
	Title = "Game",
})
items.Toggle({
	Text = "Player ESP",
	Callback = function(state)
		if state then
			for _, v in pairs(game.Players:GetPlayers()) do
				esp(v)
			end
			espAdded = game.Players.PlayerAdded:Connect(function(player)
				player.CharacterAdded:Wait()
				esp(player)
			end)
		else
			for _, v in pairs(espStepped) do
				v:Disconnect()
			end
			if espAdded then espAdded:Disconnect() end
			for _, v in pairs(drawings) do
				v:Remove()
			end
		end
	end
})
items.Button({
	Text = "Give all obtainable items",
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
for _, v in pairs(game:GetService("ReplicatedStorage").Pets:GetChildren()) do
	table.insert(pets, v.Name)
end
items.Dropdown({
	Text = "Pets",
	Callback = function(value)
		game:GetService("ReplicatedStorage").PetChange:FireServer(value)
	end,
	Options = pets
})
for _, v in pairs(game:GetService("ReplicatedStorage").Ornaments:GetChildren()) do
	table.insert(ornaments, v.Name)
end
items.Dropdown({
	Text = "Ornament 1",
	Callback = function(value)
		game:GetService("ReplicatedStorage").OrnamentChanged:FireServer("Ornament1", value)
	end,
	Options = ornaments
})
items.Dropdown({
	Text = "Ornament 2",
	Callback = function(value)
		game:GetService("ReplicatedStorage").OrnamentChanged:FireServer("Ornament2", value)
	end,
	Options = ornaments
})
items.Dropdown({
	Text = "Ornament 3",
	Callback = function(value)
		game:GetService("ReplicatedStorage").OrnamentChanged:FireServer("Ornament3", value)
	end,
	Options = ornaments
})
items.TextField({
	Text = "House Transparency (default 0)",
	Callback = function(value)
		local number = tonumber(value)
		if number then
			if number > 1 then
				number = 1
			elseif number < 0 then
				number = 0
			end
			game.ReplicatedStorage.HouseColour:FireServer(nil, currentMaterial, number, reflectance)
			transparency = number
		else
			ui.Banner({
				Text = "Please specify a number between 0 and 1"
			})
		end
	end
})
items.TextField({
	Text = "House Reflectance (default 0)",
	Callback = function(value)
		local number = tonumber(value)
		if number then
			if number > 1 then
				number = 1
			elseif number < 0 then
				number = 0
			end
			game.ReplicatedStorage.HouseColour:FireServer(nil, currentMaterial, transparency, number)
			reflectance = number
		else
			ui.Banner({
				Text = "Please specify a number between 0 and 1"
			})
		end
	end
})
for _, v in pairs(plrGui.HouseColour.Frame.Base.House.Materials.Frame:GetChildren()) do
	if v:IsA("ImageButton") then
		table.insert(materials, v.Name)
	end
end
items.Dropdown({
	Text = "House material (default smoothplastic)",
	Callback = function(value)
		game.ReplicatedStorage.HouseColour:FireServer(nil, value, transparency, reflectance)
	end,
	Options = materials
})
for _, v in pairs(plrGui.HouseColour.Frame.Base.House.Colours.Frame:GetChildren()) do
	if v:IsA("ImageButton") then
		table.insert(colours, v.Name)
	end
end
items.Dropdown({
	Text = "House colour",
	Callback = function(value)
		game.ReplicatedStorage.HouseColour:FireServer(plrGui.HouseColour.Frame.Base.House.Colours.Frame[value]["Properties"].Colour.Value)
	end,
	Options = colours
})
gameStuff.Toggle({
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
			autofarmAdded = plr.CharacterAdded:Connect(function(char)
				cframeChange:Disconnect()
				cframeChange = char:WaitForChild("HumanoidRootPart"):GetPropertyChangedSignal("CFrame"):Connect(function()
					char.HumanoidRootPart.CFrame = plrFrame
				end)
			end)
		else
			if cframeChange then cframeChange:Disconnect() end
			if autofarmAdded then autofarmAdded:Disconnect() end
			game.Players.LocalPlayer.Character.Head:Destroy()
		end
	end,
	Enabled = false,
})
gameStuff.Toggle({
	Text = "Delete sans",
	Callback = function(state)
		if state then
			gasterListener = game.Workspace.ChildAdded:Connect(function(child) -- expensive
				if child.Name == "GasterBlaster" then
					child:Destroy()
				end
			end)
		else
			if gasterListener then gasterListener:Disconnect() end
		end
	end,
	Enabled = false,
})
gameStuff.Button({
	Text = "KO sword",
	Callback = function()
		local anvilExists
		for _, v in pairs(game.Workspace.Plates:GetChildren()) do
			if v:FindFirstChild("Anvil") then
				anvilExists = true
			end
		end
		game:GetService("ReplicatedStorage").EventRemotes.ForgeUltimateSword:FireServer("Cloner", "Cloner", "Cloner")
		if not anvilExists then
			ui.Banner({
				Text = "An anvil needs to be spawned in for this to work."
			})
		end
	end,
})
