--[[
  Executor-friendly loader + dumper + file writer for GUI properties.
  Paste this into Codex (or any executor with game:HttpGet + writefile).
]]

-- sanity check
assert(type(writefile)=="function", "Your executor must support writefile")

local Players     = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")

-- 1) Pull in your big Properties table remotely
local url        = "https://raw.githubusercontent.com/notr3th/Properties/main/full.lua"
local chunk      = game:HttpGet(url)
local Properties = loadstring(chunk)()

-- 2) Accumulate every line into `lines`
local lines = {}

local function DumbInstance(instance, indent)
    indent = indent or ""
    table.insert(lines, string.format("%s[%s] %q", indent, instance.ClassName, instance.Name))
    for attr, val in pairs(instance:GetAttributes()) do
        table.insert(lines, string.format("%s  • Attribute – %s = %s", indent, attr, tostring(val)))
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
            if props then
                table.insert(lines, string.format("%s  = %s =", indent, section))
                for _, propName in ipairs(props) do
                    local ok, v = pcall(function() return instance[propName] end)
                    if ok then
                        table.insert(lines, string.format("%s    • %s = %s", indent, propName, tostring(v)))
                    end
                end
            end
        end
    end
    for _, child in ipairs(instance:GetChildren()) do
        DumbInstance(child, indent .. "    ")
    end
end

-- 3) Dump all ScreenGuis under PlayerGui
for _, gui in ipairs(PlayerGui:GetChildren()) do
    if gui:IsA("ScreenGui") then
        table.insert(lines, ("====== Dumping: %s ======"):format(gui.Name))
        DumbInstance(gui, "  ")
    end
end

-- 4) Write it all out at once
local output = table.concat(lines, "\n")
writefile("GuiPropertiesDump.txt", output)
print(("✅ Dump complete! Wrote %d lines to GuiPropertiesDump.txt"):format(#lines))
