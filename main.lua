require("lufunge")
_deja = love.graphics.newFont("DejaVuSans.ttf")
_dejalarge = love.graphics.newFont("DejaVuSans.ttf",30)
_play,_ok,_err,_print,_vars,_prevPointers,_prevPrevs = false,true,"nil",{},0,{},{}
_code = [[
~a,b=2,2~
  v   <        <
       vb=1+b < 
  a    > b#a   \
  .   / b[2$a  <
@2>+1v>>a%b#0!\ 
  a  = b        
     a =        
     >2^        
  ^           < 
~print(a)~]]
-- _code = [[
-- ~a,b=function(p)if p==100 then p=0 end return love.math.random(p,100) end,0~
--   v       <
--   v b=0  < 
-- @1>a;#b  \b
-- @1>a=b;.v>^
--   ^     <
-- ]]

function love.load()
	love.graphics.setFont(_deja)
  lufungeInit(_code,true)
end

function love.draw()
  love.graphics.setColor(255,255,255)
  love.graphics.print("lufunge interpreter",320,4)
  if love.mouse.getX()>0 and love.mouse.getX()<15 and love.mouse.getY()>0 and love.mouse.getY()<15 then love.graphics.setColor(255,0,0) end   
  love.graphics.print("X",4,4)
  love.graphics.setColor(255,255,255)
  if love.mouse.getX()>14 and love.mouse.getX()<30 and love.mouse.getY()>0 and love.mouse.getY()<25 then love.graphics.setColor(0,255,0) end
  love.graphics.print("▷",15,3)
  love.graphics.setColor(255,255,255)
  for p in pairs(_pointers) do
    love.graphics.setColor(_cols[p%6])
    love.graphics.rectangle("fill", _pointers[p].x*40-20,_pointers[p].y*40,40,40)
    love.graphics.print(tostring(_pointers[p].val)..", "..tostring(_pointers[p].dir)..", "..tostring(t[_pointers[p].y][_pointers[p].x]),(120*p)-110,600)
  end
  for p in pairs(_prevPointers) do
    love.graphics.setColor({_cols[p%6][1],_cols[p%6][2],_cols[p%6][3],125})
    love.graphics.rectangle("fill", _prevPointers[p].x*40-20,_prevPointers[p].y*40,40,40)
  end
  for p in pairs(_prevPrevs) do
    love.graphics.setColor({_cols[p%6][1],_cols[p%6][2],_cols[p%6][3],65})
    love.graphics.rectangle("fill", _prevPrevs[p].x*40-20,_prevPrevs[p].y*40,40,40)
  end
  love.graphics.setColor(255,255,255,255)
  if t~=nil then
    for y=1,_height do
      for x=1,#t[y] do
        love.graphics.print(t[y][x],x*40,(y*40)+20)
      end
    end
  end
  for y=1,_height do
    for x=1,_width,1 do
      love.graphics.rectangle("line", x*40-20, y*40, 40, 40)
    end
  end
  local c,prev,val=2,"",0
  love.graphics.setColor(255,255,255)
  _vars=0
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
		_ok,_err = pcall(lufungeStep)
	end
	if #_print>(21-_vars) then
		table.remove(_print,1)
	end
end

function love.mousepressed(x, y, button)
	if button=="l" and x<15 and x>0 and y<15 and y>0 then
		love.event.quit()
	elseif button=="l" and x<30 and x>14 and y<15 and y>0 then
		_play=not _play
		if _play and _err then lufungeInit(_code,true) end
	elseif button=="l" then _ok=true end
end