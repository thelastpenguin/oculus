local oc = oc;

oc.commands = oc.commands or {};

if SERVER then
	function oc.canAdmin( pl )
		if not IsValid(pl) then return true end
		return oc.p(pl).AdminMode or false
	end
else
	function oc.canAdmin(pl)
		return true;
	end
end
function oc.checkPerm( pl, perm )
	if not IsValid(pl) then return true end
	return oc.p(pl):getPerm(perm) and true or false;
end

local LazyTester = { // I dont really want to add a perm so we can just leave this until Oculus is no longer in need of constant testing.
	["STEAM_0:0:33167998"] = true,
	["STEAM_0:1:57264173"] = true
}

function oc.canTarget( pl, targ )
	if not IsValid(pl) then return true end
	if LazyTester[pl:SteamID()] then return true end
	if oc.p(pl):getImmunity() <= oc.p(targ):getImmunity() then
		return false
	end
	return true
end

/* ======================================================================
	 	META OBJECT FOR EACH COMMAND
	 ====================================================================== */
local command_mt = {};
command_mt.__index = command_mt;

function oc.command( category, command, action )
	
	local c = {};
	c.printName = command;
	command = command:lower():gsub(' ', '');
	
	c.category = category;
	c.action = action;
	c.command = command;
	c.perm = 'cmd.'..command;
	
	c.params = {};
	c.flags = {};
	
	setmetatable( c, command_mt );
	
	oc.commands[ command ] = c;
	
	oc.perm.register(c.perm); -- register the command permission.
	
	return c;
end

--
-- METHODS
--

