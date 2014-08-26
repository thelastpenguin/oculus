local string, table, net = string, table, net ;

oc.perm = {};
setmetatable(oc.perm, oc.perm);

local perm_mt = {};
perm_mt.__index = perm_mt;

function perm_mt:addPermTable(perms)
		
	for _, perm in pairs(perms)do
		self:addPerm(perm);
	end
	
	return self;
end

function perm_mt:addPerm(perm)
	local struct = self._struct;
	
	local lastBody = '*';
	local lastDot = 0;
	
	local going = true;
	while(going)do
		
		local dot = string.find(perm, '.', lastDot + 1, true);
		if not dot then
			going = false;
			dot = string.len(perm)+1;
		end
		
		local body = string.sub(perm, 1, dot-1);
		
		if not struct[body] then 
			local val = perm:sub(lastDot+1, dot-1);
			table.insert(self._struct[lastBody], val)
			struct[body] = {}; 
		end
		
		lastBody = body;
		lastDot = dot;

	end
	
	return self;
end


function perm_mt:getPerm(perm)
	return self._struct[perm];
end
function perm_mt:netWrite()
	local root = self:getPerm('*');
	
	if not root or #root == 0 then
		net.WriteUInt(0, 16);
		return;
	end
	
	local function writeChildren(perm)
		local cldrn = self:getPerm(perm);
		net.WriteUInt(#cldrn, 16);
		for k, v in pairs(cldrn)do
			net.WriteString(v);
			writeChildren(perm..'.'..v);
		end
	end
	
	net.WriteUInt(#root, 16);
	for k,v in pairs(root)do
		net.WriteString(v);
		writeChildren(v);
	end
	
end
function perm_mt:netRead()
	
	local struct = {};
	self._struct = struct;
	
	local function readChildren(perm)
		local cldrn = net.ReadUInt(16);
		if cldrn > 0 then
			local permd = perm..'.'
			local cur;
			for i = 1, cldrn do
				cur = net.ReadString();
				table.insert(struct[perm], cur);
				struct[permd..cur] = {};
				readChildren(permd..cur);
			end
		end
	end
	
	local rootCount = net.ReadUInt(16);
	struct['*'] = {};
	for i = 1, rootCount do
		local perm = net.ReadString();
		table.insert(struct['*'], perm);
		struct[perm] = {};
		readChildren(perm);
	end
	
	return self;
	
end



oc.perm.__call = function( self )
	return setmetatable({_struct = {['*'] = {}}}, perm_mt);
end

oc.permissions = {};
oc.perm.all = oc.perm();
function oc.perm.register(perm)
	table.insert(oc.permissions, perm);
	oc.perm.all:addPerm(perm);
end