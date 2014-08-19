----------------------------------------------------------------
-- Adminmode                                                  --
----------------------------------------------------------------
local cmd = oc.command( 'utility', 'adminmode', function( pl )
	if not oc.p(pl).AdminMode then
		oc.p(pl).AdminMode = true
		oc.notify_fancy(player.GetAll(), '#P is now administrating.', pl)
	else
		oc.p(pl).AdminMode = false
		oc.notify_fancy(player.GetAll(), '#P is no longer administrating.', pl)
	end
end);

----------------------------------------------------------------
-- MoTD                                                       --
----------------------------------------------------------------
local MoTD = { // To do, vars system.
	["ZombieRP"] = "www.superiorservers.co/forums/index.php?/topic/9-motd/",
	["darkrp"] = "www.superiorservers.co/forums/index.php?/topic/659-buildrp-rules/",
	["purge"] = "www.superiorservers.co/forums/index.php?/topic/550-motd/",
	["sledbuild"] = "www.superiorservers.co/forums/index.php?/topic/784-sledbuild-rules/",
	["Sandbox"] = "www.superiorservers.co/forums/index.php?/topic/9-motd/",
}

local cmd = oc.command( 'utility', 'motd', function( pl )
	if not MoTD[GAMEMODE.Name] then
		oc.notify(pl, oc.cfg.color_error, 'There is no MoTD set for this server!')
		return
	end
end)
cmd:runOnClient(function()
	if not MoTD[GAMEMODE.Name] then return end
	pTheme.OpenURL("HTML", MoTD[GAMEMODE.Name])	
end)

----------------------------------------------------------------
-- Get owner                                                  --
----------------------------------------------------------------
local cmd = oc.command( 'utility', 'go', function( pl )
	local trace = pl.GetEyeTrace(pl)
	if trace.Entity.FPPOwner then
		oc.notify_fancy(pl, trace.Entity:GetClass() .. ' owned by: #P', trace.Entity.FPPOwner)
	else
		oc.notify_fancy(pl, 'This entity has no owner')
	end
end)

----------------------------------------------------------------
-- Sit                                                        --
----------------------------------------------------------------
local Maps = {
	["sup_silenthill_b5"] = Vector(-1795, -3391, 380), // To do, vars system
	["rp_downtown_v4_exl"] = Vector(-2757, 86, 312),
	["rp_c18_v1"] = Vector(-1641, 82, 1744),
}

local cmd = oc.command( 'utility', 'sit', function( pl )
	if not Maps[game.GetMap()] then
		oc.notify(pl, oc.cfg.color_error, 'There is no admin room set for this server!')
		return
	end

	oc.p(pl).LastPos = pl:GetPos()

	local pos = oc.physics.FindEmptyPos(Maps[game.GetMap()], {pl}, 600, 30, Vector(16, 16, 64))
	oc.notify_fancy(player.GetAll(), '#P has went to the admin room.', pl)
end)
cmd:addFlag 'AdminMode'

----------------------------------------------------------------
-- Logs                                                       --
----------------------------------------------------------------
local cmd = oc.command( 'utility', 'logs', function( pl )
	pLogs.OpenMenu(pl)
end)
cmd:addFlag 'AdminMode'

----------------------------------------------------------------
-- Relaod Map                                                 --
----------------------------------------------------------------
local cmd = oc.command( 'utility', 'reload', function( pl )
	RunConsoleCommand( "changelevel", game.GetMap() );
end)
cmd:addFlag 'AdminMode'