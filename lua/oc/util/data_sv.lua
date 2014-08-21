local xfn, async, pon = xfn, async, pon ;

oc.data = {};
local data = oc.data;

-- ESTABLISH CONNECTION
if not oc._db then
	oc._db = pmysql.newdb( "lastpenguin.com", "penguinwebhost", "pE2SGHXU3eST9qa", "penguinwebhost_oculus", 3306 );
end


oc.data.hostip = GetConVarString('ip');
oc.data.hostport = GetConVarString('hostport');
oc.data.hostaddr = oc.data.hostip..':'..oc.data.hostport;


-- LOCALS
local db = oc._db;
local svid;
local svgid;

--
-- INITIALIZATION
-- 
local function GetServerID()
	local data = db:query_sync("SELECT * FROM oc_servers WHERE host_ip = '?'", {oc.data.hostaddr});
	svid = data[1] and data[1].sv_id;
	svgid = data[1] and data[1].svg_id;
end


function oc.data.init()
	GetServerID();
	if not svid then
		db:query_sync("REPLACE INTO oc_servers (host_ip, host_name) VALUES ('?','?')", { oc.data.hostaddr, GetConVarString("hostname") or 'unknown'}, xfn.noop );
		GetServerID();
	end
	oc.LoadMsg( 2, 'database initialized' );
	oc.LoadMsg( 2, 'server id: '..svid );
	oc.LoadMsg( 2, 'server group id: '..(svgid or 'none'));
	
	data._svid = svid;
	data.svid = svgid or svid;
	
	db:query_sync("UPDATE oc_user_perms SET perm=expires_perm, expires_perm = NULL, expires = NULL WHERE expires<?", {os.time()});
	
	oc.LoadMsg( 2, 'Rewrote Expired Permissions' );
	
	timer.Simple(1, function()
		db:query_ex('UPDATE oc_servers SET host_name=\'?\' WHERE sv_id=?', {GetConVarString('hostname'), data._svid});	
	end);
end
oc.data.init();

--
-- USER MANAGMENT
--
function oc.data.userFetchID( steamid, done )
	return db:query_ex("SELECT u_id FROM oc_users WHERE steamid='?'",{steamid}, function(data)
		if data and data[1] then
			done(data[1].u_id);
		else
			done(nil);
		end
	end);
end
function oc.data.userCreate( pl, done )
	return db:query_ex("REPLACE INTO oc_users (steamid,displayName,ip)VALUES('?','?','?')", {pl:SteamID(), pl:Name(), pl:IPAddress()}, done);
end
function oc.data.userCreateSteamID(steamid, done)
	return db:query_ex("REPLACE INTO oc_users (steamid,displayName,ip)VALUES('?','?','?')", {steamid, 'John Doe', '127.0.0.1'}, done);
end
function oc.data.userUpdate( uid, pl, done )
	return db:query_ex("UPDATE oc_users SET displayName='?', ip='?' WHERE u_id=?", {pl:Name(), pl:IPAddress(), uid}, done);
end

function oc.data.userFetchPerms( svid, uid, done )
	return db:query_ex("SELECT perm FROM oc_user_perms WHERE sv_id=? AND u_id=?", {svid, uid}, function(rows)
		xfn.map( rows, function(row)
			return row.perm;
		end);
		done(rows);
	end);
end

function oc.data.userAddPerm( svid, uid, perm, done )
	return db:query_ex("REPLACE INTO oc_user_perms (sv_id, u_id, perm)VALUES(?,?,'?')", {svid, uid, perm}, done );
end

function oc.data.userDelPerm( svid, uid, perm, done )
	return db:query_ex("DELETE FROM oc_user_perms WHERE sv_id=? AND u_id=? AND (perm = '?' OR perm LIKE '?.%')", {svid, uid, perm, perm}, done );
end

function oc.data.userPermSetExpire( svid, uid, perm, expires_time, expires_perm, done )
	return db:query_ex('UPDATE oc_user_perms SET expires=?, expires_perm=\'?\' WHERE sv_id=? AND u_id=? AND perm=\'?\'', {expires_time, expires_perm, svid, uid, perm}, done);
end
function oc.data.userPermClearExpire( svid, uid, perm, done )
	return db:query_ex('UPDATE oc_user_perms SET expires=NULL, expires_perm=NULL WHERE sv_id=? AND u_id=? AND perm=\'?\'', {svid, uid, perm}, done);
end

function oc.data.userInitVars( svid, uid, done )
	return db:query_ex("REPLACE INTO oc_user_vars VALUES(?, ?, '?')", {svid, uid, pon.encode({})}, done);
end

function oc.data.userFetchVars( svid, uid, done )
	return db:query_ex("SELECT data FROM oc_user_vars WHERE sv_id=? AND u_id=?", {svid, uid}, done );	
end

function oc.data.userUpdateVars( svid, uid, data, done )
	return db:query_ex("UPDATE oc_user_vars SET data='?' WHERE sv_id=? AND u_id=?", {data, svid, uid}, done);	
end

--
-- GROUPS
--
function oc.data.groupsGetAll(callback)
	return db:query('SElECT * FROM oc_groups', callback);
end
function oc.data.getGroupIds(callback)
	return db:query('SELECT g_id FROM oc_groups', callback);
end
function oc.data.groupGetById( g_id, callback )
	return db:query_ex('SELECT * FROM oc_groups WHERE g_id=?', {g_id}, callback);
end

function oc.data.groupCreate(g_id, groupname, callback )
	return db:query_ex('REPLACE INTO oc_groups (g_inherits,g_immunity,group_name,color)VALUES(?,?,\'?\',?)',{g_id,groupname,oc.bit.encodeColor(color_white)}, function()
		callback();
	end);
end
function oc.data.groupUpdate( g_id, g_inherits, g_immunity, group_name, color, callback)
	return db:query_ex('REPLACE INTO oc_groups (g_inherits,g_immunity,group_name,color)VALUES(?,?,\'?\',?)', {
		g_id, g_inherits, g_immunity, group_name, oc.bit.encodeColor(color)
	}, callback);
end

function oc.data.groupFetchPerms( sv_id, g_id, callback )
	return db:query_ex( 'SELECT perm FROM oc_group_perms WHERE sv_id=? AND g_id=?', {sv_id, g_id}, function(data, err)
		xfn.map( data, function(perm) return perm.perm end);
		callback(data);
	end);
end

function oc.data.groupAddPerm( sv_id, g_id, perm, callback )	
	db:query_ex('REPLACE INTO oc_group_perms (sv_id,g_id,perm)VALUES(?,?,\'?\')',{sv_id, g_id, perm}, callback);
end
function oc.data.groupDelPerm( sv_id, g_id, perm, callback )
	db:query_ex('DELETE FROM oc_group_perms WHERE sv_id=? AND g_id=? AND (perm = \'?\' OR perm LIKE \'?.%\')',{sv_id, g_id, perm, perm}, callback);
end