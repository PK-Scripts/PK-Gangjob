ESX = nil

Gang = {}

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

MySQL.ready(function()
    KrijgGangs()
end)

function KrijgGangs()
    local xPlayer = ESX.GetPlayerFromId(source)
	Gang = {}
	MySQL.Async.fetchAll("SELECT * FROM `pk_gangjob`", {}, function(result)
        if result and #result > 0 then
            Gang = result
        end
    end)
end

table.indexOf = function ( tab, value )
  for index, val in ipairs(tab) do
    if value == val then
      return index
    end
  end
      return -1
end

function refreshlabsclient(something)
	Wait(20)
	TriggerClientEvent('ct-gangjob:Sync', -1)
end

if ESX.RegisterCommand == nil then
	TriggerEvent('es:addGroupCommand', 'gangjob-create', 'admin', function(source, args, user)
		TriggerClientEvent('pk-gangjob:creategang', source)
	end, function(source, args, user)
		TriggerClientEvent('chat:addMessage', source, { args = { '^1SYSTEM', 'Insufficient Permissions.' } })
	end, {help = "Maak een lab aan"})
else
	ESX.RegisterCommand('gangjob-create', "admin", function(xPlayer, args, showError)
		xPlayer.triggerEvent('pk-gangjob:creategang', xPlayer)
	end, true)
end

RegisterServerEvent('pk-gangjob:maaktgangjob')
AddEventHandler('pk-gangjob:maaktgangjob', function(garagetable, kledingkast,kluis,jobnaam)
	print(garagetable, kledingkast,kluis,jobnaam)
	if garagetable ~= nil and kledingkast ~= nil and kluis ~= nil and jobnaam ~= nil then
		MySQL.Async.execute("INSERT INTO `pk_gangjob` ( `gang`, `kluis`, `kledingkast`, `kleding`, `garage`) VALUES (@gang, @kluis, @kledingkast, @kleding, @garage)", {
			["@gang"] = jobnaam,
			["@kluis"] = json.encode(kluis),
			["@kledingkast"] = json.encode(kledingkast),
			["@kleding"] = json.encode(Config.DefaultOutfit),
			["@garage"] = json.encode(garagetable),
		})
		KrijgGangs()
		Wait(10)
		refreshlabsclient(1)
	end
end)

RegisterServerEvent('ct-gangjob:setskingang')
AddEventHandler('ct-gangjob:setskingang', function(skintable, id)
	if skintable ~= nil then
		print(json.encode(Config.Uniforms.cosanostra))
		MySQL.Async.execute("UPDATE `pk_gangjob` SET `kleding` = @kleding WHERE gang = @gang", {
			["@kleding"] = skintable,
			["@gang"] = id,
		})
		KrijgGangs()
		Wait(10)
		refreshlabsclient(1)
	end
end)

RegisterServerEvent('ct-gangjob:leg1')
AddEventHandler('ct-gangjob:leg1', function(item, amount, id, Gangs)
	--print(id)
    local xPlayer = ESX.GetPlayerFromId(source)
	local xItem = xPlayer.getInventoryItem(item)
	local inventory, count = {}, 0
	local GangItems = json.decode(Gang[Gangs].stash)
	local GangsItem = getGangsItem(xItem, GangItems)
	if GangsItem == nil then
		local t = PlayerInventoryItemToTraphouseItem(xPlayer, xItem, tonumber(amount))
		xPlayer.removeInventoryItem(item,tonumber(amount))
		table.insert(GangItems, t)
	else
		local index = table.indexOf(GangItems, GangsItem)
		if index > 0 then
			table.remove(GangItems, index)
			GangsItem.count = GangsItem.count + amount
			xPlayer.removeInventoryItem(item,tonumber(amount))
			table.insert(GangItems, GangsItem)
		elseif index < 0 then
			print("WHAT")
		end
	end
	MySQL.Async.execute("UPDATE `pk_gangjob` SET `stash` = @inventory WHERE gang = @gang", {
		["@inventory"] = json.encode(GangItems),
        ["@gang"] = id,
    })
	KrijgGangs()
	Wait(10)
	refreshlabsclient(1)
end)

function PlayerInventoryItemToTraphouseItem(xPlayer, xItem, amount)
		for k, v in pairs(xPlayer.inventory) do
			if v.name == xItem.name and xItem.count > amount then
				return {
					name = v.name, -- drugsbag
					count = amount, -- 1
					label = v.label, -- Zakjes
				} -- [{"name":"coca_leaf","count":8,"label":"Coca leaf"},{"name":"coca_leaf","count":8,"label":"Coca leaf"}]
			end
		end

end

function getGangsItem(item, GangItems)
	for kl, itemTraphouse in pairs(GangItems) do
		--print(item.name)
		if itemTraphouse.name == item.name then
			return itemTraphouse
		end
	end
	return nil
end

RegisterServerEvent('ct-gangjob:krijg1')
AddEventHandler('ct-gangjob:krijg1', function(item, amount, id, Gangs)
    local xPlayer = ESX.GetPlayerFromId(source)
	local xItem = xPlayer.getInventoryItem(item)
	local inventory, count = {}, 0
	local GangItems = json.decode(Gang[Gangs].stash)
	local GangsItem = getGangsItem(xItem, GangItems)
	local index = table.indexOf(GangItems, GangsItem)
	for k,v in pairs(GangItems) do
	
		if v.name == xItem.name and tonumber(v.count) >= tonumber(amount) then 
		local countis0 = table.indexOf(GangItems, v)
			if index > 0 then
				table.remove(GangItems, index)
				GangsItem.count = GangsItem.count - amount
				xPlayer.addInventoryItem(item,tonumber(amount))
				if GangsItem.count == 0 then
					table.remove(GangItems, countis0)
				else
					table.insert(GangItems, GangsItem)
				end
			elseif index < 0 then
				print("DEZE INDEX IS NULL HAHA: ".. index)
			end
			
			MySQL.Async.execute("UPDATE `pk_gangjob` SET `stash` = @inventory WHERE gang = @id", {
				["@inventory"] = json.encode(GangItems),
				["@id"] = id,
			})
			KrijgGangs()
			Wait(10)
			refreshlabsclient(1)
		end
	end
end)

ESX.RegisterServerCallback('ct-gangjob:krijgGang', function(src, cb)
    cb(Gang)
end)

if Config.ESX == "OLD" then
	ESX.RegisterServerCallback("ct-gangjob:krijgLoadout", function(src, cb)
		local xPlayer = ESX.GetPlayerFromId(src)
	
		cb({
			weapons = xPlayer.getLoadout(),
			inventory = xPlayer.inventory,
		})
	end)
end

ESX.RegisterServerCallback("ct-gangjob:krijgLoadout", function(src, cb)
	local xPlayer = ESX.GetPlayerFromId(src)

	cb({
		inventory = xPlayer.inventory,
	})
end)