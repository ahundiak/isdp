#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "NFMtypes.h"
#include "MSGstruct.h"
#include "UTICinclude.h"

UTIVarchive_cmd( script, hdr )
    char          *script;
    script_header hdr;
{
    long    status;
    int     making_copies;
    int     no_copies;
    
    _UTI_dbg("UTIV_cmd : script : %s", script );

    UTILITY = UTI_ARCHIVE;
    making_copies = 1;
    no_copies     = 1;

    while( making_copies )
    {
        status = UTIVprepare_media( hdr );
        if( status != UTI_S_SUCCESS )
        {
    	    _UTI_dbg( "UTIVarchive_cmd : Prepare media status <%d>", status );
	    return( status );
        }

        fprintf(stdout, "NFMutil :  Executing Utility Script <%s>\n", script );

        status = UTIVexecute_script( script );
        if( status != UTI_S_SUCCESS )
        {
	    _UTI_dbg( "UTIVarchive_cmd : Execute script status <%d>", status);
	    return( status );
        }

        _UTI_dbg( "UTIVarchive_cmd : UTI_GROUP_NO <%d>", UTI_GROUP_NO );

	fprintf( stdout, "NFMutil : Do you want to make another archive copy ? (y/n) " );
        fgets( UTImsg, 81, stdin );
        if( UTImsg[0] == 'y' || UTImsg[0] == 'Y' )
	{
	    ++no_copies;
	    fprintf( stdout, "NFMutil : Making copy number <%d>\n",no_copies);
	    continue;
	}
        making_copies = 0;

    } /* end while */

/*  Update server database 
 */

    status = UTIVupdate_db( UTI_GROUP_NO, UTI_S_SUCCESS, UTILITY);
    if( status != UTI_S_SUCCESS )
    {
	_UTI_dbg( "UTIVarchive_cmd : Bad DB update <%d>", status );
    	UTIVerror( UTI_E_FAILURE, script );
    }
    else
    {
	_UTI_dbg( "UTIVarchive_cmd : Good DB update <%d>", status );
	UTIVerror( UTI_S_SUCCESS, script );
	_UTI_dbg( "UTIVarchive_cmd : Deleting script <%s>", script );
	unlink( script );
    }

    _UTI_dbg( "%s", "Exit UTIVarchive_cmd : " );
    return( status );
}

UTIVbackup_cmd( script, hdr )
    char          *script;
    script_header hdr;
{
    long    status;
    int     making_copies;
    int     no_copies;
    
    _UTI_dbg("UTIVbackup_cmd : script : %s", script );

    UTILITY = UTI_BACKUP;
    making_copies = 1;
    no_copies     = 1;

    while( making_copies )
    {
        status = UTIVprepare_media( hdr );
        if( status != UTI_S_SUCCESS )
        {
    	    _UTI_dbg( "UTIVbackup_cmd : Prepare media status <%d>", status );
	    return( status );
        }

        fprintf(stdout, "NFMutil :  Executing Utility Script <%s>\n", script );

        status = UTIVexecute_script( script );
        if( status != UTI_S_SUCCESS )
        {
	    _UTI_dbg( "UTIVbackup_cmd : Execute script status <%d>", status);
	    return( status );
        }

        _UTI_dbg( "UTIVbackup_cmd : UTI_GROUP_NO <%d>", UTI_GROUP_NO );

	fprintf( stdout, "NFMutil : Do you want to make another archive copy ? (y/n) " );
        fgets( UTImsg, 81, stdin );
        if( UTImsg[0] == 'y' || UTImsg[0] == 'Y' )
	{
	    ++no_copies;
	    fprintf( stdout, "NFMutil : Making copy number <%d>\n",no_copies);
	    continue;
	}
        making_copies = 0;

    } /* end while */

/*  Update server database 
 */
    status = UTIVupdate_db( UTI_GROUP_NO, UTI_S_SUCCESS, UTILITY);
    if( status != UTI_S_SUCCESS )
    {
    	UTIVerror( UTI_E_FAILURE, script );
	_UTI_dbg( "UTIVbackup_cmd : Bad DB update status <%d>", status );
    }
    else
    {
	UTIVerror( UTI_S_SUCCESS, script );
	_UTI_dbg( "UTIVbackup_cmd : Good DB update status <%d>", status );
	_UTI_dbg( "UTIVbackup_cmd : Deleting script <%s>", script );
	unlink( script );
    }

    _UTI_dbg( "%s", "Exit UTIVbackup_cmd : " );
    return( status );
}

UTIVrestore_cmd( script, dbg )
    char    *script;
    srvdbg  dbg;
{
    long    status;

    UTILITY = UTI_RESTORE;

    _UTI_dbg("UTIrstr_cmd : script : %s", script );

/*  Execute file of script names
 */
    status = UTIVexecute_group( script, dbg );

    _UTI_dbg( "%s", "Exit UTIVrestore_cmd : " );
    return( status );
}
