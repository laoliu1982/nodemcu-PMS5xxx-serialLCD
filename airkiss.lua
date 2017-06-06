local moduleName = ...
local M = {}
_G[moduleName] = M

function M.setupAirKiss()
     tmr.stop(1)
     print("\ntimer stopped")
     print("start airkissing")
     wifi.setmode(wifi.STATION)
     wifi.startsmart(1,function(ssid, password) 
          lcd.setText("info","正在配置网络...")
          file.open("network_user_cfg.lua","w")
          file.writeline("wifi.sta.config(\""..ssid.."\", \""..password.."\")")
          file.close()
          lcd.setText("info","配置成功，准备重启.")
          print(string.format("Success. SSID:%s ; PASSWORD:%s", ssid, password))
          --pms.disablePMS()
          tmr.alarm(1, 15000, 0, function()
          --print("restart")
          --node.restart()
          require("Reset")
          end)
          --tmr.delay(2000000)
        end
     )
     print("\n\rAirKissing")
     collectgarbage();
     print(node.heap())
     lcd.showPage(3)
end
