-- ENUMERATE ENTITIES
local pools = {
    object = "CObject",
    ped = "CPed",
    vehicle = "CVehicle"
}

function functions.GetEntities(entities)
    if type(entities) ~= "table" then
        entities = {entities}
    end

    for _, eType in pairs(entities) do
        if not pools[eType] then
            return { success=false, error="Can't enumerate entity \""..eType.."\"" }
        end
    end

    local toReturn = {}
    for _, eType in pairs(entities) do
        toReturn[type] = GetGamePool(pools[eType])
    end

    return { success=true, entities=toReturn }
end
