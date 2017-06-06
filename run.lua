wifiSet = true
binded = false
_G["sn"] = string.upper(string.gsub(wifi.sta.getmac(), ":", ""))

function netReq(url,rqType)
     sk=net.createConnection(net.TCP, 0)
     serverName = "www.lewei50.com"
     local serverIP
     if(serverIP == nil) then
          sk:dns(serverName, function(conn, ip)
               if(ip==nil) then 
               print("not found")
               else
                    serverIP = ip

               
                    --print(serverIP)
                    if(serverIP~=nil) then
                    
                    sk:connect(80,serverIP)
                    sk:on("connection", function(sck,c)
                    -- Wait for connection before sending.
                    --print("request:"..serverName..url.._G["sn"])
                    sk:send("GET "..url.._G["sn"].."?encode=gbk HTTP/1.1\r\nHost: "..serverName.."\r\nAccept: */*\r\n\r\nContent-Length: 0 \r\n")
                    end)
                    
                    end
               end
               end)     
          end
     
     fbStr = ""
     
     sk:on("receive", function(sck, c)
     fbStr = fbStr .. c
     --print("--")
     --print(c)
     --print("!!")
     end )
     
     sk:on("disconnection",function(c) 
     if(fbStr ~= "") then
          if(rqType == 1) then
               --print(fbStr)
               if(string.find(fbStr,"Invalid SN")~=nil) then
                    lcd.setText("info","无效二维码")
                    require("keyDetector")
                    keyDetector.enableTrig()
                    lcd.setPic("wifiState",5)
                    lcd.setWifiState(5)
                    tmr.delay(200000)
                    pms.enablePMS()
               else
                    fbStr = string.gsub(string.gsub(fbStr, "\n", ""), "\r", "")
                    d = string.sub(string.match(fbStr,"\"%d+\""),2,-2)
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
                    --node.restart()
                    require("Reset")
               end
          else
               if(string.find(fbStr,"Invalid device ID")~=nil) then
                    --wifi not set,but have qrcode file
                    print("fail")
                    require("qrCode")
                    qrCode.qrCodeDisp()
                    lcd.setText("info","绑定设备后,长按按键3秒配置网络")
               else
                    print("ok")
                    --print(string.match(fbStr,"\"name\":\".+\"typeName\":\"lw%-board"))
                    dName = string.sub(string.match(fbStr,"\"name\":\".+\"typeName\":\"lw%-board"),9,-23)
                    --print(dName)
                    lcd.showPage(1)
                    lcd.setText("info","")
                    if(dName ~= nil) then
                         lcd.setText("deviceName",dName)
                         lcd.setDName(dName)
                    end
                    require("keyDetector")
                    keyDetector.enableTrig()
                    lcd.setPic("wifiState",5)
                    lcd.setWifiState(5)
                    tmr.delay(500000)
                    pms.enablePMS()
               end
          end
     end
     fbStr = nil
     end)
end
--qrcode haven't downloaded//工厂端逻辑
if(file.open("qrcode.txt") == nil) then
     lcd.showPage(2)
     lcd.setText("info","获取二维码...") 
     netReq("/api/v1/sn/info/",1)
else
--qrcode file had already downloaded:用户端逻辑
     --if(displayQRCode ==1) then
     --     require("qrCode")
     --     qrCode.qrCodeDisp()
     --     lcd.setText("info",string.upper(string.gsub(wifi.sta.getmac(), ":", "")))
     --else
     netReq("/api/v1/device/getbysn/",2)
     lcd.setText("info","检查绑定状态...") 
     tmr.alarm(1, 10000, 0, function()
          sk = nil
          require("keyDetector")
          keyDetector.enableTrig()
          lcd.setPic("wifiState",6)
          lcd.setWifiState(6)
          --tmr.delay(300000)
          --pms.enablePMS()
          tmr.alarm(2, 20000, 0, function()
               pms.enablePMS()
               --netReq("/api/v1/device/getbysn/",2)
          end)
     end)
     --[[
          tmr.alarm(1, 1000, 0, function()
               require("pms")
               lcd.showPage(1)
               lcd.setText("info","")
               pms.enablePMS()
          end)
     ]]--
     --end
end
