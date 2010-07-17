/* $Id:*/

/*************************************************************************
 * I/ROUTE
 *
 * File:        vrrt_STEP/dbg.C
 *
 * Description:
 *      This is another copy of the vrrt/dbg.C file. This might've undergone
 *      some changes while compiling for MariSTEP. That's the reasin these
 *      files are placed in a different directory.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: dbg.C,v $
 *      Revision 1.1.1.1  2001/01/04 21:13:07  cvs
 *      Initial import to CVS
 *
 * Revision 1.2  1998/12/03  19:28:02  pinnacle
 * Replaced: vrrt_STEP/dbg.C for:  by apazhani for route
 *
 * Revision 1.1  1998/11/06  19:39:44  pinnacle
 * initial revision
 *
 *
 * History:
 *       Date            Name     Description
 *      11/06/98        Alwin     Creation
 *
 *************************************************************************/

/*
######  ####### ######    ###   #     # ####### ######
#     # #       #     #    #    #     # #       #     #
#     # #       #     #    #    #     # #       #     #
#     # #####   ######     #    #     # #####   #     #
#     # #       #   #      #     #   #  #       #     #
#     # #       #    #     #      # #   #       #     #
######  ####### #     #   ###      #    ####### ######

Shpp Fri Jun 25 20:40:56 EDT 1993
This file is derived from diagstdlib.shc
*/

/* This file is meant to be viewed/edited in a 160-column window
(at least). */

/* Thu Feb 25, 93  SPR - Intergraph CLIX has 2 extension functions
statl & fstatl that act like stat & fstat except they return a 32-bit
inode number, not 16-bit.  May need to use #ifdef around these later
if compiling on non-Intergraph machine. */

/* NOTE - exec() family
After a fork(), application shouldn't call diag_exec(DIAG_FATAL,path,...)
because that results in a call to exit(), which would try to clean up the
parent as well as the child.  Application should instead call
diag_exec(0,path,...) then immediately call _exit().
The diag_exec() functions won't even test the return value - if the
corresponding C library function returned at all, that means it failed.  */

#include "common.h"
#include "diag.h"
#include "time.h"

#define _ ,

#define M_mkdir         "Can't make directory \"%s\" (0%03o)\n",path,mode
#define M_chdir         "Can't change directory to \"%s\"\n",path
#define M_getcwd        "Can't get current working directory\n"
#define M_link          "Can't link file \"%s\" to \"%s\"\n",name1,name2
#define M_unlink        "Can't unlink file \"%s\"\n",path
#define M_chmod         "Can't change mode on file \"%s\" (0%03o)\n",path,mode
#define M_utime         "Can't set times of file \"%s\"\n",path
#define M_access        "Can't access file \"%s\" (0%o)\n",path,mode
#define M_open          "Can't open file \"%s\" (%0o,%0o)\n",path,oflag,mode
#define M_read          "Bad read on file descriptor %d\n",file_des
#define M_write         "Bad write on file descriptor %d\n",file_des
#define M_dup2          "Can't duplicate file descriptor %d to %d\n",old,new
#define M_lseek         "Can't lseek on file descriptor %d: offset %ld, whence %d\n",filedes,(long)offset,whence
#define M_close         "Error closing file descriptor %d\n",filedes
#define M_pipe          "Can't create pipe\n"
#define M_ftruncate     "Can't truncate file descriptor %d to length %ld\n",fd,(long)length
#define M_ferror        "I/O error on file descriptor %d\n",fileno(stream)
#define M_fopen         "Can't open file \"%s\" (%s)\n",filename,type
#define M_fdopen        "Can't create FILE* for file descriptor %d (%s)\n",fildes,type
#define M_freopen       "Can't open file \"%s\" (%s) for file descriptor %d\n",filename,type,fileno(stream)
#define M_stat          "Can't stat file \"%s\"\n",path
#define M_statl         "Can't statl file \"%s\"\n",path
#define M_fstat         "Can't fstat file descriptor %d\n",fd
#define M_fstatl        "Can't fstatl file descriptor %d\n",fd
#define M_ustat         "Can't ustat file system device %d\n",(int)dev
#define M_fseek         "Bad fseek on file descriptor %d: offset %ld, ptrname %d\n",fileno(stream),(long)offset,ptrname
#define M_ftell         "Bad ftell on file descriptor %d\n",fileno(stream)
#define M_fread         "Bad fread on file descriptor %d: size %d, nitems %d, return value %d\n",fileno(stream),size,nitems,var
#define M_fwrite        "Bad fwrite on file descriptor %d: size %d, nitems %d, return value %d\n",fileno(stream),size,nitems,var
#define M_fflush        "Bad fflush on file descriptor %d\n",fileno(stream)
#define M_fclose        "Error closing file descriptor %d\n",fileno(stream)
#define M_popen         "Can't open pipe for command \"%s\" (%s)\n",command,type
#define M_pclose        "Error closing pipe, file descriptor %d\n",fileno(stream)
#define M_fork          "Can't fork\n"
#define M_execl         "Can't execute \"%s\"\n",path
#define M_execv         M_execl
#define M_execle        M_execl
#define M_execve        M_execl
#define M_execlp        M_execl
#define M_execvp        M_execl
#define M_malloc        "Can't allocate %u bytes\n",size
#define M_calloc        "Can't allocate %u x %u bytes\n",nelem,elsize
#define M_free          ""
#define M_lstat         "Can't lstat file \"%s\"\n",path
#define M_lstatl        "Can't lstatl file \"%s\"\n",path
#define M_readlinkn     "Can't follow symbolic link for path \"%s\"\n",path

