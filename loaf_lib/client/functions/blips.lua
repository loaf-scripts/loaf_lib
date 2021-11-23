local blips = {}

local function GenerateBlipId()
    local id = ""
    for i = 1, 15 do
        id = id .. (math.random(1, 2) == 1 and string.char(math.random(97, 122)) or tostring(math.random(0,9)))
    end

    if not blips[id] then
        return id
    else
        return GenerateBlipId()
    end
end

functions.AddBlip = function(blipData)
    local id = GenerateBlipId()

    local blip = AddBlipForCoord(blipData.coords or vector3(0.0, 0.0, 0.0))
    SetBlipSprite(blip, blipData.sprite or 1)
    SetBlipColour(blip, blipData.colour or blipData.color or 0)
    SetBlipScale(blip, blipData.scale or 0.7)
    SetBlipAsShortRange(blip, blipData.shortRange or true)
    SetBlipDisplay(blip, blipData.display or 2)
    
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(blipData.label or id)
    EndTextCommandSetBlipName(blip)

    blipData.creator = GetInvokingResource()
    blipData.blip = blip
    blips[id] = blipData

    return id
end

functions.RemoveBlip = function(blipId)
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
                blipsRemoved = blipsRemoved + 1
            end
        end
        if blipsRemoved > 0 then
            print(string.format("Removed %i blip%s due to resource %s stopping.", blipsRemoved, blipsRemoved > 1 and "s" or "", resourceName))
        end
    end
end)