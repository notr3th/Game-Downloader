--[[
  Executor loader + per-class dumper + file writer.
  Each UI class is fetched from its own URL:
    https://raw.githubusercontent.com/notr3th/Properties/main/<ClassName>.lua
]]

assert(type(writefile)=="function", "Your executor needs writefile support!")
    local HttpService = game:GetService("HttpService")
    local Players     = game:GetService("Players")
    
    local LocalPlayer = Players.LocalPlayer
    local PlayerGui   = LocalPlayer:WaitForChild("PlayerGui")
    
    -- Base URL where each class lives as <ClassName>.lua returning a table,
    -- e.g. the file should `return { Order = {...}, Data = {...}, ... }`
    local BASE_URL = "https://raw.githubusercontent.com/notr3th/Properties/main/GUI/"
    
    -- Cache of loaded class definitions
    local classCache = {}
    
    local function fetchClassDef(className)
        if classCache[className] ~= nil then
            return classCache[className]
        end
        local success, chunk = pcall(function()
            return game:HttpGet(BASE_URL .. className .. ".lua")
        end)
        if not success then
            classCache[className] = false
            return false
        end
        local ok, def = pcall(loadstring(chunk))
        if ok and type(def) == "table" then
            classCache[className] = def
            return def
        else
            classCache[className] = false
            return false
        end
    end
    
    -- Accumulate lines here
    local lines = {}
    
    local function DumbInstance(instance, indent)
        indent = indent or ""
        table.insert(lines, string.format("%s[%s] %q", indent, instance.ClassName, instance.Name))
    
        -- Attributes
        for attr, val in pairs(instance:GetAttributes()) do
            table.insert(lines, string.format("%s  • Attribute – %s = %s",
                indent, attr, tostring(val)))
        end
    
        -- Sectioned properties (fetched per-class)
        local classDef = fetchClassDef(instance.ClassName)
        if classDef then
            local sections = classDef.Order or (function()
                local t = {}
                for k in pairs(classDef) do
                    if k ~= "Order" then t[#t+1] = k end
                end
                return t
            end)()
    
            for _, section in ipairs(sections) do
                local props = classDef[section]
                if type(props) == "table" then
                    table.insert(lines, string.format("%s  = %s =", indent, section))
                    for _, propName in ipairs(props) do
                        local ok, v = pcall(function() return instance[propName] end)
                        if ok then
                            table.insert(lines, string.format("%s    • %s = %s",
                                indent, propName, tostring(v)))
                        end
                    end
                end
            end
        end
    
        -- Recurse into children
        for _, child in ipairs(instance:GetChildren()) do
            DumbInstance(child, indent .. "    ")
        end
    end
    
    -- Dump all ScreenGuis
    for _, gui in ipairs(PlayerGui:GetChildren()) do
        if gui:IsA("ScreenGui") then
            table.insert(lines, ("====== Dumping: %s ======"):format(gui.Name))
            DumbInstance(gui, "  ")
        end
    end
    
    -- Write out
    local output = table.concat(lines, "\n")
    writefile("GuiPropertiesDump.txt", output)
    print(("✅ Dump complete! Wrote %d lines to GuiPropertiesDump.txt"):format(#lines))
    
