pin = 5 -- dht11 signal pin
channelID = "409502"
writeKey = "WKMTV2VSMBR2XU7P"
time_between_sensor_readings = 10*1000*1000 --60000 means 60sec

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
    -- conection to thingspeak.com
    print("Sending data to thingspeak.com")
    m:connect( "mqtt.thingspeak.com" , 1883, 0, function(client)
        print("Connected to MQTT")
        print("  IP: mqtt.thingspeak.com")
        print("  Port: 1883")
        client:publish("channels/"..channelID.."/publish/"..writeKey,"field1="..temp.."&field2="..humi,0,0,function(client)
            print("Going to deep sleep for "..(time_between_sensor_readings/1000000).." seconds")
            node.dsleep(time_between_sensor_readings)    
        end)
    end)
end

readDHT()
sendData(temp,humi)  
