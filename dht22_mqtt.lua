pin = 5 -- dht11 signal pin

channelID = "430964"
writeKey = "BZFXP8EBCU6Q8B9K"
time_between_sensor_readings = 25*1000*1000 --25 means 25sec

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
        print("Going to deep sleep for "..(time_between_sensor_readings/1000000).." seconds")
        node.dsleep(time_between_sensor_readings)
    elseif status == dht.ERROR_TIMEOUT then
        print( "DHT timed out." )
        print("Going to deep sleep for "..(time_between_sensor_readings/1000000).." seconds")
        node.dsleep(time_between_sensor_readings)
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
            print("Going to stay for "..(time_between_sensor_readings/1000000).." seconds")
            
        end)
    end,
    function(client, reason)
            print("failed reason: " .. reason)
            print("Going to deep sleep for "..(time_between_sensor_readings/1000000).." seconds")
            node.dsleep(time_between_sensor_readings)
    end)
end

readDHT()
sendData(temp,humi)
tmr.alarm(1,time_between_sensor_readings/1000000,1,function() readDHT()sendData(temp,humi)end)
