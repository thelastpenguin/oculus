
hook.Add('PlayerInitialSpawn', 'oc.hook',function( pl )
	oc.hook.Call('PlayerInitialSpawn', pl);
end);
oc.hook.Add('PlayerInitialSpawn', oc.HookPluginField('PlayerInitialSpawn'));

hook.Add('PlayerDisconnected', 'oc.hook', function( pl )
	oc.hook.Call('PlayerDisconnected', pl);
end);
oc.hook.Add('PlayerDisconnected', oc.HookPluginField('PlayerDisconnected'));

hook.Add('PlayerSpawn', 'oc.hook',function( pl )
	oc.hook.Call('PlayerSpawn', pl);
end);
oc.hook.Add('PlayerSpawn', oc.HookPluginField('PlayerSpawn'));

hook.Add('PlayerSay', 'oc.hook', function( ... )
	return oc.hook.Call('PlayerSay', ...);
end);
oc.hook.Add('PlayerSay', oc.HookPluginField('PlayerSay'));

hook.Add('OnEntityCreated', 'oc.OnEntityCreated', function(ent)
	oc.hook.Call('OnEntityCreated', ent);
end);
oc.hook.Add('OnEntityCreated', oc.HookPluginField('OnEntityCreated'));