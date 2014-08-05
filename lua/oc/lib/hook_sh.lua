oc.hook = {};
local hooks = {};
function oc.hook.Add( id, f )
	if not hooks[id] then 
		hooks[id] = f;
	else
		local of = hooks[id];
		hooks[id] = function( ... )
			local a, b, c, d = of( ... );
			if a then return a, b, c, d end
			return f(...);
		end
	end
end

function oc.hook.Call( id, ... )
	if hooks[id] then
		hooks[id](...);
	end
end

function oc.hook.DeleteAll( id )
	hooks[id] = nil;
end