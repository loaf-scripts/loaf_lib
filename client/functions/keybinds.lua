-- https://forum.cfx.re/t/create-get-key-mapping/2260585/2
-- http://tools.povers.fr/hashgenerator/
-- https://discord.com/channels/192358910387159041/433008322732490778/849605181589946379
local registeredKeys = {}

function functions.AddKey(name, keyData)
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
            joaat = hash | 0x80000000,
            joaat_hex = hex,
            default = keyData.defaultKey,
            status = {
                pressed = false,
                justReleased = false
            }
        }

        -- ON KEY PRESS
        RegisterCommand("+" .. command, function()
            registeredKeys[name].status.pressed = true -- SET PRESSED
            TriggerEvent("loaf_lib:pressedKey", name)
        end)
        -- ON KEY RELEASE
        RegisterCommand("-" .. command, function()
            TriggerEvent("loaf_lib:releasedKey", name)
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

function functions.GetKey(name)
    return registeredKeys[name]
end

function functions.GetInstructional(name)
    if registeredKeys[name] then
        return registeredKeys[name].instructional
    else
        return "~r~KEY NOT FOUND~s~"
    end
end

function functions.IsKeyPressed(name)
    return registeredKeys[name].status.pressed == true
end

function functions.IsKeyJustReleased(name)
    return registeredKeys[name].status.justReleased == true
end

for name, keyData in pairs(Config.Keybindings) do
    functions.AddKey(name, keyData)
end