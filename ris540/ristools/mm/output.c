/* Do not alter this SPC information: $Revision: 1.2.29.1 $ */
/*
**	NAME:							output.c
**	AUTHORS:						Terrence McIntyre
**	CREATION DATE:					11/92
**	ABSTRACT:
**	
**	REVISION HISTORY:
*/
 
/*
**	INCLUDES
*/
#include <stdarg.h>
#include "mm.h"

/*
**	DEFINES
*/

/*
**	TYPES
*/

/*
**	FUNCTION PROTOTYPES
*/
#define output_c
#include "output.prt"
#include "sys.prt"

/*
**	VARIABLES
*/
static FILE	*outfp = stdout;
static char outname[PATH_MAX] = "";

#if defined(unix) || defined(WIN32)
extern int	errno;
#endif
#if defined(DOS)
extern volatile int	errno;
#endif


/*
**	FUNCTIONS
*/

/******************************************************************************/

extern void open_output_file(
	char *name)
{
	if ((outfp = fopen(name, "w")) == NULL)
	{
		fprintf(stderr, "%s: Unable to open output file \"%s\": %s\n", exe,
			name, strerror(errno));
		EXIT(1);
	}
	strcpy(outname, name);
}

/******************************************************************************/

extern void output(
	char * fmt, 
	... )
{
	va_list args;
	int		sts;

	va_start(args,fmt);
	sts = vfprintf(outfp, fmt, args);
	va_end(args);
}

/******************************************************************************/

extern void close_output_file(
	int remove_flag)
{
	if (outfp && outfp != stdout)
	{
		if (remove_flag)
		{
			remove(outname);
		}
		fclose(outfp);
	}
}

/******************************************************************************/
