local Notification = loadstring(game:HttpGet("https://raw.githubusercontent.com/notr3th/Game-Downloader/refs/heads/main/Notifications%20Library/Client.lua"))()

Notification:Notify(
    {Title = "Example title", Description = "Example description"},
    {OutlineColor = Color3.fromRGB(80, 80, 80), Time = 5, Type = "Option"},
    {Image = "http://www.roblox.com/asset/?id=6023426923", ImageColor = Color3.fromRGB(255, 84, 84), Callback = function(State) print(tostring(State)) end}
)

wait(1)

Notification:Notify(
    {Title = "Example title", Description = "Example description"},
    {OutlineColor = Color3.fromRGB(80, 80, 80), Time = 5, Type = "Image"},
    {Image = "http://www.roblox.com/asset/?id=6023426923", ImageColor = Color3.fromRGB(255, 84, 84)}
)

wait(1)

Notification:Notify(
    {Title = "Example title", Description = "Example description"},
    {OutlineColor = Color3.fromRGB(80, 80, 80), Time = 5, Type = "Default"}
)
