require("LeweiHttpClient")
LeweiHttpClient.init()

local moduleName = ...
local M = {}
_G[moduleName] = M


local enablePMSPin = 2
gpio.mode(enablePMSPin,gpio.OUTPUT)
local pm25
local Temp
local Hum
local aqi
local bFirstData
local sendCount
local hbState = false

function calcAQI(pNum)
     --local clow = {0,15.5,40.5,65.5,150.5,250.5,350.5}
     --local chigh = {15.4,40.4,65.4,150.4,250.4,350.4,500.4}
     --local ilow = {0,51,101,151,201,301,401}
     --local ihigh = {50,100,150,200,300,400,500}
     local ipm25 = {0,35,75,115,150,250,350,500}
     local laqi = {0,50,100,150,200,300,400,500}
     local result={"优","良","轻度污染","中度污染","重度污染","严重污染","爆表"}
     --print(table.getn(chigh))
     aqiLevel = 8
     for i = 1,table.getn(ipm25),1 do
          if(pNum<ipm25[i])then
               aqiLevel = i
               break
          end
     end
     --aqiNum = (ihigh[aqiLevel]-ilow[aqiLevel])/(chigh[aqiLevel]-clow[aqiLevel])*(pNum-clow[aqiLevel])+ilow[aqiLevel]
     aqiNum = (laqi[aqiLevel]-laqi[aqiLevel-1])/(ipm25[aqiLevel]-ipm25[aqiLevel-1])*(pNum-ipm25[aqiLevel-1])+laqi[aqiLevel-1]
     return math.floor(aqiNum),result[aqiLevel-1]
end

function M.enablePMS()
     tmr.delay(100000)
     gpio.write(enablePMSPin,gpio.HIGH)
     qrCode = nil
     bFirstData = true
     sendCount  = 0
     package.loaded["qrCode"]=nil
     --network_user_cfg = nil
     --package.loaded["network_user_cfg"]=nil
     airkiss = nil
     package.loaded["airkiss"]=nil
     uart.setup( 0, 9600, 8, 0, 1, 0 )
     bIsPms5003s = false
     bShowPms5003sPage = false
     uart.on("data", "B", 
      function(data)
          if(string.find(data,"quit")~=nil) then
               M.disablePMS()
          end
          if((string.byte(data,1)==0x4d) and string.byte(data,12)~=nil and string.byte(data,13)~=nil)  then
               pm25 = (string.byte(data,12)*256+string.byte(data,13))
               if(string.byte(data,28) ~=nil and string.byte(data,29)~=nil)then
                    if(string.byte(data,28) == 0x71)then
                         hcho = nil
                    else
                         bIsPms5003s = true
                         if(bIsPms5003s==true and bShowPms5003sPage==false)then 
                              lcd.showPage(4)
                              lcd.setPic("wifiState",lcd.getWifiState())
                              lcd.setText("deviceName",lcd.getDName())
                              --print(lcd.getWifiState())
                              bShowPms5003sPage = true
                         end
                         hcho = (string.byte(data,28)*256+string.byte(data,29))/1000
                    end
               end
               aqi,result = calcAQI(pm25)
               aqiLevel = math.floor(pm25/5)
               if(aqiLevel > 100) then aqiLevel = 100 end
               local si7021 = require("si7021")
               
               SDA_PIN = 5 -- sda pin, GPIO12
               SCL_PIN = 6 -- scl pin, GPIO14
     
               si7021.init(SDA_PIN, SCL_PIN)
               si7021.read(OSS)
               Hum = si7021.getHumidity()
               Temp = si7021.getTemperature() -3
               --socket:send(pm25..'\n\r')  
               --uart.setup( 0, 115200, 8, 0, 1, 0 )
               lcd.setText("pm25",pm25..result)
               lcd.setText("aqi",aqi)
               lcd.setText("temp",math.ceil(Temp).."℃")
               lcd.setText("hum",math.ceil(Hum).."%")
               if(hcho~=nil)then
                    lcd.setText("HCHO",string.format("%.2f",hcho).."mg/m3")
               end
               lcd.setNumber("level",aqiLevel)

               --[[
               if(bFirstData == true) then
                    if(aqi ~=nil and pm25~=nil and Temp ~=nil and Hum ~=nil) then
                         LeweiHttpClient.appendSensorValue("AQI",aqi)
                         LeweiHttpClient.appendSensorValue("dust",pm25)
                         LeweiHttpClient.appendSensorValue("T1",Temp)
                         if(hcho~=nil)then
                              LeweiHttpClient.appendSensorValue("hcho",hcho)
                         end
                         LeweiHttpClient.sendSensorValue("H1",Hum)
                         bFirstData = false
                         --tmr.delay(50000)
                    end
               end
               ]]--
               print("")
               --uart.write(0,"pm25.val="..pm25..string.char(255)..string.char(255)..string.char(255))
               --tmr.delay(2000)
               --uart.write(0,"temp.val="..math.ceil(Temp)..string.char(255)..string.char(255)..string.char(255))
               --tmr.delay(2000)
               --uart.write(0,"hum.val="..math.ceil(Hum)..string.char(255)..string.char(255)..string.char(255))
               
               -- release module
               si7021 = nil
               _G["si7021"]=nil
               package.loaded["si7021"]=nil
               --tmr.softwd(60)
               require("WatchDog")
               if(hbState) then
                    lcd.setText("info",".")
                    hbState = false
               else
                    lcd.setText("info","")
                    hbState = true
               end
          end
     end, 0)
     --[[
     --print(_G["sn"])
     if(file.open("network_user_cfg.lua") ~= nil) then
          --lcd.setText("info","")
          if(wifi.sta.getip()~=nil)then
          lcd.showPage(1)
          print("network ready!")
          tmr.alarm(1, 120000, 1, function()
               --print(node.heap())
               --for k, v in pairs(_G) do 
               --print(k) 
               --end
               collectgarbage()
               if(aqi ~=nil and pm25~=nil and Temp ~=nil and Hum ~=nil) then
                    LeweiHttpClient.appendSensorValue("AQI",aqi)
                    LeweiHttpClient.appendSensorValue("dust",pm25)
                    LeweiHttpClient.appendSensorValue("T1",Temp)
                    if(hcho~=nil)then
                         LeweiHttpClient.appendSensorValue("hcho",hcho)
                    end
                    LeweiHttpClient.sendSensorValue("H1",Hum)
                    print("count:"..sendCount)
                    sendCount = sendCount + 1
               end
          end)
          end
     end
     ]]--
end

function M.getCurrentValue()
     local _aqi,_pm25,_Temp,_Hum,_hcho
     _aqi = aqi
     _pm25 = pm25
     _Temp = Temp
     _Hum = Hum
     _hcho = hcho
     aqi = nil
     pm25 = nil
     Temp = nil
     Hum =nil
     hcho = nil
     return _aqi,_pm25,_Temp,_Hum,_hcho
end

function M.disablePMS()
     gpio.write(enablePMSPin,gpio.LOW)
     uart.setup( 0, 9600, 8, 0, 1, 0 )
     uart.on("data")
     --tmr.softwd(600)
     require("WatchDog")
end

return M
