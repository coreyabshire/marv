import time
import picamera
import numpy as np
import scipy.misc

#vw, vh = (640, 480)
vw, vh = (1920, 1440)
fps = 60
n = 20

for i in range(10, 0, -1):
    print('get ready: %d' % i)
    time.sleep(0.5)

#output = np.empty((vh * vw + (int(vh/2) * int(vw/2) * 2)), dtype=np.uint8)
with picamera.PiCamera(resolution=(vw,vh), framerate=fps) as camera:
    camera.awb_mode = 'off'
    camera.awb_gains = (1.2, 1.8)
    for i in range(n):
        time.sleep(1)
        for c in range(3, 0, -1):
            print(c)
            time.sleep(0.5)
        filename = 'calib/output%02d.jpg' % i
        camera.capture(filename, use_video_port=False)
        print(filename)
        #scipy.misc.imsave(filename, output)
        #print(filename, time.time())

