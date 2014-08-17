----------------------------------------------------------------
-- Goto                                                      --
----------------------------------------------------------------
local cmd = oc.command( 'movement', true, 'goto', function(pl, args)
	local pos = args.target:GetPos();
	pos = oc.physics.FindEmptyPos(pos, {pl}, 600, 30, Vector(16, 16, 64))
	
	pl:SetPos(pos)

	oc.notify_fancy(player.GetAll(), '#P went to #P.', pl, args.target)
end)
cmd:addParam 'target' { type = 'player' }

----------------------------------------------------------------
-- Tele                                                       --
----------------------------------------------------------------
local cmd = oc.command( 'movement', true, 'tele', function(pl, args)
	if !args.target:Alive() then
		args.target:Spawn()
	end

	oc.p(args.target).LastPos = args.target:GetPos()

	local trace = pl.GetEyeTrace(pl)
	local pos = oc.physics.FindEmptyPos(trace.HitPos, {pl}, 600, 30, Vector(16, 16, 64))

	args.target:SetPos(pos)

	oc.notify_fancy(player.GetAll(), '#P has teleported #P.', pl, args.target)
end)
cmd:addParam 'target' { type = 'player' }

----------------------------------------------------------------
-- Return                                                     --
----------------------------------------------------------------
local cmd = oc.command( 'movement', true, 'return', function(pl, args)
	if !oc.p(args.target).LastPos then
		oc.notify(pl, oc.cfg.color_error, 'This player has no last know position!')
		return
	end

	local pos = oc.physics.FindEmptyPos(oc.p(args.target).LastPos, {pl}, 600, 30, Vector(16, 16, 64))
	
	args.target:SetPos(pos)
	oc.p(args.target).LastPos = nil
	
	oc.notify_fancy(player.GetAll(), '#P has returned #P.', pl, args.target)
end)
cmd:addParam 'target' { type = 'player' }

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

local cmd = oc.command( 'movement', true, 'noclip', function( pl, args, meta )
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
	if oc.p(pl):getPerm(cmd_noclip.perm) && oc.canAdmin(pl) then
		return true
	else
		if SERVER && !oc.p(pl):getPerm(cmd_noclip.perm) then 
			oc.notify(pl, oc.cfg.color_error, 'You need permission \'move.noclip\' to noclip!') 
		elseif SERVER && !oc.canAdmin(pl) then
			oc.notify(pl, oc.cfg.color_error, 'Please enter adminmode to noclip.') 
		end
		return false
	end
end);

----------------------------------------------------------------
-- Physgun Player                                             --
----------------------------------------------------------------
local physgun_perm = 'plugin.PhysgunPickup.Player';
oc.perm.register(physgun_perm);

hook.Add('PhysgunPickup', 'oc.PhysgunPickup.PlayerPhysgun', function( pl, ent )
	if ent:IsPlayer() && oc.p(pl):getPerm(physgun_perm) && oc.canTarget(pl, ent) && oc.canAdmin(pl) then // and and and
		ent:Freeze(true)
		ent:SetMoveType(MOVETYPE_NOCLIP)
		return true
	end
end)

hook.Add('PhysgunDrop', 'oc.PhysgunDrop.PlayerPhysgun', function( pl, ent )
	if ent:IsPlayer() then 
		ent:Freeze(false) 
		ent:SetMoveType(MOVETYPE_WALK) 
	end
end)
