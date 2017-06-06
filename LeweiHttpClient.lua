--------------------------------------------------------------------------------
-- LeweiHttpClient module for NODEMCU
-- LICENCE: http://opensource.org/licenses/MIT
-- yangbo<gyangbo@gmail.com>
--------------------------------------------------------------------------------

--[[
here is the demo.lua:

require("LeweiHttpClient")
LeweiHttpClient.init("01","your_api_key")
tmr.alarm(0, 60000, 1, function()
--添加数据，等待上传
LeweiHttpClient.appendSensorValue("sensor1","1")
--实际发送数据
LeweiHttpClient.sendSensorValue("sensor2","3")
end)
--]]

local moduleName = ...
local M = {}
_G[moduleName] = M
local serverName ="dust.lewei50.com"
local serverIP

local gateWay
local userKey
local sn
local sensorValueTable
local apiUrl = ""
local apiLogUrl = ""
local socket = nil
local bReady = false

function M.init()
     apiUrl = "UpdateSensorsBySN/"..string.upper(string.gsub(wifi.sta.getmac(), ":", ""))
     sensorValueTable = {}
     print(apiUrl)
end

function M.appendSensorValue(sname,svalue)
     sensorValueTable[""..sname]=""..svalue
end

function M.isReady()
     return bReady
end

function M.sendSensorValue(sname,svalue)
     PostData = "["
               for i,v in pairs(sensorValueTable) do 
                    PostData = PostData .. "{\"Name\":\""..i.."\",\"Value\":\"" .. v .. "\"}," 
               end
               PostData = PostData .."{\"Name\":\""..sname.."\",\"Value\":\"" .. svalue .. "\"}"
               PostData = PostData .. "]"
               --HTTP请求头定义
     http.post("http://"..serverName.."/api/V1/gateway/"..apiUrl,
       'Content-Type: text/plain\r\n',
       PostData,
       function(code, data)
         if (code < 0) then
           print("HTTP request failed")
         else
           print(code, data)
         end
         PostData = nil
       end)
end

