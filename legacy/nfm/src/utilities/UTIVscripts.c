#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "MSGstruct.h"
#include "UTICinclude.h"

UTIVexecute_script( str )
    char *str;
{
    long   status;
    char   command[256];

    _UTI_dbg( "%s", "Enter UTIVexecute_script : ");
    _UTI_dbg( "UTIexecute_script : Script <%s>", str );

    sprintf( command, "%s %s", LEAD_CHAR, str );
    
    _UTI_dbg( "UTIexecute_script : script <%s>", command );

    status = system( command );
    _UTI_dbg( "UTIexecute_script : execute script status <%d>", status );    
    if( UTIVsys_stat( status ) != 0 )
    {
	UTIVerror( UTI_E_EXESCRIPT, str );
	return( UTI_E_FAILURE );
    }

    _UTI_dbg( "%s", "UTIexecute_script : SUCCESSFUL" );
    return( UTI_S_SUCCESS );
}

UTIVexecute_group( str, dbg )
    char   *str;
    srvdbg dbg;
{
    int  utility;
    int  i;
    long status;

    char script_name[50];
    char ch;

    script_header hdr = NULL;

    FILE *script_file;
    FILE *fopen();

    _UTI_dbg( "%s", "Enter UTIexecute_group :" );
    _UTI_dbg( "UTIexecute_group : Group name <%s>", str );

    script_file = fopen( str, "r" );
    if( script_file == NULL )
    {
	_UTI_dbg( "UTIexecute_group : Cannot open <%s>",str );
	UTIVerror( UTI_E_OPENSCRIPT, str );
	return( UTI_E_FAILURE );
    }
    
    while( i = fscanf( script_file, "%s", script_name ) > 0 )
    {
	ch = fgetc( script_file );

/*  Read header information from script
 */
	_UTI_dbg( "UTIexecute_group : Read script <%s>", script_name );
        status = UTIVread_script( script_name, &hdr );
        if( status != UTI_S_SUCCESS )
	{
	    _UTI_dbg( "UTIexecute_group : Error reading script <%s>",
		script_name );
	    continue;
	}

	UTIVprint_header( hdr );

        status = UTIVtalk( hdr, dbg );
   	if( status != UTI_S_SUCCESS )
	{
	    status = NFMRterminate();
	    free( &hdr );
	    _UTI_dbg( "%s", "UTIexecute_group : Error in connection" );
	    continue;
	}

        _UTI_dbg( "%s", "UTIexecute_group : Try to prepare media" );
        status = UTIVprepare_media( hdr );
        if( status != UTI_S_SUCCESS )
	{
	    status = NFMRterminate();
	    free( &hdr );
	    _UTI_dbg( "%s", "UTIexecute_group : Error preparing media" );
	    continue;
	}

        fprintf( stdout, "NFMutil :  Executing Utility Script <%s>\n",
		 script_name );

    	status = UTIVexecute_script( script_name );
 	_UTI_dbg( "UTIexecute_group : Execute script status <%d>",status );
        if( status != UTI_S_SUCCESS )
	{
	    status = NFMRterminate();
	    _UTI_dbg( "UTIexecute_group : Error executing <%s>",script_name );
	    free( &hdr );
	    continue;
	}

 	_UTI_dbg( "UTIexecute_group : UTI_GROUP_NO <%d>",UTI_GROUP_NO );

/*  Update server database
 */
	status = UTIVupdate_db( UTI_GROUP_NO, status, UTI_RESTORE );
        if( status != UTI_S_SUCCESS )
	{
	    _UTI_dbg( "UTIexecute_group : Bad update_db <%d>", status );
            UTIVerror( UTI_E_FAILURE, script_name );
	}
	else
	{
	    _UTI_dbg( "UTIexecute_group : Good update_db <%d>", status );
       	    UTIVerror( UTI_S_SUCCESS, script_name );
	}

	status = NFMRterminate();
    } /* end RESTORE GROUP */

    fclose( script_file );

    _UTI_dbg( "%s", "Exit UTIexecute_group :" );
    return( UTI_S_SUCCESS );
}
/*  This routine reads the given input script, searching for important
 *  data. The data is always within a comment and if it is important,
 *  it appears after the first ':' occurrence. The data is ordered in
 *  sequential records as follows :
 *	NFM server :
 *	NFM environment :
 * 	NFM username :
 *	NFM password : 
 *	NFM storage number :
 *	[device name : ]
 *	[label : ]
 *
 *  The records with information in brackets [] may not be there in
 *  certain cases ( e.g. ARCHIVE TO HARD DISK ). The information 
 *  gathered here is stored in global variables.
 */
UTIVread_script( script, return_header )
    char   *script;
    script_header *return_header;
{
    int    header_line;
    int	   len;

    char   rec[80];

    script_header hdr  = NULL;

    FILE   *script_file;

    _UTI_dbg( "UTIVread_script : script <%s>", script );
 
    chmod( script, 06777 );
    script_file = fopen( script, "r" );
    if( script_file == NULL )
    {
    	UTIVerror( UTI_E_OPENSCRIPT, script );
	return( UTI_E_FAILURE );
    }

/*  Read all script lines starting with comment character '$ !'
 */
    header_line = 0;
    hdr = (script_header)malloc( sizeof( struct header ) );

    while( fgets( rec, 81, script_file ) != (char*)NULL )
    {
	if( (rec[0] != '$') && (rec[2] != '!') )
	    break;
	++header_line;
	switch( header_line )
	{
	    case UTI_HDR_UTILITY :
		UTIVpast_colon( rec, hdr->utility );
		break;

	    case UTI_HDR_LOCATION :
		UTIVpast_colon( rec, hdr->location  );
	 	break;

	    case UTI_HDR_SAVESET :
		UTIVpast_colon( rec, hdr->saveset );
		break;

	    case UTI_HDR_SERVER :
		UTIVpast_colon( rec, hdr->server );
		break;

	    case UTI_HDR_ENV :
		UTIVpast_colon( rec, hdr->env );
		break;

	    case UTI_HDR_USERNAME :
		UTIVpast_colon( rec, hdr->username );
		break;

	    case UTI_HDR_PASSWD :
		UTIVpast_colon( rec, hdr->passwd );
		break;

	    case UTI_HDR_PROTOCOL :
		UTIVpast_colon( rec, hdr->protocol );
		break;

	    case UTI_HDR_SA_NUMBER :
		UTIVpast_colon( rec, hdr->sa_number );
		UTI_CLIENT_SA = atol( hdr->sa_number );
		break;

	    case UTI_HDR_DEVICE :
		UTIVpast_colon( rec, hdr->device );
		break;

	    case UTI_HDR_LABEL :
		UTIVpast_colon( rec, hdr->label );
		break;

	    case UTI_HDR_GROUP :
		UTIVpast_colon( rec, hdr->group );
		UTI_GROUP_NO = atoi( hdr->group );
		break;

	    default :
		break;
	} /* end switch */
    } /* end while */

    fclose( script_file );   

    *return_header = hdr;

    return( UTI_S_SUCCESS );
}
