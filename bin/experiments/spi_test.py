import spidev
import time
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
print(spi.xfer(to_send))
spi.close()
