ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local lastdrugtrain = nil
local trainalreadyspawn = false
local pnjalreadyspawn = false
SetTimeout(10000, function()
    CreateThread(function()
        while true do
            t = os.date("*t")
            for k, v in pairs(DrugTrainConfig.DrugTrain) do
                if lastdrugtrain and tonumber(t.hour) == tonumber(DrugTrainConfig.DrugTrain[k].delais.hoursstop) and tonumber(t.min) == tonumber(DrugTrainConfig.DrugTrain[k].delais.minstop) then
                    lastdrugtrain = nil
                    TriggerClientEvent('az_train:dlcremoveDrugsTrainClient', -1, k)
                end
                if tonumber(DrugTrainConfig.DrugTrain[k].delais.hoursstart) == tonumber(t.hour) and lastdrugtrain ~= tonumber(DrugTrainConfig.DrugTrain[k].delais.hoursstart) and tonumber(t.min) == tonumber(DrugTrainConfig.DrugTrain[k].delais.minstart) then
                    lastdrugtrain = DrugTrainConfig.DrugTrain[k].delais.hoursstart
                    TriggerClientEvent('az_train:dlccreateDrugsTrainClient', -1, k)
                end
            end
            Citizen.Wait(10000)
        end
    end)
end)

RegisterNetEvent('az_train:dlcremoveTrainDrugsServer')
AddEventHandler('az_train:dlcremoveTrainDrugsServer', function(index)
    TriggerClientEvent('az_train:dlcremoveDrugsTrainClient', -1, index)
    trainalreadyspawn = false
    pnjalreadyspawn = false
end)

if Config.FrameWork == 'ESX' then
    ESX.RegisterServerCallback('az_train:dlchavespawnpnj', function(source, cb)
        if not pnjalreadyspawn then
            pnjalreadyspawn = true
            cb(true)
        else
            cb(false)
        end
    end)

    ESX.RegisterServerCallback('az_train:dlchavespawntrain', function(source, cb)
        if not trainalreadyspawn then
            trainalreadyspawn = true
            cb(true)
        else
            cb(false)
        end
    end)
elseif Config.FrameWork == 'QBCore' then 
    QBCore.Functions.CreateCallback('az_train:dlchavespawnpnj', function(source, cb)
        if not pnjalreadyspawn then
            pnjalreadyspawn = true
            cb(true)
        else
            cb(false)
        end
    end)

    QBCore.Functions.CreateCallback('az_train:dlchavespawntrain', function(source, cb)
        if not trainalreadyspawn then
            trainalreadyspawn = true
            cb(true)
        else
            cb(false)
        end
    end)
end

RegisterNetEvent('az_train:dlcgiverewardtraindrug', function(index)
    if Config.FrameWork == 'ESX' then
        local xPlayer = ESX.GetPlayerFromId(source)
        for k, v in pairs(DrugTrainConfig.DrugTrain[index].reward) do
            xPlayer.addInventoryItem(k, v)
        end
    elseif Config.FrameWork == 'QBCore' then
        local Player = QBCore.Functions.GetPlayer(source)
        for k, v in pairs(DrugTrainConfig.DrugTrain[index].reward) do
            Player.Functions.AddItem(k, v)
        end
    end
end)

RegisterNetEvent("az_train:syncTrainEventModel", function(idnet)
    TriggerClientEvent("az_train:syncTrainEventModel", -1, idnet)
end)

RegisterNetEvent("az_train:syncPNJTrainEvent", function(tablePNJ)
    TriggerClientEvent("az_train:syncPNJTrainEvent", -1, tablePNJ)
end)
