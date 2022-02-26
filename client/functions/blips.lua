local blips = {}

function functions.AddBlip(blipData)
    local id = functions.GenerateUniqueKey(blips)

    local blip = AddBlipForCoord(blipData.coords or vector3(0.0, 0.0, 0.0))
    SetBlipSprite(blip, blipData.sprite or 1)
    SetBlipColour(blip, blipData.colour or blipData.color or 0)
    SetBlipScale(blip, blipData.scale or 0.7)
    SetBlipAsShortRange(blip, blipData.shortRange or true)
    SetBlipDisplay(blip, blipData.display or 2)
    if blipData.category then
        SetBlipCategory(blip, blipData.category)
    end
    
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(blipData.label or id)
    EndTextCommandSetBlipName(blip)

    blipData.creator = GetInvokingResource()
    blipData.blip = blip
    blips[id] = blipData

    return id
end

function functions.GetBlip(blipId)
    return blips[blipId]
end

function functions.RemoveBlip(blipId)
    if blips[blipId] then
        RemoveBlip(blips[blipId].blip)
        blips[blipId] = nil
    end
end

AddEventHandler("onResourceStop", function(resourceName)
    if resourceName ~= GetCurrentResourceName() then
        local blipsRemoved = 0
        for blipId, blipData in pairs(blips) do
            if blipData.creator == resourceName then
                functions.RemoveBlip(blipId)
                blipsRemoved += 1
            end
        end
        if blipsRemoved > 0 then
            print(string.format("Removed %i blip%s due to resource %s stopping.", blipsRemoved, blipsRemoved > 1 and "s" or "", resourceName))
        end
    end
end)