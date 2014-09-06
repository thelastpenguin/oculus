/******************************************************************************
*                                PenguinTheme                                 *
*                              A tweaked DFrame                               *
******************************************************************************/
local SysTime = SysTime
local timer = timer
local surface = surface

local PANEL = {}
 
function PANEL:Init()

	self.Anim = true

	self.btnClose:Remove()
	self.lblTitle:Remove()
	
	self.CloseB = vgui.Create("DButton", self)
	self.CloseB:SetText("")
	self.CloseB.DoClick = function() 
		self:Close() 
		surface.PlaySound("sound/p_theme/beep-21.mp3")
	end
	self.CloseB.Paint = function(panel, w, h) 
		derma.SkinHook("Paint", "WindowCloseButton", panel, w, h) 
	end
	
	self.Title = vgui.Create("DLabel", self)
	self.Title:SetFont("pTheme.Header")
	
end

function PANEL:SetPos(x, y, force, time)

	if (force) then self.BaseClass.SetPos(self, x, y) return end

	self:SetMovement(self.x, x, y, y, time or nil)
	self._StartTime = SysTime()
	self._Movement = 1

end

function PANEL:SetMovement(startX, endX, startY, endY, timeOverride)

	self.StartPos = {x = startX, y = startY}
	self.EndPos = {x = endX, y = (endY or startY)}
	
	self._AnimTime = timeOverride or nil

end

function PANEL:Close()

	self:SetMovement(self.x, -self:GetWide(), self.y, self.y)
	self._StartTime = SysTime()
	self._Movement = -1
	
	timer.Simple(3, function() if (self:IsValid()) then pTheme.Clsoe(self) end end)

end

function PANEL:DoThink()
	// So we don't have to override the normal think and break the anims
end

function PANEL:Think()

	if (!self._NoMoves) and (self._Movement != 0) then
		local mul, clamp
		
		if (self._Movement == 1) then
			clamp = math.Clamp((SysTime() - self._StartTime) / (self._AnimTime or .5), 0, 1)
			mul = math.sin(clamp * (math.pi / 1.418776)) * 1.25
		else
			clamp = math.Clamp((SysTime() - self._StartTime) / (self._AnimTime or .3), 0, 1)
			mul = math.sin((1 - clamp) * (math.pi / 1.418776)) * 1.25
		end
		
		local x, y
	
		if (self._Movement == 1) then
			x = self.StartPos.x + (mul * (self.EndPos.x - self.StartPos.x))
			y = self.StartPos.y + (mul * (self.EndPos.y - self.StartPos.y))
		else
			x = self.StartPos.x - (mul * (self.EndPos.x - self.StartPos.x)) + (self.EndPos.x - self.StartPos.x)
			y = self.StartPos.y - (mul * (self.EndPos.y - self.StartPos.y)) + (self.EndPos.y - self.StartPos.y)
		end
		
		self:SetPos(x, y, true)

		if (clamp == 1) then
			self._AnimTime = nil
			
			if (self._Movement == -1) then
				self:Remove()
			else
				self._Movement = 0
			end
		end
	end
	
	-- (modified) dframe think
	local mousex = math.Clamp( gui.MouseX(), 1, ScrW()-1 )
	local mousey = math.Clamp( gui.MouseY(), 1, ScrH()-1 )
		
	if ( self.Dragging ) then
		local x = mousex - self.Dragging[1]
		local y = mousey - self.Dragging[2]

		-- Lock to screen bounds if screenlock is enabled
		if ( self:GetScreenLock() ) then
			x = math.Clamp( x, 0, ScrW() - self:GetWide() )
			y = math.Clamp( y, 0, ScrH() - self:GetTall() )
		end
		
		if (!self.EndPos or self.EndPos.x != x or self.EndPos.y != y) then	
			self:SetPos(x, y)
		end
	end
	
	if (self.Sizing) then
		local x = mousex - self.Sizing[1]
		local y = mousey - self.Sizing[2]	
		local px, py = self:GetPos()
		
		if ( x < self.m_iMinWidth ) then x = self.m_iMinWidth elseif ( x > ScrW() - px and self:GetScreenLock() ) then x = ScrW() - px end
		if ( y < self.m_iMinHeight ) then y = self.m_iMinHeight elseif ( y > ScrH() - py and self:GetScreenLock() ) then y = ScrH() - py end
	
		self:SetSize(x, y)
		self:SetCursor("sizenwse")
		return
	end
	
	if ( self.Hovered &&
		 self.m_bSizable &&
		 mousex > (self.x + self:GetWide() - 20) &&
		 mousey > (self.y + self:GetTall() - 20) ) then	

		self:SetCursor("sizenwse")
		return
	end
	
	self:SetCursor("arrow")
	
	self:DoThink()

end

function PANEL:SetTitle(strTitle, col)

	if col then
		self.Title:SetColor(col)
	end
	
	self.Title:SetText(strTitle)

end

function PANEL:PerformLayout()

	self.CloseB:SetPos(self:GetWide() - 40, 0)
	self.CloseB:SetSize(40, 20)
	
	self.Title:SizeToContents()
	self.Title:SetPos(self:GetWide()/2 - self.Title:GetWide()/2, 4)
	self.Title:SetSize(self.Title:GetWide(), 20)

end

function PANEL:ShowCloseButton(hide)

	self.CloseB:SetVisible(hide)

end

function PANEL:CloseOnCall(bool)

	if bool then
		table.insert(pTheme.OpenWindows, panel)
	end

end

vgui.Register("pFrame", PANEL, "DFrame")
