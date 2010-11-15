#include <sys/types.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include "UMSfile.h"
#include "UMCcomp.h"
#include "COMP.h"

#include "UMSpriv.h"
#include "pums_all.h"
#include "pumc_all.h"

/******************************************************************************

Doc:	main

Abstract:
	This program compiles message text files and optionally creates
	matching programming files.

History:
	15-MAR-1989	sh	Creation date
	04-NOV-1989	tz	Update for UMS 2.0 and I/FORMS

******************************************************************************/

main( argc, argv )

int	argc;
char	*argv[];
{
/*UMCFileData	fileData;	not used */
int		sts, progFlag;
char		textFile[UMC_FILELEN], msgFile[UMC_FILELEN], progFile[UMC_FILELEN];

	sts = UMCInitCOMP( argv[0] );
	if ( sts != COMP_S_SUCCESS )
	{
	        /* sml:06-24-93 This always returns SUCCESS, but comment
	                        this out just in case for win32s apps
		fprintf( stderr, "Process terminated\n" );
		*/
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

	/**********************************************

	sml:05-17-93	Add exit for exit status of 0

	***********************************************/

	/*sml:06-24-93 close the log file here and after error_exit */
/*	fclose(UMSLogFilePtr); */
        UMCCloseLogFile();
        
	if (sts == UMS_S_SUCCESS || sts == COMP_S_SUCCESS)
	  exit(0);

error_exit:
	UMCErrorMsg( COMP_M_TERMINATED, 0 );
        UMCCloseLogFile();
	exit( 1 );
	return(0);
}

