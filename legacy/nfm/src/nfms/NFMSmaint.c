#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "NETdef.h"
#include "NFMerrordef.h"
#include "NFMSextern.h"
#include "DEBUG.h"
#include "ERR.h"
 
long NFMSquery_savesets_to_delete (in_list)
    MEMptr in_list;

{
    long status;
    long ret_status = 0;
    MEMptr attr_list = NULL;
    MEMptr data_list = NULL;

    static char *fname = "NFMSquery_savesets_to_delete";
    in_list = in_list;

    ret_status = NFMquery_savesets_to_delete ( &attr_list, &data_list );
    _NFMSdebug(( fname, "NFMquery_savesets_to_delete <0x%.8x>\n", ret_status));

    status = NFMSsend_two_buffers( ret_status, attr_list, data_list );
    _NFMSdebug(( fname, "NFMSsend_two_buffers <0x%.8x>\n", status ));

    MEMclose( &attr_list );
    MEMclose( &data_list );

    return (ret_status);
}

long NFMSdelete_savesets (in_list)
    MEMptr in_list;

{
    long   status;
    long   ret_status = 0;

    static char *fname = "NFMSdelete_savesets";
   
    _NFMSdebug(( fname, "%s\n", "Entering ..." ));
    in_list = in_list;

    ret_status = NFMdelete_savesets ( in_list );
    _NFMSdebug(( fname, "NFMdelete_savesets <0x%.8x>\n", ret_status));

    status = NFMSsend_error_buffers( ret_status, ret_status );
    _NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));

    return (ret_status);
}

 
long NFMSquery_archives_to_delete (in_list)
    MEMptr in_list;

{
    long status;
    long ret_status = 0;
    MEMptr attr_list = NULL;
    MEMptr data_list = NULL;

    static char *fname = "NFMSquery_archives_to_delete";
    in_list = in_list;

    ret_status = NFMquery_archives_to_delete ( &attr_list, &data_list );
    _NFMSdebug(( fname, "NFMquery_archives_to_delete <0x%.8x>\n", ret_status));

    status = NFMSsend_two_buffers( ret_status, attr_list, data_list );
    _NFMSdebug(( fname, "NFMSsend_two_buffers <0x%.8x>\n", status ));

    MEMclose( &attr_list );
    MEMclose( &data_list );

    return (ret_status);
}

long NFMSdelete_archives (in_list)
    MEMptr in_list;

{
    long   status;
    long   ret_status = 0;

    static char *fname = "NFMSdelete_archives";

    _NFMSdebug(( fname, "%s\n", "Entering ..." ));

    ret_status = NFMdelete_archives ( in_list );
    _NFMSdebug(( fname, "NFMdelete_archives <0x%.8x>\n", ret_status));

    status = NFMSsend_error_buffers( ret_status, ret_status );
    _NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));

    return (ret_status);
}

