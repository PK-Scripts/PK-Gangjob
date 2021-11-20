Config        = {}
Config.Locale = 'nl'

Config.UseMenu = "br-menu"

Config.ESX = "NEW" -- OLD = coming soon

Config.Garage = {
    {label = 'Audi S5 Sportback', value = 's5', gang = 'blackmarket', job_grade = 0},
}

Config.DefaultOutfit = {
    male = {
        ['tshirt_1'] = 35,  ['tshirt_2'] = 0,
        ['torso_1'] = 30,   ['torso_2'] = 1,
        ['decals_1'] = 0,   ['decals_2'] = 0,
        ['arms'] = 17,
        ['pants_1'] = 24,   ['pants_2'] = 1,
        ['shoes_1'] = 20,   ['shoes_2'] = 7,
        ['chain_1'] = 0,    ['chain_2'] = 0,
        ['ears_1'] = -1,     ['ears_2'] = 0,
        ['mask_1'] = 0,   ['mask_2'] = 0
    },
    female = {
        ['tshirt_1'] = 35,  ['tshirt_2'] = 0,
        ['torso_1'] = 85,   ['torso_2'] = 0,
        ['arms'] = 46,
        ['pants_1'] = 61,   ['pants_2'] = 0,
        ['shoes_1'] = 25,   ['shoes_2'] = 0,
        ['helmet_1'] = -1,  ['helmet_2'] = 0,
        ['glasses_1'] = 5,  ['glasses_2'] = 0,
        ['ears_1'] = -1,     ['ears_2'] = 0,
        ['bproof_1'] = 31,  ['bproof_2'] = 0,
        ['mask_1'] = 121,   ['mask_2'] = 0
    }
}

-- locales

function _(str, ...)  -- Translate string

	if Locales[Config.Locale] ~= nil then

		if Locales[Config.Locale][str] ~= nil then
			return string.format(Locales[Config.Locale][str], ...)
		else
			return 'Translation [' .. Config.Locale .. '][' .. str .. '] does not exist'
		end

	else
		return 'Locale [' .. Config.Locale .. '] does not exist'
	end

end

function _U(str, ...) -- Translate string first char uppercase
	return tostring(_(str, ...):gsub("^%l", string.upper))
end