oc.serverVars = oc.serverVars or {}

net.Receive('_loadServerVars', function()
	oc.serverVars = pon.decode(net.ReadString())
end)

function oc.getServerVar(var)
	return oc.serverVars[var]
end