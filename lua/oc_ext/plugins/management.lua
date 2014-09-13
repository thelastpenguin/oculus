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
cmd:addFlag 'AdminMode'
cmd:addParam 'players' { type = 'player', 'multi' }

----------------------------------------------------------------
-- Spectate                                                   --
----------------------------------------------------------------
local specPlayers = {}
local cmd = oc.command( 'management', 'spectate', function(pl, args)
 	if !pl:Alive() then
 		oc.notify(pl, oc.cfg.color_error, 'Please respawn before attempting to spectate.')
 		return
 	end
	if !oc.p(pl).Spec then
		oc.p(pl).PreSpecPos = pl:GetPos()
		specPlayers[pl] = args.player

		pl:StripWeapons()
		pl:Flashlight(false)
		pl:Spectate(5)
		pl:SpectateEntity(args.player)

		oc.p(pl).Spec = true
	end
end)
cmd:addParam 'player' { type = 'player' }
cmd:addFlag 'AdminMode'

local cmd = oc.command( 'management', 'unspectate', function(pl, args)
 	if oc.p(pl).Spec then
		pl:UnSpectate()
		pl:Spawn()
		pl:SetPos(oc.p(pl).PreSpecPos)

		oc.p(pl).PreSpecPos = nil
		oc.p(pl).Spec = nil
 	else
 		oc.notify(pl, oc.cfg.color_error, 'You\'re not spectating anyone!')
 	end
end)

cmd:addFlag 'AdminMode'
 
hook.Add("Think", "oc.spectate.Think", function() // oc.hook.Add doesnt clal this for some reason
	for k, v in pairs(specPlayers) do
		if (!k:IsValid() or !v:IsValid()) then
			specPlayers[k] = nil;
 		end
 		if oc.p(k).PreSpecPos then
			k:SetPos(v:EyePos());
		end
 	end
end)

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
	if IsValid(pl) then
		if not oc.p(pl).NextSlay or oc.p(pl).NextSlay < CurTime() then
			oc.p(pl).NextSlay = CurTime() + 2
		elseif oc.p(pl).NextSlay > CurTime() then
			oc.notify(pl, oc.cfg.color_error, 'Please wait ' .. math.ceil(oc.p(pl).NextSlay - CurTime()) .. ' seconds to do this again!' );
			return
		end
	end
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
end);
cmd:addFlag 'AdminMode'
cmd:addParam 'players' { type = 'player', 'multi' }

----------------------------------------------------------------
-- Mute Voice                                                --
----------------------------------------------------------------
local cmd = oc.command( 'management', 'mute voice', function( pl, args )
	oc.ForEach(args.players, function(t)
		oc.p(t).VoiceMuted = true;	
	end);
	
	oc.notify_fancy( player.GetAll(), '#P muted #P', pl, args.players);
end)
cmd:addParam 'players' { type = 'player', 'multi' }
cmd:addFlag 'AdminMode';

local cmd = oc.command( 'management', 'unmute voice', function( pl, args )
	oc.ForEach(args.players, function(t)
		oc.p(t).VoiceMuted = nil;
	end);
	
	oc.notify_fancy( player.GetAll(), '#P unmuted #P', pl, args.players);
end)
cmd:addParam 'players' { type = 'player', 'multi' }
cmd:addFlag 'AdminMode';

oc.hook.Add("PlayerCanHearPlayersVoice", function( listener, talker )
	if oc.p(talker).VoiceMuted then return false, false end
end)

----------------------------------------------------------------
-- Mute Chat                                                  --
----------------------------------------------------------------
local cmd = oc.command( 'management', 'mute chat', function( pl, args )
	oc.ForEach(args.players, function(t)
		oc.p(t).ChatMuted = true;
	end);
	oc.notify_fancy(player.GetAll(), '#P chat muted #P', pl, args.players);
end)
cmd:addParam 'players' { type = 'player', 'multi' }
cmd:addFlag 'AdminMode';

local cmd = oc.command( 'management', 'unmute chat', function( pl, args )
	oc.ForEach(args.players, function(t)
		oc.p(t).ChatMuted = nil;
	end);
	oc.notify_fancy(player.GetAll(), '#P chat unmuted #P', pl, args.players);
end)
cmd:addParam 'players' { type = 'player', 'multi' }
cmd:addFlag 'AdminMode';

oc.hook.Add("PlayerSay", function( pl )
	if oc.p(pl).ChatMuted then return "" end
end)

----------------------------------------------------------------
-- Kick                                                       --
----------------------------------------------------------------
local cmd = oc.command( 'management', 'kick', function( pl, args )
	oc.notify_fancy( player.GetAll(), '#P kicked #P for #S', pl, args.player, args.reason );
	args.player:Kick( args.reason );
end)
cmd:addParam 'player' { type = 'player' }
cmd:addParam 'reason' { type = 'string', 'fill_line' }

----------------------------------------------------------------
-- Ban                                                        --
----------------------------------------------------------------
local cmd = oc.command( 'management', 'ban', function( pl, args )

	local playerObj;
	for k,v in pairs(player.GetAll())do
		if v:SteamID() == args.steamid then
			playerObj = v;
		end
	end
	
	local record = oc.sb.checkSteamID(args.steamid);
	if record then
		oc.notify(pl, oc.cfg.color_error, 'Error! This player is already banned. Unban him and ban him again if you want to overwrite.');
		if playerObj then playerObj:Kick("banned"); end
		return ;
	end
	
	if playerObj then
		oc.sb.banPlayer( pl, playerObj, math.floor(args.len/60), args.reason, function(data, err)
			oc.notify_fancy( player.GetAll(), '#P banned #P for #T reason #S.', pl, args.player, args.len, args.reason );
			game.ConsoleCommand('kickid '..args.player:SteamID()..' "'..args.reason..'"\n');
		end);
	else
		oc.sb.banSteamID( pl, args.steamid, 'John Doe', math.floor(args.len/60), args.reason )
		oc.notify_fancy( player.GetAll(), '#P banned #S for #T reason #S', pl, args.steamid, args.len, args.reason );
	end
end)
cmd:addParam 'steamid' { type = 'steamid' }
cmd:addParam 'len' { type = 'time' }
cmd:addParam 'reason' { type = 'string', 'fill_line' }

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
cmd:addParam 'reason' { type = 'string', 'fill_line' }
