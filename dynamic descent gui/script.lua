-- services
local replicatedStorage = game:GetService("ReplicatedStorage")
-- loadstrings / modules
local material = loadstring(game:HttpGet("https://raw.githubusercontent.com/Kinlei/MaterialLua/master/Module.lua"))()
-- consts
local connections = replicatedStorage.Connections
local lobby = workspace.lobby
-- vars
local trails = {}
local pets = {}

local function tp(pos)
	game:GetService("Players").LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(pos)
end
replicatedStorage.Connections.ReportClientError:Destroy()
for _, category in pairs(replicatedStorage.Loot.Trails:GetChildren()) do
	for _, trail in pairs(category:GetChildren()) do
		table.insert(trails, trail.Name)
	end
end
for _, category in pairs(replicatedStorage.Loot.Pets:GetChildren()) do
	for _, pet in pairs(category:GetChildren()) do
		table.insert(pets, pet.Name)
	end
end

local ui = material.Load({
	Title = "Dynamic Descent",
	Style = 3,
	SizeY = 200,
	Theme = "Dark",
})
local main = ui.New({
	Title = "Main"
})

main.Dropdown({
	Text = "Trails",
	Callback = function(value)
		connections.SelectCosmetic:FireServer({value})
	end,
	Options = trails
})
main.Dropdown({
	Text = "Pets",
	Callback = function(value)
		connections.SelectCosmetic:FireServer({value})
	end,
	Options = pets
})
main.Toggle({
	Text = "Invincible",
	Callback = function(state)
		if state then
			connections.Landed.Parent = replicatedStorage
		else
			connections.Landed.Parent = replicatedStorage.Connections
		end
	end
})
main.Button({
	Text = "Teleport to the end",
	Callback = function()
		tp(lobby.dropperHitbox.Position)
		task.wait()
		tp(lobby.finalSegment.Hitbox.Position)
	end
})
