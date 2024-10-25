local SVSetting = {
  maxflyspeed = 400
}

-- Definitionen:
local Flying = false
local FlyBodyGyro, FlyBodyVelocity
local ESPLinesEnabled = false
local TeamCheckEnabled = false
local ESPDistance = 100
local ESPLines = {}
local FlySpeed = 50

------------- STARTUP -------------
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local ESPEnabled = false
local ESPBoxes = {}

local function framework()

  local function init()
      print("Framework initialized.")
  end

  local function dekshdse(ex)
    if ex then
      if not Flying then
        Flying = true
  
        if LocalPlayer.Character then
          for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
              if part:IsA("BasePart") and part.CanCollide then
                  part.CanCollide = false
              end
          end
      end
  
      FlyBodyGyro = Instance.new("BodyGyro")
      FlyBodyGyro.P = 9e4
      FlyBodyGyro.MaxTorque = Vector3.new(9e4, 9e4, 9e4)
      FlyBodyGyro.CFrame = workspace.CurrentCamera.CFrame
      FlyBodyGyro.Parent = LocalPlayer.Character.HumanoidRootPart
  
      FlyBodyVelocity = Instance.new("BodyVelocity")
      FlyBodyVelocity.Velocity = Vector3.zero
      FlyBodyVelocity.MaxForce = Vector3.new(9e4, 9e4, 9e4)
      FlyBodyVelocity.Parent = LocalPlayer.Character.HumanoidRootPart
  
      local function updateFly()
          if not Flying then return end
  
          local cam = workspace.CurrentCamera
          local direction = Vector3.zero
  
          if UserInputService:IsKeyDown(Enum.KeyCode.W) then
              direction = direction + cam.CFrame.LookVector
          end
          if UserInputService:IsKeyDown(Enum.KeyCode.S) then
              direction = direction - cam.CFrame.LookVector
          end
          if UserInputService:IsKeyDown(Enum.KeyCode.A) then
              direction = direction - cam.CFrame.RightVector
          end
          if UserInputService:IsKeyDown(Enum.KeyCode.D) then
              direction = direction + cam.CFrame.RightVector
          end
  
          FlyBodyVelocity.Velocity = direction * FlySpeed
          FlyBodyGyro.CFrame = cam.CFrame
  
          if LocalPlayer.Character then
              for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                  if part:IsA("BasePart") and part.CanCollide then
                      part.CanCollide = false
                  end
              end
          end
      end
  
      RunService:BindToRenderStep("Fly", Enum.RenderPriority.Character.Value, updateFly)
      else
        Flying = false
  
        if FlyBodyGyro then FlyBodyGyro:Destroy() end
          if FlyBodyVelocity then FlyBodyVelocity:Destroy() end
  
          if LocalPlayer.Character then
              for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
                  if part:IsA("BasePart") then
                      part.CanCollide = true
                  end
              end
          end
  
          RunService:UnbindFromRenderStep("Fly")
      end
    else
      if Flying then
        Flying = false
  
        if FlyBodyGyro then FlyBodyGyro:Destroy() end
        if FlyBodyVelocity then FlyBodyVelocity:Destroy() end
  
        if LocalPlayer.Character then
          for _, part in ipairs(LocalPlayer.Character:GetDescendants()) do
            if part:IsA("BasePart") then
              part.CanCollide = true
            end
          end
        end
  
        RunService:UnbindFromRenderStep("Fly")
      end
    end
  end

  local function adjustFlySpeed(ox)
    local inputSpeed = tonumber(ox)
    if inputSpeed and inputSpeed >= 5 and inputSpeed <= SVSetting.maxflyspeed then
        FlySpeed = inputSpeed
    else
        print("ERROR! A higher Value Detected!", FlySpeed)
    end
  end

  local function removeESPBox(player)
    if ESPBoxes[player] then
        for _, component in pairs(ESPBoxes[player]) do
            if component then
                component:Destroy()
            end
        end
        ESPBoxes[player] = nil
    end
  end

  local function createESPBox(player)
    if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        return
    end
  
    local character = player.Character
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
  
    local box = Instance.new("BoxHandleAdornment")
    box.Size = humanoidRootPart.Size + Vector3.new(1, 3, 1)
    box.Adornee = humanoidRootPart
    box.Color3 = Color3.fromRGB(0, 255, 0)
    box.AlwaysOnTop = true
    box.ZIndex = 10
    box.Transparency = 0.3
    box.Parent = humanoidRootPart
  
    local glowBox = Instance.new("BoxHandleAdornment")
    glowBox.Size = humanoidRootPart.Size + Vector3.new(2, 4, 2)
    glowBox.Adornee = humanoidRootPart
    glowBox.Color3 = Color3.fromRGB(0, 255, 255)
    glowBox.AlwaysOnTop = true
    glowBox.ZIndex = 9
    glowBox.Transparency = 0.7
    glowBox.Parent = humanoidRootPart
  
    local billboard = Instance.new("BillboardGui")
    billboard.Adornee = humanoidRootPart
    billboard.Size = UDim2.new(4, 0, 1, 0)
    billboard.StudsOffset = Vector3.new(0, 4, 0)
    billboard.AlwaysOnTop = true
    billboard.Parent = humanoidRootPart
  
    ESPBoxes[player] = {box = box, glowBox = glowBox, billboard = billboard}
  
    character:WaitForChild("HumanoidRootPart").AncestryChanged:Connect(function(_, parent)
        if not parent then
            removeESPBox(player)
        end
    end)
  end

  local function toggleESPBox(Value)
    ESPEnabled = Value
  
    if ESPEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                createESPBox(player)
            end
        end
  
        Players.PlayerAdded:Connect(function(newPlayer)
            newPlayer.CharacterAdded:Connect(function()
                if ESPEnabled then
                    createESPBox(newPlayer)
                end
            end)
        end)
    else
        for _, player in pairs(Players:GetPlayers()) do
            removeESPBox(player)
        end
    end
  end

  local function createESPBeam(player)
    if player == LocalPlayer or not player.Character then
        return
    end
  
    local character = player.Character
    local lowerTorso = character:FindFirstChild("LowerTorso")
    local localCharacter = LocalPlayer.Character
    local localHumanoidRootPart = localCharacter and localCharacter:FindFirstChild("HumanoidRootPart")
  
    if not lowerTorso or not localHumanoidRootPart then
        return
    end
  
    local startAttachment = Instance.new("Attachment")
    startAttachment.Position = Vector3.new(0, -2.5, 0)
    startAttachment.Parent = localHumanoidRootPart
  
    local endAttachment = Instance.new("Attachment")
    endAttachment.Position = Vector3.new(0, 0, 0)
    endAttachment.Parent = lowerTorso
  
    local beam = Instance.new("Beam")
    beam.Attachment0 = startAttachment
    beam.Attachment1 = endAttachment
    beam.FaceCamera = true
    beam.Width0 = 0.05
    beam.Width1 = 0.05
    beam.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0))
    beam.Transparency = NumberSequence.new(0.2)
    beam.Parent = localHumanoidRootPart
  
    ESPLines[player.Name] = {beam = beam, startAttachment = startAttachment, endAttachment = endAttachment}
  
    local function updateBeam()
        if not player.Character or not lowerTorso:IsDescendantOf(Workspace) or not localCharacter:IsDescendantOf(Workspace) then
            beam.Enabled = false
            return
        end
  
        local distance = (localHumanoidRootPart.Position - lowerTorso.Position).Magnitude
        if distance > ESPDistance then
            beam.Enabled = false
            return
        end
  
        if TeamCheckEnabled and LocalPlayer.Team == player.Team then
            beam.Enabled = false
            return
        end
  
        local origin = localHumanoidRootPart.Position
        local direction = (lowerTorso.Position - origin).Unit * distance
  
        local raycastParams = RaycastParams.new()
        raycastParams.FilterDescendantsInstances = {localCharacter, character}
        raycastParams.FilterType = Enum.RaycastFilterType.Blacklist
        raycastParams.IgnoreWater = true
  
        local raycastResult = Workspace:Raycast(origin, direction, raycastParams)
  
        if raycastResult then
            beam.Color = ColorSequence.new(Color3.fromRGB(255, 0, 0))
        else
            beam.Color = ColorSequence.new(Color3.fromRGB(0, 255, 0))
        end
  
        beam.Enabled = true
    end
  
    RunService.RenderStepped:Connect(updateBeam)
  end

  local function removeESPBeam(player)
    if ESPLines[player.Name] then
        local data = ESPLines[player.Name]
        if data.beam then data.beam:Destroy() end
        if data.startAttachment then data.startAttachment:Destroy() end
        if data.endAttachment then data.endAttachment:Destroy() end
        ESPLines[player.Name] = nil
    end
  end

  local function addESPBeamsToAllPlayers()
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            createESPBeam(player)
        end
    end
  
    Players.PlayerAdded:Connect(function(newPlayer)
        newPlayer.CharacterAdded:Connect(function()
            createESPBeam(newPlayer)
        end)
    end)
  end

  local function removeAllESPBeams()
    for _, data in pairs(ESPLines) do
        if data.beam then data.beam:Destroy() end
        if data.startAttachment then data.startAttachment:Destroy() end
        if data.endAttachment then data.endAttachment:Destroy() end
    end
    ESPLines = {}
  end

  local function toggleESPLines(Value)
    ESPLinesEnabled = Value
  
    if ESPLinesEnabled then
        addESPBeamsToAllPlayers()
    else
        removeAllESPBeams()
    end
  end

  Players.PlayerRemoving:Connect(function(player)
    removeESPBeam(player)
  end)

  init()
  return {
    dekshdse = dekshdse,
    adjustFlySpeed = adjustFlySpeed,
    createESPBox = createESPBox,
    removeESPBox = removeESPBox,
    toggleESPBox = toggleESPBox,
    createESPBeam = createESPBeam,
    removeESPBeam = removeESPBeam,
    toggleESPLines = toggleESPLines
  }
end

return framework()
