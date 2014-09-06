// Backwards compadabily between pTheme 2.0 and 3.0, because I am not inclined to redo all my vgui yet.


PenguinTheme = {}

PenguinTheme.BackgroundConvar = pTheme.Background

PenguinTheme.OutlineConvar = pTheme.Outline

PenguinTheme.Outline2 = Color(0,0,0) 

PenguinTheme.OutlineActiveConvar = pTheme.Outline

PenguinTheme.BackgroundActiveConvar = pTheme.Blue

PenguinTheme.ButtonBG = pTheme.ButtonBG

PenguinTheme.Tab = pTheme.TabGB

PenguinTheme.TabActive = pTheme.ButtonBG

PenguinTheme.TextEntry = pTheme.Background

// fonts
surface.CreateFont ("PenguinTheme.HeaderFont", {
	font = "coolvetica",
	size = 24,
	weight = 300
})

surface.CreateFont ("PenguinTheme.CloseFont", {
	font = "Trebuchet MS",
	size = 20
})

surface.CreateFont ("PenguinTheme.ButtonFont", {
	font = "Tahoma",
	size = 24,
	weight = 600
})

surface.CreateFont ("PenguinTheme.TabButtonFont", {
	font = "Trebuchet MS",
	size = 16
})

// funcs
function PenguinTheme.MakeMenu(type, parent)
	if type == "SFrame" then
		local element = pTheme.Create("pFrame", parent or nil)
		return element	
	end

	local element = pTheme.Create(type, parent or nil)


	return element
end

PenguinTheme.CloseMenu = pTheme.Close

PenguinTheme.CloseAll = pTheme.CloseAll

function PenguinTheme.TabSize(w, h)
	return w - 10, h - 35
end

function PenguinTheme.SizeToParent(parent, self)
	return parent:GetWide(), parent:GetTall()
end

function PenguinTheme.MakeURL(type, url, lbl, parent, x, y, w, h)
	local btn = vgui.Create("DButton", parent)	
	btn:SetSize(w, h)
	btn:SetPos(x, y)
	btn:SetText(lbl)
	btn.DoClick = function()
		if type == "GUI" then
			gui.OpenURL("http://" .. url)
		elseif type == "HTML" then
			// To do
		else
			LocalPlayer():ChatPrint("Dip shit")
		end
	end
	return btn
end

