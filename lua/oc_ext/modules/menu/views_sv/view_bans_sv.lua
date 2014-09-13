util.AddNetworkString('oc.menu.fetchBans');
util.AddNetworkString('oc.menu.syncBan');
net.Receive('oc.menu.fetchBans', function(_, pl)
	if oc.p(pl):getPerm('menu.view.bans') then
		local modseq = net.ReadUInt(32);
		
		local key, ban;

		local function syncNext()
			while(true)do
				key, ban = next(oc.sb.bans, key);

				if not key then return end

				if ban.modseq > modseq then
					net.Start('oc.menu.syncBan')
						net.WriteUInt(ban.id, 32);
						net.WriteString(ban.steam);
						net.WriteString(ban.name or 'none');
						net.WriteString(ban.reason or 'none');
						net.WriteString(ban.admin_name);
						net.WriteUInt(ban.create_time, 32);
						net.WriteUInt(ban.length, 32);
						net.WriteUInt(ban.modseq, 16);
					net.Send(pl);
					timer.Simple(0.01, syncNext);
					
					break ;
				end
			end
		end

		syncNext();
	end
end);
