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

#define  BUFFER_SIZE  1000

long NFMSquery_archive( in_list )
    MEMptr	in_list;
{
    long	status = 0;
    long 	ret_status;
    MEMptr	sa_value    = NULL;   
    MEMptr	file_value  = NULL;
    MEMptr	label_value = NULL;

    static 	char *fname = "NFMSquery_archive";

    _NFMSdebug(( fname, "%s\n", "Entering ..." ));

    ret_status = NFMquery_archive( &sa_value, &file_value, &label_value );
    _NFMSdebug(( fname, "NFMquery_archive <0x%.8x>\n", ret_status ));
    if( ret_status != NFM_S_SUCCESS )
    {
	MEMclose( &sa_value );
	MEMclose( &file_value );
	MEMclose( &label_value );
	sa_value = NULL;
	file_value = NULL;
	label_value = NULL;
    }

    status = NFMSsend_three_buffers( ret_status, sa_value, file_value,
				     label_value );
    _NFMSdebug(( fname, "NFMSsend_three_buffers <0x%.8x>\n", status ));

    MEMclose( &sa_value );
    MEMclose( &file_value );
    MEMclose( &label_value );

    return( ret_status );
}
 

long NFMSquery_backup( in_list )
    MEMptr	in_list;

{
    long	status = 0;
    long	ret_status;
    MEMptr	sa_value    = NULL;   
    MEMptr	file_value  = NULL;
    MEMptr	label_value = NULL;

    static 	char *fname = "NFMSquery_backup";

    _NFMSdebug(( fname, "%s\n", "Entering ..." ));

    ret_status = NFMquery_backup( &sa_value, &file_value, &label_value );
    _NFMSdebug(( fname, "NFMquery_backup <0x%.8x>\n", ret_status ));
    if( ret_status != NFM_S_SUCCESS )
    {
	MEMclose( &sa_value );
	MEMclose( &file_value );
	MEMclose( &label_value );
	sa_value = NULL;
	file_value = NULL;
	label_value = NULL;
    }

    status = NFMSsend_three_buffers( ret_status, sa_value, file_value,
				     label_value );
    _NFMSdebug(( fname, "NFMSsend_three_buffers <0x%.8x>\n", status ));

    MEMclose( &sa_value );
    MEMclose( &file_value );
    MEMclose( &label_value );

    return( ret_status );
}
 

long NFMSquery_restore( in_list )
    MEMptr	in_list;

{
    long	status = 0;
    long        ret_status;
   
    MEMptr	file_value  = NULL;
 
    static 	char *fname = "NFMSquery_restore";

    _NFMSdebug(( fname, "%s\n", "Entering ..." ));

    ret_status = NFMquery_restore( &file_value );
    _NFMSdebug(( fname, "NFMquery_restore <0x%.8x>\n", ret_status ));
    if( ret_status != NFM_S_SUCCESS )
    {
	MEMclose( &file_value );
	file_value = NULL;
    }

    status = NFMSsend_one_buffer( ret_status, file_value );
    _NFMSdebug(( fname, "NFMSsend_one_buffers <0x%.8x>\n", status ));

    MEMclose( &file_value );

    return( ret_status );
}
 

long NFMSquery_delete( in_list )
    MEMptr	in_list;
{
    long	status = 0;
    long        ret_status;
    MEMptr	file_value; 
    static 	char *fname = "NFMSquery_delete";

    _NFMSdebug(( fname, "%s\n", "Entering ..." ));

    ret_status = NFMquery_delete( &file_value );
    _NFMSdebug(( fname, "NFMquery_delete <0x%.8x>\n", ret_status ));
    if( ret_status != NFM_S_SUCCESS )
    {
	MEMclose( &file_value );
	file_value = NULL;
    }

    status = NFMSsend_one_buffer( ret_status, file_value );
    _NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));

    MEMclose( &file_value );

    return( ret_status );
}
 
