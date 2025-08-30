ESX = exports["es_extended"]:getSharedObject()

-- Génération d’un ID unique
local function GenerateUniqueId()
    return "UID-" .. math.random(100000, 999999)
end

-- Attribuer un ID unique automatiquement à la connexion
AddEventHandler('esx:playerLoaded', function(playerId, xPlayer)
    exports.oxmysql:scalar(
        ('SELECT %s FROM %s WHERE identifier = ?'):format(Config.Column, Config.Table),
        {xPlayer.identifier},
        function(uniqueId)
            if not uniqueId then
                -- Génère un nouvel ID et l’enregistre en base
                local newId = GenerateUniqueId()
                exports.oxmysql:update(
                    ('UPDATE %s SET %s = ? WHERE identifier = ?'):format(Config.Table, Config.Column),
                    {newId, xPlayer.identifier}
                )

                print(("[UniqueID] %s → ID unique attribué : %s"):format(xPlayer.identifier, newId))

                -- Notification + message dans le chat
                xPlayer.showNotification("🎫 Un ID unique vous a été attribué : ~y~" .. newId)
                TriggerClientEvent('chat:addMessage', playerId, {
                    args = { '^2[ID UNIQUE]', 'Votre identifiant unique est : ^3' .. newId }
                })
            else
                print(("[UniqueID] %s possède déjà l’ID unique : %s"):format(xPlayer.identifier, uniqueId))

                -- Notification + message dans le chat
                xPlayer.showNotification("🎫 Votre ID unique est : ~y~" .. uniqueId)
                TriggerClientEvent('chat:addMessage', playerId, {
                    args = { '^2[ID UNIQUE]', 'Votre identifiant unique est : ^3' .. uniqueId }
                })
            end
        end
    )
end)

-- ✅ Ajout de l’ID unique dans le scoreboard ESX
ESX.RegisterServerCallback('uniqueid:getPlayerUniqueId', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    exports.oxmysql:scalar(
        ('SELECT %s FROM %s WHERE identifier = ?'):format(Config.Column, Config.Table),
        {xPlayer.identifier},
        function(uniqueId)
            cb(uniqueId or "N/A")
        end
    )
end)
