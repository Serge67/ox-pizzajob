ESX = exports["es_extended"]:getSharedObject()

RegisterServerEvent('pizza_delivery:deliveryComplete')
AddEventHandler('pizza_delivery:deliveryComplete', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if xPlayer then
        xPlayer.addMoney(Config.PizzaPrice)
        TriggerClientEvent('esx:showNotification', source, 'Vous avez reçu ~g~'..Config.PizzaPrice..'€~w~ pour cette livraison!')
    end
end)ESX = exports["es_extended"]:getSharedObject()

-- Initialisation de la société
TriggerEvent('esx_society:registerSociety', 'pizza', 'Pizzeria', 'society_pizza', 'society_pizza', 'society_pizza', {type = 'private'})

-- Paiement des livraisons
RegisterServerEvent('pizza_delivery:deliveryComplete')
AddEventHandler('pizza_delivery:deliveryComplete', function()
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if xPlayer and xPlayer.job.name == 'pizza' then
        -- Ajoute l'argent à la société
        TriggerEvent('esx_addonaccount:getSharedAccount', 'society_pizza', function(account)
            if account then
                account.addMoney(Config.PizzaPrice)
            end
        end)
        
        -- Donne un pourcentage au livreur
        local playerCut = math.floor(Config.PizzaPrice * 0.5) -- 50% pour le livreur
        xPlayer.addMoney(playerCut)
        
        TriggerClientEvent('esx:showNotification', source, 'Vous avez reçu ~g~'..playerCut..'€~w~ pour cette livraison!')
    end
end)