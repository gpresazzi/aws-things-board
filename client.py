import time
import json
import subprocess
import threading
import paho.mqtt.client as mqtt

access_token = "hs10012345"
plug_status = { "status": "off" }

def read_hs100_value():
    result = subprocess.run(['/home/pi/hs100/hs100/hs100.sh', '-i', '192.168.1.104', 'check'], stdout=subprocess.PIPE)
    str_res = str(result.stdout)
    print("hs100 result: {}".format(str_res))
    status = "on" if "ON" in str_res else "off"
    plug_status["status"] = status
    return plug_status


# The callback for when the client receives a CONNACK response from the server.
def on_connect(client, userdata, flags, rc):
    print("Connected with result code "+str(rc))

    # Subscribing in on_connect() means that if we lose the connection and
    # reconnect then subscriptions will be renewed.
    client.subscribe("v1/devices/me/telemetry")
    client.subscribe("v1/devices/me/rpc/request/+")


# The callback for when a PUBLISH message is received from the server.
def on_message(client, userdata, msg):
    import json
    obj = json.loads(msg.payload)
    print(msg.topic + " - " + str(msg.payload))
    if "method" not in obj:
        return

    if obj["method"] == "setValue" and obj["params"] == True:
        print("Plug on")
        result = subprocess.run(['/home/pi/hs100/hs100/hs100.sh', '-i', '192.168.1.104', 'on'], stdout=subprocess.PIPE)
    elif obj["method"] == "setValue" and obj["params"] == False:
        print("Plug off")
        result = subprocess.run(['/home/pi/hs100/hs100/hs100.sh', '-i', '192.168.1.104', 'off'], stdout=subprocess.PIPE)
    elif obj["method"] == "getValue":
        print("Read value")
        status = read_hs100_value()
        payload=json.dumps(status)
        res = client.publish(msg.topic.replace('request', 'response'), payload, 1)
        print(msg.topic.replace('request', 'response') + ' - ' + payload)
        client.publish('v1/devices/me/attributes', "{\"initial_status\":\"" +  global_status["status"] + "\"}")
        print("Publishing attributes:" +  "{\"initial_status\":\"" +  global_status["status"] + "\"}")
    else:
        print("Command unknown")

client = mqtt.Client()
client.on_connect = on_connect
client.on_message = on_message

client.username_pw_set(access_token, password=None)
client.connect("gpresazzi-iot.duckdns.org", 1883, 60)

global_status = plug_status
def read_status():
    global global_status
    while True:
        global_status = read_hs100_value()

thread = threading.Thread(target=read_status, args=())
thread.daemon = True                            # Daemonize thread
thread.start()


# Blocking call that processes network traffic, dispatches callbacks and
# handles reconnecting.
# Other loop*() functions are available that give a threaded interface and a
# manual interface.
#client.loop_forever()