-------\\ Variables //-------
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local VirtualInputManager = game:GetService("VirtualInputManager")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local LocalPlayer = Players.LocalPlayer
local Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
local Humanoid = Character:FindFirstChildOfClass("Humanoid")

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local MovingAnimals = Workspace:FindFirstChild("MovingAnimals")

local logCooldown = false
local webhookURL = ""
local autoSpin = false
local antiTeleport = false
local autoBuy = false
local selectedRarities = {}
local selectedDisplayNames = {}
local selectedMutations = {}

-------\\ Connections //-------
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

LocalPlayer.CharacterAdded:Connect(function(newCharacter)
    Character = newCharacter
    Humanoid = newCharacter:WaitForChild("Humanoid")
    HumanoidRootPart = newCharacter:WaitForChild("HumanoidRootPart")
end)

-------\\ Functions //-------
function sendLog(Message)
    if not logCooldown then
        logCooldown = true
        local Headers = {
            ["Content-Type"] = "application/json"
        }

        local Data = {
            username = LocalPlayer.DisplayName,
            avatar_url = "https://tr.rbxcdn.com/30DAY-AvatarHeadshot-D6873359FAAA3375F7489AFDDEE2009D-Png/420/420/AvatarHeadshot/Png/noFilter",
            content = Message
        }

        local Body = HttpService:JSONEncode(Data)
        local response = request({
            Url = webhookURL,
            Method = "POST",
            Headers = Headers,
            Body = Body
        })

        task.wait(2)
        logCooldown = false
    end
end

function walkTo(Position)
    if Humanoid and HumanoidRootPart then
        Humanoid:MoveTo(Position)
        Humanoid.MoveToFinished:Wait()
    end
end

function checkWhitelist(animalHumanoidRootPart)
    local shouldPrompt = false

    local Info = animalHumanoidRootPart.Info
    local Overhead = Info.AnimalOverhead
    local rarityLabel = Overhead.Rarity
    local characterLabel = Overhead.DisplayName
    local mutationLabel = Overhead.Mutation

    local rarityMatch = table.find(selectedRarities, rarityLabel.Text)
    local characterMatch = table.find(selectedDisplayNames, characterLabel.Text)
    local mutationMatch = table.find(selectedMutations, mutationLabel.Text)
    local rarityOrNameSelected = (#selectedRarities > 0) or (#selectedDisplayNames > 0)
    local mutationSelected = (#selectedMutations > 0)

    if mutationSelected then
        if rarityOrNameSelected then
            if mutationMatch and (rarityMatch or characterMatch) then
                return true
            end
        else
            if mutationMatch then
                return true
            end
        end
    else
        if rarityMatch or characterMatch then
            return true
        end
    end
    return false
end

function firePrompt(animalHumanoidRootPart)
    local promptAttachment = animalHumanoidRootPart:FindFirstChild("PromptAttachment")
    local Prompt = promptAttachment:FindFirstChildOfClass("ProximityPrompt")
    if Prompt then
        fireproximityprompt(Prompt, 3)
    end
end

-------\\ Setup //-------
local Window = Rayfield:CreateWindow({
    Name = "R3TH PRIV",
    Icon = 0,
    LoadingTitle = "R3TH PRIV",
    LoadingSubtitle = "by R3TH",
    ShowText = "R3TH PRIV",
    Theme = "Default",
    ToggleUIKeybind = "Z",
    DisableRayfieldPrompts = false,
    DisableBuildWarnings = false,
})

local farmingTab = Window:CreateTab("Farming", 4483362458)

-------\\ Main //-------
farmingTab:CreateDropdown({
    Name = "Filter Rarity(s)",
    Options = {"Common", "Rare", "Epic", "Legendary", "Mythic", "Brainrot God", "Secret"},
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "filterRaritys",
    Callback = function(Raritys)
        selectedRarities = Raritys
    end,
})

farmingTab:CreateDropdown({
    Name = "Filter Character(s)",
    Options = {"Cocofanto Elefanto", "Girafa Celestre", "Tralalero Tralala", "Odin Din Din Dun", "La Vacca Saturno Saturnita", "Los Tralaleritos", "Graipuss Medussi", "La Grande Combinasion"},
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "filterCharacters",
    Callback = function(Characters)
        selectedDisplayNames = Characters
    end,
})

farmingTab:CreateDropdown({
    Name = "Required Mutation(s)",
    Options = {"Gold", "Rainbow", "Diamond"},
    CurrentOption = {},
    MultipleOptions = true,
    Flag = "requiredMutations",
    Callback = function(Mutations)
        selectedMutations = Mutations
    end,
})

farmingTab:CreateToggle({
    Name = "Auto Buy",
    CurrentValue = false,
    Flag = "autoBuy",
    Callback = function(Toggle)
        autoBuy = Toggle
        if autoBuy then
            if Humanoid then
                Humanoid.Health = 0
            end

            task.wait(20)

            walkTo(Vector3.new(-410.479, -6.502, 78.204))

            while autoBuy and task.wait(0.1) do
                if not HumanoidRootPart then return end

                for _, Animal in ipairs(MovingAnimals:GetChildren()) do
                    local animalHumanoidRootPart = Animal:FindFirstChild("HumanoidRootPart")
                    if animalHumanoidRootPart and (animalHumanoidRootPart.Position - HumanoidRootPart.Position).Magnitude <= 10 then

                        if checkWhitelist(animalHumanoidRootPart) then
                            spawn(function()
                                sendLog("Charcter purchased: " .. animalHumanoidRootPart.Overhead.DisplayName.Text)
                            end)
                            firePrompt(animalHumanoidRootPart)
                        end
                    end
                end
            end
        end
    end,
})

farmingTab:CreateToggle({
    Name = "Auto Spin Wheel",
    CurrentValue = false,
    Flag = "autoSpin",
    Callback = function(Toggle)
        autoSpin = Toggle
        while autoSpin and task.wait(30) do
            ReplicatedStorage:WaitForChild("Packages"):WaitForChild("Net"):WaitForChild("RE/RainbowSpinWheelService/Spin"):FireServer()
        end
    end,
})

farmingTab:CreateToggle({
    Name = "Anti Teleport",
    CurrentValue = false,
    Flag = "antiTeleport",
    Callback = function(Toggle)
        antiTeleport = Toggle
        while antiTeleport and task.wait(300) do
            VirtualInputManager:SendMouseButtonEvent(1, 1, 0, true, nil, 0)
            VirtualInputManager:SendMouseButtonEvent(1, 1, 0, false, nil, 0)
        end
    end,
})

farmingTab:CreateInput({
    Name = "Webhook URL",
    PlaceholderText = "https://discord.com/api/webhooks/xxxxx/xxxxx",
    RemoveTextAfterFocusLost = false,
    Callback = function(Text)
        webhookURL = Text
    end,
})
