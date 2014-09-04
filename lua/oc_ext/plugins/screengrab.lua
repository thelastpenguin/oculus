if SERVER then
	util.AddNetworkString("SG.SendToPlayer")
	util.AddNetworkString("SG.SendToServer")
	util.AddNetworkString("SG.SendToAdmin")

	local Targs = {}

	function ScreenGrabPlayer(admin, targ)
		if Targs[targ:UserID()] then
			return
		end
		
		Targs[targ:UserID()] = {
			admin = admin,
			targ = targ
		}

		net.Start("SG.SendToPlayer")
		net.Send(targ)
	end

	net.Receive("SG.SendToServer", function(len, pl)
		if not Targs[pl:UserID()] then 
			return 
		end

		local data = net.ReadString()

		net.Start("SG.SendToAdmin")
			net.WriteString(data)
			net.WriteString(pl:SteamID())
		net.Send(Targs[pl:UserID()].admin)

		timer.Simple(5, function() // Short cooldown so dip shit admins dont spam it and crash the poor sucker.
			Targs[pl:UserID()] = nil
		end)
	end)
end

if CLIENT then
	local render = render // localize 2 stop hsvkersss
	net.Receive("SG.SendToPlayer", function()
		local info = {
			format = "jpeg",
			h = ScrH(),
			w = ScrW(),
			quality = 1, // There's really no need for quality.
			x = 0,
			y = 0
		}
		local data = util.Base64Encode(render.Capture(info))

		net.Start("SG.SendToServer")
			net.WriteString(data)
		net.SendToServer()
	end)

	net.Receive("SG.SendToAdmin", function()
		local data = net.ReadString()
		local sid = net.ReadString()

		local w, h = ScrW() *.95, ScrH() *.95
		local fr = vgui.Create('DFrame');
		fr:SetTitle("Screengrab: " ..  sid)
		fr:SetSize(w, h)
		fr:MakePopup()
		fr:Center()
		
		local image = vgui.Create("DHTML", fr)
		image:SetPos(10, 25)
		image:SetSize(w - 10, h - 30)
		image:SetHTML([[<img src="data:image/jpeg;base64, ]] .. data .. [[alt="ERROR" height="]] .. h - 50 .. [[" width="]] .. w - 40 .. [["/>]]) // Make it smaller so it doesnt have fugly scrollbars
	end)
end

local cmd = oc.command('utility', 'sg', function(pl, args)
	if SERVER then
		ScreenGrabPlayer(pl, args.player)
	end
	oc.notify_fancy(pl, 'Screengrab started on #P, please allow up to 20 seconds for this to finish.', args.player)
end)
cmd:addParam 'player' { type = 'player' }
