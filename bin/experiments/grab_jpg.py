import time
import picamera
import numpy as np
import scipy.misc

#vw, vh = (640, 480)
vw, vh = (1920, 1440)
fps = 60

output = np.empty((vh * vw + (int(vh/2) * int(vw/2) * 2)), dtype=np.uint8)
with picamera.PiCamera(resolution=(vw,vh), framerate=fps) as camera:
    time.sleep(1)
    print(time.time())
    camera.capture('output.jpg', use_video_port=False)
    #scipy.misc.imsave(filename, output)
    #print(filename, time.time())
    print(time.time())

