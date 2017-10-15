import asyncio
import evdev
import serial
from struct import Struct
from collections import namedtuple
import random
import time
from io import BytesIO
from picamera import PiCamera
import numpy as np
import csv
import subprocess
import os
from datetime import datetime
import spidev

steering_center = 1391
throttle_center = 1490

def clamp(a, lo, hi):
    if a < lo:
        return lo
    elif a > hi:
        return hi
    else:
        return a

@asyncio.coroutine
def handle_joystick(device, marv):
    while True:
        events = yield from device.async_read()
        for event in events:
            if event.type == 3 and evdev.ecodes.ABS[event.code] == 'ABS_Y':
                v = int(round((-1.0 * clamp((event.value - 35647) / 24000, -1.0, 1.0)) * 200 + throttle_center))
                marv.throttle_pwm = v
                print('y-axis', v, event.value, event.type)
            elif event.type == 3 and evdev.ecodes.ABS[event.code] == 'ABS_RX':
                v = int(round((-1.0 * clamp((event.value - 30816) / 24000, -1.0, 1.0)) * 460 + steering_center))
                marv.steering_pwm = v
                print('x-axis', v, event.value, event.type)
            elif event.type == 1 and event.code == 305 and event.value != 2:
                print('A', event.value)
            elif event.type == 1 and event.code == 304 and event.value != 2:
                print('B', event.value)
            elif event.type == 1 and event.code == 307 and event.value != 2:
                print('X', event.value)
            elif event.type == 1 and event.code == 306 and event.value != 2:
                print('Y', event.value)
            elif event.type != 0 and event.type != 4:
                #print(device.fn, evdev.categorize(event), sep=': ')
                #print(event.code, event.type, event.value)
                pass


class RTCM(object):
    """RTCM == Real-Time Control Module (basically, the Teensy part)"""
    
    ControlTuple = namedtuple('Control', 'steering_pwm throttle_pwm')
    ControlStruct = Struct('<hh52x')

    StateTuple = namedtuple('RTCMState', 'timestamp '
        'orientation_x orientation_y orientation_z '
        'acceleration_x acceleration_y acceleration_z '
        'radio_steering_pwm radio_throttle_pwm '
        'encoder0_count encoder1_count '
        'steering_servo_voltage')
    StateStruct = Struct('<5x1L6f5i3x')

    def __init__(self):
        self.spi = spidev.SpiDev()
        bus = 0
        device = 0
        self.spi.open(bus, device)
        self.spi.max_speed_hz = 2000000
        self.spi.mode = 0b00

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_value, traceback):
        try:
            spi.close()
            print('closed spi connection')
        except Exception as e:
            print('failed to close serial connection')
        if exc_type is not None:
            print(exc_type, exc_value, traceback)
            # return False # uncomment to pass exception through
        return self

    def update(self, steering_pwm, throttle_pwm):
        print(steering_pwm, throttle_pwm)
        control = RTCM.ControlTuple._make((steering_pwm, throttle_pwm))
        #self.ser.write(RTCM.ControlStruct.pack(*control))
        to_send = RTCM.ControlStruct.pack(*control)
        rtcm_bytes = self.spi.xfer(list(to_send))
        state = RTCM.StateTuple._make(RTCM.StateStruct.unpack(bytearray(rtcm_bytes)))
        return state


