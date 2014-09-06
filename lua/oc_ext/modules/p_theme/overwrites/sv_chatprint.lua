util.AddNetworkString("pChatPrint")

local meta = FindMetaTable("Player")

function meta:pChatPrint(str, type)
	local type = type or "NORM"
	net.Start("pChatPrint")
		net.WriteString(str)
		net.WriteString(type)
	net.Send(self)
end

//meta.ChatPrint = meta.pChatPrint