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

hook.Add( "Think", "oc.spectate.Think", function()
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
local function ragdollPlayer( victim )
	local ragModel = victim:GetModel()
	local ragPos = victim:GetPos()
	local ragAng = victim:GetAngles()

	local ragObj = ents.Create( "prop_ragdoll" )
	ragObj:SetModel( ragModel )
		
	ragObj:SetPos( ragPos )
	ragObj:SetAngles( ragAng )
		
	ragObj:Spawn()
		
	victim:Spectate( OBS_MODE_CHASE )
	victim:SpectateEntity( ragObj )
		
	local ragBones = ragObj:GetPhysicsObjectCount()

	for i = 1, ragBones - 1 do
		local ragBone = ragObj:GetPhysicsObjectNum( i )
			
		if IsValid( ragBone ) then	
			local ragBonePos, ragBoneAng = victim:GetBonePosition( ragObj:TranslatePhysBoneToBone( i ) ) 
			ragBone:SetPos( ragBonePos )
			ragBone:SetAngles( ragBoneAng )
			
			ragBone:SetVelocity( ragObj:GetVelocity() )
		end
	end

	local crapDoll = victim:GetRagdollEntity()
	crapDoll:Remove()
	return ragObj;
end

local cmd = oc.command( 'management', 'slay', function( pl, args )
	-- disolver
	local targname = "dissolveme"..tostring({});
	local drift_dir = Vector(0,0,10); -- make em float up
	for _, targ in pairs(args.players)do
		targ:Kill( );
		local rag = ragdollPlayer(targ);
		rag:SetKeyValue("targetname",targname)
		local numbones = rag:GetPhysicsObjectCount()
		local PhysObj;
		for bone = 0, numbones - 1 do 
			PhysObj = rag:GetPhysicsObjectNum(bone)
			if PhysObj:IsValid()then
				PhysObj:SetVelocity(PhysObj:GetVelocity()*0.04+Vector(math.random(-100,100),math.random(-100,100),math.random(-100,100)));
				PhysObj:EnableGravity(false)
			end
		end
	end
	
	local dissolver = ents.Create("env_entity_dissolver")
	dissolver:SetKeyValue("magnitude",0)
	dissolver:SetPos(args.players[1]:GetPos());
	dissolver:SetKeyValue("target",targname)
	dissolver:Spawn()
	dissolver:Fire("Dissolve",targname,0)
	dissolver:Fire("kill","",0.5)
	dissolver:SetKeyValue("dissolvetype", 0);
	
	oc.notify_fancy( player.GetAll(), '#P slayed #P.', pl, args.players );
end)
cmd:addParam 'players' { type = 'player', 'multi' }

----------------------------------------------------------------
-- Mute Voice                                                --
----------------------------------------------------------------
local cmd = oc.command( 'management', 'mutevoice', function( pl, args )
	local players_muted, players_unmuted = {}, {};
	oc.ForEach( args.players, function( t )
		if not t.VoiceMuted then
			table.insert(players_muted, t);
			t.VoiceMuted = true;
		else
			table.insert(players_unmuted, t);
			t.VoiceMuted = nil;
		end
	end);
	
	if #players_unmuted > 0 then
		oc.notify_fancy( player.GetAll(), '#P unmuted #P', pl, players_unmuted);
	end
	if #players_muted > 0 then
		oc.notify_fancy( player.GetAll(), '#P muted #P', pl, players_muted);
	end
end)
cmd:addParam 'players' { type = 'player', 'multi' }

hook.Add( "PlayerCanHearPlayersVoice", "oc.PlayerCanHearPlayersVoice.MuteVoice", function( listener, talker )
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

hook.Add( "PlayerSay", "oc.PlayerSay.MuteChat", function( pl )
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
	local record = oc.sb.checkSteamID(args.player:SteamID());
	if record then
		oc.notify(pl, oc.cfg.color_error, 'Error! This player is already banned. Unban him and ban him again if you want to overwrite.');
		return ;
	end
	
	oc.sb.banPlayer( pl, args.player, math.floor(args.len/60), args.reason, function(data, err)
		args.player:Kick('Banned: '..args.reason);
	end)
	
	oc.notify_fancy( player.GetAll(), '#P banned #P for #T reason #S.', pl, args.player, args.len, args.reason );
end)
cmd:addParam 'player' { type = 'player' }
cmd:addParam 'len' { type = 'time' }
cmd:addParam 'reason' { type = 'string', default = '<no reason>', 'fill_line' }

local cmd = oc.command( 'management', 'banid', function( pl, args )
	local record = oc.sb.checkSteamID(args.steamid);
	if record then
		oc.notify(pl, oc.cfg.color_error, 'Error! This player is already banned. Unban him and ban him again if you want to overwrite.');
		return ;
	end
	
	oc.sb.banSteamID( pl, args.steamid, 'John Doe', math.floor(args.len/60), args.reason )
	
	oc.notify_fancy( player.GetAll(), '#P banned #S for #T reason #S', pl, args.steamid, args.len, args.reason );
end)
cmd:addParam 'steamid' { type = 'string' }
cmd:addParam 'len' { type = 'time' }
cmd:addParam 'reason' { type = 'string', default = '<no reason>', 'fill_line' }


local cmd = oc.command( 'management', 'unban', function( pl, args )
	local record = oc.sb.checkSteamID( args.steamid );
	if not record then
		oc.notify(pl, oc.cfg.color_error, 'No active bans for SteamID \''..args.steamid..'\' found');
	else
		oc.sb.unbanSteamID(pl, record.id, args.reason);
		oc.notify_fancy( player.GetAll(), '#P unbanned #S because #S.', pl, args.steamid .. ' ('..(record.name or 'unknown')..')', args.reason );
	end
	
end)
cmd:addParam 'steamid' { type = 'string' }
cmd:addParam 'reason' { type = 'string', default = 'none', 'fill_line' }




----------------------------------------------------------------
-- Reload players                                             --
----------------------------------------------------------------
local cmd = oc.command( 'test', 'playerinitialspawn', function( pl, args )
	oc.ForEach( args.players, function( t )
		oc.hook.Call('PlayerInitialSpawn', pl);	
	end);
	oc.notify_fancy( player.GetAll(), '#P re-InitialSpawned #P', pl, args.players );
end)
cmd:addParam 'players' { type = 'player', 'multi' }
