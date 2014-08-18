local cmd = oc.command( 'information', 'help', function( pl, args )
	oc.notify_fancy(pl, 'See console for output.')
end)
cmd:runOnClient(function()
	local col = Color(200,200,200);
		for k,v in SortedPairs(oc.commands)do
			local canUse = v:playerCanUse(LocalPlayer());
			MsgC(canUse and oc.cfg.color_success or oc.cfg.color_error, string.format('%-30s', k) )
			local help = v:getHelp() or 'no description';
			MsgC(col, ' - '..help..'\n');
		end
end);
cmd:setHelp 'get a list of all commands that you can access'