ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('diegosmgq44_outlawalert:getCharData', function(source, cb)
	local xPlayer = ESX.GetPlayerFromId(source)
	if not xPlayer then return end

	local identifier = xPlayer.getIdentifier()
	MySQL.Async.fetchAll('SELECT firstname, lastname, phone_number FROM users WHERE identifier = @identifier', {
		['@identifier'] = identifier
	}, function(results)
		cb(results[1])
	end)
end)

RegisterServerEvent('wf-alerts:svNotify911')
AddEventHandler('wf-alerts:svNotify911', function(message, caller, coords, isEntorno)
	if message ~= nil then
		local pData = {}
		if isEntorno then
			pData.displayCode = 'Entorno'
		else
			pData.displayCode = 'Forzar'
		end
		if caller == _U('caller_unknown') then pData.dispatchMessage = _U('unknown_caller') else
		pData.dispatchMessage = _U('call_from') .. caller end
		pData.recipientList = {'police'}
		pData.length = 13000
		pData.infoM = 'fa-phone'
		pData.info = message
		pData.coords = vector3(coords.x, coords.y, coords.z)
		pData.sprite, pData.colour, pData.scale =  189, 84, 1.5 -- radar_vip, blue
    	local xPlayers = ESX.GetPlayers()
		for i= 1, #xPlayers do
			local source = xPlayers[i]
			local xPlayer = ESX.GetPlayerFromId(source)
			if xPlayer.job.name == 'police' then
				TriggerClientEvent('wf-alerts:clNotify', source, pData, true)
			end
		end
		TriggerEvent('mdt:newCall', message, caller, vector3(coords.x, coords.y, coords.z), false)
	end
end)

RegisterServerEvent('enp-entorno:forzar:sendNotify')
AddEventHandler('enp-entorno:forzar:sendNotify', function( modelo, primary, matricula, location  )
	TriggerClientEvent('enp-entorno:forzar:sendNotify', -1, modelo, primary, matricula, location  )
end, false)
