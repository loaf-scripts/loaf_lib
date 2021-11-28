function functions.LoadAnimDict(dict)
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

function functions.LoadModel(model)
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

function functions.CopyText(text)
    if text and type(text) == "string" then
        SendNUIMessage({
            type = "copy_text",
            content = text
        })
        return {success=true}
    end
    return {success=false, error="No text to copy was specified."}
end


function functions.GenerateString(length)
    local id = ""
    for i = 1, length or 15 do
        id = id .. (math.random(1, 2) == 1 and string.char(math.random(97, 122)) or tostring(math.random(0,9)))
    end
    return id
end

function functions.GenerateUniqueKey(t, length)
    local id = functions.GenerateString(length)

    if not t[id] then
        return id
    else
        return functions.GenerateUniqueKey(t, length)
    end
end