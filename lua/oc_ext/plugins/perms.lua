
-- player add perm
local cmd = oc.command( 'permissions', 'playeraddperm', function( pl, args )
	oc.p(args.player):addPerm(args.perm);
	oc.notify_fancy( player.GetAll(), '#P granted #P permission #S.', pl, args.player, args.perm );
end)
cmd:setHelp 'grant the player access to the specified permission'
cmd:addParam 'player' { type = 'player', help = 'target player' }
cmd:addParam 'perm' { type = 'string', help = 'permission name' }

-- player del perm
local cmd = oc.command( 'permissions', 'playerdelperm', function( pl, args )
	oc.p(args.player):delPerm(args.perm);
	oc.notify_fancy( player.GetAll(), '#P removed permission #S from #P.', pl, args.perm, args.player );
end)
cmd:setHelp 'grant the player access to the specified permission'
cmd:addParam 'player' { type = 'player', help = 'target player' }
cmd:addParam 'perm' { type = 'string', 'fill_line', help = 'permission name' }
