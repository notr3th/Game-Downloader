local CoreGui = game:GetService("CoreGui")
local GUI = CoreGui:FindFirstChild("STX_Notification")

if not GUI then
    local STX_Notification = Instance.new("ScreenGui")
    local UIListLayout = Instance.new("UIListLayout")
    STX_Notification.Name = "STX_Notification"
    STX_Notification.Parent = CoreGui
    STX_Notification.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    STX_Notification.ResetOnSpawn = false
    
    UIListLayout.Name = "UIListLayout"
    UIListLayout.Parent = STX_Notification
    UIListLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
end
