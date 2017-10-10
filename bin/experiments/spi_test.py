import spidev
bus = 0
device = 0
spi = spidev.SpiDev()
spi.open(bus, device)
spi.max_speed_hz = 5000
to_send = [0x01, 0x02, 0x03]
spi.xfer(to_send)
