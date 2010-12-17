#include <sys/types.h>
#include <string.h>
#include <stdio.h>
#include "UMSfile.h"
#include "UMCcomp.h"
#include "COMP.h"
#include "UMS.h"
#include "UMSpriv.h"
#include "UMSgetop.h"
#include "pums_all.h"
#include "pumc_all.h"

THREAD_DECL static char logFile[256];
THREAD_DECL static FILE *UMSLogFilePtr = NULL;

void UMCWriteLogComments(char *string)
{
    fprintf(UMSLogFilePtr, "%s\n", string);
}

void UMCCloseLogFile()
{
    fclose(UMSLogFilePtr);
}

int UMCOpenLogFile(char *filename)
{
    UMSLogFilePtr = fopen(filename, "w");
    return((int)UMSLogFilePtr);
}

/******************************************************************************

Doc:	UMSExpandBackslash

Abstract:
	This function expands backslashes in strings to two backslashes.

History:

	05-19-93	sml	Created

******************************************************************************/

void UMSExpandBackslash(char * instring, char * outstring)
{
  int ii, jj, len;


  len = strlen(instring);
  for (ii = 0, jj = 0; ii < len; ii++)
  {
    outstring[jj++] = instring[ii];
    if (instring[ii] == '\\')
    {
      outstring[jj++] = '\\';
    }
  } 
  outstring[jj] = '\0';
}






/******************************************************************************

Doc:	UMScompile

Abstract:
	This file compiles message text files and creates
	matching programming files.

History:

	10-22-91	sml	Created, with design by Jeff Johnson
        04-11-94        sml     Open log file for win32s compatibility
        
******************************************************************************/

int UMScompile(char *text_file, char *message_file, char *c_include, char *for_include)

{
UMCFileData	fileData;
int		sts, progFlag;
char		mod_textfile[256];


/* sml:10-22-91		This is a vestige of the code when it was in
					the main routine of the compiler.  It's not 
					needed here.
	sts = UMCInitCOMP( argv[0] );
	if ( sts != COMP_S_SUCCESS )
	{
		fprintf( stderr, "Process terminated\n" );
		exit( 1 );
	}
*/
        /*******************************************************/
        /* sml:04-01-94:NO TR                                  */
        /*  Open log file here if compiling inside the program */
	/* sml:05-13-94:NO TR                                  */
	/*  check if UMSLogFilePtr has already been set.       */
        /*******************************************************/

	if (UMSLogFilePtr == NULL)
	{
          UMCOpenLogFile("risumscc.log");
	}
          
	fileData.idxAlloc = 0;
	fileData.fileIdx = ( long * )0;
	fileData.textAlloc = 0;
	fileData.textBuf = ( char * )0;
	fileData.extAlloc = 0;
	fileData.extBuf = ( char * )0;
	fileData.key2Alloc = 0;
	fileData.key2Buf = ( char * )0;

	UMSExpandBackslash(text_file, mod_textfile);
	UMCErrorMsg( COMP_M_PROCESSING, "%s", mod_textfile );

	sts = UMCReadTxt( text_file, &fileData );
	if ( sts != COMP_S_SUCCESS )
	{
		if (sts == COMP_F_OPENTEXT)
			sts = UMS_E_NOFILE;
		else if (sts == COMP_F_EMPTYFILE)
			sts = UMS_E_READ;
		else 
			sts = UMS_E_COMPILE;
		goto error_exit;
	}

	sts = UMCWriteMsg( message_file, &fileData );
	if ( sts != COMP_S_SUCCESS )
	{
		sts = UMS_E_OPEN;
		goto error_exit;
	}
    if (c_include)
	  progFlag = UMC_CFILE;
	else if (for_include)
	  progFlag = UMC_FORFILE;
	else
	  progFlag = UMC_NOFILE;

	if ( progFlag == UMC_CFILE )
	{
		sts = UMCWriteH( c_include, &fileData );
		if ( sts != COMP_S_SUCCESS )
		{
			sts = UMS_E_OPEN;
			goto error_exit;
		}

	}
	else if ( progFlag == UMC_FORFILE )
	{
		sts = UMCWriteInc( for_include, &fileData );
		if ( sts != COMP_S_SUCCESS )
		{
			sts = UMS_E_OPEN;
			goto error_exit;
		}
	}

	return( UMS_S_SUCCESS );

error_exit:
	UMCErrorMsg( COMP_M_TERMINATED, 0 );
	UMCCloseLogFile();      /* sml:04-13-94:added */
	return( sts );
}

