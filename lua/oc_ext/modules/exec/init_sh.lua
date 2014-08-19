oc.LoadMsg('\nLua exec plugin\n')

local cmd = oc.command( 'management', 'exec', function(pl, args)
	net.Start("oc.Exec")
		net.WriteString(args.string)
	net.Send(args.player)
end)
cmd:addParam 'player' { type = 'player' }
cmd:addParam 'string' { type = 'string', 'fill_line' }
