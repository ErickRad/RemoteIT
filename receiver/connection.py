from pynput import mouse as ms, keyboard as kb
import socket
import platform
import random
import time
import getmac 
import screeninfo as si

BUFFER = 1024
DISCOVER = 'DISCOVER_SERVER'
AVAILABLE = 'SERVER_AVAILABLE'
REQUEST = 'REQUEST_CONNECTION'
ACCEPT = 'CONNECTION_ACCEPTED'
DENY = 'CONNECTION_DENIED'

hostname = socket.gethostname()
local_ip = socket.gethostbyname(hostname)
system = platform.system().lower()
mac = getmac.get_mac_address().upper()
screenWidth, screenHeigth = si.get_monitors()[0].width, si.get_monitors()[0].height

udp = None
mouse = ms.Controller()

canCommand = False

class Connection():
    addr = "0.0.0.0"
    port = 5000
    message = []
    response = ""
    passcode = ""

    @staticmethod
    def connectToReceiver():
        global udp, canCommand

        udp = socket.socket(
            family=socket.AF_INET,
            type=socket.SOCK_DGRAM
        )
        udp.setsockopt(
            socket.SOL_SOCKET,
            socket.SO_BROADCAST,
            1
        )
        udp.bind((
            "0.0.0.0",
            Connection.port
        ))

        print(f"Waiting for receivers on broadcast port {Connection.port}...\n")
        while True:
            try:
                data, Connection.addr = udp.recvfrom(BUFFER)
                message = data.decode('utf-8').split("|")

                if message[0] == DISCOVER:
                    print(f"{DISCOVER} received from {Connection.addr[0]}:{Connection.port}")
                    response = f"{AVAILABLE}|{hostname}|{system}"
                    udp.sendto(
                        response.encode('utf-8'),
                        Connection.addr
                    )
                    print(f"{AVAILABLE} sent to {Connection.addr[0]}:{Connection.port}\n")
                    Connection.passcode = str(random.randint(1000, 9999))

                    print(f"Use passcode {Connection.passcode} in your Android to connect\n")

                elif message[0] == REQUEST:
                    print(f"{REQUEST} received from {Connection.addr[0]}:{Connection.port}")

                    if message[1] == Connection.passcode:
                        Connection.port = random.randint(5001, 8000)
                        currentMouseX, currentMouseY = mouse.position
                        response = f"{ACCEPT}|true|{mac}|{Connection.port}|{screenWidth}|{screenHeigth}|{currentMouseX}|{currentMouseY}"
                        udp.sendto(
                            response.encode('utf-8'),
                            Connection.addr
                        )

                        print(f"{ACCEPT} sent to {Connection.addr[0]}:{Connection.port}\n")
                        udp.close()
                        udp = socket.socket(
                            socket.AF_INET,
                            socket.SOCK_DGRAM
                        )
                        udp.bind(("0.0.0.0", Connection.port))
                        print(f"Connected to {Connection.addr[0]}:{Connection.port}\n\n")
                        canCommand = True
                        break
                    else:
                        response = f"{DENY}|false"
                        udp.sendto(
                            response.encode('utf-8'),
                            Connection.addr
                        )
                        print(f"INVALID PASSCODE RECEIVED FROM {Connection.addr[0]}:{Connection.port}\n")
                        print(f"Use passcode {Connection.passcode} in your Android to connect\n\n")

            except socket.error as e:
                print(e)

    @staticmethod
    def receiveCommands():
        global udp, canCommand

        while True:
            if(canCommand):
                data, Connection.addr = udp.recvfrom(BUFFER)
                message = data.decode('utf-8').split("|")
                
                match(message[2]):
                    case "move":
                        mouse.position = (float(message[0]), float(message[1]))
                       
                    case "click":
                        mouse.click(ms.Button.left, 1)
                    
                    case "double":
                        mouse.click(ms.Button.left, 2)
                    
                    case "right":
                        mouse.click(ms.Button.right, 1)
                

                time.sleep(0.01)
