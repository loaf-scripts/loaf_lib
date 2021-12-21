local waitingCallbacks = {}

function functions.TriggerCallback(callback, cb, ...)
    local requestId = functions.GenerateUniqueKey(waitingCallbacks)
    waitingCallbacks[requestId] = cb
    TriggerServerEvent("loaf_lib:trigger_callback", callback, requestId, ...)
end
functions.TriggerCallbackAsync = functions.TriggerCallback

function functions.TriggerCallbackSync(callback, ...)
    local requestId = functions.GenerateUniqueKey(waitingCallbacks)
    local toreturn

    waitingCallbacks[requestId] = function(...)
        toreturn = {...}
    end
    TriggerServerEvent("loaf_lib:trigger_callback", callback, requestId, ...)

    while not toreturn do
        Wait(0)
    end

    return table.unpack(toreturn)
end

RegisterNetEvent("loaf_lib:callback_result")
AddEventHandler("loaf_lib:callback_result", function(requestId, ...)
    if waitingCallbacks[requestId] then 
        waitingCallbacks[requestId](...)
        waitingCallbacks[requestId] = nil
    end
end)