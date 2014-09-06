/******************************************************************************
*                                PenguinTheme                                 *
*                    Various needed and convenience functions                 *
******************************************************************************/

local vgui = vgui
local table = table
local surface = surface
local pairs = pairs 
local string = string
local type = type

pTheme.OpenWindows = {}

local VguiFucs = {
	["pFrame"] = function(panel)
		pTheme.CloseAll()
		//table.insert(OpenWindows, panel)
	end,
	["DButton"] = function(btn) // We do this in the skin itself to style defualt menus but paint functions override that in custom ones, so instead of detouring vgui.create we do this.
		local TextCol = pTheme.Background
		if btn.Hovered then
			TextCol = pTheme.Outline
		end
		btn:SetTextColor(TextCol)
		btn:SetFont("pTheme.Button")
	end
}

function pTheme.Create(type, parent, func)
	local element = vgui.Create(type, parent or nil)

	if func then
		func()
	end

	if VguiFucs[type] then
		VguiFucs[type](element)
	end
	
	return element
end

function pTheme.Close(element)
	if table.HasValue(pTheme.OpenWindows, element) then
		table.RemoveByValue(pTheme.OpenWindows, element)	
	end

	element:Remove()
end

function pTheme.CloseAll()
	for k, v in pairs(pTheme.OpenWindows) do
		v:Remove()
		table.RemoveByValue(pTheme.OpenWindows, v)
	end
end

function pTheme.WordWrap(font, text, width)
	if type(text) == "string" then
		text = text
	elseif type(text) == "table" then
		text = table.concat(text)
	end

	surface.SetFont(font)
	
	local sw, sh = surface.GetTextSize(" ")
	local ret = {}
	
	local w = 0
	local s = ""
	for i, l in pairs(string.Explode("\n", text, false)) do
		for k, v in pairs(string.Explode(" ", l)) do
			local neww = surface.GetTextSize(v)
			
			if (w + neww >= width) then
				table.insert(ret, s)
				w = neww + sw
				s = v .. " "
			else
				s = s .. v .. " "
				w = w + neww + sw
			end
		end
		table.insert(ret, s)
		w = 0
		s = ""
	end
	
	table.insert(ret, s)
	
	return ret
end

function pTheme.GetSize(element)
	return element:GetWide(), element:GetTall()
end

function pTheme.OpenURL(type, url)
	if type == "GUI" then
		gui.OpenURL("http://" .. url)
	elseif type == "HTML" then
		pTheme.CloseAll()
		local fr = pTheme.Create("pFrame")
		fr:SetSize(ScrW() * .9, ScrH() * .9)
		fr:Center()
		fr:SetTitle(url)
		fr:MakePopup()

		local w, h = pTheme.GetSize(fr)
		local htm = pTheme.Create("HTML", fr)
		htm:SetPos(10,25)
		htm:SetSize(w - 20, h - 35)
		htm:OpenURL("http://" .. url)
		return fr
	else
		LocalPlayer():ChatPrint("can u even vgui")
	end
end

function pTheme.MakeList(tbl, font, parent, x, y, w) // Loopity loopdedo
	for k, v in pairs(tbl) do
		local WrappedText = pTheme.WordWrap(font, v, w)
		for k2, txt in pairs(WrappedText) do
			local lbl = pTheme.Create("DLabel", parent)
			lbl:SetFont(font)
			lbl:SetText(txt)
			lbl:SizeToContents()
			lbl:SetPos(x, y)
			if (k2 != #WrappedText) then y = y + lbl:GetTall() end
		end
	end
	return lbl
end
