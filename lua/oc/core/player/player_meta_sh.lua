local ocp = oc.p;
local Player = FindMetaTable('Player');

oc.perm.register('meta.isSuperAdmin');
oc.perm.register('meta.isAdmin');

oc.hook.Add('PostGamemodeLoaded', function()
	function Player:IsSuperAdmin()
		if not canAdmin(pl) then
			return false
		end
		return (ocp(self):getPerm('meta.isSuperAdmin') and true or false;
	end

	function Player:IsAdmin()
		if not canAdmin(pl) then
			return false
		end
		return ocp(self):getPerm('meta.isAdmin') and true or false;	
	end
	
	function Player:setPermVar(key, value)
		-- causes error if called client side
		ocp(self):setVar(key, value);
	end
	function Player:getPermVar(key)
		return ocp(self):getVar(key);
	end
end);