import time
import picamera
import numpy as np
import scipy.misc

vw, vh = (640, 480)
fps = 60

output = np.empty((vh * vw + (int(vh/2) * int(vw/2) * 2)), dtype=np.uint8)
with picamera.PiCamera(resolution=(vw,vh), framerate=fps) as camera:
    time.sleep(1)
    print(time.time())
    camera.capture(output, 'yuv', use_video_port=True)
    np.save('yuv_image.npy', output)
    #scipy.misc.imsave(filename, output)
    #print(filename, time.time())
    print(time.time())

