functions.LoadAnimDict = function(dict)
    if DoesAnimDictExist(dict) then
        local timer = GetGameTimer() + 20000

        RequestAnimDict(dict)
        while not HasAnimDictLoaded(dict) do 
            Wait(50)
            if timer < GetGameTimer() then
                return {success=false, error="Loading anim dict timed out."}
            end
        end

        return {success=true, dict=dict}
    end
    return {success=false, error="Anim dict " .. dict ..  " does not exist."}
end

functions.LoadModel = function(model)
    model = type(model) == "string" and GetHashKey(model) or model

    if IsModelInCdimage(model) then
        local timer = GetGameTimer() + 20000

        RequestModel(model)
        while not HasModelLoaded(model) do 
            Wait(50)
            if timer < GetGameTimer() then
                return {success=false, error="Loading model timed out."}
            end
        end

        return {success=true, model=model}
    end
    return {success=false, error="Model " .. model .. " does not exist (not in cd image)."}
end

functions.CopyText = function(text)
    if text and type(text) == "string" then
        SendNUIMessage({
            type = "copy_text",
            content = text
        })
        return {success=true}
    end
    return {success=false, error="No text to copy was specified."}
end