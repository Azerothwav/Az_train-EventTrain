local SecurityPed = {}
local drugstrainblip = nil
local testspawnpnj = false
local caissedrug = {}

RegisterNetEvent('az_train:dlccreateDrugsTrainClient', function(index)
    Config.SendNotification(DrugTrainConfig.Lang["EventStart"])
    Config.CallBack('az_train:dlchavespawntrain', function(spawntrain)
        if spawntrain then
            RequestModel(GetHashKey('v_ind_cf_boxes'))
            while not HasModelLoaded(GetHashKey('v_ind_cf_boxes')) do
                Citizen.Wait(1)
            end
            temptraindrugs = CreateMissionTrain(0, DrugTrainConfig.DrugTrain[index].coordstrain.x, DrugTrainConfig.DrugTrain[index].coordstrain.y, DrugTrainConfig.DrugTrain[index].coordstrain.z, math.random(0,100))
            SetTrainSpeed(temptraindrugs, 0)
            SetTrainCruiseSpeed(temptraindrugs,0)
            FreezeEntityPosition(temptraindrugs, true)
            for k, v in pairs(DrugTrainConfig.Cargaison) do
                local coordscaisse = GetOffsetFromEntityInWorldCoords(temptraindrugs, v.x, v.y, v.z - 1.0)
                caissedrug[k] = CreateObject(GetHashKey('v_ind_cf_boxes'), coordscaisse.x, coordscaisse.y, coordscaisse.z, true, false, false)
                FreezeEntityPosition(caissedrug[k], true)
                SetEntityHeading(caissedrug[k], GetEntityHeading(temptraindrugs))
            end
            TriggerServerEvent("az_train:syncTrainEventModel", VehToNet(temptraindrugs))
        end
    end)
    ShowBlipToEveryone(DrugTrainConfig.DrugTrain[index].coordstrain, DrugTrainConfig.DrugTrain[index].showblip)
    indrugmissiontrain = true
    LaunchTrain(index)
end)

RegisterNetEvent("az_train:syncTrainEventModel", function(netid)
    temptraindrugs = NetToVeh(netid)
end)

RegisterNetEvent("az_train:syncPNJTrainEvent", function(pnjdata)
    for k, v in pairs(pnjdata) do
        SecurityPed[k] = NetToPed(v)
        print(SecurityPed[k])
    end
end)

RegisterNetEvent('az_train:dlcremoveDrugsTrainClient', function(index)
    Config.SendNotification(DrugTrainConfig.Lang["EventStop"])
    for b, c in pairs(SecurityPed) do
        DeleteEntity(c)
        SecurityPed[b] = nil
    end
    for k, v in pairs(caissedrug) do
        DeleteEntity(v)
    end
    RemoveThisTrain(temptraindrugs)
    indrugmissiontrain = false
    if drugstrainblip and drugstrainblip ~= nil then
        RemoveBlip(drugstrainblip)
        drugstrainblip = nil
    end
end)

function ShowBlipToEveryone(coords, havetoshowblip)
    if havetoshowblip then
        drugstrainblip = AddBlipForCoord(coords.x, coords.y, coords.z)
        SetBlipSprite (drugstrainblip, 795)
        SetBlipDisplay(drugstrainblip, 4)
        SetBlipScale(drugstrainblip, 0.75)
        SetBlipColour (drugstrainblip, 45)
        SetBlipAsShortRange(drugstrainblip, true)

        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(DrugTrainConfig.Lang["TrainToRob"])
        EndTextCommandSetBlipName(drugstrainblip)
    end
end

