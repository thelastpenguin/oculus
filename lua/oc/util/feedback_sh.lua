local net , type = _G.net, _G.type ;
local oc = _G.oc;

oc.fancy_formats = {};

function oc.consoleAddText(...)
	local arg = {...};
	local col = color_white;
	for k,v in pairs(arg) do
		local t = type(v);
		if t == 'table' and v.r then
			col = v;
		elseif t == 'Player' then
			MsgC( team.GetColor(v:Team()), v:Name());
		elseif t == 'string' then
			MsgC( col, tostring(v));
		end
	end
	MsgN();
end

if SERVER then
	local fancy_formats = oc.fancy_formats;
	
	local function shouldConsoleSee( tbl )
		local t = type(tbl);
		if t == 'table' then
			return #tbl == #player.GetAll();
		elseif t == 'Entity' then
			return not IsValid(tbl);
		end
		return false;
	end
	
	
	util.AddNetworkString( 'oc_notify_con' );
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
	
	function oc.notify( pl, ... )
		local arg = {...}
		net.Start( 'oc_notify_ex' );
			writemessage( arg );
		net.Send( pl );
		
		if shouldConsoleSee(pl) then
			oc.consoleAddText(...);
		end
	end
	
	function oc.notify_con( pl, ... )
		local arg = {...};
		net.Start('oc_notify_con');
			writemessage( arg );
		net.Send(pl);
	end
	
	oc.notify_all = function(...) oc.notify( player.GetAll(), ... ) end


	function oc.notify_fancy( pl, format, ... )
		local param = {...};
		local paramc = 0;
		local function next_param()
			paramc = paramc + 1;
			return param[paramc];
		end
		
		local message = {};

		-- helpers
		local function output_format(formatter, arg)
			local res = {formatter(arg)};
			for i = 1, #res do
				message[#message+1] = res[i];
			end
		end
		
		-- output modes
		local output_special, output_normal, output_array ;
		function output_normal( ind )
			local stop = string.find( format, '#', ind );
			message[#message+1] = color_white;
			if stop then
				message[#message+1] = string.sub( format, ind, stop - 1 )
				output_special(stop + 1);
			else
				message[#message+1] = string.sub( format, ind );
			end
		end
		
		function output_array( ind )
			local arg = next_param();

			local code = string.sub( format, ind, ind );
			if not code then return end
			
			local formatter = fancy_formats[code];
			if not formatter then
				message[#message+1] = oc.cfg.color_error;
				message[#message+1] = 'ERROR UNEXPECTED \''..code..'\'';
				return;
			end
			
			local len = #arg;
			if len == 1 then
				output_format(formatter, arg);
			else
				for i = 1, len-1 do
					print(arg[i]);
					output_format(formatter, arg[i]);
					message[#message+1] = color_white;
					message[#message+1] = ', ';
				end
				message[#message+1] = color_white;
				message[#message+1] = 'and ';
				output_format(formatter, arg[len]);
			end
			
			output_normal(ind+1);
		end
		
		function output_special( ind )
			local code = string.sub( format, ind, ind );
			
			if not code then return end
			if code == '#' then 
				output_array( ind+1 )
				return ;
			end
			
			local arg = next_param();
			
			local formatter = fancy_formats[code];
			if formatter then
				local res = {formatter(arg)};
				for i = 1, #res do
					message[#message+1] = res[i];
				end
				output_normal(ind+1);
			else
				message[#message+1] = oc.cfg.color_error;
				message[#message+1] = 'ERROR UNEXPECTED \''..code..'\'';
				output_normal(ind + 1);
			end
		end
		output_normal(1);
		
		oc.notify(pl, unpack(message) );
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
	
	local mc, mcd, white = oc.cfg.mod_color, oc.cfg.mod_color_d, Color(255,255,255); 
	net.Receive( 'oc_notify_con', function()
		oc.consoleAddText(mcd, '| ', white, readmessage());
	end);
	
	net.Receive( 'oc_notify_ex', function()
		chat.AddText(mcd, '| ', white, readmessage( ));	
	end);
	
end