local function addCaption(text, panel)
	local label = Label(text, panel);
	label:Dock(TOP);
	label:SetColor(color_black);
end


local view_groups = ocm.menu.addView('groups', 'GROUPS');
view_groups:setIcon('oc/icon64/group2.png');
view_groups:setGenerator(function(self, panel)

	-- GENERAL LAYOUT
	self.leftColumn = vgui.Create('DPanel', panel);
	self.leftColumn:SetVisible(false);
	self.body = vgui.Create('DScrollPanel', panel);

	-- DROPDOWN GROUP LIST
	local group ;
	self.groupList = vgui.Create('DComboBox', panel);
	self.groupList:SetValue("<none>")
	self.groupList.OnSelect = function( _, index, value, _group )
		group = _group;

		self.leftColumn:SetVisible(true);
		self.colorPicker:SetColor(group.color);
		self.groupName:SetText(group.name);
		self.immunitySlider:SetValue(group.immunity);
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

	self.updateSettings = vgui.Create('DButton', self.leftColumn);
	self.updateSettings:SetText('SAVE SETTINGS');
	self.updateSettings:Dock(TOP);
	self.updateSettings.DoClick = function(_)
		print('execute command');
		local col = self.colorPicker:GetColor();
		oc.netRunCommand('groupupdate', {
			group.name,
			self.groupName:GetValue(),
			self.immunitySlider:GetValue(),
			col.r..','..col.g..','..col.b,
		})
	end

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
	for k,v in SortedPairsByMemberValue(oc.groups, 'immunity', true)do
		self.groupList:AddChoice(v.name, v);
	end

	self.body:Clear();

	local globalPermsList = vgui.Create('DSizeToContents', self.body);
	local localPermsList = vgui.Create('DSizeToContents', self.body);

	function self.body:PerformLayout()
		local w, h = self:GetSize();
		globalPermsList:SetWide(w*0.5);
		localPermsList:SetWide(w*0.5);
		localPermsList:SetPos(w*0.5,0);
	end

	panel:InvalidateLayout(true);
	panel:InvalidateChildren(true);
end);