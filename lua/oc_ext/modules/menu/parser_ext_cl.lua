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

local type_player = oc.parser.param_types['player'];
if type_player then
	type_player:setVGUIGenerator(function(param)
		local panel = vgui.Create('DTextEntry');
		panel.OnGetFocus = function()
			local opts = vgui.Create('DPanel');
			function opts:Think()
				if not panel:HasFocus() then
					self:Remove();
				end
			end
			
		end
		panel.OnLoseFocus = function()
			
		end
		return panel;
	end);
end