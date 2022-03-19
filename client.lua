local QBCore = exports['qb-core']:GetCoreObject()

Config = {} 
Config.DamageNeeded = 100.0 -- 100.0 being broken and 1000.0 being fixed a lower value than 100.0 will break it
Config.MaxWidth = 5.0 -- Will complete soon
Config.MaxHeight = 5.0
Config.MaxLength = 5.0

local Keys = {
  ["E"] = 38, ["A"] = 34, ["D"] = 9, ["LEFTSHIFT"] = 21
}

local First = vector3(0.0, 0.0, 0.0)
local Second = vector3(5.0, 5.0, 5.0)

local Vehicle = {}

Citizen.CreateThread(function()
    while true do
        local ped = PlayerPedId()
        local closestVehicle = QBCore.Functions.GetClosestVehicle()
        local vehicleCoords = GetEntityCoords(closestVehicle)
        local dimension = GetModelDimensions(GetEntityModel(closestVehicle), First, Second)
        if DoesEntityExist(closestVehicle) and IsEntityAVehicle(closestVehicle) and not IsPedInAnyVehicle(ped, false) and #(GetEntityCoords(closestVehicle) - GetEntityCoords(ped)) < 5.0 then
            Vehicle.Coords = vehicleCoords
            Vehicle.Dimensions = dimension
            Vehicle.Vehicle = closestVehicle
            if GetDistanceBetweenCoords(GetEntityCoords(closestVehicle) + GetEntityForwardVector(closestVehicle), GetEntityCoords(ped), true) > GetDistanceBetweenCoords(GetEntityCoords(closestVehicle) + GetEntityForwardVector(closestVehicle) * -1, GetEntityCoords(ped), true) then
                Vehicle.IsInFront = false
            else
                Vehicle.IsInFront = true
            end
        else
            Vehicle = {Coords = nil, Vehicle = nil, Dimensions = nil, IsInFront = false}
        end
        Citizen.Wait(3000)
    end
end)


Citizen.CreateThread(function()
    while true do 
        Citizen.Wait(3)
        local ped = PlayerPedId()
        if Vehicle.Vehicle ~= nil then
 
            if IsVehicleSeatFree(Vehicle.Vehicle, -1) and GetVehicleEngineHealth(Vehicle.Vehicle) <= Config.DamageNeeded then
                QBCore.Functions.DrawText3D(Vehicle.Coords.x, Vehicle.Coords.y, Vehicle.Coords.z, "Press [~g~SHIFT~w~] and [~g~E~w~] to push the vehicle")
            end
     

            if IsControlPressed(0, Keys["LEFTSHIFT"]) and IsVehicleSeatFree(Vehicle.Vehicle, -1) and not IsEntityAttachedToEntity(ped, Vehicle.Vehicle) and IsControlJustPressed(0, Keys["E"])  and GetVehicleEngineHealth(Vehicle.Vehicle) <= Config.DamageNeeded then
                NetworkRequestControlOfEntity(Vehicle.Vehicle)
                local coords = GetEntityCoords(ped)
                if Vehicle.IsInFront then    
                    AttachEntityToEntity(ped, Vehicle.Vehicle, GetPedBoneIndex(6286), 0.0, Vehicle.Dimensions.y * -1 + 0.1 , Vehicle.Dimensions.z + 1.0, 0.0, 0.0, 180.0, 0.0, false, false, true, false, true)
                else
                    AttachEntityToEntity(ped, Vehicle.Vehicle, GetPedBoneIndex(6286), 0.0, Vehicle.Dimensions.y - 0.3, Vehicle.Dimensions.z  + 1.0, 0.0, 0.0, 0.0, 0.0, false, false, true, false, true)
                end

                RequestAnimDict('missfinale_c2ig_11')
                while not HasAnimDictLoaded("missfinale_c2ig_11") do
                    Citizen.Wait(2)
                end
                TaskPlayAnim(ped, 'missfinale_c2ig_11', 'pushcar_offcliff_m', 2.0, -8.0, -1, 35, 0, 0, 0, 0)
                Citizen.Wait(200)

                local currentVehicle = Vehicle.Vehicle
                 while true do
                    Citizen.Wait(5)
                    if IsDisabledControlPressed(0, Keys["A"]) then
                        TaskVehicleTempAction(ped, currentVehicle, 11, 1000)
                    end

                    if IsDisabledControlPressed(0, Keys["D"]) then
                        TaskVehicleTempAction(ped, currentVehicle, 10, 1000)
                    end

                    if Vehicle.IsInFront then
                        SetVehicleForwardSpeed(currentVehicle, -1.0)
                    else
                        SetVehicleForwardSpeed(currentVehicle, 1.0)
                    end

                    if HasEntityCollidedWithAnything(currentVehicle) then
                        SetVehicleOnGroundProperly(currentVehicle)
                    end

                    if not IsDisabledControlPressed(0, Keys["E"]) then
                        DetachEntity(ped, false, false)
                        StopAnimTask(ped, 'missfinale_c2ig_11', 'pushcar_offcliff_m', 2.0)
                        FreezeEntityPosition(ped, false)
                        break
                    end
                end
            end
        end
    end
end)
