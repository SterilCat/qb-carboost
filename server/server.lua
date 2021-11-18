local QBCore = exports['qb-core']:GetCoreObject()

RegisterNetEvent('tevi_carthief:setMoney', function()
    local user = QBCore.Functions.GetPlayer(source)
    if user then
        user.Functions.AddItem('markedbills', 1, {worth = Config.paid})
        TriggerClientEvent('QBCore:Notify', source, 'You have delivered the vehicle and you were paid ~r~$'.. Config.paid)
    end
end)