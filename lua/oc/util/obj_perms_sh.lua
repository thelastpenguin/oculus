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

/*

local string_find = string.find ;
local string_sub = string.sub ;


local function nodeAddPerm( root, node, perm )
	local dot = string_find(perm,'.', 1, true);
	if dot then
		local key = string_sub(perm, 1, dot-1);
		local rest = string_sub(perm, dot+1 );
		if not node[key] then
			node[key] = {root=root};
			node[#node+1] = key;
		end
		nodeAddPerm(root, node[key], rest);
	else
		if not node[perm] then
			node[perm] = {};
			node[#node+1] = perm;
		end
	end
end

local function nodeGetPerm( node, perm )
	local dot = string_find(perm, '.', 1, true);
	if dot then
		local key = string_sub(perm, 1, dot-1);
		local rest = string_sub(perm, dot+1 );
		if node[key] then
			return nodeGetPerm(node[key], rest);
		else
			return false;
		end
	else
		return node[perm] or false;
	end
end

local function nodeDelPerm( node, perm )
	local dot = string_find(perm,'.', 1, true);
	if dot then
		local key = string_sub(perm, 1, dot-1);
		local rest = string_sub(perm, dot+1 );
		if not node[key] then
			return ;
		end
		nodeDelPerm(node[key], rest);
	else
		if node[perm] then
			node[perm] = nil;
		end
		for k,v in ipairs(node)do
			if v == perm then
				table.remove(node, k);
				break;
			end
		end
	end
end

local tree_mt = {};
tree_mt.__index = tree_mt;
function tree_mt:getPerm( perm )
	local vals = nodeGetPerm(self.root,perm);
	self.cache[perm] = vals;
	return vals or false;
end

function oc.perm( perms )
	local node = {};
	for _, perm in pairs(perms)do
		nodeAddPerm(self, node,perm);
	end
	return setmetatable({
		root = node,
		cache = {}
	}, tree_mt);
end

function oc.permAdopt(tree)
	return setmetatable({
		root = tree,
		cache = {}
	}, tree_mt);
end

*/