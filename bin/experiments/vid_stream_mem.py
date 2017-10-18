import io
import picamera
import shutil

stream = io.BytesIO()
with picamera.PiCamera() as camera:
    camera.resolution = (640, 480)
    camera.start_recording(stream, format='h264', quality=23)
    camera.wait_recording(15)
    camera.stop_recording()
print('stream_len:', stream.tell())
stream_len = stream.tell()
stream.flush()
print('stream_len:', stream.tell())
stream_len = stream.tell()
stream.seek(0)
with open('output.h264', 'wb') as h264file:
    shutil.copyfileobj(stream, h264file, length=stream_len)
