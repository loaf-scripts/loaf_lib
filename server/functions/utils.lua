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