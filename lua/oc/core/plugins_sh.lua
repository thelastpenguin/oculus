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

function oc.LoadPlugins( dir )
	
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

function oc.LoadModules( fol )
	local _, dirs = file.Find(fol..'*', 'LUA');
	
	local p;
	for _, dir in pairs(dirs)do
		p = fol .. dir..'/';
		oc.LoadMsg(2, 'MODULE: '..dir);
		
		local init_cl = file.Exists( p..'init_cl.lua', 'LUA');
		local init_sv = file.Exists( p..'init_sv.lua', 'LUA');
		local init_sh = file.Exists( p..'init_sh.lua', 'LUA');
		
		if init_cl then
			oc.include_cl( p..'init_cl.lua' ) ('    init_cl.lua');
		end
		if init_sv then
			oc.include_sv( p..'init_sv.lua' ) ('    init_sv.lua');
		end
		if init_sh then
			oc.include_sh( p..'init_sh.lua' ) ('    init_sh.lua');
		end
		
	end
end


oc.LoadPlugins( 'oc_ext/plugins/' );

oc.LoadMsg('\nLOADING MODULES\n');
oc.LoadModules( 'oc_ext/modules/' );

-- use PostPluginsLoaded to create hooks.
oc.hook.Add( 'PluginsLoaded', oc.HookPluginField( 'PostPluginsLoaded' ) );

oc.hook.Call( 'PluginsLoaded' );
oc.hook.DeleteAll( 'PluginsLoaded' );