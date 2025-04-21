ESX = exports["es_extended"]:getSharedObject()

local isOnDuty = false
local currentDelivery = nil
local deliveryBlip = nil
local deliveryVehicle = nil
local allBlips = {}

-- Création du blip permanent de l'entreprise
CreateThread(function()
    local blip = AddBlipForCoord(Config.StartPoint.pos)
    SetBlipSprite(blip, Config.Blips.Pizzeria.Sprite)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, Config.Blips.Pizzeria.Scale)
    SetBlipColour(blip, Config.Blips.Pizzeria.Color)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.Blips.Pizzeria.Label .. " (Entreprise)")
    EndTextCommandSetBlipName(blip)
end)

-- Fonction pour créer les blips
local function CreateJobBlips()
    -- Suppression des anciens blips
    RemoveJobBlips()
    
    -- Blip principal de la pizzeria
    local pizzeriaBlip = AddBlipForCoord(Config.StartPoint.pos)
    SetBlipSprite(pizzeriaBlip, Config.Blips.Pizzeria.Sprite)
    SetBlipDisplay(pizzeriaBlip, 4)
    SetBlipScale(pizzeriaBlip, Config.Blips.Pizzeria.Scale)
    SetBlipColour(pizzeriaBlip, Config.Blips.Pizzeria.Color)
    SetBlipAsShortRange(pizzeriaBlip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.Blips.Pizzeria.Label)
    EndTextCommandSetBlipName(pizzeriaBlip)
    table.insert(allBlips, pizzeriaBlip)
    
    -- Debug notification
    ESX.ShowNotification("Blip de la pizzeria créé")
end

-- Fonction pour supprimer les blips
local function RemoveJobBlips()
    for _, blip in ipairs(allBlips) do
        RemoveBlip(blip)
    end
    allBlips = {}
end

-- Gestion du job
RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    ESX.PlayerData = xPlayer
    if ESX.PlayerData.job and ESX.PlayerData.job.name == 'pizza' then
        CreateJobBlips()
    end
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    ESX.PlayerData.job = job
    RemoveJobBlips()
    if job.name == 'pizza' then
        CreateJobBlips()
    end
end)

-- Gestion du garage
local function OpenGarageMenu()
    local elements = {
        {label = 'Sortir un véhicule', value = 'spawn_vehicle'},
    }
    
    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'garage_menu', {
        title = 'Garage Pizzeria',
        align = 'top-left',
        elements = elements
    }, function(data, menu)
        if data.current.value == 'spawn_vehicle' then
            if deliveryVehicle then
                ESX.ShowNotification('Vous avez déjà un véhicule sorti!')
                return
            end
            
            ESX.Game.SpawnVehicle(Config.Vehicle, Config.Garage.SpawnPoint.pos, Config.Garage.SpawnPoint.heading, function(vehicle)
                deliveryVehicle = vehicle
                SetVehicleNumberPlateText(vehicle, "PIZZA"..math.random(100, 999))
                TaskWarpPedIntoVehicle(PlayerPedId(), vehicle, -1)
            end)
            menu.close()
        end
    end, function(data, menu)
        menu.close()
    end)
end

