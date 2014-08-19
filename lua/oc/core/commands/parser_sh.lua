local oc = oc;
local string , table , math , pairs , ipairs = string , table , math , pairs , ipairs ;
local isfunction , istable , type = isfunction , istable , type ;


oc.parser = {};

local compiler_mt = {};
compiler_mt.__index = compiler_mt;
local paramtype_mt = {};
paramtype_mt.__index = paramtype_mt;


local param_types = {};

function oc.parser.newParamType( type )
	dprint('created new param type: '..type);
	param_types[type] = setmetatable({
		type = type,
		steps = {},
	}, paramtype_mt);
	return param_types[type];
end

function paramtype_mt:process(arg, opts, compiler)
	local orig = arg;
	local succ, res;
	for k,v in pairs(self.steps)do
		succ, res = v(arg, opts, compiler, orig);
		if succ == false then
			return false, res;
		elseif res ~= nil then
			arg = res;
		end
	end
	return true, arg;
end

function paramtype_mt:getAutoComplete(opts, pl)
	if opts.options then
		if isfunction(opts.options)then
			return opts.options(pl);
		else
			return table.Copy(opts.options);
		end
	elseif self.autocompleter then
		return self.autocompleter(opts, pl);
	end
end

function paramtype_mt:addStep(func)
	dprint(' added new step to '..self.type);
	table.insert(self.steps, func);
end

function paramtype_mt:addFancyFormat(tag, func)
	oc.fancy_formats[tag] = func;
end

function paramtype_mt:setAutoComplete(func)
	self.autocompleter = func;
end

--
-- AUTOCOMPLETE THE GIVEN ARG
--
function oc.parser.autocomplete(opts, arg, pl)
	local typeMeta = param_types[opts.type];
	if not typeMeta then
		return {'<invalid type '..opts.type..'>'};
	else
		return typeMeta:getAutoComplete(opts, pl);
	end
end


--
-- PARSE THE GIVEN STRING
--
function oc.parser.compile(params, args, pl)
	//dprint('compiler running with params: '..#params..' and args: '..#args);
	local compiler = setmetatable({}, compiler_mt);
	compiler:process(params, args, pl);
	
	return compiler;
end

function compiler_mt:process(params, args, pl)
	self.player = pl;
	self.params = params;
	self.args = args;
	
	self.result = {};
	
	//dprint('processing params');
	for ind, param in ipairs(params)do
		//dprint(ind..') param: '..param.type);
		
		local arg = self:popArg();
		
		-- it's not there!!! the world is ending!!!
		if not arg then
			if param.default then
				arg = param.default;
			elseif param.optional then
				continue ;
			else
				self:throwError(string.format('Arg expected for param %d (%s) got nil.', ind, param.pid ));
				return ;
			end
		end
		
		local meta = param_types[param.type];
		if not meta then
			error('command type '..param.type..' does not exist');
		end
		
		local succ, res = meta:process( arg, param, self );
		if succ then
			self.result[param.pid] = res;
		else
			self:throwError(res or 'no error');
		end
	end
	
	-- we frown upon errors
	if self.error then
		return ;
	end
end

function compiler_mt:throwError(msg)
	if not self.error_count then
		oc.notify(self.player, oc.cfg.color_error, 'PARSER ERROR(S):');
		self.error_count = 0;
	end
	self.error_count = self.error_count + 1;
	
	oc.notify(self.player, oc.cfg.color_error, self.error_count..') '..msg);
	self.error = msg;
end


function compiler_mt:popArg()
	return table.remove(self.args, 1);
end






--
-- REGISTER ARGUMENT TYPES
--


local function stringIsSteamID(str)
	return str:match('STEAM_[%d]:[%d]:[%d]+') == str;
end

--
-- TYPE STRING
--
local type_string = oc.parser.newParamType('string');
type_string:addStep(function(arg, opts, compiler)
	if type(arg) ~= 'string' then
		return false, 'string expected got '..type(arg);
	else
		return true;
	end
end);

type_string:addStep(function(arg, opts, compiler)
	if opts.fill_line then
		while(true)do
			local nxt = compiler:popArg();
			if not nxt then break end
			arg = arg .. ' ' .. nxt;
		end
		return true, arg;
	end
end);

type_string:addFancyFormat('S', function(arg)
	return oc.cfg.color_string, arg;
end);


--
-- ARGUMENT TYPE - PLAYER
-- 
local type_player = oc.parser.newParamType('player');
type_player:addStep(function(arg, opts, compiler)
	if type(arg) == 'table' then
		xfn.map(arg, string.lower);
		
		return true, xfn.filter(player.GetAll(), function(pl)
			local plName = pl:Name():lower();
			for k,v in pairs(arg)do
				if plName:find(v, 1, true) then
					return true;
				end
			end
			return false;
		end);
	else
		if stringIsSteamID(arg) then
			for k,v in pairs(player.GetAll())do
				if v:SteamID() == arg then
					return true, {v};
				end
			end
		end
		arg = arg:lower();
		return true, xfn.filter(player.GetAll(), function(pl)
			return pl:Name():lower():find(arg, 1, true);	
		end);
	end
end);

