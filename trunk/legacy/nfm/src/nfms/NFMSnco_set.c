#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "NFMSextern.h"
#include "DEBUG.h"
#include "NFMapi.h"

long NFMScheckout_set (in_list)

MEMptr in_list;

{
int    x;
int    i;
int    rows;
int    cols;
long   status;
long   ret_status;
char   **data_ptr1;
char   **data_ptr2;
MEMptr buffer1 = NULL;
struct NFMwf_info wf_info;
struct NFMoperation *operation;

static char *fname = "NFMScheckout_set";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        return (status);
    }

    status = MEMreset_buffer_no (in_list, 2);
    if (status == MEM_S_SUCCESS)
    {
        status = MEMsplit_copy_buffer (in_list, &buffer1, 1);
        if (status != MEM_S_SUCCESS)
        {
	    MEMclose( &buffer1 );
            _NFMSdebug(( fname, "MEMsplit_copy_buffer : <0x%.8x>\n", status));
            return (status);
        }
    }
    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        return (status);
    }

    data_ptr1 = (char**)in_list->data_ptr;

    _NFMSdebug(( fname, "Catalog      <%s>\n", data_ptr1[0] ));
    _NFMSdebug(( fname, "Catalog No   <%s>\n", data_ptr1[1] ));
    _NFMSdebug(( fname, "Set          <%s>\n", data_ptr1[2] ));
    _NFMSdebug(( fname, "Revision     <%s>\n", data_ptr1[3] ));
    _NFMSdebug(( fname, "Item No      <%s>\n", data_ptr1[4] ));
    _NFMSdebug(( fname, "Working Area <%s>\n", data_ptr1[5] ));
    _NFMSdebug(( fname, "Member Op    <%s>\n", data_ptr1[6] ));
    _NFMSdebug(( fname, "Level        <%s>\n", data_ptr1[7] ));
    _NFMSdebug(( fname, "Workflow     <%s>\n", data_ptr1[8] ));

    wf_info.workflow = atoi(data_ptr1[8]);
    if( wf_info.workflow == NFM_WORKFLOW )
    {
	strncpy( wf_info.command, data_ptr1[9], NFM_COMMANDNAME );
	strncpy( wf_info.workflow_name, data_ptr1[10], NFM_WORKFLOWNAME );
	strncpy( wf_info.project_name, data_ptr1[11], NFM_PROJECTNAME );
	strncpy( wf_info.app_name, data_ptr1[12], NFM_APPLICATION );	
	_NFMSdebug(( fname, "Command       <%s>\n", data_ptr1[9] ));
	_NFMSdebug(( fname, "Workflow Name <%s>\n", data_ptr1[10] ));
	_NFMSdebug(( fname, "Project Name  <%s>\n", data_ptr1[11] ));
	_NFMSdebug(( fname, "Application   <%s>\n", data_ptr1[12] ));
    }

    status = MEMbuild_array (buffer1);
    if (status != MEM_S_SUCCESS)
    {
	MEMclose( &buffer1 );
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        return (status);
    }

    _NFMSdebug(( fname, "Buffer1 has been built\n" ));

    data_ptr2 = (char**)buffer1->data_ptr;
    rows = buffer1->rows;
    cols = buffer1->columns;

    operation = (struct NFMoperation *)calloc((rows+1),
		(sizeof( struct NFMoperation )));    
    _NFMSdebug(( fname, "operation has been calloced\n" ));

    for( i=0,x=0; i<rows; ++i,x+=cols )
    {
	(operation+i)->transfer = atoi( data_ptr2[x] );
	_NFMSdebug(( fname, "Transfer <%d>\n", atoi( data_ptr2[x]) ));
	(operation+i)->delete   = atoi( data_ptr2[x+1] );
        _NFMSdebug(( fname, "Delete <%d>\n", atoi( data_ptr2[x+1] )));
	(operation+i)->purge    = atoi( data_ptr2[x+2] );
        _NFMSdebug(( fname, "Purge <%d>\n", atoi( data_ptr2[x+2] )));
	strncpy( (operation+i)->catalog, data_ptr2[x+3], NFM_CATALOGNAME );
        _NFMSdebug(( fname, "Catalog <%s>\n", data_ptr2[x+3] ));
	(operation+i)->catalog_no = atol( data_ptr2[x+4] );
        _NFMSdebug(( fname, "Catalog_no <%d>\n", atol (data_ptr2[x+4]) ));
	strncpy( (operation+i)->item_name, data_ptr2[x+5], NFM_ITEMNAME );
        _NFMSdebug(( fname, "Item <%s>\n", data_ptr2[x+5] ));
	strncpy( (operation+i)->item_rev, data_ptr2[x+6], NFM_ITEMREV );
        _NFMSdebug(( fname, "Rev <%s>\n", data_ptr2[x+6] ));
    }
    MEMclose( &buffer1 );

    ret_status = NFMcheckout_set( data_ptr1[0], atol(data_ptr1[1]), 
	data_ptr1[2],data_ptr1[3], atol(data_ptr1[4]), data_ptr1[5], wf_info,
	atol(data_ptr1[6]), operation, atol(data_ptr1[7]) );
    _NFMSdebug(( fname, "NFMcheckout set <0x%.8x>\n", ret_status));

    status = NFMSsend_error_buffers( ret_status, ret_status );
    _NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));
    free( operation );

    if (ret_status != NFM_S_SUCCESS)
        return (ret_status);

    return (NFM_S_SUCCESS);
}
