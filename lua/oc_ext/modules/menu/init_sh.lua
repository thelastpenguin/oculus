oc.LoadMsg('\nMENU SYSTEM\n');

oc.LoadMsg('this will be one huge ass plugin');

oc.menu = {};

oc.include_cl 'fonts_cl.lua' 'fonts';
oc.include_cl 'vgui/util.lua' 'vgui util';
oc.include_cl 'vgui/main.lua' 'vgui main';
oc.include_sh 'core/views_sh.lua' 'views shared';

oc.LoadModules( 'oc_ext/modules/menu/tabs/' );


local menu;
local cmd = oc.command( 'menu', 'menu', function( pl, args )
end);
cmd:runOnClient(function()
	if ValidPanel(menu) then menu:Remove() end
	menu = vgui.Create('oc_main');
end);