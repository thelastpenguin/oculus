local PLUGIN = {};
function PLUGIN:PlayerSpawn( pl )
	oc.notify_all( 'Player ', pl, ' spawned.' );
end
oc.RegisterPlugin( 'test', PLUGIN );

-- freeze
local cmd = oc.command( 'punishment', 'freeze', function( pl, args )
	oc.ForEach( args.players, function( t )
		t:Lock();	
	end);
	oc.notify_fancy( player.GetAll(), '#P froze #P.', pl, args.players );
end)
cmd:addParam 'players' { type = 'player', 'multi' }

-- unfreeze
local cmd = oc.command( 'punishment', 'unfreeze', function( pl, args )
	oc.ForEach( args.players, function( t )
		t:UnLock();	
	end);
	oc.notify_fancy( player.GetAll(), '#P unfroze #P.', pl, args.players );
end)
cmd:addParam 'players' { type = 'player', 'multi' }

-- slay
local cmd = oc.command( 'punishment', 'slay', function( pl, args )
	oc.ForEach( args.players, function( t )
		t:Kill();
	end);
	oc.notify_fancy( player.GetAll(), '#P slayed #P.', pl, args.players );
end)
cmd:addParam 'players' { type = 'player', 'multi' }

-- kick
local cmd = oc.command( 'punishment', 'kick', function( pl, args )
	args.player:Kick( args.reason );
	oc.notify_fancy( player.GetAll(), '#P kicked #P', pl, args.players );
end)
cmd:addParam 'player' { type = 'player' }
cmd:addParam 'reason' { type = 'string', default = '<no reason>', 'fill_line' }

-- ban
local cmd = oc.command( 'punishment', 'ban', function( pl, args )
	args.player:Ban( args.len, args.reason )
	oc.notify_fancy( player.GetAll(), '#P banned #P for #T.', pl, args.players, args.len );
end)
cmd:addParam 'player' { type = 'player' }
cmd:addParam 'len' { type = 'time' }
cmd:addParam 'reason' { type = 'string', default = '<no reason>', 'fill_line' }




-- reload all players
local cmd = oc.command( 'test', 'playerinitialspawn', function( pl, args )
	oc.ForEach( args.players, function( t )
		oc.hook.Call('PlayerInitialSpawn', pl);	
	end);
	oc.notify_fancy( player.GetAll(), '#P re-InitialSpawned #P', pl, args.players );
end)
cmd:addParam 'players' { type = 'player', 'multi' }