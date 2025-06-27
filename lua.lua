-------\\ Variables //-------
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local autoPromptEnabled = false
local selectedRarities = {}
local selectedDisplayNames = {}
local selectedMutations = {}

-------\\ Connections //-------
Players.LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

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
    Callback = function(toggle)
        autoPromptEnabled = toggle
        if toggle then
            local lp = Players.LocalPlayer
            local char = lp.Character or lp.CharacterAdded:Wait()
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid then
                humanoid.Health = 0
            end

            char = lp.CharacterAdded:Wait()
            local hrp = char:WaitForChild("HumanoidRootPart")
            task.wait(0.5)
            
            local humanoid = char:FindFirstChildOfClass("Humanoid")
            if humanoid and hrp then
                humanoid:MoveTo(Vector3.new(-410.479, -6.502, 78.204))
                humanoid.MoveToFinished:Wait()
            end


            while autoPromptEnabled and wait(0.5) do
                local lp = Players.LocalPlayer
                local char = lp.Character or lp.CharacterAdded:Wait()
                local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if not hrp then return end

                local animals = workspace:FindFirstChild("MovingAnimals")
                if not animals then return end

                for _, animal in ipairs(animals:GetChildren()) do
                    local animalHRP = animal:FindFirstChild("HumanoidRootPart")
                    if animalHRP and (animalHRP.Position - hrp.Position).Magnitude <= 10 then
                        local info = animalHRP:FindFirstChild("Info")
                        local overhead = info and info:FindFirstChild("AnimalOverhead")

                        local rarityLabel = overhead and overhead:FindFirstChild("Rarity")
                        local displayNameLabel = overhead and overhead:FindFirstChild("DisplayName")
                        local mutationLabel = overhead and overhead:FindFirstChild("Mutation")

                        local rarityMatch = rarityLabel and table.find(selectedRarities, rarityLabel.Text)
                        local nameMatch = displayNameLabel and table.find(selectedDisplayNames, displayNameLabel.Text)
                        local mutationMatch = mutationLabel and table.find(selectedMutations, mutationLabel.Text)

                        local rarityOrNameSelected = (#selectedRarities > 0) or (#selectedDisplayNames > 0)
                        local mutationSelected = (#selectedMutations > 0)

                        local shouldPrompt = false

                        if mutationSelected then
                            if rarityOrNameSelected then
                                if mutationMatch and (rarityMatch or nameMatch) then
                                    shouldPrompt = true
                                end
                            else
                                if mutationMatch then
                                    shouldPrompt = true
                                end
                            end
                        else
                            if rarityMatch or nameMatch then
                                shouldPrompt = true
                            end
                        end

                        if shouldPrompt then
                            local promptAttachment = animalHRP:FindFirstChild("PromptAttachment")
                            local prompt = promptAttachment and promptAttachment:FindFirstChildOfClass("ProximityPrompt")
                            if prompt then
                                fireproximityprompt(prompt, 3)
                            end
                        end
                    end
                end
            end
        end
    end,
})
