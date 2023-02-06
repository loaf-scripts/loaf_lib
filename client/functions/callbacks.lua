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

    local promise = promise.new()
    waitingCallbacks[requestId] = function(...)
        toreturn = { ... }
        promise:resolve()
    end
    TriggerServerEvent("loaf_lib:trigger_callback", callback, requestId, ...)
    Citizen.Await(promise)

    return table.unpack(toreturn)
end

RegisterNetEvent("loaf_lib:callback_result", function(requestId, ...)
    if waitingCallbacks[requestId] then
        waitingCallbacks[requestId](...)
        waitingCallbacks[requestId] = nil
    end
end)