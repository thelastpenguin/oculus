if (SERVER) then
	util.AddNetworkString("oc.AdminChat")

	local function AdminChat(pl, text)
		local filter = {}

		for k, v in pairs(player.GetAll()) do
			if oc.p(v):getPerm('meta.isAdmin') or v == pl then
				table.insert(filter, v)
			end
		end

		net.Start("oc.AdminChat")
			net.WriteBit(oc.p(pl):getPerm('meta.isAdmin'))
			net.WriteString(pl:Name())
			net.WriteString(text)
		net.Send(filter)
	end


	hook.Add("PlayerSay", "oc.AdminChat.PlayerSay", function(pl, text)
		if text[1] == "@" then
			AdminChat(pl, string.sub(text, 2))
			return ""
		end
	end)
elseif (CLIENT) then
	net.Receive("oc.AdminChat", function()
		local isAdmin = tobool(net.ReadBit())
		local name = net.ReadString()
		local text = net.ReadString()

		chat.AddText((isAdmin and Color(51, 128, 255)) or Color(255, 50, 255), ((isAdmin and "[STAFF] ") or "[TO STAFF] ") .. name .. ": " .. text)
	end)
end