type_player:addStep(function(arg, opts, compiler)
	if #arg == 0 then
		return false, 'No targets found';
	end
	
	if opts.multi then
		return true, arg
	else
		if #arg == 1 then
			return true, arg[1];
		else
			return false, 'Too many targets. Please be more specific';
		end
	end
end);

type_player:addFancyFormat('P', function(arg)
	local function output_player(res, pl)
		res[#res+1] = team.GetColor(pl:Team());
		res[#res+1] = pl:Name();
	end
	local start = os.clock();
	if istable(arg) then
		if #arg == #player.GetAll() then
			return oc.cfg.color_everyone, 'everyone';
		else
			local res = {};
			
			local len = #arg;
			if len == 1 then
				output_player(res, arg[1]);
			else
				for i = 1, len - 1 do
					output_player(res, arg[i]);
					res[#res+1] = color_white;
					res[#res+1] = ', ';
				end
				res[#res+1] = 'and ';
				output_player(res, arg[len]);
			end
			return unpack(res);
		end
	else
		if not IsValid(arg) then
			return Color(0,0,0), '(Console)';
		else
			return team.GetColor(arg:Team()), arg:Name();
		end
	end
end);

type_player:setAutoComplete(function(param, pl)
	return xfn.map(player.GetAll(), function(pl)
		return pl:Name()
	end);
end);



--
-- ARGUMENT TYPE - NUMBER
-- 
local type_number = oc.parser.newParamType('number');
type_number:addStep(function(arg, opts, compiler)
	local num = tonumber(arg);
	if num then
		return true, num;
	else
		return false, 'Number expected got '..tostring(arg);
	end
end);

type_number:addFancyFormat('N', function(arg)
	return oc.cfg.color_number, tostring(arg);
end);

--
-- ARGUMENT TYPE - TIME
--
local type_time = oc.parser.newParamType('time');
local time_mults = {
	['m'] = 60,
	['h'] = 3600,
	['d'] = 86400,
	['w'] = 604800,
	['y'] = 31536000
};
local time_divs = {'y','w','d','h','m'}
type_time:addStep(function(arg, opts, compiler)
	arg = arg:lower();
	
	if arg == 'forever' then
		return true, 0;
	end
	
	local s = 0;
	for v, t in string.gmatch( arg, '(%d+)(%a+)' ) do
		if time_mults[t] then
			s = s + v * time_mults[t]
		else
			return false, 'Invalid time code \''..t..'\'';
		end
	end
	
	if s == 0 then
		return false, 'nonzero time expected. use time codes m, h, d, w (minute, hour, day, week) or forever.'
	end
	return true, s;
end);

type_time:addFancyFormat('T', function(arg)
	local output = {};
	
	for _, timediv in ipairs(time_divs) do
		local mult = time_mults[timediv];
		local temp = math.floor(arg/mult);
		if temp > 0 then
			output[#output+1] = temp..timediv;
			arg = arg - temp * mult;
		end
	end
	
	return oc.cfg.color_time, table.concat(output, ' ');
end);
type_time:setAutoComplete(function()
	return {'<w:week d:day h:hour m:minute>'};
end);

--
-- STEAMID ARGUMENT TYPE
--
do
	local type_steamid = oc.parser.newParamType('steamid')
	local function findPlayer(name)
		local res;
		for k,v in pairs(player.GetAll())do
			if v:Name():lower():find(name, 1, true) then
				if res then
					return nil;
				else
					res = v;
				end
			end
		end
		return res;
	end

	type_steamid:addStep(function(arg, opts, compiler)
		if istable(arg) then
			if not opts.multi then
				return false, 'cmd does not have opts.multi flag, can not multi target';
			end
			
			local res = {};
			for _,arg in pairs(arg)do
				if stringIsSteamID(arg) then
					table.insert(res, arg);
				else
					local pl = findPlayer(arg:lower());
					if pl then 
						table.insert(res, pl:SteamID())
					else
						return false, 'Failed to match '..arg..' to a single player (if any)';
					end
				end
			end
			if #res == 0 then
				return false, 'Failed to identify any steamid(s)';
			end
			return true, xfn.unique(res);
		else
			if stringIsSteamID(arg) then
				return arg;
			else
				local pl = findPlayer(arg:lower());
				if pl then
					return true, pl:SteamID();
				else
					return false, 'Failed to match '..arg..' to a single player (if any)';
				end
			end
		end
	end);

	type_steamid:addStep(function(arg, opts, compiler)
		if opts.multi then
			return true, istable(arg) and arg or {arg};
		else
			return true, arg;
		end
	end);

	local mt_SteamID = FindMetaTable('Player').SteamID;
	type_steamid:setAutoComplete(function(opts)
		return xfn.map(player.GetAll(), mt_SteamID);
	end);
end


local type_group = oc.parser.newParamType('group');

type_group:addStep(function(arg)
	local id = tonumber(arg);
	if id and oc.g(id) then
		return true, oc.g(id);
	else
		for k,v in pairs(oc.groups)do
			if v.name == arg then return true, v end
		end
		return false, 'group '..arg..' doesnt exist';
	end
end);

type_group:setAutoComplete(function(opts)
	local res = {};
	for k,v in pairs(oc.groups)do
		res[#res+1] = v.name;
	end
	return res
end);

type_group:addFancyFormat('G', function(arg)
	return arg.color, arg.name;
end);


