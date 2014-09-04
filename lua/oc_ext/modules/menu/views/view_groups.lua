local function addCaption(text, panel)
	local label = Label(text, panel);
	label:Dock(TOP);
	label:SetColor(color_black);
end


local view_groups = ocm.menu.addView('groups', 'GROUPS');
view_groups:setIcon('oc/icon64/group2.png');
view_groups:setGenerator(function(self, panel)

	-- UPDATE GROUP DISPLAY
	function self.UpdateProperties()
		self.colorPicker:SetColor(self.group.color);
		self.groupName:SetText(self.group.name);
		self.immunitySlider:SetValue(self.group.immunity);
		self.groupPerms:SetGroup(self.group);

		self.inheritanceList:SetValue(self.group.inherits and self.group.inherits.name or '<none>');
	end


	-- GENERAL LAYOUT
	self.leftColumn = vgui.Create('DPanel', panel);
	self.leftColumn:SetVisible(false);
	self.body = vgui.Create('DScrollPanel', panel);
	self.body:SetVisible(false);

	-- DROPDOWN GROUP LIST
	self.groupList = vgui.Create('DComboBox', panel);
	self.groupList:SetValue("<none>")
	self.groupList.OnSelect = function( _, index, value, _group )
		self.group = _group;

		self.leftColumn:SetVisible(true);
		self.body:SetVisible(true);

		self.UpdateProperties();
	end

	-- GROUP NAME EDITOR
	addCaption('GROUP NAME:', self.leftColumn);
	self.groupName = vgui.Create('DTextEntry', self.leftColumn);
	self.groupName:Dock(TOP);

	-- GROUP COLOR PICKER
	addCaption('GROUP COLOR:', self.leftColumn);
	self.colorPicker = vgui.Create('DColorMixer', self.leftColumn);
	self.colorPicker:Dock(TOP);
	self.colorPicker:SetAlphaBar(false);
	self.colorPicker:SetPalette(false);

	-- GROUP IMMUNITY SLIDER
	self.immunitySlider = vgui.Create('DNumSlider', self.leftColumn);
	self.immunitySlider:SetText('IMMUNITY:');
	self.immunitySlider:SetMin(0);
	self.immunitySlider:SetMax(1000);
	self.immunitySlider:SetDecimals(0);
	self.immunitySlider:Dock(TOP);
	self.immunitySlider.Label:SetColor(color_black);

	-- GROUP INHERITANCE
	addCaption('GROUP INHERITS:', self.leftColumn);
	self.inheritanceList = vgui.Create('DComboBox', self.leftColumn);
	self.inheritanceList:SetValue("<none");
	self.inheritanceList.OnSelect = function(_, index, value, _group)
		oc.netRunCommand('groupsetparent', {
			self.group.name,
			_group and _group.name or nil
		})
	end
	self.inheritanceList:Dock(TOP);

	self.updateSettings = vgui.Create('DButton', self.leftColumn);
	self.updateSettings:SetText('SAVE SETTINGS');
	self.updateSettings:Dock(TOP);
	self.updateSettings.DoClick = function(_)
		print('execute command');
		local col = self.colorPicker:GetColor();
		oc.netRunCommand('groupupdate', {
			self.group.name,
			self.groupName:GetValue(),
			self.immunitySlider:GetValue(),
			col.r..','..col.g..','..col.b,
		})
	end

	self.createNew = vgui.Create('DButton', self.leftColumn);
	self.createNew:SetText('CREATE NEW');
	self.createNew:Dock(BOTTOM);
	self.createNew.DoClick = function()
		Derma_StringRequest('GROUP NAME', 'Enter a name for the new group', 'group'..math.random(1,1000), function(text)
			oc.netRunCommand('groupcreate', {
				text,
				self.group and self.group.name
			});
		end);
	end


	self.groupPerms = vgui.Create('oc_menu-group-perms', self.body);
	self.groupPerms:Dock(FILL);

	function panel.PerformLayout()
		if not ValidPanel(self.groupList) then return end

		local w, h = panel:GetSize();
		
		self.groupList:SetWide(w*0.3);

		self.leftColumn:SetSize(0.3*w-6, h - self.groupList:GetTall() - 4);
		self.leftColumn:SetPos(3, self.groupList:GetTall() + 4);

		self.body:SetPos(0.3*w, 0);
		self.body:SetSize(0.7*w, h);

		self.colorPicker:SetTall(self.colorPicker:GetWide()*0.5);
	end

end);

view_groups:setUpdater(function(self, panel)
	self.groupList:Clear();
	self.inheritanceList:Clear();
	for k,v in SortedPairsByMemberValue(oc.groups, 'immunity', true)do
		self.groupList:AddChoice(v.gid..' - '..v.name, v);
		self.inheritanceList:AddChoice(v.gid..' - '..v.name, v);
	end
	self.inheritanceList:AddChoice('<none>');

	if self.group then
		self.groupList:SetValue(self.group.name);

		self.UpdateProperties();
	end
end);
