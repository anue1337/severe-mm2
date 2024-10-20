local workspace = getchildren(Game)[1]
local espElements = {}
local localPlayer = getlocalplayer()
local localPlayerChar = getcharacter(localPlayer)
local localHumanoidRootPart = findfirstchild(localPlayerChar, "HumanoidRootPart")

local gunPlayers = {}
local knifePlayers = {}

local KnifeText = Drawing.new("Text")
KnifeText.Text = ""
KnifeText.Visible = false
KnifeText.Color = {255, 0, 0}
KnifeText.Size = 20
KnifeText.Center = true
KnifeText.Outline = true

local CooldownText = Drawing.new("Text")
CooldownText.Text = "Cooldown"
CooldownText.Visible = false
CooldownText.Color = {255, 255, 255}
CooldownText.Size = 20
CooldownText.Center = true
CooldownText.Outline = true

local GunText = Drawing.new("Text")
GunText.Text = ""
GunText.Visible = false
GunText.Color = {0, 0, 255}
GunText.Size = 20
GunText.Center = true
GunText.Outline = true

local GunDropText = Drawing.new("Text")
GunDropText.Text = ""
GunDropText.Visible = false
GunDropText.Color = {255, 255, 0}  
GunDropText.Size = 20
GunDropText.Center = true
GunDropText.Outline = true

local screenWidth = 1920
local screenHeight = 1080
local offsetY = 100

KnifeText.Position = {screenWidth / 2, offsetY}
CooldownText.Position = {screenWidth / 2, offsetY}
GunText.Position = {screenWidth / 2, offsetY + 40}
GunDropText.Position = {screenWidth / 2, offsetY + 80}

local function getPosition(part)
    return part and string.find(getclassname(part), "Part") and getposition(part) or nil
end

local function getHealth(humanoid)
    if humanoid and getclassname(humanoid) == "Humanoid" then
        return gethealth(humanoid)
    end
    return 0
end

local function getMaxHealth(humanoid)
    if humanoid and getclassname(humanoid) == "Humanoid" then
        return getmaxhealth(humanoid)
    end
    return 0
end

local function createESP()
    local esp = {
        text = Drawing.new("Text"),
        healthText = Drawing.new("Text"),
        distanceText = Drawing.new("Text"),
        roleText = Drawing.new("Text") 
    }
    for _, t in pairs({esp.text, esp.healthText, esp.distanceText, esp.roleText}) do
        t.Size = 12
        t.Center = true
        t.Outline = true
    end
    esp.text.Color = {255, 255, 255}
    esp.healthText.Color = {0, 255, 0}
    esp.distanceText.Color = {255, 255, 255}
    esp.roleText.Color = {255, 255, 255} 
    return esp
end

local function calculateDistance(pos1, pos2)
    local dx = pos1.x - pos2.x
    local dy = pos1.y - pos2.y
    local dz = pos1.z - pos2.z
    return math.sqrt(dx * dx + dy * dy + dz * dz)
end

local function updateESP(part, esp, parentName, health, maxHealth, isGun, isKnife, isGunDrop)
    local pos3D = getPosition(part)
    if pos3D then
        local pos2D, onScreen = worldtoscreenpoint({pos3D.x, pos3D.y, pos3D.z})
        if onScreen then
            local localPos3D = getPosition(localHumanoidRootPart)
            if localPos3D then
                local distance = calculateDistance(pos3D, localPos3D)

                if distance <= 99999999 then 
                    esp.text.Position = {pos2D.x, pos2D.y - 15}
                    esp.text.Text = parentName
                    esp.text.Visible = true

                    esp.healthText.Position = {pos2D.x, pos2D.y}
                    esp.healthText.Text = string.format("HP: %d/%d", health, maxHealth)
                    esp.healthText.Visible = true

                    if health <= (maxHealth * 0.35) then
                        esp.healthText.Color = {255, 0, 0}
                    elseif health <= (maxHealth * 0.5) then
                        esp.healthText.Color = {255, 255, 0}
                    else
                        esp.healthText.Color = {0, 255, 0}
                    end

                    esp.distanceText.Position = {pos2D.x, pos2D.y + 15}
                    esp.distanceText.Text = string.format("D: %d", math.round(distance))
                    esp.distanceText.Visible = true

                    if isGun then
                        esp.text.Color = {0, 0, 255}  
                        esp.roleText.Text = "Sheriff"
                        esp.roleText.Color = {0, 0, 255}
                    elseif isKnife then
                        esp.text.Color = {255, 0, 0}  
                        esp.roleText.Text = "Murderer"
                        esp.roleText.Color = {255, 0, 0}
                    else
                        esp.text.Color = {255, 255, 255}  
                        esp.roleText.Text = "Innocent"
                        esp.roleText.Color = {255, 255, 255}
                    end

                    esp.roleText.Position = {pos2D.x, pos2D.y - 30} 
                    esp.roleText.Visible = true

                    if isGunDrop then
                        esp.text.Text = "GunDrop"
                        esp.text.Color = {255, 255, 0}  
                        esp.distanceText.Text = string.format("D: %d", math.round(distance))
                        esp.distanceText.Color = {255, 255, 0}
                    end
                else
                    esp.text.Visible = false
                    esp.healthText.Visible = false
                    esp.distanceText.Visible = false
                    esp.roleText.Visible = false
                end
            end
        else
            esp.text.Visible = false
            esp.healthText.Visible = false
            esp.distanceText.Visible = false
            esp.roleText.Visible = false
        end
    else
        esp.text.Visible = false
        esp.healthText.Visible = false
        esp.distanceText.Visible = false
        esp.roleText.Visible = false
    end
end

