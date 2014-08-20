require 'glsock2'

local port = 5555
local password = 2492329323

oc.sock = {};

function oc.sock.init()
	
	local function onReceive(sock, client, err)
		
		if err == GLSOCK_ERROR_SUCCESS then
			local res = GLSockBuffer();
			
			-- write the rest of the message
			local ip = client:RemoteAddress();
			dprint('successfully received message');
			dprint('  from ip addr: '..ip);
			
			client:Read(1024, function(_, buff, err)
				if err == GLSOCK_ERROR_SUCCESS then
					dprint('successfully read shit');
					local _, resp = buff:Read(buff:Size());
					dprint(resp);
				else
					dprint('god damnit there was a read error wtf');
				end
					
				res:WriteString('this is like a response');
				client:Send(res, function()
					client:Close();	
				end);
			end);
		else
			dprint('ERROR ON RECEIVE MESSAGE');
		end
		
		if (err ~= GLSOCK_ERROR_OPERATIONABORTED) then
			sock:Accept(onReceive);
		end
	end
	
	local function onListen(sock, err)
		if err == GLSOCK_ERROR_SUCCESS then
			sock:Accept(onReceive)
			dprint('Listening on port '..port);
		else
			dprint('Failed to listen on port '..port);
		end
	end
	
	
	dprint('initializing oculus socket listener');
	oc.sock.socket = GLSock(GLSOCK_TYPE_ACCEPTOR);
	oc.sock.socket:Bind('', port, function(sock, err)
		if err == GLSOCK_ERROR_SUCCESS then
			sock:Listen(0, onListen);
		else
			dprint('ERROR SOCKET BINDING FAILED');
		end
	end);
end

function oc.sock.sendMessage(host, ip, msgId, text, callback)
	local buff = GLSockBuffer();
	dprint('sock sending to '..host..':'..ip..' - '..text);
	
	buff:WriteLong(password) -- write the password
	buff:WriteString(msgId); -- message id
	buff:WriteString(text); -- message body
	
	local sock = GLSock(GLSOCK_TYPE_TCP);
	sock:Connect(host, ip, function(sock, err)
		
		if err == GLSOCK_ERROR_SUCCESS then
			
			-- send request to the server
			sock:Send(buff, function(sock, _, err)
				
				if err ~= GLSOCK_ERROR_SUCCESS then
					dprint('SOCKET SEND ERROR');
					if callback then callback(err) end
				else
					sock:Read(1024, function(_, buff, err)
						if not buff then
							dprint('BUFFER IS NIL');
						else
							local _, resp = buff:Read(buff:Size());
							dprint('response: '..resp);
							if callback then callback(nil, resp) end
						end
					end);
				end
				
				sock:Close();
			end);
		else
			dprint('encountered connection error');
		end
		
	end);
	
end

oc.sock.init();