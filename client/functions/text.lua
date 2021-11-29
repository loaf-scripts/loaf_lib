--[[
    textEntry = texts[textId].textEntry,
    font = texts[textId].font,
    wrap = texts[textId].wrap,
    size = texts[textId].size
]]
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

local texts = {}

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
        AddTextEntry(textId, textData.text)
    end
    -- texts[textId].text, texts[textId].size, texts[textId].font, wrap
    texts[textId].textSize = functions.GetTextSize({
        textEntry = texts[textId].textEntry,
        text = texts[textId].text,
        font = texts[textId].font,
        wrap = texts[textId].wrap,
        size = texts[textId].size
    })
    return textId
end

-- REMOVE MARKER
function functions.Remove3DText(textId)
    if texts[textId] then 
        texts[textId] = nil
        return true
    end
    return false
end

-- HANDLE 3D TEXTS
CreateThread(function()
    local nearbyTexts = {}

    -- THREAD THAT HANDLES NEARBY 3D TEXTS
    CreateThread(function()
        -- maybe a grid system would be better ¯\_(ツ)_/¯
        while true do
            Wait(2500)
            local startTime = GetGameTimer()

            local newNearby = {}
            local selfCoords = GetEntityCoords(PlayerPedId())
            for textId, textData in pairs(texts) do
                if textData and #(selfCoords - textData.coords) <= 150.0 then
                    table.insert(newNearby, textId)
                end
                Wait(5) -- wait increases performance quite a bit, no wait = a lot of cpu usage BUT really fast
            end

            nearbyTexts = newNearby
            collectgarbage()
        end
    end)

    -- THREAD THAT HANDLES TEXT DISTANCE
    CreateThread(function()
        while true do
            Wait(2500)
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

    -- THREAD THAT HANDLES THE DRAWING OF MARKERS
    while true do
        Wait(2500)
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
                        SetTextWrap(0.0, text.wrap) -- TESTING
                        SetTextCentre(1)
                        SetTextFont(4)
                        EndTextCommandDisplayText(0.0, 0.0)

                        DrawRect(0.0, text.textSize.y/2, math.min(text.wrap + 0.0015, text.textSize.x), text.textSize.y, 45, 45, 45, 150)

                        ClearDrawOrigin()
                    end
                end
            end
        end
        insideMarkers = {}
    end
end)

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        local textsRemoved = 0
        for textId, textData in pairs(texts) do
            if textData.creator == resourceName then
                functions.Remove3DText(markerId)
                textsRemoved = textsRemoved + 1
            end
        end
        if textsRemoved > 0 then
            print(string.format("Removed %i 3d text%s due to resource %s stopping.", textsRemoved, textsRemoved > 1 and "s" or "", resourceName))
        end
    end
end)