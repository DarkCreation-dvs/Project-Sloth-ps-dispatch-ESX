ESX = exports['es_extended']:getSharedObject()

local calls = {}
local callCount = 0

-- Callbacks
ESX.RegisterServerCallback('ps-dispatch:getDispatchCalls', function(source, cb)
    cb(calls)
end)

ESX.RegisterServerCallback('ps-dispatch:getLatestDispatch', function(source, cb)
    cb(calls[#calls])
end)

-- Events
RegisterServerEvent('ps-dispatch:server:notify')
AddEventHandler('ps-dispatch:server:notify', function(data)
    callCount = callCount + 1
    data.id = callCount
    data.time = os.time() * 1000
    data.units = {}
    data.responses = {}

    -- Prevent duplicate entries
    if #calls > 0 and calls[#calls].id == data.id then
        return
    end
    
    if #calls >= Config.MaxCallList then
        table.remove(calls, 1)
    end

    table.insert(calls, data)

    TriggerClientEvent('ps-dispatch:client:notify', -1, data)
end)

RegisterServerEvent('ps-dispatch:server:attach')
AddEventHandler('ps-dispatch:server:attach', function(id, player)
    for i = 1, #calls do
        if calls[i].id == id then
            for j = 1, #calls[i].units do
                if calls[i].units[j].citizenid == player.citizenid then
                    return -- Already attached
                end
            end
            table.insert(calls[i].units, player)
            return
        end
    end
end)

RegisterServerEvent('ps-dispatch:server:detach')
AddEventHandler('ps-dispatch:server:detach', function(id, player)
    for i = #calls, 1, -1 do
        if calls[i].id == id then
            if calls[i].units and #calls[i].units > 0 then
                for j = #calls[i].units, 1, -1 do
                    if calls[i].units[j].citizenid == player.citizenid then
                        table.remove(calls[i].units, j)
                    end
                end
            end
            return
        end
    end
end)

-- Commands

RegisterCommand('dispatch', function(source, args, rawCommand)
    TriggerClientEvent('ps-dispatch:client:openMenu', source, calls)
end, false)

RegisterCommand('911', function(source, args, rawCommand)
    local fullMessage = rawCommand:sub(5)
    if fullMessage == '' then
        TriggerClientEvent('chat:addMessage', source, { args = { '^1Error', 'Please enter a message.' } })
        return
    end
    TriggerClientEvent('ps-dispatch:client:sendEmergencyMsg', source, fullMessage, "911", false)
end, false)

RegisterCommand('911a', function(source, args, rawCommand)
    local fullMessage = rawCommand:sub(6)
    if fullMessage == '' then
        TriggerClientEvent('chat:addMessage', source, { args = { '^1Error', 'Please enter a message.' } })
        return
    end
    TriggerClientEvent('ps-dispatch:client:sendEmergencyMsg', source, fullMessage, "911", true)
end, false)

RegisterCommand('311', function(source, args, rawCommand)
    local fullMessage = rawCommand:sub(5)
    if fullMessage == '' then
        TriggerClientEvent('chat:addMessage', source, { args = { '^1Error', 'Please enter a message.' } })
        return
    end
    TriggerClientEvent('ps-dispatch:client:sendEmergencyMsg', source, fullMessage, "311", false)
end, false)

RegisterCommand('311a', function(source, args, rawCommand)
    local fullMessage = rawCommand:sub(6)
    if fullMessage == '' then
        TriggerClientEvent('chat:addMessage', source, { args = { '^1Error', 'Please enter a message.' } })
        return
    end
    TriggerClientEvent('ps-dispatch:client:sendEmergencyMsg', source, fullMessage, "311", true)
end, false)