local bit, table = bit, table;
oc.bit = {};

function oc.bit.encodeColor( col )
	local n = 0;
	n = bit.bor( n, col.r );
	n = bit.bor( bit.lshift( n, 8 ), col.g );
	n = bit.bor( bit.lshift( n, 8 ), col.b );
	n = bit.bor( bit.lshift( n, 8 ), col.a );
	return n;
end


function oc.bit.decodeColor( n )
	local a = bit.band( n, 0xFF );
	local b = bit.band( bit.rshift( n, 8 ), 0xFF );
	local g = bit.band( bit.rshift( n, 16 ), 0xFF );
	local r = bit.band( bit.rshift( n, 24 ), 0xFF );
	
	return Color( r, g, b, a );
end



