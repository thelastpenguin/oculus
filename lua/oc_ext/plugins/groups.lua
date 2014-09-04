-- group add perm
local cmd = oc.command( 'permissions', 'Group AddLocalPerm', function( pl, args )
	args.group:addPerm(args.perm, false);
	oc.notify_fancy( player.GetAll(), '#P granted local permission #S to #G', pl, args.perm, args.group );
end)
cmd:setHelp 'grant the group local access to the specified permission'
cmd:addParam 'group' { type = 'group', help = 'target group' }
cmd:addParam 'perm' { type = 'string', help = 'permission name', options = oc.autocomplete.perms}


-- group del perm
local cmd = oc.command( 'permissions', 'Group DelLocalPerm', function( pl, args )
	args.group:delPerm(args.perm, false);
	oc.notify_fancy( player.GetAll(), '#P deleted local permission #S from #G', pl, args.perm, args.group );
end)
cmd:setHelp 'deny the group local access to the specified permission'
cmd:addParam 'group' { type = 'group', help = 'target group' }
cmd:addParam 'perm' { type = 'string', help = 'permission name', options = oc.autocomplete.perms}


-- group add perm
local cmd = oc.command( 'permissions', 'Group AddGlobalPerm', function( pl, args )
	args.group:addPerm(args.perm, true);
	oc.notify_fancy( player.GetAll(), '#P granted global permission #S to #G', pl, args.perm, args.group );
end)
cmd:setHelp 'grant the group global access to the specified permission'
cmd:addParam 'group' { type = 'group', help = 'target group' }
cmd:addParam 'perm' { type = 'string', help = 'permission name', options = oc.autocomplete.perms}


-- group del perm
local cmd = oc.command( 'permissions', 'Group DelGlobalPerm', function( pl, args )
	args.group:delPerm(args.perm, true);
	oc.notify_fancy( player.GetAll(), '#P deleted global permission #S from #G', pl, args.perm, args.group );
end)
cmd:setHelp 'deny the group global access to the specified permission'
cmd:addParam 'group' { type = 'group', help = 'target group' }
cmd:addParam 'perm' { type = 'string', help = 'permission name', options = oc.autocomplete.perms}

-- group update settings
local cmd = oc.command( 'permissions', 'Group Update', function( pl, args )
	local group = args.group;
	group:setColor(args.color);
	group:setImmunity(args.immunity);
	group:setName(args.name);
	group:sync();
	group:updateDb();

	oc.notify_fancy(player.GetAll(), '#P updated group #G to name: #S immunity: #N color: #N, #N, #N',
		pl, 
		args.group, 
		args.name,
		args.immunity,
		args.color.r, args.color.g, args.color.b);

end);
cmd:setHelp 'update the group\'s settings'
cmd:addParam 'group' { type = 'group' }
cmd:addParam 'name' { type = 'string' }
cmd:addParam 'immunity' { type = 'number' }
cmd:addParam 'color' { type = 'color' }

-- group set inheritance
local cmd = oc.command( 'permissions', 'Group SetParent', function( pl, args )
	local group = args.group;
	group:setInherits(args.parent);

	group:sync();
	group:updateDb();

	if args.parent then
		oc.notify_fancy(player.GetAll(), '#P set group #G\'s parent to #G', pl, args.group, args.parent);
	else
		oc.notify_fancy(player.GetAll(), '#P removed #G\'s inheritance', pl, args.group);
	end
end);
cmd:addParam 'group' { type = 'group', help = 'group to modify' }
cmd:addParam 'parent' { type = 'group', help = 'group to inherit', 'optional' }

-- group create
local cmd = oc.command( 'permissions', 'Group Create', function( pl, args )
	if args.parent then
		oc.data.groupCreate(args.parent.gid, args.name, function()
			oc.notify_fancy(player.GetAll(), '#P created new group #S inheriting from #G.', pl, args.name, args.parent);
			oc.group.sync();
		end);	
	else
		oc.data.groupCreate(0, args.name, function()
			oc.notify_fancy(player.GetAll(), '#P created new group #S with no inheritance.', pl, args.name);
			oc.group.sync();
		end);	
	end
end);
cmd:addParam 'name' { type = 'string' }
cmd:addParam 'parent' { type = 'group', 'optional' };


-- group print info to console (for really hardcore users)
local cmd = oc.command( 'permissions', 'Group Info', function( pl, args )
	net.Start('oc.cmd.groupinfo.run');
		net.WriteUInt( args.group.gid, 32 );	
	net.Send(pl);
end)

if SERVER then
	util.AddNetworkString('oc.cmd.groupinfo.run');
else
	net.Receive('oc.cmd.groupinfo.run', function()
		local groupid = net.ReadUInt(32);
		local group = oc.g(groupid);
		
		oc.LoadMsg(0, '\nNAME: '..group.name);
		oc.LoadMsg(0, 'IMMUNITY: '..group.immunity);
		oc.LoadMsg(0, 'INHERITS: '..(group.inherits and group.inherits.name or 'nothing'));
		
		local function printChildren( obj, depth, perm )
			local cldrn = obj:getPerm(perm);
			for k,v in pairs(cldrn) do
				oc.LoadMsg( depth, v );
				printChildren( obj, depth + 2, perm..'.'..v );
			end
		end
		
		if group.globalPerms then
			oc.LoadMsg(0, 'GLOBAL PERMS:');
			for k,v in pairs(group.globalPerms:getPerm('*')) do
				oc.LoadMsg(2, v);
				printChildren(group.globalPerms, 4, v);
			end
		end
		
		if group.serverPerms then
			oc.LoadMsg(0, 'SERVER PERMS:');
			for k,v in pairs(group.serverPerms:getPerm('*')) do
				oc.LoadMsg(2, v);
				printChildren(group.serverPerms, 4, v);
			end
		end
	end);
end

cmd:setHelp 'print various information about the specified group'
cmd:addParam 'group' { type = 'group', help = 'group to examine' }