-- 4F unicorn info
client_ip="172.30.1.102"         -- 101부터 순차적으로 사용

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
if client_ip ~= "" then
    wifi.sta.setip({ip=client_ip,netmask="255.255.255.0",gateway="172.30.1.254"})
end
wifi.sta.connect()

i = 1
tmr.alarm(1, 1000, 1, function()
    if wifi.sta.getrssi() == nil then
        if i == 30 then
            print("Going to deep sleep for 300 seconds")
            node.dsleep(25*1000*1000)
        end
        print("Waiting for IP address...")
        i = i + 1
    else
        tmr.stop(1)
        print("WiFi connection established, IP address: " .. wifi.sta.getip())
        print("Waiting...")
        tmr.alarm(0, 1000, 0, startup)
    end
end)
