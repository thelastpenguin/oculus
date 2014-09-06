/******************************************************************************
*                                PenguinTheme                                 *
*                                 The theme                                   *
******************************************************************************/

local draw = draw
local surface = surface
local Color = Color

local SKIN = {}

SKIN.PrintName = "pTheme"
SKIN.Author = "aStonedPenguin"

pTheme.Blue = Color(51,128,255)

pTheme.Background = Color(0,0,0)
pTheme.Outline = Color(225,225,255)

pTheme.PanelBG = Color(200,200,200)
pTheme.PanelOutline = Color(255,255,255)

pTheme.CloseBG = Color(215,45,90)
pTheme.CloseBG_Depressed = Color(235,25,70)

pTheme.ButtonBG = Color(150,150,150)
pTheme.ButtonOutline = Color(225,225,255)

pTheme.TabGB = Color(175,175,175)

----------------------------------------------------------------
-- Frames                                                     --
----------------------------------------------------------------
function SKIN:PaintFrame(panel, w, h)

	draw.OutlinedBox(0, 0, w, h, pTheme.Background, pTheme.Outline)

	if (panel.btnMinim) then
		panel.btnMinim:SetVisible(false)
	end
	
	if (panel.btnMaxim) then
		panel.btnMaxim:SetVisible(false)
	end

end 

function SKIN:PaintPanel(panel, w, h)

	if (!panel.m_bBackground) then return end 

	draw.OutlinedBox(0, 0, w, h, pTheme.Background, pTheme.Outline)

end

function SKIN:PaintShadow() end

----------------------------------------------------------------
-- Buttons                                                    --
----------------------------------------------------------------
function SKIN:PaintButton(panel, w, h)

	if (!panel.m_bBackground) then return end

	local Background = pTheme.ButtonBG
	local TextCol = Color(0,0,0)

	if panel.Hovered then
		Background = pTheme.Blue
		TextCol = Color(255,255,255)
	end
	
	draw.OutlinedBox(0, 0, w, h, Background, pTheme.ButtonOutline)
	
	panel:SetTextColor(TextCol)
	panel:SetFont("pTheme.Button")
	
end

----------------------------------------------------------------
-- Close Button                                               --
----------------------------------------------------------------
function SKIN:PaintWindowCloseButton(panel, w, h)

	if (!panel.m_bBackground) then return end

	local h = 20 // Otherwise DFrames look kinda fucky
	local Background = pTheme.CloseBG
	local CloseX = pTheme.Outline
	
	if (panel.Hovered) then
		Background =  pTheme.CloseBG_Depressed
		CloseX = pTheme.Background 
	end
	
	draw.OutlinedBox(0, 0, w, h, Background, pTheme.Outline)
	draw.SimpleText("X", "pTheme.Close", w/2 + 1, h/2, CloseX, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER)

end

----------------------------------------------------------------
-- Property Sheet                                             --
----------------------------------------------------------------
function SKIN:PaintPropertySheet(panel, w, h)

	local ActiveTab = panel:GetActiveTab()
	local Offset = 0
	
	if (ActiveTab) then Offset = ActiveTab:GetTall() - 9  end

	draw.OutlinedBox(0, 0 + Offset, w, h - Offset, pTheme.Background, pTheme.Outline)

end

----------------------------------------------------------------
-- Tabs                                                       --
----------------------------------------------------------------
function SKIN:PaintTab(panel, w, h)

	local Background = pTheme.TabGB

	if panel:GetPropertySheet():GetActiveTab() == panel then
		h = h - 4
		Background = pTheme.ButtonBG
	end

	draw.OutlinedBox(0, 0, w, h, Background, pTheme.ButtonOutline)
	
	panel:SetTextColor(Color(0,0,0,255))
	
end

----------------------------------------------------------------
-- Scrollbar                                                  --
----------------------------------------------------------------
function SKIN:PaintVScrollBar(panel, w, h) end

function SKIN:PaintScrollBarGrip(panel, w, h)
	
	local Background = pTheme.ButtonBG

	if panel:GetParent().btnGrip.Depressed then
		Background = pTheme.Blue
	end
	
	draw.OutlinedBox(0, 0, w, h, Background, pTheme.Outline)

end

function SKIN:PaintButtonUp(panel, w, h)

	if (!panel.m_bBackground) then return end

	local Background = pTheme.ButtonBG

	if panel:GetParent().btnUp.Depressed then
		Background = pTheme.Blue
	end
	
	draw.OutlinedBox(0, 0, w, h, Background, pTheme.Outline)

end

function SKIN:PaintButtonDown(panel, w, h)

	if (!panel.m_bBackground) then return end

	local Background = pTheme.ButtonBG

	if panel:GetParent().btnDown.Depressed then
		Background = pTheme.Blue
	end
	
	draw.OutlinedBox(0, 0, w, h, Background, pTheme.Outline)

end

function SKIN:PaintButtonLeft(panel, w, h)
	
	if (!panel.m_bBackground) then return end

	local Background = pTheme.ButtonBG

	if panel:GetParent().btnLeft.Depressed then
		Background = pTheme.Blue
	end
	
	draw.OutlinedBox(0, 0, w, h, Background, pTheme.Outline)

end

