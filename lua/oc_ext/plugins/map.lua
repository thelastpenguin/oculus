----------------------------------------------------------------
-- Relaod Map                                                 --
----------------------------------------------------------------
local cmd = oc.command( 'utility', 'reload', function( pl )
	RunConsoleCommand( "changelevel", game.GetMap() );
end)