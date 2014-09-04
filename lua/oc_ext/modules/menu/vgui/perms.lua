local PANEL = {};

function PANEL:Init()
	self.perms = {};

	-- add permission rows
	for k,v in SortedPairs(oc.permissions)do
		local row = vgui.Create('oc_menu-perm-row', self);
		row:SetPerm(v);
		table.insert(self.perms, row);
	end
	self:Update();


	self.onUpdate = function(group)
		if group == self.group then
			dprint('pannel received group update event for group '..group.name);
			self:Update();
		end
	end
	oc.hook.Add('GroupPermUpdate', self.onUpdate);

	self:PerformLayout();
end

function PANEL:Update()
	for k,v in pairs(self.perms)do
		v:Update(self.group);
	end
end
function PANEL:PerformLayout()
	local w = self:GetWide();

	local h = 0;
	for ind, row in pairs(self.perms) do
		row:SetPos(0, h);
		row:SetWide(w);
		h = h + row:GetTall() + 5;
	end
	
	self:SetTall(h);
end

function PANEL:OnRemove()
	dprint('removed panel');
	oc.hook.Remove('GroupPermUpdate', self.onUpdate);
end

function PANEL:SetGroup(group)
	self.group = group;
	self:Update();
end

vgui.Register('oc_menu-group-perms', PANEL);


local col_darkgreen = Color(55,155,55);
local col_paleblue = Color(155,155,200);
local PANEL = {};
function PANEL:Init()
	self:SetTall(32);
end
function PANEL:SetPerm(perm)
	self.perm = perm;

	self.lbl = Label(perm, self);
	self.lbl:SetTextColor(color_black);
	self.lbl:SetFont('oc_menu_8');

	self.cb_server = vgui.Create('DCheckBox', self);
	self.cb_global = vgui.Create('DCheckBox', self);
	self.cb_union = vgui.Create('DCheckBox', self);

	self.cb_server:SetToolTip("server value");
	self.cb_global:SetToolTip("global value");
	self.cb_union:SetToolTip("actual value server or global or inherited");
end

function PANEL:Update(group)
	if group then
		self.cb_global:SetVisible(true);
		self.cb_server:SetVisible(true);
		self.cb_union:SetVisible(true);

		local val_global = group.globalPerms:getPerm(self.perm);
		local val_local = group.serverPerms:getPerm(self.perm);

		self.cb_server.OnChange = xfn.noop;
		self.cb_global.OnChange = xfn.noop;
		self.cb_union.OnChange = xfn.noop;

		self.cb_server:SetValue(val_local);
		self.cb_global:SetValue(val_global);

		if not val_global and not val_local and group.inherits and group.inherits:getPerm(self.perm) then
			self.cb_union:SetValue(true);
			self.cb_union.color = col_paleblue;
		else
			self.cb_union:SetValue(val_global or val_local);
			self.cb_union.color = col_darkgreen;
		end


		function self.cb_server.OnChange(_, val)
			self:EditPerm(group.name, self.perm, false, val);
		end

		function self.cb_global.OnChange(_, val)
			self:EditPerm(group.name, self.perm, true, val);
		end

		function self.cb_union.OnChange(_, val)
			if val == false then
				if val_global then
					self:EditPerm(group.name, self.perm, true, false);
				end
				if val_local then
					self:EditPerm(group.name, self.perm, false, false);
				end
			else
				self:EditPerm(group.name, self.perm, false, true);
			end
		end
		

	else
		self.cb_global:SetVisible(false);
		self.cb_server:SetVisible(false);
		self.cb_union:SetVisible(false);
	end
end

function PANEL:EditPerm(groupName, perm, isGlobal, value)
	local cmd = 'group'..(value and 'add' or 'del')..(isGlobal and 'global' or 'local')..'perm';
	dprint('group name '..groupName..' perm '..perm);
	oc.netRunCommand(cmd, {
		groupName,
		perm
	})
end

function PANEL:PerformLayout()
	local w, h = self:GetSize();
	self.lbl:SetPos(5, (h-self.lbl:GetTall())*0.5);
	self.lbl:SetWide(w-10);

	local cbwidth = self.cb_server:GetWide();
	self.cb_global:SetPos(w - cbwidth * 3 - 15, (h-cbwidth)*0.5);
	self.cb_server:SetPos(w - cbwidth * 2 - 10, (h-cbwidth)*0.5);
	self.cb_union:SetPos(w - cbwidth * 1 - 5, (h-cbwidth)*0.5);
end


function PANEL:Paint(w, h)
	surface.SetDrawColor(200, 200, 200);
	surface.DrawRect(0,0,w,h);
	surface.SetDrawColor(0,0,0);
	surface.DrawOutlinedRect(0,0,w,h);
end

vgui.Register('oc_menu-perm-row', PANEL);