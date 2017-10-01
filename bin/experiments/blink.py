import RPi.GPIO as GPIO
import time

LedPin = 12

def setup():
    GPIO.setmode(GPIO.BOARD)
    GPIO.setup(LedPin, GPIO.OUT)
    GPIO.output(LedPin, GPIO.HIGH)

def blink():
    while True:
        GPIO.output(LedPin, GPIO.HIGH)
        time.sleep(1.0)
        GPIO.output(LedPin, GPIO.LOW)
        time.sleep(1.0)

def destroy():
    GPIO.output(LedPin, GPIO.LOW)
    GPIO.cleanup()

if __name__ == '__main__':
    setup()
    try:
        blink()
    except KeyboardInterrupt:
        destroy()

