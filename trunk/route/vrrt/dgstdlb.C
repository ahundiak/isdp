/* $Id: */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrrt/dgstdlb.C
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: dgstdlb.C,v $
 *	Revision 1.1.1.1  2001/01/04 21:13:06  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.1  1998/01/16  05:25:02  pinnacle
 * Created: vrrt/dgstdlb.C by r250_int for route
 *
 *
 *
 * History:
 *	01/15/98	Onay	Integration date.
 *
 *************************************************************************/

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

#include <common.h>

/* When printing a string argument (e.g. a filename) in an error message,
make control characters visible to the user.  back_str(), defined in the
Common module backc.c, overwrites its buffer with each call.  Since we'll
sometimes need to print more than one of these in a single C statement,
keep a circular array for the strings it returns. */

/* For diagnosing problems with memory allocation, we keep track of the
number of calls to malloc() and free() and the number of bytes allocated.
At the time of this writing, we also have a variable for the number of
bytes freed, but this stays at 0 because the standard memory allocation
routines hide information about the size of an allocated block.
(Newer, better versions of malloc() exist with more complete
diagnostics.) */

static unsigned long aCalls = 0, aBytes = 0;
#define sAL diag_mallocstatus(mask_dflags(dflags));
#define aAL(size) aCalls++, aBytes += size;
void diag_mallocstatus(dflags) int dflags; {
	diag(dflags,"diag_mallocstatus: aCalls=%8lu aBytes=%8lu\n",
	            aCalls,aBytes); }

/* So we can pass stuff with commas in it as a single argument
to a macro */
#define _ ,

#define M_mkdir 	"Can't make directory \"%s\" (0%03o)\n",path,mode
#define M_chdir 	"Can't change directory to \"%s\"\n",path
#define M_getcwd 	"Can't get current working directory\n"
#define M_link 		"Can't link file \"%s\" to \"%s\"\n",name1,name2
#define M_unlink 	"Can't unlink file \"%s\"\n",path
#define M_chmod 	"Can't change mode on file \"%s\" (0%03o)\n",path,mode
#define M_utime 	"Can't set times of file \"%s\"\n",path
#define M_access	"Can't access file \"%s\" (0%o)\n",path,mode
#define M_open 		"Can't open file \"%s\" (%0o,%0o)\n",path,oflag,mode
#define M_read 		"Bad read on file descriptor %d\n",file_des
#define M_write 	"Bad write on file descriptor %d\n",file_des
#define M_dup2 		"Can't duplicate file descriptor %d to %d\n",old,new
#define M_lseek 	"Can't lseek on file descriptor %d: offset %ld, whence %d\n",filedes,(long)offset,whence
#define M_close 	"Error closing file descriptor %d\n",filedes
#define M_pipe 		"Can't create pipe\n"
#define M_ftruncate 	"Can't truncate file descriptor %d to length %ld\n",fd,(long)length
#define M_ferror 	"I/O error on file descriptor %d\n",fileno(stream)
#define M_fopen 	"Can't open file \"%s\" (%s)\n",filename,type
#define M_fdopen 	"Can't create FILE* for file descriptor %d (%s)\n",fildes,type
#define M_freopen 	"Can't open file \"%s\" (%s) for file descriptor %d\n",filename,type,fileno(stream)
#define M_stat 		"Can't stat file \"%s\"\n",path
#define M_statl 	"Can't statl file \"%s\"\n",path
#define M_fstat 	"Can't fstat file descriptor %d\n",fd
#define M_fstatl 	"Can't fstatl file descriptor %d\n",fd
#define M_ustat 	"Can't ustat file system device %d\n",(int)dev
#define M_fseek 	"Bad fseek on file descriptor %d: offset %ld, ptrname %d\n",fileno(stream),(long)offset,ptrname
#define M_ftell 	"Bad ftell on file descriptor %d\n",fileno(stream)
#define M_fread 	"Bad fread on file descriptor %d: size %d, nitems %d, return value %d\n",fileno(stream),size,nitems,var
#define M_fwrite 	"Bad fwrite on file descriptor %d: size %d, nitems %d, return value %d\n",fileno(stream),size,nitems,var
#define M_fflush 	"Bad fflush on file descriptor %d\n",fileno(stream)
#define M_fclose 	"Error closing file descriptor %d\n",fileno(stream)
#define M_popen 	"Can't open pipe for command \"%s\" (%s)\n",command,type
#define M_pclose 	"Error closing pipe, file descriptor %d\n",fileno(stream)
#define M_fork 		"Can't fork\n"
#define M_execl 	"Can't execute \"%s\"\n",path
#define M_execv 	M_execl
#define M_execle 	M_execl
#define M_execve 	M_execl
#define M_execlp 	M_execl
#define M_execvp 	M_execl
#define M_malloc 	"Can't allocate %u bytes\n",size
#define M_calloc 	"Can't allocate %u x %u bytes\n",nelem,elsize
#define M_free 		""
#define M_lstat 	"Can't lstat file \"%s\"\n",path
#define M_lstatl 	"Can't lstatl file \"%s\"\n",path
#define M_readlinkn 	"Can't follow symbolic link for path \"%s\"\n",path

