local moduleName = ...
local M = {}
_G[moduleName] = M


function drawRec(startPos,endPos,size,bFill)
     startPosX = 45--37
     startPosY = 41--33
     if(bFill=="0") then
     uart.write(0,"fill "..startPos*size+startPosX..","..endPos*size+startPosY..","..size..","..size..",WHITE"..string.char(255)..string.char(255)..string.char(255))
     end
end


function M.qrCodeDisp()
     print(node.heap())
     require("keyDetector")
     keyDetector.disableTrig()
     qrFileName = "qrcode.txt"
     lcd.showPage(2)
     l = file.list();
     lcd.setDrawing(true)
     for k,v in pairs(l) do
          --print("name:"..k..", size:"..v)
          if(k==qrFileName) then
               l = nil
               --uart.write(0,"bauds=115200"..string.char(255)..string.char(255)..string.char(255))
               --tmr.delay(2000)
               --uart.setup( 0, 115200, 8, 0, 1, 0 )
               level = math.sqrt(v-1)
               file.open(qrFileName, "r")
               qrFileName = nil
               row = 0
               uart.write(0,"fill 33,29,170,170,BLACK"..string.char(255)..string.char(255)..string.char(255))
               uart.write(0,"fill 33,29,170,170,BLACK"..string.char(255)..string.char(255)..string.char(255))
               
               while(row < level)
                    do
                         collectgarbage()
                         rowStr = file.read(level)
                         --if(row == 0) then
                              --print(rowStr)
                              col = 0
                              while (col < level)
                                   do
                                        --print(string.sub(rowStr,col,col))
                                        drawRec(col,row,5,string.sub(rowStr,col+1,col+1))
                                        col = col + 1
                                        tmr.delay(2000)
                                        --tmr.wdclr()
                                        require("WatchDog")
                                   end
                         --end
                    row = row + 1
                    end
               file.close()
               --uart.write(0,"bauds=9600"..string.char(255)..string.char(255)..string.char(255))
               --uart.setup( 0, 9600, 8, 0, 1, 0 )
          end
     end
     print(node.heap())
     lcd.setDrawing(false)
     keyDetector.enableTrig()
end
