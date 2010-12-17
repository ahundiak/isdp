
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include <stdio.h>

/* 12/17/92 - KT - SUN Port */
/* __unix__ changed to OS_CLIX - SSRS - 27 Dec 93 */
#ifdef OS_CLIX
#include <stdarg.h>
#endif
/* #ifdef sparc changed to read as follwing to take care of sco MVR 16 Dec 93 */
/* Modified to support SGI. 030394 MaC */

#if (defined (__sgi) || defined( OS_SUNOS ) || defined( OS_SOLARIS ) || \
     defined(OS_SCO_UNIX ) || defined (OS_HPUX) )
#include <varargs.h>
#endif

#include "DEBUG.h"

#ifndef TRUE
#define TRUE  1
#endif
#ifndef FALSE
#define FALSE 0
#endif

struct _NFMdebug_st _NFMdebug_st = 
{ 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
  "/dev/console", "/dev/console", "/dev/console",
  "/dev/console", "/dev/console", "/dev/console",
  "/dev/console", "/dev/console", "/dev/console", 
  "/dev/console", "/dev/console" };

/* 12/8/92 - KT - SUN port. Variable argument lists are handled differently. */

#ifdef OS_CLIX
void _NFMdebug_function (char *fname, char *format, ...)
#endif

/* #ifdef sparc changed to read as follwing to take care of sco MVR 16 Dec 93 */

#if (defined (__sgi) || defined( OS_SUNOS ) || defined( OS_SOLARIS ) || \
     defined(OS_SCO_UNIX ) || defined (OS_HPUX) )
void _NFMdebug_function ( va_alist )
va_dcl
#endif

  {

/* #ifdef sparc changed to read as follwing to take care of sco MVR 16 Dec 93 */

#if (defined (__sgi) || defined( OS_SUNOS ) || defined( OS_SOLARIS ) || \
     defined(OS_SCO_UNIX ) || defined(OS_HPUX) )
	char *fname;
	char *format;
#endif
	auto	char subsystem[9];
	auto	FILE *outfile;
	auto	short do_not_close;
	auto	va_list args;
	static	char *debug_file;

	/*  Find the subsystem and debug filename  */

/* 12/8/92 - KT - SUN port */
/* #ifdef sparc changed to read as follwing to take care of sco MVR 16 Dec 93 */
#if (defined (__sgi) || defined( OS_SUNOS ) || defined( OS_SOLARIS ) || \
     defined(OS_SCO_UNIX ) || defined (OS_HPUX) )
        va_start ( args );

	fname = va_arg ( args, char *);
	format = va_arg ( args, char *);
#endif

	switch (_NFMdebug_st.subsystem)
	  {
		case NFIDEBUG:
			strncpy (subsystem, "NFI", sizeof (subsystem) - 1);
			debug_file = _NFMdebug_st.NFIdebug_file;
			break;

		case NFMRDEBUG:
			strncpy (subsystem, "NFMR", sizeof (subsystem) - 1);
			debug_file = _NFMdebug_st.NFMRdebug_file;
			break;

		case NETCDEBUG:
			strncpy (subsystem, "NETC", sizeof (subsystem) - 1);
			debug_file = _NFMdebug_st.NETCdebug_file;
			break;

		case NETSDEBUG:
			strncpy (subsystem, "NETS", sizeof (subsystem) - 1);
			debug_file = _NFMdebug_st.NETSdebug_file;
			break;

		case NFMSDEBUG:
			strncpy (subsystem, "NFMS", sizeof (subsystem) - 1);
			debug_file = _NFMdebug_st.NFMSdebug_file;
			break;

		case NFMDEBUG:
			strncpy (subsystem, "NFM", sizeof (subsystem) - 1);
			debug_file = _NFMdebug_st.NFMdebug_file;
			break;

		case SQLDEBUG:
			strncpy (subsystem, "SQL", sizeof (subsystem) - 1);
			debug_file = _NFMdebug_st.SQLdebug_file;
			break;

		case MEMDEBUG:
			strncpy (subsystem, "MEM", sizeof (subsystem) - 1);
			debug_file = _NFMdebug_st.MEMdebug_file;
			break;

		case UTIDEBUG:
			strncpy (subsystem, "UTI", sizeof (subsystem) - 1);
			debug_file = _NFMdebug_st.UTIdebug_file;
			break;

		case ERRDEBUG:
			strncpy (subsystem, "ERR", sizeof (subsystem) - 1);
			debug_file = _NFMdebug_st.ERRdebug_file;
			break;

		case TLIDEBUG:
			strncpy (subsystem, "TLI", sizeof (subsystem) - 1);
			debug_file = _NFMdebug_st.TLIdebug_file;
			break;
		default:
			return;
	  }

	/*  Open the debug file  */

	if ((strcmp (debug_file, "")) == 0)
	  {
		/*  Default to stderr  */

		outfile = stderr;

		do_not_close = TRUE;
	  }
	else
	  {
		if ((outfile = fopen (debug_file, "a")) == NULL)
			return;

		do_not_close = FALSE;
	  }

	/*  Print out name of the subsystem and calling function  */

/* KT - 1/6/93 - SUN Port */
#ifdef OS_CLIX
        va_start (args, format);
#endif

	fprintf (outfile, "%s: %s: ", subsystem, fname);

	/*  Print out remainder of message  */

	vfprintf (outfile, format, args);

	va_end (args);

	/*  Close the file  */

	if (do_not_close == FALSE)
		fclose (outfile);

	return;
  }
