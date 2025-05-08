assert(type(writefile)=="function", "Executor needs writefile support!")
local Players     = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

local classCache = {}

local function fetchClassDef(className)
    if classCache[className] ~= nil then
        return classCache[className]
    end
    local ok, chunk = pcall(function()
        return game:HttpGet("https://raw.githubusercontent.com/notr3th/Properties/main/" .. className .. ".lua")
    end)
    if not ok then
        classCache[className] = false
        return false
    end
    local ok2, def = pcall(loadstring(chunk))
    if ok2 and type(def) == "table" then
        classCache[className] = def
        return def
    end
    classCache[className] = false
    return false
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
            local t = {}
            for k in pairs(classDef) do
                if k ~= "Order" then t[#t+1] = k end
            end
            return t
        end)()
        for _, sec in ipairs(sections) do
            local props = classDef[sec]
            if type(props) == "table" then
                lines[#lines+1] = string.format("%s  = %s =", indent, sec)
                for _, p in ipairs(props) do
                    local ok, v = pcall(function() return inst[p] end)
                    if ok then
                        lines[#lines+1] = string.format("%s    • %s = %s",
                            indent, p, tostring(v))
                    end
                end
            end
        end
    end
    for _, child in ipairs(inst:GetChildren()) do
        DumbInstance(child, indent.."    ")
    end
end

for _, gui in ipairs(PlayerGui:GetChildren()) do
    if gui:IsA("ScreenGui") then
        lines[#lines+1] = ("====== Dumping: %s ======"):format(gui.Name)
        DumbInstance(gui, "  ")
    end
end

local out = table.concat(lines, "\n")
writefile("GuiDump.txt", out)
print(("✅ Dump complete! Wrote %d lines to GuiDump.txt"):format(#lines))
