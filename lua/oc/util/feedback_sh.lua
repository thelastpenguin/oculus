local net , type = _G.net, _G.type ;
local oc = _G.oc;

if SERVER then
	
	util.AddNetworkString( 'oc_notify' );
	util.AddNetworkString( 'oc_notify_ex' );
	local function writemessage( arg )
		for _, v in ipairs( arg )do
			local t = type( v );
			if t == 'table' and v.r then
				net.WriteUInt( 2, 4 );
				net.WriteUInt( oc.bit.encodeColor( v ), 32 );
			elseif t == 'Player' then
				net.WriteUInt( 3, 4 );
				net.WriteEntity( v );
			elseif t == 'string' then
				net.WriteUInt( 1, 4 );
				net.WriteString( v );
			end
		end
		net.WriteUInt( 0, 4 );
	end
	
	function oc.notify_r( pl, ... )
		local arg = {...};
		net.Start( 'oc_notify' );
			writemessage( arg );
		net.Send( pl );
		
		-- properly output to console
		if type(pl) == 'Player' and not IsValid(pl) then
			for k,v in pairs(arg)do
				if type(v) == 'string' then
					Msg(v);
				elseif type(v) == 'Player' then
					Msg(v:Name());
				end
			end
			Msg('\n');
		end
		
	end
	function oc.notify( pl, ... )
		local arg = {...}
		net.Start( 'oc_notify_ex' );
			writemessage( arg );
		net.Send( pl );
	end
	
	oc.notify_all = function(...) oc.notify( player.GetAll(), ... ) end
	
	
	local fancy_formats = {};
	oc.fancy_formats = fancy_formats;
	
	function oc.notify_fancy( pl, format, ... )
		local param = {...};
		local paramc = 0;
		local function next_param()
			paramc = paramc + 1;
			return param[paramc];
		end
		
		local output_special, output_normal ;
		function output_normal( ind )
			local stop = string.find( format, '#', ind );
			if stop then
				return Color(255,255,255), string.sub( format, ind, stop - 1 ), output_special( stop + 1 );
			else
				return Color(255,255,255), string.sub( format, ind );
			end
		end
		
		local function arg_merge( a, ... )
			if type( a ) == 'function' then
				return arg_merge( a() ), arg_merge( ... );
			else
				return a, arg_merge( ... );
			end
		end
		
		local function pushAll( func, a, ... )
			if a then
				return a, pushAll( func, ... );
			else
				return func();
			end
		end
		
		function output_special( ind )
			local code = string.sub( format, ind, ind );
			local arg = next_param();
			
			if not code then return end
			local formatter = fancy_formats[code];
			if formatter then
				--local test = { formatter( arg ) , output_normal( ind + 1 ) };
				return pushAll( function() 
					return output_normal( ind + 1 )
				end, formatter( arg ) );
			else
				return Color(255,0,0), 'ERROR UNEXPECTED \''..code..'\'', output_normal( ind + 1 );
			end
		end
		oc.notify( pl, output_normal( 1 ) );
	end
	
elseif CLIENT then
	local fancy_formats = {};
	oc.fancy_formats = fancy_formats;
	
	local function readmessage( )
		local type = net.ReadUInt( 4 )
		local value ;
		if type == 1 then
			value = net.ReadString( );
		elseif type == 2 then
			value = oc.bit.decodeColor( net.ReadUInt( 32 ) );
		elseif type == 3 then
			value = net.ReadEntity( );
		elseif type == 0 then
			return
		end
		return value, readmessage( );
	end
	
	net.Receive( 'oc_notify', function() 
		chat.AddText( readmessage() );
	end);
	
	local mc, mcd, white = oc.cfg.mod_color, oc.cfg.mod_color_d, Color(255,255,255); 
	net.Receive( 'oc_notify_ex', function()
		chat.AddText( mcd,'[',mc,'OC',mcd, ']  ', white, readmessage( ) );	
	end);
	
end