if not oc._sbdb then
	oc._sbdb = pmysql.newdb( "lastpenguin.com", "penguinwebhost", "pE2SGHXU3eST9qa", "penguinwebhost_oculus", 3306 );
end

local prefix = 'sb_';
local queries = {
	SELECT_SERVER_ID_BY_ADDR = 'SELECT id FROM '..prefix..'servers WHERE host = \'?\' AND port = ?',
	INSERT_SERVER = 'INSERT INTO '..prefix..'servers (host, port, game_id) VALUES(\'?\', ?, 9)',
	SELECT_ADMIN_BY_STEAMID = 'SELECT id FROM '..prefix..'admins WHERE identity = \'?\'',
	INSERT_ADMIN = 'INSERT INTO '..prefix..'admins (name, identity, create_time) VALUES (\'?\',\'?\', ?)',
	UPDATE_ADMIN = 'UPDATE '..prefix..'admins SET name = \'?\' WHERE identity = \'?\'',
	INSERT_BAN_BY_STEAMID = 'INSERT INTO '..prefix..'bans (server_id,admin_id, admin_ip, steam, name, reason, create_time, length) VALUES (?, ?, \'?\', \'?\', \'?\', \'?\', ?, ?)',
	INSERT_BAN_BY_STEAMID_IP = 'INSERT INTO '..prefix..'bans (server_id,admin_id, admin_ip, steam, ip, name, reason, create_time, length) VALUES (?, ?, \'?\', \'?\', \'?\', \'?\', \'?\', ?, ?)',
	INSERT_BAN_BY_STEAMID_CONSOLE = 'INSERT INTO '..prefix..'bans (server_id,admin_ip, steam, name, reason, create_time, length) VALUES (?, \'?\', \'?\', \'?\', \'?\', ?, ?)',
	INSERT_BAN_BY_STEAMID_CONSOLE_IP = 'INSERT INTO '..prefix..'bans (server_id,admin_ip, steam, ip, name, reason, create_time, length) VALUES (?, \'?\', \'?\', \'?\', \'?\', \'?\', ?, ?)',
	--SELECT_UPDATED_BANS = 'SELECT * FROM '..prefix..'bans WHERE (unban_time > ? OR create_time > ?) AND (length = 0 OR (create_time + length*60) > ?)',
	SELECT_UPDATED_BANS = ([[
		SELECT prefix_bans.*, prefix_admins.name AS admin_name 
		FROM prefix_bans
		INNER JOIN prefix_admins 
		ON prefix_bans.admin_id = prefix_admins.id
		WHERE (prefix_bans.unban_time > ? OR prefix_bans.create_time > ?) AND 
			(prefix_bans.length = 0 OR (prefix_bans.create_time + prefix_bans.length*60) > ?)
	]]):gsub('prefix_', prefix);

	UNBAN_BY_STEAMID_CONSOLE = 'UPDATE '..prefix..'bans SET unban_reason = \'?\', unban_time = ? WHERE id = ?',
	UNBAN_BY_STEAMID = 'UPDATE '..prefix..'bans SET unban_admin_id = ?, unban_reason = \'?\', unban_time = ? WHERE id = ?',
}

dprint(queries.SELECT_UPDATED_BANS);

local db = oc._sbdb;

oc.sb = {};

oc.sb.hostip = GetConVarString('ip');
oc.sb.hostport = GetConVarString('hostport');
oc.sb.hostaddr = oc.sb.hostip..':'..oc.sb.hostport;


local function GetServerID()
	local data = db:query_sync(queries.SELECT_SERVER_ID_BY_ADDR, {oc.sb.hostip, oc.sb.hostport});
	oc.sb.svid = data[1] and data[1].id;
end

local function ResolveServerID()
	GetServerID();
	if not oc.sb.svid then
		db:query_sync(queries.INSERT_SERVER, {oc.sb.hostip, oc.sb.hostport});
		GetServerID();
	end
	oc.LoadMsg(2, 'Loaded SourceBans Server ID: '..oc.sb.svid);	
end
ResolveServerID();



-- fuk you aStonedPenguin
function oc.sb.playerGetAdminId(pl, done)
	db:query_ex(queries.SELECT_ADMIN_BY_STEAMID, {pl:SteamID()}, function(data, err)
		if err then return done() end
		if data[1] then
			done(data[1].id);
			db:query_ex(queries.UPDATE_ADMIN, {oc.p(pl).uid..'-'..pl:Name(), pl:SteamID()});
		else
			db:query_ex(queries.INSERT_ADMIN, {oc.p(pl).uid..'-'..pl:Name(), pl:SteamID(), os.time()}, function(data, err)
				if err then return done() end
				oc.sb.playerGetAdminId(pl, done);	
			end);
		end
	end);
