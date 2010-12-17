#include "machine.h"
#include <stdio.h>
#ifdef OS_CLIX
#include <inc.h>     /* SSRS 18-10-93 : include file kept in condition*/
#endif
#include "MEMstruct.h"
#include "NFIerrordef.h"
#include "NFMtypes.h"
#include "NFMerrordef.h"
#include "NFMRextern.h"
#include "SCdef.h"
#include "UTIerrordef.h"

list_restore()
{
    long	status;
    MEMptr	file_value = NULL;

    _NFMR_str( "%s", "Enter NFMlist_restore : " );

/*  Retrieve flagged files from NFM server
 */
    status =NFMRquery_flagged_files( NFMuser_id,NFM_RESTORE_LIST,&file_value );
    if( status != NFM_S_SUCCESS )
    {
        MEMclose( &file_value );
        return( status );
    }

    status = UTIRlist_flagged_files( "RESTORE", file_value );
    if( status != UTI_S_SUCCESS )
    {
	MEMclose( &file_value );
        return( status );
    }

    MEMclose( &file_value );
    return( NFI_S_SUCCESS );
}
