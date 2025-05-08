-- GuiDumpClipboardImporter.lua
-- Enhanced: gracefully skips unknown classes, fixes size, color, and FontFace parsing
-- Plugin UI shows on load and toggles via toolbar button
-- Place under Plugins/

local toolbar    = plugin:CreateToolbar("GUI Tools")
local importBtn  = toolbar:CreateButton("Clipboard Import", "Import GUI from clipboard dump", "")

local widgetInfo = DockWidgetPluginGuiInfo.new(
    Enum.InitialDockState.Right, true, true,
    400, 300, 400, 300
)
local dock = plugin:CreateDockWidgetPluginGui("GuiDumpClipboardImporter", widgetInfo)
dock.Title = "GUI Clipboard Importer"
-- Show UI by default
dock.Enabled = true

-- UI setup
local frame = Instance.new("Frame", dock)
frame.Size                   = UDim2.new(1, -8, 1, -34)
frame.Position               = UDim2.new(0, 4, 0, 30)
frame.BackgroundTransparency = 1

local infoLabel = Instance.new("TextLabel", frame)
infoLabel.Size                   = UDim2.new(1, 0, 0, 30)
infoLabel.Position               = UDim2.new(0, 0, 0, 0)
infoLabel.Text                   = "Paste GuiDump output here, then click Import."
infoLabel.TextWrapped            = true
infoLabel.BackgroundTransparency = 1
infoLabel.TextXAlignment         = Enum.TextXAlignment.Left
infoLabel.TextYAlignment         = Enum.TextYAlignment.Top

local dumpBox = Instance.new("TextBox", frame)
dumpBox.Size             = UDim2.new(1, 0, 1, -60)
dumpBox.Position         = UDim2.new(0, 0, 0, 35)
dumpBox.ClearTextOnFocus = false
dumpBox.MultiLine        = true
dumpBox.PlaceholderText  = "Paste dump here…"
dumpBox.Font             = Enum.Font.Code
dumpBox.TextSize         = 14
dumpBox.TextXAlignment   = Enum.TextXAlignment.Left
dumpBox.TextYAlignment   = Enum.TextYAlignment.Top

local importBtnGUI = Instance.new("TextButton", frame)
importBtnGUI.Text            = "Import"
importBtnGUI.Size            = UDim2.new(1, 0, 0, 30)
importBtnGUI.Position        = UDim2.new(0, 0, 1, -30)
importBtnGUI.AutoButtonColor = true

-- Property mappings
local propTypeMap = {
    -- Spatial
    AbsolutePosition="Vector2", AbsoluteSize="Vector2",
    AnchorPoint="Vector2", SizeOffset="Vector2",
    ExtentsOffset="Vector2", ExtentsOffsetWorldSpace="Vector2",
    CanvasPosition="Vector2", CanvasSize="Vector2",
    StudsOffset="Vector3", StudsOffsetWorldSpace="Vector3",
    -- Layout
    Position="UDim2", Size="UDim2",
    CellSize="UDim2", CellPadding="UDim2", Padding="UDim", CornerRadius="UDim",
    -- Color
    BackgroundColor3="Color3", BorderColor3="Color3", ImageColor3="Color3",
    TextColor3="Color3", TextStrokeColor3="Color3", GroupColor3="Color3", Color="Color3"
}

-- Parsers
local function parseVector2(s)
    local x,y = s:match("%s*([%d%.%-]+)%s*,%s*([%d%.%-]+)%s*")
    return x and y and Vector2.new(tonumber(x), tonumber(y))
end

local function parseVector3(s)
    local x,y,z = s:match("%s*([%d%.%-]+)%s*,%s*([%d%.%-]+)%s*,%s*([%d%.%-]+)%s*")
    return x and y and z and Vector3.new(tonumber(x), tonumber(y), tonumber(z))
end

local function parseUDim(s)
    local scale, offset = s:match("{?%s*([%d%.%-]+)%s*,%s*([%d%.%-]+)%s*}?")
    return scale and offset and UDim.new(tonumber(scale), tonumber(offset))
end

local function parseUDim2(s)
    local sx, ox, sy, oy = s:match("{?%s*([%d%.%-]+)%s*,%s*([%d%.%-]+)%s*}?,%s*{?%s*([%d%.%-]+)%s*,%s*([%d%.%-]+)%s*}?")
    return sx and ox and sy and oy and UDim2.new(tonumber(sx), tonumber(ox), tonumber(sy), tonumber(oy))