end

-- I hate my life
function oc.sb.banSteamID( admin, player_steamid, player_name, length, reason, done)
	if IsValid(admin) then
		oc.sb.playerGetAdminId(admin, function(id)
			if not id then
				error('failed to load admin id for ' .. admin:SteamID());
			end
			
			dprint('admin id is: '..id);
			db:query_ex(queries.INSERT_BAN_BY_STEAMID, {oc.sb.svid, id, admin:IPAddress(), player_steamid, player_name, reason, os.time(), length}, function()
				oc.sb.syncBans(done);	
			end);
		end);
		
	else
		db:query_ex(queries.INSERT_BAN_BY_STEAMID_CONSOLE, {oc.sb.svid, oc.sb.hostip, player_steamid, player_name, reason, os.time(), length}, function()
			oc.sb.syncBans(done);	
		end);
	end
end

function oc.sb.banPlayer( admin, player, length, reason, done )
	local playerIpAddr = player:IPAddress();
	local playerSteamID = player:SteamID();
	local playerName = player:Name();
	if IsValid(admin) then
		oc.sb.playerGetAdminId(admin, function(id)
			if not id then
				error('failed to load admin id for ' .. admin:SteamID());
			end
			
			dprint('admin id is: '..id);
			db:query_ex(queries.INSERT_BAN_BY_STEAMID_IP, {oc.sb.svid, id, admin:IPAddress(), playerSteamID, playerIpAddr, playerName, reason, os.time(), length}, function()
				oc.sb.syncBans(done);
			end);
		end);
		
	else
		db:query_ex(queries.INSERT_BAN_BY_STEAMID_CONSOLE_IP, {oc.sb.svid, oc.sb.hostip, playerSteamID, playerIpAddr, playerName, reason, os.time(), length}, function()
			oc.sb.syncBans(done);	
		end);
	end
end

function oc.sb.unbanSteamID( admin, banid, reason, done )
	if IsValid(admin) then
		oc.sb.playerGetAdminId(admin, function(id)
			if not id then
				error('failed to load admin id for ' .. admin:SteamID());
			end
			
			dprint('admin id is: '..id);
			
			db:query_ex(queries.UNBAN_BY_STEAMID, {id, reason, os.time(), banid}, function()
				oc.sb.syncBans(done);	
			end);
		end);
	else
		db:query_ex(queries.UNBAN_BY_STEAMID_CONSOLE, {reason, os.time(), banid}, function()
			oc.sb.syncBans(done);	
		end);
	end
end


local lastsync = -1;
oc.sb.bans = {};

local modseq = 0;
function oc.sb.syncBans(done)
	dprint('syncing all bans');
	db:query_ex(queries.SELECT_UPDATED_BANS, {lastsync, lastsync, os.time()}, function(data)
		for _, ban in pairs(data)do
			oc.sb.bans[ban.id] = ban;

			-- modseq is used primarily for syncing bans accross network.
			ban.modseq = modseq;
			modseq = modseq + 1;
		end
		lastsync = os.time();
		
		dprint('loaded '..table.Count(data)..' bans from SourceBans');
		
		if done then done() end
	end);
end
oc.sb.syncBans();

function oc.sb.checkSteamID( steamid )
	local curtime = os.time();
	for id, ban in pairs(oc.sb.bans)do
		local length = tonumber(ban.length);
		if ban.steam == steamid and (length == 0 or ban.create_time + length * 60 > curtime) and not ban.unban_time then
			return ban;
		end
	end
	return false;
end


local message = [[
www.SuperiorServers.co
  BAN ID: %s
  PLAYER NAME: %s
  REASON: %s
  BANNED ON: %s
  BANNED UNTIL: %s
]]

local timeFormat = '%m/%d/%y - %H:%M'

hook.Add('CheckPassword', 'oc.SourceBans', function(steamid64, ipPort, serverPassword, userPassword, name)
	if serverPassword and serverPassword:len() > 0 and serverPassword ~= userPassword then
		return false, 'Password: '..userPassword..' is incorrect';
	end
	local steamid = util.SteamIDFrom64( steamid64 );
	dprint('decoded connecting player steamid: '..steamid);
	
	local record = oc.sb.checkSteamID( steamid );
	if record then
		
		local bannedDate = os.date(timeFormat, record.create_time);
		local unbanDate = os.date(timeFormat, record.create_time + record.length * 60);
		
		local ret = string.format(message, record.id, record.name, record.reason, bannedDate, unbanDate)
		
		return false, ret
	end	
	return true;
end);