/*
struct  statl {
        dev_t   st_dev;
        ulong   st_ino;
        ushort  st_mode;
        short   st_nlink;
        ushort  st_uid;
        ushort  st_gid;
        dev_t   st_rdev;
        off_t   st_size;
        time_t  st_atime;
        time_t  st_mtime;
        time_t  st_ctime;
};
***/
extern struct statl;
extern int readlink();

static unsigned long aCalls = 0, aBytes = 0;
#define aAL(size)  aCalls++; aBytes += size;

void diag_mallocstatus(dflags) 
int dflags; 
{
    diag(dflags,"diag_mallocstatus: aCalls=%8lu aBytes=%8lu\n", aCalls,aBytes); 
}

#define sAL diag_mallocstatus( mask_dflags(dflags) );

char* diag_malloc(dflags, size)
int dflags;  unsigned size; 
{
	char* var;
 	int errno_save;
	errno = 0;
	var = malloc(size);
	errno_save = errno;
	ifnot (var !=NULL) {
		sAL
		errno = errno_save;
		if (errno!=0) dflags |= DIAG_SYSERR;
		diag(dflags,M_malloc); }
	aAL(size)
	return var;
}

char* diag_calloc(dflags, nelem, elsize)
int dflags;  unsigned nelem; unsigned elsize; {
	char* var;
 	int errno_save;
	errno = 0;
	var = calloc(nelem, elsize);
	errno_save = errno;
	ifnot (var !=NULL) {
		sAL
		errno = errno_save;
		if (errno!=0) dflags |= DIAG_SYSERR;
		diag(dflags,M_calloc); }
	aAL(nelem*elsize)
	return var;
}
void diag_free(dflags, ptr)
int dflags;  char* ptr; {
 	int errno_save;
	errno = 0;
	free(ptr);
	errno_save = errno;
	
}
int diag_lstat(dflags, path, buf)
int dflags;  char* path; struct stat* buf; {
	int var;
 	int errno_save;
	errno = 0;
	var = lstat(path _ buf);
	errno_save = errno;
	ifnot (var ==0) {
		BACK(path)
		errno = errno_save;
		if (errno!=0) dflags |= DIAG_SYSERR;
		diag(dflags,M_lstat); }
	
	return var;
}

/****
int diag_lstatl(dflags, path, buf)
int dflags;  char* path; struct statl* buf; 
{
	int var;
 	int errno_save;
	errno = 0;
	var = lstatl(path _ buf);
	errno_save = errno;
	ifnot (var ==0) {
		BACK(path)
		errno = errno_save;
		if (errno!=0) dflags |= DIAG_SYSERR;
		diag(dflags,M_lstatl); }
	
	return var;
}
***/

int diag_readlinkn(dflags, path, buf, bufsize )
int dflags;  char* path; char* buf; int bufsize; 
{
	int var;
 	int errno_save;
	errno = 0;
	var = readlinkn(path, buf, bufsize );
	errno_save = errno;
	ifnot (var ==0) {
		BACK(path)
		errno = errno_save;
		if (errno!=0) dflags |= DIAG_SYSERR;
		diag(dflags,M_readlinkn); }
	
	return var;
}

/* diag_free() is offered above for consistency with the other diagnostic
routines.  However, diag0_free() is more useful.  The library function free()
never returns a status, so we never print an error message, so dflags might
as well be 0.  More importantly, a function pointer to diag0_free() can be
used as an argument to other functions just as with free(). */

void diag0_free(ptr) char* ptr; { diag_free(0,ptr); }
