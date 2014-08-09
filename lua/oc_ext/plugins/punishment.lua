local PLUGIN = {};
function PLUGIN:PlayerSpawn( pl )
	oc.notify_all( 'Player ', pl, ' spawned.' );
end
oc.RegisterPlugin( 'test', PLUGIN );

----------------------------------------------------------------
-- Freeze                                                     --
----------------------------------------------------------------
local cmd = oc.command( 'management', 'freeze', function( pl, args )
	oc.ForEach( args.players, function( t )
		if t.frozen then
			t:UnLock();
			t.frozen = nil;
			oc.notify_fancy( player.GetAll(), '#P unfroze #P.', pl, args.players );
		else
			t:Lock();
			t.frozen = true;
			oc.notify_fancy( player.GetAll(), '#P froze #P.', pl, args.players );
		end
	end);
end)
cmd:addParam 'players' { type = 'player', 'multi' }

----------------------------------------------------------------
-- Spectate                                                   --
----------------------------------------------------------------
local specPlayers = {}
local cmd = oc.command( 'management', 'spectate', function( pl, args )
	oc.ForEach( args.players, function( t )
		if !pl.Spec then
			pl.PreSpecPos = pl:GetPos();
			specPlayers[pl] = t;

			pl:StripWeapons()
			pl:Flashlight( false );
			pl:Spectate( 5 );
			pl:SpectateEntity( t );

			pl.Spec = true;
		else

			pl:UnSpectate()
			pl:Spawn()
			pl:SetPos( pl.PreSpecPos )

			pl.PreSpecPos = nil;
			pl.Spec = nil;
		end
	end);
end)
cmd:addParam 'players' { type = 'player', 'multi' }

hook.Add( "Think", "OC.Spectate.Think", function()
	for k, v in pairs( specPlayers ) do
		if ( !k:IsValid() or !v:IsValid() or !k.Spec ) then
			specPlayers[k] = nil;
		end
		
		k:SetPos( v:EyePos() );
	end
end );

----------------------------------------------------------------
-- Slay                                                       --
----------------------------------------------------------------
local cmd = oc.command( 'management', 'slay', function( pl, args )
	oc.ForEach( args.players, function( t )
		if !t:Alive() then
			oc.notify( pl, oc.cfg.color_error, 'This player is not alive!' );
			return
		end
		t:Kill();
	end);
	oc.notify_fancy( player.GetAll(), '#P slayed #P.', pl, args.players );
end)
cmd:addParam 'players' { type = 'player', 'multi' }

----------------------------------------------------------------
-- Tele                                                       --
----------------------------------------------------------------
local cmd = oc.command( 'management', 'tele', function( pl, args )
	oc.ForEach( args.players, function( t )
		local trace = pl:GetEyeTrace()
		if (trace.HitSky) then return end
		if !t:Alive() then 
			t:Spawn()
		end
		t:SetPos(trace.HitPos)
	end);
	oc.notify_fancy( player.GetAll(), '#P teleported #P.', pl, args.players );
end)
cmd:addParam 'players' { type = 'player', 'multi' }

----------------------------------------------------------------
-- Mute Voice                                                --
----------------------------------------------------------------
local cmd = oc.command( 'management', 'mutevoice', function( pl, args )
	oc.ForEach( args.players, function( t )
		if !t.VoiceMuted then
			t.VoiceMuted = true;
			oc.notify_fancy( player.GetAll(), '#P muted #Ps voice', pl, args.players );
		else
			t.VoiceMuted = nil;
			oc.notify_fancy( player.GetAll(), '#P unmuted #Ps voice', pl, args.players );
		end
	end);
end)
cmd:addParam 'players' { type = 'player', 'multi' }

hook.Add( "PlayerCanHearPlayersVoice", "OC.PlayerCanHearPlayersVoice.MuteVoice", function( listener, talker )
	if talker.VoiceMuted then return false end
end)

----------------------------------------------------------------
-- Mute Chat                                                  --
----------------------------------------------------------------
local cmd = oc.command( 'management', 'mutechat', function( pl, args )
	oc.ForEach( args.players, function( t )
		if !t.ChatMuted then
			t.ChatMuted = true;
			oc.notify_fancy( player.GetAll(), '#P muted #Ps chat', pl, args.players );
		else
			t.ChatMuted = nil;
			oc.notify_fancy( player.GetAll(), '#P unmuted #Ps chat', pl, args.players );
		end
	end);
end)
cmd:addParam 'players' { type = 'player', 'multi' }

hook.Add( "PlayerSay", "OC.PlayerSay.MuteChat", function( pl )
	if pl.ChatMuted then return "" end
end)

----------------------------------------------------------------
-- Kick                                                       --
----------------------------------------------------------------
local cmd = oc.command( 'management', 'kick', function( pl, args )
	args.player:Kick( args.reason );
	oc.notify_fancy( player.GetAll(), '#P kicked #P', pl, args.players );
end)
cmd:addParam 'player' { type = 'player' }
cmd:addParam 'reason' { type = 'string', default = '<no reason>', 'fill_line' }

----------------------------------------------------------------
-- Ban                                                        --
----------------------------------------------------------------
local cmd = oc.command( 'management', 'ban', function( pl, args )
	args.player:Ban( args.len, args.reason )
	oc.notify_fancy( player.GetAll(), '#P banned #P for #T.', pl, args.players, args.len );
end)
cmd:addParam 'player' { type = 'player' }
cmd:addParam 'len' { type = 'time' }
cmd:addParam 'reason' { type = 'string', default = '<no reason>', 'fill_line' }

----------------------------------------------------------------
-- Relaod Map                                                 --
----------------------------------------------------------------
local cmd = oc.command( 'utility', 'reload', function( pl )
	RunConsoleCommand( "changelevel", game.GetMap() );
end)

----------------------------------------------------------------
-- Reload all players                                         --
----------------------------------------------------------------
local cmd = oc.command( 'test', 'playerinitialspawn', function( pl, args )
	oc.ForEach( args.players, function( t )
		oc.hook.Call('PlayerInitialSpawn', pl);	
	end);
	oc.notify_fancy( player.GetAll(), '#P re-InitialSpawned #P', pl, args.players );
end)
cmd:addParam 'players' { type = 'player', 'multi' }
