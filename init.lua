require("WatchDog")
require("lcd")
require("keyDetector")
require("pms")
pms.disablePMS()
uart.setup( 0, 9600, 8, 0, 1, 0 )
lcd.showPage(0)
tmr.delay(1000000)
lcd.showPage(1)
lcd.showPage(1)
lcd.setPic("wifiState",4)



--tmr.alarm(0, 20000, 1, function()

function connect()
     print("connect")
     --wifi.eventmon.register(wifi.eventmon.STA_CONNECTED, function(T) 
      --print("\n\tSTA - CONNECTED".."\n\tSSID: "..T.SSID.."\n\tBSSID: "..
      --T.BSSID.."\n\tChannel: "..T.channel)
      --lcd.setPic("wifiState",6)
      --end)
     
      --wifi.eventmon.register(wifi.eventmon.STA_DISCONNECTED, function(T) 
      --print("\n\tSTA - DISCONNECTED".."\n\tSSID: "..T.SSID.."\n\tBSSID: "..
      --T.BSSID.."\n\treason: "..T.reason)
      --lcd.setPic("wifiState",4)
      --end)
     
      wifi.eventmon.register(wifi.eventmon.STA_GOT_IP, function(T) 
      --print("\n\tSTA - GOT IP".."\n\tStation IP: "..T.IP.."\n\tSubnet mask: "..
      --T.netmask.."\n\tGateway IP: "..T.gateway)
      --lcd.setPic("wifiState",5)


     if(file.open("qrcode.txt") == nil) then
          pms.disablePMS()
          collectgarbage()
          print(node.heap())
          lcd.showPage(2)
          lcd.setText("info","获取二维码...") 
          --netReq("/api/v1/sn/info/",1)
          http.get("http://www.lewei50.com/api/v1/sn/info/"..string.upper(string.gsub(wifi.sta.getmac(), ":", "")).."?encode=gbk", nil, function(code, data)
              if (code < 0) then
                print("HTTP request failed")
                
               require("keyDetector")
               keyDetector.enableTrig()
               --lcd.setPic("wifiState",5)
               --lcd.setWifiState(5)
               --tmr.delay(500000)
               pms.enablePMS()
               
              else
                --print(code, data)
                if(string.find(data,"Invalid SN")~=nil) then
                    lcd.setText("info","无效二维码")
                    require("keyDetector")
                    keyDetector.enableTrig()
                    --lcd.setPic("wifiState",5)
                    --lcd.setWifiState(5)
                    --tmr.delay(200000)
                    pms.enablePMS()
               else
                d = string.sub(string.match(data,"\"%d+\""),2,-2)
                    lcd.setText("info","校验二维码..")
                    fsize=string.len(d)
                    if(math.floor(math.sqrt(fsize))== math.sqrt(fsize))then
                         --print(endPos)
                         --t= cjson.decode(fbStr)
                         --for k,v in pairs(t) do print(k,v) end
                         fbStr = nil
                         file.open("qrcode.txt", "w")
                         lcd.setText("info","保存二维码.")
                         -- write 'foo bar' to the end of the file
                         file.writeline(d)
                         file.close()
                         file.remove("network_user_cfg.lua")
                         sk = nil
                         
                         --
                         lcd.setText("info","获取成功.")
                         --
                    else
                         lcd.setText("info","校验失败")
                    end
                    require("Reset")
                  end
              end
          end)
     else
          --qrcode file had already downloaded:用户端逻辑
          --if(displayQRCode ==1) then
          --     require("qrCode")
          --     qrCode.qrCodeDisp()
          --     lcd.setText("info",string.upper(string.gsub(wifi.sta.getmac(), ":", "")))
          --else
          --netReq("/api/v1/device/getbysn/",2)
          print("http://www.lewei50.com/api/v1/device/getbysn/"..string.upper(string.gsub(wifi.sta.getmac(), ":", "")).."?encode=gbk")
          http.get("http://www.lewei50.com/api/v1/device/getbysn/"..string.upper(string.gsub(wifi.sta.getmac(), ":", "")).."?encode=gbk", nil, function(code, data)
               if (code < 0) then
                print("HTTP request failed")
                
               require("keyDetector")
               keyDetector.enableTrig()
               --lcd.setPic("wifiState",5)
               --lcd.setWifiState(5)
               --tmr.delay(500000)
               pms.enablePMS()
               
               else
                    if(string.find(data,"Invalid device ID")~=nil) then
                         --wifi not set,but have qrcode file
                         print("fail")
                         require("qrCode")
                         qrCode.qrCodeDisp()
                         lcd.setText("info","绑定设备后,长按按键3秒配置网络")
                    else
                         print("ok")
                         --print(string.match(fbStr,"\"name\":\".+\"typeName\":\"lw%-board"))
                         dName = string.sub(string.match(data,"\"name\":\".+\"typeName\":\"lw%-board"),9,-23)
                         --print(dName)
                         lcd.showPage(1)
                         lcd.setText("info","")
                         if(dName ~= nil) then
                              lcd.setText("deviceName",dName)
                              lcd.setDName(dName)
                         end
                         require("keyDetector")
                         keyDetector.enableTrig()
                         --lcd.setPic("wifiState",5)
                         --lcd.setWifiState(5)
                         --tmr.delay(500000)
                         pms.enablePMS()
                    end
               end
          end)
          --lcd.setText("info","检查绑定状态...") 
          --end
     end

      
      end)

     wifi.sta.connect()    
end   
--end)

--[[
local status = false
tmr.alarm(4, 20000, 1, function()
     if(status==true) then 
          print("disable pms")
          --gpio.write(2,gpio.LOW)
          pms.disablePMS()
          status = false
          connect()
     else 
          print("enable pms")
          --gpio.write(2,gpio.HIGH)
          pms.enablePMS()
          status = true
     end
end)
]]--
if(file.open('network_user_cfg.lua')) then
     dofile('network_user_cfg.lua')
     connect()
end

keyDetector.enableTrig()
pms.enablePMS()

tmr.alarm(1, 1000, 1, function()
     collectgarbage()
     if (wifi.sta.status()==3 or wifi.sta.status()==2 or wifi.sta.status()==4) then--fail
          lcd.setPic("wifiState",4)
     elseif(wifi.sta.status()==5 or wifi.sta.status()==0) then
          lcd.setPic("wifiState",5)
     else
          lcd.setPic("wifiState",6)
     end
     --lcd.setText("info",node.heap())
     --print("RAM:"..node.heap())
end)


tmr.alarm(2, 20000, 1, function()
     --print(node.heap())
     --for k, v in pairs(_G) do 
     --print(k) 
     --end
     collectgarbage()
     if(pms~=nil) then
          aqi,pm25,Temp,Hum,hcho = pms.getCurrentValue()
          if(wifi.sta.status()==5 and aqi ~=nil and pm25~=nil and Temp ~=nil and Hum ~=nil) then
               LeweiHttpClient.appendSensorValue("AQI",aqi)
               LeweiHttpClient.appendSensorValue("dust",pm25)
               LeweiHttpClient.appendSensorValue("T1",Temp)
               if(hcho~=nil)then
                    LeweiHttpClient.appendSensorValue("hcho",hcho)
               end
               LeweiHttpClient.sendSensorValue("H1",Hum)
          end
     end
end)
