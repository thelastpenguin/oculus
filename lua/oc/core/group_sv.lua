oc.group = {};
oc.group.groups = {};
local groups = oc.group.groups;

local group_mt = {};
group_mt.__index = group_mt;

--
-- RESYNC GROUPS WITH MYSQL
-- 
function oc.group.sync()
	oc.LoadMsg(0, '\nSYNCING GROUPS\n');
	-- clear old groups
	for k,v in pairs(groups)do
		groups[k] = nil;
	end
	-- fetch and init new ones
	oc.data.getGroupIds(function(groupIds)
		xfn.map(groupIds, function(row)
			return row.g_id;	
		end);
		for k, gid in pairs(groupIds)do
			oc.group.loadId(gid);
		end
	end):wait();
end

--
-- LOAD GROUP WITH GIVEN ID IF NOT ALREADY LOADED
--
function oc.group.loadId(g_id)
	
	if groups[g_id] then return end
	
	local group = {};
	
	oc.data.groupGetById(g_id, function(data)
		if data[1] then
			group.gid = g_id
			group.name = data[1].group_name;
			group.immunity = data[1].g_immunity;
			group.inherits = oc.group.loadId(data[1].g_inherits);
			group.color = oc.bit.decodeColor(data[1].color);
		end
	end):wait();
	
	if group.gid then
		oc.LoadMsg(2, 'Loaded group: ' .. group.gid.. ' - ' .. group.name);
		groups[g_id] = setmetatable(group, group_mt);
		-- fetch permissions
		group:fetchPerms(true, xfn.noop):wait();
		group:fetchPerms(false, xfn.noop):wait(); 
		return group;
	else 
		oc.LoadMsg(2, 'ERROR! FAILED TO LOAD GROUP: ' .. g_id);
	end
	
end

function group_mt:fetchPerms(isGlobal, done)
	return oc.data.groupFetchPerms(isGlobal and 0 or oc.data.svid, self.gid, function(data)
		oc.LoadMsg(3, isGlobal and 'global perms:' or 'local perms:');
		for k,v in pairs(data)do
			oc.LoadMsg(4, 'perm: '..v);
		end
		if isGlobal then
			self.globalPerms = oc.perm(data);
		else
			self.serverPerms = oc.perm(data);
		end
		done();
	end);
end

function group_mt:addPerm(perm, isGlobal, done)
	return oc.data.groupAddPerm( isGlobal and 0 or oc.data.svid, self.gid, perm, function()
		self:fetchPerms( isGlobal, xfn.fn_deafen(done or xfn.noop));	
	end);
end
function group_mt:addPermNumber(perm, value, isGlobal, done)
	return self:addPerm(perm..'.'..tonumber(value, 16), isGlobal, done);
end
function group_mt:setPermString(perm, value, isGlobal, done)
	return self:delPerm(perm, isGlobal, function() 
		self:addPerm(perm..'.'..value, isGlobal, done);
	end);
end
function group_mt:setPermNumber(perm, value, isGlobal, done)
	return self:delPerm(perm, isGlobal, function()
		self:addPerm(perm..'.'..tonumber(value, 16), isGlobal, done);
	end);	
end

function group_mt:delPerm(perm, isGlobal, done)
	local subs = (isGlobal and self.globalPerms or self.serverPerms):getPerm(perm);
	local count = #subs;
	if count == 0 then
		return self:_delPerm(perm, isGlobal, done);
	end
	local amIDone = done and function()
		count = count - 1;
		if count == 0 then
			done()
		end
	end or xfn.noop;
	for _, sub in ipairs(subs)do
		self:delPerm(perm..'.'..sub, isGlobal, amIDone);
	end
end

function group_mt:getPerm(perm)
	return self.serverPerms:getPerm(perm) or self.globalPerms:getPerm(perm) or (self.inherits and self.inherits:getPerm(perm));
end

function group_mt:getPermString(perm)
	local res = self:getPerm(perm);
	return res and res[1]	
end
function group_mt:getPermNumber(perm)
	local res = self:getPerm(perm);
	return res and res[1] and tonumber(res[1], 16);
end


function oc.g(groupid)
	return groups[groupid];
end

oc.group.sync();