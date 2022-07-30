DrugTrainConfig = {}

DrugTrainConfig.ProgressBarTime = 5000

DrugTrainConfig.DrugTrain = {
    [1] = {
        delais = {
            hoursstart = 16,
            minstart = 16,
            hoursstop = 18,
            minstop = 20
        },
        security = true,
        coordstrain = vector3(-520.39, 4461.92, 89.05),
        showblip = true,
        reward = {
            ["bread"] = 15,
            ["water"] = 15,
        },
        security = {
            [1] = {
                coordspnj = vector3(-522.46, 4456.5, 89.8),
                ped = 'a_f_m_bevhills_02',
                freeze = false,
                weapon = 'WEAPON_PISTOL',
                health = 100,
                scenario = '',
                armor = 25,
                accuracy = 20
            },
            [2] = {
                coordspnj = vector3(-517.88, 4463.93, 89.79),
                ped = 'a_f_m_bevhills_02',
                freeze = false,
                weapon = 'WEAPON_SMG',
                health = 100,
                scenario = '',
                armor = 25,
                accuracy = 20
            }
        }
    },
}

function DrugTrainConfigFunctionProgressBar(time, msg)
    if Config.FrameWork == 'ESX' then
        ProgressBar(time, msg)
    elseif Config.FrameWork == 'QBCore' then
        QBCore.Functions.Progressbar("", msg, time, false, true, {
                disableMovement = false,
                disableCarMovement = false,
                disableMouse = false,
                disableCombat = true,
            }, {}, {}, {}, function()
        end)
    end
end

DrugTrainConfig.Cargaison = {
    [1] = vector3(-0.0730, -15.50, -0.2503),
    [2] = vector3(-0.1224, -18.41749, -0.2445),
    [3] = vector3(-0.080, -21.3815, -0.2385),

    [4] = vector3(0.0415, -32.55, -0.2591),
    [5] = vector3(0.0364, -35.48, -0.2599),
    [6] = vector3(0.03843, -39.276, -0.2606)
}

DrugTrainConfig.Lang = {
    ["TrainToRob"] = 'Train to rob',
    ["TakeCargaison"] = 'Press E to take the cargaison of the train',
    ["NotAllPNJDeath"] = 'Not all the PNJ is death',
    ["InTakeOff"] = 'Cargaison in recuperation',
    ["EventStart"] = 'A train with a big cargo had problems on a track, we put the point on your map if you want to look at it',
    ["EventStop"] = 'The train left, it seems that someone helped them'
}