/******************************************************************************

Doc:	UMCCmdLine

Abstract:
	The UMCCmdLine function interprets the command line arguments.

Return Status:
	COMP_S_SUCCESS		-	Success
	COMP_F_INVCMDOPT	-	Invalid command line options
	COMP_F_NOTEXTFILE	-	No text file specified
	COMP_F_TOOMANYTEXT	-	More than one text file specified

History:
	15-MAR-1989	sh	Creation date
	04-NOV-1989	tz	Update for UMS 2.0 and I/FORMS
	12-NOV-1991	sml	add code for PC 
				  check for backslash pathname delimiter
				  use PC getopt
				  add extra check for executable name
        23-JUN-1993     sml     add logFile argument with -l option
				
******************************************************************************/

int	UMCCmdLine( argc, argv, progFlag, textFile, msgFile, progFile )

int	argc;			/* i - Number of command line arguments	*/
char	*argv[];		/* i - Command line arguments		*/
int	*progFlag;		/* o - Programming file to create
					UMC_NOFILE - No programming file
					UMC_CFILE - C header file
					UMC_FORFILE - Fortran inc file	*/
char	*textFile;		/* o - Message text file		*/
char	*msgFile;		/* o - Indexed message file (-m option)	*/
char	*progFile;		/* o - Programming file (-p option)	*/
{
	
extern int UMSgetopt();

#define	UMC_COMPTXT	"umcmptxt"
#define	UMC_COMPILE	"risumscc"
#define	DOS_UMC_COMPILE	"RISUMSCC.EXE"

THREAD_DECL extern	int	UMSoptind, UMSopterr;
THREAD_DECL extern	char	UMSoptarg[];       /* sml:changed to have memory */
int		opt, sts;
char		*cmdName;
char            mod_arg0[256];


        strcpy(logFile, "risumscc.log");
/*        UMSLogFilePtr = fopen(logFile, "w"); */
        UMCOpenLogFile(logFile);
	cmdName = strrchr( argv[0], '/' );
	if ( cmdName )
		cmdName++;
	else
	{
	/* add code to check for backslash for DOS */
		cmdName = strrchr( argv[0], '\\' );
		if (cmdName)
			cmdName++;
		else
			cmdName = argv[0];
	}
	textFile[0] = msgFile[0] = progFile[0] = '\0';
	*progFlag = ( strcmp( cmdName, UMC_COMPILE ) &&
		strcmp(cmdName, DOS_UMC_COMPILE) ) ? UMC_NOFILE : UMC_CFILE;

	UMSopterr = 0;
	while ( ( ( opt = UMSgetopt( argc, argv, "m:p:l:F" ) ) != NONOPT )
		|| (UMSoptarg[0] != (char) NULL ) ) 
	{
		if ( opt == ( int )'m' )
			strcpy( msgFile, UMSoptarg );
		else if ( opt == ( int )'p' && *progFlag != UMC_NOFILE )
			strcpy( progFile, UMSoptarg );
		else if ( opt == ( int )'F' && *progFlag != UMC_NOFILE )
			*progFlag = UMC_FORFILE;
		/* sml:06-23-93 add -l switch for logFile */
		else if ( opt == (int) 'l')
		{
		    char comment[256];
		    
		        strcpy(logFile, UMSoptarg);
		        sprintf(comment, "Log File Name is %s\n", logFile);
		        UMCWriteLogComments(comment);
		        UMCCloseLogFile();
		        if (!UMCOpenLogFile(logFile))
		        {
		            UMCOpenLogFile("risumscc.log");
         		    sprintf(comment,
                                "Log File Name %s could not be opened\nUsing default log filename risumscc.log\n", logFile);
		            UMCWriteLogComments(comment);
		        }
		}
		/* sml:09-19-91		add this for C's getopt */
		else if (opt == NONOPT /*&& *progFlag != UMC_NOFILE*/)
		{
			/* check if textFile has already been set */
			if (textFile[0] != '\0')
			{
			  sts = COMP_F_TOOMANYTEXT;
                	  /* sml:06-24-93 print message after usage_msg */
			/*  UMCErrorMsg(sts, 0); */
			  goto usage_msg;
			}
			else
			  strcpy(textFile, UMSoptarg);
		}
		/* check if valid option */
		else if (opt != (int)'m' && opt != (int)'p' && opt != (int)'F')
		{
			sts = COMP_F_INVCMDOPT;
                	  /* sml:06-24-93 print message after usage_msg */
			/* UMCErrorMsg( sts, 0 ); */
			goto usage_msg;
		}
	}
	
	/* check if textFile option given */
	if (!textFile)
	{
	  sts = COMP_F_NOTEXTFILE;
	  /* sml:06-24-93 print message after usage_msg */
	  /* UMCErrorMsg(sts, 0); */
	  goto usage_msg;
	}

/*
 * sml:09-19-91		comment out for now
   sml:11-12-91		Check for this above

	if ( UMSoptind == argc - 1 )
		strcpy( textFile, argv[UMSoptind] );
	else
	{
		if ( UMSoptind == argc )
			sts = COMP_F_NOTEXTFILE;
		else
			sts = COMP_F_TOOMANYTEXT;
		UMCErrorMsg( sts, 0 );
		goto usage_msg;
	}
*/
	return( COMP_S_SUCCESS );

usage_msg:
        /* sml:06-24-93 print error message here after getting log file name */
	UMCErrorMsg( sts, 0 ); 

	UMSExpandBackslash(argv[0], mod_arg0);
	if ( *progFlag == UMC_NOFILE )
		UMCErrorMsg( COMP_M_TXTUSAGE, "%s", mod_arg0 );
	else
		UMCErrorMsg( COMP_M_DEVUSAGE, "%s", mod_arg0 );
	UMCCloseLogFile();      /* sml:04-13-94:added */
	return( sts );
}

