-- 全域參數
getgenv().VFXEnabled = false
getgenv().circleRadius = 10
getgenv().circleHeight = -2
getgenv().circleCount = 110
getgenv().updateInterval = 0.03
getgenv().rotationSpeed = 15
getgenv().particleEmitters = {}
getgenv().selectedVFXID = "rbxassetid://5833235272"
getgenv().personalTrailEnabled = false
getgenv().lightningEnabled = false

-- 粒子效果
function getgenv().createParticle()
    local attachment = Instance.new("Attachment", workspace.Terrain)
    local particle = Instance.new("ParticleEmitter", attachment)
    particle.Texture = "rbxassetid://373435404"
    particle.Rate = 10
    particle.Lifetime = NumberRange.new(0.5, 1)
    particle.Speed = NumberRange.new(0)
    particle.Size = NumberSequence.new(0.5)
    particle.LightEmission = 0.7
    particle.Transparency = NumberSequence.new(0.5)
    table.insert(particleEmitters, attachment)
end

function getgenv().initializeVFXCircle()
    for _ = 1, circleCount do
        createParticle()
    end
end

function getgenv().clearVFXCircle()
    for _, attachment in ipairs(particleEmitters) do
        attachment:Destroy()
    end
    particleEmitters = {}
end

function getgenv().updateVFXCircle()
    local currentAngle = 0
    while VFXEnabled do
        local char = game.Players.LocalPlayer.Character
        local root = char and char:FindFirstChild("HumanoidRootPart")
        if root then
            local pos = root.Position
            currentAngle += rotationSpeed
            for i, attachment in ipairs(particleEmitters) do
                local angle = math.rad(i * (360 / circleCount) + currentAngle)
                local x = circleRadius * math.cos(angle)
                local z = circleRadius * math.sin(angle)
                attachment.Position = pos + Vector3.new(x, circleHeight, z)
            end
        end
        task.wait(updateInterval)
    end
    clearVFXCircle()
end

-- 閃電效果
function getgenv().createZigzagLightning(startPos, endPos)
    local segments, current, beamParts = 10, startPos, {}
    for i = 1, segments do
        local nextPos = (i == segments and endPos) or (current + ((endPos - current) / segments) + Vector3.new(math.random(-3, 3), math.random(-3, -1), math.random(-3, 3)))
        local part = Instance.new("Part", workspace)
        part.Anchored, part.CanCollide, part.Transparency = true, false, 1

        local a0 = Instance.new("Attachment", part) a0.WorldPosition = current
        local a1 = Instance.new("Attachment", part) a1.WorldPosition = nextPos

        local beam = Instance.new("Beam", part)
        beam.Attachment0 = a0
        beam.Attachment1 = a1
        beam.Width0 = 0.2
        beam.Width1 = 0.1
        beam.LightEmission = 1
        beam.Texture = "rbxassetid://5833323391"
        beam.TextureLength = 1
        beam.TextureSpeed = 0.5
        beam.Transparency = NumberSequence.new({
            NumberSequenceKeypoint.new(0, 0),
            NumberSequenceKeypoint.new(1, 1)
        })
        table.insert(beamParts, part)
        current = nextPos
    end
    for _, part in ipairs(beamParts) do
        game.Debris:AddItem(part, 0.3)
    end
end

function getgenv().getGround(pos)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Blacklist
    params.FilterDescendantsInstances = {game.Players.LocalPlayer.Character}
    local ray = workspace:Raycast(pos, Vector3.new(0, -50, 0), params)
    return ray and ray.Position or nil
end

function getgenv().toggleLightningEffect(state)
    lightningEnabled = state
    if state then
        task.spawn(function()
            while lightningEnabled do
                task.wait(math.random(0, 0.1))
                local char = game.Players.LocalPlayer.Character
                local root = char and char:FindFirstChild("HumanoidRootPart")
                if root then
                    local start = root.Position + Vector3.new(math.random(-10, 10), math.random(5, 15), math.random(-10, 10))
                    local ground = getGround(start)
                    if ground then
                        createZigzagLightning(start, ground)
                    end
                end
            end
        end)
    end
end

-- 拖尾
function getgenv().createPersonalTrail()
    local char = game.Players.LocalPlayer.Character
    local root = char and char:WaitForChild("HumanoidRootPart")
    while personalTrailEnabled do
        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Blacklist
        params.FilterDescendantsInstances = {char}
        local ray = workspace:Raycast(root.Position, Vector3.new(0, -10, 0), params)
        if ray and ray.Instance then
            local attach = Instance.new("Attachment", ray.Instance)
            attach.WorldPosition = ray.Position
            local p = Instance.new("ParticleEmitter", attach)
            p.Texture = selectedVFXID
            p.Rate = 50
            p.Lifetime = NumberRange.new(0.5, 1)
            p.Speed = NumberRange.new(3)
            p.Size = NumberSequence.new(1.5)
            p.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(1, 1)
            })
            game.Debris:AddItem(attach, 1.5)
        end
        task.wait(0.2)
    end
end
