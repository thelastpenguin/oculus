local function autocomplete_perms()
	local res = {};
	for k,v in pairs(oc.commands)do
		table.insert(res, 'cmd.'..k);
	end
	return res;
end



-- player add perm
local cmd = oc.command( 'permissions', 'playeraddlocalperm', function( pl, args )
	oc.p(args.player):addPerm(args.perm, false);
	oc.notify_fancy( player.GetAll(), '#P granted #P local permission #S.', pl, args.player, args.perm );
end)
cmd:setHelp 'grant the player local access to the specified permission'
cmd:addParam 'player' { type = 'player', help = 'target player' }
cmd:addParam 'perm' { type = 'string', help = 'permission name', options = autocomplete_perms}

-- player add perm
local cmd = oc.command( 'permissions', 'playeraddglobalperm', function( pl, args )
	oc.p(args.player):addPerm(args.perm, true);
	oc.notify_fancy( player.GetAll(), '#P granted #P global permission #S.', pl, args.player, args.perm );
end)
cmd:setHelp 'grant the player global access to the specified permission'
cmd:addParam 'player' { type = 'player', help = 'target player' }
cmd:addParam 'perm' { type = 'string', help = 'permission name', options = autocomplete_perms}



-- player del perm
local cmd = oc.command( 'permissions', 'playerdellocalperm', function( pl, args )
	oc.p(args.player):delPerm(args.perm, false);
	oc.notify_fancy( player.GetAll(), '#P removed local permission #S from #P.', pl, args.perm, args.player );
end)
cmd:setHelp 'remove local access to the specified perm from the player'
cmd:addParam 'player' { type = 'player', help = 'target player'}
cmd:addParam 'perm' { type = 'string', 'fill_line', help = 'permission name', options = autocomplete_perms}

-- player del perm
local cmd = oc.command( 'permissions', 'playerdelglobalperm', function( pl, args )
	oc.p(args.player):delPerm(args.perm, true);
	oc.notify_fancy( player.GetAll(), '#P removed global permission #S from #P.', pl, args.perm, args.player );
end)
cmd:setHelp 'remove global access to the specified perm from the player'
cmd:addParam 'player' { type = 'player', help = 'target player'}
cmd:addParam 'perm' { type = 'string', 'fill_line', help = 'permission name', options = autocomplete_perms}



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
	oc.notify_fancy( player.GetAll(), '#P added secondary global group #G for #P', pl, args.group, args.player );
end)
cmd:setHelp 'del secondary global group'
cmd:addParam 'player' { type = 'player', help = 'target player' }
cmd:addParam 'group' { type = 'group', help = 'secondary group' }

