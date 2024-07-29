local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

-- Wait 12 seconds before executing the script
wait(12)

local function createBox()
    local box = {}
    for i = 1, 12 do
        local line = Drawing.new("Line")
        line.Color = Color3.new(1, 0, 0)
        line.Thickness = 2.5
        line.Transparency = 1
        box[i] = line
    end
    return box
end

local function updateBox(box, position, size)
    -- Scale down the size
    local scaleFactor = 0.69
    size = size * scaleFactor
    
    local corners = {
        position + Vector3.new(-size.X, size.Y, -size.Z) / 2,
        position + Vector3.new(size.X, size.Y, -size.Z) / 2,
        position + Vector3.new(-size.X, -size.Y, -size.Z) / 2,
        position + Vector3.new(size.X, -size.Y, -size.Z) / 2,
        position + Vector3.new(-size.X, size.Y, size.Z) / 2,
        position + Vector3.new(size.X, size.Y, size.Z) / 2,
        position + Vector3.new(-size.X, -size.Y, size.Z) / 2,
        position + Vector3.new(size.X, -size.Y, size.Z) / 2
    }

    local screenCorners = {}
    for _, corner in ipairs(corners) do
        local screenPos, onScreen = Camera:WorldToViewportPoint(corner)
        table.insert(screenCorners, {pos = screenPos, visible = onScreen})
    end

    if #screenCorners == 8 then
        local lines = {
            {1, 2}, {2, 4}, {4, 3}, {3, 1},
            {5, 6}, {6, 8}, {8, 7}, {7, 5},
            {1, 5}, {2, 6}, {3, 7}, {4, 8}
        }

        for i, line in ipairs(lines) do
            if screenCorners[line[1]].visible and screenCorners[line[2]].visible then
                box[i].From = Vector2.new(screenCorners[line[1]].pos.X, screenCorners[line[1]].pos.Y)
                box[i].To = Vector2.new(screenCorners[line[2]].pos.X, screenCorners[line[2]].pos.Y)
                box[i].Visible = true
            else
                box[i].Visible = false
            end
        end
    end
end

local boxes = {}
for _, player in pairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        boxes[player] = createBox()
    end
end

RunService.RenderStepped:Connect(function()
    for player, box in pairs(boxes) do
        if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local position = player.Character.HumanoidRootPart.Position
            local size = player.Character:GetExtentsSize()
            updateBox(box, position, size)
        end
    end
end)

Players.PlayerAdded:Connect(function(player)
    if player ~= LocalPlayer then
        boxes[player] = createBox()
    end
end)

Players.PlayerRemoving:Connect(function(player)
    if boxes[player] then
        for _, part in pairs(boxes[player]) do
            part:Remove()
        end
        boxes[player] = nil
    end
end)
