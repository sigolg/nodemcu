pin = 5 -- dht11 signal pin
channelID = "426751"
writeKey = "XDGPU512PKQSQMW2"
time_between_sensor_readings = 60*1000*1000 --60000 means 60sec

--- MQTT ---
m = mqtt.Client(channelID, 120)
 
--read DHT11 temp, humi data function
function readDHT()
    status, temp, humi = dht.read(pin)
    if status == dht.OK then
        print("Temp: "..temp.."C")
        print("Humi: "..humi.."%")
    elseif status == dht.ERROR_CHECKSUM then
        print( "DHT Checksum error." )
    elseif status == dht.ERROR_TIMEOUT then
        print( "DHT timed out." )
    end
    dht = nil
end

--send data to thingspeak
function sendData(temp,humi)
    -- conection to thingspeak.com
    print("Sending data to thingspeak.com")
    m:connect( "mqtt.thingspeak.com" , 1883, 0, function(client)
        print("Connected to MQTT")
        print("  IP: mqtt.thingspeak.com")
        print("  Port: 1883")
        client:publish("channels/"..channelID.."/publish/"..writeKey,"field3="..temp.."&field4="..humi,0,0,function(client)
            client:close()
            print("Going to deep sleep for "..(time_between_sensor_readings/1000000).." seconds")
            node.dsleep(time_between_sensor_readings)
        end)
    end,
    function(client, reason)
            print("failed reason: " .. reason)
            print("Going to deep sleep for 60 seconds")
            node.dsleep(60*1000*1000)
    end)
end

readDHT()
sendData(temp,humi)  
