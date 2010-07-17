/* $Id: */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vrrt/cmmnxt.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: cmmnxt.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:13:06  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.1  1998/01/16  05:24:48  pinnacle
 * Created: vrrt/cmmnxt.h by r250_int for route
 *
 *
 *
 * History:
 *	01/15/98	Onay	Integration date.
 *
 *************************************************************************/

#ifndef _COMMONEXT_
#define _COMMONEXT_

/* Declarations for most functions defined in the Common library. */

/* time.c */
extern charp nnl_ctime();
extern charp nl_ctime();
extern charp tmformat();

/* symlink.c */
extern int lstatl();
extern int readlinkn();

/* min.c */
#define DECLARE_MFUNCS(t,type) \
extern type self3(min,t,func)(); \
extern type self3(max,t,func)();
DECLARE_MFUNCS(,int)
DECLARE_MFUNCS(l,long)
DECLARE_MFUNCS(d,double)

/* cmp.c */
#define DECLARE_CMPINTFUNC(type) \
extern int self(type)_to_cmpint();
DECLARE_CMPINTFUNC(int)
DECLARE_CMPINTFUNC(long)
DECLARE_CMPINTFUNC(float)
DECLARE_CMPINTFUNC(double)
extern int str_cmp();
extern int pointercmp();
extern int pointercmp_int();
extern int pointercmp_long();

/* mem.c */
extern charp membcpy();
extern charp memcopy();
extern charp membcopy();

/* arrays.c */
DECLARE_AFUNCS(short)   DECLARE_AIOFUNCS(short) DECLARE_ANUMFUNCS(short)
DECLARE_AFUNCS(int)     DECLARE_AIOFUNCS(int)   DECLARE_ANUMFUNCS(int)
DECLARE_AFUNCS(long)    DECLARE_AIOFUNCS(long)  DECLARE_ANUMFUNCS(long)
DECLARE_AFUNCS(pointer)
extern pointer mda_new();
extern void mda_free();

/* tolower.c */
extern int tolower_func();
extern int toupper_func();

/* str.c */
extern charp strend();
extern charp str0end();
extern int strlastc();
extern charp strcate();
extern charp strncate();
extern charp basename();
extern charp lunsp_str();
extern charp runsp_str();
extern charp unsp_str();
extern charp strcopy();
extern charp strncopy();
extern charp str_copy();
extern charp strconvert();
extern int strcheck();
extern charp strreverse();
extern int strnimatch();
extern int strimatch();
extern int strnematch();
extern int strematch();
extern charp tfstr();
extern charp strfind();
extern charp strbcpy();
extern charp strnbcpy();
extern charp undelim_str();
extern charp strlprefix();
extern charp strrprefix();
extern charp strlsuffix();
extern charp strrsuffix();
extern int xdigit_char();
extern charp xdigit_str();
extern charp ctype_str();

/* csprintf.c */
extern charp csprintf();

/* detab.c */
extern charp detab_col();
extern charp detab();

/* backc.c */
extern int ubcsearch();
extern int bcsearch();
extern int unbackc_info();
extern int unback_str();
extern charp backc_info();
extern charp backc();
extern charp back_str();
extern char backbufa[NBACKBUF][MAXSTR];
extern charp nextbackbuf();

/* crange.c */
extern charp expand_cranges();

/* search.c */
extern int strsearch();

/* mode.c */
extern int cumask();
extern charp fmodestr();
extern charp ftypestr();
extern int check_fmode();
extern int check_umask();
extern int diag_check_fmode();
extern int diag_check_umask();

/* commonio.c */
extern void spn();
extern void nln();
extern void tabn();
extern charp getsn();
extern charp fgetsn();
extern int putsn();
extern int fputsn();
#define COMMONIO_LINELEN (4*KB)
extern char Commonio_line[];
extern charp commonio_getline();
#define DECLARE_IOFUNCS(type) \
extern void self(type)_write(); \
extern void self(type)_read();
DECLARE_IOFUNCS(short)
DECLARE_IOFUNCS(int)
DECLARE_IOFUNCS(long)
DECLARE_IOFUNCS(double)
DECLARE_IOFUNCS(charp)
DECLARE_IOFUNCS(str)

/* digits.c */
extern int digits(); 
extern int digitsl();

/* datoi.c */
extern int datoi();
extern long datol();
extern int diag_datoi();
extern long diag_datol();

#endif
