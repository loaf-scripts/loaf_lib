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