end

local function parseColor3(s)
    local r,g,b = s:match("%s*([%d%.%-]+)%s*,%s*([%d%.%-]+)%s*,%s*([%d%.%-]+)%s*")
    return r and g and b and Color3.new(tonumber(r), tonumber(g), tonumber(b))
end

local function safeSet(inst, prop, val)
    local ok, err = pcall(function() inst[prop] = val end)
    if not ok then
        warn(('[GUI Import] Skipping %s.%s = %s (%s)'):format(
            inst.ClassName, prop, tostring(val), err:gsub("\n.*","")))
    end
end

-- Main dump parser
local function parseDump(text)
    local root, stack = {}, {}
    local function indentLevel(s) return #(s:match('^(%s*)') or '') end
    for _, line in ipairs(text:split("\n")) do
        local lvl = indentLevel(line)
        local cls, name = line:match('%[(%w+)%]%s*"(.-)"')
        if cls and name then
            local okNew, inst = pcall(Instance.new, cls)
            if okNew and inst then
                inst.Name = name
                while #stack>0 and stack[#stack].lvl>=lvl do table.remove(stack) end
                if #stack==0 then table.insert(root, inst)
                else inst.Parent = stack[#stack].inst end
                table.insert(stack, {lvl=lvl, inst=inst})
            else
                warn(('[GUI Import] Skipping unknown class %q'):format(cls))
                while #stack>0 and stack[#stack].lvl>=lvl do table.remove(stack) end
                table.insert(stack, {lvl=lvl, inst=nil})
            end
        else
            local prop, val = line:match('•%s*(%w+)%s*=%s*(.+)$')
            if prop and val and #stack>0 then
                local inst = stack[#stack].inst
                if inst then
                    -- Handle FontFace specially
                    if prop=="FontFace" then
                        local family, w, sty = val:match("Font%s*{%s*Family%s*=%s*([^,]+),%s*Weight%s*=%s*(%w+),%s*Style%s*=%s*(%w+)")
                        if family and w and sty then
                            local weightEnum = Enum.FontWeight[w]
                            local styleEnum  = Enum.FontStyle[sty]
                            if weightEnum and styleEnum then
                                local fobj = Font.new(family, weightEnum, styleEnum)
                                safeSet(inst, prop, fobj)
                            end
                        end
                    else
                        -- Generic handling
                        local t = propTypeMap[prop]
                        if t=="Vector2" then
                            local v2 = parseVector2(val); if v2 then safeSet(inst,prop,v2) end
                        elseif t=="Vector3" then
                            local v3 = parseVector3(val); if v3 then safeSet(inst,prop,v3) end
                        elseif t=="UDim2" then
                            local u2 = parseUDim2(val); if u2 then safeSet(inst,prop,u2) end
                        elseif t=="UDim" then
                            local u  = parseUDim(val); if u  then safeSet(inst,prop,u) end
                        elseif t=="Color3" then
                            local c3 = parseColor3(val); if c3 then safeSet(inst,prop,c3) end
                        else
                            if val=="true" or val=="false" then safeSet(inst,prop,val=="true")
                            elseif tonumber(val) then safeSet(inst,prop,tonumber(val))
                            elseif val:match("^Enum") then
                                local fn=loadstring("return "..val)
                                if fn then local ok2,ev=pcall(fn); if ok2 then safeSet(inst,prop,ev) end end
                            else safeSet(inst,prop,val) end
                        end
                    end
                end
            end
        end
    end
    return root
end

-- Toolbar button toggles UI
importBtn.Click:Connect(function()
    dock.Enabled = not dock.Enabled
    if dock.Enabled then dumpBox:CaptureFocus() end
end)

-- Import action
importBtnGUI.MouseButton1Click:Connect(function()
    local txt = dumpBox.Text or ""
    if #txt<10 then warn('[GUI Import] dump is too short') return end
    local ok, res = pcall(parseDump, txt)
    if not ok then warn('[GUI Import] parse error',res); return end
    for _,sg in ipairs(res) do sg.Parent = game:GetService('StarterGui') end
    warn(('[GUI Import] Imported %d ScreenGui(s)'):format(#res))
    dock.Enabled=false
end)

-- Auto-focus
spawn(function() wait(0.1); dumpBox:CaptureFocus() end)
