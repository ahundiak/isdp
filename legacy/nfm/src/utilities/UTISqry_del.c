#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "MEMerrordef.h"
#include "NFMerrordef.h"
#include "NFMSextern.h"
#include "UTIerrordef.h"
#include "UTIstruct.h"
#include "UTIglobals.h"
#include "DEBUG.h"

#define BUFFER_SIZE 1000

long NFMSquery_delete( in_list, out_list, flist )
    MEMptr	in_list;
    MEMptr	*out_list;
    UTIpending  *flist;
{
    long	status;
    char	**data_ptr;
    MEMptr	file_value;

    UTIpending  list = NULL;

    static	char *fname = "UTIquery_delete";

    _UTIdebug(( fname, "%s\n", "Entering ..." ));
   
    status = UTIset_globals( "D" );
    if( status != UTI_S_SUCCESS )
	return( status );

/******* User id is normally set to 0
    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
        return (status);

    data_ptr = (char **) in_list->data_ptr;

    UTIuser_id    = atol( data_ptr[0] );
*******/

    UTIuser_id    = 0;

/*  Query and build pending flagged files list **/

    status = UTIquery_files_flagged_for_delete( &file_value, 
					        &list, UTIdelete );
    if( status != UTI_S_SUCCESS )
	return( status );

    *flist = list;

/*  Now build out_list buffer to send back to requester.
 *  If the file_value buffer is NULL, open an empty buffer and append
 *  it to be a place holder.
 */
    if( file_value == NULL ) 
    {
        _UTIdebug(( fname, "File_value is NULL!!!"));
	status = MEMopen( &file_value, BUFFER_SIZE );
        if( status != MEM_S_SUCCESS )
        {
	    MEMclose( &file_value );
  	    return( status );
	}
    }

    *out_list = file_value;

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( NFM_S_SUCCESS );
}
