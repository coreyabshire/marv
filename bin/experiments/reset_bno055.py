import time
import RPi.GPIO as GPIO
reset_pin = 16;
GPIO.setmode(GPIO.BOARD)
GPIO.setup(reset_pin, GPIO.OUT)
GPIO.output(reset_pin, GPIO.LOW)
time.sleep(0.01)
GPIO.output(reset_pin, GPIO.HIGH)
print('BNO055 reset')
GPIO.cleanup()
