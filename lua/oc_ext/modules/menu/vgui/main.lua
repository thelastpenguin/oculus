local header_height = 32;
local icon_size = 64;

local col_header = Color(35, 41, 31); //Color(155,160,155);

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
		self.nav = vgui.Create('oc_main_nav', self);
		
		self:SetExpanded(true);
		
		self:SetSize(ScrW()*0.5, ScrH()*0.5);
		self:Center();
		self:MakePopup();
		
	end,
	
	PerformLayout = function(self)
		local w, h = self:GetSize();
		
		local navWidth = self.nav.expanded and w*0.2 or icon_size;
		
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
		surface.SetDrawColor(220,220,220);
		surface.DrawRect(0,0,w,h);
	end
	
	
}, 'EditablePanel')


vgui.Register('oc_main_nav', {
	
	Init = function(self)
		self.buttons = {};
		
		self:AddTabButton( 'SETTINGS', 'oc/icon64/little17.png', function() end);
		self:AddTabButton( 'GROUPS', 'oc/icon64/little17.png', function() end);
		self:AddTabButton( 'BANS', 'oc/icon64/little17.png', function() end);
		self:AddTabButton( 'SEARCH', 'oc/icon64/little17.png', function() end);
		self:AddTabButton( 'KICK', 'oc/icon64/little17.png', function() end);
	end,
	
	AddTabButton = function( self, tabName, tabIcon, func )
		local btn = vgui.Create('oc_main_nav-btn', self);
		btn:SetTab(tabName, tabIcon, func);
		table.insert(self.buttons, btn);
	end,
	
	SetExpanded = function( self, expanded )
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
		surface.SetDrawColor(155,158,155);
		surface.DrawRect(0,0,w,h);
	end,
});

vgui.Register('oc_main_nav-btn', {
	Init = function(self)
		
	end,
	
	SetTab = function(self, title, icon, func)
		self.raw_title = title;
		self.icon_material = Material(icon);
		self.func = func;
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
		self.func();
	end,
	
	Paint = function(self, w, h)
		if self.selected then
			surface.SetDrawColor(250,250,250);
		elseif self:IsHovered() then
			surface.SetDrawColor(200,200,200);
		else
			surface.SetDrawColor(155,158,155);
		end
		surface.DrawRect(0,0,w,h);
		
		surface.SetMaterial(self.icon_material);
		surface.SetDrawColor(0,0,0);
		surface.DrawTexturedRect(h*0.15,h*0.15,h*0.7,h*0.7);
	end
});


/*
--
-- THE MAIN PANEL
-- 
local PANEL = {};
function PANEL:Init()
	
end
function PANEL:SetExpanded(state)
	
end
function PANEL:PerformLayout()
	
end
function PANEL:Paint()
	
end

















local header_height = 32
local icon_size = 64;

local col_header = Color(35, 41, 31); //Color(155,160,155);
local col_nav_bg = Color(182, 184, 180);

local PANEL = {}
print('reloaded oculus menu');
function PANEL:Init()
	
	self.header = vgui.Create('DPanel', self);
	self.body = vgui.Create('DPanel', self);
	self.nav = vgui.Create('oc_menu_nav', self);
	
	
	-- HEADER SETUP
	do
		-- close button
		local btnClose = vgui.Create('oc_ImageButton', self.header);
		btnClose:SetImage('oc/icon32/prohibited1.png');
		btnClose:SetColor(Color(200,200,200));
		btnClose:SetHoverColor(Color(200,55,55));
		function btnClose.DoClick()
			self:Remove()
		end
		
		local btnSidenav = vgui.Create('oc_ImageButton', self.header);
		btnSidenav:SetImage('oc/icon32/menu9.png');
		btnSidenav:SetColor(Color(200,200,200));
		btnSidenav:SetHoverColor(Color(255,255,255));
		function btnSidenav.DoClick()
			self.nav:SetExpanded(not self.nav.expanded);
		end
		
		function self.header:PerformLayout()
			local w, h = self:GetSize();
			btnClose:SetPos(w-h, 0);
			btnClose:SetSize(h, h);
			
			btnSidenav:SetPos(0,0);
			btnSidenav:SetSize(h,h);
		end
		
		function self.header:Paint(w,h)
			surface.SetDrawColor(col_header);
			surface.DrawRect(0,0,w,h);
		end
	end
	
	self:SetSize(ScrW()*0.7, ScrH()*0.7);
	self:Center();
	self:MakePopup();
	
end
function PANEL:PerformLayout()
	local w, h = self:GetSize();
	self.nav:PerformLayout();
	self.body:SetSize(w - self.nav:GetWide(), h-32);
	self.header:SetSize(w - self.nav:GetWide(), 32 );
	
	self.header:SetPos(self.nav:GetWide(), 0);
	self.body:SetPos(self.nav:GetWide(), 32);
	self.nav:SetPos(0, 0);
	
	self.header:InvalidateLayout();
end
function PANEL:Paint(w,h)
end

vgui.Register('oc_menu', PANEL, 'EditablePanel');



local PANEL = {};

function PANEL:Init()
	
	self.header = vgui.Create('DPanel', self);
	function self.header:Paint(w,h)
		surface.SetDrawColor(col_header);
		surface.DrawRect(0,0,w,h);
		surface.SetDrawColor(255,255,255,10);
		surface.DrawRect(0,0,w,h);
	end
	
	self.buttons = {};
	
	local btn = vgui.Create('oc_menu_navbtn', self);
	btn:Setup('test', 'oc/icon32/prohibited1.png', xfn.noop);
	table.insert(self.buttons, btn);
	
	local btn = vgui.Create('oc_menu_navbtn', self);
	btn:Setup('test', 'oc/icon32/prohibited1.png', xfn.noop);
	table.insert(self.buttons, btn);
	
	self:SetExpanded(true);
end

function PANEL:SetExpanded(_b)
	self.expanded = _b;
	
	self:InvalidateLayout();
	for k,v in pairs(self.buttons)do
		v:SetExpanded(_b);
	end
end

function PANEL:PerformLayout()
	local pw, ph = self:GetParent():GetSize();
	self:SetTall(ph);
	self.header:SetSize(pw, header_height);
	
	if self.expanded then
		self:SetWide(pw*0.2);
	else		
		self:SetWide(icon_size);
	end
end

function PANEL:Paint(w,h)
	surface.SetDrawColor(col_nav_bg);
	surface.DrawRect(0,0,w,h);
end
vgui.Register('oc_menu_nav', PANEL );



-- MENU NAV BUTTON
local PANEL = {};
function PANEL:Init()
end

function PANEL:Setup(name, icon, func)
	self.name = name;
	self.icon = icon;
	self.func = func;
end

function PANEL:SetExpanded(_b)
	self.expanded = _b;
	self:Clear();
	
	self.panel:SetTall(icon_size);
	if _b then
		self.panel = vgui.Create('DButton', self);
		self.panel:SetText(self.name);
		self:SetWide(self:GetParent():GetWide());
	else
		self.panel = vgui.Create('oc_ImageButton', self);
		self:SetWide(icon_size);
	end
end

function PANEL:PerformLayout()
	local w, h = self:GetSize()
	if ValidPanel(self.panel) then
		self.panel:SetSize(w,h);
	end
end

vgui.Register('oc_menu_navbtn', PANEL);
*/