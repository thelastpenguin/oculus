local view_mt = {};
view_mt.__index = view_mt;

oc.menu.views = {};
function oc.menu.addView( id, name )
	local obj = setmetatable({
		vid = id,
		name = name,
		icon = 'oc/icon64/little17.png',
	}, view_mt);
	oc.menu.views[id] = obj;
	return obj;
end

function view_mt:setIcon( icon )
	self.icon = icon;
	if SERVER then
		resource.AddSingleFile('materials/'..icon);
	end
end

function view_mt:setGenerator(func)
	self.generator = func;
end
function view_mt:runGenerator(panel, done)
	self.generator(self, panel, done)
end
function view_mt:setUpdater(func)
	self.updater = func;
end
function view_mt:runUpdater(panel, done)
	if self.updater then
		self.updater(self, panel, done)
	end
end

function view_mt:addPerm(perm)
	self.perm = perm;
	oc.perm.register(perm);
end

function view_mt:canOpen()
	if self.perm then
		return oc.checkPerm(LocalPlayer(), self.perm);
	else
		return true;
	end
end

local view_motd = oc.menu.addView('motd', 'MOTD');
local view_cmds = oc.menu.addView('cmds', 'ACTIONS');
local view_groups = oc.menu.addView('groups', 'GROUPS');
view_groups:setIcon('oc/icon64/group2.png');
local view_players = oc.menu.addView('players', 'PLAYERS');
view_players:setIcon('oc/icon64/search7.png');
local view_bans = oc.menu.addView('bans', 'BANS');
view_bans:setIcon('oc/icon64/trash8.png');