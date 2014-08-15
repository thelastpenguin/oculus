local oc = oc;

local player_mt = {};
player_mt.__index = player_mt;

local players = {};
oc._players = players;
function oc.p( pl )
	if players[pl] then
		return players[pl];
	elseif(IsValid(pl))then
		local new = setmetatable( {player=pl}, player_mt);
		new.state = 'loading';
		new:load(xfn.noop);
		players[pl] = new;
		return new;
	end
end


--
-- LOAD USERS
--
function player_mt:load(done)
	oc.hook.Call('PlayerStartLoad', self);
	async.series({
		-- fetch userid
		function( done )
			oc.data.userFetchID( self.player:SteamID(), function(uid)
				if not uid then
					oc.data.userCreate(self.player, function()
						oc.data.userFetchID(self.player:SteamID(), function(uid)
							self.uid = uid;
							dprint('fetched player uid: '..uid);
							done();
						end);	
					end);
				else
					self.uid = uid;
					oc.data.userUpdate(uid,self.player);
					done();
				end
			end);
		end,
		-- fetch perms and pdata
		function( done )
			async.parallel({
				function(done)
					self:fetchPerms(true, done);
				end,
				function(done)
					self:fetchPerms(false, done);
				end,
				function(done)
					self:fetchVars(function(err)
						if self.vars then
							done();
						else
							self.vars = {};
							oc.data.userInitVars( oc.data.svid, self.uid, done);
						end
					end);
				end
			}, done);
		end,
	}, function()
		self.ready = true;
		self:loadInheritance();
		
		if self.player then
			dprint('loaded player ' .. self.player:Name());
			net.waitForPlayer(self.player, function()
				dprint('syncing player vars for ' .. self.player:Name());
				self:syncAllVars();
				self:syncPermTree(true);
				self:syncPermTree(false);
			end);
		end
		
		done();
	end);
end

-- LOADS INHERITED PERMISSIONS
function player_mt:loadInheritance()
	-- load primary usergroup
	self.primaryGroup = oc.g(self:getPermNumber('group.primary')) or oc.g(oc.cfg.group_user);
	if self.player then
		self.player:SetUserGroup(self.primaryGroup.name);
	end
	
end

function player_mt:setGroup( group, isGlobal, done )
	async.series({
		xfn.fn_partial(self.delPerm, self, 'group.primary', isGlobal or false),
		xfn.fn_partial(self.setPermNumber, self, 'group.primary', group, isGlobal or false),
	}, function()
		self:loadInheritance();
		if done then done() end
	end);
end

function player_mt:getImmunity() 
	return self.primaryGroup and self.primaryGroup.immunity or 0;	
end

--
-- USER VARS
--
util.AddNetworkString('oc.pl.syncVar');
function player_mt:fetchVars(done) 
	return oc.data.userFetchVars( oc.data.svid, self.uid, function(data, err) 
		
		if data[1] then
			self.vars = pon.decode(data[1].data);
		end
		
		if self.player and self.ready then
			-- if we are refetching after initial load then we should sync our findings
			net.waitForPlayer(self.player, function()
				self:syncPermTree();	
			end);
		end
		
		done(err);
	end);
end
function player_mt:saveVars(done)	
	self.vars_changed = false;
	return oc.data.userUpdateVars( oc.data.svid, self.uid, pon.encode(self.vars), done);
end
function player_mt:setVar( key, value )
	self.vars_changed = true;
	self.vars[key] = value;
	self:syncVar(key, pl);
end
function player_mt:getVar(key)
	return self.vars and self.vars[key];
end
function player_mt:syncAllVars(pl)
	for k,v in pairs(self.vars)do
		self:syncVar(k, pl);
	end
end
function player_mt:syncVar(key, pl)
	net.Start('oc.pl.syncVar');
		net.WriteEntity(self.player);
		net.WriteTable({key, self.vars[key]});
	net.Send(pl or player.GetAll());	
end


--
-- PERMISSION UTILITIES
--
function player_mt:fetchPerms(isGlobal, done)
	oc.data.userFetchPerms( isGlobal and 0 or oc.data.svid, self.uid, function(perms)
		if isGlobal then
			self.globalPerms = oc.perm():addPermTable(perms);
		else
			self.serverPerms = oc.perm():addPermTable(perms);
		end
		self:syncPermTree(isGlobal);
		done();
	end);
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



function player_mt:delPerm(perm, isGlobal, done)
	oc.data.userDelPerm( isGlobal and 0 or oc.data.svid, self.uid, perm, function()
		self:fetchPerms(isGlobal, done);
	end);
end

function player_mt:addPerm(perm, isGlobal, done)
	return oc.data.userAddPerm( isGlobal and 0 or oc.data.svid, self.uid, perm, function()
		self:fetchPerms( isGlobal, xfn.fn_deafen(done or xfn.noop));	
	end);
end

function player_mt:addTempPerm( perm, fallback, time, isGlobal, done)
	return oc.data.userPermSetExpire( isGlobal and 0 or oc.data.svid, self.uid, perm, time, fallback, done);
end

function player_mt:delTempPerm( perm, isGlobal, done)
	return oc.data.userPermSetExpire( isGlobal and 0 or oc.data.svid, self.uid, perm, done);
end

function player_mt:addPermNumber(perm, value, isGlobal, done)
	return self:addPerm(perm..'.'..tonumber(value, 16), isGlobal, done);
end
function player_mt:setPermString(perm, value, isGlobal, done)
	return self:delPerm(perm, isGlobal, function() 
		self:addPerm(perm..'.'..value, isGlobal, done);
	end);
end
function player_mt:setPermNumber(perm, value, isGlobal, done)
	return self:delPerm(perm, isGlobal, function()
		self:addPerm(string.format('%s.%x', perm, value), isGlobal, done);
	end);
end

util.AddNetworkString('oc.pl.syncPermTree');
function player_mt:syncPermTree(isGlobal)
	net.Start('oc.pl.syncPermTree');
		net.WriteUInt(isGlobal and 1 or 0, 8);
		(isGlobal and self.globalPerms or self.serverPerms):netWrite();
	net.Send(self.player);
end



oc.hook.Add('PlayerInitialSpawn', function(pl)
	dprint('loading player: '..pl:Name());
	oc.p(pl);
	
	-- sync user variables
	net.waitForPlayer(pl, function()
		for k,v in pairs(players)do
			if not v.ready then continue end
			v:syncAllVars(pl);
		end
	end);
	
end);

oc.hook.Add('PlayerDisconnected', function(pl)
	dprint('unloading player: '..pl:Name());
	oc.p(pl):saveVars();
	players[pl] = nil;
end);

timer.Create('oc.pl.saveVars', 120, 0, function()
	local offset = 0;
	for _, pl in pairs(players)do
		if pl.vars_changed then
			timer.Simple(offset, function()
				if not IsValid(pl) then return end
				dprint('  saved user: '..pl.player:Name());
				pl:saveVars();	
			end);
			offset = offset + 1;
		end
	end
end);