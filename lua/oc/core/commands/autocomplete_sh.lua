oc.autocomplete = {};

function oc.autocomplete.commands( partial, pl )
	partial = partial:lower();
	
	local res = {};
	for k,v in pairs(oc.commands)do
		if v.command:find(partial) and v:playerCanUse(pl) then
			res[#res+1] = 'oc '..v.command;
		end
	end
	
	if #res == 0 then
		return {'<no commands>'};
	else
		return res;
	end
end


local function quotify(str)
	return str:find('[^%w]') and '"'..str..'"' or str;
end

function oc.autocomplete.args( cmd_text, args, pl )
	local cmd = oc.commands[cmd_text];
	if not cmd then return {'<invalid command>'} end
	
	local params = cmd.params;
	
	local arg = args[#args];
	local param = params[#args];
	
	local opts;
	if param then
		opts = oc.parser.autocomplete(param, arg, pl);
		if opts then
			xfn.filter(opts, function(opt)
				return opt:find(arg);
			end);
		else
			opts = {};
		end
		if param.optional then
			opts[#opts+1] = '<[OPTIONAL] '..param.type..':'..param.pid..'>';
		else
			opts[#opts+1] = '<'..param.type..':'..param.pid..'>';
		end
	else
		opts = {'<too many params>'}
	end
	
	local prefix = 'oc '..cmd_text..' ';
	for i = 1, #args - 1 do
		local carg = args[i];
		if istable(carg) then
			prefix = prefix .. table.concat(xfn.map(carg, quotify))..' ';
		else
			prefix = prefix .. quotify(carg) .. ' ';
		end
	end
	
	local postFix = #args <= #params and ' ' or '';
	return xfn.map(opts, function(opt)
		return prefix..quotify(opt)..postFix;
	end);
end

function oc.autocomplete.general( text, pl )
	local args = {oc.parseLine(text)};
	if #args <= 1 then
		return oc.autocomplete.commands( args[1] or '', pl);
	else
		local cmd = table.remove(args, 1);
		return oc.autocomplete.args( cmd, args, pl );
	end
end


-- backwards compatability
oc.autocomplete.perms = oc.permissions;
oc.autocomplete.commandPerms = {};
