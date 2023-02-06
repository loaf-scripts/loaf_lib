function functions.LoadAnimDict(dict)
    if not DoesAnimDictExist(dict) then
        return { success=false, error="Anim dict " .. dict ..  " does not exist." }
    end

    local timer = GetGameTimer() + 5000

    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(0)
        if timer < GetGameTimer() then
            return { success=false, error="Loading anim dict timed out." }
        end
    end

    return { success=true, dict=dict }
end

function functions.LoadModel(model)
    model = type(model) == "string" and GetHashKey(model) or model

    if not IsModelInCdimage(model) then
        return { success=false, error="Model " .. model .. " does not exist (not in cd image)." }
    end

    local timer = GetGameTimer() + 5000

    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(0)
        if timer < GetGameTimer() then
            return { success=false, error="Loading model timed out." }
        end
    end

    return { success=true, model=model }
end

function functions.CopyText(text)
    if not text or type(text) ~= "string" then
        return { success=false, error="No text to copy was specified." }
    end

    SendNUIMessage({
        type = "copy_text",
        content = text
    })
    return { success=true }
end

---@diagnostic disable-next-line: duplicate-set-field
function functions.GenerateString(length)
    local id = ""
    for _ = 1, length or 7 do
        local char = math.random(1, 2) == 1 and string.char(math.random(97, 122)) or tostring(math.random(0, 9))
        if math.random(1, 2) == 1 then
            char = string.upper(char)
        end
        id = id .. char
    end
    return id
end

---@diagnostic disable-next-line: duplicate-set-field
function functions.GenerateUniqueKey(t, length)
    local id = functions.GenerateString(length)

    if not t[id] then
        return id
    else
        return functions.GenerateUniqueKey(t, length)
    end
end