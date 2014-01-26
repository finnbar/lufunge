--[[
	LuFunge: A Lua Funge Compiler Thingy.
	Simply put:
¬ @     start location, where a pointer can begin. will always start by going right. if another pointer hits it @ acts like >
¬ <^>v  four directions, go in that direction
¬ /     trigger: if "true" is carried turn right else turn left
¬ \     reverse trigger: if "true" is carried turn left else turn right
¬ ?     if false, kill this pointer. useful for ending the program
¬ !     reverse the pointer (if it would be true, explicitly set it to false, else if it is false or nil, make it true)
¬ 0-9   make the pointer equal to that value
¬ ;     sync: wait until another pointer has reached another one of these, then go
¬ |     jump: if given "true", jump to next one IN LINE (e.g. would skip ab: |ab|)
¬ +     increment pointer by next var
¬ -     decrement pointer by next var
¬ =     set next variable to pointer
¬ #     check if pointer is equal to next variable, and change pointer to true/false based on that
¬ .     print pointer
¬ %     modulus pointer with next var
¬ *     multiply pointer by next var
¬ $     divide pointer by next var
¬ "     assume everything is a string literal rather than a command until the next " (side effect: pointer is cleared)
¬ ~     lua code is contained in the tildas
¬ £     to the power of
¬ ]     greater than (changes pointer to true if so)
¬ [     less than

	Anything else:
	if a reference to a function, do it!
	if a variable, pointer equals it!
	if a variable AND there was an = before it, variable equals pointer!
	if there's no square there, bounce back! :D
	
	Example code:

	~a,b,c = run(), check(), find()~

	>0!?
	c@av
	\bc<
	b
	>0!?

	this code would execute a(), go down, go left, execute b(). c() then if the pointer has a "true" value it will execute c() else b(). then it will make the pointer equal 0 and reverse that (so true -> false), and then quit as the ? is given a false. now for more example code!:

	~a,b,c,d,e,p = run(), compare(), check(), false, 0, "0"~

	@4a;b;|0!?| v
	@4; b;p|0!?|v
	^           <

	function compare(arg,point) if d then if arg==e return true else p=false return false end else e=arg p=true d=true end --in short, first pointer to run this records its value as e. second pointer compares its value with e and returns true if they are the same

	this example code starts two _pointers with 4 and then makes one of them run a(). then they both run b(), and if they are the same, p becomes true, so the second pointer returns true. if they are true, they jump over the 0!? (aka quit the program) and loop! however, this program can be written better with more advanced symbols:

	~a,b,c = run(),0,false~

	@4a     ;v
					 =
	@4;     #b=c;|0!?|v
					 >;c|0!?| v
	^                 <

	this starts with two pointers, executes a() on one of them and then records the result as b ("=b"), then the second one checks b and records that value as c ("#b=c"), then kills the program if that is false. then the second pointer is set to c, and if that is false, the second pointer is killed, else they loop back to the start.
]]

-- _var == global var used by the interpreter, shouldn't be displayed in the list of vars.

_pointers = {} --work out where pointers are, and then record their positions
_cols = {{255,0,0},{0,255,0},{0,0,255},{255,255,0},{255,0,255},{0,255,255}}
_timer=0
_sync=0
_prevPointers,_prevPrevs={},{}

function lufungeInit(code2,newPointers)
	do  --for local scopes
		_height,_width = 0,0
		local check=0
		local luastrings=""
		for i in string.gmatch(code2,"%b~~") do
			luastrings=luastrings.."\n"..i
		end
		local luastrings = string.gsub(luastrings,"~","")
		local code = string.gsub(code2,"%b~~","")
		for i in string.gmatch(code,".") do
			if i=="\n" or i=="\r" then
				_height=_height+1
				if check>=_width then _width=check end
				check=0
			else check=check+1 end
		end
		_height=_height+1 --last line
		t={}
		table.insert(t,{})
		local p = 1
		for i in string.gmatch(code,".") do
			if i=="\n" or i=="\r" then table.insert(t,{}) p=p+1
			else table.insert(t[p],i) end
		end
		for y=1,_height,1 do
			local printString = ""
			for x=1,#t[y] do
				printString=printString..t[y][x]
			end
			print(printString)
		end
		if newPointers then _pointers={} end
		print(luastrings.."\n")
		local ok,err = pcall(loadstring(luastrings))
		if not ok then error(err) end
		print("")
		local c=1
		for y=1,_height do
			for x=1,#t[y] do
				if t[y][x]=="@" then 
					print(x,y)
					table.insert(_pointers,{})
					_pointers[c].x=x
					_pointers[c].y=y
					_pointers[c].dir="right"
					_pointers[c].val=false
					_pointers[c].mode="norm"
					c=c+1
				end
			end
		end
	end
	print("")
	return true --cheer
