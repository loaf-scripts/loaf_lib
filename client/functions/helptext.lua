local currentHelptext, currentCoords, width, height
local fontSize = 0.35
local wrap = 0.2

local textEntry = GetCurrentResourceName() .. "_helptext"

function functions.HideHelpText()
    if currentHelptext then 
        if Config.HelpTextStyle == "luke" then
            TriggerEvent("luke_textui:HideUI")
        elseif Config.HelpTextStyle == "cd" then
            TriggerEvent("cd_drawtextui:HideUI")
        elseif Config.HelpTextStyle == "esx" then
            TriggerEvent("ESX:HideUI")
        elseif Config.HelpTextStyle == "qbcore" then
            TriggerEvent("qb-core:client:HideText")
        elseif Config.HelpTextStyle == "gta" then
            ClearAllHelpMessages()
            ClearHelp(true)
        end
    end

    currentHelptext = nil
end

function functions.DrawHelpText(text, coords, key)
    functions.HideHelpText()
    if key then
        if Config.HelpTextStyle == "gta" or Config.HelpTextStyle == "3d-gta" then
            text = functions.GetInstructional(key) .. " " .. text
        elseif Config.HelpTextStyle == "3d" then
            text = string.format("~b~[~s~%s~b~]~s~ %s", string.gsub(GetControlInstructionalButton(0, functions.GetKey(key).joaat, 1), "t_", ""), text)
        else
            text = string.format("[%s] %s", string.gsub(GetControlInstructionalButton(0, functions.GetKey(key).joaat, 1), "t_", ""), text)
        end
    end
    currentHelptext = text
    currentCoords = coords

    if Config.HelpTextStyle == "luke" then
        TriggerEvent("luke_textui:ShowUI", currentHelptext)
    elseif Config.HelpTextStyle == "cd" then
        TriggerEvent("cd_drawtextui:ShowUI", "show", currentHelptext)
    elseif Config.HelpTextStyle == "esx" then
        TriggerEvent("ESX:TextUI", currentHelptext)
    elseif Config.HelpTextStyle == "qbcore" then
        TriggerEvent("qb-core:client:DrawText", currentHelptext)
    elseif Config.HelpTextStyle == "gta" then
        AddTextEntry(textEntry, currentHelptext)
        BeginTextCommandDisplayHelp(textEntry)
        EndTextCommandDisplayHelp(0, true, true, 0)
    end
end

-- 3D helptext
CreateThread(function()
    if not (Config.HelpTextStyle == "3d" and Config.Distancescale3DText) then
        return
    end

    local startFontSize = fontSize
    while true do
        Wait(250)

        while currentHelptext do
            -- calculate font size
            local fov = GetGameplayCamFov()
            local camCoords = GetFinalRenderedCamCoord()
            local dist = #(camCoords - currentCoords)
            local size = 1/(2 * math.abs(math.tan(math.rad(fov)/2)) * dist) / startFontSize
            fontSize = math.min(0.8, size)

            local textSize = functions.GetTextSize({
                text = currentHelptext,
                size = fontSize,
                font = 4,
                wrap = wrap
            })
            width = textSize.x
            height = textSize.y

            Wait(10)
        end
    end
end)

CreateThread(function()
    if Config.HelpTextStyle ~= "3d-gta" and Config.HelpTextStyle ~= "3d" then
        return
    end

    while true do
        Wait(250)

        if currentHelptext then
            if Config.HelpTextStyle == "3d-gta" then
                local str = currentHelptext
                local start, stop = string.find(currentHelptext, "~([^~]+)~")
                if start and start > 1 then
                    start = start - 2
                    stop = stop + 2
                    str = ""
                    str = str .. string.sub(currentHelptext, 0, start) .. string.rep(" ", 3) .. string.sub(currentHelptext, start+2, stop-2) .. string.sub(currentHelptext, stop, #currentHelptext)
                end
                AddTextEntry(textEntry, str)
            elseif Config.HelpTextStyle == "3d" then
                AddTextEntry(textEntry, currentHelptext)

                local textSize = functions.GetTextSize({
                    text = currentHelptext,
                    size = fontSize,
                    font = 4,
                    wrap = wrap
                })
                width = textSize.x
                height = textSize.y
            end

            while currentHelptext do
                Wait(0)

                if Config.HelpTextStyle == "3d-gta" then
                    BeginTextCommandDisplayHelp(textEntry)
                    EndTextCommandDisplayHelp(2, false, false, -1)

                    SetFloatingHelpTextWorldPosition(1, currentCoords)
                    SetFloatingHelpTextStyle(1, 1, 2, -1, 3, 0)
                elseif Config.HelpTextStyle == "3d" then
                    SetDrawOrigin(currentCoords)

                    BeginTextCommandDisplayText(textEntry)
                    SetTextScale(fontSize, fontSize)
                    SetTextWrap(0.0, wrap) -- TESTING
                    SetTextCentre(1)
                    SetTextFont(4)
                    EndTextCommandDisplayText(0.0, 0.0)

                    DrawRect(0.0, height/2, math.min(wrap + 0.0015, width), height, 45, 45, 45, 150)

                    ClearDrawOrigin()
                end
            end
        end
    end
end)