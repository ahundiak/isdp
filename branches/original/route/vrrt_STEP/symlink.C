/* $Id:*/

/*************************************************************************
 * I/ROUTE
 *
 * File:        vrrt_STEP/symlink.C
 *
 * Description:
 *      This is another copy of the vrrt/symlink.C file. This might've undergone
 *      some changes while compiling for MariSTEP. That's the reasin these
 *      files are placed in a different directory.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: symlink.C,v $
 *      Revision 1.1.1.1  2001/01/04 21:13:08  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/11/06  19:36:34  pinnacle
 * initial revision
 *
 *
 * History:
 *       Date            Name     Description
 *      11/06/98        Alwin     Creation
 *
 *************************************************************************/

#include <sys/types.h>
#include <sys/stat.h>

#define self(x) x
#define ASSIGN(el) lbuf->self(st_)el = buf.self(st_)el;

#if 0
#define ALL(m) \
	m(mode) m(ino) m(dev) m(rdev) m(nlink) m(uid) m(gid) m(size) \
	m(atime) m(mtime) m(ctime)
#endif

/***
int lstatl(path,lbuf) 
char* path; struct statl* lbuf; 
{
    struct stat buf; int status;

    if ( (-1) == (status = lstat(path,&buf)) ) goto end;
    ALL(ASSIGN)
    end: 
    
    return status; 
}
***/

int readlinkn(path,buf,bufsize) char* path; char* buf; int bufsize; { int nc;
	if (-1==(nc = readlink(path,buf,bufsize-1))) return -1;
	/* If nc == bufsize-1, we can't be sure there weren't more characters
	in the symbolic link.  Disallow nc >= bufsize-1, but allow
	nc < bufsize-1. */
	if (!(nc > 0 && nc<bufsize-1)) return -1;
	*(buf+nc) = '\0'; return 0; }
