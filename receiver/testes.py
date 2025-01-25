import getmac
import screeninfo as si
import pynput


moveMouse = pynput.mouse.Controller()

print(getmac.get_mac_address().upper())
print("\n")
print(si.get_monitors()[0].width, si.get_monitors()[0].height)
print("\n")
print(moveMouse.position[0])
print(moveMouse.position)