end

function bounce(p)
	if _pointers[p].dir=="left" then _pointers[p].dir="right"
	elseif _pointers[p].dir=="right" then _pointers[p].dir="left"
	elseif _pointers[p].dir=="up" then _pointers[p].dir="down"
	elseif _pointers[p].dir=="down" then _pointers[p].dir="up"
	end
	for x=1,2 do --bounce!
		if _pointers[p].dir=="left" then
			if _pointers[p].x>1 then _pointers[p].x=_pointers[p].x-1 end
		elseif _pointers[p].dir=="right" then
			if _pointers[p].x<_width then _pointers[p].x=_pointers[p].x+1 end
		elseif _pointers[p].dir=="up" then
			if _pointers[p].y>1 then _pointers[p].y=_pointers[p].y-1 end
		elseif _pointers[p].dir=="down" then
			if _pointers[p].y<_height then _pointers[p].y=_pointers[p].y+1 end
		end
	end
end

function lufungeStep()
--per pointer, move in dir, check square. square is PASSIVE (sets stuff but doesn't move the pointer)
	for p in pairs(_pointers) do
		if _pointers[p].mode~="_sync" then
			_prevPrevs={}
			for p in pairs(_prevPointers) do table.insert(_prevPrevs,{x=_prevPointers[p].x,y=_prevPointers[p].y}) end
			_prevPointers={}
			for p in pairs(_pointers) do table.insert(_prevPointers,{x=_pointers[p].x,y=_pointers[p].y}) end
			--movement!
			if _pointers[p].dir=="left" then
				if _pointers[p].x>1 then _pointers[p].x=_pointers[p].x-1 else bounce(p) end
			elseif _pointers[p].dir=="right" then
				if _pointers[p].x<_width then _pointers[p].x=_pointers[p].x+1 else bounce(p) end
			elseif _pointers[p].dir=="up" then
				if _pointers[p].y>1 then _pointers[p].y=_pointers[p].y-1 else bounce(p) end
			elseif _pointers[p].dir=="down" then
				if _pointers[p].y<_height then _pointers[p].y=_pointers[p].y+1 else bounce(p) end
			end
			--check square!
			local sq = t[_pointers[p].y][_pointers[p].x]
			if sq==nil then
				bounce(p)
			end
			if _pointers[p].mode~="string" and _pointers[p].mode~="jmp" then
				if sq=="^" or sq=="@" then
					_pointers[p].dir="up"
				elseif sq==">" then
					_pointers[p].dir="right"
				elseif sq=="<" then
					_pointers[p].dir="left"
				elseif sq=="v" then
					_pointers[p].dir="down"
				elseif type(sq)=="string" and sq:find("%d") then
					if _pointers[p].mode=="norm" then _pointers[p].val=sq end
					if _pointers[p].mode=="inc" then _pointers[p].val=_pointers[p].val+sq _pointers[p].mode="norm" end
					if _pointers[p].mode=="dec" then _pointers[p].val=_pointers[p].val-sq _pointers[p].mode="norm" end
					if _pointers[p].mode=="mul" then _pointers[p].val=_pointers[p].val*sq _pointers[p].mode="norm" end
					if _pointers[p].mode=="div" then _pointers[p].val=_pointers[p].val/sq _pointers[p].mode="norm" end
					if _pointers[p].mode=="mod" then _pointers[p].val=_pointers[p].val%sq _pointers[p].mode="norm" end
					if _pointers[p].mode=="pow" then _pointers[p].val=_pointers[p].val^sq _pointers[p].mode="norm" end
					if _pointers[p].mode=="com" then if tostring(_pointers[p].val)==tostring(sq) then _pointers[p].val=true else _pointers[p].val=false end _pointers[p].mode="norm" end
					if _pointers[p].mode=="gt" then if tonumber(_pointers[p].val)>tonumber(sq) then _pointers[p].val=true else _pointers[p].val=false end _pointers[p].mode="norm" end
					if _pointers[p].mode=="lt" then if tonumber(_pointers[p].val)<tonumber(sq) then _pointers[p].val=true else _pointers[p].val=false end _pointers[p].mode="norm" end
				elseif sq=="/" then
					if _pointers[p].val then
						local d=_pointers[p].dir
						if d=="left" then _pointers[p].dir="up"  --staggered due to Lua weirdness
						else 
							if d=="up" then _pointers[p].dir="right"
							else 
								if d=="right" then _pointers[p].dir="down"
								else 
									if d=="down" then _pointers[p].dir="left" end
								end
							end
						end
					else
						local d=_pointers[p].dir
						if d=="left" then _pointers[p].dir="down"
						else 
							if d=="up" then _pointers[p].dir="left"
							else
								if d=="right" then _pointers[p].dir="up"
								else
									if d=="down" then _pointers[p].dir="right" end
								end
							end
						end
					end
				elseif sq==[[\]] then --used [[]] so I didn't have to deal with \\
					if _pointers[p].val then
						local d=_pointers[p].dir
						if d=="left" then _pointers[p].dir="down"
						else 
							if d=="up" then _pointers[p].dir="left"
							else 
								if d=="right" then _pointers[p].dir="up"
								else 
									if d=="down" then _pointers[p].dir="right" end
								end
							end
						end
					else
						local d=_pointers[p].dir
						if d=="left" then _pointers[p].dir="up"
						else 
							if d=="up" then _pointers[p].dir="right"
							else 
								if d=="right" then _pointers[p].dir="down"
								else
									if d=="down" then _pointers[p].dir="left" end
								end
							end
						end
					end
				elseif sq=="?" then
					if not _pointers[p].val then
						_pointers[p]=nil
					end
				elseif sq=="!" then
					_pointers[p].val=not _pointers[p].val
				elseif sq=="+" then
					_pointers[p].mode="inc"
				elseif sq=="-" then
					_pointers[p].mode="dec"
				elseif sq=="." then
					print(_pointers[p].val)
					table.insert(_print,_pointers[p].val)
				elseif sq==[["]] then
					_pointers[p].mode="string"
				elseif sq==[[%]] then
					_pointers[p].mode="mod"
				elseif sq=="$" then
					_pointers[p].mode="div"
				elseif sq=="*" then
					_pointers[p].mode="mul"
				elseif sq=="£" then
					_pointers[p].mode="pow"
				elseif sq=="|" then
					if _pointers[p].val then _pointers[p].mode="jmp" end
				elseif sq=="#" then
					_pointers[p].mode="com"
				elseif sq=="=" then
					_pointers[p].mode="equ"
				elseif sq=="]" then _pointers[p].mode="gt"
				elseif sq=="[" then _pointers[p].mode="lt"
				elseif sq==";" then
					if _sync==0 then _pointers[p].mode="_sync" _sync=1 else if _sync==1 then _sync=2 end end 
				elseif sq=="" then
					--do nothing, just making sure a blank comes up in the below else
				else
					if _pointers[p].mode=="norm" then
						local v=_G[sq]
						if type(_G[sq])=="function" then local b=v(_pointers[p].val) if b~=nil then _pointers[p].val=b end 
						elseif v~=nil then _pointers[p].val=v end
					elseif _pointers[p].mode=="com" then
						if type(_G[sq])=="function" then
							if tostring(_pointers[p].val)==tostring(_G[sq]()) then _pointers[p].val=true else _pointers[p].val=false end
						else
							if tostring(_pointers[p].val)==tostring(_G[sq]) then _pointers[p].val=true else _pointers[p].val=false end
							_pointers[p].mode="norm"
						end
					elseif _pointers[p].mode=="equ" then
						_G[sq]=_pointers[p].val
						_pointers[p].mode="norm"
					else
						local v=_G[sq]
						if v~=nil then
							if _pointers[p].mode=="inc" then _pointers[p].val=_pointers[p].val+v _pointers[p].mode="norm" end
							if _pointers[p].mode=="dec" then _pointers[p].val=_pointers[p].val-v _pointers[p].mode="norm" end
							if _pointers[p].mode=="mul" then _pointers[p].val=_pointers[p].val*v _pointers[p].mode="norm" end
							if _pointers[p].mode=="div" then _pointers[p].val=_pointers[p].val/v _pointers[p].mode="norm" end
							if _pointers[p].mode=="mod" then _pointers[p].val=_pointers[p].val%v _pointers[p].mode="norm" end
							if _pointers[p].mode=="pow" then _pointers[p].val=_pointers[p].val^v _pointers[p].mode="norm" end
							if _pointers[p].mode=="gt" then if tonumber(_pointers[p].val)>tonumber(v) then _pointers[p].val=true else _pointers[p].val=false end _pointers[p].mode="norm" end
							if _pointers[p].mode=="lt" then if tonumber(_pointers[p].val)<tonumber(v) then _pointers[p].val=true else _pointers[p].val=false end _pointers[p].mode="norm" end
						end
					end
				end
			else
				if _pointers[p].mode=="string" then
					if type(_pointers[p].val)~="string" then _pointers[p].val="" end
					local v=t[_pointers[p].y][_pointers[p].x]
					if v~=[["]] then _pointers[p].val=_pointers[p].val..t[_pointers[p].y][_pointers[p].x] end
				elseif _pointers[p].mode=="jmp" then
					if t[_pointers[p].y][_pointers[p].x]=="|" then _pointers[p].mode="norm" end
				end
			end
		elseif _sync==2 then _pointers[p].mode="norm" _sync=0 end
	end
end