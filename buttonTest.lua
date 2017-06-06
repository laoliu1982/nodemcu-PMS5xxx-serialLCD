pulse1 = 0
du = 0
gpio.mode(3,gpio.INT)
function pin1cb(level)
du = tmr.now()-pulse1
print(du)
pulse1 = tmr.now()
if level == 1 then gpio.trig(3, "down") else gpio.trig(3, "up") end
end
gpio.trig(3, "down",pin1cb)