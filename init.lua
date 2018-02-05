
SIGNALMODE = wifi.PHYMODE_N
-- 4F unicorn info
SSID="sigolCouple"
PASSWORD="96239623"
--client_ip="172.30.1.101"     -- 101부터 순차적으로 사용
--client_netmask="255.255.255.0"
--client_gateway="172.30.1.254"
-- 6F egg info
--SSID="ktEgg_095"
--PASSWORD="moda29379"
--client_ip="192.168.1.101"    -- 101부터 순차적으로 사용 
--client_netmask="255.255.255.0"
--client_gateway="192.168.1.1"
client_ip=""
client_netmask=""
client_gateway=""

function startup()
    if file.open("init.lua") == nil then
        print("init.lua deleted or renamed")
    else
        print("Wifi Connected")
        print("")
        print("")
        file.close("init.lua")
        -- the actual application is stored in 'application.lua'
        dofile("dht22_mqtt.lua")
    end
end
 
print("Connecting to WiFi access point...")
wifi.setmode(wifi.STATION)
--wifi.setphymode(SIGNALMODE)
wifi.sta.config(SSID, PASSWORD)
wifi.sta.connect()
if client_ip ~= "" then
    wifi.sta.setip({ip=client_ip,netmask=client_netmask,gateway=client_gateway})
end

tmr.alarm(1, 1000, 1, function()
    if wifi.sta.getip() == nil then
        print("Waiting for IP address...")
    else
        tmr.stop(1)
        print("WiFi connection established, IP address: " .. wifi.sta.getip())
        wifi.sta.getip()
        print("Waiting...")
        tmr.alarm(0, 5000, 0, startup)
    end
end)
