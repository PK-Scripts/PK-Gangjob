ESX   = nil
Gangs = nil
PlayerItems = nil
Gang = nil
loadout = nil

Keys = {
	["ESC"] = 322, ["F1"] = 288, ["F2"] = 289, ["F3"] = 170, ["F5"] = 166, ["F6"] = 167, ["F7"] = 168, ["F8"] = 169, ["F9"] = 56, ["F10"] = 57,
	["~"] = 243, ["1"] = 157, ["2"] = 158, ["3"] = 160, ["4"] = 164, ["5"] = 165, ["6"] = 159, ["7"] = 161, ["8"] = 162, ["9"] = 163, ["-"] = 84, ["="] = 83, ["BACKSPACE"] = 177,
	["TAB"] = 37, ["Q"] = 44, ["W"] = 32, ["E"] = 38, ["R"] = 45, ["T"] = 245, ["Y"] = 246, ["U"] = 303, ["P"] = 199, ["["] = 39, ["]"] = 40, ["ENTER"] = 18,
	["CAPS"] = 137, ["A"] = 34, ["S"] = 8, ["D"] = 9, ["F"] = 23, ["G"] = 47, ["H"] = 74, ["K"] = 311, ["L"] = 182,
	["LEFTSHIFT"] = 21, ["Z"] = 20, ["X"] = 73, ["C"] = 26, ["V"] = 0, ["B"] = 29, ["N"] = 249, ["M"] = 244, [","] = 82, ["."] = 81,
	["LEFTCTRL"] = 36, ["LEFTALT"] = 19, ["SPACE"] = 22, ["RIGHTCTRL"] = 70,
	["HOME"] = 213, ["PAGEUP"] = 10, ["PAGEDOWN"] = 11, ["DELETE"] = 178,
	["LEFT"] = 174, ["RIGHT"] = 175, ["TOP"] = 27, ["DOWN"] = 173,
	["NENTER"] = 201, ["N4"] = 108, ["N5"] = 60, ["N6"] = 107, ["N+"] = 96, ["N-"] = 97, ["N7"] = 117, ["N8"] = 61, ["N9"] = 118
}


Citizen.CreateThread(function()
	while ESX == nil do
		isLoggedIn = true
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end

	while ESX.GetPlayerData().job == nil do
		Citizen.Wait(10)
	end
	
	while true do
		if isLoggedIn ~= nil then
			if Gangs == nil then
				ESX.TriggerServerCallback('ct-gangjob:krijgGang', function(GangsLoad)
					Gangs = GangsLoad
					--print("done loading")
				end)
			end
		end
		if isLoggedIn and Gangs ~= nil then
			
			if PlayerItems == nil then
				ESX.TriggerServerCallback('ct-gangjob:krijgLoadout', function(loadoutsLoad)
					if loadoutsLoad.inventory ~= nil then
						PlayerItems = loadoutsLoad.inventory
					else
						PlayerItems = "{}"
					end
					--print("done loading")
				end)
			end
			if Config.ESX == "OLD" and PlayerItems == nil and loadout == nil then
				ESX.TriggerServerCallback('ct-gangjob:krijgLoadout', function(loadoutsLoad)
					if loadoutsLoad.inventory ~= nil or loadoutsLoad.weapons ~= nil then
						PlayerItems = loadoutsLoad.inventory
						loadout = loadoutsLoad.weapons
					else
						PlayerItems = "{}"
						loadout = "{}"
					end
					--print("done loading")
				end)
			end
		end
		Citizen.Wait(10)
	end

	ESX.GetPlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
	ESX.PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
	ESX.PlayerData.job = job
end)

