local cleanup_perm = 'plugin.AdminCleanup'
oc.perm.register(cleanup_perm)

concommand.Add("gmod_admin_cleanup", function(pl, cmd, args)
	if not oc.p(pl):getPerm(cleanup_perm) then
		return
	end
	for k,v in pairs(ents.GetAll()) do
		if v:GetClass() == args[1] then
			v:Remove()
		end
	end
end)
