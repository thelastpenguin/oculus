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
local cmd = oc.command('utility', 'motd', function(pl)
	if not oc.getServerVar('motd') then
		oc.notify(pl, oc.cfg.color_error, 'There is no MoTD set for this server!')
		return
	end
end)
cmd:runOnClient(function()
	if not oc.getServerVar('motd') then return end
	pTheme.OpenURL('HTML', oc.getServerVar('motd'))
end)

oc.hook.Add('ServerVarsLoaded', function(pl)
	pl:ConCommand('oc motd')
end)

local cmd = oc.command('utility', 'setmotd', function(pl, args)
	oc.setServerVar('motd', args.link)
end)
cmd:addParam 'link' { type = 'string', 'fill_line' }

----------------------------------------------------------------
-- Sit                                                        --
----------------------------------------------------------------
local cmd = oc.command( 'utility', 'sit', function( pl )
	if not oc.getServerVar('adminroom') then
		oc.notify(pl, oc.cfg.color_error, 'There is no admin room set for this server!')
		return
	end

	oc.p(pl).LastPos = pl:GetPos()

	local pos = oc.physics.FindEmptyPos(oc.getServerVar('adminroom'), {pl}, 600, 30, Vector(16, 16, 64))
	pl:SetPos(pos)
	
	oc.notify_fancy(player.GetAll(), '#P has went to the admin room.', pl)
end)
cmd:addFlag 'AdminMode'

local cmd = oc.command('utility', 'setadminroom', function(pl)
	oc.setServerVar('adminroom', pl:GetPos())
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
