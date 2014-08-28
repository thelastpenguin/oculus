local view_motd = ocm.menu.addView('motd', 'MOTD');
view_motd:setGenerator(function(self, panel, done)
	local html = vgui.Create('DHTML', panel);
	html:Dock(FILL);
	html:OpenURL('http://www.google.com');
end);