require("lufunge")
local gamera = require("gamera")
local cam = gamera.new(0,0,800,620)
_dejalarge = love.graphics.newFont("DejaVuSans.ttf",30)
_dejasys = love.graphics.newFont("DejaVuSans.ttf")
_play,_ok,_err,_print,_vars = false,true,"nil",{},0
_slow,_slowCount = false,0.1
_code = love.filesystem.read("code.lufunge")
_size = 40
_superSpeed = 10000
_zoom = 1

function love.load()
	lufungeInit(_code,true)
	local sx = 11/_height
	local sy = 16/_width
	print("scale:",sx,sy)
	local hs
	if sx<sy then hs=sx else hs=sy end
	_size=40*hs
	_deja = love.graphics.newFont("DejaVuSans.ttf",12*hs)
end

function love.draw()
	cam:setPosition(love.mouse.getX(),love.mouse.getY())
	cam:setScale(_zoom)
	love.graphics.setFont(_dejasys)
	love.graphics.setColor(255,255,255)
	love.graphics.print("lufunge interpreter",320,4)
	if love.mouse.getX()>0 and love.mouse.getX()<15 and love.mouse.getY()>0 and love.mouse.getY()<15 then love.graphics.setColor(255,0,0) end   
	love.graphics.print("X",4,4)
	love.graphics.setColor(255,255,255)
	if love.mouse.getX()>14 and love.mouse.getX()<30 and love.mouse.getY()>0 and love.mouse.getY()<25 then love.graphics.setColor(0,255,0) end
	love.graphics.print("▷",15,3)
	love.graphics.setColor(255,255,255)
	if love.mouse.getX()>29 and love.mouse.getX()<40 and love.mouse.getY()>0 and love.mouse.getY()<25 then love.graphics.setColor(255,255,0) end
	love.graphics.print("+",26,3)
	love.graphics.setColor(255,255,255)
	if love.mouse.getX()>39 and love.mouse.getX()<50 and love.mouse.getY()>0 and love.mouse.getY()<25 then love.graphics.setColor(0,255,255) end
	love.graphics.print("-",37,3)
	cam:draw(function()
		if _xp~=nil and _yp~=nil then
			--love.graphics.circle("fill",_xp*_size,_yp*_size,5)
			love.graphics.polygon("fill",{_xp*_size,_yp*_size+10,_xp*_size-5,_yp*_size-5,_xp*_size+5,_yp*_size-5})
		end
		love.graphics.setColor(255,255,255)
		love.graphics.setFont(_deja)
		for p in pairs(_pointers) do
			love.graphics.setFont(_deja)
			love.graphics.setColor(_cols[p%6])
			love.graphics.rectangle("fill", _pointers[p].x*_size-(_size/2),_pointers[p].y*_size,_size,_size)
			love.graphics.setFont(_dejasys)
			love.graphics.print(tostring(_pointers[p].val)..", "..tostring(_pointers[p].dir)..", "..tostring(t[_pointers[p].y][_pointers[p].x]),(120*p)-110,600)
		end
		love.graphics.setFont(_deja)
		for p in pairs(_prevPointers) do
			love.graphics.setColor({_cols[p%6][1],_cols[p%6][2],_cols[p%6][3],125})
			love.graphics.rectangle("fill", _prevPointers[p].x*_size-(_size/2),_prevPointers[p].y*_size,_size,_size)
		end
		for p in pairs(_prevPrevs) do
			love.graphics.setColor({_cols[p%6][1],_cols[p%6][2],_cols[p%6][3],65})
			love.graphics.rectangle("fill", _prevPrevs[p].x*_size-(_size/2),_prevPrevs[p].y*_size,_size,_size)
		end
		love.graphics.setColor(255,255,255,255)
		if t~=nil then
			for y=1,_height do
				for x=1,#t[y] do
					love.graphics.print(t[y][x],x*_size,(y*_size)+(_size/2))
				end
			end
		end
		for y=1,_height do
			for x=1,_width,1 do
				love.graphics.rectangle("line", x*_size-(_size/2), y*_size, _size, _size)
			end
		end
	end)
	local c,prev,val=2,"",0
	love.graphics.setColor(255,255,255)
	_vars=0
	love.graphics.setFont(_dejasys)
	for i,v in pairs(_G) do
		if type(v)~="table" and type(v)~="function" then
			if not tostring(i):find("^_") then
				if prev~="" then
					local var1,var2
					if type(v)=="string" then
						var1=i.."=\""..tostring(v).."\""
					else var1=i.."="..tostring(v) end
					if type(val)=="string" then
						var2=prev.."=\""..tostring(val).."\""
					else var2=prev.."="..tostring(val) end
					love.graphics.print(var1.." "..var2,670,(c*20))
					c=c+1
					prev=""
					val=0
				else prev=i val=v end
				_vars=_vars+1
			end
		end
	end
	love.graphics.print("print:",670,(c*20))
	c=c+1
	for i=#_print,1,-1 do
		love.graphics.print(tostring(_print[i]),670,(c*20))
		c=c+1
	end
	if not _ok then
		_play=false
		love.graphics.setColor(0,0,0)
		love.graphics.rectangle("fill", 10, 100, 660, 120)
		love.graphics.setColor(255,255,255)
		love.graphics.setFont(_dejalarge)
		love.graphics.printf("AN ERROR WAS RAISED: ".._err,20,100,650,"center")
	end
	love.graphics.setFont(_deja)
end

function love.update(dt)
	if _play then
		for x=1,_superSpeed do
			_ok,_err = pcall(lufungeStep)
			if not _ok then break end
			if #_print>(21-_vars) then
				table.remove(_print,1)
			end
		end
	end
	if _slow then
		if _slowCount<=0 then
			_ok,_err = pcall(lufungeStep)
			_slowCount=0.1
		else _slowCount=_slowCount-dt
		end
	end
end

function love.mousepressed(x, y, button)
	if button=="l" and x<15 and x>0 and y<15 and y>0 then
		love.event.quit()
	elseif button=="l" and x<30 and x>14 and y<15 and y>0 then
		_play=not _play
		if _play and _err then lufungeInit(_code,true) end
	elseif button=="l" and x<40 and x>29 and y<15 and y>0 then
		if _superSpeed<1000000 then _superSpeed=_superSpeed*10 end
	elseif button=="l" and x<55 and x>39 and y<15 and y>0 then
		if _superSpeed>1 then _superSpeed=_superSpeed/10 end
	elseif button=="l" then
		_ok=true
		_xp,_yp = cam:toWorld(x,y)
		_xp=_xp-(_size/2)
		_xp=math.floor(_xp/_size)+1
		_yp=math.floor(_yp/_size)
		if _yp>0 and _yp<_height+1 and _xp>0 and _xp<_width+1 then t[_yp][_xp]="" _code=genCode() end
	elseif button=="wu" then _zoom=_zoom+0.2
	elseif button=="wd" then _zoom=_zoom-0.2
	end
	if _zoom<1 then _zoom=1 end
end

function love.textinput(key)
	if _yp>0 and _yp<_height+1 and _xp>0 and _xp<_width+1 then t[_yp][_xp]=key _code=genCode() end
end

function love.keyreleased(key)
	if key=="return" then
		_slow=false
	end
end

function genCode()
	local newCode=""
	if t~=nil then
		for y=1,_height do
			for x=1,#t[y] do
				newCode=newCode..t[y][x]
			end
			newCode=newCode.."\r"
		end
	end
	love.filesystem.write("code.lufunge", newCode,all)
	return newCode
end