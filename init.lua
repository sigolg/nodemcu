-- 4F unicorn info
client_ip="172.30.1.101"     -- 101부터 순차적으로 사용

function startup()
    if file.open("init.lua") == nil then
        print("init.lua deleted or renamed")
    else
        print("Wifi Connected")
        print("")
        file.close("init.lua")
        -- the actual application is stored in 'application.lua'
        dofile("dht22_mqtt.lua")
    end
end
 
print("Connecting to WiFi access point...")
wifi.setmode(wifi.STATION)
wifi.setphymode(wifi.PHYMODE_N)
wifi.sta.config("unicorn_00", "00000034a1")
wifi.sta.connect()
if client_ip ~= "" then
    wifi.sta.setip({ip=client_ip,netmask="255.255.255.0",gateway="172.30.1.254"})
end

tmr.alarm(1, 1000, 1, function()
    if wifi.sta.status() ~= 1 then
        print("Waiting for IP address...")
        wifi.sta.connect()
    else
        tmr.stop(1)
        print("WiFi connection established, IP address: " .. wifi.sta.getip())
        wifi.sta.getip()
        print("Waiting...")
        tmr.alarm(0, 3000, 0, startup)
    end
end)
