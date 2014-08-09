
if CLIENT then
	net.Receive('oc.cmd.displayhelp', function()
		local col = Color(200,200,200);
		for k,v in SortedPairs(oc.commands)do
			local canUse = v:playerCanUse(LocalPlayer());
			MsgC(canUse and oc.cfg.color_success or oc.cfg.color_error, string.format('%-30s', k) )
			local help = v:getHelp() or 'no description';
			MsgC(col, ' - '..help..'\n');
		end
	end);
else
	util.AddNetworkString('oc.cmd.displayhelp');
end

-- group add perm
local cmd = oc.command( 'information', 'help', function( pl, args )
	net.Start('oc.cmd.displayhelp');
	net.Send(pl);
end)
cmd:setHelp 'get a list of all commands that you can access'