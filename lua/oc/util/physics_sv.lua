oc.physics = oc.physics or {}

function oc.physics.IsEmpty(vector, ignore)
	ignore = ignore or {}

	local point = util.PointContents(vector)
	local a = point ~= CONTENTS_SOLID
		and point ~= CONTENTS_MOVEABLE
		and point ~= CONTENTS_LADDER
		and point ~= CONTENTS_PLAYERCLIP
		and point ~= CONTENTS_MONSTERCLIP

	local b = true

	for k,v in pairs(ents.FindInSphere(vector, 35)) do
		if (v:IsNPC() or v:IsPlayer() or v:GetClass() == "prop_physics") and not table.HasValue(ignore, v) then
			b = false
			break
		end
	end
	return a and b
end

function oc.physics.FindEmptyPos(pos, ignore, distance, step, area)
	if oc.physics.IsEmpty(pos, ignore) and oc.physics.IsEmpty(pos + area, ignore) then
		return pos
	end

	for j = step, distance, step do
		for i = -1, 1, 2 do -- alternate in direction
			local k = j * i

			-- Look North/South
			if oc.physics.IsEmpty(pos + Vector(k, 0, 0), ignore) and oc.physics.IsEmpty(pos + Vector(k, 0, 0) + area, ignore) then
				return pos + Vector(k, 0, 0)
			end

			-- Look East/West
			if oc.physics.IsEmpty(pos + Vector(0, k, 0), ignore) and oc.physics.IsEmpty(pos + Vector(0, k, 0) + area, ignore) then
				return pos + Vector(0, k, 0)
			end

			-- Look Up/Down
			if oc.physics.IsEmpty(pos + Vector(0, 0, k), ignore) and oc.physics.IsEmpty(pos + Vector(0, 0, k) + area, ignore) then
				return pos + Vector(0, 0, k)
			end
		end
	end

	return pos
end