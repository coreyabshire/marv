import numpy as np
import cv2
import time
import imutils
from imutils.video import VideoStream

#cap = cv2.VideoCapture(0)
vs = VideoStream(usePiCamera=True, resolution=(320,240), framerate=30).start()
time.sleep(2.0)

# Define the codec and create VideoWriter object
fourcc = cv2.VideoWriter_fourcc(*'MJPG')
out = cv2.VideoWriter('output.avi',fourcc, 30.0, (320,240))
print('init')

for i in range(300):
    frame = vs.read()
    #frame = imutils.resize(frame, width=400)
    #frame = cv2.flip(frame,0)

    # write the flipped frame
    out.write(frame)

# Release everything if job is finished
vs.stop()
out.release()
cv2.destroyAllWindows()