function PenguinTheme.MakeList(tbl, font, parent, x, y)
	for k, v in pairs(tbl) do
		local lbl = vgui.Create("DLabel", parent)
		lbl:SetFont(font)
		lbl:SetText(v)
		lbl:SizeToContents()
		lbl:SetPos(x, y)
		if (k != #tbl) then y = y + lbl:GetTall() end
	end
	return lbl
end

 //  theme funcs
function DrawOutlinedBox(w, h, col1, col2)
	draw.OutlinedBox(0, 0, w, h, col1, col2)
end

function DrawOutlinedBox( w, h, col1, col2 )
	draw.RoundedBox( 0, 1, 1, w - 2, h - 2, col1 )
	surface.SetDrawColor( col2 )
	surface.DrawOutlinedRect( 0, 0, w, h )
end

function PaintTabButton( parent, name )
	local w, h = 126,60
	if parent.CurrentTab == name then
		surface.SetDrawColor(PenguinTheme.BackgroundActiveConvar)
		surface.SetTexture(surface.GetTextureID("gui/center_gradient"))
		surface.DrawTexturedRect(w-w*1.1, h-h*1.1, w *1.2, h*1.2)
	end
	surface.SetDrawColor(PenguinTheme.OutlineConvar)
	surface.DrawOutlinedRect(0, 0, w, h)
end

function PaintF4Button( self )
	local w, h = 126,60
	if self.Toggled then
		surface.SetDrawColor(PenguinTheme.BackgroundActiveConvar)
		surface.SetTexture(surface.GetTextureID("gui/center_gradient"))
		surface.DrawTexturedRect(w-w*1.1, h-h*1.1, w *1.2, h*1.2)
	end
	surface.SetDrawColor(PenguinTheme.OutlineConvar)
	surface.DrawOutlinedRect(0, 0, w, h)
end

function DrawGradBG(x, y, w, h, col)
	if col == nil then col = Color(255,255,255,255) end

	surface.SetMaterial(Material("gui/gradient"))
	
	surface.SetDrawColor(0,0,0,102)
	surface.DrawRect(x + h, y, w - h * 2, h)
	surface.DrawRect(x + h, y, w - h * 2, h)
	
	surface.SetDrawColor(0,0,0,168)
	surface.DrawTexturedRect(x + w - h, y, h, h)
	surface.DrawTexturedRectRotated(x + h/2, y + h/2, h, h, 180)

	surface.SetDrawColor(col)
	surface.DrawRect(x + h, y, w - h * 2, 2)
	surface.DrawTexturedRect(x + w - h, y, h, 2)
	surface.DrawTexturedRectRotated(x + h/2, y + 1, h, 2, 180)
	
	surface.DrawRect(x + h, y + h, w - h * 2, 2)
	surface.DrawTexturedRect(x + w - h, y + h, h, 2)
	surface.DrawTexturedRectRotated(x + h/2, y + h + 1, h, 2, 180)
end



// VGUI
local PANEL = {}
AccessorFunc( PANEL, "m_iconSize", "IconSize" )

function PANEL:Init( )
	self:SetIconSize( 126 )
	self.seperatorWidth = 0
	self.tabBarWidth = 126
	
	self.tabsContainer = vgui.Create( "DPanel", self )
	self.tabsContainer:Dock( RIGHT )
	function self.tabsContainer.PerformLayout( )
		self.tabsContainer:SetWide( self.tabBarWidth )
	end
	function self.tabsContainer:Paint( w, h )
		surface.DrawLine(0, 0, w, 0)
	end
	
	self.tabs = vgui.Create( "DIconLayout", self.tabsContainer )
	self.tabs:Dock( FILL )
	function self.tabs:Paint( w, h )
	end
	
	self.selectedPanelMarker = vgui.Create( "DPanel", self )
	self.selectedPanelMarker:SetZPos( 0 )
	function self.selectedPanelMarker:Paint( w, h )
	end
	
	self:SetIconSpacing( -1 )
	self:SetTabsInnerMargin( 5 )
end

function PANEL:SetTabsInnerMargin( space )
	self.innerMargin = space
end

function PANEL:SetIconSpacing( space )
	self.ySpacing = space
	self.tabs:SetSpaceY( space )
end

function PANEL:PerformLayout( )
	self.tabs:SetWide( self:GetIconSize( ) )
	local spaceX = ( self.tabsContainer:GetWide( ) - self:GetIconSize( ) ) / 2
	self.tabs:DockMargin( spaceX, self.ySpacing, spaceX, self.ySpacing )
	
	self:SetWide( self.tabsContainer:GetWide( ) + self.seperatorWidth )
	for k, v in pairs( self:GetTabs( ) ) do
		if self:GetPropertySheet( ):GetActiveTab( ) == v then
			local x, y = v:GetPos( )
			local x2, y2 = self.tabs:GetPos( )
			
			x = x + x2
			y = y + y2
			
			x = x - self.ySpacing / 2
			y = y - self.ySpacing / 2
			
			self.selectedPanelMarker:SetPos( x, y )
			self.selectedPanelMarker:SetSize( self:GetWide( ) - x, v:GetTall( ) + self.ySpacing )
		end
	end
end

function PANEL:Paint( w, h )
end

function PANEL:GetTabs( )
	return self.tabs:GetChildren( )
end	


function PANEL:addTab( label, panel, material )
	local TabButton = vgui.Create( "DButton", self.tabs )
	TabButton:SetSize( 126,60 )
	TabButton:SetText(label)
	TabButton:SetTextColor(Color(255,255,255))
	TabButton:SetFont( "PenguinTheme.ButtonFont" )
	TabButton.Paint = function(self)
		local w, h = self:GetWide(), self:GetTall()
		if self:GetPropertySheet( ):GetActiveTab( ) == TabButton then
			surface.SetDrawColor(PenguinTheme.BackgroundActiveConvar)
			surface.SetTexture(surface.GetTextureID("gui/center_gradient"))
			surface.DrawTexturedRect(w-w*1.1, h-h*1.1, w *1.2, h*1.2)
		end
		surface.SetDrawColor(PenguinTheme.OutlineConvar)
		surface.DrawOutlinedRect(0, 0, w, h)
	end


	function TabButton:DoClick( )
		self:GetPropertySheet( ):SetActiveTab( self )
		surface.PlaySound("d3a/beep-21.mp3")
	end
	TabButton.panel = panel
	function TabButton:GetPanel( )
		return self.panel
	end
	function TabButton.GetPropertySheet( )
		return self:GetPropertySheet( )
	end
	
	return TabButton
end
vgui.Register( "DVPS", PANEL, "DPanel" ) 





local PANEL = {}
AccessorFunc( PANEL, "m_pActiveTab", "ActiveTab" )
function PANEL:Init( )
	self.spacing = 25
	
	self.tabBar = vgui.Create( "DVPS", self )
	self.tabBar:Dock( LEFT )
	function self.tabBar.GetPropertySheet( )
		return self
	end
	
	self.panelContainer = vgui.Create( "DPanel", self )
	self.panelContainer:DockMargin( 0, 0, 0, 0 )
	self.panelContainer:Dock( FILL )
end

function PANEL:AddTab( label, panel, material )
	panel:SetParent( self.panelContainer )
	local tab = self.tabBar:addTab( label, panel, material )
	panel:SetVisible( false )
	panel:Dock( FILL )
	if not self:GetActiveTab( ) then
		self:SetActiveTab( tab )
		panel:SetVisible( true )
	end
end

function PANEL:SetActiveTab( tab )
	if self.m_pActiveTab then
		self.m_pActiveTab:GetPanel( ):SetVisible( false )
	end
	self.m_pActiveTab = tab
	self.m_pActiveTab:GetPanel( ):SetVisible( true )
	self:InvalidateLayout( )
	self.tabBar:InvalidateLayout( )
end

function PANEL:Paint( w, h )
end

function PANEL:PerformLayout( )
	local activeTab = self:GetActiveTab( )
	if not activeTab then return end
	activeTab:InvalidateLayout( true )
	
	for k, tab in pairs( self.tabBar:GetTabs( ) ) do
		if tab == activeTab then
			tab:GetPanel( ):SetVisible( true )
			tab:GetPanel( ):SetZPos( 2 )
		else
			tab:GetPanel( ):SetVisible( false )
			tab:GetPanel( ):SetZPos( 1 )
		end
	end
end

vgui.Register( "DPS", PANEL, "DPanel" )

local PANEL = {}
 
function PANEL:Init()

	self.btnClose:Remove()
	self.lblTitle:Remove()
	
	self.CloseB = vgui.Create( "DButton", self )
	self.CloseB:SetText( "" )
	self.CloseB.DoClick = function() 
		self:Close() 
		surface.PlaySound( "d3a/beep-21.mp3" )
	end
	self.CloseB.Paint = function( panel, w, h ) 
		derma.SkinHook( "Paint", "WindowCloseButton", panel, w, h ) 
	end
	
	self.Title = vgui.Create( "DLabel", self )
	self.Title:SetFont( "PenguinTheme.HeaderFont" )
	
end

function PANEL:SetTitle( strTitle )

	self.Title:SetText( strTitle )

end

function PANEL:PerformLayout()

	self.CloseB:SetPos( self:GetWide() - 40, 0 )
	self.CloseB:SetSize( 40, 20 )
	
	self.Title:SizeToContents()
	self.Title:SetPos( self:GetWide()/2 - self.Title:GetWide()/2, 4 )
	self.Title:SetSize( self.Title:GetWide(), 20 )

end

function PANEL:ShowCloseButton( bit )

	if bit == true then return end
	
	self.CloseB:SetVisible( false )

end

function PANEL:Close()
	pTheme.Close(self)
end

vgui.Register( "SFrame", PANEL, "DFrame" )