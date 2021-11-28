-- ENUMERATE ENTITIES
local enumNatives = {
    object   = {FindFirstObject,  FindNextObject,  EndFindObject },
    ped      = {FindFirstPed,     FindNextPed,     EndFindPed    },
    vehicle  = {FindFirstVehicle, FindNextVehicle, EndFindVehicle}
}

local cachedEntities = {}

function functions.GetEntities(entities)
    if type(entities) ~= "table" then
        entities = {entities}
    end

    for _, type in pairs(entities) do
        if not enumNatives[type] then
            return {success=false, error="Can't enumerate entity \""..type.."\""}
        end
    end

    for _, type in pairs(entities) do
        if not cachedEntities[type] or (GetGameTimer() - cachedEntities[type].runAt) > 5000 then
            local foundEntities = {}
            local enumFuncs = enumNatives[type]
            local handle, entity, success = enumFuncs[1]()
            if DoesEntityExist(entity) then
                table.insert(foundEntities, entity)
            end
        
            repeat
                success, entity = enumFuncs[2](handle)
                if DoesEntityExist(entity) then
                    table.insert(foundEntities, entity)
                end
            until(not success)
        
            enumFuncs[3](handle)
            cachedEntities[type] = {
                entities = foundEntities,
                runAt = GetGameTimer()
            }
        end
    end

    local toReturn = {}
    for _, type in pairs(entities) do
        toReturn[type] = cachedEntities[type].entities
    end
    return {success=true, entities=toReturn}
end