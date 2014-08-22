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


local view_cmds = oc.menu.addView('cmds', 'ACTIONS');
view_cmds:setGenerator(function(self, panel, done)
	local cmdList = makeScrollPanel(panel);
	
	-- LIST OF COMMANDS
	self.cmdList = cmdList;
	
	-- BODY
	local body = vgui.Create('DPanel', panel);
	function body:Paint() end
	self.body = body;
	
	-- PANEL LAYOUT
	function panel:PerformLayout()
		local w, h = self:GetSize();
		cmdList:SetSize(w*0.35, h);
		body:SetPos(w*0.35+5, 0);
		body:SetSize(w*(1-0.35)-10, h);
	end
	
end);

view_cmds:setUpdater(function(self, panel, done)
	local cmdList = self.cmdList;
	
	-- POPULATE CATEGORIES
	local cmdCategories = {};
	local function getCategory(cname)
		if not cmdCategories[cname] then
			local cat = vgui.Create( "DCollapsibleCategory", cmdList );
			cat:Dock(TOP);
			cat:SetLabel( cname );
			cat:SizeToContents();
			cat:SetExpanded(false);
			cmdCategories[cname] = cat;
			return cat;
		else
			return cmdCategories[cname];
		end
	end
	
	for k,v in pairs(oc.commands)do
		if not v:playerCanUse(LocalPlayer()) then continue end
		
		local row = vgui.Create('oc_menu-cmd_btn', getCategory(v.category));
		row:SetCommand(v);
		row:Dock(TOP);
		
		row.DoClick = function()
			self:DisplayCommand(v);
		end
	end
	
end);

function view_cmds:DisplayCommand(cmd)
	dprint('displaying command '..cmd.command);
	self.body:Clear();
	
	local title = Label(cmd.command, self.body);
	title:SetFont('oc_menu_14');
	title:SetColor(color_black);
	title:SizeToContents();
	title:DockMargin(5,5,5,5);
	title:Dock(TOP);
	
	local container = makeScrollPanel(self.body);
	container:Dock(FILL);
	
	for _, param in pairs(cmd.params)do
		local type_meta = oc.parser.param_types[param.type];
		
		local lbl = Label(param.pid, self.body);
		lbl:SetTextColor(color_black)
		lbl:SetFont('oc_menu_8');
		lbl:Dock(TOP);
		
		type_meta:genVGUIPanel(param, self.body);
	end
	
end

vgui.Register('oc_menu-cmd_btn', {
	Init = function(self)
		self:SetText('');
	end,
	
	SetCommand = function(self, cmd)
		self.command = cmd;
		
		self.lbl = Label(cmd.command, self);
		self.lbl:SetTextColor(color_black);
		self.lbl:SetFont('oc_menu_8');
		self.lbl:SizeToContents();
		self:SetTall(self.lbl:GetTall()*1.3);
	end,
	
	PerformLayout = function(self)
		local w, h = self:GetSize();
		self.lbl:SetPos(5, (h-self.lbl:GetTall())*0.5);
	end,
	
	Paint = function(self, w, h)
		if self:IsHovered() then
			if input.IsMouseDown(MOUSE_LEFT) then
				surface.SetDrawColor(0, 0, 100, 120);
			else
				surface.SetDrawColor(0, 0, 100, 80);
			end
			surface.DrawRect(0, 0, w, h);
		end
	end
}, 'DButton')