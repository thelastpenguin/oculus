oc.hook = {};
local hooks = {};
local hook_names = {};

local function indexByName(id, func, name)
	hook_names[id..'-'..name] = func;
end

local function deleteByName(id, name)
	local uid = id..'-'..name;
	local func = hook_names[uid];
	if not hooks[id] or not func then return end
	hook_names[uid] = nil;
	
	for ind, val in pairs(hooks[id])do
		if val == func then
			dprint('removed function with name: ' .. name .. ' at index ' .. ind);
			return table.remove(hooks[id], ind);
		end
	end
end

function oc.hook.Add( id, name, func )
	if func and type(name) == 'string' then
		deleteByName(id, name);
		indexByName(id, func, name);
	elseif type(name) == 'function' then
		func = name;
		name = nil;
	else
		error('hook.Add expected either name, func or func');
	end
	if not hooks[id] then 
		hooks[id] = {};
	end
	table.insert(hooks[id], func);
	return f;
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
	if hooks[id] then
		for id, _fn in ipairs(hooks[id])do
			if fn == _fn then
				table.remove(hooks[id], id);
				break;
			end
		end
	end
end