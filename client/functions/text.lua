local texts, amountTexts = {}, 0
local nearbyTexts = {}

function functions.GetTextSize(textData)
    if type(textData) ~= "table" then return vector2(0.0, 0.0) end
    
    if textData.text then
        BeginTextCommandGetWidth("STRING")
        AddTextComponentSubstringPlayerName(textData.text)
    else
        BeginTextCommandGetWidth(textData.textEntry)
    end
    SetTextScale(textData.size or 0.35, textData.size or 0.35)
    SetTextFont(4)
    local textWidth = EndTextCommandGetWidth(1)
    local width = textWidth + 0.0015

    local newlines = 0
    if textData.text then
        local _, count = string.gsub(textData.text, "\n", "")
        newlines = newlines + count
        _, count = string.gsub(textData.text, "~n~", "")
        newlines = newlines + count
    end

    local lines = math.ceil(textWidth/(textData.wrap or 1.0)) + newlines

    local characterHeight = GetRenderedCharacterHeight(textData.size or 0.35, textData.font or 4)
    local height = characterHeight * lines + characterHeight * 0.3

    return vector2(width, height)
end

-- ADD MARKER
function functions.Add3DText(textData)    
    local textId = functions.GenerateUniqueKey(texts)
    
    texts[textId] = {
        coords = textData.coords or vector3(0.0, 0.0, 0.0),
        text = textData.text or "No text set.",
        size = textData.size or 0.35,
        initialSize = textData.size or 0.35, -- used for distanceScale calculation
        wrap = textData.wrap or 1.0,
        font = textData.font or 4,
        distanceScale = textData.distanceScale == true,
        viewDistance = textData.viewDistance or 5.0,
        textEntry = textData.textEntry or textId,
        creator = GetInvokingResource()
    }

    if not textData.textEntry then
        AddTextEntry(textId, texts[textId].text)
    end

    texts[textId].textSize = functions.GetTextSize({
        textEntry = texts[textId].textEntry,
        text = texts[textId].text,
        font = texts[textId].font,
        wrap = texts[textId].wrap,
        size = texts[textId].size
    })

    amountTexts += 1
    return textId
end

-- REMOVE MARKER
function functions.Remove3DText(textId)
    if texts[textId] then 
        texts[textId] = nil
        amountTexts -= 1
        return true
    end
    return false
end

-- check for nearby 3d texts
CreateThread(function()
    local lastCoords, lastAmount = vector3(0.0, 0.0, 0.0), 0

    while true do
        Wait(500)
        local selfCoords = GetEntityCoords(PlayerPedId())

        if #(lastCoords - selfCoords) > 5.0 or lastAmount ~= amountTexts then
            lastCoords = selfCoords
            lastAmount = amountTexts

            local newNearby = {}
            for textId, textData in pairs(texts) do
                if textData and #(selfCoords - textData.coords) <= (Config.DrawDistance or 150.0) then
                    newNearby[#newNearby + 1] = textId
                end
                Wait(0)
            end
            
            nearbyTexts = newNearby
        end
    end
end)

CreateThread(function()
    if not Config.Distancescale3DText then
        return
    end

    while true do
        Wait(500)

        while #nearbyTexts > 0 do
            Wait(25)
            local selfCoords = GetEntityCoords(PlayerPedId())
            for _, textId in pairs(nearbyTexts) do
                if texts[textId] then
                    local text = texts[textId]
                    if text.distanceScale and #(selfCoords - text.coords) <= text.viewDistance then
                        -- calculate font size
                        local fov = GetGameplayCamFov()
                        local camCoords = GetFinalRenderedCamCoord()
                        local dist = #(camCoords - text.coords)
                        local size = 1/(2 * math.abs(math.tan(math.rad(fov)/2)) * dist) / text.initialSize
                        
                        text.size = math.min(0.8, size)

                        text.textSize = functions.GetTextSize({
                            textEntry = text.textEntry,
                            text = text.text,
                            font = text.font,
                            wrap = text.wrap,
                            size = text.size
                        })
                    end
                end
            end
        end
    end
end)

-- HANDLE 3D TEXTS
CreateThread(function()
    while true do
        Wait(500)

        while #nearbyTexts > 0 do
            Wait(0)
            local selfCoords = GetEntityCoords(PlayerPedId())
            for _, textId in pairs(nearbyTexts) do
                if texts[textId] then
                    local text = texts[textId]
                    if #(selfCoords - text.coords) <= text.viewDistance then
                        SetDrawOrigin(text.coords)

                        BeginTextCommandDisplayText(text.textEntry)
                        SetTextScale(text.size, text.size)
                        SetTextWrap(0.0, text.wrap)
                        SetTextCentre(1)
                        SetTextFont(4)
                        EndTextCommandDisplayText(0.0, 0.0)

                        DrawRect(0.0, text.textSize.y/2, math.min(text.wrap + 0.0015, text.textSize.x), text.textSize.y, 45, 45, 45, 150)

                        ClearDrawOrigin()
                    end
                end
            end
        end
    end
end)

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        local textsRemoved = 0
        for textId, textData in pairs(texts) do
            if textData.creator == resourceName then
                functions.Remove3DText(markerId)
                textsRemoved += 1
            end
        end
        if textsRemoved > 0 then
            print(string.format("Removed %i 3d text%s due to resource %s stopping.", textsRemoved, textsRemoved > 1 and "s" or "", resourceName))
        end
    end
end)