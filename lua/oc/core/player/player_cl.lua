local oc = oc;

local player_mt = {};
player_mt.__index = player_mt;


local players = {};
function oc.p(pl)
	if players[pl] then
		return players[pl];
	else
		local meta = setmetatable({
			player = pl,
			vars = {},	
		}, player_mt);
		players[pl] = meta;
		return meta;
	end
end

function player_mt:applyPermUpdates()
	// don't update data until serverPerms and globalPerms have been synced
	if not self.ready then
		if self.serverPerms and self.globalPerms then
			self.ready = true
		else
			return ;
		end
	end
	dprint('applying permission updates');
		
	self:loadInheritance();
end


-- LOADS INHERITED PERMISSIONS
function player_mt:loadInheritance()
	-- load primary usergroup
	local primaryGroupId = self:getPermNumber('group.primary') or self.player:GetNWInt('pgid');
	self.primaryGroup = oc.g(primaryGroupId or oc.cfg.group_user) or oc.g(oc.cfg.group_user);

	if not self.primaryGroup or not self.primaryGroup.name then
		dprint('WARNING: attempted to load inheritance before primaryGroup was ready. this may be safe to ignore.');
		return ;
	end
	dprint('loaded primary group as '..self.primaryGroup.name);
end

function player_mt:getImmunity() 
	return self.primaryGroup and self.primaryGroup.immunity or 0;	
end

function player_mt:getPerm( perm )
	if not self.ready then return false end
	
	local res;
	res = self.serverPerms:getPerm(perm);
	if res then return res end
	res = self.globalPerms:getPerm(perm);
	if res then return res end
	
	if self.primaryGroup then
		res = self.primaryGroup:getPerm(perm);
		if res then return res end
	end
end
function player_mt:getPermString(perm)
	local res = self:getPerm(perm);
	return res and res[1]
end
function player_mt:getPermNumber(perm)
	local res = self:getPerm(perm);
	return res and res[1] and tonumber(res[1], 16);
end

function player_mt:getVar(key)
	return self.vars and self.vars[key];
end


net.Receive('oc.pl.syncVar', function(len)
	local pl = net.ReadEntity();
	local tbl = net.ReadTable();
	local meta = oc.p(pl);
	dprint( 'sync var: '..pl:Name()..' - '..tostring(tbl[1])..' = '..tostring(tbl[2]));
	meta.vars[tbl[1]] = tbl[2];
end);

net.Receive('oc.pl.syncPermTree', function(len)
	local isGlobal = net.ReadUInt(8) == 1;
		
	dprint('received perms: '..(isGlobal and 'global' or 'server' ));
	local p = oc.p(LocalPlayer());
	local perms = oc.perm():netRead();
	if isGlobal then
		p.globalPerms = perms;
	else
		p.serverPerms = perms;
	end
	
	p:applyPermUpdates();
end);

oc.hook.Add('OnEntityCreated', function(ent)
	if ent:IsPlayer() then
		oc.p(ent);
	end
end);