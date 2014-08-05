if SERVER then
	AddCSLuaFile()
end

oc = {};

if SERVER then
	oc._include_cl = function( ... ) AddCSLuaFile( ... ) end
	oc._include_sv = function( ... ) include( ... ) end
	oc._include_sh = function( ... )
		oc._include_cl( ... )
		oc._include_sv( ... )
	end
else
	oc._include_cl = function( ... ) include( ... ) end
	oc._include_sv = function( ... ) end
	oc._include_sh = function( ... ) include( ... ) end
end

oc._include_sh 'oc/main.lua'