local function checkPlayersForItems()
    while true do
        local players = getchildren(findservice(Game, "Players"))
        local newGunPlayers = {}
        local newKnifePlayers = {}

        for _, player in ipairs(players) do
            local character = getcharacter(player)
            if character then
                local backpack = findfirstchild(player, "Backpack")
                local knifeInBackpack = backpack and findfirstchild(backpack, "Knife")
                local gunInBackpack = backpack and findfirstchild(backpack, "Gun")
                local knifeInHand = findfirstchild(character, "Knife")
                local gunInHand = findfirstchild(character, "Gun")

                if knifeInBackpack or knifeInHand then
                    newKnifePlayers[getname(player)] = true
                end

                if gunInBackpack or gunInHand then
                    newGunPlayers[getname(player)] = true
                end
            end
        end

        gunPlayers = newGunPlayers
        knifePlayers = newKnifePlayers

        local knifeDetected = false
        local gunDetected = false
        for name, _ in pairs(knifePlayers) do
            KnifeText.Text = "Murderer: " .. name
            KnifeText.Visible = true
            knifeDetected = true
            break
        end

        if not knifeDetected then
            KnifeText.Visible = false
            CooldownText.Visible = true
        else
            CooldownText.Visible = false
        end

        for name, _ in pairs(gunPlayers) do
            GunText.Text = "Sheriff: " .. name
            GunText.Visible = true
            gunDetected = true
            break
        end

        if not gunDetected then
            GunText.Visible = false
        end

        wait(1)
    end
end

local function cacheLoop()
    while true do
        if getpressedkey() == "End" then
            
            Drawing.clear()
            print("Finished")
            break
        end
        wait(1)
    end
end

local function updateGunDrop()
    
    local children = getchildren(workspace)

    for _, model in pairs(children) do
        
        local spawns = findfirstchild(model, "Spawns")
        local coinContainer = findfirstchild(model, "CoinContainer")

        
        if spawns and coinContainer then
            
            local gunDrop = findfirstchild(model, 'GunDrop')
            
            if gunDrop then
                local pos3D = getPosition(gunDrop)
                if pos3D then
                    local pos2D, onScreen = worldtoscreenpoint({pos3D.x, pos3D.y, pos3D.z})
                    if onScreen then
                        local gunDropMessage = 'The gun has been dropped!'
                        if GunDropText.Text ~= gunDropMessage then
                            GunDropText.Text = gunDropMessage
                        end
                        GunDropText.Position = {pos2D.x, pos2D.y - 15}
                        GunDropText.Visible = true

                        local localPos3D = getPosition(localHumanoidRootPart)
                        if localPos3D then
                            local distance = calculateDistance(pos3D, localPos3D)

                            local gunDropDistanceText = string.format('The gun has been dropped!\nD: %d', math.round(distance))
                            if GunDropText.Text ~= gunDropDistanceText then
                                GunDropText.Text = gunDropDistanceText
                            end
                            GunDropText.Position = {pos2D.x, pos2D.y - 15}
                            GunDropText.Visible = true
                        end
                    else
                        GunDropText.Visible = false
                    end
                else
                    GunDropText.Visible = false
                end
            else
                GunDropText.Visible = false
            end
        end
    end
end

local function isIgnoredModel(model)
    local ignoredModels = {
        "ServerStatus",
        "Lobby",
        "ThrowingKnife"
    }


    for _, ignored in ipairs(ignoredModels) do
        if getname(model) == ignored then
            return true
        end
    end
end

local function mainLoop()
    while true do
        updateGunDrop()

        local children = getchildren(workspace)
        local currentParts = {}
        local localPos3D = getPosition(localHumanoidRootPart)
        if localPos3D then
            for _, part in pairs(children) do

				if getname(part) == "EffectLoader" then
                    continue
                end

                if not isIgnoredModel(part) then
                    if getclassname(part) == "Model" and part ~= localPlayerChar then
                        local humanoidRootPart = findfirstchild(part, "HumanoidRootPart")
                        local humanoid = findfirstchild(part, "Humanoid")
                        local targetPart = humanoidRootPart or humanoid
                        if humanoid then
                            local parentName = getname(part)
                            local health = getHealth(humanoid)
                            local maxHealth = getMaxHealth(humanoid)
                            local isGun = gunPlayers[parentName] or false
                            local isKnife = knifePlayers[parentName] or false
                            local isGunDrop = findfirstchild(part, "GunDrop") ~= nil
                            currentParts[part] = true
                            if not espElements[part] then
                                espElements[part] = createESP()
                            end
                            updateESP(targetPart, espElements[part], parentName, health, maxHealth, isGun, isKnife, isGunDrop)
                        end
                    elseif getclassname(part) == "Model" and findfirstchild(part, "GunDrop") then
                        local gunDropPart = findfirstchild(part, "GunDrop")
                        if gunDropPart then
                            local gunDropESP = createESP()
                            local gunDropPosition = getPosition(gunDropPart)
                            if gunDropPosition then
                                local pos2D, onScreen = worldtoscreenpoint({gunDropPosition.x, gunDropPosition.y, gunDropPosition.z})
                                if onScreen then
                                    local distance = calculateDistance(gunDropPosition, localPos3D)
                                    updateESP(gunDropPart, gunDropESP, "GunDrop", 0, 0, false, false, true)
                                end
                            end
                        end
                    end
                end
            end

            for part, _ in pairs(espElements) do
                if not currentParts[part] then
                    espElements[part].text:Remove()
                    espElements[part].healthText:Remove()
                    espElements[part].distanceText:Remove()
                    espElements[part].roleText:Remove()
                    espElements[part] = nil
                end
            end
        end
        wait(0.001)
    end
end



spawn(checkPlayersForItems)
spawn(cacheLoop)
spawn(mainLoop)
