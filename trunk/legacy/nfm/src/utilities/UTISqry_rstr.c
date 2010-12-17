#include "machine.h"
#include <stdio.h>
#include <errno.h>
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "NFMSextern.h"
#include "UTIerrordef.h"
#include "UTIstruct.h"
#include "UTIglobals.h"
#include "DEBUG.h"
#include "ERR.h"
#include "NFMstruct.h"

#define BUFFER_SIZE 1000
extern struct NFMglobal_st NFMglobal;

long NFMSquery_restore( in_list, out_list, flist )
    MEMptr	in_list;
    MEMptr	*out_list;
    UTIpending  *flist;
{
    long	status;
    char	**data_ptr;
    MEMptr	file_value;

    UTIpending  list	    = NULL;

    static 	char *fname = "UTIquery_restore";

    _UTIdebug(( fname, "%s\n", "Entering ..." ));
   
    status = UTIset_globals( "R" );
    if( status != UTI_S_SUCCESS )
	return( status );

/*********
    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
        return (status);

    data_ptr = (char **) in_list->data_ptr;

    UTIuser_id    = atol( data_ptr[0] );
*********/
    UTIuser_id    = NFMglobal.NFMuserid;

/*  Query and build pending flagged files list
 */
    status = UTIquery_files_flagged_for_archive_or_backup( file_value, UTIrestore );
    if( status != UTI_S_SUCCESS )
    {
        _NFMdebug(( fname, "UTIquery_files_flagged_for_archive_or_backup <0x%.8x>\n", status ));
        return( status );
    }

    *flist = list;

/*  Now build out_list buffer to send back to requester.
 *  If the file_value buffer is NULL, open an empty buffer and append
 *  it to be a place holder.
 */
    if( file_value == NULL ) 
    {
	status = MEMopen( &file_value, BUFFER_SIZE );
        if( status != MEM_S_SUCCESS )
        {
            ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	    MEMclose( &file_value );
  	    return( NFM_E_MEM );
	}
    }

    *out_list = file_value;

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( NFM_S_SUCCESS );
}
