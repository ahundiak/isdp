#include <sys/types.h>
#include <string.h>
#include <stdio.h>
#include <getopt.h>
#include <UMSfile.h>
#include <UMCcomp.h>
#include <COMP.h>
#include <UMS.h>

#include <pums_pub.h>
#include <pums_pri.h>

/******************************************************************************

Doc:	UMScompile

Abstract:
	This file compiles message text files and creates
	matching programming files.

History:

	10-22-91	sml	Created, with design by Jeff Johnson

******************************************************************************/

UMScompile(char *text_file, char *message_file, char *c_include,
    char *for_include)
{
UMCFileData	fileData;
int		sts, progFlag;

	fileData.idxAlloc = 0;
	fileData.fileIdx = ( long * )0;
	fileData.textAlloc = 0;
	fileData.textBuf = ( char * )0;
	fileData.extAlloc = 0;
	fileData.extBuf = ( char * )0;
	fileData.key2Alloc = 0;
	fileData.key2Buf = ( char * )0;

	UMCErrorMsg( COMP_M_PROCESSING, "%s", text_file );

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

    int	argc;			i - Number of command line arguments	
    char	*argv[];	i - Command line arguments		
    int	*progFlag;	    o - Programming file to create
    					UMC_NOFILE - No programming file
    					UMC_CFILE - C header file
    					UMC_FORFILE - Fortran inc file
    char	*textFile;	 o - Message text file	
    char	*msgFile;	 o - Indexed message file (-m option)
    char	*progFile;	 o - Programming file (-p option)
				
******************************************************************************/

int	UMCCmdLine( int argc, char *argv[], int *progFlag, char *textFile,
      char *msgFile, char *progFile )
{
	

/* sml:10-08-91		change names to match 8.3 PC convention
#define	UMC_COMPTXT	"umscomptxt"
#define	UMC_COMPILE	"umscompile"
*/
#define	UMC_COMPTXT	"umcmptxt"
#define	UMC_COMPTXT_LONG	"umscomptxt"
#define	UMC_COMPILE	"umscomp"
#define	UMC_COMPILE_LONG	"umscompile"
#define	DOS_UMC_COMPILE	"UMSCOMP.EXE"

extern	int	UMSoptind, UMSopterr;
extern	char	*UMSoptarg;
int		opt, sts;
char		*cmdName;


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
                    strcmp( cmdName, UMC_COMPILE_LONG ) &&
		strcmp(cmdName, DOS_UMC_COMPILE) ) ? UMC_NOFILE : UMC_CFILE;

	UMSopterr = 0;
	while ( ( ( opt = UMSgetopt( argc, argv, "m:p:F" ) ) != NONOPT )
		|| (UMSoptarg != NULL ) ) 
	{
		if ( opt == ( int )'m' )
			strcpy( msgFile, UMSoptarg );
		else if ( opt == ( int )'p' && *progFlag != UMC_NOFILE )
			strcpy( progFile, UMSoptarg );
		else if ( opt == ( int )'F' && *progFlag != UMC_NOFILE )
			*progFlag = UMC_FORFILE;
		/* sml:09-19-91		add this for C's getopt */
		else if (opt == NONOPT /*&& *progFlag != UMC_NOFILE*/)
		{
			/* check if textFile has already been set */
			if (textFile[0] != '\0')
			{
			  sts = COMP_F_TOOMANYTEXT;
			  UMCErrorMsg(sts, 0);
			  goto usage_msg;
			}
			else
			  strcpy(textFile, UMSoptarg);
		}
		/* check if valid option */
		else if (opt != (int)'m' && opt != (int)'p' && opt != (int)'F')
		{
			sts = COMP_F_INVCMDOPT;
			UMCErrorMsg( sts, 0 );
			goto usage_msg;
		}
	}
	
	/* check if textFile option given */
	if (!textFile)
	{
	  sts = COMP_F_NOTEXTFILE;
	  UMCErrorMsg(sts, 0);
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
	if ( *progFlag == UMC_NOFILE )
		UMCErrorMsg( COMP_M_TXTUSAGE, "%s", argv[0] );
	else
		UMCErrorMsg( COMP_M_DEVUSAGE, "%s", argv[0] );
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

int	progFlag;		 i - Programming file to create
					UMC_NOFILE - No programming file
					UMC_CFILE - C header file
					UMC_FORFILE - Fortran inc file	
char	*textFile;		 i - Message text file		
char	*msgFile;		 i/o - Indexed message file		
char	*progFile;		 i/o - Programming file		

******************************************************************************/

int	UMCDefNames( int progFlag, char *textFile, char *msgFile,
       char *progFile )

{
char	*name, *dir, *ext;
char	tmpText[UMC_FILELEN], tmpFile[UMC_FILELEN];

	strcpy( tmpText, textFile );
	if ( ( name = strrchr( tmpText, '/' ) ) != NULL )
	{
		*name++ = '\0';
		dir = tmpText;
	}
	else
	{
		name = tmpText;
		dir = ".";
	}
	if ( ( ext = strrchr( name, '.' ) ) != NULL )
		*ext = '\0';
	if ( strlen( name ) > (size_t) 10 )
		name[10] = '\0';

	if ( msgFile[0] == '\0' )
		sprintf( msgFile, "%s/%s.msg", dir, name );
	if ( msgFile[0] != '/' && msgFile[0] != '.' )
	{
		strcpy( tmpFile, msgFile );
		sprintf( msgFile, "./%s", tmpFile );
	}

	if ( progFlag != UMC_NOFILE )
	{
		if ( progFile[0] == '\0' )
			sprintf( progFile, "%s/%s.%s", dir, name,
				 ( progFlag == UMC_CFILE ) ? "h" : "inc" );
		if ( progFile[0] != '/' && progFile[0] != '.' )
		{
			strcpy( tmpFile, progFile );
			sprintf( progFile, "./%s", tmpFile );
		}
	}

	return( COMP_S_SUCCESS );
}
