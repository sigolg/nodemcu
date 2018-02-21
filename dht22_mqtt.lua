pin = 5 -- dht11 signal pin
channelID = ""
writeKey = ""
time_between_sensor_readings = 20*1000*1000 --60000 means 60sec

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
    if temp == -999 then
        print("Going to deep sleep for 10 seconds")
        node.dsleep(10*1000*1000)
    else
        -- conection to thingspeak.com
        print("Sending data to thingspeak.com")
        m:connect( "mqtt.thingspeak.com" , 1883, 0, 0, function(client)
            print("Connected to MQTT")
            print("  IP: mqtt.thingspeak.com")
            print("  Port: 1883")
            client:publish("channels/"..channelID.."/publish/"..writeKey,"field1="..temp.."&field2="..humi,0,0,function(client)
                client:close()
                print("Going to stay for "..(time_between_sensor_readings/1000000).." seconds")  
            end)
        end,
        function(client, reason)
            print("failed reason: " .. reason)
            print("Going to deep sleep for 10 seconds")
            node.dsleep(10*1000*1000) 
        end)
    )
end

readDHT()
sendData(temp,humi)  
tmr.alarm(1,time_between_sensor_readings/1000,1,function() readDHT()sendData(temp,humi) end)
