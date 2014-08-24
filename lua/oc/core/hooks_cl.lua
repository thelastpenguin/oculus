hook.Add('HUDPaint', 'oc.hudPaint', function()
	oc.hook.Call('HUDPaint');
end);
oc.hook.Add('HUDPaint', oc.HookPluginField('HUDPaint'));

hook.Add('OnEntityCreated', 'oc.OnEntityCreated', function(ent)
	oc.hook.Call('OnEntityCreated', ent);
end);
oc.hook.Add('OnEntityCreated', oc.HookPluginField('OnEntityCreated'));

hook.Add('PlayerInitialSpawn', 'oc.PlayerInitialSpawn', function(pl)
	oc.hook.Call('PlayerInitialSpawn', pl);
end);
oc.hook.Add('PlayerInitialSpawn', oc.HookPluginField('PlayerInitialSpawn'));