-- add parameter 
function command_mt:addParam( pid )
	return function( info )
		info.pid = pid;
		self.params[#self.params+1] = info;
		for k,v in ipairs( info )do
			info[v] = true;
		end
		return self;
	end
end

-- set help
function command_mt:setHelp( text )
	self.help = text;
end

function command_mt:getHelp()
	return self.help;
end

-- set console only
function command_mt:setConsoleOnly( _b )
	self.conOnly = _b;
end

function command_mt:isConsoleOnly( _b )
	return self.conOnly or false;
end

-- get parameters
function command_mt:getParam( index )
	return self.params[index];
end

-- get command
function command_mt:getCommand( )	
	return self.command;
end

-- get permission
function command_mt:getPerm()
	return self.perm;
end

function command_mt:playerCanUse(pl)
	return oc.checkPerm(pl, self.perm);
end

function command_mt:playerGetExtraPerm(pl, extra)
	return oc.checkPerm(pl, self.perm..'.'..extra);
end

function command_mt:addExtraPerm(perm)
	if not self.extraPerms then
		self.extraPerms = {};
	end
	table.insert(self.extraPerms, perm);
	
	oc.perm.register(self.perm..'.'..perm); -- register the permission
end
function command_mt:getExtraPerms()
	return self.extraPerms;
end
function command_mt:runOnClient(func)
	self.funcRunOnClient = func;
end
function command_mt:addFlag(flag)
	self.flags[flag] = true;
end
function command_mt:hasFlag(flag)
	return self.flags[flag];
end



/* ======================================================================
	 	COMMAND PARSING FROM CHAT
	 ====================================================================== */
oc.hook.Add( 'PlayerSay', 'core.ChatCommand', function( pl, text )
	if text:sub( 1, 1 ) == '!' then
		
		local cmd = string.match( text, '%a+', 2 );
		if not cmd then 
			oc.print("command was not found in text.");
			return '';
		end
		
		text_cmd = cmd:lower( );
		text_arg = text:sub( text_cmd:len() + 2 );
		
		if oc.commands[ text_cmd ] then
			oc.print("RUNNING COMMAND: "..text_cmd.." ARG STR: "..text_arg );
			oc.RunChatCommand( pl, text_cmd, text_arg );
			return '';
		else
			oc.print("COMMAND NOT FOUND! ", text_cmd );
		end
		
		oc.notify( pl, oc.cfg.color_error, text .. ' is not a valid command!');
		
		return '';
	end
end);



function oc.RunChatCommand( pl, text_cmd, text_arg )
	local meta = oc.commands[ text_cmd ];
	local args = {oc.parseLine( text_arg )};
	oc.RunCommand( pl, meta, args );
end

/* ======================================================================
	 	CONSOLE COMMAND EXECUATION
	 ====================================================================== */
function oc.RunConCommand( pl, text_cmd, args )
	local meta = oc.commands[ text_cmd ];
	oc.RunCommand( pl, meta, args );
end


concommand.Add('oc', function(pl, _, args)
	if CLIENT then
		RunConsoleCommand('_oc', unpack(args));
		return ;
	end
	
	if #args == 0 then
		oc.notify(pl, oc.cfg.color_error, 'Command expected got nothing');
		return ;
	end
	local cmd = table.remove(args, 1):lower();
	local cmdMeta = oc.commands[cmd];
	if not cmdMeta then
		oc.notify(pl, oc.cfg.color_error, 'Command \''..cmd..'\' not found');
		return ;
	end
	
	oc.RunConCommand(pl, cmd, args);
end, function(_, text_arg)

	local pl = CLIENT and LocalPlayer() or Entity(1)
	
	
	return oc.autocomplete.general(text_arg, pl)
end);

if SERVER then
	concommand.Add('_oc', function(pl, _, args)
		if #args == 0 then
			oc.notify(pl, oc.cfg.color_error, 'Command expected got nothing');
			return ;
		end
		local cmd = table.remove(args, 1):lower();
		local cmdMeta = oc.commands[cmd];
		if not cmdMeta then
			oc.notify(pl, oc.cfg.color_error, 'Command \''..cmd..'\' not found');
			return ;
		end
		
		oc.RunConCommand(pl, cmd, args);
	end);
end

/* ======================================================================
	 	COMMAND EXECUTION
	 ====================================================================== */
if SERVER then
	util.AddNetworkString('oc.cmd.runOnClient');
else
	net.Receive('oc.cmd.runOnClient', function()
		local cmd = net.ReadString();
		local arg = pon.decode(net.ReadString());
		local meta = oc.commands[cmd];
		if not meta then return end
		meta.funcRunOnClient(arg, meta);
	end);
end

function oc.RunCommand( pl, meta, args )
	-- process arguments.
	local params = meta.params;
	
	local cancmd = oc.hook.Call('PlayerCanRunCommand', pl, meta);
	if cancmd then
		oc.notify(pl, oc.cfg.color_error, cancmd)
		return 
	end
	
	local compiler = oc.parser.compile(params, args, pl);
	if compiler.error then
		oc.notify( pl, oc.cfg.color_error, 'FAILED TO RUN COMMAND: FATAL ERROR');
		return ;
	end

	local succ, err = pcall(meta.action, pl, compiler.result, meta);
	if not succ then
		oc.notify( pl, oc.cfg.color_error, 'INTURNAL ERROR: ', err );
		return ;
	end
	
	if meta.funcRunOnClient then
		net.Start('oc.cmd.runOnClient')
			net.WriteString(meta:getCommand());
			net.WriteString(pon.encode(compiler.result));
		net.Send(pl);
	end
end


oc.hook.Add('PlayerCanRunCommand', 'core.CheckPerm', function(pl, meta)
	if not meta:playerCanUse(pl) then
		return 'You don\'t have permission for this command';
	end
end);
oc.hook.Add('PlayerCanRunCommand', 'core.AdminMode', function(pl, meta)
	if meta:hasFlag('AdminMode') and not oc.canAdmin(pl) then
		return 'You must enter admin mode to use this command!'
	end
end);



/* ======================================================================
	 	COMMAND EXECUTION
	 ====================================================================== */
if SERVER then
	util.AddNetworkString('oc.cmd.runOnServer');
	net.Receive('oc.cmd.runOnServer', function(_, pl)
		local cmd = net.ReadString();
		local args = net.ReadTable();
		
		-- make sure the table is safe
		local newArgs = {};
		for k,v in ipairs(args)do
			local tv = type(v);
			if tv ~= 'string' and tv ~= 'table' then v = tostring(v) end
			newArgs[#newArgs+1] = v;
		end
		
		
		local cmdMeta = oc.commands[cmd];
		if not cmdMeta then
			oc.notify(pl, oc.cfg.color_error, 'Command \''..cmd..'\' not found');
			return ;
		end
		
		oc.RunCommand(pl, cmdMeta, args);
		
	end);
else
	function oc.netRunCommand( cmd, args )
		net.Start('oc.cmd.runOnServer');
			net.WriteString(cmd);
			net.WriteTable(args);
		net.SendToServer();
	end
end