oc.group = {};

local groups = {};


function oc.group.sync(done)
	return oc.data.groupsGetAll(function(groups)
		oc.LoadMsg( 2, 'LOADED GROUPS\n');
		for _, group in pairs(groups)do
			
			groups[group.g_id] = group;
			
			oc.LoadMsg(2, group.g_id..' - '..group.group_name);
			
			oc.data.groupFetchPerms(oc.data.svid, group.g_id, function(data)
				xfn.map(data, function(row)
					return row.perm
				end);
				group.perms = oc.perm(data);
			end):wait();
		end
	end);
end
oc.group.sync():wait();

function oc.group.groupCreate( )
end


local group_mt = {};
group_mt.__index = group_mt;


function oc.g(groupid)
	if groups[groupid] then
		groups[groupid] = setmetatable({}, group_mt);
	end
	return groups[groupid];
end
