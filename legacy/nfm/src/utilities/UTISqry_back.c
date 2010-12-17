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

#define BUFFER_SIZE 1000

long NFMSquery_backup( in_list, out_list, flist )
    MEMptr	in_list;
    MEMptr	*out_list;
    UTIpending  *flist;
{
    long	status;

    UTIpending  list	    = NULL;
   
    MEMptr	sa_value    = NULL;
    MEMptr	file_value  = NULL;
    MEMptr	label_value = NULL;

    static	char *fname = "UTIquery_backup";

    _UTIdebug(( fname, "%s\n", "Entering ..." ));

    status = UTIset_globals( "B" );
    if( status != UTI_S_SUCCESS )
	return( status );

/*  Query and build buffers for storage areas.
 */
    status = UTIquery_sa( &sa_value );
    if( status != UTI_S_SUCCESS )
	return( status );

/*  Query and build labels buffer .
 */
    status = UTIquery_labels( &label_value );

/*  Query and build pending flagged files list
 */
    status = UTIquery_files_flagged_for_archive_or_backup( &file_value,
    			&list, UTIbackup );
    if( status != UTI_S_SUCCESS )
	return( status );

    *flist = list;

/*  Now build out_list buffer to send back to requester.
 *  Only append a value list if it is not NULL.
 */
/*  If the file_value buffer is NULL, open an empty buffer and append
 *  it to be a place holder.
 */
    if( file_value )    
    {
        status = MEMappend( file_value, sa_value );
        if( status != MEM_S_SUCCESS )
        {
            ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	    MEMclose( &sa_value );
	    MEMclose( &file_value );
   	    MEMclose( &label_value );
	    return( NFM_E_MEM );
        }
    }
    else
    {
	status = MEMopen( &file_value, BUFFER_SIZE );
        if( status != MEM_S_SUCCESS )
        {
            ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
  	    MEMclose( &sa_value );
	    MEMclose( &file_value );
	    MEMclose( &label_value );
  	    return( NFM_E_MEM );
        }
	status = MEMappend( file_value, sa_value );
        if( status != MEM_S_SUCCESS )
        {
            ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	    MEMclose( &sa_value );
	    MEMclose( &file_value );
   	    MEMclose( &label_value );
	    return( NFM_E_MEM );
        }
    }

/*  Only append values  list if not NULL    
 */
    if( label_value )
    {
        status = MEMappend( label_value, sa_value );
        if( status != MEM_S_SUCCESS )
        {
            ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	    MEMclose( &sa_value );
	    MEMclose( &file_value );
	    MEMclose( &label_value );
	    return( NFM_E_MEM );
        }
    }
    else
    {
	status = MEMopen( &label_value, BUFFER_SIZE );
        if( status != MEM_S_SUCCESS )
        {
            ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
  	    MEMclose( &sa_value );
	    MEMclose( &file_value );
	    MEMclose( &label_value );
  	    return( NFM_E_MEM );
        }

	status = MEMappend( label_value, sa_value );
        if( status != MEM_S_SUCCESS )
        {
            ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	    MEMclose( &sa_value );
	    MEMclose( &file_value );
   	    MEMclose( &label_value );
	    return( NFM_E_MEM );
        }
    }
  
    *out_list = sa_value;

    MEMclose( &file_value );
    MEMclose( &label_value );

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( NFM_S_SUCCESS );
}
