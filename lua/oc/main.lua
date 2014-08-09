oc._include_sh '_config_sh.lua' ;
oc._include_sh 'lib/functionutil.lua' ;
require 'xfn';

-- FORMATTED LOADING MESSAGE
do
	local print, string, table, isnumber = print, string, table, isnumber ;
	local br = ''; for i = 1, 80 + 4 do br = br .. '=' end
	local brd = '= '; for i = 1, 80 do brd = brd .. '-' end; brd = brd..' ='
	function oc.LoadMsg( depth, ... )
		local arg ;
		if isnumber( depth ) then
			arg = {...}
		else
			arg = {depth, ... }
			depth = 0;
		end
		local msg = table.concat( arg , ' ' );
		if msg:len( ) == 0 then print( depth > 0 and brd or br ) return end
		if string.find( msg, '\n' ) then 
			oc.ForEach( string.Explode( '\n', msg ), function( str )
						oc.LoadMsg( depth, str );
					end);
			return ;
		end
		print( string.format( '= %'..(depth)..'s%-'..(80-depth)..'s =', '', msg ) );
	end
	
	oc.print = oc.fn_IF( oc.cfg.debug, xfn.fn_partial( print, '[oc]') );
end

--
-- INCLUDE FUNCTION WRAPPER
--
local function wrapper( func, shouldPrint )
	return oc.fn_Curry( oc.fn_Parallel( oc.fn_IF( shouldPrint, function( path, msg ) oc.LoadMsg( 0, msg ) end ),func ), 2 );
end

oc.include_sh = wrapper( oc._include_sh, function() return true end );
oc.include_cl = wrapper( oc._include_cl, function() return CLIENT end );
oc.include_sv = wrapper( oc._include_sv, function() return SERVER end );

--
-- LOAD FILES BELOW THIS LINE.
--

print();oc.LoadMsg( '\nOCULUS ADMIN\n    by TheLastPenguin\n')

-- DEPENDENCIES
print();oc.LoadMsg('\nREQUIRING DEPENDENCIES\n');
require 'pon';
require 'async';	
require 'rpc';
require 'pnet';
require 'dprint';
(SERVER and require or xfn.noop)('pmysql')

-- LIBRARIES
print();oc.LoadMsg( '\nLIBRARIES\n' );
oc.include_sh 'lib/hook_sh.lua' 'LIB: hooks';

print();oc.LoadMsg( '\nUTILS\n' );
oc.include_sh 'util/stringutil.lua' 'UTIL: string util';
oc.include_sv 'util/data_sv.lua' 'UTIL: data api' ;
oc.include_sh 'util/feedback_sh.lua' 'UTIL: feedback';
oc.include_sh 'util/binary_sh.lua' 'UTIL: binary';
oc.include_sh 'util/obj_perms_sh.lua' 'UTIL: perms';

print();oc.LoadMsg( '\nCORE\n' );
oc.include_sv 'core/group_sv.lua' 'CORE: group sv';
oc.include_cl 'core/group_cl.lua' 'CORE: group cl';
oc.include_sv 'core/player_sv.lua' 'CORE: player sv';
oc.include_cl 'core/player_cl.lua' 'CORE: player cl';
oc.include_sh 'core/commands_sh.lua' 'CORE: commands';
oc.include_sh 'core/autocomplete_sh.lua' 'CORE: autocomplete';
oc.include_sh 'core/plugins_sh.lua' '\nCORE: plugins\n';


print();oc.LoadMsg( '\nHOOKS\n' );
oc.include_sv 'core/hooks_sv.lua' 'server hooks';
oc.include_cl 'core/hooks_cl.lua' 'client hooks';


oc.hook.Call('loaded');
