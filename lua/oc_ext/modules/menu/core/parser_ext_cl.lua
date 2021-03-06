local function panelAutocomplete( optGenerator, updateResult )
	local panel = vgui.Create('DTextEntry');
	panel:SetEnterAllowed(true);
	local list;
	function panel:OnGetFocus()
		if ValidPanel(list) then list:Remove() end
		
		local opts = optGenerator();
		for k,v in pairs(opts)do
			function v.OnMousePressed()
				self:SetText(v.value);
				updateResult(v.value); -- for now we will use string values in all cases
			end
		end
		
		list = vgui.Create('DPanel', panel:GetParent());
		function list:Paint(w, h)
			surface.SetDrawColor(220,220,220,220);
			surface.DrawRect(0,0,w,h);
		end
		for k,v in pairs(opts)do
			v:SetParent(list);
		end
		
		local px, py = panel:GetPos();
		py = py + panel:GetTall();
		list:SetPos(px+4, py);
		
		function list:PerformLayout()
			list:SetWide(panel:GetWide()-8);
			local w, h = list:GetWide(), 0;
			for _, p in pairs(list:GetChildren())do
				if not p:IsVisible() then continue end
				p:SetWide(w);
				p:SetPos(0, h);
				h = h + p:GetTall();
			end
			list:SetTall(h);
		end
		function list:Think()
			if not panel:HasFocus() and not self:HasFocus() then
				self:Remove();
			end
		end
		
	end
	function panel:OnLoseFocus()
		updateResult(self:GetValue());
		if not ValidPanel(lest) then return end
		list:Remove();
	end
	function panel:OnTextChanged()
		if not ValidPanel(lest) then return end
		local text = self:GetValue():lower();
		for k,v in pairs(list:GetChildren())do
			v:SetVisible(v.string:lower():find(text, 1, false));
		end
		list:InvalidateLayout();
	end
	function panel:OnKeyCodeTyped(code)
		if not ValidPanel(lest) then return end
		if code == KEY_TAB then
			local lcldrn = list:GetChildren();
			if lcldrn[1] then
				lcldrn[1].OnMousePressed(lcldrn[1]);
			end
		end
	end	
	return panel;
end


local type_player = oc.parser.param_types['player'];
if type_player then
	type_player:setVGUIGenerator(function(param, updateValue)
		return panelAutocomplete(function()
			return xfn.map(player.GetAll(), function(v)
				local btn = vgui.Create('DButton');
				btn:SetSkin('oc_menu');
				btn:SetText(v:Name());
				function btn.OnMousePressed()
					panel:SetText(v:Name());
				end
				local a = vgui.Create('AvatarImage', btn);
				a:SetPlayer(v, 16);
				a:SetMouseInputEnabled(false);
				function btn:PerformLayout()
					a:SetSize(self:GetTall(), self:GetTall());
				end
				
				btn.string = v:Name();
				btn.value = v:Name();
				
				return btn;
			end);
		end, updateValue);
	end);
end


local type_steamid = oc.parser.param_types['steamid'];
if type_steamid then
	type_steamid:setVGUIGenerator(function(param, updateValue)
		return panelAutocomplete(function()
			return xfn.map(player.GetAll(), function(v)
				local btn = vgui.Create('DButton');
				btn:SetSkin('oc_menu');
				btn.value = v:SteamID();
				btn.string = btn.value .. ' ('..v:Name()..')';
				
				btn:SetText(btn.string);
				function btn.OnMousePressed()
					panel:SetText(btn.value);
				end
				local a = vgui.Create('AvatarImage');
				a:SetPlayer(v, 16);
				a:SetMouseInputEnabled(false);
				function btn:PerformLayout()
					a:SetSize(self:GetTall(), self:GetTall());
				end
				
				return btn;
			end);
		end, updateValue);
	end);
end


local type_string = oc.parser.param_types['string'];
if type_string then
	type_string:setVGUIGenerator(function(param, updateValue)
		return panelAutocomplete(function()
			return xfn.map(table.Copy(param.options or {}), function(v)
				local btn = vgui.Create('DButton', opts);
				btn:SetSkin('oc_menu');
				btn:SetText(v);
				function btn.OnMousePressed()
					panel:SetText(v);
				end
				btn.string = v;
				btn.value = v
				return btn;
			end);
		end, updateValue);
	end);
end

local type_number = oc.parser.param_types['number'];
if type_number then
	type_number:setVGUIGenerator(function(param, updateValue)
		local numberSlider = vgui.Create('DNumSlider');
		numberSlider:SetText(param.pid);
		numberSlider:SetDecimals(0);
		numberSlider.OnValueChanged = function(_, value)
			updateValue(value);
		end
		return numberSlider;
	end);
end

local type_group = oc.parser.param_types['group'];
if type_group then
	type_group:setVGUIGenerator(function(param, updateValue)
		return panelAutocomplete(function()
			return xfn.map(table.Copy(oc.groups or {}), function(v)
				local btn = vgui.Create('DButton', opts);
				btn:SetSkin('oc_menu');
				btn:SetText(v.name .. ' ('..v.gid..')');
				function btn.OnMousePressed()
					panel:SetText(v.name);
				end
				btn.string = v.name;
				btn.value = v.name
				return btn;
			end);
		end, updateValue);
	end);
end


local type_time = oc.parser.param_types['time'];
if type_time then
	type_time:setVGUIGenerator(function(param, updateValue)
		local panel = vgui.Create('DPanel');
		panel.Paint = xfn.noop;
		
		local function capt(t)
			local lbl = Label(t, panel);
			lbl:SetTextColor(color_black);
			lbl:DockMargin(10, 0, 4, 0);
			lbl:SetFont('oc_menu_8');
			lbl:SizeToContents();
			lbl:Dock(LEFT);
		end
		
		local pw, pd, ph, pm;
		local function calcValue()
			local pwVal = tonumber(pw:GetValue());
			local pdVal = tonumber(pd:GetValue());
			local phVal = tonumber(ph:GetValue());
			local pmVal = tonumber(pm:GetValue());
			
			local time = (((pwVal*7+pdVal)*24+phVal)*60+pmVal)
			updateValue(time..'m');
		end
		
		local function setupWang(p)
			p:Dock(LEFT);
			p:SetDecimals(0);
			p:SetWide(30);
			p.OnValueChanged = calcValue;
		end
		
		capt('W');
		pw = vgui.Create('DNumberWang', panel);
		pw:SetMinMax(0, 10000);
		setupWang(pw);
		
		capt('D');
		pd = vgui.Create('DNumberWang', panel);
		pd:SetMinMax(0, 7);
		setupWang(pd);
		
		capt('H');
		ph = vgui.Create('DNumberWang', panel);
		ph:SetMinMax(0, 24);
		setupWang(ph);
		
		capt('M');
		pm = vgui.Create('DNumberWang', panel);
		pm:SetMinMax(0, 60);
		setupWang(pm);
		
		return panel;
	end);
end