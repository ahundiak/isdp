#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "NFMSextern.h"
#include "UTIerrordef.h"
#include "UTIstruct.h"
#include "UTIglobals.h"
#include "ERR.h"
#include "DEBUG.h"

UTIpending UTIflist = NULL;

long  NFMquery_archive( sa_value, file_value, label_value )
    MEMptr *sa_value;
    MEMptr *file_value;
    MEMptr *label_value;
{
    long        status;
    static char *fname = "NFMquery_archive";

    status = UTIset_globals( "A" );
    if( status != UTI_S_SUCCESS )
    {
	_NFMdebug(( fname, "UTIset_globals <0x%.8x>\n", status ));
	return( status );
    }

    status = UTIquery_sa( sa_value );
    if( status != UTI_S_SUCCESS )
    {
        _NFMdebug(( fname, "UTIquery_sa <0x%.8x>\n", status ));
        return( status );
    }

/*  Query and build labels buffer .
 */
    status = UTIquery_labels( label_value );

/*  Query and build pending flagged files list
 */
    status = UTIquery_files_flagged_for_archive_or_backup( file_value, 
		UTIarchive );
    if( status != UTI_S_SUCCESS )
    {
        _NFMdebug(( fname, 
		"UTIquery_files_flagged_for_archive_or_backup <0x%.8x>\n", 
		 status ));
        return( status );
    }

    _NFMdebug(( fname, "%s\n", "Exiting ..." ));

    return( NFM_S_SUCCESS );
}

long  NFMquery_backup( sa_value, file_value, label_value )
    MEMptr *sa_value;
    MEMptr *file_value;
    MEMptr *label_value;
{
    long        status;

    static char *fname = "NFMquery_backup";

    status = UTIset_globals( "B" );
    if( status != UTI_S_SUCCESS )
    {
	_NFMdebug(( fname, "UTIset_globals <0x%.8x>\n", status ));
	return( status );
    }

    status = UTIquery_sa( sa_value );
    if( status != UTI_S_SUCCESS )
    {
        _NFMdebug(( fname, "UTIquery_sa <0x%.8x>\n", status ));
        return( status );
    }

/*  Query and build labels buffer .
 */
    status = UTIquery_labels( label_value );

/*  Query and build pending flagged files list
 */
    status = UTIquery_files_flagged_for_archive_or_backup( file_value, 
		UTIbackup );
    if( status != UTI_S_SUCCESS )
    {
        _NFMdebug(( fname, 
		"UTIquery_files_flagged_for_archive_or_backup <0x%.8x>\n", 
		 status ));
        return( status );
    }

    _NFMdebug(( fname, "%s\n", "Exiting ..." ));

    return( NFM_S_SUCCESS );
}


long  NFMquery_restore( file_value )
    MEMptr *file_value;
{
    long        status;
    static char *fname = "NFMquery_restore";

    _NFMdebug(( fname, "%s\n", "Entering ..." ));
   
    status = UTIset_globals( "R" );
    if( status != UTI_S_SUCCESS )
	return( status );

/*  Query and build pending flagged files list
 */
    status = UTIquery_files_flagged_for_archive_or_backup( file_value, UTIrestore );
    if( status != UTI_S_SUCCESS )
    {
	_NFMdebug(( fname, "UTIquery_files_flagged_for_archive_or_backup <0x%.8x>\n", status ));
	return( status );
    }

    _NFMdebug(( fname, "%s\n", "Exiting ..." ));

    return( NFM_S_SUCCESS );
}

long  NFMquery_delete( file_value )
    MEMptr *file_value;
{
    long        status;
    static char *fname = "NFMquery_delete";

    status = UTIset_globals( "D" );
    if( status != UTI_S_SUCCESS )
    {
	_NFMdebug(( fname, "UTIset_globals <0x%.8x>\n", status ));
	return( status );
    }

    status = UTIquery_files_flagged_for_delete( file_value, UTIdelete );
    if( status != UTI_S_SUCCESS )
    {
	_NFMdebug(( fname, "UTIquery_files_flagged_for_delete <0x%.8x>\n",
			    status ));
        return( status );
    }

    _NFMdebug(( fname, "%s\n", "Exiting ..." ));

    return( NFM_S_SUCCESS );
}
