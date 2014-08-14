/*

local db = oc._db;


oc.ban = {};



local highBanId = -1;
local bans = {};

function oc.ban.syncAll(done)
	dprint('syncing oculus bans starting at: ' .. highBanId);
	return db:query_ex('SELECT * FROM oc_bans WHERE b_id > ? AND unban_time > ?', {highBanId, math.floor(os.time()/60)}, function(data)
		
		for k, ban in pairs(data)do
			bans[ban.b_id] = ban;
			
			if ban.b_id > highBanId then
				highBanId = ban.b_id;
			end
		end
		
		dprint('updated highBanId to ' .. highBanId);
		dprint('total of '..#bans..' are now cached.');
		if done then done() end
	end);

end

oc.ban.syncAll();

function oc.ban.checkSteamID( steamid )
	local curtime = math.floor(os.time()/60);
	for _, ban in pairs(bans)do
		if ban.banned_steamid == steamid and curtime < ban.unban_time then
			return ban;
		end
	end
	return false;
end

function oc.ban.addRecord(data)
	local fields = {};
	local values = {};
	for k,v in pairs(data)do
		fields[#fields+1] = k;
		values[#values+1] = v;
	end
	db:query('REPLACE INTO oc_bans ('..table.concat(fields, ',')..') VALUES (\''..table.concat(values, '\',\'')..'\')', function()
		oc.ban.syncAll(done);	
	end);
end

function oc.ban.editRecord(b_id, data, done)
	local record = bans[b_id];
	if not record then return false end
	
	local query = {};
	for k,v in pairs(data) do
		record[k] = v;
		query[#query+1] = k..' = \''..v..'\'';
	end
	
	db:query('UPDATE oc_bans SET '..table.concat(query, ',')..' WHERE b_id = '..b_id, done);
end

function oc.ban.delRecord(b_id, done)
	bans[b_id] = nil;
	db:query('DELETE oc_bans WHERE b_id = ?', {b_id}, done);
end



local message = [[
BAN ID: %s
PLAYER NAME: %s
REASON: %s
ADMIN NAME: %s
BANNED ON: %s
BANNED UNTIL: %s
]]

local timeFormat = '%m/%d/%y - %H:%M'

oc.hook.Add('PostGamemodeLoaded', function()
	function GAMEMODE:CheckPassword( steamid64, ipPort, serverPassword, userPassword, name)
		if serverPassword and serverPassword:len() > 0 and serverPassword ~= userPassword then
			return false, 'Password: '..userPassword..' is incorrect';
		end
		local steamid = util.SteamIDFrom64( steamid64 );
		dprint('decoded connecting player steamid: '..steamid);
		
		local record = oc.ban.checkSteamID( steamid );
		if record then
			
			local bannedDate = os.date(timeFormat, record.ban_time*60);
			local unbanDate = os.date(timeFormat, record.unban_time*60);
			
			
			local ret = string.format(message, record.b_id, record.banned_name, record.reason, record.admin_name, bannedDate, unbanDate)
			
			return false, ret
		end
		return true;
	end
end);

*/