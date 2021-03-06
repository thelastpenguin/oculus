util.AddNetworkString('_loadServerVars')

oc.serverVars = oc.serverVars or {}

local db = oc._db

local function saveServerVars(done)
	net.Start('_loadServerVars')
		net.WriteString(pon.encode(oc.serverVars))
	net.Broadcast()

	local vars = pon.encode(oc.serverVars)
	return db:query_ex('REPLACE INTO oc_server_vars(sv_id, data)VALUES(?,\'?\')', {oc.data._svid, vars}, done);
end

local encodedVars = '{}'; // an empty pON table
local function loadServerVars()
	return db:query('SELECT data FROM oc_server_vars WHERE sv_id = "' .. oc.data._svid .. '";', function(data)
		if not data[1] then return end
		oc.serverVars = pon.decode(data[1].data)
		encodedVars = data[1].data
	end)
end
loadServerVars():wait();

function oc.setServerVar(var, val)
	oc.serverVars[var] = val
	saveServerVars()
end

function oc.getServerVar(var)
	return oc.serverVars[var]
end

oc.hook.Add('PlayerInitialSpawn', 'util.serverVars', function(pl)
	net.waitForPlayer(pl, function()
		net.Start('_loadServerVars')
			net.WriteString(encodedVars)
		net.Send(pl)
		oc.hook.Call('ServerVarsLoaded', pl)
	end)
end)