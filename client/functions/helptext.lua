local currentHelptext, currentCoords, width, height
local fontSize = 0.35

CreateThread(function()
    function functions.HideHelpText()
        if currentHelptext then 
            if Config.HelpTextStyle == "luke" then
                TriggerEvent("luke_textui:HideUI")
            elseif Config.HelpTextStyle == "cd" then
                TriggerEvent("cd_drawtextui:HideUI")
            end
        end

        currentHelptext = nil
    end

    function functions.DrawHelpText(text, coords, key)
        functions.HideHelpText()
        if key then
            if Config.HelpTextStyle == "gta" or Config.HelpTextStyle == "3d-gta" then
                text = functions.GetInstructional(key) .. " " .. text
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
        end
    end

    if Config.HelpTextStyle == "gta" or Config.HelpTextStyle == "3d-gta" or Config.HelpTextStyle == "3d" then
        if Config.HelpTextStyle == "3d" and Config.UseExperimental3D then
            CreateThread(function()
                while true do
                    Wait(250)

                    while currentHelptext do
                        Wait(10)
                        local fov = GetGameplayCamFov()
                        local camCoords = GetFinalRenderedCamCoord()
                        local dist = #(camCoords - currentCoords)
                        local size = 1/(2 * math.abs(math.tan(math.rad(fov)/2)) * dist) / 0.35
                        fontSize = math.min(0.8, size)

                        BeginTextCommandGetWidth(GetCurrentResourceName())
                        SetTextScale(fontSize, fontSize)
                        SetTextFont(4)
                        width = EndTextCommandGetWidth(1) + 0.0015
                        height = GetRenderedCharacterHeight(fontSize, 4) * 1.5
                    end
                end
            end)
        end

        CreateThread(function()
            while true do
                Wait(250)

                if currentHelptext then
                    if Config.HelpTextStyle == "gta" then
                        AddTextEntry(GetCurrentResourceName(), currentHelptext)
                    elseif Config.HelpTextStyle == "3d-gta" then
                        local str = currentHelptext
                        local start, stop = string.find(currentHelptext, "~([^~]+)~")
                        if start and start > 1 then
                            start = start - 2
                            stop = stop + 2
                            str = ""
                            str = str .. string.sub(currentHelptext, 0, start) .. string.rep(" ", 3) .. string.sub(currentHelptext, start+2, stop-2) .. string.sub(currentHelptext, stop, #currentHelptext)
                        end
                        AddTextEntry(GetCurrentResourceName(), str)
                    elseif Config.HelpTextStyle == "3d" then
                        AddTextEntry(GetCurrentResourceName(), currentHelptext)

                        BeginTextCommandGetWidth(GetCurrentResourceName())
                        SetTextScale(0.35, 0.35)
                        SetTextFont(4)
                        width = EndTextCommandGetWidth(1) + 0.0015
                        height = GetRenderedCharacterHeight(0.35, 4) * 1.5
                    end

                    while currentHelptext do
                        Wait(0)

                        if Config.HelpTextStyle == "gta" then
                            BeginTextCommandDisplayHelp(GetCurrentResourceName())
                            EndTextCommandDisplayHelp(0, 0, true, -1)
                        elseif Config.HelpTextStyle == "3d-gta" then
                            BeginTextCommandDisplayHelp(GetCurrentResourceName())
                            EndTextCommandDisplayHelp(2, false, false, -1)
        
                            SetFloatingHelpTextWorldPosition(1, currentCoords)
                            SetFloatingHelpTextStyle(1, 1, 2, -1, 3, 0)
                        elseif Config.HelpTextStyle == "3d" then
                            SetDrawOrigin(currentCoords)

                            BeginTextCommandDisplayText(GetCurrentResourceName())
                            SetTextScale(fontSize, fontSize)
                            SetTextCentre(1)
                            SetTextFont(4)
                            EndTextCommandDisplayText(0.0, 0.0)

                            DrawRect(0.0, height/(2.5), width, height, 45, 45, 45, 150)

                            ClearDrawOrigin()
                        end
                    end
                end
            end
        end)
    end
end)