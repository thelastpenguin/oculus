oc.LoadMsg('\nMENU SYSTEM\n');

oc.LoadMsg('this will be one huge ass plugin');

ocm.menu = {};

oc.include_cl 'fonts_cl.lua' 'fonts';
oc.include_cl 'vgui_theme_cl.lua' 'oculus menu vgui theme';
oc.include_cl 'vgui/util.lua' 'vgui util';
oc.include_cl 'vgui/main.lua' 'vgui main';
oc.include_cl 'vgui/perms.lua' 'vgui perms';

oc.include_sh 'core/views_sh.lua' 'views shared';
oc.include_sh 'core/parser_ext_sh.lua' 'parser ext sh';
oc.include_sh 'core/parser_ext_cl.lua' 'parser ext cl';

oc.LoadMsg('\nLOADING VIEWS\n');
print(path.join(path.cwd(), '../views')..'/');
oc.IncludeDir(path.join(path.cwd(), '../views')..'/', function(f)
	oc.include_cl(f)('view: '..f);
end);
oc.IncludeDir(path.join(path.cwd(), '../views_sv')..'/', function(f)
	oc.include_sv(f)('view sv: '..f);
end);


-- add command
local menu;
local cmd = oc.command( 'menu', 'menu', function( pl, args )
end);
cmd:runOnClient(function()
	if ValidPanel(menu) then menu:Remove() end
	menu = vgui.Create('oc_main');
end);