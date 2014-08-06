oc.hook = {};
local hooks = {};
function oc.hook.Add( id, f )
	if not hooks[id] then 
		hooks[id] = {};
	end
	table.insert(hooks[id], f);
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