/******************************************************************************

Doc:	UMCDefNames

Abstract:
	If the message file and/or the programming file were not specified
	on the command line, the UMCDefNames function generates the names
	from the name of the text file.

Return Status:
	COMP_S_SUCCESS	-	Success

History:
	15-MAR-1989	sh	Creation date
	04-NOV-1989	tz	Renamed from UMSMsgName/Updated for UMS 2.0

******************************************************************************/

int	UMCDefNames( progFlag, textFile, msgFile, progFile )

int	progFlag;		/* i - Programming file to create
					UMC_NOFILE - No programming file
					UMC_CFILE - C header file
					UMC_FORFILE - Fortran inc file	*/
char	*textFile;		/* i - Message text file		*/
char	*msgFile;		/* i/o - Indexed message file		*/
char	*progFile;		/* i/o - Programming file		*/
{
char	*name, *dir, *ext;
char	tmpText[UMC_FILELEN], tmpFile[UMC_FILELEN];
char	tmpmsgFile[UMC_FILELEN], tmpprogFile[UMC_FILELEN];

/* sml:05-19-93	use a variable pathname delimiter since we're in both
		DOS and UNIX world now.
*/
char	delimiter = '\\';

	strcpy( tmpText, textFile );
	if ( ( name = strrchr( tmpText, '/' ) ) != NULL )
	{
		*name++ = '\0';
		dir = tmpText;
		delimiter = '/';
	}
	else if ( ( name = strrchr( tmpText, '\\' ) ) != NULL )
	{
		*name++ = '\0';
		dir = tmpText;
		delimiter = '\\';
	}
	else
	{
		name = tmpText;
		dir = ".";
	}

	if ( ( ext = strrchr( name, '.' ) ) != NULL )
		*ext = '\0';
	if ( strlen( name ) > 10 )
		name[10] = '\0';

	/* sml:06-23-93 if the delimiter is still #, check if there's
                        a slash or backslash in this filename
        */	
	strcpy( tmpmsgFile, msgFile );
	if ( strrchr( tmpmsgFile, '/' ) != NULL )
	{
		delimiter = '/';
	}
	else if ( strrchr( tmpmsgFile, '\\' ) != NULL )
	{
		delimiter = '\\';
	}

	/* sml:06-23-93 if the delimiter is still #, check if there's
                        a slash or backslash in this filename
        */	
	strcpy( tmpprogFile, progFile );
	if ( strrchr( tmpprogFile, '/' ) != NULL )
	{
		delimiter = '/';
	}
	else if ( strrchr( tmpprogFile, '\\' ) != NULL )
	{
		delimiter = '\\';
	}




	if ( msgFile[0] == '\0' )
		sprintf( msgFile, "%s%c%s.msg", dir, delimiter, name );
	if ( msgFile[0] != delimiter && msgFile[0] != '.' && msgFile[1] != ':')
	{
		strcpy( tmpFile, msgFile );
/*		sprintf( msgFile, ".%c%s", delimiter, tmpFile ); */
		sprintf( msgFile, "%s", tmpFile );
	}

	if ( progFlag != UMC_NOFILE )
	{
		if ( progFile[0] == '\0' )
			sprintf( progFile, "%s%c%s.%s", dir, delimiter, name,
				 ( progFlag == UMC_CFILE ) ? "h" : "inc" );
		if ( progFile[0] != delimiter && progFile[0] != '.' 
			&& progFile[1] != ':' )
		{
			strcpy( tmpFile, progFile );
/*			sprintf( progFile, ".%c%s", delimiter, tmpFile );*/
			sprintf( progFile, "%s", tmpFile );
		}
	}

	return( COMP_S_SUCCESS );
}
