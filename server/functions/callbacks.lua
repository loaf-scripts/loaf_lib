local callbacks = {}

function functions.RegisterCallback(callback, cb)
    callbacks[callback] = cb
end

RegisterNetEvent("loaf_lib:trigger_callback")
AddEventHandler("loaf_lib:trigger_callback", function(callback, requestId, ...)
    local src = source
    if callbacks[callback] then
        callbacks[callback](src, function(...)
            TriggerClientEvent("loaf_lib:callback_result", src, requestId, ...)
        end, ...)
    end
end)