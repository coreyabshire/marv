import spidev
import time
from struct import pack, unpack
bus = 0
device = 0
spi = spidev.SpiDev()
spi.open(bus, device)
#spi.max_speed_hz = 1000000 * 12
spi.max_speed_hz = 2000000
spi.mode = 0b00
#to_send = [0x01, 0x02, 0x03, 0x04]
#to_send = [0xff, 0xff, 0xff, 0xff]
to_send = list(range(56))
state_bytes = spi.xfer(to_send)
#print(spi.xfer(to_send))
print(list(state_bytes))
state = unpack('<5x1L6f5i3x', bytearray(state_bytes))
print(state)
timestamp = state[0]
orientation = state[1:4]
acceleration = state[4:7]
radio_pwm = state[7:9]
wheel_encoders = state[9:11]
servo_voltage = state[11]
print('timestamp:', timestamp)
print('orientation:', orientation)
print('acceleration:', acceleration)
print('wheel encoders:', wheel_encoders)
print('servo voltage:', servo_voltage)
spi.close()
