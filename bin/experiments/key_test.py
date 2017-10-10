import tty
import sys
import termios

fd = sys.stdin.fileno()
fdattrorig = termios.tcgetattr(fd)

try:
    tty.setraw(fd)
    done = False
    while not done:
        ch = sys.stdin.read(1)
        sys.stdout.write('test: %s\r\n' % ord(ch))
        if ord(ch) == 27:
            ch = sys.stdin.read(1)
            sys.stdout.write('esc: %s\r\n' % ord(ch))
        if ord(ch) == 3:
            done = True
finally:
    termios.tcsetattr(fd, termios.TCSADRAIN, fdattrorig)

