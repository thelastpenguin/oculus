local ocp = oc.p;
local Player = FindMetaTable('Player');

oc.perm.register('meta.isSuperAdmin');
oc.perm.register('meta.isAdmin');

oc.hook.Add('PostGamemodeLoaded', function()
	function Player:IsSuperAdmin()
		local ocp = ocp(self);
		return (ocp:getPerm('meta.isSuperAdmin') or ocp:getPerm('meta.isAdmin')) and true or false;
	end

	function Player:IsAdmin()
		return ocp(self):getPerm('meta.isAdmin') and true or false;	
	end

end);