oc.commands = {};

-- STUBS REMOVE LATER
function oc.checkPerm( pl, perm )
	return oc.p(pl):getPerm(perm) and true or false;
end
function oc.canTarget( pl, targ )
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
function command_mt:getPerm( )
	return self.perm;
end





/* ======================================================================
	 	COMMAND PARSING FROM CHAT
	 ====================================================================== */
oc.hook.Add( 'PlayerSay', function( pl, text )
	if text:sub( 1, 1 ) == '!' then
		
		local cmd = string.match( text, '%a+', 2 );
		if not cmd then 
			oc.print("command was not found in text.");
			return ;
		end
		
		text_cmd = cmd:lower( );
		text_arg = text:sub( text_cmd:len() + 2 );
		
		if oc.commands[ text_cmd ] then
			oc.print("RUNNING COMMAND: "..text_cmd.." ARG STR: "..text_arg );
			oc.RunChatCommand( pl, text_cmd, text_arg );
		else
			oc.print("COMMAND NOT FOUND! ", text_cmd );
		end
		
	end
end);


function oc.RunChatCommand( pl, text_cmd, text_arg )
	local meta = oc.commands[ text_cmd ];
	local perm = meta:getPerm( );
	
	if not oc.checkPerm( pl, perm ) then
		oc.notify( pl, Color(255,0,0), 'You do not have permission \''..perm..'\'.' );
		return ;
	end
	
	oc.notify( pl, 'You ran command '..text_cmd );
	
	local args = oc.ParseString( text_arg );
	oc.RunCommand( pl, meta, args );
end





/* ======================================================================
	 	COMMAND EXECUTION
	 ====================================================================== */

function oc.RunCommand( pl, meta, args )
	-- process arguments.
	local params = meta.params;
	
	local succ = oc.hook.Call( 'ProcessCMDArgs', pl, params, args );
	if succ == false then return end
	
	if #params > #args then
		oc.notify(pl, oc.cfg.color_error, 'PARSE ERROR: too few arguements. Got ' .. #args .. ' expected ' .. #params );
		return ;
	end
	local processed = {};
	for i = 1, #args do
		local arg = args[i];
		local param = params[i];
		local pmeta = oc.getParamType( param.type );
		PrintTable( pmeta );
		if not pmeta then
			oc.notify( pl, oc.cfg.color_error,'CONTACT A CODER! PARAM TYPE: '..param.type..' does not exist! This should never happen.' );
			return ;
		end
		
		local succ, narg = pmeta.parse( arg, param );
		
		if not succ then
			oc.notify( pl, oc.cfg.color_error, 'PARSE ERROR: Failed to parse arg ('..i..') '..narg..'. ', narg );
			return ;
		end
		
		processed[ param.pid ] = narg;
	end
	
	local succ, err = pcall( meta.action, pl, processed );
	if not succ then
		oc.notify( pl, oc.cfg.color_error, 'ERROR ON COMMAND: ', err );
		return ;
	end
end

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
				oc.notify( pl, Color(255,155,0), 'ERROR: too many arguements. Expected '..#cmdParams..' got '..#args..' params.' );
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
	local s = 0;
	for v, t in string.gmatch( arg, '(%d+)(%a+)' ) do
		if mults[t] then s = s + v * mults[t] end
	end
	return true, s;
end
oc.addParamType( 'time', TYPE );
oc.fancy_formats['T'] = function( number )
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

TYPE.parse = oc.fn_Compose( 
-- STEP 1: find all players we can.
function( arg, param )
	return findPlayersByName( arg ), param ;
end,

-- STEP 2: validate
oc.fn_IF( function( _, param ) return param.multi or false end ,
-- VALIDATE: multi
function( targ, param )
	if #targ == 0 then
		return false, 'No targets found';
	else
		return true, targ;
	end
end,
-- VALIDATE: single
function( targ, param )
	if #targ == 0 then
		return false, 'No targets found';
	elseif #targ > 1 then
		return false, 'Too many targets';
	else
		return true, targ[1];
	end
end));

oc.addParamType( 'player', TYPE );
oc.fancy_formats['P'] = function( players )
	
	if type( players ) ~= 'table' then
		players = { players };
	end
	PrintTable( players );
	
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