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
local MOTD = { // To do, vars system.
	["zombierp"] = "www.superiorservers.co/forums/index.php?/topic/9-motd/",
	["darkrp"] = "www.superiorservers.co/forums/index.php?/topic/659-buildrp-rules/",
	["purge"] = "www.superiorservers.co/forums/index.php?/topic/550-motd/",
	["sledbuild"] = "www.superiorservers.co/forums/index.php?/topic/784-sledbuild-rules/",
	["Sandbox"] = "www.superiorservers.co/forums/index.php?/topic/9-motd/",
}

local cmd = oc.command( 'utility', 'motd', function( pl )
	if not MOTD[GAMEMODE.Name] then
		oc.notify(pl, oc.cfg.color_error, 'There is no MoTD set for this server!')
		return
	end
end)
cmd:runOnClient(function()
	pTheme.OpenURL("HTML", MoTD[GAMEMODE.Name])	
end)

----------------------------------------------------------------
-- Relaod Map                                                 --
----------------------------------------------------------------
local cmd = oc.command( 'utility', 'reload', function( pl )
	RunConsoleCommand( "changelevel", game.GetMap() );
end)
`