----------------------------------------------------------------
-- Unwanted                                                   --
----------------------------------------------------------------
local cmd = oc.command( 'utility', 'unwant', function( pl, args )
	args.target:unWanted()
	oc.notify_fancy(player.GetAll(), '#P has unwanted #P', pl, args.target)
end)
cmd:addParam 'target' { type = 'player' }
cmd:addFlag 'AdminMode'

// To do, add a large number of commands here.