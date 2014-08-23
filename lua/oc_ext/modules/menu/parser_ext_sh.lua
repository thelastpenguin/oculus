local paramtype_mt = oc.parser.paramtype_mt;

function paramtype_mt:genVGUIPanel(param, parent)
	if not self.vguiGenerator then return end
	local panel = self.vguiGenerator(param)
	panel:SetParent(parent);
	panel:Dock(TOP);
	return panel;
end

function paramtype_mt:setVGUIGenerator(func)
	self.vguiGenerator = func;	
end




local function makeScrollPanel(panel)
	local spanel = vgui.Create('DScrollPanel', panel);
	function spanel.VBar:Paint( w, h ) end
	function spanel.VBar.btnGrip:Paint( w, h )
		surface.SetDrawColor( 100,100,100,255 );
		surface.DrawRect( 0, 0, w, h );
	end
	function spanel.VBar.btnUp:Paint() end
	function spanel.VBar.btnDown:Paint() end
	spanel.VBar:SetWide(5);
	return spanel;
end

