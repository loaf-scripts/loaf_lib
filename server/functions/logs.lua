local function GetIdentifier(source, identifier)
    if not GetPlayerName(source) then return false end

    identifier = identifier .. ":"
    for i, ident in pairs(GetPlayerIdentifiers(source)) do
        if string.sub(ident, 1, #identifier) == identifier then
            return string.sub(ident, #identifier + 1, #ident)
        end
    end
    return false
end

local function GetPlayerPicture(source)
    if not GetPlayerName(source) then return false end

    local steam = GetIdentifier(source, "steam")
    if not steam then return false end
    local url
    PerformHttpRequest("https://steamcommunity.com/profiles/" .. tonumber(steam, 16), function(err, text, headers) 
        if not text then url = false end

        url = text:match('<meta name="twitter:image" content="(.-)"')
    end, "GET")
    while url == nil do
        Wait(0)
    end
    return url
end

function functions.Log(data)
    if type(data) ~= "table" or not data.text then return end

    local messageData = ServerConfig.ErrorTypes[data.type or "info"] or ServerConfig.ErrorTypes.info
    local embed = {
        color = messageData.colour,
        author = {
            name = messageData.label,
            icon_url = messageData.image
        },
        timestamp = os.date('!%Y-%m-%dT%H:%M:%S.000Z'),
        footer = {
            text = GetInvokingResource(),
        },
    }

    if data.source then
        local picture = GetPlayerPicture(data.source) or "https://winaero.com/blog/wp-content/uploads/2018/08/Windows-10-user-icon-big.png"
        local discord = GetIdentifier(data.source, "discord")
        
        local identifiers = "Identifiers:\n"
        for i, identifier in pairs(GetPlayerIdentifiers(data.source)) do
            if not string.find(identifier, "ip:") then
                if string.find(identifier, "steam:") then
                    local steam = GetIdentifier(data.source, "steam")
                    if not steam then
                        identifiers = identifiers .. "    • " .. identifier .. "\n"
                    else
                        identifiers = identifiers .. ("    • https://steamcommunity.com/profiles/%s %s\n"):format(tonumber(steam, 16), identifier)
                    end
                elseif string.find(identifier, "discord:") then
                    local discord = GetIdentifier(data.source, "discord")
                    if not discord then
                        identifiers = identifiers .. "    • " .. identifier .. "\n"
                    else
                        identifiers = identifiers .. ("    • <@%s> %s\n"):format(discord, discord)
                    end
                else
                    identifiers = identifiers .. "    • " .. identifier .. "\n"
                end
            end
        end

        embed.author = {
            name = GetPlayerName(data.source) .. " [id "..data.source.."]",
            icon_url = picture
        }

        embed.description = identifiers
        if data.title then embed.title = data.title end
        if data.text then embed.description = data.text .. "\n\n"..embed.description end
    else
        if data.title then embed.title = data.title end
        if data.text then embed.description = data.text end
    end

    PerformHttpRequest(data.webhook or ServerConfig.Logs[data.category or "default"] or ServerConfig.Logs.default, function(err, text, headers) end, "POST", json.encode({
        username = data.category or "Default", 
        embeds = {embed}, 
        avatar_url = data.avatar or "https://dunb17ur4ymx4.cloudfront.net/webstore/logos/3abb800c9903d7ba189328c8f520e76c96bf35ba.png"
    }), {["Content-Type"] = "application/json"})
end