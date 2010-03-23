/* 
 * File:   xcsyscall.h
 * Author: impd
 *
 * Created on March 19, 2010, 4:26 PM
 */

#ifndef _XCSYSCALL_H
#define	_XCSYSCALL_H

#ifdef	__cplusplus
extern "C" {
#endif

#ifdef __STDC__
extern int XC_munmap (uint addr, int len);
extern long XC_getpagesz (void);
extern long XC_seek (int fno, long offset, int whence);
extern int XC_open (char *path, int oflag, int mode);
extern int XC_reads (int fno, void *buf, unsigned int nbyte);
#else
extern int XC_munmap ();
extern long XC_getpagesz ();
extern long XC_seek ();
extern int XC_open ()
extern int XC_reads ();
#endif

#ifdef	__cplusplus
}
#endif

#endif	/* _XCSYSCALL_H */

