local playerCodes = {}
local usedCodes = {}
local playerReady = {}

local tokenAmount = 2.5

local waitTime = 30 * 60 * 1000  

function GetLicenseIdentifier(src)
    for i = 0, GetNumPlayerIdentifiers(src) - 1 do
        local id = GetPlayerIdentifier(src, i)
        if string.sub(id, 1, 7) == "license" then
            return string.sub(id, 9)  
        end
    end
    return nil
end

AddEventHandler('playerJoining', function()
    local src = source
    local identifier = GetLicenseIdentifier(src)
    if not identifier then return end

    playerReady[identifier] = false

    SetTimeout(waitTime, function()
        if GetPlayerName(src) then
            local code = tostring(math.random(10000, 99999))
            playerCodes[identifier] = code
            playerReady[identifier] = true

            TriggerClientEvent('chat:addMessage', src, {
                args = {"~r~[SYSTEM]", " Type /claimtoken " .. code .. " to receive " .. tokenAmount .. " token!"}
            })
        end
    end)
end)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end

    for _, playerId in ipairs(GetPlayers()) do
        local identifier = GetLicenseIdentifier(playerId)
        if identifier then
            playerReady[identifier] = false

            SetTimeout(waitTime, function()
                if GetPlayerName(playerId) then
                    local code = tostring(math.random(10000, 99999))
                    playerCodes[identifier] = code
                    playerReady[identifier] = true

                    TriggerClientEvent('chat:addMessage', playerId, {
                        args = {"~r~[SYSTEM]", " Type /claimtoken " .. code .. " to receive " .. tokenAmount .. " token!"}
                    })
                end
            end)
        end
    end
end)

RegisterCommand("claimtoken", function(source, args)
    local src = source
    local identifier = GetLicenseIdentifier(src)
    if not identifier then return end

    local codeEntered = args[1]
    local correctCode = playerCodes[identifier]

    if not playerReady[identifier] then
        TriggerClientEvent('chat:addMessage', src, {
            args = {"~r~[SYSTEM]", " You are not able to receive a token yet. Please wait."}
        })
        return
    end

    if usedCodes[identifier] then
        TriggerClientEvent('chat:addMessage', src, {
            args = {"~r~[SYSTEM]", " You already claimed your token."}
        })
        return
    end

    if not codeEntered or codeEntered ~= correctCode then
        TriggerClientEvent('chat:addMessage', src, {
            args = {"~r~~r~[SYSTEM]", " Invalid code."}
        })
        return
    end

    MySQL.query('SELECT tokens FROM users WHERE identifier = ?', {identifier}, function(result)
        local tokens = 0.0
        if result[1] and result[1].tokens then
            tokens = tonumber(result[1].tokens)
        else
            MySQL.update('INSERT INTO users (identifier, tokens) VALUES (?, ?)', {
                identifier, 0.0
            })
        end

        local newTokens = tokens + tokenAmount  
        MySQL.update('UPDATE users SET tokens = ? WHERE identifier = ?', {
            newTokens, identifier
        })

        usedCodes[identifier] = true
        TriggerClientEvent('chat:addMessage', src, {
            args = {"~r~[SYSTEM]", " You received " .. tokenAmount .. " token!"}
        })
    end)
end, false)

AddEventHandler('onResourceStart', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        TriggerClientEvent('chat:addSuggestion', -1, '/claimtoken', 'Claim your token', {
            { name = 'code', help = 'Enter the 5-digit code to receive your token' }
        })
    end
end)

