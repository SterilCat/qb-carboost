local QBCore = exports['qb-core']:GetCoreObject()
local mission, inzone1 = false, false
local ped, pedenauto, flomsg1, flomsg2, blip, blip2, blip3, Veh

local function DrawText3D(text, coords)
    local onScreen, _x, _y = World3dToScreen2d(coords.x, coords.y, coords.z)

    if onScreen then
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
        local factor = (string.len(text)) / 350
        DrawRect(_x, _y + 0.0125, 0.017 + factor, 0.03, 0, 0, 0, 75)
    end
end

local function modelRequest(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(0)
    end
end

local function CreateBlips()
    blip = AddBlipForEntity(Veh)
    SetBlipSprite(blip, 523)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, 1.0)
    SetBlipColour(blip, 60)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString('Vehicle')
    EndTextCommandSetBlipName(blip)

    blip2 = AddBlipForCoord(1189.46, -3108.26, 4.24)
    SetBlipSprite(blip2, 229)
    SetBlipDisplay(blip2, 4)
    SetBlipScale(blip2, 1.0)
    SetBlipColour(blip2, 0)
    SetBlipAsShortRange(blip2, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString('Delivery point')
    EndTextCommandSetBlipName(blip2)
end

local function CreateBlips2()
    blip3 = AddBlipForEntity(ped)
    SetBlipSprite(blip3, 303)
    SetBlipDisplay(blip3, 4)
    SetBlipScale(blip3, 1.0)
    SetBlipColour(blip3, 4)
    SetBlipAsShortRange(blip2, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString('Vehicle theft')
    EndTextCommandSetBlipName(blip3)
end

local function SetIntoCar(ped, veh, seat)
    SetPedIntoVehicle(ped, veh, seat)
    SetPedRelationshipGroupHash(ped)
    SetDriverAbility(ped, 1.0)
    SetPedFleeAttributes(ped, 0, 1)
    SetPedCombatAttributes(ped, 2, 1)
    SetPedCombatAttributes(ped, 3, 1)
end

local function SpawnCar()
    local pos = Config.spawnpoints[math.random(1, #Config.spawnpoints)]
    local modelo = Config.vehicles[math.random(1, #Config.vehicles)]
    local modelo2 = GetHashKey(modelo.m)
    modelRequest(`a_m_m_bevhills_01`)
    modelRequest(modelo2)
    pedenauto = CreatePed(4, `a_m_m_bevhills_01`, pos.x, pos.y, pos.z, pos.h, true, true)
    Veh = CreateVehicle(modelo2, pos.x, pos.y, pos.z, pos.h, true, true)
    SetIntoCar(pedenauto, Veh, -1)
    TaskWarpPedIntoVehicle(pedenauto, Veh, -1)
    TaskVehicleDriveWander(pedenauto, Veh, 20.0, 786603)
    CreateBlips()
end

CreateThread(function()
    modelRequest(`s_m_y_dealer_01`)
    RequestAnimDict("mini@strip_club@idles@bouncer@base")
    while not HasAnimDictLoaded("mini@strip_club@idles@bouncer@base") do
        Wait(0)
    end
    ped = CreatePed(4, `s_m_y_dealer_01`, 1200.58, -3114.56, 4.5, false, true)
    SetEntityHeading(ped, 294.1)
    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    TaskPlayAnim(ped, "mini@strip_club@idles@bouncer@base", "base", 8.0, 0.0, -1, 1, 0, 0, 0, 0)
end)

CreateThread(function()
    while true do
        local sleep = 1000
        inzone1 = #(vector3(1200.58, -3114.56, 4.5) - GetEntityCoords(PlayerPedId())) < 7.0
        if inzone1 and not mission then
            sleep = 0
            DrawText3D(flomsg1, vector3(1200.58, -3114.56, 6.5))
            if IsControlJustPressed(1, Config.InteractKey) then
                TriggerEvent('QBCore:Notify', 'I have a job for you, there is a vehicle on your gps, bring it to me quickly')
                SpawnCar()
                mission = true
            end
        end

        if mission then
            sleep = 0
            DrawMarker(1, 1189.46, -3108.26, 4.24, 0, 0, 0, 0, 0, 0, 3.5001, 3.5001, 0.6001, 0, 0, 255, 200, 0, 0, 0, 0)
            if inzone1 then
                DrawText3D(flomsg2, vector3(1189.46, -3108.26, 4.24+2))
                if IsControlJustPressed(1, Config.InteractKey) then
                    local coordsauto = GetEntityCoords(Veh)
                    if #(vector3(1189.46, -3108.26, 4.24) - coordsauto) < 7.0 then
                        QBCore.Functions.DeleteVehicle(Veh)
                        mission = false
                        TriggerServerEvent("tevi_carthief:setMoney")
                        RemoveBlip(blip2)
                        blip2 = nil
                    else
                        QBCore.Functions.Notify('You are not in the vehicle I asked for!')
                    end
                    sleep = 1000
                end
            end
        end
        Wait(sleep)
    end
end)

AddEventHandler('onResourceStart', function()
    flomsg1 = 'Press ~g~[E]~s~ to talk to the client.'
    flomsg2 = 'Press ~g~[E]~s~ to deliver the vehicle'
    mission = false
    if Config.blip then
        CreateBlips2()
    end
end)

AddEventHandler('onResourceStop', function(resource)
    if resource == GetCurrentResourceName() then
        if ped then
            DeletePed(ped)
        end
        if pedenauto then
            DeletePed(pedenauto)
        end
        if blip then
            RemoveBlip(blip)
        end
        if blip2 then
            RemoveBlip(blip2)
        end
        if blip3 then
            RemoveBlip(blip3)
        end
    end
end)