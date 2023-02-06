ServerConfig = {}
ServerConfig.Logs = {
    ["default"] = "https://discord.com/api/webhooks/",
}
ServerConfig.ErrorTypes = {
    error = {
        colour = 16739179,
        image = "https://icons.iconarchive.com/icons/paomedia/small-n-flat/1024/sign-error-icon.png",
        label = "Error"
    },
    warning = {
        colour = 16766566,
        image = "https://cdn-icons-png.flaticon.com/512/194/194330.png",
        label = "Warning"
    },
    success = {
        colour = 6750115,
        image = "https://cdn-icons-png.flaticon.com/512/148/148767.png",
        label = "Success"
    },
    info = {
        colour = 6928383,
        image = "https://image.flaticon.com/icons/png/512/189/189664.png",
        label = "Information"
    },
}

--- VERSION CHECK ---
CreateThread(function()
    PerformHttpRequest("https://loaf-scripts.com/versions/", function(_, text, _)
        if text then
            print(text)
        end
    end, "POST", json.encode({
        resource = "lib",
        version = GetResourceMetadata(GetCurrentResourceName(), "version", 0) or "1.0.0"
    }), {["Content-Type"] = "application/json"})
end)