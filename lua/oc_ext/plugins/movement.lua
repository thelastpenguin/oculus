local function playerSend( from, to, force )
	if not to:IsInWorld() and not force then return false end

	local yawForward = to:EyeAngles().yaw
	local directions = {
		math.NormalizeAngle( yawForward - 180 ), 
		math.NormalizeAngle( yawForward + 90 ),
		math.NormalizeAngle( yawForward - 90 ),
		yawForward,
	}

	local t = {}
	t.start = to:GetPos() + Vector( 0, 0, 32 )
	t.filter = { to, from }

	local i = 1
	t.endpos = to:GetPos() + Angle( 0, directions[ i ], 0 ):Forward() * 47
	local tr = util.TraceEntity( t, from )
	while tr.Hit do
		i = i + 1
		if i > #directions then
			if force then
				from.ulx_prevpos = from:GetPos()
				from.ulx_prevang = from:EyeAngles()
				return to:GetPos() + Angle( 0, directions[ 1 ], 0 ):Forward() * 47
			else
				return false
			end
		end

		t.endpos = to:GetPos() + Angle( 0, directions[ i ], 0 ):Forward() * 47

		tr = util.TraceEntity( t, from )
	end

	from.ulx_prevpos = from:GetPos()
	from.ulx_prevang = from:EyeAngles()
	return tr.HitPos
end

----------------------------------------------------------------
-- Goto                                                      --
----------------------------------------------------------------
local cmd = oc.command( 'movement', 'goto', function( pl, args )
	local succ = playerSend(pl, args.target, pl:GetMoveType() == MOVETYPE_NOCLIP);
	if not succ then
		oc.notify(oc.cfg.color_error, 'No where to put you! Go into noclip to bipass this.');
	else
		oc.notify_fancy( player.GetAll(), '#P went to #P.', pl, args.target );
	end
end)
cmd:addParam 'target' { type = 'player' }

----------------------------------------------------------------
-- Bring                                                      --
----------------------------------------------------------------
local cmd = oc.command( 'movement', 'bring', function( pl, args )
	local succ = playerSend(args.target, pl, args.target:GetMoveType() == MOVETYPE_NOCLIP);
	if not succ then
		oc.notify(oc.cfg.color_error, 'No where to put them! Noclip target to bipass this.');
	else
		oc.notify_fancy( player.GetAll(), '#P brought #P.', pl, args.target );
	end
end)
cmd:addParam 'target' { type = 'player' }

----------------------------------------------------------------
-- Send                                                       --
----------------------------------------------------------------
local cmd = oc.command( 'movement', 'bring', function( pl, args )
	local succ = playerSend(args.send, args.to, args.send:GetMoveType() == MOVETYPE_NOCLIP);
	if not succ then
		oc.notify(oc.cfg.color_error, 'No where to put them! Noclip the player you are sending to bipass this.');
	else
		oc.notify_fancy( player.GetAll(), '#P sent #P to #P.', pl, args.send, args.to );
	end
end)
cmd:addParam 'send' { type = 'player', help = 'player to send' }
cmd:addParam 'to' { type = 'player', help = 'target player' }

----------------------------------------------------------------
-- Noclip                                                     --
----------------------------------------------------------------
local function toggleFlying(pl)
	local mt = pl:GetMoveType();
	if mt == MOVETYPE_NOCLIP then
		pl:SetMoveType(MOVETYPE_WALK);
		return true;
	elseif mt == MOVETYPE_WALK then
		pl:SetMoveType(MOVETYPE_NOCLIP);
		return true;
	else
		return false;
	end
end

local cmd = oc.command( 'movement', 'noclip', function( pl, args, meta )
	if args.target ~= pl then
		if meta:playerGetExtraPerm('others') then
			if not toggleFlying(args.target) then
				oc.notify(pl, oc.cfg.color_error, 'failed to toggle noclip');
			else
				oc.notify_fancy(pl, 'You noclipped #P.', args.target);
				oc.notify_fancy(args.target, 'You were noclipped by #P.', pl);
			end
		else
			oc.notify(pl, oc.cfg.color_error, 'you can\'t noclip other players!');
		end
	else
		if not toggleFlying(args.target) then
			oc.notify(pl, oc.cfg.color_error, 'failed to toggle noclip');
		else
			oc.notify_fancy(pl, 'You noclipped yourself');
		end
	end
end)
local cmd_noclip = cmd;
cmd:addExtraPerm 'others';
cmd:addParam 'target' { type = 'player', help = 'player to noclip', default = function(pl) return pl end }

hook.Add('PlayerNoClip', 'oc.permCheck.PlayerNoClip', function(pl)
	local canNoclip = oc.p(pl):getPerm(cmd_noclip.perm);
	if canNoclip then
		return true
	else
		oc.notify(pl, oc.cfg.color_error, 'You need permission \'move.noclip\' to noclip!');
		return false
	end
end);

----------------------------------------------------------------
-- Physgun Player                                             --
----------------------------------------------------------------
local cmd = oc.command( 'movement', 'physgun', function( pl ) // Temp hack job
	oc.notify(pl, oc.cfg.color_error, 'Don\'t use the command');
end)
local cmd_physgun = cmd;
cmd:addExtraPerm 'others';
// oc.registerPerm('physgun')

hook.Add('PhysgunPickup', 'oc.PhysgunPickup.PlayerPhysgun', function( pl, ent )
	local canPhys = oc.p(pl):getPerm(cmd_physgun.perm)
	if ent:IsPlayer() && canPhys then
		ent:Freeze(true)
		ent:SetMoveType(MOVETYPE_NOCLIP)
		return true
	else
		return false
	end
end)

hook.Add('PhysgunDrop', 'oc.PhysgunDrop.PlayerPhysgun', function( pl, ent )
	if ent:IsPlayer() then 
		ent:Freeze(false) 
		ent:SetMoveType(MOVETYPE_WALK) 
	end
end)
