#include "machine.h"
#include "MEMstruct.h"
#include "NETdef.h"
#include "NFMerrordef.h"
#include "NFMSextern.h"
#include "DEBUG.h"
#include "ERR.h"

#define BUFFER_SIZE 1000

long NFMSquery_flag_archive (in_list)
    MEMptr in_list;
{
    long status;
    long ret_status;
    long user_id;
    char **data_ptr;
    MEMptr data_list = NULL;

    static char *fname = "NFMSquery_flag_archive";

    _NFMSdebug(( fname, "%s\n", "Entering ..." ));

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        return (status);
    }

    data_ptr = (char **) in_list->data_ptr;

   _NFMSdebug(( fname, "Catalog : <%s>\n", data_ptr[1]));

   user_id = atol (data_ptr[0]);
   
   ret_status = NFMquery_flag_archive (user_id, data_ptr[1], &data_list );
   _NFMSdebug(( fname, "NFMquery_flag_archive <0x%.8x>\n", ret_status ));

    status = NFMSsend_one_buffer( ret_status, data_list );
    _NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));

    MEMclose( &data_list );

    if( ret_status != NFM_S_SUCCESS )
   	return( ret_status);

    return (NFM_S_SUCCESS);
}


long NFMSquery_flag_backup (in_list)
    MEMptr in_list;
{
    long status;
    long ret_status;
    long user_id;
    char **data_ptr;
    MEMptr data_list = NULL;

    static char *fname = "NFMSquery_flag_backup"; 

    _NFMSdebug(( fname, "%s\n", "Entering ..." ));

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        return (status);
    }

    data_ptr = (char **) in_list->data_ptr;

    _NFMSdebug(( fname, "Catalog : <%s>\n", data_ptr[1]));

    user_id = atol (data_ptr[0]);

    ret_status = NFMquery_flag_backup (user_id, data_ptr[1], &data_list );
    _NFMSdebug(( fname, "NFMquery_flag_backup <0x%.8x>\n", ret_status ));

    status = NFMSsend_one_buffer( ret_status, data_list );
    _NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));

    MEMclose( &data_list );

    if( ret_status != NFM_S_SUCCESS )
   	return( ret_status);

    return (NFM_S_SUCCESS);
}


long NFMSquery_flag_restore (in_list)
    MEMptr in_list;
{
    long status;
    long ret_status;
    long user_id;
    char **data_ptr;
    MEMptr data_list = NULL;

    static char *fname = "NFMSquery_flag_restore";

    _NFMSdebug(( fname, "%s\n", "Entering ..." ));

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        return (status);
    }

    data_ptr = (char **) in_list->data_ptr;

    _NFMSdebug(( fname, "Catalog : <%s>\n", data_ptr[1]));

    user_id = atol (data_ptr[0]);

    ret_status = NFMquery_flag_restore (user_id, data_ptr[1], &data_list );
    _NFMSdebug(( fname, "NFMquery_flag_restore <0x%.8x>\n", ret_status ));

    status = NFMSsend_one_buffer( ret_status, data_list );
    _NFMSdebug(( fname, "NFMSsend_one_buffers <0x%.8x>\n", status ));

    MEMclose( &data_list );

    if( ret_status != NFM_S_SUCCESS )
   	return( ret_status);

    return (NFM_S_SUCCESS);

}


long NFMSnew_query_flag_restore (in_list)
    MEMptr in_list;
{
    long status;
    long ret_status;
    char **data_ptr;
    MEMptr data_list = NULL;

    static char *fname = "NFMSnew_query_flag_restore";

    _NFMSdebug(( fname, "%s\n", "Entering ..." ));

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        return (status);
    }

    data_ptr = (char **) in_list->data_ptr;

    _NFMSdebug(( fname, "Catalog : <%s>\n", data_ptr[0]));
    _NFMSdebug(( fname, "Item    : <%s>\n", data_ptr[1]));
    _NFMSdebug(( fname, "Revision : <%s>\n", data_ptr[2]));

    ret_status = NFMnew_query_flag_restore (data_ptr[0], data_ptr[1], 
					    data_ptr[2], &data_list );
    _NFMSdebug(( fname, "NFMnew_query_flag_restore <0x%.8x>\n", ret_status ));

    status = NFMSsend_one_buffer( ret_status, data_list );
    _NFMSdebug(( fname, "NFMSsend_one_buffers <0x%.8x>\n", status ));

    MEMclose( &data_list );

    if( ret_status != NFM_S_SUCCESS )
   	return( ret_status);

    return (NFM_S_SUCCESS);

}


long NFMSquery_flag_delete (in_list)
    MEMptr in_list;
{
    long status;
    long ret_status;
    long user_id;
    char **data_ptr;
    MEMptr data_list = NULL;
    static char *fname = "NFMSquery_flag_delete";

    _NFMSdebug(( fname, "%s\n", "Entering ..." ));

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        return (status);
    }

    data_ptr = (char **) in_list->data_ptr;

    _NFMSdebug(( fname, "Catalog : <%s>\n", data_ptr[1]));
    user_id = atol (data_ptr[0]);

    ret_status = NFMquery_flag_delete (user_id, data_ptr[1], &data_list );
    _NFMSdebug(( fname, "NFMquery_flag_delete <0x%.8x>\n", ret_status ));

    status = NFMSsend_one_buffer( ret_status, data_list );
    _NFMSdebug(( fname, "NFMSsend_one_buffers <0x%.8x>\n", status ));

    MEMclose( &data_list );

    if( ret_status != NFM_S_SUCCESS )
   	return( ret_status);

    return (NFM_S_SUCCESS);
}




