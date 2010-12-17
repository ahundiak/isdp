#include "machine.h"
#include "MEMstruct.h"
#include "NETdef.h"
#include "NFMerrordef.h"
#include "NFMSextern.h"
#include "DEBUG.h"
#include "ERR.h"

/* 
 Doc: NFMSget_user_defaults
 
 Abstract:
     This function will get the user defaults that are stored in
     the nfmusers table using the user_id.

 */
 
long NFMSget_user_defaults (in_list)

MEMptr in_list;

{
    long status;
    long ret_status;
    long user_id = 0;

    char **data_ptr;
    MEMptr data_list = NULL;
 
    static char *fname = "NFMSget_user_defaults";

    ret_status = NFMuser_defaults_login_old(user_id, &data_list);
    _NFMSdebug(( fname, "NFMuser_defaults_login_old <0x%.8x>\n", ret_status));
    if (ret_status != NFM_S_SUCCESS)
    {
	MEMclose( &data_list );
	data_list = NULL;
    }

    status = NFMSsend_one_buffer( ret_status, data_list );
    _NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));

    MEMclose( &data_list );

    return (ret_status);
}

/* 
 Doc: NFMSread_user_defaults
 
 Abstract:
     This function will get the user defaults that are stored in
     the <env>/system directory.

 */
 
long NFMSread_user_defaults (in_list)

MEMptr in_list;

{
    long status;
    long ret_status;

    char **data_ptr;
    MEMptr data_list = NULL;
 
    static char *fname = "NFMSread_user_defaults";

    ret_status = NFMread_user_defaults( &data_list);
    _NFMSdebug(( fname, "NFMread_user_defaults <0x%.8x>\n", ret_status));
    if (ret_status != NFM_S_SUCCESS)
    {
	MEMclose( &data_list );
	data_list = NULL;
    }

    status = NFMSsend_one_buffer( ret_status, data_list );
    _NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));

    MEMclose( &data_list );

    return (ret_status);
}
