function oc.AutocompleteCommand( pl, text_arg )
	
	-- properly descide which arguement we are currently intrested in
	local rawArgs = oc.ParseString(text_arg);
	
	local argIndex = #rawArgs
	local arg
	if text_arg[text_arg:len()] == ' ' then
		argIndex = argIndex + 1;
		arg = nil;
	else
		arg = table.remove(rawArgs, #rawArgs);
	end
	
	local res = {};
	
	if argIndex == 0 or argIndex == 1 then
		if arg then arg = arg:lower() end
		local oc_player = oc.p(pl);
		for cmdName,cmdMeta in pairs(oc.commands)do
			-- if arg is nil everything passes
			if (not arg or cmdName:find(arg)) and oc_player:getPerm(cmdMeta.perm) then
				table.insert(res, cmdName);
			end
		end
	else
		-- arguement autocompletion
		local command = oc.commands[rawArgs[1] and rawArgs[1]:lower()];
		if not command then
			return {'<command not found>'};
		else
			local paramMeta = command:getParam(argIndex-1);
			if not paramMeta then return {'<too many params>'} end
			
			local options;
			if paramMeta.options then
				options = paramMeta.options
			else
				local typeMeta = oc.getParamType(paramMeta.type);
				if typeMeta and typeMeta.autocomplete then
					options = typeMeta.autocomplete
				end
			end
			
			if options then
				-- resolve options to an array
				if isfunction(options) then
					res = options() or {}
				else
					res = table.Copy(options);
				end
				
				-- filter options
				if arg then
					xfn.filter(res, function(opt)
						return opt:find(arg)
					end);
				end
			end
			
			-- if there is no arg then show help
			if not arg and paramMeta.help then
				table.insert(res, 'tip: ' .. paramMeta.help);
			end
			
			if #res == 0 then
				if arg then table.insert(res, arg) end
				table.insert(res, '<'..(paramMeta.help or 'no suggestions')..'>');
			end
			
		end
	end
	
	do
		local prefix = {'oc'};
		for k,v in pairs(rawArgs)do
			if v:find(' ') then
				table.insert(prefix, '"'..v..'"')
			else
				table.insert(prefix, v);
			end
		end
		prefix = table.concat(prefix, ' ')..' ';
		
		xfn.map(res, function(res)
			if res:find(' ') then 
				return prefix..'"'..res..'"';
			else
				return prefix..res;
			end
		end);
	end
	
	return res;
end


oc.autocomplete = {};
oc.autocomplete.commandPerms = {};

oc.hook.Add('loaded', function()
	dprint('calculating autocomplete options');
	
	-- autocomplete options for command permissions
	local commandPerms = oc.autocomplete.commandPerms;
	table.Empty(commandPerms);
	for k,meta in pairs(oc.commands)do
		if meta.perm then
			commandPerms[#commandPerms+1] = meta.perm;
			if meta:getExtraPerms() then
				for k,v in pairs(meta:getExtraPerms())do
					commandPerms[#commandPerms+1] = v;
				end
			end
		end
	end
	dprint('calculated '..#commandPerms..' options for command permisisons');
	
end);