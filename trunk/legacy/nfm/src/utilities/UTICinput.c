#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "MSGstruct.h"
#include "UTICinclude.h"

/*  Prompt user for OFF-LINE media script.
 */
UTICrequest( dbg )
    srvdbg dbg;
{
    char   command[MAXSTR+1];
    char   *ret;
    char   *fgets();

    strptr UTICparsecommand();
    strptr scripts;

/*  Although we are in a loop to get script names, a connection,
 *  login and disconnect to server must be made for each script 
 *  because these could be different in each script.
 */
    while( 1 )
    {
	fprintf( stdout, "\nNfmutil ( script name ? ) ---> " );
	ret = fgets( command, MAXSTR, stdin );
	if( ( ret == NULL )  || strlen( command ) <= 1 )
	    return;
        scripts = UTICparsecommand( command );
        while( scripts != NULL )
	{        
	    UTICdocommand( scripts->str, dbg );
	    scripts = scripts->next;
	}
    }
}

UTICdocommand( script, dbg )
    char   *script;
    srvdbg dbg;
{
    long          status;

    int		  utility;
    char	  tmp_script[80];
    char	  *ptr;
    char	  *strrchr();
    char  	  *ret;
    char          command[MAXSTR+1];
    strptr        UTICparsecommand();
    strptr        scripts;

    script_header hdr = NULL;

    _UTI_dbg( "UTIdocommand : Script : <%s>", script );
    strcpy( tmp_script, script );
    if( ( ptr = strrchr( script, '/' ) ) != NULL )
	strcpy( tmp_script, (++ptr) );

/*  If script is and ARCHIVE or BACKUP - proceed normally.
 *  A RESTORE script is treated with caution.
 */
    if( strncmp( tmp_script, "RESTORE", 7 ) == 0 )
    {
        _UTI_dbg( "%s", "UTIdocommand : Execute Restore  :" );
	status = UTICrestore_cmd( script, dbg );
	return( status );	
    }

    fprintf( stdout, "Nfmutil ( configurable file - <RETURN> if not configuring ) ---> " );
    ret = fgets( command, MAXSTR, stdin );
    if( ( ret == NULL )  || strlen( command ) <= 1 )
	strcpy( UTI_CONFIG, "" );
    else
    {
        scripts = UTICparsecommand( command );
        strcpy( UTI_CONFIG, scripts->str );
    }

/*  Read header information from script
 */
    status = UTICread_script( script, &hdr );
    if( status != UTI_S_SUCCESS )
	return( status );

    UTICprint_header( hdr );

    status = UTICtalk( hdr, dbg );
    if( status != UTI_S_SUCCESS )
    {
  	status = NFMRterminate();
	return( status );
    }
    
    utility = atoi( hdr->utility );

    if( utility == UTI_ARCHIVE )
    {
	status = UTICarchive_cmd( script, hdr);
    }
    else if( utility ==  UTI_BACKUP )
    {
	status = UTICbackup_cmd( script, hdr );
    }

    fprintf( stdout, "Nfmutil :  Terminating Server Connection ...\n" );
    status = NFMRterminate();

    return( status );
}

/* Take the blank or tab seperated items in "str" and make them into
 * a linked list.  This is done to make handling of variable numbers
 * of arguments much easier and straight-forward.
 */
strptr
UTICparsecommand( str )
    char *str;
{
    char tmp[MAXSTR+1];
    char *s;

    int i;

    strptr command;
    strptr sptr;
    strptr last = NULL;

    command = NULL;
    i = 0;

    for( s=str; ; ++s )
    {
	if( (*s == ' ') || (*s == (char)0) || (*s == '\n') )
	{
	    if( i > 0 )
	    {
		tmp[i] = (char) 0;
		sptr = (strptr) malloc( sizeof(struct strstruct) );
		sptr->next = NULL;
		sptr->str = strcpy( malloc(strlen(tmp)+1), tmp );

		if( command == NULL )
		    command = sptr;
		else
		    last->next = sptr;

		last = sptr;
		i = 0;
	    }
	}
	else if( i < MAXSTR )
	    tmp[i++] = *s;

	if( (*s == (char)0) || (*s == '\n') )
	    break;
    }

    return( command );
}

/* Generate a single string from the arguments on the command line.
 * This, in turn, will be broken into a linked list and interpreted.
 */
UTICcommandline( argc, argv )
    int argc;
    char *argv[];
{
    int i;
    char command[MAXSTR+1];
    srvdbg dbg = NULL;

    command[0] = 0;

    for( i=1; i<argc; ++i )
    {
	if( (1 + strlen(argv[i]) + strlen(command)) >= MAXSTR )
	    break;

	sprintf( command+strlen(command), " %s", argv[i] );
    }
    _UTI_dbg( "UTIcommandline : command : <%s>", command );
    return( UTICdocommand(command,dbg) );
}
