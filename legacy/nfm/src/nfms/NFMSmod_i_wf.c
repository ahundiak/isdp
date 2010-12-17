#include "machine.h"
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "NFMSextern.h"
#include "DEBUG.h"
#include "ERR.h"

/* 
 Doc: NFMSget_wf_and_completed_acl_list
 
 Abstract:
     This function will return all workflow and complete ACLs.
 */

long NFMSget_wf_and_completed_acl_list(in_list)
MEMptr in_list;

{

long   status;
long   ret_status;
char   **data_ptr;
MEMptr list1 = NULL;
MEMptr list2 = NULL;

static char *fname = "NFMSget_wf_and_completed_acl_list";

    _NFMSdebug(( fname, "%s\n", "Entering ..." ));

    ret_status = NFMget_wf_and_completed_acl_list( &list1, &list2 );
    _NFMSdebug(( fname, "NFMget_wf_and_completed_acl_list <0x%.8x>\n",
		ret_status ));
    if (ret_status != NFM_S_SUCCESS)
    {
        MEMclose( &list1 );
        MEMclose( &list2 );
        list1 = NULL;
        list2 = NULL;
    }

    status = NFMSsend_two_buffers( ret_status, list1, list2 );
    _NFMSdebug(( fname, "NFMSsend_two_buffers <0x%.8x>\n", status ));

    MEMclose( &list1 );
    MEMclose( &list2 );

    return (ret_status);
}

long NFMSget_state_list_for_workflow (in_list)

MEMptr in_list;

{

long   status;
long   ret_status;
char   **data_ptr;
MEMptr list1 = NULL;
MEMptr list2 = NULL;

static char *fname = "NFMSget_state_list_for_workflow";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return( NFM_E_MEM );
    }

    data_ptr = (char**)in_list->data_ptr;

    _NFMSdebug(( fname, "WF Name <%s>\n", data_ptr[0]));

    ret_status = NFMget_state_list_for_workflow( data_ptr[0], &list1, &list2 );
    _NFMSdebug(( fname, "NFMget_state_list_for_workflow <0x%.8x>\n", 
		ret_status));
    if (ret_status != NFM_S_SUCCESS)
    {
 	MEMclose( &list1 );
	MEMclose( &list2 );
	list1 = NULL;
 	list2 = NULL;
    }

    status = NFMSsend_two_buffers( ret_status, list1, list2 );
    _NFMSdebug(( fname, "NFMSsend_two_buffers <0x%.8x>\n", status ));

    MEMclose( &list1 );
    MEMclose( &list2 );

    return (ret_status);
}


/* 
 Doc: NFMSchange_wf_item
 
 Abstract:
     This function will change the workflow for the given item using
     the input acl number and state number.

 */
 
long NFMSchange_wf_item (in_list)

MEMptr in_list;

{
long status;
long ret_status;
char **data_ptr;

static char *fname = "NFMSchange_wf_item";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
    ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
    return( NFM_E_MEM );
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "Catalog Name  : <%s>\n", data_ptr[0]));
_NFMSdebug(( fname, "Item Name     : <%s>\n", data_ptr[1]));
_NFMSdebug(( fname, "Item Rev      : <%s>\n", data_ptr[2]));
_NFMSdebug(( fname, "Workflow      : <%s>\n", data_ptr[3]));
_NFMSdebug(( fname, "ACL Name      : <%s>\n", data_ptr[4]));
_NFMSdebug(( fname, "ACL No.       : <%s>\n", data_ptr[5]));
_NFMSdebug(( fname, "State Name    : <%s>\n", data_ptr[6]));
_NFMSdebug(( fname, "State No      : <%s>\n", data_ptr[7]));

ret_status = NFMchange_wf_item (data_ptr[0], data_ptr[1], data_ptr[2],
	data_ptr[3], data_ptr[4], atol(data_ptr[5]), data_ptr[6],
	atol(data_ptr[7]) );

_NFMSdebug(( fname, "NFMchange_wf_item <0x%.8x>\n", ret_status));

status = NFMSsend_error_buffers( ret_status, ret_status );
_NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));

return( ret_status);

}




