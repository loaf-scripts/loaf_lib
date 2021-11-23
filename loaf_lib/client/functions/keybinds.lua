-- https://forum.cfx.re/t/create-get-key-mapping/2260585/2
-- http://tools.povers.fr/hashgenerator/
local keysPressed = {}
local registeredKeys = {}
local keysReleased = {}

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
            default = keyData.defaultKey
        }

        -- ON KEY PRESS
        RegisterCommand("+" .. command, function()
            keysPressed[name] = true -- SET PRESSED
        end)
        -- ON KEY RELEASE
        RegisterCommand("-" .. command, function()
            keysPressed[name] = false -- NO LONGER PRESSED
            
            keysReleased[name] = true -- SET JUST RELEASED
            Wait(1) -- WAIT 1 FRAME
            keysReleased[name] = false -- NO LONGER JUST RELEASED
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
    return keysPressed[name] == true
end

functions.IsKeyJustReleased = function(name)
    return keysReleased[name] == true
end

for name, keyData in pairs(Config.Keybindings) do
    functions.AddKey(name, keyData)
end