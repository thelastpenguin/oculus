function oc.ParseString( str )
	str = ' '..str..' ';
	local res = {};
	local ind = 1;
	while( true )do
		local sInd, start = string.find( str, '[^%s]', ind );
		if not sInd then break end
		ind = sInd + 1;
		local quoted = str:sub( sInd, sInd ):match( '["\']' ) and true or false;
		local fInd, finish = string.find( str, quoted and '["\']' or '[%s]', ind );
		if not fInd then break end
		ind = fInd + 1;
		local str = str:sub( quoted and sInd + 1 or sInd, fInd - 1 )
		res[#res+1] = str;
	end
	return res;
end