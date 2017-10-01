import tornado.ioloop
import tornado.web
import json
import time
from datetime import datetime
from Adafruit_BNO055 import BNO055

bno = BNO055.BNO055()
bno.begin()

class MainHandler(tornado.web.RequestHandler):
    def get(self):
        self.write("Hello, world")

class BNOHandler(tornado.web.RequestHandler):
    def get(self):
        self.write('ts, heading, roll, pitch\n')
        for i in range(1000):
            ts = datetime.now().strftime('%Y-%m-%d %H:%M:%S.%f') 
            heading, roll, pitch = bno.read_euler()  
            self.write('%s, %f, %f, %f\n' % (ts, heading, roll, pitch))
            time.sleep(0.01)

def make_app():
    return tornado.web.Application([
        (r"/", MainHandler),
        (r"/bno", BNOHandler),
    ])

if __name__ == "__main__":
    app = make_app()
    app.listen(8888)
    tornado.ioloop.IOLoop.current().start()
