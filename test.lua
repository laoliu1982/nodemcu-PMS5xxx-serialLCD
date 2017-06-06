tmr.softwd(600)
require("pms")
--require("qrCode")
require("lcd")
--dofile("qrCodeCfg.cfg")

wifiSet = false

lcd.showPage(0)
tmr.delay(100000)
--require("pms")
pms.disablePMS()
--pms = nil
--displayQRCode = 1

--already set wifi
if( file.open("network_user_cfg.lua") ~= nil) then
     ssid=""
     password=""
     require("network_user_cfg")
     wifi.setmode(wifi.STATION)
     wifi.sta.autoconnect(1)
     --please config ssid and password according to settings of your wireless router.
     wifi.sta.config(ssid,password)
     wifi.sta.connect()
     cnt = 0
     tmr.alarm(1, 1000, 1, function()
          print(cnt)
          if (wifi.sta.getip() == nil) and (cnt < 10) then
               --print(".")
               lcd.setText("info","连接网络"..string.rep(".", cnt%3))
               cnt = cnt + 1
          else
               tmr.stop(1)
               if (cnt < 10) then print("IP:"..wifi.sta.getip())
                         --pms.disablePMS()
                         require("keyDetector")
                         keyDetector.enableTrig()
                         dofile("run.lc")
               else print("FailToConnect,LoadDefault")
                    wifi.sta.disconnect()
                    --lcd.setText("info","联网失败，重启或长按3秒用微信配置网络")
                    --setupAirKiss()
                    lcd.showPage(1)
                    lcd.setPic("wifiState",4)
                    tmr.delay(200000)
                    pms.enablePMS()
                    require("keyDetector")
                    keyDetector.enableTrig()
               end
          end
     end)
else
--wifi not set
     if(file.open("qrcode.txt") == nil) then
          --正常这里不应该进入
          require("airkiss")
          print("nothing found")
          airkiss.setupAirKiss()
     else
          --wifi not set,but have qrcode file
          --require("qrCode")
          --qrCode.qrCodeDisp()
          --lcd.setText("info","微信扫一扫")
          lcd.showPage(1)
          lcd.setPic("wifiState",4)
          tmr.delay(20000)
          pms.enablePMS()
     end
     require("keyDetector")
     keyDetector.enableTrig()
end

tmr.alarm(2, 2000, 1, function()
     print("RAM:"..node.heap())
end)