function FormatNumber(number)
    local toreturn = ""
    if number >= 1000 then
        local string_number = string.reverse(tostring(number))
        for i = 0, #string_number - 1 do
            if i % 3 == 0 then
                toreturn = toreturn .. " "
            end
            toreturn = toreturn .. string.sub(string_number, i + 1, i + 1)
        end
    else
        return tostring(number)
    end
    toreturn = string.reverse(toreturn)
    if string.sub(toreturn, #toreturn, #toreturn) == " " then
        toreturn = string.sub(toreturn, 0, #toreturn - 1)
    end
    return toreturn
end

function DrawText3Ds(x, y, z, text)
	SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(true)
    AddTextComponentString(text)
    SetDrawOrigin(x,y,z, 0)
    DrawText(0.0, 0.0)
    local factor = (string.len(text)) / 370
    DrawRect(0.0, 0.0+0.0125, 0.017+ factor, 0.03, 0, 0, 0, 75)
    ClearDrawOrigin()
end

function KeyboardInput(TextEntry, ExampleText, MaxStringLenght)

	-- TextEntry		-->	The Text above the typing field in the black square
	-- ExampleText		-->	An Example Text, what it should say in the typing field
	-- MaxStringLenght	-->	Maximum String Lenght

	AddTextEntry('FMMC_KEY_TIP1', TextEntry) --Sets the Text above the typing field in the black square
	DisplayOnscreenKeyboard(1, "FMMC_KEY_TIP1", "", ExampleText, "", "", "", MaxStringLenght) --Actually calls the Keyboard Input
	blockinput = true --Blocks new input while typing if **blockinput** is used

	while UpdateOnscreenKeyboard() ~= 1 and UpdateOnscreenKeyboard() ~= 2 do --While typing is not aborted and not finished, this loop waits
		Citizen.Wait(0)
	end
		
	if UpdateOnscreenKeyboard() ~= 2 then
		local result = GetOnscreenKeyboardResult() --Gets the result of the typing
		Citizen.Wait(500) --Little Time Delay, so the Keyboard won't open again if you press enter to finish the typing
		blockinput = false --This unblocks new Input when typing is done
		return result --Returns the result
	else
		Citizen.Wait(500) --Little Time Delay, so the Keyboard won't open again if you press enter to finish the typing
		blockinput = false --This unblocks new Input when typing is done
		return nil --Returns nil if the typing got aborted
	end
end

RegisterNetEvent('ct-gangjob:spawnvoertuig')
AddEventHandler('ct-gangjob:spawnvoertuig', function(model)
	for k,v in pairs(Gangs) do
		local garage = json.decode(Gangs[k].garage)
		local x,y,z,heading = tonumber(garage.spawnlocation.x),tonumber(garage.spawnlocation.y),tonumber(garage.spawnlocation.z),tonumber(garage.spawnlocation.heading)
		if ESX.Game.IsSpawnPointClear(vector3(x,y,z), 2) then	
			local coords = vector3(x,y,z)
			SpawnVehicle(model,coords,heading)							
		else
			exports.pNotify:SendNotification({text = "<b>GangJob</b></br>De parkeerplaats van het voertuig is geblokkeerd!", timeout = 4000})
		end
	end

end)

RegisterNetEvent('ct-gangjob:Sync')
AddEventHandler('ct-gangjob:Sync', function(blahblahblah)
	PlayerItems = nil
	Gangs = nil
end)

RegisterNetEvent('pk-gangjob:creategang')
AddEventHandler('pk-gangjob:creategang', function(blahblahblah)
	local garage,garage_spawnpoint,garage_deletepoint,kledingkast,kluis,jobnaam
	local elements = {
        {label = "Garage", value = "garage"},
        {label = "Voertuig spawnpunt", value = "garage_spawnpoint"},
        {label = "Voertuig Deletepunt", value = "garage_deletepoint"},
        {label = "KledingKast", value = "kledingkast"},
        {label = "Gang Kluis", value = "kluis"},
		{label = "Job naam", value = "jobnaam"},
        {label = "Maak", value = "maak"}
    }

    ESX.UI.Menu.Open("default", GetCurrentResourceName(), "creator", {
        title = "Gangjob aanmaken",
        align = 'top-right',
        elements = elements
    }, function(data, menu)
        local action = data.current.value
    
        if action == "garage" then
			garage = GetEntityCoords(PlayerPedId())
			ESX.ShowNotification("Done!")
        elseif action == "garage_spawnpoint" then
			garage_spawnpoint = GetEntityCoords(PlayerPedId())
			ESX.ShowNotification("Done!")
        elseif action == "garage_deletepoint" then
			garage_deletepoint = GetEntityCoords(PlayerPedId())
			ESX.ShowNotification("Done!")
        elseif action == "kledingkast" then
			kledingkast = GetEntityCoords(PlayerPedId())
			ESX.ShowNotification("Done!")
		elseif action == "kluis" then
			kluis = GetEntityCoords(PlayerPedId())
			ESX.ShowNotification("Done!")
		elseif action == "jobnaam" then
			local jobname = KeyboardInput("Voer De Amount in", "", 100)
			jobnaam = jobname
        elseif action == "maak" then
            if garage and garage_spawnpoint and garage_deletepoint and kledingkast and kluis and jobnaam then
                garagetable = {garagemenu = garage, spawnlocation = garage_spawnpoint, deletepoint = garage_deletepoint}
				TriggerServerEvent('pk-gangjob:maaktgangjob', garagetable, kledingkast,kluis,jobnaam)
				ESX.ShowNotification("Je hebt een gangjob gemaakt")
            else
                ESX.ShowNotification("Je moet wel alles hebben gedaan")
            end
        end
    end, function(data, menu)
        menu.close()
    end)
end)

RegisterNetEvent('ct-gangjob:leg')
AddEventHandler('ct-gangjob:leg', function(item)
	local amount = KeyboardInput("Voer De Amount in", "", 10)
	TriggerServerEvent('ct-gangjob:leg1', item, amount, Gangs[Gang].gang, Gang)
	exports.rprogress:Custom({
		Duration = 2500,
		Label = "Spullen opslaan...",
		Animation = {
			scenario = "PROP_HUMAN_BUM_BIN", -- https://pastebin.com/6mrYTdQv
			animationDictionary = "idle_a", -- https://alexguirre.github.io/animations-list/
		},
		DisableControls = {
			Mouse = false,
			Player = true,
			Vehicle = true
		}
	})
end)

RegisterNetEvent('ct-gangjob:krijg')
AddEventHandler('ct-gangjob:krijg', function(item)
	local amount = KeyboardInput("Voer De Amount in", "", 10)
	TriggerServerEvent('ct-gangjob:krijg1', item, amount, Gangs[Gang].gang, Gang)
	exports.rprogress:Custom({
		Duration = 2500,
		Label = "Spullen opslaan...",
		Animation = {
			scenario = "PROP_HUMAN_BUM_BIN", -- https://pastebin.com/6mrYTdQv
			animationDictionary = "idle_a", -- https://alexguirre.github.io/animations-list/
		},
		DisableControls = {
			Mouse = false,
			Player = true,
			Vehicle = true
		}
	})
end)

RegisterNetEvent('ct-gangjob:setgangkleding')
AddEventHandler('ct-gangjob:setgangkleding', function()
	ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
		for k,v in pairs(Gangs) do
			if v.gang == ESX.PlayerData.job.name then
				if skin.sex == 0 then
					skintable = {male = skin, female = json.decode(Gangs[k].kleding).female}
					skin1 = json.encode(skintable)
					TriggerServerEvent('ct-gangjob:setskingang', skin1, v.gang)
				elseif skin.sex == 1 then
					skintable = {male = json.decode(Gangs[k].kleding).male, female = skin}
					skin1 = json.encode(skintable)
					TriggerServerEvent('ct-gangjob:setskingang', skin1, v.gang)
				end
			end
		end
		exports.pNotify:SendNotification({text = '<b>Gangjob</b></br>Je hebt de Gang kleding aan gedaan!', timeout = 4000})
	end)
end)

RegisterNetEvent('ct-gangjob:gangkleding')
AddEventHandler('ct-gangjob:gangkleding', function()
	ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin, jobSkin)
		for k,v in pairs(Gangs) do
			if v.gang == ESX.PlayerData.job.name then
				if skin.sex == 0 then
					TriggerEvent('skinchanger:loadClothes', skin, json.decode(Gangs[k].kleding).male)
				elseif skin.sex == 1 then
					TriggerEvent('skinchanger:loadClothes', skin, json.decode(Gangs[k].kleding).female)
				end
			end
		end
		exports.pNotify:SendNotification({text = '<b>Gangjob</b></br>Je hebt de Gang kleding aan gedaan!', timeout = 4000})
	end)
