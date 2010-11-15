/*
**      NAME:                       dlddebug.c
**      AUTHORS:                    Hitesh R. Patel
**      CREATION DATE:              4/93
**      ABSTRACT:
**              
**      
**      REVISION HISTORY:
*/
 
/*
**      INCLUDES
*/
#include <stdio.h>
#include <stdarg.h>
#if defined(WIN32)
#include <windows.h>
#endif
#include "dload.h"

/*
**      DEFINES
*/

#if defined(unix)
# define DEBUG_DIR      "/usr/tmp/"
#endif
#if defined(WIN32) || defined(DOS)
# define DEBUG_DIR      "c:\\tmp\\"
#endif

#define DLD_DEBUG_INPUT_FILE            "risdld"
#define DLD_DEFAULT_OUTPUT_FILE         "risdld.out"

#define DEFAULT_OUTPUT_FILE             "ris.out"

#ifdef DEBUG
# undef DEBUG
#endif

/*
**      TYPES
*/

/*
**      FUNCTION PROTOTYPES
*/
#define dlddebug_c
#include "dlddebug.prt"
#include "sys.prt"

/*
**      VARIABLES
*/
static char debug_output_device[RIS_MAX_PATH_SIZE] = "";
static FILE     *debug_fp = NULL;

/*
**      FUNCTIONS
*/

/******************************************************************************/

extern void RISdld_initialize_debug(
	void)
{
	char    buf[RIS_MAX_PATH_SIZE];
	FILE    *fp;

	if (debug_output_device[0])
	{
		return;
	}

	/*
	** Check the existacne of DLD_DEBUG_INPUT_FILE
	*/
	sprintf(buf, "%s%s", DEBUG_DIR, DLD_DEBUG_INPUT_FILE);

	sprintf(debug_output_device, "%s%s", DEBUG_DIR, DLD_DEFAULT_OUTPUT_FILE);

	if ((fp = fopen(buf, "r")) == NULL)
	{
		return;
	}

	if( fgets(buf, sizeof(buf), fp) != NULL )
	{
		/*
		** Open DLD_DEBUG_OUTPUT_FILE
		*/
		if ((debug_fp = fopen(debug_output_device, "w")) == NULL)
		{
			fclose(fp);
			return;
		}
		RISdld_debug = 1;
	}

	fclose(fp);
}

/******************************************************************************/

extern void RISdld_set_debug_output_device(
	char    *output_device)
{
	strcpy(debug_output_device, output_device);
}

/******************************************************************************/

extern int RISdld_output_debug(
	const char *fmt,
	...)
{
	int             sts;
	va_list         args;

	if (!debug_fp)
	{
		return 0;
	}

	va_start(args, fmt);
	sts = vfprintf(debug_fp, fmt, args);
	fflush(debug_fp);
	va_end(args);

	return sts;
}

/******************************************************************************/
