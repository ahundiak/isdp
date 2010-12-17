#include "machine.h"
#include <stdio.h>
#include "NFMerrordef.h"
#include "NFMstruct.h"
#include "DEBUG.h"
#include "ERR.h"
#include "NFMapi.h"

/* 11/20/92 -- Added by dontu and Karen. We also made NFMset_msg in NFMstruct.h
               'extern'. */

MEMptr NFMset_msg = NULL;

long NFMopen_message_buffer()
{
    long    status;

    static  char *fname = "NFMopen_message_buffer";

    _NFMdebug(( fname, "%s\n", "Entering..." ));

    if( NFMset_msg != NULL )
	MEMclose( &NFMset_msg );

    status = MEMopen( &NFMset_msg, MEM_SIZE );
    if( status != MEM_S_SUCCESS )
    {
        _NFMdebug(( fname, "MEMopen : <0x%.8x>\n", status ));
        return( status );
    }

    status = MEMwrite_format( NFMset_msg, "message", "char(256)" );
    if( status != MEM_S_SUCCESS )
    {
        _NFMdebug(( fname, "MEMwrite_format:<0x%.8x>\n", status ));
        return( status );
    }   

    _NFMdebug(( fname, "%s\n", "Returning ... " ));
    return( NFM_S_SUCCESS );
} 

long NFMlog_message( )
{
    long    status;
    char    msg[512];
    static  char *fname = "NFMlog_message";

    status = ERRget_message( msg );
    _NFMdebug(( fname, "ERR status <0x%.8x>\n", status ));

    _NFMdebug(( fname, "Message <%s>\n", msg ));

    status = MEMwrite( NFMset_msg, msg );
    if( status != MEM_S_SUCCESS )
    {
        _NFMdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
	return( status );
    }
    return( NFM_S_SUCCESS );
}

long  NFMget_set_messages( out_list )
    MEMptr *out_list;
{
    int   i;
    long  status;
    char  **data_ptr;

    static char *fname = "NFMget_set_messages";

    _NFMdebug(( fname, "%s\n", "Entering ..." ));

    status = MEMbuild_array( NFMset_msg );
    if( status != MEM_S_SUCCESS )
    {
	_NFMdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
 	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
 	return( NFM_E_MEM );
    }

    data_ptr = (char **)NFMset_msg->data_ptr;

    for( i=0; i<NFMset_msg->rows; ++i )
	_NFMdebug(( fname, "set_msg[%d] - <%s>\n", i, data_ptr[i] ));

    status = MEMsplit_copy_buffer( NFMset_msg, out_list, 1 );
    if( status != MEM_S_SUCCESS )
    {
	_NFMdebug(( fname, "MEMsplit_copy <0x%.8x>\n", status ));
 	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
 	return( NFM_E_MEM );
    }

    _NFMdebug(( fname, "%s\n", "Exiting ..." ));
  
    return( NFM_S_SUCCESS );
}