function LaunchTrain(index)
    local createpnjsecurity = false
    Citizen.CreateThread(function()
        while indrugmissiontrain do
            local wait = 1000
            local playercoords = GetEntityCoords(GetPlayerPed(-1))
            if GetDistanceBetweenCoords(playercoords, DrugTrainConfig.DrugTrain[index].coordstrain, true) < 50 then
                for k, v in pairs(DrugTrainConfig.Cargaison) do
                    local coordscaisse = GetOffsetFromEntityInWorldCoords(temptraindrugs, v.x, v.y, v.z - 1.0)
                    local caissecoords = vector3(coordscaisse.x, coordscaisse.y, coordscaisse.z)
                    if GetDistanceBetweenCoords(playercoords, caissecoords, true) < 2 then
                        wait = 0
                        Config.HelpNotification(DrugTrainConfig.Lang["TakeCargaison"])
                        if IsControlJustReleased(0, 38) then
                            allpnjdeath = true
                            for b, c in pairs(SecurityPed) do
                                if IsEntityDead(c) == false then
                                    allpnjdeath = false
                                end
                            end
                            if allpnjdeath then
                                FreezeEntityPosition(GetPlayerPed(-1), true)
                                DrugTrainConfigFunctionProgressBar(DrugTrainConfig.ProgressBarTime, DrugTrainConfig.Lang["InTakeOff"])
                                Citizen.Wait(DrugTrainConfig.ProgressBarTime)
                                FreezeEntityPosition(GetPlayerPed(-1), false)
                                TriggerServerEvent('az_train:dlcremoveTrainDrugsServer', index)
                                TriggerServerEvent('az_train:dlcgiverewardtraindrug', index)
                                indrugmissiontrain = false
                            else
                                Config.SendNotification(DrugTrainConfig.Lang["NotAllPNJDeath"])
                            end
                        end
                    end
                    if not testspawnpnj then
                        testspawnpnj = true
                        Config.CallBack('az_train:dlchavespawnpnj', function(spawnpnj)
                            if spawnpnj then
                                for b, n in pairs(SecurityPed) do
                                    SecurityPed[b] = nil
                                end
                                AddRelationshipGroup('pedennemiedrug')
                                for x, w in pairs(DrugTrainConfig.DrugTrain[index].security) do
                                    RequestModel(GetHashKey(w.ped))
                                    while not HasModelLoaded(GetHashKey(w.ped)) do
                                        Citizen.Wait(0)
                                    end
                                    SecurityPed[x] = CreatePed(7,GetHashKey(w.ped),w.coordspnj.x, w.coordspnj.y, w.coordspnj.z - 1, math.random(0, 120),true,true)
                                    if w.scenario ~= nil then
                                        TaskStartScenarioInPlace(SecurityPed[x], w.scenario, 0, false)
                                    end
                                    if w.health < 200 then
                                        SetPedMaxHealth(SecurityPed[x], w.health)
                                    end
                                    if w.armor > 0 then
                                        SetPedArmour(SecurityPed[x], w.armor)
                                    end
                                    if w.weapon ~= nil then
                                        GiveWeaponToPed(SecurityPed[x], GetHashKey(w.weapon), 250, false, true)
                                        SetCurrentPedWeapon(SecurityPed[x], GetHashKey(w.weapon), true)
                                        SetPedAccuracy(SecurityPed[x], w.accuracy)
                                    end
                                    if w.freeze then
                                        FreezeEntityPosition(SecurityPed[x], true)
                                    end
                                    SetPedCombatRange(SecurityPed[x], 2)
                                    SetPedCombatAttributes(SecurityPed[x], 46, true)
                                    SetPedRelationshipGroupHash(SecurityPed[x], GetHashKey('pedennemiedrug'))
                                    SetRelationshipBetweenGroups(5, GetHashKey('pedennemiedrug'), GetHashKey("PLAYER"))
                                end
                                local serverTableNetID = {}
                                for x, w in pairs(SecurityPed) do
                                    serverTableNetID[x] = PedToNet(w)
                                end
                                TriggerServerEvent("az_train:syncPNJTrainEvent", serverTableNetID)
                            end
                        end)
                    end
                end
            end
            Citizen.Wait(wait)
        end
    end)
end

function RemoveThisTrain(traintodelete)
    Citizen.SetTimeout(30000, function()
        DeleteMissionTrain(traintodelete)
    end)
end

print("[AZ_TRAIN] - DLC Drug Train Load")
