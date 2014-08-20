local header_height = 32;
local icon_size = 64;

local col_navbg = Color(155,155,160);
local col_navhov = Color(200,200,200);
local col_main = Color(240,240,240);



local col_header = Color(35, 41, 31); //Color(155,160,155);

--
-- MAIN MENU PANEL - handles view managment in essense
--
vgui.Register('oc_main', {
	
	Init = function(self)
		
		self.header = vgui.Create('DPanel', self);
		function self.header:Paint(w,h)
			surface.SetDrawColor(col_header);
			surface.DrawRect(0,0,w,h);
		end
		self.header.btnClose = vgui.Create('oc_ImageButton', self);
		self.header.btnClose:SetImage('oc/icon32/prohibited1.png');
		self.header.btnClose:SetColor(Color(200,200,200));
		self.header.btnClose:SetHoverColor(Color(200,55,55));
		self.header.btnClose.DoClick = function()
			self:Remove();
		end
		
		self.header.btnCollapse = vgui.Create('oc_ImageButton', self);
		self.header.btnCollapse:SetImage('oc/icon32/menu9.png');
		self.header.btnCollapse:SetColor(Color(200,200,200));
		self.header.btnCollapse:SetHoverColor(Color(255,255,255));
		self.header.btnCollapse.DoClick = function()
			self:SetExpanded(not self.expanded);
		end
		
		self.header.PerformLayout = function(self)
			local w, h = self:GetSize();
			
			self.btnClose:SetSize(h,h);
			self.btnClose:SetPos(w-h, 0);
			
			self.btnCollapse:SetSize(h,h);
			self.btnCollapse:SetPos(0,0);
			
		end
		
		self.body = vgui.Create('DPanel', self);
		self.body.Paint = function(self, w, h)
			surface.SetDrawColor(col_main);
			surface.DrawRect(0,0,w,h);
		end
		self.nav = vgui.Create('oc_main_nav', self);
		
		self:SetExpanded(true);
		
		self:SetSize(ScrW()*0.5, ScrH()*0.5);
		self:Center();
		self:MakePopup();
		
		self.tabCache = {};
	end,
	
	Update = function(self)
		self.nav:Update();
	end,
	
	CreateBody = function(self)
		self.body = vgui.Create('DPanel', self);
		self.body.Paint = function(self, w, h)
			surface.SetDrawColor(col_main);
			surface.DrawRect(0,0,w,h);
		end
		self:PerformLayout();
	end,
	DisplayTab = function(self, tab)
		if ValidPanel(self.body) then
			self.body:SetVisible(false);
			self.body:SetMouseInputEnabled(false);
		end
		
		dprint('displaying tab '..tab.name);
		if self.tabCache[tab] then
			dprint('  loading existing cached render');
			self.body = self.tabCache[tab];
			tab:runUpdater(self.body);
		else
			dprint('  creating fresh render');
			self:CreateBody();
			tab:runGenerator(self.body);
			self.tabCache[tab] = self.body;
		end
		
		self.body:SetVisible(true);
		self.body:SetMouseInputEnabled(true);
		self:InvalidateLayout(true);
	end,
	
	PerformLayout = function(self)
		local w, h = self:GetSize();
		
		local navWidth = self.nav.expanded and w*0.24 or icon_size;
		
		self.nav:SetPos(0,header_height);
		self.body:SetPos(navWidth, header_height);
		self.nav:SetTall(h-header_height);
		self.nav:SetWide(navWidth);
		self.body:SetSize(w-navWidth, h-header_height);
		
		self.header:SetSize(w, header_height);
	end,
	
	SetExpanded = function( self, expanded )
		self.expanded = expanded;
		
		if expanded then
			dprint('updating state to expanded');
		else
			dprint('updating state to collapsed');
		end
		
		self.nav:SetExpanded(expanded);
		self:InvalidateLayout(true);
	end,
	
	Paint = function(self, w, h)
		surface.SetDrawColor(col_main);
		surface.DrawRect(0,0,w,h);
	end
}, 'EditablePanel')


vgui.Register('oc_main_nav', {
	
	Init = function(self)
		self.buttons = {};
		self:Update();
	end,
	
	Update = function(self)
		for vid, view in pairs(oc.menu.views)do
			if view:canOpen() then
				self:AddViewButton(view)
			elseif self.buttons[view] then
				self.buttons[view]:Remove();
				self.buttons[view] = nil;
			end
		end
	end,
	
	AddViewButton = function( self, tab )
		local btn = vgui.Create('oc_main_nav-btn', self);
		btn:SetTab(tab);
		btn:Dock(TOP);
		btn.func = function()
			for k,v in pairs(self.buttons)do
				v:SetSelected(false);
			end
			btn:SetSelected(true);
			
			self:GetParent():DisplayTab(tab);
		end
		self.buttons[tab.vid] = btn;
	end,
	
	SetExpanded = function(self, expanded)
		self.expanded = expanded;
		dprint('updating nav state to: '..tostring(expanded));
		
		for k,v in pairs(self.buttons)do
			v:SetExpanded(expanded);
		end
	end,
	
	PerformLayout = function(self)
		local w, h = self:GetSize();
		
		for k,v in pairs(self.buttons)do
			v:SetSize(w, icon_size);
		end
	end,
	
	Paint = function(self, w, h)
		surface.SetDrawColor(col_navbg);
		surface.DrawRect(0,0,w,h);
	end,
});

vgui.Register('oc_main_nav-btn', {
	Init = function(self)
		self:SetText('');
	end,
	
	SetTab = function(self, tab)
		self.tab = tab;
		self.raw_title = tab.name;
		self.icon_material = Material(tab.icon);
	end,
	
	SetExpanded = function( self, expanded )
		self.expanded = expanded;
		
		if expanded then
			self.title = Label(self.raw_title, self);
			self.title:SetFont('oc_menu_10');
			self.title:SizeToContents();
			self.title:SetTextColor(color_black);
		else
			if ValidPanel(self.title) then self.title:Remove() end
		end
	end,
	
	PerformLayout = function(self)
		if ValidPanel(self.title) then
			self.title:SetPos(icon_size, (self:GetTall()-self.title:GetTall())*0.5);
		end
	end,
	
	SetSelected = function(self, _b)
		self.selected = _b;
	end,
	
	DoClick = function(self)
		print('was clicked');
		self.func();
	end,
	
	Paint = function(self, w, h)
		if self.selected then
			surface.SetDrawColor(col_main);
		elseif self:IsHovered() then
			surface.SetDrawColor(col_navhov);
		else
			surface.SetDrawColor(col_navbg);
		end
		surface.DrawRect(0,0,w,h);
		
		surface.SetMaterial(self.icon_material);
		surface.SetDrawColor(0,0,0);
		surface.DrawTexturedRect(h*0.15,h*0.15,h*0.7,h*0.7);
	end
}, 'DButton');

