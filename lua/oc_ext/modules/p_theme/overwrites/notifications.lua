/******************************************************************************
*                                PenguinTheme                                 *
*                       An edited notification.AddLegacy                      *
******************************************************************************/

local surface = surface 
local draw = draw
local vgui = vgui
local SysTime = SysTime
local CurTime = CurTime
local math = math
local table = table
local FrameTime = FrameTime

surface.CreateFont("GModNotify",{font= "Arial",size	= 20,weight	= 800})

local NotifyTypes = {
	[NOTIFY_GENERIC]	= Color(100,100,255),
	[NOTIFY_ERROR]		= Color(255,100,0),
	[NOTIFY_UNDO]		= Color(51,128,255),
	[NOTIFY_HINT]		= Color(0,215,15),
	[NOTIFY_CLEANUP]	= Color(51,128,255),
	[0]					= Color(255,128,51),
	[1]					= Color(255,0,0),
	[2]					= Color(51,128,255),
	[3]					= Color(0,215,15),
	[4]					= Color(51,128,255)
}

local Notices = {}

function pTheme.AddProgress( uid, text )

	local parent = nil
	if ( GetOverlayPanel ) then parent = GetOverlayPanel() end

	local Panel = vgui.Create( "pNoticePanel", parent )
		Panel.StartTime 	= SysTime()
		Panel.Length 		= 1000000
		Panel.VelX			= -5
		Panel.VelY			= 0
		Panel.fx = ScrW() + 200
		Panel.fy = ScrH()
		Panel:SetAlpha( 255 )
		Panel:SetText( text )
		Panel:SetPos( Panel.fx, Panel.fy )
		Panel:SetProgress()
	
	Notices[ uid ] = Panel

end

function pTheme.Kill( uid )

	if ( !IsValid( Notices[ uid ] ) ) then return end
	
	Notices[ uid ].StartTime 	= SysTime()
	Notices[ uid ].Length 		= 0.8

end

function pTheme.AddLegacy( text, type, length )

	local parent = nil
	if ( GetOverlayPanel ) then parent = GetOverlayPanel() end

	local Panel = vgui.Create( "pNoticePanel", parent )
	Panel.NotifyType = type
	Panel.StartTime 	= SysTime()
	Panel.Length 		= length
	Panel.VelX			= -5
	Panel.VelY			= 0
	Panel.fx = ScrW() + 200
	Panel.fy = ScrH()
	Panel:SetAlpha( 255 )
	Panel:SetText( text )
	Panel:SetPos( Panel.fx, Panel.fy )
	
	table.insert( Notices, Panel )

end

-- This is ugly because it's ripped straight from the old notice system
local function UpdateNotice( i, Panel, Count )

	local x = Panel.fx
	local y = Panel.fy
	
	local w = Panel:GetWide()
	local h = Panel:GetTall()

	w = w + 16
	h = h + 16
	
	local ideal_y = ScrH() - (Count - i) * (h-12) - 150
	local ideal_x = ScrW() - w - 20

	local timeleft = Panel.StartTime - (SysTime() - Panel.Length)
	
	-- Cartoon style about to go thing
	if ( timeleft < 0.7  ) then
		ideal_x = ideal_x - 50
	end
	 
	-- Gone!
	if ( timeleft < 0.2  ) then
	
		ideal_x = ideal_x + w * 2
	
	end
	
	local spd = FrameTime() * 15
	
	y = y + Panel.VelY * spd
	x = x + Panel.VelX * spd
	
	local dist = ideal_y - y
	Panel.VelY = Panel.VelY + dist * spd * 1
	if (math.abs(dist) < 2 && math.abs(Panel.VelY) < 0.1) then Panel.VelY = 0 end
	local dist = ideal_x - x
	Panel.VelX = Panel.VelX + dist * spd * 1
	if (math.abs(dist) < 2 && math.abs(Panel.VelX) < 0.1) then Panel.VelX = 0 end
	
	-- Friction.. kind of FPS independant.
	Panel.VelX = Panel.VelX * (0.95 - FrameTime() * 8 )
	Panel.VelY = Panel.VelY * (0.95 - FrameTime() * 8 )

	Panel.fx = x
	Panel.fy = y
	Panel:SetPos( Panel.fx, Panel.fy )

end


local function Update()

	if ( !Notices ) then return end
		
	local i = 0
	local Count = table.Count( Notices );
	for key, Panel in pairs( Notices ) do
	
		i = i + 1
		UpdateNotice( i, Panel, Count )
		
	end
	
	for k, Panel in pairs( Notices ) do
	
		if ( !IsValid(Panel) || Panel:KillSelf() ) then Notices[ k ] = nil end

	end

end

hook.Add( "Think", "NotificationThink", Update )

local PANEL = {}

--[[---------------------------------------------------------
   Name: Init
-----------------------------------------------------------]]
function PANEL:Init()

	self.NotifyType = NOTIFY_GENERIC
	
	self:DockPadding( 3, 3, 3, 3 )
	
	self.Label = vgui.Create( "DLabel", self )
	self.Label:Dock( FILL )
	self.Label:SetFont( "GModNotify" )
	self.Label:SetTextColor( Color( 255, 255, 255, 255 ) )
	self.Label:SetExpensiveShadow( 1, Color( 0, 0, 0, 200 ) )
	self.Label:SetContentAlignment( 5 )
	
	self:SetBackgroundColor( Color( 20, 20, 20, 255*0.6 ) )
	
end

function PANEL:SetText( txt )

	self.Label:SetText( txt )
	self:SizeToContents()
	
end

function PANEL:SizeToContents()

	self.Label:SizeToContents()
	
	local width = self.Label:GetWide()
	
	width = width + 15
	self:SetWidth( width )
	
	self:SetHeight( 28 )
	
	self:InvalidateLayout()

end

function PANEL:SetProgress()

	-- Quick and dirty, just how I like it.
	self.Paint = function( s, w, h )
	
		self.BaseClass.Paint( self, w, h )
		
	
		surface.SetDrawColor( 0, 100, 0, 150 )
		surface.DrawRect( 4, self:GetTall() - 10, self:GetWide() - 8, 5 )
		
		surface.SetDrawColor( 0, 50, 0, 255 )
		surface.DrawRect( 5, self:GetTall() - 9, self:GetWide() - 10, 3 )
		
		local w = self:GetWide() * 0.25
		local x = math.fmod( SysTime() * 200, self:GetWide() + w ) - w
		
		if ( x + w > self:GetWide() - 11 ) then w = ( self:GetWide() - 11 ) - x end 
		if ( x < 0 ) then w = w + x; x = 0 end
		
		surface.SetDrawColor( 0, 255, 0, 255 )
		surface.DrawRect( 5 + x, self:GetTall() - 9, w, 3 )
	
	end

end

function PANEL:KillSelf()

	if ( self.StartTime + self.Length < SysTime() ) then
	
		self:Remove()
		return true
	
	end

	return false
end

function PANEL:Paint(w, h)

	draw.OutlinedBox(0, 0, w, h, pTheme.Background, NotifyTypes[self.NotifyType])

end

vgui.Register( "pNoticePanel", PANEL, "DPanel" )

notification.AddLegacy = pTheme.AddLegacy 
