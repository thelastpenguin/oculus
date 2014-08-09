-- group add perm
local cmd = oc.command( 'permissions', 'groupaddlocalperm', function( pl, args )
	args.group:addPerm(args.perm, false);
	oc.notify_fancy( player.GetAll(), '#P granted local permission #S to #G', pl, args.perm, args.group );
end)
cmd:setHelp 'grant the group local access to the specified permission'
cmd:addParam 'group' { type = 'group', help = 'target group' }
cmd:addParam 'perm' { type = 'string', help = 'permission name', options = oc.autocomplete.commandPerms}


-- group del perm
local cmd = oc.command( 'permissions', 'groupdellocalperm', function( pl, args )
	args.group:delPerm(args.perm, false);
	oc.notify_fancy( player.GetAll(), '#P deleted local permission #S from #G', pl, args.perm, args.group );
end)
cmd:setHelp 'deny the group local access to the specified permission'
cmd:addParam 'group' { type = 'group', help = 'target group' }
cmd:addParam 'perm' { type = 'string', help = 'permission name', options = oc.autocomplete.commandPerms}


-- group add perm
local cmd = oc.command( 'permissions', 'groupaddglobalperm', function( pl, args )
	args.group:addPerm(args.perm, true);
	oc.notify_fancy( player.GetAll(), '#P granted global permission #S to #G', pl, args.perm, args.group );
end)
cmd:setHelp 'grant the group global access to the specified permission'
cmd:addParam 'group' { type = 'group', help = 'target group' }
cmd:addParam 'perm' { type = 'string', help = 'permission name', options = oc.autocomplete.commandPerms}


-- group del perm
local cmd = oc.command( 'permissions', 'groupdelglobalperm', function( pl, args )
	args.group:delPerm(args.perm, true);
	oc.notify_fancy( player.GetAll(), '#P deleted global permission #S from #G', pl, args.perm, args.group );
end)
cmd:setHelp 'deny the group global access to the specified permission'
cmd:addParam 'group' { type = 'group', help = 'target group' }
cmd:addParam 'perm' { type = 'string', help = 'permission name', options = oc.autocomplete.commandPerms}


local cmd = oc.command( 'permissions', 'groupinfo', function( pl, args )
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
		
		local function printPermTree(tree)
			local function recurse(depth, _tree, perm)
				if not perm then return end
				perm = perm..'.';
				for _, sub in ipairs(_tree)do
					oc.LoadMsg(depth, sub);
					recurse(depth + 2, tree:getPerm(perm..sub), perm..sub);
				end
			end
			
			for k,v in ipairs(tree.root)do
				oc.LoadMsg(2, v)
				recurse(4, tree:getPerm(v), v);
			end
		end
		
		if group.globalPerms then
			oc.LoadMsg(0, '\nGLOBAL PERMS:\n');
			printPermTree(group.globalPerms);
		end
		
		if group.serverPerms then
			oc.LoadMsg(0, '\nLOCAL PERMS:\n');
			printPermTree(group.serverPerms);
		end
	end);
end

cmd:setHelp 'print various information about the specified group'
cmd:addParam 'group' { type = 'group', help = 'group to examine' }