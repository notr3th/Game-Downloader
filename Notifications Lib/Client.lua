local Notification = {}

function Notification:Notify(Text, Details, Miscellaneous)
    local CoreGui = game:GetService("CoreGui")  
    local Type = string.lower(tostring(Details.Type))
    local Shadow = Instance.new("ImageLabel")
    local Window = Instance.new("Frame")
    local Outline = Instance.new("Frame")
    local Title = Instance.new("TextLabel")
    local Description = Instance.new("TextLabel")
    
    Shadow.Name = "Shadow"
    Shadow.Parent = CoreGui:FindFirstChild("STX_Notification")
    Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
    Shadow.BackgroundTransparency = 1
    Shadow.BorderSizePixel = 0
    Shadow.Position = UDim2.new(0.91525954, 0, 0.936809778, 0)
    Shadow.Size = UDim2.new(0, 0, 0, 0)
    Shadow.Image = "rbxassetid://1316045217"
    Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    Shadow.ImageTransparency = 0.400
    Shadow.ScaleType = Enum.ScaleType.Slice
    Shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    
    Window.Name = "Window"
    Window.Parent = Shadow
    Window.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    Window.BorderSizePixel = 0
    Window.Position = UDim2.new(0, 5, 0, 5)
    Window.Size = UDim2.new(0, 230, 0, 80)
    Window.ZIndex = 2
    
    Outline.Name = "Outline"
    Outline.Parent = Window
    Outline.BackgroundColor3 = Details.OutlineColor
    Outline.BorderSizePixel = 0
    Outline.Position = UDim2.new(0, 0, 0, 25)
    Outline.Size = UDim2.new(0, 230, 0, 2)
    Outline.ZIndex = 5
    
    Title.Name = "Title"
    Title.Parent = Window
    Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Title.BackgroundTransparency = 1
    Title.BorderColor3 = Color3.fromRGB(27, 42, 53)
    Title.BorderSizePixel = 0
    Title.Position = UDim2.new(0, 8, 0, 2)
    Title.Size = UDim2.new(0, 222, 0, 22)
    Title.ZIndex = 4
    Title.Font = Enum.Font.GothamSemibold
    Title.Text = Text.Title
    Title.TextColor3 = Color3.fromRGB(220, 220, 220)
    Title.TextSize = 12
    Title.TextXAlignment = Enum.TextXAlignment.Left
    
    Description.Name = "Description"
    Description.Parent = Window
    Description.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Description.BackgroundTransparency = 1
    Description.BorderColor3 = Color3.fromRGB(27, 42, 53)
    Description.BorderSizePixel = 0
    Description.Position = UDim2.new(0, 8, 0, 34)
    Description.Size = UDim2.new(0, 216, 0, 40)
    Description.ZIndex = 4
    Description.Font = Enum.Font.GothamSemibold
    Description.Text = Text.Description
    Description.TextColor3 = Color3.fromRGB(180, 180, 180)
    Description.TextSize = 12
    Description.TextWrapped = true
    Description.TextXAlignment = Enum.TextXAlignment.Left
    Description.TextYAlignment = Enum.TextYAlignment.Top

    if Type == "Default" then
        coroutine.wrap(function()
            local script = Instance.new("LocalScript", Shadow)

            Shadow:TweenSize(UDim2.new(0, 240, 0, 90), "Out", "Linear", 0.2)
            Window.Size = UDim2.new(0, 230, 0, 80)
            Outline:TweenSize(UDim2.new(0, 0, 0, 2), "Out", "Linear", Details.Time)
    
            wait(Details.Time)
        
            Shadow:TweenSize(UDim2.new(0, 0, 0, 0), "Out", "Linear", 0.2)

            wait(0.2)

            Shadow:Destroy()
        end)()
    elseif Type == "Image" then
        Shadow:TweenSize(UDim2.new(0, 240, 0, 90), "Out", "Linear", 0.2)
        Window.Size = UDim2.new(0, 230, 0, 80)
        Title.Position = UDim2.new(0, 24, 0, 2)

        local ImageButton = Instance.new("ImageButton")
        ImageButton.Parent = Window
        ImageButton.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        ImageButton.BackgroundTransparency = 1
        ImageButton.BorderSizePixel = 0
        ImageButton.Position = UDim2.new(0, 4, 0, 4)
        ImageButton.Size = UDim2.new(0, 18, 0, 18)
        ImageButton.ZIndex = 5
        ImageButton.AutoButtonColor = false
        ImageButton.Image = Miscellaneous.Image
        ImageButton.ImageColor3 = Miscellaneous.ImageColor

        coroutine.wrap(function()
            local script = Instance.new('LocalScript', Shadow)
            Outline:TweenSize(UDim2.new(0, 0, 0, 2), "Out", "Linear", Details.Time)

            wait(Details.Time)

            Shadow:TweenSize(UDim2.new(0, 0, 0, 0), "Out", "Linear", 0.2)
            
            wait(0.2)

            Shadow:Destroy()
        end)()
    elseif Type == "Option" then
        Shadow:TweenSize(UDim2.new(0, 240, 0, 110), "Out", "Linear", 0.2)
        Window.Size = UDim2.new(0, 230, 0, 100)

        local Accept = Instance.new("ImageButton")
        local Decline = Instance.new("ImageButton")
        
        Accept.Name = "Accept"
        Accept.Parent = Window
        Accept.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Accept.BackgroundTransparency = 1
        Accept.BorderSizePixel = 0
        Accept.Position = UDim2.new(0, 28, 0, 76)
        Accept.Size = UDim2.new(0, 18, 0, 18)
        Accept.ZIndex = 5
        Accept.AutoButtonColor = false
        Accept.Image = "http://www.roblox.com/asset/?id=6031094667"
        Accept.ImageColor3 = Color3.fromRGB(83, 230, 50)

        Decline.Name = "Decline"
        Decline.Parent = Window
        Decline.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        Decline.BackgroundTransparency = 1
        Decline.BorderSizePixel = 0
        Decline.Position = UDim2.new(0, 7, 0, 76)
        Decline.Size = UDim2.new(0, 18, 0, 18)
        Decline.ZIndex = 5
        Decline.AutoButtonColor = false
        Decline.Image = "http://www.roblox.com/asset/?id=6031094678"
        Decline.ImageColor3 = Color3.fromRGB(255, 84, 84)

        coroutine.wrap(function()
            local script = Instance.new("LocalScript", Shadow)
            local Pending = true

            Accept.MouseButton1Click:Connect(function()
                pcall(function()
                    Miscellaneous.Callback(true)
                end)
                Shadow:TweenSize(UDim2.new(0, 0, 0, 0), "Out", "Linear", 0.2)
                
                wait(0.2)

                Shadow:Destroy()
                Pending = false
            end)

            Decline.MouseButton1Click:Connect(function()
                pcall(function()
                    Miscellaneous.Callback(false)
                end)
                Shadow:TweenSize(UDim2.new(0, 0, 0, 0), "Out", "Linear", 0.2)
                
                wait(0.2)

                Shadow:Destroy()
                Pending = false
            end)
            
            Outline:TweenSize(UDim2.new(0, 0, 0, 2), "Out", "Linear", Details.Time)
    
            wait(Details.Time)

            if Pending == true then
                Shadow:TweenSize(UDim2.new(0, 0, 0, 0), "Out", "Linear", 0.2)
                
                wait(0.2)

                Shadow:Destroy()
            end
        end)()
    end
end

return Notification
