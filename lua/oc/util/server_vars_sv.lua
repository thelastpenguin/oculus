util.AddNetworkString('_loadServerVars')

oc.serverVars = oc.serverVars or {}

local db = oc._db

local function saveServerVars()
	local vars = pon.encode(oc.serverVars)
	db:query('REPLACE INTO oc_server_vars(sv_id, data) VALUES("' .. oc.data._svid .. '", "' .. vars .. '");')

	net.Start('_loadServerVars')
		net.WriteString(pon.encode(oc.serverVars))
	net.Broadcast()
end

local encodedVars
local function loadServerVars()
	db:query('SELECT * FROM oc_server_vars WHERE sv_id = "' .. oc.data._svid .. '";', function(data)
		oc.serverVars = pon.decode(data[1].data)
		encodedVars = data[1].data
	end)
end
loadServerVars()

function oc.setServerVar(var, val)
	oc.serverVars[var] = val
	saveServerVars()
end

function oc.getServerVar(var)
	return oc.serverVars[var]
end

oc.hook.Add('PlayerInitialSpawn', function(pl)
	net.waitForPlayer(pl, function()
		net.Start('_loadServerVars')
			net.WriteString(encodedVars)
		net.Send(pl)
		oc.hook.Call('ServerVarsLoaded', pl)
	end)
end)