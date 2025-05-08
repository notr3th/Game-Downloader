if type(Configuration) ~= "table" then
    error([[❌ Configuration table missing!
        Configuration = {
          Savetofile = true,
          Copytoclipboard = false,
          Print = false,
        }

        loadstring(game:HttpGet("https://raw.githubusercontent.com/notr3th/GUI-Stealer/main/loader.lua"))()
    ]])
end

if Configuration.Savetofile then
    assert(type(writefile)=="function", "Executor needs writefile support for Savetofile")
end

if Configuration.Copytoclipboard then
    assert(type(setclipboard)=="function", "Executor needs setclipboard support for Copytoclipboard")
end

local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local Properties = loadstring(game:HttpGet("https://raw.githubusercontent.com/notr3th/Properties/main/GUI/GUI.lua"))()
local Lines = {}

local function DumbInstance(Instance, Indent)
    Indent = Indent or ""
    Lines[#Lines+1] = string.format("%s[%s] %q", Indent, Instance.ClassName, Instance.Name)

    for Attributes, Value in pairs(Instance:GetAttributes()) do
        Lines[#Lines+1] = string.format("%s  • Attribute – %s = %s", Indent, Attributes, tostring(Value))
    end

    local ClassName = Properties[Instance.ClassName]
    if ClassName then
        local Sections = ClassName.Order or (function()
            local Temp = {}
            for k in pairs(ClassName) do
                if k ~= "Order" then Temp[#Temp+1] = k end
            end
            return Temp
        end)()

        for _, Section in ipairs(Sections) do
            local Props = ClassName[Section]
            if type(Props)=="table" then
                Lines[#Lines+1] = string.format("%s  = %s =", Indent, Section)
                for _, propName in ipairs(Props) do
                    local ok, v = pcall(function() return Instance[propName] end)
                    if ok then
                        Lines[#Lines+1] = string.format("%s    • %s = %s", Indent, propName, tostring(v))
                    end
                end
            end
        end
    end

    for _, child in ipairs(Instance:GetChildren()) do
        DumbInstance(child, Indent.."    ")
    end
end

for _, gui in ipairs(PlayerGui:GetChildren()) do
    if gui:IsA("ScreenGui") then
        Lines[#Lines+1] = ("====== Dumping: %s ======"):format(gui.Name)
        DumbInstance(gui, "  ")
    end
end

local Output = table.concat(Lines, "\n")

if Configuration.Print then
    for _, Line in ipairs(Lines) do
        print(Line)
    end
end

if Configuration.Savetofile then
    local Name = ("GUISTEALER_%s.txt"):format(HttpService:GenerateGUID(false))
    writefile(Name, Output)
    print(("✅ Dump complete! Wrote %d lines to %s"):format(#Lines, Name))
end

if Configuration.Copytoclipboard then
    setclipboard(Output)
    print("✅ Dump copied to clipboard.")
end
