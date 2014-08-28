local view_groups = ocm.menu.addView('groups', 'GROUPS');
view_groups:setIcon('oc/icon64/group2.png');
view_groups:setGenerator(function(self, panel, done)
	local groupList = vgui.Create('DScrollPanel', panel);
	
	-- LIST OF COMMANDS
	self.groupList = groupList;
	
	-- BODY
	local body = vgui.Create('DPanel', panel);
	self.body = body;
	
	-- PANEL LAYOUT
	function panel:PerformLayout()
		local w, h = self:GetSize();
		groupList:SetSize(w*0.35, h);
		body:SetPos(w*0.35+5, 0);
		body:SetSize(w*(1-0.35)-10, h);
	end 
end);

view_groups:setUpdater(function(self, panel, done)
	local groupList = self.groupList;
	groupList:Clear();

	local copied = {};
	for k,v in SortedPairsByMemberValue(oc.groups, 'immunity', true)do
		local row = vgui.Create('DButton', groupList);
		row:SetText(v.name..' ('..v.immunity..')');
		row:Dock(TOP);
	end
end);