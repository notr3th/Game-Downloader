if type(Config) ~= "table" then
    error(
        "❌ Config table missing!\n" ..
        "Define it before running:\n" ..
        "local Config = {\n" ..
        "  Savetofile = true,\n" ..
        "  Copytoclipboard = false,\n" ..
        "  Print = false,\n" ..
        "}\n" ..
        "then:\n" ..
        'loadstring(game:HttpGet(".../DumpLoader.lua"))()'
    )
end

local saveToFile = Config.Savetofile
local copyToClipboard = Config.Copytoclipboard
local shouldPrint = Config.Print

local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

local BASE_URL = "https://raw.githubusercontent.com/notr3th/Properties/main/"
local classCache = {}

local function fetchClassDef(className)
    if classCache[className] ~= nil then
        return classCache[className]
    end
    local ok, chunk = pcall(function()
        return game:HttpGet(BASE_URL .. className .. ".lua")
    end)
    if not ok then
        classCache[className] = false
        return false
    end
    local ok2, def = pcall(loadstring(chunk))
    if ok2 and type(def) == "table" then
        classCache[className] = def
        return def
    else
        classCache[className] = false
        return false
    end
end

local lines = {}

local function DumbInstance(inst, indent)
    indent = indent or ""
    lines[#lines+1] = string.format("%s[%s] %q", indent, inst.ClassName, inst.Name)
    for attr, val in pairs(inst:GetAttributes()) do
        lines[#lines+1] = string.format("%s  • Attribute – %s = %s",
            indent, attr, tostring(val))
    end
    local classDef = fetchClassDef(inst.ClassName)
    if classDef then
        local sections = classDef.Order or (function()
            local t={}
            for k in pairs(classDef) do
                if k~="Order" then t[#t+1]=k end
            end
            return t
        end)()
        for _, sec in ipairs(sections) do
            local props = classDef[sec]
            if type(props)=="table" then
                lines[#lines+1] = string.format("%s  = %s =", indent, sec)
                for _, propName in ipairs(props) do
                    local ok, v = pcall(function() return inst[propName] end)
                    if ok then
                        lines[#lines+1] = string.format("%s    • %s = %s",
                            indent, propName, tostring(v))
                    end
                end
            end
        end
    end
    for _, child in ipairs(inst:GetChildren()) do
        DumbInstance(child, indent .. "    ")
    end
end

for _, gui in ipairs(PlayerGui:GetChildren()) do
    if gui:IsA("ScreenGui") then
        lines[#lines+1] = ("====== Dumping: %s ======"):format(gui.Name)
        DumbInstance(gui, "  ")
    end
end

local output = table.concat(lines, "\n")

if shouldPrint then
    for _, line in ipairs(lines) do
        print(line)
    end
end

if saveToFile then
    assert(type(writefile)=="function", "Executor missing writefile")
    writefile("GuiPropertiesDump.txt", output)
    print(("✅ Dump complete! Wrote %d lines to GuiPropertiesDump.txt"):format(#lines))
end

if copyToClipboard then
    if type(setclipboard)=="function" then
        setclipboard(output)
        print("✅ Dump copied to clipboard.")
    else
        warn("⚠️ copytoclipboard requested, but executor has no setclipboard.")
    end
end
