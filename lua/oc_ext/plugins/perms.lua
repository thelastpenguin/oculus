-- group add perm
local cmd = oc.command( 'permissions', 'groupaddlocalperm', function( pl, args )
	args.group:addPerm(args.perm, false);
	oc.notify_fancy( player.GetAll(), '#P granted local permission #S to #G', pl, args.perm, args.group );
end)
cmd:setHelp 'grant the group local access to the specified permission'
cmd:addParam 'group' { type = 'group', help = 'target group' }
cmd:addParam 'perm' { type = 'string', help = 'permission name', options = oc.autocomplete.perms}


-- group del perm
local cmd = oc.command( 'permissions', 'groupdellocalperm', function( pl, args )
	args.group:delPerm(args.perm, false);
	oc.notify_fancy( player.GetAll(), '#P deleted local permission #S from #G', pl, args.perm, args.group );
end)
cmd:setHelp 'deny the group local access to the specified permission'
cmd:addParam 'group' { type = 'group', help = 'target group' }
cmd:addParam 'perm' { type = 'string', help = 'permission name', options = oc.autocomplete.perms}




-- group add perm
local cmd = oc.command( 'permissions', 'groupaddglobalperm', function( pl, args )
	args.group:addPerm(args.perm, true);
	oc.notify_fancy( player.GetAll(), '#P granted global permission #S to #G', pl, args.perm, args.group );
end)
cmd:setHelp 'grant the group global access to the specified permission'
cmd:addParam 'group' { type = 'group', help = 'target group' }
cmd:addParam 'perm' { type = 'string', help = 'permission name', options = oc.autocomplete.perms}


-- group del perm
local cmd = oc.command( 'permissions', 'groupdelglobalperm', function( pl, args )
	args.group:delPerm(args.perm, true);
	oc.notify_fancy( player.GetAll(), '#P deleted global permission #S from #G', pl, args.perm, args.group );
end)
cmd:setHelp 'deny the group global access to the specified permission'
cmd:addParam 'group' { type = 'group', help = 'target group' }
cmd:addParam 'perm' { type = 'string', help = 'permission name', options = oc.autocomplete.perms}





-- player add perm
local cmd = oc.command( 'permissions', 'playeraddlocalperm', function( pl, args )
	oc.p(args.player):addPerm(args.perm, false);
	oc.notify_fancy( player.GetAll(), '#P granted #P local permission #S.', pl, args.player, args.perm );
end)
cmd:setHelp 'grant the player local access to the specified permission'
cmd:addParam 'player' { type = 'player', help = 'target player' }
cmd:addParam 'perm' { type = 'string', help = 'permission name', options = oc.autocomplete.perms}

-- player add perm
local cmd = oc.command( 'permissions', 'playeraddglobalperm', function( pl, args )
	oc.p(args.player):addPerm(args.perm, true);
	oc.notify_fancy( player.GetAll(), '#P granted #P global permission #S.', pl, args.player, args.perm );
end)
cmd:setHelp 'grant the player global access to the specified permission'
cmd:addParam 'player' { type = 'player', help = 'target player' }
cmd:addParam 'perm' { type = 'string', help = 'permission name', options = oc.autocomplete.perms}



-- player del perm
local cmd = oc.command( 'permissions', 'playerdellocalperm', function( pl, args )
	oc.p(args.player):delPerm(args.perm, false);
	oc.notify_fancy( player.GetAll(), '#P removed local permission #S from #P.', pl, args.perm, args.player );
end)
cmd:setHelp 'remove local access to the specified perm from the player'
cmd:addParam 'player' { type = 'player', help = 'target player'}
cmd:addParam 'perm' { type = 'string', 'fill_line', help = 'permission name', options = oc.autocomplete.perms}

-- player del perm
local cmd = oc.command( 'permissions', 'playerdelglobalperm', function( pl, args )
	oc.p(args.player):delPerm(args.perm, true);
	oc.notify_fancy( player.GetAll(), '#P removed global permission #S from #P.', pl, args.perm, args.player );
end)
cmd:setHelp 'remove global access to the specified perm from the player'
cmd:addParam 'player' { type = 'player', help = 'target player'}
cmd:addParam 'perm' { type = 'string', 'fill_line', help = 'permission name', options = oc.autocomplete.perms}



-- player set primary group
local cmd = oc.command( 'permissions', 'playersetlocalgroup', function( pl, args )
	oc.p(args.player):setGroup(args.group.gid, false);
	oc.notify_fancy( player.GetAll(), '#P set #P\'s primary local group to #G', pl, args.player, args.group );
end)
cmd:setHelp 'set the player\'s local group'
cmd:addParam 'player' { type = 'player', help = 'target player' }
cmd:addParam 'group' { type = 'group', help = 'primary group' }

-- player set primary group
local cmd = oc.command( 'permissions', 'playersetglobalgroup', function( pl, args )
	oc.p(args.player):setGroup(args.group.gid, true);
	oc.notify_fancy( player.GetAll(), '#P set #P\'s primary global group to #G', pl, args.player, args.group );
end)
cmd:setHelp 'set the player\'s global group'
cmd:addParam 'player' { type = 'player', help = 'target player' }
cmd:addParam 'group' { type = 'group', help = 'primary group' }



-- player add secondary group
local cmd = oc.command( 'permissions', 'playeraddlocalgroup', function( pl, args )
	oc.p(args.player):addGroup(args.group.gid, false);
	oc.notify_fancy( player.GetAll(), '#P added seconary local group #G for #P', pl, args.group, args.player );
end)
cmd:setHelp 'add secondary local group'
cmd:addParam 'player' { type = 'player', help = 'target player' }
cmd:addParam 'group' { type = 'group', help = 'secondary group' }

-- player add secondary group
local cmd = oc.command( 'permissions', 'playeraddglobalgroup', function( pl, args )
	oc.p(args.player):addGroup(args.group.gid, true);
	oc.notify_fancy( player.GetAll(), '#P added secondary global group #G for #P', pl, args.group, args.player );
end)
cmd:setHelp 'add secondary global group'
cmd:addParam 'player' { type = 'player', help = 'target player' }
cmd:addParam 'group' { type = 'group', help = 'secondary group' }



-- player del secondary group
local cmd = oc.command( 'permissions', 'playerdellocalgroup', function( pl, args )
	oc.p(args.player):delGroup(args.group.gid, false);
	oc.notify_fancy( player.GetAll(), '#P added seconary local group #G for #P', pl, args.group, args.player );
end)
cmd:setHelp 'del secondary local group'
cmd:addParam 'player' { type = 'player', help = 'target player' }
cmd:addParam 'group' { type = 'group', help = 'secondary group' }

-- player del secondary group
local cmd = oc.command( 'permissions', 'playerdelglobalgroup', function( pl, args )
	oc.p(args.player):delGroup(args.group.gid, true);
	oc.notify_fancy( player.GetAll(), '#P removed secondary global group #G for #P', pl, args.group, args.player );
end)
cmd:setHelp 'del secondary global group'
cmd:addParam 'player' { type = 'player', help = 'target player' }
cmd:addParam 'group' { type = 'group', help = 'secondary group' }


-- player get info
local cmd = oc.command( 'permissions', 'playerinfo', function( pl, args )
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