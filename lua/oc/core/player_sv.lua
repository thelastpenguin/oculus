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
		done();
	end);
end

function player_mt:getPerm( perm )
	return self.ready and (self.serverPerms:getPerm(perm) or self.globalPerms:getPerm(perm));
end
function player_mt:setGroup( group, isGlobal, done )
	async.series( {
		xfn.fn_partial(self.delPerm, self, 'group.primary.', isGlobal or false),
		xfn.fn_partial(self.addPerm, self, 'group.primary.'..group, isGlobal or false),
	}, done or xfn.noop);
end
function player_mt:addGroup( group, isGlobal, done )
	self:addPerm( 'group.extra.'..group, isGlobal, done);
end
function player_mt:delGroup( group, isGlobal, done )
	self:delPerm( 'group.extra.'..group, isGlobal, done);	
end

function player_mt:fetchPerms(isGlobal, done)
	oc.data.userFetchPerms( isGlobal and 0 or oc.data.svid, self.uid, function(perms)
		if isGlobal then
			self.serverPerms = oc.perm(perms);
		else
			self.globalPerms = oc.perm(perms);
		end
		done();
	end);
end
function player_mt:delPerm(perm, isGlobal, done)
	isGlobal = isGlobal or false;
	oc.data.userDelPerm( isGlobal and 0 or oc.data.svid, self.uid, perm, function()
		self:fetchPerms( isGlobal, xfn.fn_deafen(done or xfn.noop));	
	end);
end
function player_mt:addPerm(perm, isGlobal, done)
	isGlobal = isGlobal or false;
	oc.data.userAddPerm( isGlobal and 0 or oc.data.svid, self.uid, perm, function()
		self:fetchPerms( isGlobal, xfn.fn_deafen(done or xfn.noop));	
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