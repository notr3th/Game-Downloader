local Studio = game:GetService("StudioService")
local Toolbar = plugin:CreateToolbar("GUI Stealer")
local ImportButton = Toolbar:CreateButton("Import", "", "rbxassetid://114445161415517")

local propTypeMap = {
    AbsolutePosition="Vector2",AbsoluteSize="Vector2",
    AnchorPoint="Vector2",SizeOffset="Vector2",
    ExtentsOffset="Vector2",ExtentsOffsetWorldSpace="Vector2",
    CanvasPosition="Vector2",CanvasSize="Vector2",
    StudsOffset="Vector3",StudsOffsetWorldSpace="Vector3",
    Position="UDim2",Size="UDim2",CellSize="UDim2",
    CellPadding="UDim2",Padding="UDim", CornerRadius="UDim",
    BackgroundColor3="Color3",BorderColor3="Color3",
    ImageColor3="Color3",TextColor3="Color3",TextStrokeColor3="Color3",
    GroupColor3="Color3",Color="Color3"
}

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
        warn(('[GUI Stealer]: Skipping %s.%s = %s (%s)'):format(inst.ClassName, prop, tostring(val), err:gsub("\n.*","")))
    end
end

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
                warn(('[GUI Stealer]: Skipping unknown class %q'):format(cls))
                while #stack>0 and stack[#stack].lvl>=lvl do table.remove(stack) end
                table.insert(stack, {lvl=lvl, inst=nil})
            end
        else
            local prop, val = line:match('•%s*(%w+)%s*=%s*(.+)$')
            if prop and val and #stack>0 then
                local inst = stack[#stack].inst
                if inst then
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

ImportButton.Click:Connect(function()
    local file = Studio:PromptImportFile({"txt","lua"})
    if not file then
        warn('[GUI Stealer]: No file selected or file too large')
        return
    end
    local txt = file:GetBinaryContents()
    if #txt < 10 then
        warn('[GUI Import] dump is too short')
        return
    end
    local ok, res = pcall(parseDump, txt)
    if not ok then
        warn('[GUI Stealer]: parse error ' .. tostring(res))
        return
    end
    for _, sg in ipairs(res) do
        sg.Parent = game:GetService("StarterGui")
    end
    warn('[GUI Stealer]: Imported ' .. #res .. ' ScreenGui(s)')
end)
