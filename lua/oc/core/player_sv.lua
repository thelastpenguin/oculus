local oc = oc;

local player_mt = {};
player_mt.__index = player_mt;

local players = {};
function oc.p( pl )
	if players[pl] then
		return players[pl];
	else
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
	async.series({
		-- fetch userid
		function( done )
			oc.data.userFetchID( self.player:SteamID(), function(uid)
				if not uid then
					oc.data.userCreate(self.player, function()
						oc.data.userFetchID(self.player:SteamID(), function(uid)
							self.uid = uid;
							print('fetched player uid: '..uid);
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
		-- fetch permissions
		function( done )
			async.parallel({
				function(done)
					oc.data.userFetchPerms( oc.data.svid, self.uid, function(perms)
						self.serverPerms = oc.perm(perms);
						done();
					end);	
				end,
				function(done)
					oc.data.userFetchPerms( 0, self.uid, function(perms)
						self.globalPerms = oc.perm(perms);
						done();
					end);
				end
			}, done);
		end,
	}, function()
		self.ready = true;
		self:loadInheritance();
		done();
	end);
end

function player_mt:loadInheritance()
	-- load primary usergroup
	self.primaryGroup = oc.g(self:getPermNumber('group.primary') or oc.cfg.group_user);
	if self.player then
		self.player:SetNWString('UserGroup', self.primaryGroup.name);
	end
	
	-- load secondary user groups
	local groupids = self:getPerm('group.secondary');
	if groupids then
		local groups = {};
		for k,v in pairs(groupids)do
			local num = tonumber(v, 16);
			groups[#groups+1] = oc.g(num);
		end
		self.groups = groups;
	end
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
	
	if self.groups then
		for k,v in ipairs(self.groups) do
			res = v:getPerm(perm);
			if res then return res end
		end
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

function player_mt:setGroup( group, isGlobal, done )
	async.series( {
		xfn.fn_partial(self.delPerm, self, 'group.primary.', isGlobal or false),
		xfn.fn_partial(self.addPerm, self, 'group.primary.'..group, isGlobal or false),
	}, function()
		self:loadInheritance();
		if done then done() end
	end);
end

function player_mt:addGroup( group, isGlobal, done )
	self:addPerm( 'group.extra.'..group, isGlobal, function()
		self:loadInheritance();
		if done then done() end
	end)
end

function player_mt:delGroup( group, isGlobal, done )
	self:delPerm( 'group.extra.'..group, isGlobal, function()
		self:loadInheritance();
		if done then done() end	
	end);	
end

function player_mt:fetchPerms(isGlobal, done)
	oc.data.userFetchPerms( isGlobal and 0 or oc.data.svid, self.uid, function(perms)
		if isGlobal then
			self.globalPerms = oc.perm(perms);
		else
			self.serverPerms = oc.perm(perms);
		end
		done();
	end);
end

function player_mt:_delPerm(perm, isGlobal, done)
	return oc.data.userDelPerm( isGlobal and 0 or oc.data.svid, self.uid, perm, function()
		self:fetchPerms( isGlobal, xfn.fn_deafen(done or xfn.noop));	
	end);
end
function player_mt:delPerm(perm, isGlobal, done)
	local subs = (isGlobal and self.globalPerms or self.serverPerms):getPerm(perm);
	local count = #subs;
	if count == 0 then
		self:_delPerm(perm, isGlobal, done);
		return
	end
	
	local amIDone;
	if done then
		amIDone = function()
			count = count - 1;
			if count == 0 then done() end
		end
	else
		amIDone = xfn.noop;
	end
	
	for _, sub in ipairs(subs)do
		self:delPerm(perm..'.'..sub, isGlobal, amIDone);
	end
end
function player_mt:addPerm(perm, isGlobal, done)
	return oc.data.userAddPerm( isGlobal and 0 or oc.data.svid, self.uid, perm, function()
		self:fetchPerms( isGlobal, xfn.fn_deafen(done or xfn.noop));	
	end);
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
		self:addPerm(perm..'.'..tonumber(value, 16), isGlobal, done);
	end);	
end

oc.hook.Add('PlayerInitialSpawn', function(pl)
	oc.print('oculus load player: '..pl:Name());
	oc.p(pl);
end);

oc.hook.Add('PlayerDisconnected', function(pl)
	oc.print('oculus unload player: '..pl);
	players[pl] = nil;
end);