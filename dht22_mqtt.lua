pin = 5 -- dht11 signal pin
temp = 25
humi = 25
channelID = "409502"
mqttKey = "PJLICMGSC03XH81M"
writeKey = "WKMTV2VSMBR2XU7P"
time_between_sensor_readings = 10*1000*1000 --60000 means 60sec

--- MQTT ---
mqtt_broker_ip = "mqtt.thingspeak.com"     
mqtt_broker_port = 1883

m = mqtt.Client(channelID, 120)

--tmr.alarm(1,20000,1,function()readDHT()sendData(temp,humi)end)
--tmr.alarm(0,100,1,function()readDHT()sendData(temp,humi)end)
 
--read DHT11 temp, humi data function
function readDHT()
    DHT=require("dht22_min")
    DHT.read(pin)
    temp = DHT.getTemperature()
    humi = DHT.getHumidity()
    if humi == nil then
        print("Error reading from DHT22")
    else
        print("Temperature: "..(temp / 10).."."..(temp % 10).." deg C")
        print("Humidity: "..(humi / 10).."."..(humi % 10).."%")
    end
    DHT = nil
    package.loaded["dht22_min"]=nil
end

--send data to thingspeak
function sendData(temp,humi)
    -- conection to thingspeak.com
    print("Sending data to thingspeak.com")
    m:connect( mqtt_broker_ip , mqtt_broker_port, 0, function(client)
        print("Connected to MQTT")
        print("  IP: ".. mqtt_broker_ip)
        print("  Port: ".. mqtt_broker_port)
        client:publish("channels/"..channelID.."/publish/"..writeKey,"field5="..(temp / 10).."."..(temp % 10).."&field6="..(humi / 10).."."..(humi % 10),0,0)
        --print("Going to deep sleep for "..(time_between_sensor_readings/1000000).." seconds")
        --node.dsleep(time_between_sensor_readings)      
    end,
    function(client, reason)
        print("failed reason: " .. reason)
    end)
end

readDHT()
sendData(temp,humi)  
