local string_find = string.find ;
local string_sub = string.sub ;


local function nodeAddPerm( node, perm )
	local dot = string_find(perm,'.', 1, true);
	if dot then
		local key = string_sub(perm, 1, dot-1);
		local rest = string_sub(perm, dot+1 );
		if not node[key] then
			node[key] = {};
			node[#node+1] = key;
		end
		nodeAddPerm(node[key], rest);
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
	if vals then
		local out = {};
		for k,v in ipairs(vals)do
			out[k] = v;
		end
		return out;
	else
		return false;
	end
end

function tree_mt:delPerm( perm )
	nodeDelperm(self.root, perm);
end

function tree_mt:addPerm

function oc.perm( perms )
	local node = {};
	for _, perm in pairs(perms)do
		nodeAddPerm(node,perm);
	end
	return setmetatable({
		root = node,
		perms = perms
	}, tree_mt);
end
