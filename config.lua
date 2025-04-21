Config = {}

Config.PizzaPrice = 10 -- Prix de vente d'une pizza
Config.Vehicle = 'blista' -- Véhicule de livraison

-- Blips
Config.Blips = {
    Pizzeria = {
        Sprite = 267,
        Color = 47, -- Rouge vif
        Scale = 0.8, -- Plus grand
        Label = "Pizzeria"
    },
    Delivery = {
        Sprite = 501,
        Color = 2,
        Scale = 0.6,
        Label = "Point de livraison"
    }
}

-- Points principaux
Config.StartPoint = {
    pos = vector3(-1285.73, -1387.15, 3.34),
    heading = 286.63
}

Config.BossMenu = {
    pos = vector3(-1283.73, -1387.15, 3.44)
}

-- Garage
Config.Garage = {
    MenuPosition = vector3(-1277.73, -1387.15, 3.34),
    SpawnPoint = {
        pos = vector3(-1275.73, -1387.15, 3.34),
        heading = 286.63
    },
    DeletePoint = {
        pos = vector3(-1273.73, -1387.15, 3.34)
    }
}

-- Points de livraison
Config.DeliveryPoints = {
    {pos = vector3(-1064.45, -1159.62, 2.34)},
    {pos = vector3(-1225.47, -1208.42, 6.34)},
    {pos = vector3(-1185.25, -1386.40, 3.34)},
    {pos = vector3(-1332.60, -1198.04, 3.34)},
    {pos = vector3(-1371.68, -1042.58, 3.34)}
}