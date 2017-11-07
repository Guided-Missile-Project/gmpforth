/* 
   cfmakeraw.c

   Copyright (c) 2011 by Daniel Kelley

   $Id:$

   non-libc cfmakeraw()

   -ignbrk*
   -brkint*
   -ignpar+
   -parmrk*
   -inpck+
   -istrip*
   -inlcr*
   -igncr*
   -icrnl*
   -iuclc+
   -ixon*
   -ixany+
   -ixoff+
   -imaxbel+
   -opost*
   -isig*
   -icanon*
   -xcase+
   min 1*
   time 0*

   * = from makecfraw()
   + = from stty raw

*/

#include <termios.h>

void cfmakeraw(struct termios *raw)
{
  raw->c_iflag &= ~(IGNBRK|BRKINT|IGNPAR|PARMRK|INPCK|ISTRIP|
                           INLCR|IGNCR|ICRNL|IUCLC|IXON|IXANY|IXOFF|IMAXBEL);
  raw->c_oflag &= ~OPOST;
  raw->c_lflag &= ~(ECHO|ECHONL|ICANON|ISIG|IEXTEN|XCASE);
  raw->c_cflag &= ~(CSIZE|PARENB);
  raw->c_cflag |= CS8;
  raw->c_cc[VMIN] = 1;
  raw->c_cc[VTIME] = 0;
}
