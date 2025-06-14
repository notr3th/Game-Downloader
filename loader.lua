-------\\ Checks //-------
if type(Configuration) ~= "table" then
    error([[❌ Configuration table missing!
        Configuration = {
            Threads = 100,
            Savetofile = true,
        }
        
        loadstring(game:HttpGet("https://raw.githubusercontent.com/notr3th/Game-Downloader/main/loader.lua"))()
    ]])
end

if Configuration.Savetofile then
    assert(type(writefile)=="function", "Script requires the executor to support writefile.")
end

-------\\ Variables //-------
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer.PlayerGui
local Workspace = game:GetService("Workspace")
local StarterGui = game:GetService("StarterGui")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")

if PlayerGui:FindFirstChild("mPtMWI1wy9E5gfRtz6XN") then return end
game:GetObjects("rbxassetid://85469160259929")[1].Parent = PlayerGui

local Lines = {}
local takenAssets = 0
local totalAssets = 0
local Properties = loadstring(game:HttpGet("https://raw.githubusercontent.com/notr3th/Properties/main/Classes.lua"))()

local ScreenGui = PlayerGui:WaitForChild("mPtMWI1wy9E5gfRtz6XN")
local Menu = ScreenGui:WaitForChild("Menu")
local Assets = ScreenGui:WaitForChild("Assets")
local Finished = ScreenGui:WaitForChild("Finished")
local transitionFrame = ScreenGui:WaitForChild("Transition")
local menuButton = Menu:WaitForChild("TextButton")
local finishedButton = Finished:WaitForChild("TextButton")
local assetsText = Assets:WaitForChild("TextBox")
local finishedText = Finished:WaitForChild("TextLabel2")
local transitionCooldown = false
local menuCooldown = false
local finishedCooldown = false

-------\\ Functions //-------
local function DumbInstance(Instance, Indentation)
    Indentation = Indentation or ""
    takenAssets += 1

    Lines[#Lines+1] = string.format("%s[%s] %q", Indentation, Instance.ClassName, Instance.Name)

    for Attribute, Value in pairs(Instance:GetAttributes()) do
        Lines[#Lines+1] = string.format("%s  • Attribute – %s = %s", Indentation, Attribute, tostring(Value))
    end

    local Propertie = Properties[Instance.ClassName]
    if Propertie then
        Lines[#Lines+1] = Indentation .. "  = Properties ="
        for _, propName in ipairs(Propertie) do
            local ok, v = pcall(function() return Instance[propName] end)
            if ok then
                Lines[#Lines+1] = string.format("%s    • %s = %s", Indentation, propName, tostring(v))
            end
        end
    end

    assetsText.PlaceholderText = ("%d/%d Assets copied..."):format(takenAssets, totalAssets or 0)

    if takenAssets % Configuration.Threads == 0 then
        task.wait()
    end

    for _, Child in ipairs(Instance:GetChildren()) do
        if Child.Name ~= "mPtMWI1wy9E5gfRtz6XN" then
            DumbInstance(Child, Indentation .. "    ")
        end
    end
end

function Transition(Response)
	if transitionCooldown then return end
	transitionCooldown = true

	transitionFrame.Visible = true

	local FadeIn = TweenService:Create(transitionFrame, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 0})
	FadeIn:Play()
	FadeIn.Completed:Wait()

	wait(0.2)

	if Response then Response() end

	local FadeOut = TweenService:Create(transitionFrame, TweenInfo.new(0.6, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {BackgroundTransparency = 1})
	FadeOut:Play()
	FadeOut.Completed:Wait()

	transitionFrame.Visible = false
	transitionCooldown = false
end

function CoreGui(Value)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Chat, Value)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, Value)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.Health, Value)
	StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.PlayerList, Value)
end

-------\\ Listeners //-------
menuButton.Activated:Connect(function()
    if menuCooldown then return end
    menuCooldown = true

	Transition(function()
		Menu.Visible = false
		Assets.Visible = true
	end)

    for _, Service in ipairs(game:GetChildren()) do
        totalAssets +=  #Service:GetDescendants()
    end
    totalAssets -= 42

    for _, Service in ipairs(game:GetChildren()) do
        Lines[#Lines+1] = ("====== Dumping: %s ======"):format(Service.Name)
        DumbInstance(Service, "  ")
    end

    assetsText.PlaceholderText = ("%d/%d Assets copied..."):format(totalAssets, totalAssets)

    wait(2.5)
    
    local Output = table.concat(Lines, "\n")
    
    if Configuration.Savetofile then
        local Name = ("FULLDUMP_%s.txt"):format(HttpService:GenerateGUID(false))
        writefile(Name, Output)
        finishedText.Text = ('2. It was saved with the name "%s".'):format(Name)
    end

    Transition(function()
		Assets.Visible = false
		Finished.Visible = true
	end)

    menuCooldown = false
end)

finishedButton.Activated:Connect(function()
    if finishedCooldown then return end
    finishedCooldown = true

	Transition(function()
		CoreGui(true)
		Finished.Visible = false
	end)
	
	task.wait(5)
	ScreenGui:Destroy()
    finishedCooldown = false
end)

Transition(function()
	CoreGui(false)
	Menu.Visible = true
end)