end)

RegisterNetEvent('ct-gangjob:burgerkleding')
AddEventHandler('ct-gangjob:burgerkleding', function(item)
	ESX.TriggerServerCallback('esx_skin:getPlayerSkin', function(skin)
		TriggerEvent('skinchanger:loadSkin', skin)
		exports.pNotify:SendNotification({text = '<b>Gangjob</b></br>Je hebt je eige kleding aan!', timeout = 4000})
	end)
end)

function SpawnVehicle(model,coords,heading)
	Wait(1500)
	ESX.Game.SpawnVehicle(model, coords, heading, function(vehicle)
		TaskWarpPedIntoVehicle(GetPlayerPed(-1), vehicle, -1)  
		exports.pNotify:SendNotification({text = "<b>GangJob</b></br>De auto staat er.", timeout = 5500})
	end)
end

function OpenGarage()
	exports['br-menu']:SetTitle("Voertuig lijst")
	for k,v in pairs(Gangs) do
		for index,value in pairs(Config.Garage) do
			if v.gang == Config.Garage[index].gang then
				if Config.Garage[index].job_grade == -1 then
					exports['br-menu']:AddButton(Config.Garage[index].label , "",'ct-gangjob:spawnvoertuig' ,Config.Garage[index].value ,"legmenu")
				elseif ESX.PlayerData.job.grade >= Config.Garage[index].job_grade then
					exports['br-menu']:AddButton(Config.Garage[index].label , "",'ct-gangjob:spawnvoertuig' ,Config.Garage[index].value ,"legmenu")
				end
			end
		end
	end
