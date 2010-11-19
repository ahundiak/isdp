/* ========================================================================
 * Debug printing routine for all nfm stuff
 * Really seems a bit over kill with each sub system being able to write to
 * a different file
 *
 * Stuff only gets put out if sub system flag is set
 * Keep for now but might do away with it completely
 *
 * Looks like the sub systems flags are getting set somewhere in the init process
 */

#include <stdio.h>
#include <stdarg.h>
#include <string.h>

#include "ERR.h"
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


// void _NFMdebug_function ( va_alist ) va_dcl
void _NFMdebug_function (char *fname, char *format, ...)
{
	char subsystem[9];
	FILE *outfile;
	short do_not_close;

	va_list args;
	char *debug_file;

	/*  Find the subsystem and debug filename  */
  va_start ( args, format );

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
	fprintf (outfile, "%s: %s: ", subsystem, fname);

	/*  Print out remainder of message  */
	vfprintf (outfile, format, args);

	va_end (args);

	/*  Close the file  */

	if (do_not_close == FALSE) fclose (outfile);

	return;
}
