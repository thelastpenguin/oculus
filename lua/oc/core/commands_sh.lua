local oc = oc;

oc.commands = {};

-- STUBS REMOVE LATER
function oc.checkPerm( pl, perm )
	if not IsValid(pl) then return true end
	return oc.p(pl):getPerm(perm) and true or false;
end
function oc.canTarget( pl, targ )
	if not IsValid(pl) then return true end
	return oc.p(pl):getImmunity() >= oc.p(targ):getImmunity();
end



/* ======================================================================
	 	META OBJECT FOR EACH PARAMETER TYPE
	 ====================================================================== */

local paramtypes = {};
function oc.addParamType( typeid, table )
	paramtypes[ typeid ] = table;
end
oc.getParamType = oc.fn_ReadOnly( paramtypes );


/* ======================================================================
	 	META OBJECT FOR EACH COMMAND
	 ====================================================================== */
local command_mt = {};
command_mt.__index = command_mt;

function oc.command( category, command, action )
	command = string.lower( command );
	
	local c = {};
	
	c.category = category;
	c.action = action;
	c.command = command;
	c.perm = 'cmd.'..command;
	
	c.params = {};
	
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



/* ======================================================================
	 	COMMAND PARSING FROM CHAT
	 ====================================================================== */
oc.hook.Add( 'PlayerSay', function( pl, text )
	if text:sub( 1, 1 ) == '!' or text:sub( 1, 1 ) == '/' then
		
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
	local perm = meta:getPerm( );
	
	if not oc.checkPerm( pl, perm ) then
		oc.notify( pl, oc.cfg.color_error, 'You do not have permission \''..perm..'\'.' );
		return ;
	end
	
	local args = oc.ParseString( text_arg );
	oc.RunCommand( pl, meta, args );
end

/* ======================================================================
	 	CONSOLE COMMAND EXECUATION
	 ====================================================================== */
function oc.RunConCommand( pl, text_cmd, args )
	local meta = oc.commands[ text_cmd ];
	local perm = meta:getPerm( );
	
	if not oc.checkPerm( pl, perm ) then
		oc.notify( pl, oc.cfg.color_error, 'You do not have permission \''..perm..'\'.' );
		return ;
	end
	
	oc.notify( pl, 'You ran command '..text_cmd );
	
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

	if not pl then 
		Error('no player could be found');
	end

	return oc.AutocompleteCommand( pl, text_arg )
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

function oc.RunCommand( pl, meta, args )
	-- process arguments.
	local params = meta.params;
	
	local succ = oc.hook.Call( 'ProcessCMDArgs', pl, params, args );
	if succ == false then return end
	
	-- make some arguments optional
	for i = #args+1, #params do
		if not params[i].optional then
			oc.notify(pl, oc.cfg.color_error, 'PARSE ERROR: too few arguements. Got ' .. #args .. ' expected ' .. #params );
			return ;
		end
	end
	
	local processed = {};
	for i = 1, #args do
		local arg = args[i];
		local param = params[i];
		local pmeta = oc.getParamType( param.type );
		if not pmeta then
			oc.notify( pl, oc.cfg.color_error,'CONTACT A CODER! PARAM TYPE: '..param.type..' does not exist! This should never happen.' );
			return ;
		end
		
		local succ, narg = pmeta.parse( arg, param, pl );
		
		if not succ then
			oc.notify( pl, oc.cfg.color_error, 'PARSE ERROR: Failed to parse arg ('..i..') '..narg..'. ', narg );
			return ;
		end
		
		processed[ param.pid ] = narg;
	end
	
	local succ, err = pcall(meta.action, pl, processed, meta);
	if not succ then
		oc.notify( pl, oc.cfg.color_error, 'ERROR ON COMMAND: ', err );
		return ;
	end
	
	if meta.funcRunOnClient then
		net.Start('oc.cmd.runOnClient')
			net.WriteString(meta:getCommand());
			net.WriteString(pon.encode(processed));
		net.Send(pl);
	end
end

-- handle commands with client side components
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

-- strip arguements that have zero length
oc.hook.Add( 'ProcessCMDArgs', function( pl, params, args )
	xfn.filter(args, function(arg)
		return arg:len() > 0;
	end);
end);

-- auto fill in default values
oc.hook.Add( 'ProcessCMDArgs', function( pl, params, args )
	for k,v in pairs( params )do
		if v.default and not args[k] then args[k] = isfunction(v.default) and v.default(pl, v, args[k]) or v.default end
	end
end);

oc.hook.Add( 'ProcessCMDArgs', function( pl, params, args )
	
	-- fill to the end of the line so quotes aren't needed for ban reasons etc.
	if #args > #params then
		if #params ~= 0 then
			if params[#params].fill_line then
				local lastArg = #params;
				for i = lastArg + 1, #args do
					args[lastArg] = args[lastArg]..' '..args[i];
					args[i] = nil;
				end
			else
				oc.notify( pl, Color(255,155,0), 'ERROR: too many arguements. Expected '..#params..' got '..#args..' params.' );
				return false;
			end
		end
	end
	
end);


/* ======================================================================
	 	PARAMETER TYPES FOR COMMANDS
	 ====================================================================== */


-- STRING
local TYPE = {};
TYPE.parse = function( arg ) return arg:len() ~= 0, arg end
oc.addParamType( 'string', TYPE );

oc.fancy_formats['S'] = function( arg ) 
	return oc.cfg.color_string, tostring( arg );
end

-- NUMBER
local TYPE = {};
TYPE.parse = function( str, param )
	local n = tonumber( str )
	if not n then return false end
	return true, n ;
end
oc.addParamType( 'number', TYPE );
oc.fancy_formats['N'] = function( arg )
	return oc.cfg.color_number, tonumber( arg );
end

-- TIME
local mults = {}
mults['m'] = 60;
mults['h'] = 60*mults['m'];
mults['d'] = 24*mults['h'];
mults['w'] = 7 *mults['d'];
local divs = {'w','d','h','m'}
local TYPE = {};
TYPE.parse = function( arg, param )
	if tonumber(arg) then
		return true, tonumber(arg);
	end
	if param.forever and arg == 'forever' then
		return true, 0;
	end
	
	local s = 0;
	for v, t in string.gmatch( arg, '(%d+)(%a+)' ) do
		if mults[t] then s = s + v * mults[t] end
	end
	return true, s;
end
oc.addParamType( 'time', TYPE );
oc.fancy_formats['T'] = function( number )
	if number == 0 then
		return oc.cfg.color_time, 'forever';
	end
	
	local time = ''
	for _, div in ipairs( divs )do
		local val = math.floor( number / mults[div] );
		if val > 0 then
			time = time .. val .. div;
		end
		number = number % mults[div];
	end
	return oc.cfg.color_time, time ;
end


local TYPE = {};
local function findPlayersByName( arg )
	if arg == '*' then
		return player.GetAll();
	else
		local targ = {};
		local searchfor = string.lower( arg );
		local n;
		
		for k, v in pairs( player.GetAll() )do
			n = string.lower( v:Name() );
			if n == searchfor or v:SteamID() == searchfor then
				return {v};
			elseif n:find( searchfor ) then
				targ[#targ+1] = v;
			end
		end
		
		return targ;
	end
end

TYPE.parse = function( arg, param, pl )
	local targets = xfn.filter(findPlayersByName( arg ), 
		function(other)
			return oc.canTarget(pl, other)
		end);
	
	if #targets == 0 then 
		return false, 'No targets found';
	end
	
	if param.multi then
		return true, targets;
	elseif #targets ~= 1 then
		return false, 'Too many targets';
	else
		return true, targets[1];
	end
end

oc.addParamType( 'player', TYPE );
oc.fancy_formats['P'] = function( players )
	-- special case for console
	if type(players) == 'Entity' and not IsValid(players) then
		return Color(0,0,0), '(Console)';
	end
	
	if type( players ) ~= 'table' then
		players = { players };
	end
	
	local addName, addSep ;

	local playerCount = #players;
	function addSep( index )
		if index == playerCount then
			return
		elseif index == playerCount - 1 then
			return color_white, ' and ', addName( index + 1 );
		else
			return color_white, ', ', addName( index + 1 );
		end
	end
	function addName( index )
		local ply = players[index];
		if type( ply ) == 'Player' then
			return team.GetColor( ply:Team() ) or color_white, ply:Name(), addSep( index ) ;
		elseif ply then
			return addName( index + 1 );
		end
	end
	
	return addName( 1 );
end

TYPE.autocomplete = function(param)
	return xfn.map(player.GetAll(), function(pl) return pl:Name() end);
end



-- GROUP
local TYPE = {};
TYPE.parse = function( str, param )
	local id = tonumber(str);
	if id and oc.g(id) then
		return true, oc.g(id);
	else
		for k,v in pairs(oc.groups)do
			if v.name == str then return true, v end
		end
		return false
	end
end
TYPE.autocomplete = function(param)
	local res = {};
	for k,v in pairs(oc.groups)do
		res[#res+1] = v.name;
	end
	return res
end

oc.addParamType( 'group', TYPE );
oc.fancy_formats['G'] = function( arg )
	return arg.color, arg.name;
end