-- Configuration des targets avec ox_target
CreateThread(function()
    -- Target pour commencer/arrêter les livraisons
    exports.ox_target:addBoxZone({
        coords = Config.StartPoint.pos,
        size = vector3(1.5, 1.5, 3.0),
        rotation = Config.StartPoint.heading,
        debug = false,
        options = {
            {
                name = 'delivery_job',
                icon = 'fas fa-box',
                label = 'Commencer/Arrêter les livraisons',
                onSelect = function()
                    if not isOnDuty then
                        StartDeliveryJob()
                    else
                        StopDeliveryJob()
                    end
                end,
                canInteract = function()
                    return ESX.PlayerData.job and ESX.PlayerData.job.name == 'pizza'
                end
            }
        }
    })

    -- Target pour le garage
    exports.ox_target:addBoxZone({
        coords = Config.Garage.MenuPosition,
        size = vector3(1.5, 1.5, 3.0),
        rotation = Config.StartPoint.heading,
        debug = false,
        options = {
            {
                name = 'garage_menu',
                icon = 'fas fa-car',
                label = 'Ouvrir le garage',
                onSelect = function()
                    OpenGarageMenu()
                end,
                canInteract = function()
                    return ESX.PlayerData.job and ESX.PlayerData.job.name == 'pizza'
                end
            }
        }
    })

    -- Target pour ranger le véhicule
    exports.ox_target:addBoxZone({
        coords = Config.Garage.DeletePoint.pos,
        size = vector3(1.5, 1.5, 3.0),
        rotation = Config.StartPoint.heading,
        debug = false,
        options = {
            {
                name = 'delete_vehicle',
                icon = 'fas fa-parking',
                label = 'Ranger le véhicule',
                onSelect = function()
                    if GetVehiclePedIsIn(PlayerPedId(), false) == deliveryVehicle then
                        ESX.Game.DeleteVehicle(deliveryVehicle)
                        deliveryVehicle = nil
                        ESX.ShowNotification('Véhicule rangé')
                    end
                end,
                canInteract = function()
                    return deliveryVehicle and ESX.PlayerData.job and ESX.PlayerData.job.name == 'pizza'
                end
            }
        }
    })

    -- Target pour le menu boss
    exports.ox_target:addBoxZone({
        coords = Config.BossMenu.pos,
        size = vector3(1.5, 1.5, 3.0),
        rotation = Config.StartPoint.heading,
        debug = false,
        options = {
            {
                name = 'boss_menu',
                icon = 'fas fa-user-tie',
                label = 'Menu patron',
                onSelect = function()
                    TriggerEvent('esx_society:openBossMenu', 'pizza', function(data, menu)
                        menu.close()
                    end)
                end,
                canInteract = function()
                    return ESX.PlayerData.job and ESX.PlayerData.job.name == 'pizza' and ESX.PlayerData.job.grade_name == 'boss'
                end
            }
        }
    })
end)

-- Gestion des points de livraison avec ox_target
CreateThread(function()
    while true do
        Wait(1000)
        
        if isOnDuty and currentDelivery then
            -- Supprimer l'ancienne target si elle existe
            exports.ox_target:removeZone('deliver_pizza')
            
            -- Créer une nouvelle target pour ce point de livraison
            exports.ox_target:addBoxZone({
                coords = currentDelivery.pos,
                size = vector3(1.5, 1.5, 3.0),
                rotation = 0.0,
                debug = false,
                options = {
                    {
                        name = 'deliver_pizza',
                        icon = 'fas fa-pizza-slice',
                        label = 'Livrer la pizza',
                        onSelect = function()
                            TriggerServerEvent('pizza_delivery:deliveryComplete')
                            StartNewDelivery()
                        end,
                        canInteract = function()
                            return isOnDuty and currentDelivery
                        end
                    }
                }
            })
        else
            -- Supprimer la target si on n'est pas en service ou pas de livraison
            exports.ox_target:removeZone('deliver_pizza')
        end
    end
end)

-- Fonctions principales
function StartNewDelivery()
    if not isOnDuty then return end
    
    currentDelivery = Config.DeliveryPoints[math.random(#Config.DeliveryPoints)]
    
    if DoesBlipExist(deliveryBlip) then
        RemoveBlip(deliveryBlip)
    end
    
    deliveryBlip = AddBlipForCoord(currentDelivery.pos)
    SetBlipSprite(deliveryBlip, Config.Blips.Delivery.Sprite)
    SetBlipScale(deliveryBlip, Config.Blips.Delivery.Scale)
    SetBlipColour(deliveryBlip, Config.Blips.Delivery.Color)
    SetBlipRoute(deliveryBlip, true)
    SetBlipRouteColour(deliveryBlip, Config.Blips.Delivery.Color)
    
    ESX.ShowNotification("Nouvelle livraison en cours, suivez le GPS!")
end

function StartDeliveryJob()
    isOnDuty = true
    ESX.ShowNotification("Vous commencez votre service de livreur de pizza")
    StartNewDelivery()
end

function StopDeliveryJob()
    isOnDuty = false
    ESX.ShowNotification("Vous terminez votre service")
    
    if DoesBlipExist(deliveryBlip) then
        RemoveBlip(deliveryBlip)
    end
    
    currentDelivery = nil
end
