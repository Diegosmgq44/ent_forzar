function getStreetandZone(coords)
	local zone = GetLabelText(GetNameOfZone(coords.x, coords.y, coords.z))
	local currentStreetHash = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
	currentStreetName = GetStreetNameFromHashKey(currentStreetHash)
	playerStreetsLocation = currentStreetName .. ", " .. zone
	return playerStreetsLocation
end

function GetAllPeds()
	local getPeds = {}
	local findHandle, foundPed = FindFirstPed()
	local continueFind = (foundPed and true or false)
	local count = 0
	while continueFind do
		local pedCoords = GetEntityCoords(foundPed)
		if GetPedType(foundPed) ~= 28 and not IsEntityDead(foundPed) and not IsPedAPlayer(foundPed) and #(playerCoords - pedCoords) < 80.0 then
			getPeds[#getPeds + 1] = foundPed
			count = count + 1
		end
		continueFind, foundPed = FindNextPed(findHandle)
	end
	EndFindPed(findHandle)
	return count
end

function createBlip(data)
	Citizen.CreateThread(function()
		local alpha, blip = 255
		local sprite, colour, scale = 161, 84, 1.0
		if data.sprite then sprite = data.sprite end
		if data.colour then colour = data.colour end
		if data.scale then scale = data.scale end
		local entId = NetworkGetEntityFromNetworkId(data.netId)
		if data.netId and entId > 0 then
			blip = AddBlipForEntity(entId)
			SetBlipSprite(blip, sprite)
			SetBlipHighDetail(blip, true)
			SetBlipScale(blip, scale)
			SetBlipColour(blip, colour)
			SetBlipAlpha(blip, alpha)
			SetBlipAsShortRange(blip, false)
			SetBlipCategory(blip, 2)
			BeginTextCommandSetBlipName('STRING')
			AddTextComponentString(data.displayCode..' - '..data.dispatchMessage)
			EndTextCommandSetBlipName(blip)
			Citizen.Wait(data.length)
			RemoveBlip(blip)
			Citizen.Wait(0)
			blip = AddBlipForCoord(GetEntityCoords(entId))
		else
			data.netId = nil
			blip = AddBlipForCoord(data.coords.x, data.coords.y, data.coords.z)
		end
		SetBlipSprite(blip, sprite)
		SetBlipHighDetail(blip, true)
		SetBlipScale(blip, scale)
		SetBlipColour(blip, colour)
		SetBlipAlpha(blip, alpha)
		SetBlipAsShortRange(blip, true)
		SetBlipCategory(blip, 2)
		BeginTextCommandSetBlipName('STRING')
		AddTextComponentString(data.displayCode..' - '..data.dispatchMessage)
		EndTextCommandSetBlipName(blip)
		while alpha ~= 0 do
			if data.netId then Citizen.Wait((data.length / 1000) * 5) else Citizen.Wait((data.length / 1000) * 20) end
			alpha = alpha - 1
			SetBlipAlpha(blip, alpha)
			if alpha == 0 then
				RemoveBlip(blip)
				return
			end
		end
	end)
end

RegisterNetEvent('wf-alerts:clNotify')
AddEventHandler('wf-alerts:clNotify', function(pData, isPolice)
	if pData ~= nil then
		if isPolice then
			Citizen.Wait(1500)
			if not pData.length then pData.length = 4000 end
			pData.street = getStreetandZone(vector3(pData.coords.x, pData.coords.y, pData.coords.z))
			SendNUIMessage({action = 'display', info = pData, job = ESX.PlayerData.job.name, length = pData.length})
			PlaySound(-1, "Event_Message_Purple", "GTAO_FM_Events_Soundset", 0, 0, 1)
			waypoint = vector2(pData.coords.x, pData.coords.y)
			createBlip(pData)
			Citizen.Wait(pData.length+2000)
			waypoint = nil
		end
	end
end)

RegisterCommand('alert_gps', function()
	if waypoint then SetWaypointOff() SetNewWaypoint(waypoint.x, waypoint.y) end
end, false)

RegisterKeyMapping('alert_gps', 'Set waypoint', 'keyboard', 'Y')

Citizen.CreateThread(function()
	while notLoaded do Citizen.Wait(0) end
	while true do
		Citizen.Wait(0)
		playerCoords = GetEntityCoords(PlayerPedId())
		if currentStreetName then lastStreet = currentStreetName end
		local currentStreetHash = GetStreetNameAtCoord(playerCoords.x, playerCoords.y, playerCoords.z)
		currentStreetName = GetStreetNameFromHashKey(currentStreetHash)
		nearbyPeds = GetAllPeds()
		Citizen.Wait(500)
	end
end)

-- Comando para mandar un forzar
RegisterCommand('forzar', function(playerId, args, rawCommand)
	local playername = GetPlayerName(PlayerId())
    local ped = GetPlayerPed(PlayerId())
    local x, y, z = table.unpack(GetEntityCoords(ped, true))
    local street = GetStreetNameAtCoord(x, y, z)
    local location = GetStreetNameFromHashKey(street)
    local inVehicle = IsPedInAnyVehicle(ped, false)
    local model = GetEntityModel(veh)
    local vehicleModel = GetEntityModel(GetVehiclePedIsIn(PlayerPedId()))
    local vehiculo = GetVehiclePedIsIn(ped)
    local primary = GetVehicleColours(vehiculo)
    primary = Config.colorNames[tostring(primary)]
    local modelo = GetDisplayNameFromVehicleModel(vehicleModel)
    local matricula = GetVehicleNumberPlateText(vehiculo)
	local message
	if not inVehicle then
		TriggerEvent('chatMessage', '[^1FORZAR^0]', {255,255,255}, 'No estás en ningún vehiculo.')
	else
		message = 'Robo de vehiculo en ' .. location .. ', Modelo: ' .. modelo .. ', Color: ' .. primary .. ', Matricula: ' .. matricula .. '.'
		TriggerEvent('chatMessage', '[^1FORZAR^0]', {255,255,255}, 'Se ha enviado una alerta.')
	end
	TriggerServerEvent('wf-alerts:svNotify911', message, _U('caller_unknown'), playerCoords, false)
end, false)

-- Comando para mandar entorno
RegisterCommand('entorno', function(playerId, args, rawCommand)
	if not args[1] then
		exports['mythic_notify']:SendAlert('error', 'You must include a message with your 911 call')
		return 
	end
	args = table.concat(args, ' ')
	TriggerServerEvent('wf-alerts:svNotify911', args, _U('caller_unknown'), playerCoords, true)
	TriggerEvent('chatMessage', '[^1ENTORNO^0]', {255,255,255}, 'Se ha enviado un entorno')
end, false)
