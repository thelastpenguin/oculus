local view_players = ocm.menu.addView('players', 'PLAYERS');
view_players:setIcon('oc/icon64/search7.png');
view_players:addPerm('menu.view.bans');

view_players:setGenerator(function(self, panel)
	self.header = vgui.Create('DPanel', panel);
	self.header:Dock(TOP);

	self.searchModes = vgui.Create('DComboBox', self.header);
	self.searchModes:Dock(LEFT);
	self.searchModes:SetWide(60);

	self.searchBox = vgui.Create('DTextEntry', self.header);
	self.searchBox:Dock(FILL);

	self.list = vgui.Create('DListView', panel);
	self.list:Dock(FILL);
end);


view_players:setUpdater(function()
end);