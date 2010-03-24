#include <sys/types.h>
#include <string.h>
#include <stdio.h>
#include <UMSfile.h>
#include <UMCcomp.h>
#include <COMP.h>

#include <UMSpriv.h>	/* include in order  to use pums_all.h */
#include <stdarg.h>		/* include in order  to use pums_all.h */
#include <pums_pub.h>
#include <pums_pri.h>

/******************************************************************************

Doc:	main

Abstract:
	This program compiles message text files and optionally creates
	matching programming files.

History:
	15-MAR-1989	sh	Creation date
	04-NOV-1989	tz	Update for UMS 2.0 and I/FORMS
	30-DEC-1991	sml	Add exit before final label

******************************************************************************/

main( int argc, char *argv[] )
{
int		sts, progFlag;
char	textFile[UMC_FILELEN], msgFile[UMC_FILELEN], progFile[UMC_FILELEN];

	sts = UMCInitCOMP( argv[0] );
	if ( sts != COMP_S_SUCCESS )
	{
		fprintf( stderr, "Process terminated\n" );
		exit( 1 );
	}

	sts = UMCCmdLine( argc, argv, &progFlag, textFile, msgFile, progFile );
	if ( sts != COMP_S_SUCCESS )
		goto error_exit;

	sts = UMCDefNames( progFlag, textFile, msgFile, progFile );

	if (progFlag == UMC_NOFILE)
	{
	  sts = UMScompile(textFile, msgFile, 0, 0);
	}
	else if (progFlag == UMC_CFILE)
	{
	  sts = UMScompile(textFile, msgFile, progFile, 0);
	}
	else if (progFlag == UMC_FORFILE)
	{
	  sts = UMScompile(textFile, msgFile, 0, progFile);
	}

	/* sml:12-30-91		Add exit to avoid falling through label */
	exit(0);

error_exit:
	UMCErrorMsg( COMP_M_TERMINATED, 0 );
	exit( 1 );
}

