import asyncio, evdev, time

def clamp(a, lo, hi):
    if a < lo:
        return lo
    elif a > hi: 
        return hi
    else:
        return a

@asyncio.coroutine
def print_events(device):
    while True:
        events = yield from device.async_read()
        for event in events:
            if event.type == 3 and evdev.ecodes.ABS[event.code] == 'ABS_Y':
                v = int(round((-1.0 * clamp((event.value - 35647) / 24000, -1.0, 1.0)) * 200 + 1490))
                print('y-axis', v, event.value, event.type)
            elif event.type == 3 and evdev.ecodes.ABS[event.code] == 'ABS_RX':
                v = int(round(clamp((event.value - 30816) / 24000, -1.0, 1.0) * 460 + 1391))
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

def do_serial(loop):
    loop.call_later(0.01, do_serial, loop)

joystick = evdev.InputDevice('/dev/input/event0')

asyncio.async(print_events(joystick))

loop = asyncio.get_event_loop()
loop.call_soon(do_serial, loop)
loop.run_forever()
