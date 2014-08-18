if (SERVER) then
	util.AddNetworkString("oc.TellAll")
elseif (CLIENT) then
	surface.CreateFont("oc.TellAll.Font", {font = "coolvetica",size = 40,weight = 800})

	net.Receive("oc.TellAll", function()
		local str = net.ReadString()

		surface.SetFont("oc.TellAll.Font")

		local w = surface.GetTextSize(str) + 20
		local x, y = 10, 25
		local msg

		if w < 100 then
			w = 175
			x = 175/2 - surface.GetTextSize(str)/2
		end

		if w < ScrW() * .8 then
			msg = {str}
		elseif w > ScrW() * .8 then
			w = ScrW() * .8
			msg = pTheme.WordWrap("oc.TellAll.Font", str, w - 20)
		end

		local fr = pTheme.Create("pFrame")
		fr:SetSize(w, 65 + (#msg - 1) * 30)
		fr:SetTitle("Staff Message!", Color(255,0,0))
		fr:ShowCloseButton(false)
		fr:SetPos(ScrW()/2 - fr:GetWide()/2, 100)

		for k, txt in pairs(msg) do
			local lbl = pTheme.Create("DLabel", fr)
			lbl:SetFont("oc.TellAll.Font")
			lbl:SetText(txt)
			lbl:SizeToContents()
			lbl:SetPos(x, y)
			if (k != #msg) then 
				y = y + lbl:GetTall()
			end
		end

		timer.Simple(10, function()
			pTheme.Close(fr)
		end)
	end)
end

local cmd = oc.command('utility', true, 'tellall', function(pl, args)
	if (SERVER) then
		net.Start("oc.TellAll")
			net.WriteString(args.msg)
		net.Broadcast()
	end
	oc.notify_fancy(player.GetAll(), '#P has sent a staff message to the server.', pl)
end)
cmd:addParam 'msg' { type = 'string', 'fill_line' }