int diag_mkdir(dflags    _  path _ mode)
int dflags;  char* path; int mode; {
	int var;
 	int errno_save;
	errno = 0;
	var = mkdir(path _ mode);
	errno_save = errno;
	ifnot (var ==0) {
		BACK(path)
		errno = errno_save;
		if (errno!=0) dflags |= DIAG_SYSERR;
		diag(dflags,M_mkdir); }
	
	return var;
}
int diag_chdir(dflags    _  path)
int dflags;  char* path; {
	int var;
 	int errno_save;
	errno = 0;
	var = chdir(path);
	errno_save = errno;
	ifnot (var ==0) {
		BACK(path)
		errno = errno_save;
		if (errno!=0) dflags |= DIAG_SYSERR;
		diag(dflags,M_chdir); }
	
	return var;
}
char* diag_getcwd(dflags    _  buf _ size)
int dflags;  char* buf; int size; {
	char* var;
 	int errno_save;
	errno = 0;
	var = getcwd(buf _ size);
	errno_save = errno;
	ifnot (var !=NULL) {
		
		errno = errno_save;
		if (errno!=0) dflags |= DIAG_SYSERR;
		diag(dflags,M_getcwd); }
	
	return var;
}
int diag_link(dflags    _  name1 _ name2)
int dflags;  char* name1; char* name2; {
	int var;
 	int errno_save;
	errno = 0;
	var = link(name1 _ name2);
	errno_save = errno;
	ifnot (var ==0) {
		BACK(name1) BACK(name2)
		errno = errno_save;
		if (errno!=0) dflags |= DIAG_SYSERR;
		diag(dflags,M_link); }
	
	return var;
}
int diag_unlink(dflags    _  path)
int dflags;  char* path; {
	int var;
 	int errno_save;
	errno = 0;
	var = unlink(path);
	errno_save = errno;
	ifnot (var ==0) {
		BACK(path)
		errno = errno_save;
		if (errno!=0) dflags |= DIAG_SYSERR;
		diag(dflags,M_unlink); }
	
	return var;
}
int diag_chmod(dflags    _  path _ mode)
int dflags;  char* path; int mode; {
	int var;
 	int errno_save;
	errno = 0;
	var = chmod(path _ mode);
	errno_save = errno;
	ifnot (var ==0) {
		BACK(path)
		errno = errno_save;
		if (errno!=0) dflags |= DIAG_SYSERR;
		diag(dflags,M_chmod); }
	
	return var;
}
int diag_utime(dflags    _  path _ times)
int dflags;  char* path; struct utimbuf* times; {
	int var;
 	int errno_save;
	errno = 0;
	var = utime(path _ times);
	errno_save = errno;
	ifnot (var ==0) {
		BACK(path)
		errno = errno_save;
		if (errno!=0) dflags |= DIAG_SYSERR;
		diag(dflags,M_utime); }
	
	return var;
}
int diag_access(dflags    _  path _ mode)
int dflags;  char* path; int mode; {
	int var;
 	int errno_save;
	errno = 0;
	var = access(path _ mode);
	errno_save = errno;
	ifnot (var ==0) {
		BACK(path)
		errno = errno_save;
		if (errno!=0) dflags |= DIAG_SYSERR;
		diag(dflags,M_access); }
	
	return var;
}
int diag_open(dflags    _  path _ oflag _ mode)
int dflags;  char* path; int oflag; int mode; {
	int var;
 	int errno_save;
	errno = 0;
	var = open(path _ oflag _ mode);
	errno_save = errno;
	ifnot (var !=-1) {
		BACK(path)
		errno = errno_save;
		if (errno!=0) dflags |= DIAG_SYSERR;
		diag(dflags,M_open); }
	
	return var;
}
int diag_read(dflags    _  file_des _ buffer _ nbytes)
int dflags;  int file_des; char* buffer; unsigned nbytes; {
	int var;
 	int errno_save;
	errno = 0;
	var = read(file_des _ buffer _ nbytes);
	errno_save = errno;
	ifnot (var >=0) {
		
		errno = errno_save;
		if (errno!=0) dflags |= DIAG_SYSERR;
		diag(dflags,M_read); }
	
	return var;
}
int diag_fname_read(dflags _ fname  _  file_des _ buffer _ nbytes)
int dflags; char* fname; int file_des; char* buffer; unsigned nbytes; {
	int var;
 	int errno_save;
	errno = 0;
	var = read(file_des _ buffer _ nbytes);
	errno_save = errno;
	ifnot (var >=0) {
		
		diag(mask_dflags(dflags),M_fname);
		errno = errno_save;
		if (errno!=0) dflags |= DIAG_SYSERR;
		diag(dflags,M_read); }
	
	return var;
}
int diag_write(dflags    _  file_des _ buffer _ nbytes)
int dflags;  int file_des; char* buffer; unsigned nbytes; {
	int var;
 	int errno_save;
	errno = 0;
	var = write(file_des _ buffer _ nbytes);
	errno_save = errno;
	ifnot (var ==nbytes) {
		
		errno = errno_save;
		if (errno!=0) dflags |= DIAG_SYSERR;
		diag(dflags,M_write); }
	
	return var;
}
int diag_fname_write(dflags _ fname  _  file_des _ buffer _ nbytes)
int dflags; char* fname; int file_des; char* buffer; unsigned nbytes; {
	int var;
 	int errno_save;
	errno = 0;
	var = write(file_des _ buffer _ nbytes);
	errno_save = errno;
	ifnot (var ==nbytes) {
		
		diag(mask_dflags(dflags),M_fname);
		errno = errno_save;
		if (errno!=0) dflags |= DIAG_SYSERR;
		diag(dflags,M_write); }
	
	return var;
}
int diag_dup2(dflags    _  old _ new)
int dflags;  int old; int new; {
	int var;
 	int errno_save;
	errno = 0;
	var = dup2(old _ new);
	errno_save = errno;
	ifnot (var ==new) {
		
		errno = errno_save;
		if (errno!=0) dflags |= DIAG_SYSERR;
		diag(dflags,M_dup2); }
	
	return var;
}
off_t diag_lseek(dflags    _  filedes _ offset _ whence)
int dflags;  int filedes; off_t offset; int whence; {
	off_t var;
 	int errno_save;
	errno = 0;
	var = lseek(filedes _ offset _ whence);
	errno_save = errno;
	ifnot (var !=-1) {
		
		errno = errno_save;
		if (errno!=0) dflags |= DIAG_SYSERR;
		diag(dflags,M_lseek); }
	
	return var;
}
off_t diag_fname_lseek(dflags _ fname  _  filedes _ offset _ whence)
int dflags; char* fname; int filedes; off_t offset; int whence; {
	off_t var;
 	int errno_save;
	errno = 0;
	var = lseek(filedes _ offset _ whence);
	errno_save = errno;
	ifnot (var !=-1) {
		
		diag(mask_dflags(dflags),M_fname);
		errno = errno_save;
		if (errno!=0) dflags |= DIAG_SYSERR;
		diag(dflags,M_lseek); }
	
	return var;
}
int diag_close(dflags    _  filedes)
int dflags;  int filedes; {
	int var;
 	int errno_save;
	errno = 0;
	var = close(filedes);
	errno_save = errno;
	ifnot (var ==0) {
		
		errno = errno_save;
		if (errno!=0) dflags |= DIAG_SYSERR;
		diag(dflags,M_close); }
	
	return var;
}
int diag_fname_close(dflags _ fname  _  filedes)
int dflags; char* fname; int filedes; {
	int var;
 	int errno_save;
	errno = 0;
	var = close(filedes);
	errno_save = errno;
	ifnot (var ==0) {
		
		diag(mask_dflags(dflags),M_fname);
		errno = errno_save;
		if (errno!=0) dflags |= DIAG_SYSERR;
		diag(dflags,M_close); }
	
	return var;
}
int diag_pipe(dflags    _  file_des)
int dflags;  int* file_des; {
	int var;
 	int errno_save;
	errno = 0;
	var = pipe(file_des);
	errno_save = errno;
	ifnot (var ==0) {
		
		errno = errno_save;
		if (errno!=0) dflags |= DIAG_SYSERR;
		diag(dflags,M_pipe); }
	
	return var;
}
int diag_ftruncate(dflags    _  fd _ length)
int dflags;  int fd; off_t length; {
	int var;
 	int errno_save;
	errno = 0;
	var = ftruncate(fd _ length);
	errno_save = errno;
	ifnot (var ==0) {
		
		errno = errno_save;
		if (errno!=0) dflags |= DIAG_SYSERR;
		diag(dflags,M_ftruncate); }
	
	return var;
}
int diag_fname_ftruncate(dflags _ fname  _  fd _ length)
int dflags; char* fname; int fd; off_t length; {
	int var;
 	int errno_save;
	errno = 0;
	var = ftruncate(fd _ length);
	errno_save = errno;
	ifnot (var ==0) {
		
		diag(mask_dflags(dflags),M_fname);
		errno = errno_save;
		if (errno!=0) dflags |= DIAG_SYSERR;
		diag(dflags,M_ftruncate); }
	
	return var;
}
int diag_ferror(dflags    _  stream)
int dflags;  FILE* stream; {
	int var;
 	int errno_save;
	errno = 0;
	var = ferror(stream);
	errno_save = errno;
	ifnot (var ==0) {
		
		errno = errno_save;
		if (errno!=0) dflags |= DIAG_SYSERR;
		diag(dflags,M_ferror); }
	
	return var;
}
int diag_fname_ferror(dflags _ fname  _  stream)
int dflags; char* fname; FILE* stream; {
	int var;
 	int errno_save;
	errno = 0;
	var = ferror(stream);
	errno_save = errno;
	ifnot (var ==0) {
		
		diag(mask_dflags(dflags),M_fname);
		errno = errno_save;
		if (errno!=0) dflags |= DIAG_SYSERR;
		diag(dflags,M_ferror); }
	
	return var;
}
FILE* diag_fopen(dflags    _  filename _ type)
int dflags;  char* filename; char* type; {
	FILE* var;
 	int errno_save;
	errno = 0;
	var = fopen(filename _ type);
	errno_save = errno;
	ifnot (var !=NULL) {
		BACK(filename) BACK(type)
		errno = errno_save;
		if (errno!=0) dflags |= DIAG_SYSERR;
		diag(dflags,M_fopen); }
	
	return var;
}
FILE* diag_fdopen(dflags    _  fildes _ type)
int dflags;  int fildes; char* type; {
	FILE* var;
 	int errno_save;
	errno = 0;
	var = fdopen(fildes _ type);
	errno_save = errno;
	ifnot (var !=NULL) {
		BACK(type)
		errno = errno_save;
		if (errno!=0) dflags |= DIAG_SYSERR;
		diag(dflags,M_fdopen); }
	
	return var;
}
FILE* diag_fname_fdopen(dflags _ fname  _  fildes _ type)
int dflags; char* fname; int fildes; char* type; {
	FILE* var;
 	int errno_save;
	errno = 0;
	var = fdopen(fildes _ type);
	errno_save = errno;
	ifnot (var !=NULL) {
		BACK(type)
		diag(mask_dflags(dflags),M_fname);
		errno = errno_save;
		if (errno!=0) dflags |= DIAG_SYSERR;
		diag(dflags,M_fdopen); }
	
	return var;
}
FILE* diag_freopen(dflags    _  filename _ type _ stream)
int dflags;  char* filename; char* type; FILE* stream; {
	FILE* var;
 	int errno_save;
	errno = 0;
	var = freopen(filename _ type _ stream);
	errno_save = errno;
	ifnot (var !=NULL) {
		BACK(filename) BACK(type)
		errno = errno_save;
		if (errno!=0) dflags |= DIAG_SYSERR;
		diag(dflags,M_freopen); }
	
	return var;
}
int diag_stat(dflags    _  path _ buf)
int dflags;  char* path; struct stat* buf; {
	int var;
 	int errno_save;
	errno = 0;
	var = stat(path _ buf);
	errno_save = errno;
	ifnot (var ==0) {
		BACK(path)
		errno = errno_save;
		if (errno!=0) dflags |= DIAG_SYSERR;
		diag(dflags,M_stat); }
	
	return var;
}
int diag_statl(dflags    _  path _ buf)
int dflags;  char* path; struct statl* buf; {
	int var;
 	int errno_save;
	errno = 0;
	var = statl(path _ buf);
	errno_save = errno;
	ifnot (var ==0) {
		BACK(path)
		errno = errno_save;
		if (errno!=0) dflags |= DIAG_SYSERR;
		diag(dflags,M_statl); }
	
	return var;
}
int diag_fstat(dflags    _  fd _ buf)
int dflags;  int fd; struct stat* buf; {
	int var;
 	int errno_save;
	errno = 0;
	var = fstat(fd _ buf);
	errno_save = errno;
	ifnot (var ==0) {
		
		errno = errno_save;
		if (errno!=0) dflags |= DIAG_SYSERR;
		diag(dflags,M_fstat); }
	
	return var;
}
int diag_fname_fstat(dflags _ fname  _  fd _ buf)
int dflags; char* fname; int fd; struct stat* buf; {
	int var;
 	int errno_save;
	errno = 0;
	var = fstat(fd _ buf);
	errno_save = errno;
	ifnot (var ==0) {
		
		diag(mask_dflags(dflags),M_fname);
		errno = errno_save;
		if (errno!=0) dflags |= DIAG_SYSERR;
		diag(dflags,M_fstat); }
	
	return var;
}
int diag_fstatl(dflags    _  fd _ buf)
int dflags;  int fd; struct statl* buf; {
	int var;
 	int errno_save;
	errno = 0;
	var = fstatl(fd _ buf);
	errno_save = errno;
	ifnot (var ==0) {
		
		errno = errno_save;
		if (errno!=0) dflags |= DIAG_SYSERR;
		diag(dflags,M_fstatl); }
	
	return var;
}
int diag_fname_fstatl(dflags _ fname  _  fd _ buf)
int dflags; char* fname; int fd; struct statl* buf; {
	int var;
 	int errno_save;
	errno = 0;
	var = fstatl(fd _ buf);
	errno_save = errno;
	ifnot (var ==0) {
		
		diag(mask_dflags(dflags),M_fname);
		errno = errno_save;
		if (errno!=0) dflags |= DIAG_SYSERR;
		diag(dflags,M_fstatl); }
	
	return var;
}
int diag_ustat(dflags    _  dev _ buf)
int dflags;  dev_t dev; struct ustat* buf; {
	int var;
 	int errno_save;
	errno = 0;
	var = ustat(dev _ buf);
	errno_save = errno;
	ifnot (var ==0) {
		
		errno = errno_save;
		if (errno!=0) dflags |= DIAG_SYSERR;
		diag(dflags,M_ustat); }
	
	return var;
}
int diag_fseek(dflags    _  stream _ offset _ ptrname)
int dflags;  FILE* stream; long offset; int ptrname; {
	int var;
 	int errno_save;
	errno = 0;
	var = fseek(stream _ offset _ ptrname);
	errno_save = errno;
	ifnot (var ==0) {
		
		errno = errno_save;
		if (errno!=0) dflags |= DIAG_SYSERR;
		diag(dflags,M_fseek); }
	
	return var;
}
int diag_fname_fseek(dflags _ fname  _  stream _ offset _ ptrname)
int dflags; char* fname; FILE* stream; long offset; int ptrname; {
	int var;
 	int errno_save;
	errno = 0;
	var = fseek(stream _ offset _ ptrname);
	errno_save = errno;
	ifnot (var ==0) {
		
		diag(mask_dflags(dflags),M_fname);
		errno = errno_save;
		if (errno!=0) dflags |= DIAG_SYSERR;
		diag(dflags,M_fseek); }
	
	return var;
}
long diag_ftell(dflags    _  stream)
int dflags;  FILE* stream; {
	long var;
 	int errno_save;
	errno = 0;
	var = ftell(stream);
	errno_save = errno;
	ifnot (var >=0) {
		
		errno = errno_save;
		if (errno!=0) dflags |= DIAG_SYSERR;
		diag(dflags,M_ftell); }
	
	return var;
}
long diag_fname_ftell(dflags _ fname  _  stream)
int dflags; char* fname; FILE* stream; {
	long var;
 	int errno_save;
	errno = 0;
	var = ftell(stream);
	errno_save = errno;
	ifnot (var >=0) {
		
		diag(mask_dflags(dflags),M_fname);
		errno = errno_save;
		if (errno!=0) dflags |= DIAG_SYSERR;
		diag(dflags,M_ftell); }
	
	return var;
}
int diag_fread(dflags    _  ptr _ size _ nitems _ stream)
int dflags;  char* ptr; int size; int nitems; FILE* stream; {
	int var;
 	int errno_save;
	errno = 0;
	var = fread(ptr _ size _ nitems _ stream);
	errno_save = errno;
	ifnot (var ==nitems) {
		
		errno = errno_save;
		if (errno!=0) dflags |= DIAG_SYSERR;
		diag(dflags,M_fread); }
	
	return var;
}
int diag_fname_fread(dflags _ fname  _  ptr _ size _ nitems _ stream)
int dflags; char* fname; char* ptr; int size; int nitems; FILE* stream; {
	int var;
 	int errno_save;
	errno = 0;
	var = fread(ptr _ size _ nitems _ stream);
	errno_save = errno;
	ifnot (var ==nitems) {
		
		diag(mask_dflags(dflags),M_fname);
		errno = errno_save;
		if (errno!=0) dflags |= DIAG_SYSERR;
		diag(dflags,M_fread); }
	
	return var;
}
int diag_fwrite(dflags    _  ptr _ size _ nitems _ stream)
int dflags;  char* ptr; int size; int nitems; FILE* stream; {
	int var;
 	int errno_save;
	errno = 0;
	var = fwrite(ptr _ size _ nitems _ stream);
	errno_save = errno;
	ifnot (var ==nitems) {
		
		errno = errno_save;
		if (errno!=0) dflags |= DIAG_SYSERR;
		diag(dflags,M_fwrite); }
	
	return var;
}
int diag_fname_fwrite(dflags _ fname  _  ptr _ size _ nitems _ stream)
int dflags; char* fname; char* ptr; int size; int nitems; FILE* stream; {
	int var;
 	int errno_save;
	errno = 0;
	var = fwrite(ptr _ size _ nitems _ stream);
	errno_save = errno;
	ifnot (var ==nitems) {
		
		diag(mask_dflags(dflags),M_fname);
		errno = errno_save;
		if (errno!=0) dflags |= DIAG_SYSERR;
		diag(dflags,M_fwrite); }
	
	return var;
}
int diag_fflush(dflags    _  stream)
int dflags;  FILE* stream; {
	int var;
 	int errno_save;
	errno = 0;
	var = fflush(stream);
	errno_save = errno;
	ifnot (var ==0) {
		
		errno = errno_save;
		if (errno!=0) dflags |= DIAG_SYSERR;
		diag(dflags,M_fflush); }
	
	return var;
}
int diag_fname_fflush(dflags _ fname  _  stream)
int dflags; char* fname; FILE* stream; {
	int var;
 	int errno_save;
	errno = 0;
	var = fflush(stream);
	errno_save = errno;
	ifnot (var ==0) {
		
		diag(mask_dflags(dflags),M_fname);
		errno = errno_save;
		if (errno!=0) dflags |= DIAG_SYSERR;
		diag(dflags,M_fflush); }
	
	return var;
}
int diag_fclose(dflags    _  stream)
int dflags;  FILE* stream; {
	int var;
 	int errno_save;
	errno = 0;
	var = fclose(stream);
	errno_save = errno;
	ifnot (var ==0) {
		
		errno = errno_save;
		if (errno!=0) dflags |= DIAG_SYSERR;
		diag(dflags,M_fclose); }
	
	return var;
}
int diag_fname_fclose(dflags _ fname  _  stream)
int dflags; char* fname; FILE* stream; {
	int var;
 	int errno_save;
	errno = 0;
	var = fclose(stream);
	errno_save = errno;
	ifnot (var ==0) {
		
		diag(mask_dflags(dflags),M_fname);
		errno = errno_save;
		if (errno!=0) dflags |= DIAG_SYSERR;
		diag(dflags,M_fclose); }
	
	return var;
}
FILE* diag_popen(dflags    _  command _ type)
int dflags;  char* command; char* type; {
	FILE* var;
 	int errno_save;
	errno = 0;
	var = popen(command _ type);
	errno_save = errno;
	ifnot (var !=NULL) {
		BACK(command) BACK(type)
		errno = errno_save;
		if (errno!=0) dflags |= DIAG_SYSERR;
		diag(dflags,M_popen); }
	
	return var;
}
int diag_pclose(dflags    _  stream)
int dflags;  FILE* stream; {
	int var;
 	int errno_save;
	errno = 0;
	var = pclose(stream);
	errno_save = errno;
	ifnot (var !=-1) {
		
		errno = errno_save;
		if (errno!=0) dflags |= DIAG_SYSERR;
		diag(dflags,M_pclose); }
	
	return var;
}
int diag_fname_pclose(dflags _ fname  _  stream)
int dflags; char* fname; FILE* stream; {
	int var;
 	int errno_save;
	errno = 0;
	var = pclose(stream);
	errno_save = errno;
	ifnot (var !=-1) {
		
		diag(mask_dflags(dflags),M_fname);
		errno = errno_save;
		if (errno!=0) dflags |= DIAG_SYSERR;
		diag(dflags,M_pclose); }
	
	return var;
}
int diag_fork(dflags    )
int dflags;   {
	int var;
 	int errno_save;
	errno = 0;
	var = fork();
	errno_save = errno;
	ifnot (var !=-1) {
		
		errno = errno_save;
		if (errno!=0) dflags |= DIAG_SYSERR;
		diag(dflags,M_fork); }
	
	return var;
}
int diag_execl(dflags    _  path _ PASSARGS)
int dflags;  char* path; PASSDECL {
	int var;
 	int errno_save;
	errno = 0;
	var = execl(path _ PASSARGS);
	errno_save = errno;
	ifnot (var _ 0) {
		BACK(path)
		errno = errno_save;
		if (errno!=0) dflags |= DIAG_SYSERR;
		diag(dflags,M_execl); }
	
	return var;
}
int diag_execv(dflags    _  path _ PASSARGS)
int dflags;  char* path; PASSDECL {
	int var;
 	int errno_save;
	errno = 0;
	var = execv(path _ PASSARGS);
	errno_save = errno;
	ifnot (var _ 0) {
		BACK(path)
		errno = errno_save;
		if (errno!=0) dflags |= DIAG_SYSERR;
		diag(dflags,M_execv); }
	
	return var;
}
int diag_execle(dflags    _  path _ PASSARGS)
int dflags;  char* path; PASSDECL {
	int var;
 	int errno_save;
	errno = 0;
	var = execle(path _ PASSARGS);
	errno_save = errno;
	ifnot (var _ 0) {
		BACK(path)
		errno = errno_save;
		if (errno!=0) dflags |= DIAG_SYSERR;
		diag(dflags,M_execle); }
	
	return var;
}
int diag_execve(dflags    _  path _ PASSARGS)
int dflags;  char* path; PASSDECL {
	int var;
 	int errno_save;
	errno = 0;
	var = execve(path _ PASSARGS);
	errno_save = errno;
	ifnot (var _ 0) {
		BACK(path)
		errno = errno_save;
		if (errno!=0) dflags |= DIAG_SYSERR;
		diag(dflags,M_execve); }
	
	return var;
}
int diag_execlp(dflags    _  path _ PASSARGS)
int dflags;  char* path; PASSDECL {
	int var;
 	int errno_save;
	errno = 0;
	var = execlp(path _ PASSARGS);
	errno_save = errno;
	ifnot (var _ 0) {
		BACK(path)
		errno = errno_save;
		if (errno!=0) dflags |= DIAG_SYSERR;
		diag(dflags,M_execlp); }
	
	return var;
}
int diag_execvp(dflags    _  path _ PASSARGS)
int dflags;  char* path; PASSDECL {
	int var;
 	int errno_save;
	errno = 0;
	var = execvp(path _ PASSARGS);
	errno_save = errno;
	ifnot (var _ 0) {
		BACK(path)
		errno = errno_save;
		if (errno!=0) dflags |= DIAG_SYSERR;
		diag(dflags,M_execvp); }
	
	return var;
}
char* diag_malloc(dflags    _  size)
int dflags;  unsigned size; {
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
char* diag_calloc(dflags    _  nelem _ elsize)
int dflags;  unsigned nelem; unsigned elsize; {
	char* var;
 	int errno_save;
	errno = 0;
	var = calloc(nelem _ elsize);
	errno_save = errno;
	ifnot (var !=NULL) {
		sAL
		errno = errno_save;
		if (errno!=0) dflags |= DIAG_SYSERR;
		diag(dflags,M_calloc); }
	aAL(nelem*elsize)
	return var;
}
void diag_free(dflags    _  ptr)
int dflags;  char* ptr; {
 	int errno_save;
	errno = 0;
	free(ptr);
	errno_save = errno;
	
}
int diag_lstat(dflags    _  path _ buf)
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
int diag_lstatl(dflags    _  path _ buf)
int dflags;  char* path; struct statl* buf; {
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
int diag_readlinkn(dflags    _  path _ buf _ bufsize)
int dflags;  char* path; char* buf; int bufsize; {
	int var;
 	int errno_save;
	errno = 0;
	var = readlinkn(path _ buf _ bufsize);
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
@
