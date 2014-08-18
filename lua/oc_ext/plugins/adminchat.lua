if (SERVER) then
	util.AddNetworkString("oc.AdminChat")

	oc.hook.Add("PlayerSay", function(pl, text)
		if text:sub(1,1) == "@" then
			local recipiants = xfn.filter(player.GetAll(), function(pl)
				return pl:IsAdmin()
			end);
			
			local isAdmin = pl:IsAdmin();
			oc.notify(recipiants, isAdmin and Color(51, 128, 255) or Color(255, 50, 255), isAdmin and '[STAFF] ' or '[TO STAFF]', team.GetColor(pl:Team()), pl:Name(), color_white, ':'.. text:sub(2));
			return ""
		end
	end)
	
end
