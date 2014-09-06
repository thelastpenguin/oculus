/******************************************************************************
*                                PenguinTheme                                 *
*                         Derma_StringRequest Overwrite                       *
******************************************************************************/

function pTheme.StringReq(title, text, default, cb)
	local menu = pTheme.Create("pFrame")
	menu:SetTitle(title)
	menu:ShowCloseButton(false)
	menu:SetWide(ScrW() * .3)

	
	local txt = pTheme.WordWrap("pTheme.LblMed", text, menu:GetWide() - 10)
	local y = 25
	
	for k, v in pairs(txt) do
		local lbl = pTheme.Create("DLabel", menu)
		lbl:SetText(v)
		lbl:SetFont("pTheme.LblMed")
		lbl:SizeToContents()
		lbl:SetPos((menu:GetWide() - lbl:GetWide()) / 2, y)
		
		if (k != #txt) then y = y + lbl:GetTall() end
	end
	
	local tb = pTheme.Create("DTextEntry", menu)
	tb:SetPos(menu:GetWide() * .25, y + 5)
	tb:SetWide(menu:GetWide() * .5)
	tb:SetValue(default or "")
	y = y + tb:GetTall() + 10
	tb.OnEnter = function(s)
		cb(s:GetValue())
		menu:Close()
	end
	
	local btnOK = pTheme.Create("DButton", menu)
	btnOK:SetText("Okay")
	btnOK:SetPos(5, y)
	btnOK:SetWide((menu:GetWide() - 15) / 2)
	btnOK.DoClick = function(s)
		cb(tb:GetValue())
		menu:Close()
	end
	
	local btnCan = pTheme.Create("DButton", menu)
	btnCan:SetText("Cancel")
	btnCan:SetPos(btnOK:GetWide() + 10, y)
	btnCan:SetWide(btnOK:GetWide())
	btnCan.DoClick = function(s)
		menu:Close()
	end
	
	y = y + btnCan:GetTall() + 5
	
	menu:SetTall(y)
	menu:Center()
	menu:MakePopup()
end

Derma_StringRequest = pTheme.StringReq