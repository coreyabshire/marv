import serial

with serial.Serial('/dev/serial0', 9600, timeout=2) as ser:
    line1 = ser.readline()
    print(line1)
    line2 = ser.readline()
    print(line2)
    line3 = ser.readline()
    print(line3)
    line4 = ser.readline()
    print(line4)
    for i in range(100):
        command = 'command%d\n' % i
        ser.write(command.encode())
        line = ser.readline()
        print(line)
