oc.hook = {};
local hooks = {};
local hook_names = {};

local function indexByName(id, name, func)
	local longName = id..'-'..name;
	local oldFunc = hook_names[longName];
	hook_names[longName] = func;

	if oldFunc and hooks[id] then
		for ind, fn in pairs(hooks[id]) do
			if fn == oldFunc then
				return ind;
			end
		end
		return #hooks[id] + 1;
	else
		return #hooks[id] + 1;
	end
end

local function deleteByName(id, name)
	local uid = id..'-'..name;
	local func = hook_names[uid];
	if not hooks[id] or not func then return end
	hook_names[uid] = nil;
	
	for ind, val in pairs(hooks[id])do
		if val == func then
			dprint('removed function with name: ' .. name .. ' at index ' .. ind);
			return ind;
		end
	end
end


function oc.hook.Add( id, name, func )

	if not hooks[id] then 
		hooks[id] = {};
	end

	if func and type(name) == 'string' then
		local insertIndex = indexByName(id, name, func);
		hooks[id][insertIndex] = func;
	elseif type(name) == 'function' then
		func = name;
		name = nil;
		table.insert(hooks[id], func);
	else
		error('hook.Add expected either name, func or func');
	end
	
	dprint('ADDED HOOK: '..id..' TOTAL: '..#hooks[id]);

	return func;
end

function oc.hook.Call( id, ... )
	if hooks[id] then
		local a, b, c, d;
		for _, fn in ipairs(hooks[id])do
			a, b, c, d = fn(...)
			if a then
				return a, b, c, d;
			end
		end
	end
end

function oc.hook.DeleteAll( id )
	hooks[id] = nil;
end
function oc.hook.Delete(id, fn)
	local t = type(fn);
	if t == 'function' then
		if hooks[id] then
			for id, _fn in ipairs(hooks[id])do
				if fn == _fn then
					table.remove(hooks[id], id);
					break;
				end
			end
		end
	elseif t == 'string' then
		return deleteByName(id, fn);
	end
end