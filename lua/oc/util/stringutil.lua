local readNext, readSimple, readQuoted, readArray;

function readNext( str, start )
	//dprint('reading next from: '..start);
 	local start = string.find(str, '[^%s]', start);
	
	if start then
		//dprint('found next at: '..start);
		
		local startChar = str:sub(start, start);
		//dprint('  first char is: '..startChar);
		if startChar == '[' then
			return readArray(str, start+1);
		elseif startChar == '\'' or startChar == '"' then
			return readQuoted(str, start+1, startChar);
		else
			return readSimple(str, start);
		end
	else
		//dprint('no next found. terminating parse');
	end
end


local function findArrayClose( str, start )
	local count = 1;
	while(true)do
		start = str:find('[%[%]]', start);
		if not start then return end
		
		local char = str:sub(start, start);
		//print('char is: '..char);
		if char == '[' then
			count = count + 1;
		elseif char == ']' then
			count = count - 1;
			if count == 0 then
				return start;
			end
		end
		start = start + 1;
	end
end


function readArray( str, start )
	local finish = findArrayClose( str, start );
	if finish then
		local arrayBody = str:sub(start, finish-1);
		//print('ARRAY BODY: ', arrayBody);
		local array = {oc.parseLine(arrayBody)};
		return array, readNext(str, finish+1);
	else
		error('array not terminated. Error');
	end
end

function readQuoted( str, start, endChar )
	local finish = str:find('[^\\]'..endChar, start);
	//dprint('reading quoted');
	if finish then
		//dprint('found a finish at '..finish);
		return str:sub(start, finish), readNext(str, finish+2);
	else
		//dprint('finish quote not found. read entire line and terminated parser.');
		return str:sub(start);
	end
end

function readSimple( str, start )
	local finish = str:find('[%s]', start);
	//dprint('reading simple');
	
	if finish then
		//dprint('found a finish');
		return str:sub(start, finish-1), readNext(str, finish);
	else
		//dprint('finish not found. read entire line and terminated parser.');
		return str:sub(start);
	end
end


function oc.parseLine( str )
	return readNext(str, 1);
end