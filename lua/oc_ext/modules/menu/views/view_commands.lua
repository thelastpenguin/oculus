local view_cmds = oc.menu.addView('cmds', 'ACTIONS');
view_cmds:setGenerator(function(self, panel, done)
	/*for k,v in pairs(oc.commands)do
		local lbl = Label(v.command, panel);
		lbl:Dock(TOP);
		lbl:SetTextColor(color_black);
		lbl:SetFont('oc_menu_10')
		lbl:SizeToContents();
	end*/

	local test = vgui.Create('DPanel', panel);
	test:SetSize(100,200);
	local material = Material('oc/anim/loading')
	function test:Paint(w, h)
		print('test');
		surface.SetMaterial(material);
		surface.DrawRect(0, 0, w, h);
	end
end);

local test = vgui.Create('DPanel', panel);
test:SetSize(200,100);
local material = Material('oc/anim/loading')
function test:Paint(w, h)
	surface.SetMaterial(material);
	surface.SetDrawColor(255,255,255);
	surface.DrawTexturedRect(0, 0, w, h);
end