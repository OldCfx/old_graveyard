local textUi = false
local graves = {}
local gravePoints = {}
local activePoint = nil

CreateThread(function()
    createGraves()
end)

function clearGravePoints()
    for _, point in pairs(gravePoints) do
        point:remove()
    end
    gravePoints = {}
end

function createGraves()
    clearGravePoints()

    graves = lib.callback.await('old_graveyard:getGraves', false)
    if not graves then return end

    for _, grave in pairs(graves) do
        local point = lib.points.new({
            coords = vec3(grave.coords.x, grave.coords.y, grave.coords.z),
            distance = Config.DrawDistance,
            grave = grave
        })

        function point:nearby()
            DrawMarker(
                Config.MarkerType,
                self.coords.x, self.coords.y, self.coords.z - 1.0,
                0.0, 0.0, 0.0,
                0, 0, 0,
                0.6, 0.6, 0.6,
                Config.MarkerColor.r,
                Config.MarkerColor.g,
                Config.MarkerColor.b,
                Config.MarkerColor.a,
                false, true
            )

            if self.currentDistance < Config.InteractDistance then
                if activePoint ~= self then
                    activePoint = self
                    if not textUi then
                        textUi = true
                        lib.showTextUI('[E] - Lire la stèle', { icon = 'fa-eye' })
                    end
                end

                if IsControlJustReleased(0, 38) then
                    openGraveDialog(self.grave)
                end
            else
                if activePoint == self then
                    activePoint = nil
                    if textUi then
                        textUi = false
                        lib.hideTextUI()
                    end
                end
            end
        end

        table.insert(gravePoints, point)
    end
end

function openGraveDialog(grave)
    local msg = string.format([[
**Nom :** %s

**Naissance :** %s

**Décès :** %s

**Cause du décès :** %s

%s
]],
        grave.name or "Inconnu",
        grave.birth or "?",
        grave.death or "?",
        grave.cause or "Aucune information",
        (grave.photo and grave.photo ~= "" and string.format("![photo](%s)", grave.photo)) or ""
    )

    local result = lib.alertDialog({
        header = '🕯️ Ici repose ' .. (grave.name or "Quelqu’un"),
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
            disable = { car = true },
            anim = {
                dict = 'anim@heists@narcotics@trash',
                clip = 'throw_ranged_side_e'
            },
            prop = {
                model = `prop_single_rose`,
                bone = 64097,
                pos = vec3(0, 0, 0),
                rot = vec3(0, 0, 0)
            },
        })
    end
end

RegisterNetEvent('old_graveyard:updateGraves', function()
    createGraves()
end)

RegisterNetEvent('old_graveyard:removeGrave', function(id)
    for i, g in ipairs(graves) do
        if g.id == id then
            table.remove(graves, i)
            createGraves()
            lib.notify({
                title = 'Mise à jour',
                description = 'Tombe #' .. id .. ' retirée.',
                type = 'inform'
            })
            return
        end
    end
end)

RegisterNetEvent('old_graveyard:openGraveDialog', function()
    local input = lib.inputDialog('Nouvelle Tombe',
        { { type = 'input', label = 'Nom & Prénom', placeholder = 'ex: Blunt Cfx', required = true }, { type = 'date', label = 'Date de naissance', description = 'Sélectionnez la date de naissance du défunt.', icon = 'cake-candles', required = true, default = true, format = 'DD/MM/YYYY', returnString = true, clearable = true, }, { type = 'date', label = 'Date de décès', description = 'Sélectionnez la date du décès.', icon = 'skull-crossbones', required = true, default = true, format = 'DD/MM/YYYY', returnString = true, clearable = true, }, { type = 'input', label = 'Cause du décès', placeholder = 'ex: Accident de montgolfière', required = true }, { type = 'input', label = 'Photo (URL .png/.jpg)', placeholder = 'ex: https://exemple.com/photo.png' } })
    if not input then
        lib.notify({ title = 'Annulé', description = 'Aucune tombe n’a été créée.', type = 'error' })
        return
    end
    local name, birth, death, cause, photo = table.unpack(input)
    local coords = GetEntityCoords(PlayerPedId())
    local grave = { name = name, birth = birth, death = death, cause = cause, photo = photo, coords = { x = coords.x, y = coords.y, z = coords.z } }
    TriggerServerEvent('old_graveyard:addGrave', grave)
    lib.notify({ title = 'Tombe ajoutée', description = 'Nouvelle tombe enregistrée pour ' .. name, type = 'success' })
end)
