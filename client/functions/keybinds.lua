-- https://forum.cfx.re/t/create-get-key-mapping/2260585/2
-- http://tools.povers.fr/hashgenerator/
local registeredKeys = {}

functions.AddKey = function(name, keyData)
    name = string.lower(name)
    if not registeredKeys[name] then
        local command = string.format("use_%s_key", name)

        local hash = GetHashKey("+" .. command)
        local hex = string.upper(string.format("%x", hash))
        if hash < 0 then
            hex = string.gsub(hex, string.rep("F", 8), "")
        end
        registeredKeys[name] = {
            command = command,
            instructional = "~INPUT_"..hex.."~",
            default = keyData.defaultKey,
            status = {
                pressed = false,
                justReleased = false
            }
        }

        -- ON KEY PRESS
        RegisterCommand("+" .. command, function()
            registeredKeys[name].status.pressed = true -- SET PRESSED
        end)
        -- ON KEY RELEASE
        RegisterCommand("-" .. command, function()
            registeredKeys[name].status.pressed = false -- NO LONGER PRESSED
            
            registeredKeys[name].status.justReleased = true -- SET JUST RELEASED
            Wait(1) -- WAIT 1 FRAME
            registeredKeys[name].status.justReleased = false -- NO LONGER JUST RELEASED
        end, false)
        RegisterKeyMapping("+" .. command, keyData.description, "keyboard", keyData.defaultKey)
        return true
    else
        return false
    end
end

functions.GetKey = function(name)
    return registeredKeys[name]
end

functions.GetInstructional = function(name)
    if registeredKeys[name] then
        return registeredKeys[name].instructional
    else
        return "~r~KEY NOT FOUND~s~"
    end
end

functions.IsKeyPressed = function(name)
    return registeredKeys[name].status.pressed == true
end

functions.IsKeyJustReleased = function(name)
    return registeredKeys[name].status.justReleased == true
end

for name, keyData in pairs(Config.Keybindings) do
    functions.AddKey(name, keyData)
end