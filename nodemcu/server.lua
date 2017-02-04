---
local matrix = {2,3}
c = dofile 'colors.lua'
npx = dofile('npx.lua')(matrix,true)
a = dofile('animations.lua')
----

wifi.setmode(wifi.SOFTAP)
local IP = "192.168.0.10"
wifi.ap.setip({ip=IP,netmask="255.255.255.0"})
wifi.ap.config{ssid="Lua_NodeMCU",pwd="demodemo"}
print(wifi.ap.getip())


local unescape = function (s)
   s = string.gsub(s, "+", " ")
   s = string.gsub(s, "%%(%x%x)", function (h)
         return string.char(tonumber(h, 16))
      end)
   return s
end

srv=net.createServer(net.TCP)
srv:listen(80,function(conn)
  conn:on("receive", function(client,request)
    local buf = "<h1>NodeMCU webserver</h1>Send a POST with some Lua code!"
    local mcu_run = string.match(request, "mcu_run=(.*)")
    mcu_run = mcu_run and unescape(mcu_run)
    
    local ok,err
    if type(mcu_run)=='string' then
      local code = loadstring(mcu_run)
      setfenv(code, {c=c,npx=npx,animate=a,string=string,ws2812=ws2812,math=math,coroutine=coroutine})
      ok,err = pcall(code)
      if err then buf = buf..'<br/>'..err end
    end
    
    buf = buf ..[[
    <hr/>
    mcu_run=</br>
    <form method=post>
      <textarea rows="20" cols="100"name="mcu_run" placeholder="mcu_run">
]]..(mcu_run or 'mcu_run')..[[
      </textarea>
      <br/>
      <input type="submit" value="Submit">
    </form>
    ]]
    client:send(buf);
    client:close();
    collectgarbage();
  end)
end)
