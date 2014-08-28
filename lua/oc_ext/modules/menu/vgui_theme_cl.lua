local draw = draw
local surface = surface
local Color = Color

local SKIN = {}

SKIN.PrintName = "pTheme"
SKIN.Author = "aStonedPenguin"

local panel_background = Color(240,240,240);

----------------------------------------------------------------
-- Frames                                                     --
----------------------------------------------------------------
function SKIN:PaintFrame(panel, w, h)

	surface.SetDrawColor(panel_background);
	surface.DrawRect(0, 0, w, h);

	if (panel.btnMinim) then
		panel.btnMinim:SetVisible(false)
	end
	
	if (panel.btnMaxim) then
		panel.btnMaxim:SetVisible(false)
	end

end 

-- we never really want to draw a panel's background.
function SKIN:PaintPanel(panel, w, h) end

function SKIN:PaintShadow() end

----------------------------------------------------------------
-- Buttons                                                    --
----------------------------------------------------------------
function SKIN:PaintButton(panel, w, h)

	if (!panel.m_bBackground) then return end

	if panel.btnColor then
		surface.SetDrawColor(panel.btnColor);
		surface.DrawRect(0,0,w,h);
	end

	if panel.Hovered then
		surface.SetDrawColor(0, 0, 100, 120);
		surface.DrawRect(0, 0, w, h);
	elseif not self.btnColor then
		surface.SetDrawColor(0, 0, 100, 80);
		surface.DrawRect(0, 0, w, h);
	end
end

----------------------------------------------------------------
-- Close Button                                               --
----------------------------------------------------------------
function SKIN:PaintWindowCloseButton(panel, w, h)

	if (!panel.m_bBackground) then return end

	-- we don't use this shit

end

----------------------------------------------------------------
-- Property Sheet                                             --
----------------------------------------------------------------
function SKIN:PaintPropertySheet(panel, w, h)
	-- we dont use this shit
end

----------------------------------------------------------------
-- Tabs                                                       --
----------------------------------------------------------------
function SKIN:PaintTab(panel, w, h)
	-- we dont use this shit	
end

----------------------------------------------------------------
-- Scrollbar                                                  --
----------------------------------------------------------------
function SKIN:PaintVScrollBar(panel, w, h) end

function SKIN:PaintScrollBarGrip(panel, w, h)
	if w ~= 5 then
		panel:SetWide(5);
		w = 5;
	end
	surface.SetDrawColor(50,50,50,230);
	surface.DrawRect(0,0,w,h);
end

function SKIN:PaintButtonUp(panel, w, h) end

function SKIN:PaintButtonDown(panel, w, h) end

function SKIN:PaintButtonLeft(panel, w, h) end

function SKIN:PaintButtonRight(panel, w, h) end

----------------------------------------------------------------
-- Collapsible Category                                       --
----------------------------------------------------------------
-- lets keep the default one
function SKIN:PaintCollapsibleCategory(panel, w, h)
	
	surface.SetDrawColor(20,30,100);
	surface.DrawRect(0,0,w,20);
end

----------------------------------------------------------------
-- Checkbox                                                   --
----------------------------------------------------------------
function SKIN:PaintCheckBox(panel, w, h)

	surface.SetDrawColor(255,255,255)
	surface.DrawRect(0,0,w,h);

	surface.SetDrawColor(0,0,0);
	surface.DrawOutlinedRect(0,0,w,h);

	if panel:GetChecked() then
		surface.SetDrawColor(50,50,50);
		surface.DrawRect(3, 3, w-6, h-6);
	end
end

----------------------------------------------------------------
-- Text Entry                                                 --
----------------------------------------------------------------
--function SKIN:PaintTextEntry(panel, w, h) end

----------------------------------------------------------------
-- NumSlider                                                  --
----------------------------------------------------------------
-- function SKIN:PaintNumSlider(panel, w, h) end
-- function SKIN:PaintSliderKnob(panel, w, h) end

----------------------------------------------------------------
-- Tree                                                       --
----------------------------------------------------------------
-- function SKIN:PaintTree(panel, w, h) end
-- function SKIN:PaintTreeNodeButton(panel) end

----------------------------------------------------------------
-- Category List                                              --
----------------------------------------------------------------
/*
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
	
end*/

----------------------------------------------------------------
-- Tool Tip                                                   --
----------------------------------------------------------------
--function SKIN:PaintTooltip(panel, w, h) end

derma.DefineSkin("oc_menu", "Theme for Oculus Menu", SKIN)