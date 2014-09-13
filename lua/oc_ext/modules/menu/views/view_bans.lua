local view_bans = ocm.menu.addView('bans', 'BANS');
view_bans:setIcon('oc/icon64/trash8.png');
view_bans:addPerm('menu.view.bans');

local function removeRowByColumn(list, colIndex, value)
	local lines = list:GetLines();
	for rowid, line in pairs(lines)do
		if line:GetValue(colIndex) == value then
			list:RemoveLine(rowid);
			break ;
		end
	end
end


view_bans:setGenerator(function(self, panel)
	self.seqno = 0;

	self.bans = {};
	self.modseq = 0;

	self.banlist = vgui.Create('DListView', panel);
	self.banlist:Dock(FILL);

	self.banlist:AddColumn('name');
	self.banlist:AddColumn('steamid');
	self.banlist:AddColumn('reason');
	self.banlist:AddColumn('admin');
	self.banlist:AddColumn('unban');

	function self.banlist.OnClickLine(banlist, line)
		Derma_Query('Would you like to unban this player?', 'CONFIRM', 'yes', function()
			Derma_Query('Are you really REALLY sure you want to unban this tawt?', 'REALLY?', 'pmuch over 9000', function()
				Derma_StringRequest('BAN REASON', 'Please type a reason for this unban', '', function(reason)
					if reason:len() < 10 then
						Derma_Message('Please provide a more detailed reason', 'ERROR');
					else
						removeRowByColumn(self.banlist, 2, line:GetValue(2));
						LocalPlayer():ConCommand(string.format('oc unban "%s" "%s"\n', line:GetValue(2), reason));

						SetClipboardText(line:GetValue(2));
						Derma_Message('The player\'s steamid has been copied to your clipboard incase you want to reban them', 'INFO');
					end
				end);
			end, 'no I guess not');
		end, 'no');
	end

	net.Receive('oc.menu.syncBan', function()
		local banid = net.ReadUInt(32);
		local steamid = net.ReadString();
		local name = net.ReadString();
		local reason = net.ReadString();
		local admin_name = net.ReadString();
		local create_time = net.ReadUInt(32);
		local length = net.ReadUInt(32);
		local modseq = net.ReadUInt(16);
		
		if modseq > self.modseq then 
			self.modseq = modseq
			dprint('mod sequence is now '..modseq);
		end
		
		-- remove any conflicting record that may have been synced in the past
		if self.bans[banid] then
			removeRowByColumn(self.banlist, 2, steamid);
		end

		self.banlist:AddLine(name, steamid, reason, admin_name, length == 0 and 'never' or os.date('%m/%d/%y  %H:%m', create_time + length*60));

		-- store the new ban record
		self.bans[banid] = {
			steamid = steamid,
			name = name,
			reason = reason,
			admin_name = admin_name,
			create_time = create_time,
			length = length
		};
	end);
end);

view_bans:setUpdater(function(self, panel)
	dprint('fetching bans');
	net.Start('oc.menu.fetchBans')
		net.WriteUInt(self.modseq, 32);
	net.SendToServer();
end);