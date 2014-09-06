if SERVER then
	util.AddNetworkString("_AntiCrash")

	timer.Create("AntiCrash", 5, 0, function()
		net.Start("_AntiCrash")
		net.Send(player.GetAll())
	end) 
end


if CLIENT then
	surface.CreateFont ("AntiCrash.Font", {
		font = "coolvetica",
		size = 50,
		weight = 300
	})

	local NextReTry = false
	local IsCrashed = false
	local ReconnectTime = 0

	local color_white = Color(255,255,255)
	local color_black = Color(0,0,0)

	local function StartAutoconect()
		LocalPlayer():ChatPrint("Connection to server lost.") 
		LocalPlayer():ChatPrint("You will be reconnected shortly if connection is not re-established!")

		ReconnectTime = CurTime() + 30

		if IsValid(Crash_Frame) then Crash_Frame:Remove() end

		Crash_Frame = vgui.Create("DFrame")
		Crash_Frame:SetSize(475, 125)
		Crash_Frame:SetPos(ScrW(), 0)
		Crash_Frame:MoveTo(ScrW() - 475, 0, 0.3, 0, 1)
		Crash_Frame:SetTitle("")
		Crash_Frame:ShowCloseButton(false)
		Crash_Frame.btnMinim:SetVisible(false)
		Crash_Frame.btnMaxim:SetVisible(false)
		function Crash_Frame:Paint(w, h)
			local delta = ReconnectTime - CurTime()

			draw.RoundedBox(0, 0, 0,w, h , color_black)

			surface.SetDrawColor(delta % 1 < 0.2 and Color(255,0,0) or color_white)
			surface.DrawOutlinedRect(0, 0, w, h)

			draw.SimpleText("Uh Oh, reconnecting in:", "AntiCrash.Font", w/2, 10, color_white, TEXT_ALIGN_CENTER)
			draw.SimpleText(math.ceil(delta), "AntiCrash.Font", w*0.5, 75, delta % 1 < 0.2 and Color(255,0,0) or color_white, TEXT_ALIGN_CENTER)
		end
	end

	net.Receive("_AntiCrash", function()
		//print("AntiCrash got ping")
		NextReTry = CurTime() + 10
		IsCrashed = false
		if IsValid(Crash_Frame) then
			Crash_Frame:Remove()
		end
	end)

	hook.Add("Think", "AntiCrash.Think", function()
		if NextReTry && !IsCrashed then
			if NextReTry < CurTime() then
				IsCrashed = true
				StartAutoconect()
			end
		end
		if IsCrashed then
			//print(ReconnectTime - CurTime())
			if ReconnectTime <= CurTime() then
				RunConsoleCommand("retry")
			end 
		end
	end)
end