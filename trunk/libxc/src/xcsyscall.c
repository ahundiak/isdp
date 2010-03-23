#include <sys/types.h>
#include <sys/mman.h>
#include <unistd.h>
#include <fcntl.h>
#include "errordef.h"

int XC_errno  = 0;
int XC_erraux = 0;

#if SunOS_5x
extern char **environ;
extern char **envstart;

void XC_init ()
{
  envstart = environ;
}
#endif


int XC_close (int fno)
{
  if (-1 == close (fno)) {
    XC_errno = CLOSFAIL;
    return -1;
  }
  return 0;
}


long XC_seek (int fno, long offset, int whence)
{
  long ret = lseek (fno, offset, whence);

  if (ret == -1)
    XC_errno = SEEKFAIL;
  return ret;
}


int XC_open (char *path, int oflag, int mode)
{
  int ret = open (path, oflag, mode);

  if (ret == -1)
    XC_errno = OPENFAIL;
  return ret;
}


int XC_read (int fno, void *buf, unsigned int nbyte)
{
  int ret = read (fno, buf, nbyte);

  if (ret == -1)
    XC_errno = READFAIL;
  return ret;
}


int XC_reads (int fno, void *buf, unsigned int nbyte)
{
  int ret = read (fno, buf, nbyte);

  if (ret == -1)
    XC_errno = READFAIL;
  else if (ret != nbyte) {
    XC_errno = UNEXPEOF;
    return -1;
  }
  return ret;
}


int XC_write (int fno, void *buf, unsigned int nbyte)
{
  int ret = write (fno, buf, nbyte);

  if (ret == -1)
    XC_errno = RITEFAIL;
  return ret;
}


void *XC_mmap (uint addr, uint len, int prot, int flags, int fd, uint off)
{
#if defined(__mips__)
  void *mapaddr = mmap ((void *)addr, len, prot, flags, fd, off);
#else
  void *mapaddr = (void *)mmap ((caddr_t)addr, len, prot, flags, fd, off);
#endif
/*
  if (mapaddr == (caddr_t)-1)
    XC_errno = MAPFAIL;		*/
  return mapaddr;
}


int XC_munmap (uint addr, int len)
{
  return munmap ((caddr_t)addr, len);
}


long XC_getpagesz (void)
{
#if (BSD || CLIX)
  return getpagesize ();
#endif
#if SVR4
  return sysconf (_SC_PAGESIZE);
#endif
}
