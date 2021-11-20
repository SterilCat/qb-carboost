local amount = math.random(1000, 2700)
local luckchance = math.random(1, 100)

RegisterNetEvent('tevi_carthief:setMoney', function()
    local user = QBCore.Functions.GetPlayer(source)
    if user and luckchance <= 98 then
        user.Functions.AddMoney("cash", amount, "Car Boost")
        TriggerClientEvent('QBCore:Notify', source, 'You have delivered the vehicle and you were paid $'..amount )
    elseif user and luckchance > 98 then
        user.Functions.AddItem("rubber", math.random(35, 125))
        TriggerClientEvent('QBCore:Notify', source, 'You have delivered the vehicle and were paid $'..amount.. " you also received some bonus items for your good work!" )
    end
end)