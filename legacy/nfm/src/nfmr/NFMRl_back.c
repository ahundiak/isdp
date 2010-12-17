#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "NFIerrordef.h"
#include "NFMtypes.h"
#include "NFMerrordef.h"
#include "NFMRextern.h"
#include "SCdef.h"
#include "UTIerrordef.h"

list_backup()
{
    long	status;
    MEMptr	file_value = NULL;

    _NFMR_str( "%s", "Enter NFMRlist_backup : " );

/*  Retrieve flagged files from NFM server
 */
    status = NFMRquery_flagged_files(NFMuser_id, NFM_BACKUP_LIST,&file_value);
    if( status != NFM_S_SUCCESS )
    {
	MEMclose( &file_value );
        return( status );
    }

    status = UTIRlist_flagged_files( "BACKUP", file_value );
    if( status != UTI_S_SUCCESS )
    {
	MEMclose( &file_value );
        return( status );
    }

    MEMclose( &file_value );
    return( NFI_S_SUCCESS );
}