function SKIN:PaintButtonRight(panel, w, h)

	if (!panel.m_bBackground) then return end

	local Background = pTheme.ButtonBG

	if panel:GetParent().btnRight.Depressed then
		Background = pTheme.Blue
	end
	
	draw.OutlinedBox(0, 0, w, h, Background, pTheme.Outline)

end

----------------------------------------------------------------
-- Collapsible Category                                       --
----------------------------------------------------------------
function SKIN:PaintCollapsibleCategory(panel, w, h)

	panel.light = true

	panel.Header:SetFont("pTheme.Catagory")
	panel.Header:SetTextColor(pTheme.Background)

	if (!panel:GetExpanded() and h < 20) then 
		draw.OutlinedBox(0, 0, w, h, Color(200,200,200), pTheme.Outline)
	else
		draw.OutlinedBox(0, 0, w, h, Color(200,200,200), pTheme.Outline)
		draw.OutlinedBox(0, 0, w, 20, pTheme.ButtonBG, pTheme.Outline)
	end
		
end

----------------------------------------------------------------
-- Checkbox                                                   --
----------------------------------------------------------------
function SKIN:PaintCheckBox(panel, w, h)

	local Background = pTheme.TabGB
	local Checked = false
	
	if (panel:GetChecked()) then
		Checked = true
		Background = pTheme.ButtonBG
	end	
	
	draw.OutlinedBox(0, 0, w, h, Background, pTheme.Background)

	if Checked then 
		draw.Box(3, 3, w - 6, h - 6, pTheme.Blue)
	end
	
end

----------------------------------------------------------------
-- Text Entry                                                 --
----------------------------------------------------------------
function SKIN:PaintTextEntry(panel, w, h)

	draw.Box(0, 0, w, h, pTheme.PanelBG, pTheme.PanelOutline)
	
	panel:DrawTextEntryText(pTheme.Background, pTheme.Blue, pTheme.Background)
	
end

----------------------------------------------------------------
-- NumSlider                                                  --
----------------------------------------------------------------
 function SKIN:PaintNumSlider(panel, w, h)

	surface.SetDrawColor(pTheme.Outline)
	surface.DrawLine(2, h/2, w - 4, h/2)
	surface.DrawLine(2, h/2 - 5, 2, h/2 + 6)
	surface.DrawLine(w * 0.1, h/2 - 2, w * 0.1, h/2 + 3)
	surface.DrawLine(w * 0.2, h/2 - 2, w * 0.2, h/2 + 3)
	surface.DrawLine(w * 0.3, h/2 - 2, w * 0.3, h/2 + 3)
	surface.DrawLine(w * 0.4, h/2 - 2, w * 0.4, h/2 + 3)
	surface.DrawLine(w * 0.5, h/2 - 5, w * 0.5, h/2 + 6)
	surface.DrawLine(w * 0.6, h/2 - 2, w * 0.6, h/2 + 3)
	surface.DrawLine(w * 0.7, h/2 - 2, w * 0.7, h/2 + 3)
	surface.DrawLine(w * 0.8, h/2 - 2, w * 0.8, h/2 + 3)
	surface.DrawLine(w * 0.9, h/2 - 2, w * 0.9, h/2 + 3)
	surface.DrawLine(w - 4, h/2 - 5, w - 4, h/2 + 6)
	
end

function SKIN:PaintSliderKnob(panel, w, h)
	
	local Background = pTheme.ButtonBG
	
	if panel.Depressed then
		Background = pTheme.Blue
	end	
			
	draw.OutlinedBox(3, 3, w - 4, h - 4, Background, pTheme.Outline)

end

----------------------------------------------------------------
-- Tree                                                       --
----------------------------------------------------------------
function SKIN:PaintTree(panel, w, h)
	
	draw.OutlinedBox(0, 0, w, h, pTheme.PanelBG, pTheme.Outline)

end

function SKIN:PaintTreeNodeButton(panel)

	local w, h = panel:GetTextSize() 

	if (panel.m_bSelected) then 
		draw.OutlinedBox(38, 0, w + 6, h + 3, pTheme.Blue, pTheme.Outline)
	end
	
	panel:SetTextColor(pTheme.Background)

end

----------------------------------------------------------------
-- Category List                                              --
----------------------------------------------------------------
function SKIN:PaintCategoryList() end

function SKIN:PaintCategoryButton(panel, w, h)

	local SelectedCol = false

	if (panel.AltLine) then
		if (panel.Depressed || panel.m_bSelected || panel.Hovered)  then 
			SelectedCol = pTheme.Blue
		end
	else
		if (panel.Depressed || panel.m_bSelected || panel.Hovered)  then 
			SelectedCol = pTheme.Blue
		end
	end
	
	panel:SetTextColor(pTheme.Background)
	
	if SelectedCol then 
		surface.SetDrawColor(SelectedCol)
		surface.DrawRect(0, 0, w, h)
		panel:SetTextColor(pTheme.Background)
	end
	
end

----------------------------------------------------------------
-- Tool Tip                                                   --
----------------------------------------------------------------
function SKIN:PaintTooltip(panel, w, h)

	draw.OutlinedBox(0, 0, w, h, pTheme.Background, pTheme.Outline)

end

derma.DefineSkin("pTheme", "The official SUP derma theme", SKIN)