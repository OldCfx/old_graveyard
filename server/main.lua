local resourcePath = GetResourcePath(GetCurrentResourceName())
local dataFile = resourcePath .. '/shared/data.json'


local function loadData()
    local f = io.open(dataFile, 'r')
    if not f then
        return {}
    end
    local content = f:read('*a')
    f:close()
    local ok, result = pcall(function() return json.decode(content) end)
    if ok and result then return result else return {} end
end

local function saveData(data)
    local f, err = io.open(dataFile, 'w+')
    if not f then
        return
    end
    f:write(json.encode(data, { indent = true }))
    f:close()
end


RegisterNetEvent('old_graveyard:addGrave', function(grave)
    if not grave then return end
    local graves = loadData()


    grave.id = (#graves > 0) and (graves[#graves].id + 1) or 1

    table.insert(graves, grave)
    saveData(graves)

    TriggerClientEvent('old_graveyard:updateGraves', -1, grave)
end)

lib.callback.register('old_graveyard:getGraves', function()
    return loadData()
end)



lib.addCommand('addgrave', {
    help = 'Créer une nouvelle tombe',
    restricted = Config.restrictedCommand
}, function(source)
    TriggerClientEvent('old_graveyard:openGraveDialog', source)
end)



lib.addCommand('delgrave', {
    help = 'Supprime une tombe par ID',
    restricted = Config.restrictedCommand,
    params = {
        {
            name = 'target',
            type = 'number',
            help = 'id de la tombe',
        },
    },
}, function(source, args)
    local id = tonumber(args.target)
    if not id then
        lib.notify(source, { title = 'Erreur', description = 'Vous devez spécifier un ID valide.', type = 'error' })
        return
    end

    local graves = loadData()
    local found = false

    for i, g in ipairs(graves) do
        if g.id == id then
            found = true
            table.remove(graves, i)
            break
        end
    end

    if found then
        saveData(graves)
        lib.notify(source,
            { title = 'Suppression', description = 'Tombe # ' .. id .. ' supprimée avec succès.', type = 'success' })

        TriggerClientEvent('old_graveyard:removeGrave', -1, id)
    else
        lib.notify(source, { title = 'Introuvable', description = 'Aucune tombe avec l\'ID ' .. id, type = 'error' })
    end
end)
