/* $Id:*/

/*************************************************************************
 * I/ROUTE
 *
 * File:        vrrt_STEP/diag.C
 *
 * Description:
 *      This is another copy of the vrrt/diag.C file. This might've undergone
 *      some changes while compiling for MariSTEP. That's the reasin these
 *      files are placed in a different directory.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: diag.C,v $
 *      Revision 1.1.1.1  2001/01/04 21:13:07  cvs
 *      Initial import to CVS
 *
 * Revision 1.4  1999/04/10  17:08:00  pinnacle
 * ah
 *
 * Revision 1.3  1998/12/03  19:27:56  pinnacle
 * Replaced: vrrt_STEP/diag.C for:  by apazhani for route
 *
 * Revision 1.2  1998/11/08  18:58:20  pinnacle
 * ah
 *
 * Revision 1.1  1998/11/06  19:40:32  pinnacle
 * initial revision
 *
 *
 * History:
 *       Date            Name     Description
 *      11/06/98        Alwin     Creation
 *
 *************************************************************************/

/* See separate documentation about the Common diagnostic modules. */

#include <common.h>

int Diag_flags = 0;
FILE* Diag_file = stderr;
static charp Default_progstr = "<program-name>";
charp Diag_program = NULL;
charp Diag_usage = NULL;
int Diag_debug = F;
int Diag_jmp = F; jmp_buf Diag_jmp_buf;
int Diag_newline = T;
charp Debug_tmp;

/* 
 * Hacked by art just to get route to run
 * changed all printf to vprintf
 *
 * These next two functions are standard unix but are not getting
 * linked on clipper for some reason, just put in dummy ones which
 * will almost certainly crash is used but not my problem.
 */
/** Both these dummy functions are not needed. The readlink() function has
been defined in symlink.C file. The lstat is not needed and its usage is 
commented. */

#ifdef ENV5
int readlink() { return 1; }
int lstat() { return 1; }
#endif

/* All I/O to Diag_file should happen through these basic functions.
All do a flush immediately after printing to make sure the user sees
the output even if the program is about to crash. */

#define FL fflush(Diag_file);
int diag_putc(c) int c; { int ret = fputc(c,Diag_file); FL return ret; }
int diag_puts(s) charp s; { int ret = fputs(s,Diag_file); FL return ret; }

/***added by alwin 
int diag_putsn(s) charp s; { int ret = fputsn(s,Diag_file); FL return ret; }
***/
int diag_vprintf(format,ap) charp format; va_list ap; {
	int ret = vfprintf(Diag_file,format,ap); FL return ret; }
int diag_printf(va_alist) va_dcl { va_list ap; charp format; int ret;
	va_start(ap); format = va_arg(ap,charp);
	ret = diag_vprintf(format,ap);
	va_end(ap); return ret; }

int diag(va_alist) va_dcl { int ret;
	va_list ap; int dflags; charp format;
	va_start(ap); dflags = va_arg(ap,int); format = va_arg(ap,charp);
	ret = vdiag(dflags,format,ap);
	va_end(ap); return ret; }

/* This is the function that does all the work.
It returns the number of characters transmitted, so that it
works like printf(). */

extern charp strend(charp);

