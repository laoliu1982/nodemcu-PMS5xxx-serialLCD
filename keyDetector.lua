local moduleName = ...
local M = {}
_G[moduleName] = M

local pulse1 = 0
local du = 0

local flashButton = 3
--bEnabledPMS = true

function noOp(level)
--print("no op")
end



function shortPress()
     print("short press")
     tmr.stop(6)
     require("lcd")
     if(lcd.crtPage() == 2 or lcd.crtPage() == 3) then
          enduser_setup.stop()
          lcd.showPage(1)
          --lcd.setText("info","")
          tmr.delay(200000)
          pms = require("pms")
          pms.enablePMS()
     else
          lcd.showPage(2)
          require("pms")
          pms.disablePMS()
          pms = nil
          require("qrCode")
          qrCode.qrCodeDisp()
          lcd.setText("info","绑定设备后,长按按键3秒配置网络")
          tmr.delay(200000)
          qrCode = nil
          collectgarbage()
          
          if(wifi.sta.getip()==nil)then
          --[[
          for k, v in pairs(_G) do 
               print(k) 
               end
               print("==================")
               for k, v in pairs(package.loaded) do 
               print(k) 
          end
          ]]--
               _G['LeweiHttpClient'] = nil
               LeweiHttpClient  = nil
               --lcd =nil
          collectgarbage()
     print(node.heap())
               print("soft ap mode")
               --require("network_default_cfg")
               
               wifi.setmode(wifi.STATIONAP)
               wifi.ap.config({ssid="LEWEI50", auth=wifi.OPEN})
               enduser_setup.manual(true)
               wifi.sta.disconnect()
               wifi.ap.dhcp.start()
               enduser_setup.start(
                 function()
                    print("Connected to wifi as:" .. wifi.sta.getip())
                    ssid, password, bssid_set, bssid=wifi.sta.getconfig()
                    file.open("network_user_cfg.lua","w")
                    file.writeline("wifi.sta.config(\""..ssid.."\", \""..password.."\")")
                    file.close()
                    lcd.setText("info","网络配置成功.")
                    ssid, password, bssid_set, bssid=nil, nil, nil, nil
                    --node.restart()
                 end,
                 function(err, str)
                   --print("enduser_setup: Err #" .. err .. ": " .. str)
                 end
               );
               
               
          end
     end
end

function longPress()
     --tmr.stop(6)
     gpio.trig(flashButton, "down")
     require("pms")
     pms.disablePMS()    
     require("airkiss")
     airkiss.setupAirKiss()
end

function pin1cb(level)
     if level == 1 then 
          --print("up"..tmr.now().."-"..pulse1)
          tmr.stop(6)
          gpio.trig(flashButton, "down",pin1cb) 
          du = tmr.now()-pulse1
          if(du<50000)then
               --ignor
          elseif(du<600000)then
                    shortPress()
          --elseif(du<10000000)then
                    --require("pms")
                    --pms.disablePMS()    
                    --require("airkiss")
                    --airkiss.setupAirKiss()
          --else
               --print("restore default")
               --file.remove("network_user_cfg.lua")
               --file.remove("qrcode.txt")
               --node.restart()
          end
     else 
          --print("down"..tmr.now())
          pulse1 = tmr.now()
          tmr.alarm(6, 2500, 0, function()
               print("3s")
               longPress()
               end )
          gpio.trig(flashButton, "up",pin1cb) 
     end
     print(node.heap())
end


function M.disableTrig()
--print("disable trig")
gpio.mode(flashButton,gpio.INT)
--print("disable trig1")
     gpio.trig(flashButton, "down",noOp)
--print("disable trig2")
end

function M.enableTrig()
--print("enable trig")
gpio.mode(flashButton,gpio.INT)
     gpio.trig(flashButton, "down",pin1cb)
end
--enableTrig()

return M
