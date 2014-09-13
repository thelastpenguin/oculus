if SERVER then
	util.AddNetworkString('sg.request');
	util.AddNetworkString('sg.upload');
	util.AddNetworkString('sg.pushToAdmin');
end

local function receiveStream(callback)
	local streams = {};
	return function()
		local txnid = net.ReadUInt(32);
		if streams[txnid] then
			local b = streams[txnid];
			local size = net.ReadUInt(16);
			local data = net.ReadData(size);
			b[#b+1] = data;

			if #b == b.len then
				b.len = nil;
				streams[txnid] = nil;
				callback(txnid, table.concat(b);
			end
		else
			streams[txnid] = {};
			streams[txnid].len = net.ReadUInt(32);
		end
	end
end

local function writeStream(msgid, txnid, targs)
	local send;
	if CLIENT then
		send = function() net.Send(targs) end
	else
		send = net.SendToServer ;
	end

	net.Start(msgid);
		net.WriteUInt(txnid, 16);
		net.WriteUInt(math.ceil(string.len(data)/blocksize), 32);
	send();
	-- send chunk segments
	for i = 1, math.ceil(string.len(data)/blocksize) do
		local window = i * blocksize; -- dem closures tho
		timer.Simple(i * 0.1, function()
			local block = data:sub(window-blocksize-1, window);
			print('streamed data: '..window);
			net.Start(msgid)
				net.WriteUInt(txnid, 16);
				net.WriteUInt(size, 16);
				net.WriteData(block, size);
			send();
		end);
	end
end



if CLIENT then
	local render = render // localize 2 stop hsvkersss
	local blocksize = 1024;

	net.Receive("sg.request", function()
		local txnid = net.ReadUInt(16); -- unique identifier for this screengrab txn.

		-- capture
		local data = render.Capture({
			format = "jpeg",
			h = ScrH(),
			w = ScrW(),
			quality = 20,
			x = 0,
			y = 0
		});


		-- init stream
		print('streaming txnid: '..txnid..' blocks: '..math.ceil(string.len(data)/blocksize));
		net.Start('sg.upload');
			net.WriteUInt(txnid, 16);
			net.WriteUInt(math.ceil(string.len(data)/blocksize), 32);
		net.SendToServer();

		-- send chunk segments
		for i = 1, math.ceil(string.len(data)/blocksize) do
			local window = i * blocksize; -- dem closures tho
			timer.Simple(i * 0.1, function()
				local block = data:sub(window-blocksize-1, window);
				print('streamed data: '..window);
				net.Start('sg.upload')
					net.WriteUInt(txnid, 16);
					net.WriteUInt(size, 16);
					net.WriteData(block, size);
				net.Start('sg.upload');
			end);
		end
	end)

	net.Receive("SG.SendToAdmin", function()
		local data = net.ReadString()
		local sid = net.ReadString()

		local w, h = ScrW() *.95, ScrH() *.95
		local fr = vgui.Create('DFrame');
		fr:SetTitle("Screengrab: " ..  sid)
		fr:SetSize(w, h)
		fr:MakePopup()
		fr:Center()
		
		local image = vgui.Create("DHTML", fr)
		image:SetPos(10, 25)
		image:SetSize(w - 10, h - 30)
		image:SetHTML([[<img src="data:image/jpeg;base64, ]] .. data .. [[alt="ERROR" height="]] .. h - 50 .. [[" width="]] .. w - 40 .. [["/>]]) // Make it smaller so it doesnt have fugly scrollbars
	end)
end

local cmd = oc.command('utility', 'sg', function(pl, args)
	if SERVER then
		ScreenGrabPlayer(pl, args.player)
	end
	oc.notify_fancy(pl, 'Screengrab started on #P, please allow up to 20 seconds for this to finish.', args.player)
end)
cmd:addParam 'player' { type = 'player' }
