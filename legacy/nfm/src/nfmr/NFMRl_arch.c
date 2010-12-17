#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "NFMtypes.h"
#include "NFIerrordef.h"
#include "NFMerrordef.h"
#include "NFMRextern.h"
#include "SCdef.h"
#include "UTIerrordef.h"

list_archive()
{
    long	status;
    MEMptr	file_value = NULL;

/*  Retrieve flagged files from NFM server
 */
    status = NFMRquery_flagged_files(NFMuser_id,NFM_ARCHIVE_LIST,&file_value);
    if( status != NFM_S_SUCCESS )
    {
	MEMclose( &file_value );
        return( status );
    }

    status = UTIRlist_flagged_files( "ARCHIVE", file_value );
    if( status != UTI_S_SUCCESS )
    {
	MEMclose( &file_value );
        return( status );
    }

    MEMclose( &file_value );

    return( NFI_S_SUCCESS );
}
