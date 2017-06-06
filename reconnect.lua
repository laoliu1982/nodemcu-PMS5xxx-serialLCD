tmr.alarm(1, 60000, 1, function()
if(wifi.sta.getip()==nil) then
wifi.sta.connect()
else
dofile("run.lc")
end
end)
