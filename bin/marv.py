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

ControlTuple = namedtuple('Control', 'steering_pwm throttle_pwm')
ControlStruct = Struct('hh')

# RTCM == Real-Time Control Module (basically, the Teensy part)
RTCMStateTuple = namedtuple('RTCMState', 'timestamp orientation_x orientation_y orientation_z acceleration_x acceleration_y acceleration_z radio_steering_pwm radio_throttle_pwm encoder0_count encoder1_count steering_servo_voltage')
RTCMStateStruct = Struct('iffffffiiiii')

state_history = []

stream = BytesIO()
camera = PiCamera()
camera.resolution = (640, 480)

base_filename = 'output'
time_to_run_seconds = 60
update_frequency = 100

with serial.Serial('/dev/serial0', 460800, timeout=1) as ser:
    line = ''
    control = ControlTuple._make((0, 0))
    state = RTCMStateTuple._make((0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0))
    count = 0
    count_limit = update_frequency * time_to_run_seconds
    interval = 1.0 / update_frequency
    camera.start_recording('%s.h264' % (base_filename, ))
    print('start_recording', '%s.h264' % (base_filename, ))
    while count < count_limit:
        try:
            start_time = time.time()
            control = ControlTuple._make((state.radio_steering_pwm, state.radio_throttle_pwm))
            ser.write(ControlStruct.pack(*control))
            rtcm_bytes = ser.read(RTCMStateStruct.size)
            state = RTCMStateTuple._make(RTCMStateStruct.unpack(rtcm_bytes))
            print(state.encoder0_count, state.encoder1_count, state.steering_servo_voltage)
            state_history.append(state)
            count += 1
            end_time = time.time()
            diff_time = end_time - start_time
            sleep_time = interval - diff_time
            #print(start_time, end_time, diff_time, sleep_time)
            if sleep_time > 0.0:
                time.sleep(sleep_time)
        except Exception as e:
            print(e)
            time.sleep(1.0)
    camera.stop_recording()

subprocess.call('rm %s.mp4' % (base_filename, ), shell=True)
subprocess.call('MP4Box -add %s.h264 %s.mp4' % (base_filename, base_filename), shell=True)
subprocess.call('rm %s.h264' % (base_filename, ), shell=True)

with open('output.csv', 'w') as csvfile:
    csvfile.write('timestamp,orientation_x,orientation_y,orientation_z,acceleration_x,acceleration_y,acceleration_z,radio_steering_pwm,radio_throttle_pwm,encoder0_count,encoder1_count,steering_servo_voltage\n')
    for state in state_history:
        new_state = list(state)
        new_state[0] = float(new_state[0] / 1000000.0)
        csvfile.write('%0.4f,%0.4f,%0.4f,%0.4f,%0.4f,%0.4f,%0.4f,%d,%d,%d,%d,%d\n' % tuple(new_state))

