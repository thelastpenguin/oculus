local txt = {'It looks like you\'re not in our steam group. Every member counts and we urge your to join. Would you like to join?'}
local neverask = CreateClientConVar('req_steamgroup', 1, true, false)

local function SteamGroupReq()
	if GetConVarNumber('req_steamgroup') == 0 then 
		// fagget
		return
	end
	
	local w, h = 500, 205
	local fr = pTheme.Create('SFrame')
	fr:SetSize(w, h)
	fr:SetTitle('Hey!')
	fr:Center()
	fr:MakePopup()

	pTheme.MakeList(txt, 'pTheme.Header', fr, 5, 25, w - 10)

	local yesbtn = pTheme.Create('DButton', fr)
	yesbtn:SetPos(5, 100)
	yesbtn:SetSize(w - 10, 30)
	yesbtn:SetText('Take me there :)')
	function yesbtn:DoClick()
		pTheme.OpenURL('GUI', 'steamcommunity.com/gid/103582791434605559/')
		pTheme.Close(fr)
	end

	local maybbtn = pTheme.Create('DButton', fr)
	maybbtn:SetPos(5, 135)
	maybbtn:SetSize(w - 10, 30)
	maybbtn:SetText('Ask me next time')
	function maybbtn:DoClick()
		pTheme.Close(fr)
	end

	local nobtn = pTheme.Create('DButton', fr)
	nobtn:SetPos(5, 170)
	nobtn:SetSize(w - 10, 30)
	nobtn:SetText('Never ask me again')
	function nobtn:DoClick()
		RunConsoleCommand('req_steamgroup', '0')
		pTheme.Close(fr)
	end

end

oc.hook.Add('PlayerInitialSpawn', 'oc.steamGroupReq.PlayerInitialSpawn', function(pl)	
	http.Fetch('http://steamcommunity.com/gid/103582791434605559/memberslistxml/?xml=1', function(body, len, headers, code)
		if not string.find(body, LocalPlayer():SteamID64()) then
			SteamGroupReq()
		end
	end)
end)