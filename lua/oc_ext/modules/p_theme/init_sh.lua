/******************************************************************************
*                                PenguinTheme                                 *
*                              By aStonedPenguin                              *
******************************************************************************/
if (CLIENT) then
	pTheme = pTheme or {}
end

// Like everything I make, it's gotta have fancy prints.
MsgC(Color(255,0,0), "------------------------\n")
MsgC(Color(255,0,0), "- pTheme v3.0 Loading: -\n")
MsgC(Color(255,0,0), "------------------------\n")

local function AddClientFile(dir)
	if (SERVER) then
		AddCSLuaFile(dir)
	elseif (CLIENT) then
		include(dir)
		MsgC(Color(255,0,0), "pTheme | " .. dir .. "\n")
	end
end

local function AddServerFile(dir)
	if (SERVER) then
		include(dir)
		MsgC(Color(255,0,0), "pTheme | " .. dir .. "\n")
	end
end

AddClientFile("theme/funcs.lua")
AddClientFile("theme/fonts.lua")
AddClientFile("theme/skin.lua")

AddClientFile("vgui/funcs.lua")
AddClientFile("vgui/pframe.lua")

AddClientFile("overwrites/dermastring.lua")
AddClientFile("overwrites/notifications.lua")
AddClientFile("overwrites/cl_chatprint.lua")
AddServerFile("overwrites/sv_chatprint.lua")

AddClientFile("legacy/misc.lua")

MsgC(Color(255,0,0), "------------------------\n")


if (CLIENT) then
	hook.Add("ForceDermaSkin", "pTheme.ForceSkin", function()
		return "pTheme"
	end)
end

if (SERVER) then
	resource.AddFile("sound/p_theme/beep-21.mp3")
	resource.AddFile("sound/p_theme/beep-30.mp3")
end