class MARV():

    def __init__(self):
        self.state_history = []
        self.camera = PiCamera()
        time.sleep(2)
        self.vw = vw = 640
        self.vh = vh = 480
        self.camera.resolution = (self.vw, self.vh)
        self.camera.awb_mode = 'off'
        self.camera.awb_gains = (1.2, 1.8)

        self.base_filename = 'output'
        self.time_to_run_seconds = 30
        self.update_frequency = 50.0
        self.interval = 1.0 / self.update_frequency
        self.count_limit = self.update_frequency * self.time_to_run_seconds

        self.count = 0

        self.steering_pwm = steering_center
        self.throttle_pwm = throttle_center
        self.output = np.empty(vw * vh + vw // 2 * vh // 2 * 2, dtype=np.uint8)

        self.rtcm = RTCM()

    def update(self):
        try:
            self.camera.capture(self.output, 'yuv', use_video_port=True)
            #print('captured image', time.time())
            vw, vh = self.vw, self.vh
            #y = self.output[:vw*vh].reshape(vh,vw)
            u = self.output[vw*vh:vw*vh+vw//2*vh//2].reshape(vh//2,vw//2)
            u = u[-vh//8:,:]
            np.save('images/u%d.npy' % (self.count % 5), u)
            y, x = np.where(u < 85)
            #print(y, x)
            #print(x.mean())
            #self.steering_pwm = int(round((((x.mean() - (vw/4))/(vw/4)) * -400.0 + 1391.0)))
        except Exception as e:
            print('erroru:',e)
            self.steering_pwm = 1391
            self.throttle_pwm = 1490
        #print(x.mean(), self.steering_pwm, list(np.polyfit(x, y, 1)))
        self.state = self.rtcm.update(self.steering_pwm, self.throttle_pwm)
        #v = self.output[vw*vh+vw//2*vh//2:].reshape(vh//2,vw//2)
        #np.save('images/y%d.npy' % (self.count % 5), y)
        #np.save('images/v%d.npy' % (self.count % 5), v)
        #print(self.camera.awb_gains)
        #self.steering_pwm = self.state.radio_steering_pwm
        #self.throttle_pwm = self.state.radio_throttle_pwm
        print(self.state.encoder0_count, self.state.encoder1_count, self.state.steering_servo_voltage, self.state.radio_steering_pwm, self.state.radio_throttle_pwm, self.steering_pwm, self.throttle_pwm)
        self.state_history.append(self.state)

    def close(self):
        self.rtcm.__exit__()

    def process_video(self):
        subprocess.call('rm %s.mp4' % (self.base_filename, ), shell=True)
        subprocess.call('MP4Box -add %s.h264 %s.mp4' % (self.base_filename, self.base_filename), shell=True)
        subprocess.call('rm %s.h264' % (self.base_filename, ), shell=True)

    def write_state_history(self):
        print('writing state history')
        with open('output.csv', 'w') as csvfile:
            csvfile.write('timestamp,orientation_x,orientation_y,orientation_z,acceleration_x,acceleration_y,acceleration_z,radio_steering_pwm,radio_throttle_pwm,encoder0_count,encoder1_count,steering_servo_voltage\n')
            for state in self.state_history:
                new_state = list(state)
                new_state[0] = float(new_state[0] / 1000000.0)
                csvfile.write('%0.4f,%0.4f,%0.4f,%0.4f,%0.4f,%0.4f,%0.4f,%d,%d,%d,%d,%d\n' % tuple(new_state))

    def finish(self):
        self.process_video()
        self.write_state_history()

    
    def run(self):
        self.camera.start_recording('%s.h264' % (self.base_filename, ))
        print('start_recording', '%s.h264' % (self.base_filename, ))
        while self.count < self.count_limit:
            try:
                start_time = time.time()
                self.count += 1
                self.update()
                self.camera.wait_recording(0.0)
                end_time = time.time()
                diff_time = end_time - start_time
                sleep_time = self.interval - diff_time
                if sleep_time > 0.0:
                    time.sleep(sleep_time)
            except Exception as e:
                print('error:', e)
                #time.sleep(1.0)
        print('stop_recording', '%s.h264' % (self.base_filename, ))
        self.camera.stop_recording()
        self.finish()

def update_marv(loop, marv):
    marv.count += 1
    if marv.count < marv.count_limit:
        loop.call_later(marv.interval, update_marv, loop, marv)
    else:
        loop.stop()
    marv.update()
    marv.camera.wait_recording(0.0)

if __name__ == '__main__':
    joystick = evdev.InputDevice('/dev/input/event0')
    marv = MARV()
    marv.camera.start_recording('%s.h264' % (marv.base_filename, ))
    print('start_recording', '%s.h264' % (marv.base_filename, ))

    asyncio.async(handle_joystick(joystick, marv))

    loop = asyncio.get_event_loop()
    loop.call_soon(update_marv, loop, marv)
    loop.run_forever()

    print('stop_recording', '%s.h264' % (marv.base_filename, ))
    marv.camera.stop_recording()
    marv.finish()

    #marv.run()
