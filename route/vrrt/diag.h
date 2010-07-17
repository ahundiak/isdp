/* $Id: */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrrt/diag.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: diag.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:13:06  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.1  1998/01/16  05:25:10  pinnacle
 * Created: vrrt/diag.h by r250_int for route
 *
 *
 *
 * History:
 *	01/15/98	Onay	Integration date.
 *
 *************************************************************************/

#ifndef _DIAG_
#define _DIAG_

/* See separate documentation about the Common diagnostic modules. */

#include <dflags.h>

#define mask_dflags(dflags) \
	((dflags) & ~(DIAG_EXIT|DIAG_FATAL))

/* The following macros call diag_printf()/diag()/debug() instead of
diag_putc() so that they can return the number of characters
transmitted.  A convenience. */
#define dpSP diag_printf(" ")
#define dpNL diag_printf("\n")
#define dSP diag(0," ")
#define dNL diag(0,"\n")
#define ddSP debug(" ")
#define ddNL debug("\n")

#define debugv(val,fmt) \
	debug(" %s=fmt","val",val)
#define debugs(str) \
	(Debug_tmp = str, debug(" str=%s%s%s", \
	                        Debug_tmp ? "\"" : "", \
	                        Debug_tmp ? Debug_tmp : "NULL", \
	                        Debug_tmp ? "\"" : "" ) )

#define DIAG_ASSERT(dflags,expr) \
	diag_assert(dflags,expr,"expr",__FILE__,__LINE__)
#define DIAG_SWITCH(dflags,sw) \
	diag_switch(dflags,sw,__FILE__,__LINE__)

#define USAGE diag_usage(DIAG_FATAL);
#define MALLOCS { \
	if (Diag_flags & DIAG_MALLOCS) diag_mallocstatus(DIAG_DEBUG); }

#define M_fname 	"File \"%s\": ",fname

/* diag.c */
extern int Diag_flags;
extern FILE* Diag_file;
extern charp Diag_program;
extern charp Diag_usage;
extern int Diag_debug;
extern int Diag_jmp;
extern jmp_buf Diag_jmp_buf;
extern int Diag_newline;
extern charp Debug_tmp;
extern int diag_putc();
extern int diag_puts();
extern int diag_putsn();
extern int diag_vprintf();
extern int diag_printf();
extern int diag();
extern int vdiag();
extern int diag_doflags();
extern int diag_usage();
extern int diag_printusage();
extern int diag_assert();
extern int diag_switch();
extern int debug();
extern int tdebug();
extern int dtdebug();

/*
include <diagstdlib.h>
*/

/* strdflag.c */
extern int strdflag();
extern int diag_strdflag();

/* diagenv.c */
extern void get_diagenv();

#endif
