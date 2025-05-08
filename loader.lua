-- DumpLoader.lua
-- Executor-friendly GUI property dumper with Config flags:
--   Config.Savetofile      → writefile("GuiPropertiesDump.txt", …)
--   Config.Copytoclipboard → setclipboard(…)
--   Config.Print           → print to console

-- 0) Config check
if type(Config) ~= "table" then
    error(
        "❌ Config table missing!\n" ..
        "Define it before running:\n" ..
        "local Config = {\n" ..
        "  Savetofile = true,\n" ..
        "  Copytoclipboard = false,\n" ..
        "  Print = false,\n" ..
        "}\n" ..
        'loadstring(game:HttpGet("<your-raw-url>/DumpLoader.lua"))()'
    )
end

local saveToFile      = Config.Savetofile
local copyToClipboard = Config.Copytoclipboard
local shouldPrint     = Config.Print

-- 1) Sanity checks
if saveToFile then
    assert(type(writefile)=="function", "Executor must support writefile for Savetofile")
end
if copyToClipboard then
    assert(type(setclipboard)=="function", "Executor must support setclipboard for Copytoclipboard")
end

-- 2) Fetch properties table
local Players     = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

local url        = "https://raw.githubusercontent.com/notr3th/Properties/main/GUI/GUI.lua"
local chunk      = game:HttpGet(url)
local Properties = loadstring(chunk)()

-- 3) Accumulate every line into `lines`
local lines = {}

local function DumbInstance(instance, indent)
    indent = indent or ""
    lines[#lines+1] = string.format("%s[%s] %q", indent, instance.ClassName, instance.Name)
    for attr, val in pairs(instance:GetAttributes()) do
        lines[#lines+1] = string.format("%s  • Attribute – %s = %s", indent, attr, tostring(val))
    end
    local classDef = Properties[instance.ClassName]
    if classDef then
        local sections = classDef.Order or (function()
            local tmp = {}
            for k in pairs(classDef) do
                if k ~= "Order" then tmp[#tmp+1] = k end
            end
            return tmp
        end)()
        for _, section in ipairs(sections) do
            local props = classDef[section]
            if type(props)=="table" then
                lines[#lines+1] = string.format("%s  = %s =", indent, section)
                for _, propName in ipairs(props) do
                    local ok, v = pcall(function() return instance[propName] end)
                    if ok then
                        lines[#lines+1] = string.format("%s    • %s = %s", indent, propName, tostring(v))
                    end
                end
            end
        end
    end
    for _, child in ipairs(instance:GetChildren()) do
        DumbInstance(child, indent.."    ")
    end
end

-- 4) Dump all ScreenGuis under PlayerGui
for _, gui in ipairs(PlayerGui:GetChildren()) do
    if gui:IsA("ScreenGui") then
        lines[#lines+1] = ("====== Dumping: %s ======"):format(gui.Name)
        DumbInstance(gui, "  ")
    end
end

-- 5) Produce final output
local output = table.concat(lines, "\n")

-- Print to console?
if shouldPrint then
    for _, line in ipairs(lines) do
        print(line)
    end
end

-- Save to file?
if saveToFile then
    writefile("GuiPropertiesDump.txt", output)
    print(("✅ Dump complete! Wrote %d lines to GuiPropertiesDump.txt"):format(#lines))
end

-- Copy to clipboard?
if copyToClipboard then
    setclipboard(output)
    print("✅ Dump copied to clipboard.")
end
