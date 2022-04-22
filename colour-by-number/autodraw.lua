local replicatedStorage = game:GetService("ReplicatedStorage")
local Roact = require(replicatedStorage.Roact)
local Notification = require(
	game:GetService("Players").LocalPlayer.PlayerScripts.UI.Components.UIComponents.TemporizedMessage
)
local plr = game:GetService("Players").LocalPlayer
local remote = replicatedStorage.Knit.Services.PixelGeneratorService.RF.DrawPixel
local head = plr.Character.Head
local thumb = "rbxthumb://type=AvatarHeadShot&id="..plr.UserId.."&w=420&h=420"
local drawingExists = false
local pixels = nil

local function notify(text: string, colour: Color3)
	local alert = Roact.mount(Roact.createElement(Notification, {
		Text = text,
		TextColor3 = colour,
		Font = Enum.Font.Cartoon,
		TextStrokeTransparency = 1,
		TextStrokeColor3 = Color3.fromRGB(255, 255, 255),
	}))
	task.delay(3, function()
		Roact.unmount(alert)
	end)
end

for _, image in pairs(workspace.Map.Blocks:GetDescendants()) do
	if not image:IsA("ImageLabel") then
		continue
	end
	if image.Image == thumb then
		local draw = image.Parent.Parent.Parent.Parent:FindFirstChild("Draw")
		if draw then
			drawingExists = true
			pixels = draw:GetChildren()
		end
	end
end
if not drawingExists then
	notify("You need to start a drawing before executing.", Color3.fromRGB(255, 0, 0))
	return
end
for _, pixel in pairs(pixels) do
	if pixel.Name == "Part" and pixel.Transparency == 0 and pixel.Texture.Transparency < 1 then
		if pixel.Texture.Transparency == 0 then
			firetouchinterest(head, pixel, 1)
			task.wait()
			firetouchinterest(head, pixel, 0)
		elseif pixel.Texture.Transparency == 0.75 then
			remote:InvokeServer(pixel)
		end
	end
end
notify("Drawing finished!", Color3.fromRGB(0, 255, 0))
