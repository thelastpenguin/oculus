/******************************************************************************
*                                PenguinTheme                                 *
*                            Convenience functions                            *
******************************************************************************/

local surface = surface

function draw.Box(x, y, w, h, col)
	surface.SetDrawColor(col)
	surface.DrawRect(x, y, w, h)
end

function draw.OutlinedBox(x, y, w, h, col, bordercol)
	surface.SetDrawColor(col)
	surface.DrawRect(x + 1, y + 1, w - 2, h - 2)
	
	surface.SetDrawColor(bordercol)
	surface.DrawOutlinedRect(x, y, w, h)
end

// Saving these dirty fuckers for when I re add tabs
/*
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
end*/