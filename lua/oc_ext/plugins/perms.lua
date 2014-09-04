
-- player add perm
local cmd = oc.command( 'permissions', 'Player AddLocalPerm', function( pl, args )
	oc.p(args.player, function(meta)
		meta:addPerm(args.perm, false, function()
			oc.notify_fancy( player.GetAll(), '#P granted #P local permission #S.', pl, meta, args.perm );
		end);
	end);
end)
cmd:setHelp 'grant the player local access to the specified permission'
cmd:addParam 'player' { type = 'steamid', help = 'target player' }
cmd:addParam 'perm' { type = 'string', help = 'permission name', options = oc.autocomplete.perms}

-- player add perm
local cmd = oc.command( 'permissions', 'Player AddGlobalPerm', function( pl, args )
	oc.p(args.player, function(meta)
		meta:addPerm(args.perm, true, function()
			oc.notify_fancy( player.GetAll(), '#P granted #P global permission #S.', pl, meta, args.perm );
		end);
	end);
end)
cmd:setHelp 'grant the player global access to the specified permission'
cmd:addParam 'player' { type = 'steamid', help = 'target player' }
cmd:addParam 'perm' { type = 'string', help = 'permission name', options = oc.autocomplete.perms}



-- player del perm
local cmd = oc.command( 'permissions', 'Player DelLocalPerm', function( pl, args )
	oc.p(args.player, function(meta)
		meta:delPerm(args.perm, false, function()
			oc.notify_fancy( player.GetAll(), '#P removed local permission #S from #P.', pl, args.perm, meta );
		end);
	end);
end)
cmd:setHelp 'remove local access to the specified perm from the player'
cmd:addParam 'player' { type = 'steamid', help = 'target player'}
cmd:addParam 'perm' { type = 'string', 'fill_line', help = 'permission name', options = oc.autocomplete.perms}

-- player del perm
local cmd = oc.command( 'permissions', 'Player DelGlobalPerm', function( pl, args )
	oc.p(args.player, function(meta)
		meta:delPerm(args.perm, true, function()
			oc.notify_fancy( player.GetAll(), '#P removed global permission #S from #P.', pl, args.perm, meta );
		end);
	end);
end)
cmd:setHelp 'remove global access to the specified perm from the player'
cmd:addParam 'player' { type = 'steamid', help = 'target player'}
cmd:addParam 'perm' { type = 'string', 'fill_line', help = 'permission name', options = oc.autocomplete.perms}



-- player set primary group
local cmd = oc.command( 'permissions', 'Player SetLocalGroup', function( pl, args )
	if (args.time or args.fallback) and not (args.time and args.fallback) then
		oc.notify(pl, oc.cfg.color_error, 'Error! You must provide both time and fallback if you choose to use this feature');
		return ;
	end
	if args.time then
		oc.p(args.player, function(meta)
			oc.notify_fancy( player.GetAll(), '#P set #P\'s primary local group to #G for #T with fallback group #G', pl, meta, args.group, args.time, args.fallback );
			meta:setGroup(args.group.gid, false, function()
				meta:addTempPerm(string.format('group.primary.%x', args.group.gid), string.format('group.primary.%x', args.fallback.gid), os.time() + args.time, false );
			end);
		end);
	else
		oc.p(args.player, function(meta)
			oc.notify_fancy( player.GetAll(), '#P set #P\'s primary local group to #G', pl, meta, args.group );
			meta:setGroup(args.group.gid, false);
		end);
	end
end)
cmd:setHelp 'set the player\'s local group'
cmd:addParam 'player' { type = 'steamid', help = 'target player' }
cmd:addParam 'group' { type = 'group', help = 'primary group' }
cmd:addParam 'time' { type = 'time', 'optional' }
cmd:addParam 'fallback' { type = 'group', 'optional' }

-- player set primary group
local cmd = oc.command( 'permissions', 'Player SetGlobalGroup', function( pl, args )
	if (args.time or args.fallback) and not (args.time and args.fallback) then
		oc.notify(pl, oc.cfg.color_error, 'Error! You must provide both time and fallback if you choose to use this feature');
		return ;
	end
	if args.time then
		oc.p(args.player, function(meta)
			meta:setGroup(args.group.gid, true, function()
				oc.notify_fancy( player.GetAll(), '#P set #P\'s primary global group to #G for #T with fallback group #G', pl, meta, args.group, args.time, args.fallback );
				meta:addTempPerm(string.format('group.primary.%x', args.group.gid), string.format('group.primary.%x', args.fallback.gid), os.time() + args.time, true );
			end);
		end);
	else
		oc.p(args.player, function(meta)
			oc.notify_fancy( player.GetAll(), '#P set #P\'s primary global group to #G', pl, meta, args.group);
			meta:setGroup(args.group.gid, true);
		end);
	end
end)
cmd:setHelp 'set the player\'s global group'
cmd:addParam 'player' { type = 'steamid', help = 'target player' }
cmd:addParam 'group' { type = 'group', help = 'primary group' }
cmd:addParam 'time' { type = 'time', 'optional' }
cmd:addParam 'fallback' { type = 'group', 'optional' }


-- player get info
local cmd = oc.command( 'permissions', 'Player Info', function( pl, args )
end)
cmd:runOnClient(function(args)
	local pl = args.player;
	oc.LoadMsg(0, '\nNAME: '..pl:Name());
	oc.LoadMsg(0, 'GROUP: '..pl:GetNWString('UserGroup', 'unknown')..'\n');
	
	local plMeta = oc.p(pl);
	
	if plMeta.groups then
		for k,v in pairs(plMeta.groups)do
			oc.LoadMsg(2, 'EXTRA GROUP: '..v.name);	
		end
		oc.LoadMsg('\n');
	end
	
	local function printChildren( obj, depth, perm )
		local cldrn = obj:getPerm(perm);
		for k,v in pairs(cldrn) do
			oc.LoadMsg(depth, v);
			printChildren(obj, depth + 2, perm..'.'..v);
		end
	end
	
	if plMeta.globalPerms then
		oc.LoadMsg(0, 'GLOBAL PERMS:');
		for k,v in pairs(plMeta.globalPerms:getPerm('*')) do
			oc.LoadMsg(2, v);
			printChildren(plMeta.globalPerms, 4, v);
		end
	end
	
	if plMeta.serverPerms then
		oc.LoadMsg(0, 'SERVER PERMS:');
		for k,v in pairs(plMeta.serverPerms:getPerm('*')) do
			oc.LoadMsg(2, v);
			printChildren(plMeta.serverPerms, 4, v);
		end
	end
	
end);
cmd:setHelp 'print various information about the specified player'
cmd:addParam 'player' { type = 'player', help = 'target player' }