local view_mt = {};
view_mt.__index = view_mt;

ocm.menu.views = {};
function ocm.menu.addView( id, name )
	local obj = setmetatable({
		vid = id,	
		name = name,
		icon = 'oc/icon64/little17.png',
	}, view_mt);
	ocm.menu.views[id] = obj;
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