end

function OpenKluis()
	if Config.UseMenu == "br-menu" then
		exports['br-menu']:SetTitle("Gang Kluis")
		for k,v in pairs(PlayerItems) do
			exports['br-menu']:AddButton(v.label , "count: " .. FormatNumber(v.count) ,'ct-gangjob:leg' ,v.name ,"legmenu")
		end
		for k,v in pairs(json.decode(Gangs[Gang].stash)) do
			exports['br-menu']:AddButton(v.label , "count: " .. FormatNumber(v.count) ,'ct-gangjob:krijg' ,v.name ,"krijgmenu")
		end
		exports['br-menu']:SubMenu("Leg" , "Leg je spullen in de Gang kluis" , "legmenu" )
		exports['br-menu']:SubMenu("Pak" , "Krijg spullen die in de Gang kluis zitten" , "krijgmenu" )

	elseif Config.UseMenu == "linden" then
		exports['linden_inventory']:OpenStash({owner = "Gang"..Gang, id = "Gang"..Gang, label = "Gang"..Gang, slots = 200})
	end
end

function OpenWapenKluis()
	if Config.UseMenu == "br-menu" then
		exports['br-menu']:SetTitle("Gang WapenKluis")
		for k,v in pairs(loadout) do
			exports['br-menu']:AddButton(v.label , "count: " .. FormatNumber(v.count) ,'ct-gangjob:leg' ,v.name ,"legmenu")
		end
		for k,v in pairs(json.decode(Gangs[Gang].stash)) do
			exports['br-menu']:AddButton(v.label , "count: " .. FormatNumber(v.count) ,'ct-gangjob:krijg' ,v.name ,"krijgmenu")
		end
		exports['br-menu']:SubMenu("Leg" , "Leg je spullen in de Gang kluis" , "legmenu" )
		exports['br-menu']:SubMenu("Pak" , "Krijg spullen die in de Gang kluis zitten" , "krijgmenu" )

	elseif Config.UseMenu == "linden" then
		exports['linden_inventory']:OpenStash({owner = "Gang"..Gang, id = "Gang"..Gang, label = "Gang"..Gang, slots = 200})
	end
end

function OpenKledingKast()
	exports['br-menu']:SetTitle("Gang Kleding Kast")
	exports['br-menu']:AddButton("Gang Kleding" , "Dit is de Gang kleding van de Gang" ,'ct-gangjob:gangkleding' , "" ,"legmenu")
	exports['br-menu']:AddButton("Burger Kleding" , "Je eige Kleding" ,'ct-gangjob:burgerkleding' , "" ,"krijgmenu")
	for k,v in pairs(Gangs) do
		if ESX.PlayerData.job.grade_name == "boss" then
			exports['br-menu']:AddButton("Set Gang Kleding" , "Set Gang Kleding" ,'ct-gangjob:setgangkleding' , "" ,"krijgmenu")
		end
	end
end

function HasHandsupOrIsCuffed(ped)
	if (IsEntityPlayingAnim(ped, 'random@mugging3', 'handsup_standing_base', 3)) or IsEntityPlayingAnim(ped, 'mp_arresting', 'idle', 3) or IsEntityPlayingAnim(ped, 'missminuteman_1ig_2', 'handsup_base', 3) then return true end
	return false
end

