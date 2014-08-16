local PANEL = {};
function PANEL:Init()
	self.image = Material('oc/icon64/prohibited1.png');
	self.col = Color(200,200,200);
	self.hcol = Color(200,55,55);
	self:SetText('');
end
function PANEL:SetImage(path)
	self.image = Material(path);
end
function PANEL:SetHoverColor(hcol)
	self.hcol = hcol;
end
function PANEL:SetPressColor(pcol)
	self.pcol = pcol;
end
function PANEL:SetColor(col)
	self.col = col;
end
function PANEL:Paint(w, h)
	surface.SetMaterial(self.image);
	if self:IsHovered() then
		if not self.pcol or not input.IsMouseDown(MOUSE_LEFT) then
			surface.SetDrawColor(self.hcol);
		else
			surface.SetDrawColor(self.pcol);
		end
	else
		surface.SetDrawColor(self.col);
	end
	surface.DrawTexturedRect(0,0,w,h);
end

vgui.Register('oc_ImageButton', PANEL, 'DButton');