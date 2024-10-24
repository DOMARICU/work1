--SaveSettings
local SVSetting = {
  maxflyspeed = 400
}

--Definitionen:
local Flying = false
local FlySpeed = 50
local FlyBodyGyro, FlyBodyVelocity
local ESPLinesEnabled = false
local TeamCheckEnabled = false
local ESPDistance = 100
local ESPLines = {}
local framework

local ox

-------------STARTUP-----------------
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local TweenService = game:GetService("TweenService")
local Camera = workspace.CurrentCamera
local ESPEnabled = false
local ESPBoxes = {}

local framework = {
  dekshdse = function(ex)
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
  end,

  adjustFlySpeed = function(ox)
       print("Test. Variable = " ..ox)
  end,

  createESPBox = function(player)
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
            framework:removeESPBox(player)
        end
    end)
  end,

  removeESPBox = function(player)
    if ESPBoxes[player] then
      for _, component in pairs(ESPBoxes[player]) do
          if component then
              component:Destroy()
          end
      end
      ESPBoxes[player] = nil
    end
  end,

  toggleESPBox = function(Value)
    ESPEnabled = Value

    if ESPEnabled then
        for _, player in ipairs(Players:GetPlayers()) do
            if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
                framework:createESPBox(player)
            end
        end

        Players.PlayerAdded:Connect(function(newPlayer)
            newPlayer.CharacterAdded:Connect(function()
                if ESPEnabled then
                    framework:createESPBox(newPlayer)
                end
            end)
        end)
    else
        for _, player in pairs(Players:GetPlayers()) do
            framework:removeESPBox(player)
        end
    end
  end,

  createESPBeam = function(player)
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
  end,

  removeESPBeam = function(player)
    if ESPLines[player.Name] then
      local data = ESPLines[player.Name]
      if data.beam then data.beam:Destroy() end
      if data.startAttachment then data.startAttachment:Destroy() end
      if data.endAttachment then data.endAttachment:Destroy() end
      ESPLines[player.Name] = nil
    end
  end,

  toggleESPLines = function(Value)
    ESPLinesEnabled = Value

    if ESPLinesEnabled then
        framework:addESPBeamsToAllPlayers()
    else
        framework:removeAllESPBeams()
    end
  end,

  addESPBeamsToAllPlayers = function()
    for _, player in ipairs(Players:GetPlayers()) do
      if player ~= LocalPlayer then
          framework:createESPBeam(player)
      end
  end

  Players.PlayerAdded:Connect(function(newPlayer)
      newPlayer.CharacterAdded:Connect(function()
          framework:createESPBeam(newPlayer)
      end)
    end)
  end,

  removeAllESPBeams = function()
    for _, data in pairs(ESPLines) do
      if data.beam then data.beam:Destroy() end
      if data.startAttachment then data.startAttachment:Destroy() end
      if data.endAttachment then data.endAttachment:Destroy() end
    end
    ESPLines = {}
  end,

  Players.PlayerRemoving:Connect(function(player)
    framework:removeESPBeam(player)
  end)
}

return framework