function OpenActionMenu(gang)
	ESX.UI.Menu.CloseAll()

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), gang..'_actions', {
		title    = gang,
		align    = 'top-left',
		elements = {
			{label = _U('citizen_interaction'), value = 'citizen_interaction'},
	}}, function(data, menu)
		if data.current.value == 'citizen_interaction' then
			local elements = {
				{label = _U('search'), value = 'search'},
				{label = _U('handcuff'), value = 'handcuff'},
				{label = _U('drag'), value = 'drag'},
				{label = _U('put_in_vehicle'), value = 'put_in_vehicle'},
				{label = _U('out_the_vehicle'), value = 'out_the_vehicle'},
			}

			if Config.EnableLicenses then
				table.insert(elements, {label = _U('license_check'), value = 'license'})
			end

			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'citizen_interaction', {
				title    = _U('citizen_interaction'),
				align    = 'top-left',
				elements = elements
			}, function(data2, menu2)
				local closestPlayer, closestDistance = ESX.Game.GetClosestPlayer()
				if closestPlayer ~= -1 and closestDistance <= 3.0 then
					local action = data2.current.value

					if action == 'search' then
						if HasHandsupOrIsCuffed(GetPlayerPed(closestPlayer)) then
							if closestDistance <= 1 then
								OpenBodySearchMenu(closestPlayer)
							end
						end
					elseif action == 'handcuff' then	
						if HasHandsupOrIsCuffed(GetPlayerPed(closestPlayer)) then
							if closestDistance <= 1 then
								TriggerServerEvent('esx_policejob:handcuff', GetPlayerServerId(closestPlayer))
							end
						end
					elseif action == 'drag' then
						TriggerServerEvent('esx_policejob:drag', GetPlayerServerId(closestPlayer))
					elseif action == 'put_in_vehicle' then
						TriggerServerEvent('esx_policejob:putInVehicle', GetPlayerServerId(closestPlayer))
					elseif action == 'out_the_vehicle' then
						TriggerServerEvent('esx_policejob:OutVehicle', GetPlayerServerId(closestPlayer))
					end
				else
					ESX.ShowNotification(_U('no_players_nearby'))
				end
			end, function(data2, menu2)
				menu2.close()
			end)
		end
	end, function(data, menu)
		menu.close()
	end)
end

function OpenBodySearchMenu(player)
	ESX.TriggerServerCallback('pk-gangjob:krijgAndereInventory', function(data)
		local elements = {}

		for i=1, #data.accounts, 1 do
			if data.accounts[i].name == 'black_money' and data.accounts[i].money > 0 then
				table.insert(elements, {
					label    = _U('confiscate_dirty', ESX.Math.Round(data.accounts[i].money)),
					value    = 'black_money',
					itemType = 'item_account',
					amount   = data.accounts[i].money
				})

				break
			end
		end

		table.insert(elements, {label = _U('guns_label')})

		for i=1, #data.weapons, 1 do
			table.insert(elements, {
				label    = _U('confiscate_weapon', ESX.GetWeaponLabel(data.weapons[i].name), data.weapons[i].ammo),
				value    = data.weapons[i].name,
				itemType = 'item_weapon',
				amount   = data.weapons[i].ammo
			})
		end

		table.insert(elements, {label = _U('inventory_label')})

		for i=1, #data.inventory, 1 do
			if data.inventory[i].count > 0 then
				table.insert(elements, {
					label    = _U('confiscate_inv', data.inventory[i].count, data.inventory[i].label),
					value    = data.inventory[i].name,
					itemType = 'item_standard',
					amount   = data.inventory[i].count
				})
			end
		end

		ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'body_search', {
			title    = _U('search'),
			align    = 'top-left',
			elements = elements
		}, function(data, menu)
			if data.current.value then
				TriggerServerEvent('pk-gangjob:pakSpelerItem', GetPlayerServerId(player), data.current.itemType, data.current.value, data.current.amount)
				menu.close()
			end
		end, function(data, menu)
			menu.close()
		end)
	end, GetPlayerServerId(player))
end

