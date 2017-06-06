local moduleName = ...
local M = {}
_G[moduleName] = M

local currentPage = 0
local bDrawing = false
local dName = ""
local wifiState=4

function M.setDName(dname)
     dName = dname
end

function M.getDName()
     return dName
end

function M.setWifiState(state)
     wifiState = state
end

function M.getWifiState()
     return wifiState
end
function sentData(data)
     uart.write(0,data..string.char(255)..string.char(255)..string.char(255))
     tmr.delay(200)
     uart.write(0,data..string.char(255)..string.char(255)..string.char(255))
     tmr.delay(200)
end

function M.showPage(pid)
     sentData("page "..pid)
     currentPage= pid
end

function M.setText(textName,txt)
     sentData(textName..".txt=\""..txt.."\"")
end

function M.setNumber(numName,num)
     sentData(numName..".val="..num)
end

function M.setPic(numName,num)
     sentData(numName..".pic="..num)
end

function M.crtPage()
     return currentPage
end

function M.setDrawing(state)
     bDrawing = state
end

function M.isDrawing()
     return bDrawing
end
