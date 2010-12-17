
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "NFMSextern.h"
#include "DEBUG.h"
#include "NFMapi.h"
#include "ERR.h"

long NFMScancel_co_set (in_list)

MEMptr in_list;

{
long   status;
long   ret_status;
long   user_id;
char   **data_ptr;
MEMptr data_list = NULL;

static char *fname = "NFMScancel_co_set";

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "ID           : <%s>\n", data_ptr[0]));

user_id = atol (data_ptr[0]);

status = MEMreset_buffer_no (in_list, 2);
if (status == MEM_S_SUCCESS)
    {
    status = MEMsplit_copy_buffer (in_list, &data_list, 0);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&data_list);
        _NFMSdebug(( fname, "MEMsplit_copy_buffer : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    }

ret_status = NFMcancel_co_set (user_id, data_list);
_NFMSdebug(( fname, "NFMcancel_co_set <0x%.8x>\n", status));

status = NFMSsend_error_buffers( ret_status, ret_status );
_NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));

MEMclose( &data_list );

if( ret_status != NFM_S_SUCCESS )
    return( ret_status);

return (NFM_S_SUCCESS);

}

long NFMScancel_check_out_set (in_list)

MEMptr in_list;

{
int    x;
int    i;
int    rows;
int    cols;
long   ret_status;
long   status;
char   **data_ptr1;
char   **data_ptr2;
MEMptr buffer1 = NULL;
struct NFMwf_info wf_info;
struct NFMoperation *operation;

static char *fname = "NFMScancel_check_out_set";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    status = MEMreset_buffer_no (in_list, 2);
    if (status == MEM_S_SUCCESS)
    {
        status = MEMsplit_copy_buffer (in_list, &buffer1, 1);
        if (status != MEM_S_SUCCESS)
        {
	    MEMclose( &buffer1 );
            _NFMSdebug(( fname, "MEMsplit_copy_buffer : <0x%.8x>\n", status));
            ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
            return( NFM_E_MEM );
        }
    }
    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    data_ptr1 = (char**)in_list->data_ptr;

    _NFMSdebug(( fname, "Catalog      <%s>\n", data_ptr1[0] ));
    _NFMSdebug(( fname, "Catalog No   <%s>\n", data_ptr1[1] ));
    _NFMSdebug(( fname, "Set          <%s>\n", data_ptr1[2] ));
    _NFMSdebug(( fname, "Revision     <%s>\n", data_ptr1[3] ));
    _NFMSdebug(( fname, "Item No      <%s>\n", data_ptr1[4] ));
    _NFMSdebug(( fname, "Member Op    <%s>\n", data_ptr1[5] ));
    _NFMSdebug(( fname, "Level        <%s>\n", data_ptr1[6] ));
    _NFMSdebug(( fname, "Workflow     <%s>\n", data_ptr1[7] ));

    wf_info.workflow = atoi(data_ptr1[7]);
    if( wf_info.workflow == NFM_WORKFLOW )
    {
	_NFMSdebug(( fname, "Command       <%s>\n", data_ptr1[8] ));
	_NFMSdebug(( fname, "Workflow Name <%s>\n", data_ptr1[9] ));
	_NFMSdebug(( fname, "Project Name  <%s>\n", data_ptr1[10] ));
	_NFMSdebug(( fname, "Application   <%s>\n", data_ptr1[11] ));
	strncpy( wf_info.command, data_ptr1[8], NFM_COMMANDNAME );
	strncpy( wf_info.workflow_name, data_ptr1[9], NFM_WORKFLOWNAME );
	strncpy( wf_info.project_name, data_ptr1[10], NFM_PROJECTNAME );
	strncpy( wf_info.app_name, data_ptr1[11], NFM_APPLICATION );	
    }

    status = MEMbuild_array (buffer1);
    if (status != MEM_S_SUCCESS)
    {
	MEMclose( &buffer1 );
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    data_ptr2 = (char**)buffer1->data_ptr;
    rows = buffer1->rows;
    cols = buffer1->columns;

    operation = (struct NFMoperation *)calloc((rows+1),
		(sizeof( struct NFMoperation )));    
    for( i=0,x=0; i<rows; ++i,x+=cols )
    {
	(operation+i)->transfer = atoi( data_ptr2[x] );
	(operation+i)->delete   = atoi( data_ptr2[x+1] );
	(operation+i)->purge    = atoi( data_ptr2[x+2] );
	strncpy( (operation+i)->catalog, data_ptr2[x+3], NFM_CATALOGNAME );
/*	(operation+i)->catalog_no = atol( data_ptr2[x+4] );
	strncpy( (operation+i)->item_name, data_ptr2[x+5], NFM_ITEMNAME );
	strncpy( (operation+i)->item_rev, data_ptr2[x+6], NFM_ITEMREV );
*/
        /* The input buffer has no 'catalog_no' information.
           (see nfmr/NFMRcan_set.c - function NFMRcancel_check_out_set). 
           So the data_ptr2[x+4] is not catalog_no but item_name.
           And data_ptr2[x+5] becomes item_rev.
           SSRS 24 Jan 94 */
	strncpy( (operation+i)->item_name, data_ptr2[x+4], NFM_ITEMNAME );
	strncpy( (operation+i)->item_rev, data_ptr2[x+5], NFM_ITEMREV );
    }
    MEMclose( &buffer1 );

    ret_status = NFMcancel_check_out_set( data_ptr1[0], atol(data_ptr1[1]), 
		data_ptr1[2], data_ptr1[3], atol(data_ptr1[4]), wf_info,
	atol(data_ptr1[5]), operation, atol(data_ptr1[6]) );
    _NFMSdebug(( fname, "NFMcancel_check_out_set <0x%.8x>\n", ret_status));

    free( operation );

    status = NFMSsend_error_buffers( ret_status, ret_status );
    _NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));

    return (ret_status);
}

