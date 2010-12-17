#include "machine.h"
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "NFMSextern.h"
#include "DEBUG.h"
#include "NFMapi.h"
#include "ERR.h"

long NFMSdefine_set_information (in_list)

MEMptr in_list;

{
long   status;
long   ret_status;
int    rows;
int    cols;
int    x;
int    i;
char   **data_ptr1;
char   **data_ptr2;
MEMptr buffer1 = NULL;
struct NFMmember_info *members_info;

static char *fname = "NFMSdefine_set_information";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array(in_list) : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, fname, "MEMbuild_array" );
        return( NFM_E_MEM );
    }

    data_ptr1 = (char**)in_list->data_ptr;

    _NFMSdebug(( fname, "Catalog      <%s>\n", data_ptr1[0] ));
    _NFMSdebug(( fname, "Catalog No   <%s>\n", data_ptr1[1] ));
    _NFMSdebug(( fname, "Set          <%s>\n", data_ptr1[2] ));
    _NFMSdebug(( fname, "Revision     <%s>\n", data_ptr1[3] ));
    _NFMSdebug(( fname, "Status Check <%s>\n", data_ptr1[4] ));
    _NFMSdebug(( fname, "# Members    <%s>\n", data_ptr1[5] ));

    status = MEMreset_buffer_no (in_list, 2);
    if (status == MEM_S_SUCCESS)
    {
        status = MEMsplit_copy_buffer (in_list, &buffer1, 0);
        if (status != MEM_S_SUCCESS)
        {
            MEMclose (&buffer1);
            _NFMSdebug(( fname, "MEMsplit_copy_buffer : <0x%.8x>\n", status));
            ERRload_struct( NFM, NFM_E_MEM, fname, "MEMsplit_copy" );
            return( NFM_E_MEM );
        }
    }

    status = MEMbuild_array (buffer1);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array(buffer1) : <0x%.8x>\n", status));
	MEMclose (&buffer1);
        ERRload_struct( NFM, NFM_E_MEM, fname, "MEMbuild_array" );
        return( NFM_E_MEM );
    }

    data_ptr2 = (char**)buffer1->data_ptr;
    rows = buffer1->rows;
    cols = buffer1->columns;

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array(in_list) : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, fname, "MEMbuild_array" );
        return( NFM_E_MEM );
    }

    data_ptr1 = (char**)in_list->data_ptr;

    _NFMSdebug(( fname, "Catalog      <%s>\n", data_ptr1[0] ));
    _NFMSdebug(( fname, "Catalog No   <%s>\n", data_ptr1[1] ));
    _NFMSdebug(( fname, "Set          <%s>\n", data_ptr1[2] ));
    _NFMSdebug(( fname, "Revision     <%s>\n", data_ptr1[3] ));
    _NFMSdebug(( fname, "Status Check <%s>\n", data_ptr1[4] ));
    _NFMSdebug(( fname, "# Members    <%s>\n", data_ptr1[5] ));

    members_info = (struct NFMmember_info *)calloc((rows+1),
                   (sizeof (struct NFMmember_info)));

    for( x=0,i=0; x<(rows*cols); x+=cols,++i )
    {
        (members_info+i)->operation = atoi( data_ptr2[x] );
        (members_info+i)->citno     = atol( data_ptr2[x+1] );
        strncpy( (members_info+i)->catalog_name, data_ptr2[x+2],
		  NFM_CATALOGNAME );
   	(members_info+i)->catalog_no= atol( data_ptr2[x+3] );
        strncpy( (members_info+i)->item_name, data_ptr2[x+4],
                 NFM_ITEMNAME );
        strncpy( (members_info+i)->item_rev, data_ptr2[x+5],
		 NFM_ITEMREV );
	(members_info+i)->item_no = atoi( data_ptr2[x+6] );
        strncpy( (members_info+i)->type, data_ptr2[x+7], NFM_TYPE );
    }

    ret_status = NFMdefine_set_information( data_ptr1[0], atol(data_ptr1[1]),
	 data_ptr1[2], data_ptr1[3], atoi(data_ptr1[4]), atoi(data_ptr1[5]),
	 members_info );
    _NFMSdebug(( fname, "NFMdefine_set_information <0x%.8x>\n", status));

    MEMclose( &buffer1 );
    free( members_info );

    status = NFMSsend_error_buffers( ret_status, ret_status );
    _NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));

    if (ret_status != NFM_S_SUCCESS)
        return (ret_status);

    return (NFM_S_SUCCESS);
}

long NFMSget_set_messages(in_list)

MEMptr in_list;

{
    long   status;
    long   ret_status;
    MEMptr data_list = NULL;

    static char *fname = "NFMSget_set_messages";
  
    _NFMSdebug(( fname, "%s\n", "Entering ..." ));

    ret_status = NFMget_set_messages( &data_list );
    _NFMSdebug(( fname, "NFMget_set_messages <0x%.8x>\n", ret_status ));

    status = NFMSsend_one_buffer( ret_status, data_list );
    _NFMSdebug(( fname, "NFMSsend_one_buffer <0x%.8x>\n", status ));

    if( _NFMdebug_st.NFMSdebug_on )
	MEMprint_buffers( "MESSAGES", data_list, _NFMdebug_st.NFMSdebug_file);

    MEMclose( &data_list );

    return( ret_status );
}
