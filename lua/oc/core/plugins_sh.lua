local plugins = {};
function oc.RegisterPlugin( id, plugin )
	plugins[id] = plugin;
	plugin.id = id;
end

do
	local alreadyLinked = {};
	function oc.HookPluginField( field )
		if alreadyLinked[field] then return end
		alreadyLinked[field] = true;
		
		local plugs = {};
		for k,v in pairs( plugins )do
			if v[field] then
				table.insert( plugs, v )
			end
		end
		return function( ... )
			local p, a, b, c, d ;
			for i = 1, #plugs do
				p = plugs[i];
				a, b, c, d = p[field]( p, ... );
				if a then
					return a, b, c, d ;
				end
			end
		end
	end
end

function oc.LoadPlugins( dir, load )
	
	local p ;
	local fol = dir ;
	local files = file.Find( fol .. "*.lua", "LUA");
	for _, f in SortedPairs( files, true )do
		p = fol .. f;
		oc.include_sh( p )( 'PLUGIN FILE: '..f );
	end
	
	
	local fol = dir..'server/' ;
	local files = file.Find( fol .. "*.lua", "LUA");
	for _, f in SortedPairs( files, true )do
		p = fol .. f;
		oc.include_sv( p )( 'PLUGIN FILE: '..f );
	end
	
	local fol = dir..'client/' ;
	local files = file.Find( fol .. "*.lua", "LUA");
	for _, f in SortedPairs( files, true )do
		p = fol .. f;
		oc.include_cl( p )( 'PLUGIN FILE: '..f );
	end
	
end

oc.LoadPlugins( 'oc_ext/plugins/' );

-- use PostPluginsLoaded to create hooks.
oc.hook.Add( 'PluginsLoaded', oc.HookPluginField( 'PostPluginsLoaded' ) );

oc.hook.Call( 'PluginsLoaded' );
oc.hook.DeleteAll( 'PluginsLoaded' );