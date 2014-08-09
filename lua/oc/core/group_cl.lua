local group_mt = {};
group_mt.__index = group_mt;


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


net.Receive('oc.g.syncMeta', function(len)
	local groupid = net.ReadUInt(32);
	dprint('syncing group meta data for group: ' .. groupid);
	local group = oc.g(groupid);
	group.immunity = net.ReadUInt(32);
	group.color = oc.bit.decodeColor(net.ReadUInt(32));
	local inherits = net.ReadUInt(32);
	group.inherits = inherits ~= 0 and oc.g(inherits) or nil;
	group.name = net.ReadString();
end);
net.Receive('oc.g.syncPerms', function(len)
	local isGlobal = net.ReadUInt(8) == 1;
	local groupid = net.ReadUInt(32);
	local permTreeStr = net.ReadString();
	dprint('syncing group perm data for '..groupid..':'..(isGlobal and 'global' or 'server')..' = '..permTreeStr);
	
	local permTree = pon.decode(permTreeStr);
	if isGlobal then
		oc.g(groupid).globalPerms = oc.permAdopt(permTree);
	else
		oc.g(groupid).serverPerms = oc.permAdopt(permTree);
	end
end);

local groups = {};
oc.groups = groups;
function oc.g(groupid)
	if not groups[groupid] then
		groups[groupid] = setmetatable({
			gid = groupid
		}, group_mt);
	end
	return groups[groupid];
end