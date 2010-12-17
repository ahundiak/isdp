#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "MSGstruct.h"
#include "UTICinclude.h"

/*  Prompt user for OFF-LINE media script.
 */
UTIVrequest( dbg )
    srvdbg dbg;
{
    char   command[MAXSTR+1];
    char   *ret;
    char   *fgets();
    strptr UTIVparsecommand();
    strptr scripts;

/*  Although we are in a loop to get script names, a connection,
 *  login and disconnect to server must be made for each script 
 *  because these could be different in each script.
 */
    while( 1 )
    {
	fprintf( stdout, "\nNFMutil ( script name ? ) ---> " );
	ret = fgets( command, MAXSTR, stdin );
	if( ( ret == NULL )  || strlen( command ) <= 1 )
	    return;
        scripts = UTIVparsecommand( command );
        while( scripts != NULL )
	{        
	    UTIVdocommand( scripts->str, dbg );
	    scripts = scripts->next;
	}
    }
}

UTIVdocommand( script, dbg )
    char   *script;
    srvdbg dbg;
{
    long    status;
    int	          group_no;
    int		  utility;
    script_header hdr = NULL;
   
    UTIVupcase( script );

    _UTI_dbg( "UTIdocommand : Script : <%s>", script );

/*  If script is and ARCHIVE or BACKUP - proceed normally.
 *  A RESTORE script is treated with caution.
 */
    if( strncmp( script, "RESTORE", 7 ) == 0 )
    {
        _UTI_dbg( "%s", "UTIdocommand : Execute Restore  :" );
	status = UTIVrestore_cmd( script, dbg );
	return( status );	
    }

/*  Read header information from script
 */
    status = UTIVread_script( script, &hdr );
    if( status != UTI_S_SUCCESS )
	return( status );

    UTIVprint_header( hdr );

    status = UTIVtalk( hdr, dbg );
    if( status != UTI_S_SUCCESS )
    {
        _UTI_dbg( "UTIdocommand : UTIVtalk : <0x%.8x>", status );
  	status = NFMRterminate();
	free( &hdr );
	return( status );
    }
    _UTI_dbg( "UTIdocommand : UTIVtalk : <0x%.8x>", status );

    utility = atoi( hdr->utility );
    if( utility == UTI_ARCHIVE )
    {
	status = UTIVarchive_cmd( script, hdr );
    }
    else if( utility == UTI_BACKUP )
    {
	status = UTIVbackup_cmd( script, hdr );
    }

    fprintf( stdout, "NFMutil :  Terminating Server Connection ...\n" );

    status = NFMRterminate();
    free( &hdr );
    return( status );
}

/* Take the blank or tab seperated items in "str" and make them into
 * a linked list.  This is done to make handling of variable numbers
 * of arguments much easier and straight-forward.
 */
strptr
UTIVparsecommand( str )
    char *str;
{
    char tmp[MAXSTR+1];
    char c;
    char *s;

    int i;

    strptr command;
    strptr sptr;
    strptr last;

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
UTIVcommandline( argc, argv )
    int argc;
    char *argv[];
{
    int i;
    char command[MAXSTR+1];
    strptr sptr;

    command[0] = 0;

    for( i=1; i<argc; ++i )
    {
	if( (1 + strlen(argv[i]) + strlen(command)) >= MAXSTR )
	    break;

	sprintf( command+strlen(command), " %s", argv[i] );
    }
    _UTI_dbg( "UTIcommandline : command : <%s>", command );
    return( UTIVdocommand(command) );
}