Citizen.CreateThread(function()
	while true do
		if Gangs ~= nil and isLoggedIn then
			local pos = GetEntityCoords(GetPlayerPed(-1), true)
			for k,v in pairs(Gangs) do
				if v.gang == ESX.PlayerData.job.name then
					Gang = k
					local veh = GetVehiclePedIsIn(GetPlayerPed(-1), false)
					local garage = json.decode(Gangs[k].garage)
					local kluis = json.decode(Gangs[k].kluis)
					local wapenkluis = json.decode(Gangs[k].wapenkluis)
					local kledingkast = json.decode(Gangs[k].kledingkast)
					local xgarage,ygarage,zgarage = tonumber(garage.garagemenu.x),tonumber(garage.garagemenu.y),tonumber(garage.garagemenu.z)
					local DistanceBetweenGarage = GetDistanceBetweenCoords(pos, xgarage,ygarage,zgarage, true)
					local xkluis,ykluis,zkluis = tonumber(kluis.x),tonumber(kluis.y),tonumber(kluis.z)
					local DistanceBetweenKluis = GetDistanceBetweenCoords(pos, xkluis,ykluis,zkluis, true)
					local xkledingkast,ykledingkast,zkledingkast = tonumber(kledingkast.x),tonumber(kledingkast.y),tonumber(kledingkast.z)
					local DistanceBetweenKledingKast = GetDistanceBetweenCoords(pos, xkledingkast,ykledingkast,zkledingkast, true)
					if Config.ESX == "OLD" then
						local xwapenkluis,ywapenkluis,zwapenkluis = tonumber(wapenkluis.x),tonumber(wapenkluis.y),tonumber(wapenkluis.z)
					end
					local DistanceBetweenWapenKluis = GetDistanceBetweenCoords(pos, xwapenkluis,ywapenkluis,zwapenkluis, true)
					local xdeletepoint,ydeletepoint,zdeletepoint = tonumber(garage.deletepoint.x),tonumber(garage.deletepoint.y),tonumber(garage.deletepoint.z)
					local DistanceBetweenGarageDeletePoint = GetDistanceBetweenCoords(pos, xdeletepoint,ydeletepoint,zdeletepoint, true)
					if IsControlJustPressed(0, Keys["F6"]) then
						OpenActionMenu(v.gang)
					end
					if DistanceBetweenGarage < 2.5 or DistanceBetweenKluis < 2.5 or DistanceBetweenKledingKast < 2.5 or DistanceBetweenWapenKluis < 2.5 or DistanceBetweenGarageDeletePoint < 2.5 then
						if DistanceBetweenGarage < 2.5 and not IsPedInVehicle(GetPlayerPed(-1), veh) then
							DrawText3Ds(xgarage,ygarage,zgarage, '~b~E~w~ - Gang Garage')
							if DistanceBetweenGarage < 1 and not IsPedInVehicle(GetPlayerPed(-1), veh) then
								if IsControlJustPressed(0, Keys["E"]) then
									OpenGarage()
								end
							end
						end
						if DistanceBetweenKluis < 2.5 and not IsPedInVehicle(GetPlayerPed(-1), veh) then
							DrawText3Ds(xkluis,ykluis,zkluis, '~b~E~w~ - Gang Kluis')
							if DistanceBetweenKluis < 1 and not IsPedInVehicle(GetPlayerPed(-1), veh) then
								if IsControlJustPressed(0, Keys["E"]) then
									OpenKluis()
								end
							end
						end
						if DistanceBetweenKledingKast < 2.5 and not IsPedInVehicle(GetPlayerPed(-1), veh) then
							DrawText3Ds(xkledingkast,ykledingkast,zkledingkast, '~b~E~w~ - Gang Kledingkast')
							if DistanceBetweenKledingKast < 1 and not IsPedInVehicle(GetPlayerPed(-1), veh) then
								if IsControlJustPressed(0, Keys["E"]) then
									OpenKledingKast()
								end
							end
						end
						if Config.ESX == "OLD" then
							if DistanceBetweenWapenKluis < 2.5 and not IsPedInVehicle(GetPlayerPed(-1), veh) then
								DrawText3Ds(xwapenkluis,ywapenkluis,zwapenkluis, '~b~E~w~ - Wapen Kluis')
								if DistanceBetweenWapenKluis < 1 and not IsPedInVehicle(GetPlayerPed(-1), veh) then
									if IsControlJustPressed(0, Keys["E"]) then
										OpenWapenKluis()
									end
								end
							end
						end
						if DistanceBetweenGarageDeletePoint < 2.5 and IsPedInVehicle(GetPlayerPed(-1), veh) then
							DrawText3Ds(xdeletepoint, ydeletepoint, zdeletepoint, '~b~E~w~ - Zet voertuig in garage')
							if DistanceBetweenGarageDeletePoint < 1 and IsPedInVehicle(GetPlayerPed(-1), veh) then
								if IsControlJustPressed(0, Keys["E"]) then
									ESX.Game.DeleteVehicle(veh)
								end
							end
						end
					else
						Wait(1000)
					end
				end
			end
		else
			Citizen.Wait(100)
		end
		Citizen.Wait(10)
	end
end)