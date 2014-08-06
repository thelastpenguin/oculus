local player_mt = {};
player_mt.__index = player_mt;


local players = {};
function oc.p(pl)
	if players[pl] then
		return players[pl];
	else
		oc.print('creating player meta wrapper for '..pl:Name());	
		local meta = setmetatable({
			player = pl,
			vars = {},	
		}, player_mt);
		players[pl] = meta;
		return meta;
	end
end

net.Receive('oc.pl.syncVar', function(len)
	local pl = net.ReadEntity();
	local tbl = net.ReadTable();
	local meta = oc.p(pl);
	oc.print( 'sync var: '..pl:Name()..' - '..tostring(tbl[1])..' = '..tostring(tbl[2]));
	meta.vars[tbl[1]] = tbl[2];
end);

oc.hook.Add('OnEntityCreated', function(ent)
	if ent:IsPlayer() then
		oc.p(ent);
	end
end);