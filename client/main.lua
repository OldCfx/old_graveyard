local graves = {}
local canPressE, closestGrave = false, nil


CreateThread(function()
    graves = lib.callback.await('old_graveyard:getGraves', false)
end)


RegisterNetEvent('old_graveyard:updateGraves', function(newGrave)
    table.insert(graves, newGrave)
end)


RegisterNetEvent('old_graveyard:removeGrave', function(id)
    for i, g in ipairs(graves) do
        if g.id == id then
            table.remove(graves, i)
            lib.notify({
                title = 'Mise à jour',
                description = 'Tombe #' .. id .. ' retirée du cimetière.',
                type =
                'inform'
            })
            return
        end
    end
end)


RegisterNetEvent('old_graveyard:openGraveDialog', function()
    local input = lib.inputDialog('Nouvelle Tombe', {
        { type = 'input', label = 'Nom & Prénom',          placeholder = 'ex: Blunt Cfx',                    required = true },
        {
            type = 'date',
            label = 'Date de naissance',
            description = 'Sélectionnez la date de naissance du défunt.',
            icon = 'cake-candles',
            required = true,
            default = true,
            format = 'DD/MM/YYYY',
            returnString = true,
            clearable = true,

        },

        {
            type = 'date',
            label = 'Date de décès',
            description = 'Sélectionnez la date du décès.',
            icon = 'skull-crossbones',
            required = true,
            default = true,
            format = 'DD/MM/YYYY',
            returnString = true,
            clearable = true,

        },
        { type = 'input', label = 'Cause du décès',        placeholder = 'ex: Accident de montgolfière',     required = true },
        { type = 'input', label = 'Photo (URL .png/.jpg)', placeholder = 'ex: https://exemple.com/photo.png' }
    })

    if not input then
        lib.notify({ title = 'Annulé', description = 'Aucune tombe n’a été créée.', type = 'error' })
        return
    end

    local name, birth, death, cause, photo = table.unpack(input)
    local coords = GetEntityCoords(PlayerPedId())

    local grave = {
        name = name,
        birth = birth,
        death = death,
        cause = cause,
        photo = photo,
        coords = { x = coords.x, y = coords.y, z = coords.z }
    }

    TriggerServerEvent('old_graveyard:addGrave', grave)
    lib.notify({ title = 'Tombe ajoutée', description = 'Nouvelle tombe enregistrée pour ' .. name, type = 'success' })
end)


CreateThread(function()
    while true do
        Wait(0)
        local pCoords = GetEntityCoords(PlayerPedId())
        canPressE = false
        closestGrave = nil

        for _, grave in pairs(graves) do
            local pos = vec3(grave.coords.x, grave.coords.y, grave.coords.z)
            local dist = #(pCoords - pos)

            if dist < Config.DrawDistance then
                DrawMarker(Config.MarkerType, pos.x, pos.y, pos.z - 1.0, 0.0, 0.0, 0.0, 0, 0, 0,
                    0.6, 0.6, 0.6,
                    Config.MarkerColor.r, Config.MarkerColor.g,
                    Config.MarkerColor.b, Config.MarkerColor.a,
                    false, true)
            end

            if dist < Config.InteractDistance then
                canPressE = true
                closestGrave = grave
                lib.showTextUI('[E] - Lire la stèle', {
                    icon = 'fa-eye',
                })
            end
        end

        if not canPressE then
            lib.hideTextUI()
        end
    end
end)


CreateThread(function()
    while true do
        Wait(0)
        if canPressE and IsControlJustReleased(0, 38) and closestGrave then
            lib.hideTextUI()

            print("Tombe id :" .. closestGrave.id)
            local msg = string.format([[

**Nom :** %s

**Naissance :** %s

**Décès :** %s

**Cause du décès :** %s

%s
]],
                closestGrave.name or "Inconnu",
                closestGrave.birth or "?",
                closestGrave.death or "?",
                closestGrave.cause or "Aucune information",
                (closestGrave.photo and closestGrave.photo ~= "" and
                    string.format("![photo](%s)", closestGrave.photo)) or ""
            )

            local result = lib.alertDialog({
                header = '🕯️ Ici repose ' .. (closestGrave.name or "Quelqu’un"),
                content = msg,
                centered = true,
                cancel = true,
                size = 'md',
                labels = { confirm = 'Fermer', cancel = 'Jeter une rose' },
            })

            if result == 'cancel' then
                lib.progressCircle({
                    duration = 1300,
                    position = 'bottom',
                    useWhileDead = false,
                    canCancel = true,
                    disable = {
                        car = true,
                    },
                    anim = {
                        dict = 'anim@heists@narcotics@trash',
                        clip = 'throw_ranged_side_e'
                    },
                    prop = {
                        model = `prop_single_rose`,
                        bone = 64097,
                        pos = vector3(0, 0, 0),
                        rot = vector3(0, 0, 0)
                    },
                })
            end
        end
    end
end)
