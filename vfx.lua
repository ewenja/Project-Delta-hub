--vfx
local VFXEnabled = false
local circleRadius = 10
local circleHeight = -2
local circleCount = 110
local updateInterval = 0.03
local rotationSpeed = 15
local particleEmitters = {}
local selectedVFXID = "rbxassetid://5833235272" -- 火焰粒子

-- 建立粒子
local function createParticle()
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

-- 初始化粒子環
local function initializeVFXCircle()
    for _ = 1, circleCount do
        createParticle()
    end
end

-- 清除粒子
local function clearVFXCircle()
    for _, attachment in ipairs(particleEmitters) do
        attachment:Destroy()
    end
    particleEmitters = {}
end

-- 更新粒子環繞位置
local function updateVFXCircle()
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
        wait(updateInterval)
    end
    clearVFXCircle()
end

-- 雷電效果
local function createZigzagLightning(startPos, endPos)
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

local function getGround(pos)
    local ray = workspace:Raycast(pos, Vector3.new(0, -50, 0), RaycastParams.new({
        FilterType = Enum.RaycastFilterType.Blacklist,
        FilterDescendantsInstances = {game.Players.LocalPlayer.Character}
    }))
    return ray and ray.Position or nil
end

local lightningEnabled = false
local function toggleLightningEffect(state)
    lightningEnabled = state
    if state then
        coroutine.wrap(function()
            while lightningEnabled do
                wait(math.random(0, 0.1))
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
        end)()
    end
end

-- 地板軌跡
local personalTrailEnabled = false
local function createPersonalTrail()
    local char = game.Players.LocalPlayer.Character
    local root = char and char:WaitForChild("HumanoidRootPart")
    while personalTrailEnabled do
        local ray = workspace:Raycast(root.Position, Vector3.new(0, -10, 0), RaycastParams.new({
            FilterType = Enum.RaycastFilterType.Blacklist,
            FilterDescendantsInstances = {char}
        }))
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
        wait(0.2)
    end
end
