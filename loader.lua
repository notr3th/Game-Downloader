-- DumpLoader.lua
-- Executor-friendly GUI dumper with per-class URLs + full.lua fallback

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
        'loadstring(game:HttpGet(".../DumpLoader.lua"))()'
    )
end

local saveToFile      = Config.Savetofile
local copyToClipboard = Config.Copytoclipboard
local shouldPrint     = Config.Print

-- 1) Services + URLs
local Players     = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")
local BASE_URL    = "https://raw.githubusercontent.com/notr3th/Properties/main/"
local FULL_URL    = BASE_URL .. "full.lua"
local classCache  = {}
local fullProps

-- 2) Load full.lua on demand
local function loadFull()
    if fullProps then return end
    local ok, chunk = pcall(function() return game:HttpGet(FULL_URL) end)
    if not ok then
        warn("⚠️ Could not fetch full.lua:", chunk)
        fullProps = {}
        return
    end
    local ok2, tbl = pcall(loadstring(chunk))
    fullProps = (ok2 and type(tbl)=="table") and tbl or {}
end

-- 3) Fetch per-class, fallback to fullProps
local function fetchClassDef(className)
    if classCache[className] ~= nil then
        return classCache[className]
    end

    -- Try individual file
    local ok, chunk = pcall(function()
        return game:HttpGet(BASE_URL .. className .. ".lua")
    end)
    if ok then
        local ok2, def = pcall(loadstring(chunk))
        if ok2 and type(def)=="table" then
            classCache[className] = def
            return def
        end
    end

    -- Fallback to full.lua
    loadFull()
    local def = fullProps[className]
    if type(def)=="table" then
        classCache[className] = def
        return def
    end

    classCache[className] = false
    return false
end

-- 4) Dumper
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

-- 5) Walk and collect
for _, gui in ipairs(PlayerGui:GetChildren()) do
    if gui:IsA("ScreenGui") then
        lines[#lines+1] = ("====== Dumping: %s ======"):format(gui.Name)
        DumbInstance(gui, "  ")
    end
end

-- 6) Output
local output = table.concat(lines, "\n")

if shouldPrint then
    for _, l in ipairs(lines) do print(l) end
end

if saveToFile then
    assert(type(writefile)=="function", "⚠️ writefile not supported")
    writefile("GuiPropertiesDump.txt", output)
    print(("✅ Wrote %d lines to GuiPropertiesDump.txt"):format(#lines))
end

if copyToClipboard then
    if type(setclipboard)=="function" then
        setclipboard(output)
        print("✅ Dump copied to clipboard.")
    else
        warn("⚠️ setclipboard not supported")
    end
end
