function oc.fn_Parallel( ... )
	local funcs = {...}
	return function( ... )
		local a, b, c, d ;
		for i = 1, #funcs do
			a, b, c, d = funcs[i]( ... )
			if a then return a, b, c, d end
		end
	end
end

function oc.fn_Compose( ... )
	local funcs = {...};
	return function( ... )
		local res = {...}
		for i = 1, #funcs do
			res = {funcs[i](unpack(res))};
		end
		return unpack( res );
	end	
end

function oc.fn_ForEach( func_todo )
	return function( tbl )
		for k,v in pairs( tbl )do
			func_todo( v, k );
		end
	end
end
function oc.ForEach( table, func_todo )
	for k,v in pairs( table )do
		func_todo( v, k );
	end
end



function oc.fn_IF( cond, func_true, func_false )
	if type( cond ) == 'function' then
		return function( ... )
			if cond(...) then return func_true(...) elseif func_false then return func_false(...) end
		end
	else
		if cond then
			return func_true;
		else
			return func_false or function() end
		end
	end	
end

function oc.fn_Const( val )
	return function() return val end
end


function oc.fn_ReverseArgs(...)
   --reverse args by building a function to do it, similar to the unpack() example
   local function reverse_h(acc, v, ...)
	  if select('#', ...) == 0 then
		 return v, acc()
	  else
		 return reverse_h(function () return v, acc() end, ...)
	  end
   end

   -- initial acc is the end of	the list
   return reverse_h(function () return end, ...)
end

function oc.fn_Curry(func, num_args)
	if not num_args then error("Missing argument #2: num_args") end
	if not func then error("Function does not exist!", 2) end
	-- helper
	local function curry_h(argtrace, n)
		if n == 0 then
			-- reverse argument list and call function
			return func(oc.fn_ReverseArgs(argtrace()))
		else
			-- "push" argument (by building a wrapper function) and decrement n
			return function(x)
				return curry_h(function() return x, argtrace() end, n - 1)
			end
		end
   end

   -- no sense currying for 1 arg or less
   if num_args > 1 then
	  return curry_h(function() return end, num_args)
   else
	  return func
   end
end

function oc.fn_MapArgs( func, ... )
	local argmap = {...}
	return function( ... )
		local arg = { ... }
		if #arg > #argmap then error("TOO MANY ARGUMENTS TO REMAP. GOT: "..#arg.." MAX "..#argmap ) end
		local function map( count )
			if count < #arg then
				return arg[ argmap[ count ] ], map( count + 1 )
			else
				return arg[ argmap[ count ] ];
			end
		end
		func( map( 1 ) );
	end
end

function oc.fn_Getter( key )
	return function( table )
		return table[ key ];
	end
end

function oc.fn_ReadOnly( table )
	return function( key )
		return table[ key ];
	end
end