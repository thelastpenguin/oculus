local xfn, async, pon = xfn, async, pon ;

oc.data = {};
local data = oc.data;

-- ESTABLISH CONNECTION
if not oc._db then
	oc._db = pmysql.newdb( "lastpenguin.com", "penguinwebhost", "pE2SGHXU3eST9qa", "penguinwebhost_oculus", 3306 );
end

-- LOCALS
local db = oc._db;
local svid;
function data.svId()
	return svid;
end

--
-- INITIALIZATION
-- 
local function GetServerID()
	local data = db:query_sync("SELECT * FROM oc_servers WHERE host_ip = '?'", {GetConVarString('ip')});
	svid = data[1] and data[1].sv_id;
end


function oc.data.init()
	GetServerID();
	if not svid then
		db:query_sync("REPLACE INTO oc_servers (host_ip, host_name) VALUES ('?','?')", { GetConVarString("ip"), GetConVarString("hostname") or 'unknown'}, xfn.noop );
		GetServerID();
	end
	oc.LoadMsg( 2, 'database initialized' );
	oc.LoadMsg( 2, 'server id: '..svid );
	data.svid = svid;
end
oc.data.init();

--
-- USER MANAGMENT
--
function oc.data.userFetchID( steamid, done )
	return db:query_ex("SELECT u_id, displayName FROM oc_users WHERE steamid='?'",{steamid}, function(data)
		if data and data[1] then
			done(data[1].u_id);
		else
			done(nil);
		end
	end);
end
function oc.data.userCreate( pl, done )
	return db:query_ex("REPLACE INTO oc_users (steamid,displayName)VALUES('?','?')", {pl:SteamID(), pl:Name()}, done);
end
function oc.data.userUpdate( uid, pl, done )
	return db:query_ex("UPDATE oc_users SET displayName='?' WHERE u_id=?", {pl:Name(), uid}, done);
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
	return db:query_ex("REPLACE INTO oc_user_perms VALUES(?,?,'?')", {svid, uid, perm}, done );
end

function oc.data.userDelPerm( svid, uid, perm, done )
	return db:query_ex("DELETE FROM oc_user_perms WHERE sv_id=? AND u_id=? AND perm LIKE '?%'", {svid, uid, perm}, done );
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
	db:query_ex('DELETE FROM oc_group_perms WHERE sv_id=? AND g_id=? AND perm=\'?\'',{sv_id, g_id, perm}, callback);
end
