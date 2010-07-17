/* $Id: */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrrt/dgstdlb.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: dgstdlb.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:13:06  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.1  1998/01/16  05:25:06  pinnacle
 * Created: vrrt/dgstdlb.h by r250_int for route
 *
 *
 *
 * History:
 *	01/15/98	Onay	Integration date.
 *
 *************************************************************************/

extern int diag_mkdir();
extern int diag_chdir();
extern char* diag_getcwd();
extern int diag_link();
extern int diag_unlink();
extern int diag_chmod();
extern int diag_utime();
extern int diag_access();
extern int diag_open();
extern int diag_read(); extern int diag_fname_read();
extern int diag_write(); extern int diag_fname_write();
extern int diag_dup2();
extern off_t diag_lseek(); extern off_t diag_fname_lseek();
extern int diag_close(); extern off_t diag_fname_close();
extern int diag_pipe();
extern int diag_ftruncate(); extern int diag_fname_ftruncate();
extern int diag_ferror(); extern int diag_fname_ferror();
extern FILE* diag_fopen();
extern FILE* diag_fdopen(); extern FILE* diag_fname_fdopen();
extern FILE* diag_freopen();
extern int diag_stat();
extern int diag_statl();
extern int diag_fstat(); extern int diag_fname_fstat();
extern int diag_fstatl(); extern int diag_fname_fstatl();
extern int diag_ustat();
extern int diag_fseek(); extern int diag_fname_fseek();
extern int diag_ftell(); extern int diag_fname_ftell();
extern int diag_fread(); extern int diag_fname_fread();
extern int diag_fwrite(); extern int diag_fname_fwrite();
extern int diag_fflush(); extern int diag_fname_fflush();
extern int diag_fclose(); extern int diag_fname_fclose();
extern FILE* diag_popen();
extern int diag_pclose(); extern int diag_fname_pclose();
extern int diag_fork();
extern int diag_execl();
extern int diag_execv();
extern int diag_execle();
extern int diag_execve();
extern int diag_execlp();
extern int diag_execvp();
extern char* diag_malloc();
extern char* diag_calloc();
extern void diag_free();
extern int diag_lstat();
extern int diag_lstatl();
extern int diag_readlinkn();

extern void diag_mallocstatus();
extern void diag0_free();
