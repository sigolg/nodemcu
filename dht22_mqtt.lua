pin = 5 -- dht11 signal pin
channelID = ""
writeKey = ""
time_between_sensor_readings = 180*1000*1000 --60000 means 60sec
suspend_state=0

--- MQTT ---
m = mqtt.Client(channelID, 120)

--read DHT11 temp, humi data function
function readDHT()
    status, temp, humi = dht.read(pin)
    if status == dht.OK then
        print("Temperature: "..temp.."C")
        print("Humidity: "..humi.."%")
    elseif status == dht.ERROR_CHECKSUM then
        print( "DHT Checksum error." )
    elseif status == dht.ERROR_TIMEOUT then
        print( "DHT timed out." )
    end
    dht = nil
end

--send data to thingspeak
function sendData(temp,humi)
    if humi == -999 then
        print("Going to light sleep for "..(time_between_sensor_readings/1000000).." seconds")
        node.dsleep(time_between_sensor_readings)
    else
        -- conection to thingspeak.com
        print("Sending data to thingspeak.com")
        -- if suspend_state ~= 0 then
        -- wifi.resume()
        -- end
        m:connect( "mqtt.thingspeak.com" , 1883, 0, function(client)
            print("Connected to MQTT")
            print("  IP: mqtt.thingspeak.com")
            print("  Port:  1883")
            client:publish("channels/"..channelID.."/publish/"..writeKey,"field1="..temp.."&field2="..humi, 0,0,function(client)
                client:close()
                print("Going to deep sleep for "..(time_between_sensor_readings/1000000).." seconds")
                node.dsleep(time_between_sensor_readings)
            -- cfg={}
            -- cfg.duration=time_between_sensor_readings
            -- cfg.resume_cb=function() print("WiFi resume") end
            -- cfg.suspend_cb=function() print("WiFi suspended") end
            --suspend_state=wifi.suspend(cfg)
            end)
        end,
        function(client, reason)
            print("failed reason: " .. reason)
            print("Going to deep sleep for 60 seconds")
            node.dsleep(60*1000*1000)
        end)
    end
end

readDHT()
sendData(temp,humi)  
--tmr.alarm(1,60000,1,function()readDHT()sendData(temp,humi) end)