int vdiag(dflags,format,ap) int dflags; charp format; va_list ap; 
{
	/* Save the operating system error number in case something
	we do affects it between now and the time we print it.
	See W. Richard Stevens, Advanced Programming in the Unix
	Environment, p. 23, 688, 279. */
	int errno_save = errno;
	charp end; int endc; int changedend;
	int nc = 0;

	dflags |= mask_dflags(Diag_flags);
	if (dflags & DIAG_QUIET) goto after_print;
        if (dflags & DIAG_DEBUG && !Diag_debug) goto after_print;

	/* Print dflags strings, but only if this call to vdiag() is currently
	at the beginning of a line.  (Obviously we can't really be sure.
	For one thing, Diag_newline is referenced only here in vdiag().) */
	if (Diag_newline) nc += diag_doflags(dflags);

	/* Now determine whether to end the coming message with a newline. */
	Diag_newline = F; changedend = F;
	end = strend(format); if (end > format && (endc = *(end-1))=='\n') {
		*(end-1) = '\0'; changedend = T; Diag_newline = T; }
	/* For output readability, separate the caller's message from
	additional messages we may print (see below). */
	if (dflags & (DIAG_USAGE|DIAG_FATAL|DIAG_EXIT)) Diag_newline = T;
	
	/* Print. */
	nc += diag_vprintf(format,ap);

	if (changedend) *(end-1) = endc;

	/* If the user wants the system error message, print it at the
	end of his message but before the terminating newline if
	there is one. */
	                            /* sanity check */
	if (dflags & DIAG_SYSERR && inrange(errno_save,1,sys_nerr-1))
		nc += diag_vprintf(": %s",sys_errlist[errno_save]);

	/* Print newline.  Remember for the next call to vdiag(). */
	if (Diag_newline) nc += dpNL;

	/* Print calling program's usage message if desired. */
	if (dflags & DIAG_USAGE) nc += diag_printusage();

#define JMPCALL longjmp(Diag_jmp_buf,1)
#define JMPMSG(x) "Calling x"
#define CORECALL abort()
#define COREMSG(x) "Calling x. A core dump will be generated."

	after_print:
	if (dflags & DIAG_EXIT || dflags & DIAG_FATAL) {
		if (Diag_jmp) {
			nc += diag_vprintf("%s: %s\n",
			 __FILE__,JMPMSG(JMPCALL));
			JMPCALL; }
		if (dflags & DIAG_CORE) {
			nc += diag_vprintf("%s: %s\n",
			 __FILE__,COREMSG(CORECALL));
			CORECALL; }
		exit(dflags & DIAG_FATAL ? ERROR : OKAY); }

	return nc; }

int diag_doflags(dflags) int dflags; 
{
        int dodate = dflags & DIAG_DATE;
	int dotime = dflags & DIAG_TIME;
	char buf[MAXSTR+2]; charp dir;
	int nc = 0;
	if (dodate || dotime) {
		static char* dfmt = "%a %h %d %C%y";
		static char* tfmt = "%H:%M:%S";
		long clock; time(&clock);

		/*** Commenting this peice of code, as we couldn't find the
		source code corresponding to the function "nnl_ctime", moreover
		I beleive this functions has something to do with CLIX 
		workstation. Alwin

                if (dodate) nc += diag_vprintf("%s ",nnl_ctime(&clock,dfmt,0));
                if (dotime) nc += diag_vprintf("%s ",nnl_ctime(&clock,tfmt,0));

		***/
	}
	if (dflags & DIAG_PID)
		nc += diag_vprintf("%5d ",getpid());
	if (dflags & DIAG_DIR)
		nc += diag_vprintf("%s ",
		 (dir = getcwd(buf,MAXSTR)) ? dir : "(Dir unknown)");
	if (dflags & DIAG_PROGRAM && Diag_program)
		nc += diag_vprintf("%s: ",Diag_program);
	if (dflags & DIAG_WARNING)
		nc += diag_vprintf("Warning: ");
	return nc; 
}

int diag_usage(dflags) int dflags; { return diag(dflags|DIAG_USAGE,"\n"); }

int diag_printusage() {
	if (Diag_usage)
		return diag_vprintf("Usage: %s %s\n",
		 Diag_program?Diag_program:Default_progstr,Diag_usage);
	else { 	int nc = 0;
		if (Diag_program) nc += diag_vprintf("%s: ",Diag_program);
		nc += diag_vprintf("Incorrect usage\n");
		return nc; } }

/* Notice that this returns the condition, not the number of
characters transmitted like the others. */
int diag_assert(dflags,cond,str,fname,lineno)
 int dflags; int cond; charp str; charp fname; int lineno; {
	ifnot (cond) diag(dflags,
"Assertion failed: source file %s, line %d: %s\n",fname,lineno,str);
	return cond; }

int diag_switch(dflags,sw,fname,lineno)
 int dflags; int sw; charp fname; int lineno; {
	return diag(dflags,
"Unknown switch %d: source file %s, line %d\n",sw,fname,lineno); }

#define DEFINE_FUNC(name,dflags) \
int name(va_alist) va_dcl { int ret; \
	va_list ap; charp format; \
	va_start(ap); format = va_arg(ap,charp); \
	ret = vdiag(dflags|DIAG_DEBUG,format,ap); \
	va_end(ap); return ret; }
DEFINE_FUNC(debug,0)
DEFINE_FUNC(tdebug,DIAG_TIME)
DEFINE_FUNC(dtdebug,DIAG_DATE|DIAG_TIME)
