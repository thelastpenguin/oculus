local meta = FindMetaTable("Player")

local ChatPrints = {
	["NORM"] = {
		col = Color(255,255,255),
		sound = "sound/p_theme/beep-21.mp3"
	},
	["ERR"] = {
		col = Color(255,100,100),
		sound = "sound/p_theme/beep-30.mp3"
	},
}

function meta:pChatPrint(str, type)
	local col = Color(255,255,255)
	local sound = "sound/p_theme/beep-21.mp3"

	if type then
		col = ChatPrints[type].col
		sound = ChatPrints[type].sound
	end
	
	chat.AddText(Color(51,128,255), "| ", col, str)
	surface.PlaySound(sound)
end

net.Receive("pChatPrint", function()
	LocalPlayer():pChatPrint(net.ReadString(), net.ReadString())
end)

meta.ChatPrint = meta.pChatPrint

