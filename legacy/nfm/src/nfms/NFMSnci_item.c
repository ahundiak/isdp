#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "NFMSextern.h"
#include "DEBUG.h"
#include "NFMapi.h"
#include "ERR.h"

long NFMScheckin_item (in_list)

MEMptr in_list;

{
long   status;
long   ret_status;
char   **data_ptr;
struct NFMwf_info wf_info;
struct NFMoperation operation;

static char *fname = "NFMScheckin_item";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        return (status);
    }
    data_ptr = (char**)in_list->data_ptr;

    _NFMSdebug(( fname, "Catalog      <%s>\n", data_ptr[0] ));
    _NFMSdebug(( fname, "Catalog No   <%s>\n", data_ptr[1] ));
    _NFMSdebug(( fname, "Item         <%s>\n", data_ptr[2] ));
    _NFMSdebug(( fname, "Revision     <%s>\n", data_ptr[3] ));
    _NFMSdebug(( fname, "Working Area <%s>\n", data_ptr[4] ));
    _NFMSdebug(( fname, "Transfer     <%s>\n", data_ptr[5] ));
    _NFMSdebug(( fname, "Delete       <%s>\n", data_ptr[6] ));
    _NFMSdebug(( fname, "Purge        <%s>\n", data_ptr[7] ));

    operation.transfer = atoi( data_ptr[5] );
    operation.delete   = atoi( data_ptr[6] );
    operation.purge    = atoi( data_ptr[7] );

    wf_info.workflow = atoi(data_ptr[8]);
    if( wf_info.workflow == NFM_WORKFLOW )
    {
	_NFMSdebug(( fname, "Command       <%s>\n", data_ptr[9] ));
	_NFMSdebug(( fname, "Workflow Name <%s>\n", data_ptr[10] ));
	_NFMSdebug(( fname, "Project Name  <%s>\n", data_ptr[11] ));
	_NFMSdebug(( fname, "Application   <%s>\n", data_ptr[12] ));
	strncpy( wf_info.command, data_ptr[9], NFM_COMMANDNAME );
	strncpy( wf_info.workflow_name, data_ptr[10], NFM_WORKFLOWNAME );
	strncpy( wf_info.project_name, data_ptr[11], NFM_PROJECTNAME );
	strncpy( wf_info.app_name, data_ptr[12], NFM_APPLICATION );	
    }

    ret_status = NFMcheckin_item( data_ptr[0], atol(data_ptr[1]), data_ptr[2],
		data_ptr[3], data_ptr[4], wf_info, operation);
    _NFMSdebug(( fname, "NFMcheckin_item  <0x%.8x>\n", ret_status));

    status = NFMSsend_error_buffers( ret_status, ret_status );
    _NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));

    return (ret_status);
}

long NFMSftr_checkin_item (in_list)

MEMptr in_list;

{
long   status;
long   ret_status;
char   **data_ptr;
MEMptr ciBuff = NULL;
MEMptr filesBuff = NULL;
MEMptr keyBuff = NULL;
struct NFMwf_info wf_info;
struct NFMoperation operation;

static char *fname = "NFMSftr_checkin_item";

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        return (status);
    }

    status = MEMsplit_copy_buffer (in_list, &ciBuff, 0);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMsplit_copy_buffer : <0x%.8x>\n", status));
        ERRload_struct( NFMS, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    status = MEMreset_buffer_no (in_list, 2);
    if (status == MEM_S_SUCCESS)
    {
        status = MEMsplit_copy_buffer (in_list, &filesBuff, 0);
        if (status != MEM_S_SUCCESS)
        {
            MEMclose (&ciBuff);
            _NFMSdebug(( fname, "MEMsplit_copy_buffer : <0x%.8x>\n", status));
            ERRload_struct( NFMS, NFM_E_MEM, NULL, NULL );
            return( NFM_E_MEM );
        }
    }

    status = MEMreset_buffer_no (in_list, 3);
    if (status == MEM_S_SUCCESS)
    {
        status = MEMsplit_copy_buffer (in_list, &keyBuff, 0);
        if (status != MEM_S_SUCCESS)
        {
            MEMclose (&ciBuff);
	    MEMclose (&filesBuff);
            _NFMSdebug(( fname, "MEMsplit_copy_buffer : <0x%.8x>\n", status));
            ERRload_struct( NFMS, NFM_E_MEM, NULL, NULL );
            return( NFM_E_MEM );
        }
    }

    status = MEMbuild_array (ciBuff);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
	MEMclose (&ciBuff);
 	MEMclose (&filesBuff);
	MEMclose (&keyBuff);
        ERRload_struct( NFMS, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    data_ptr = (char**)ciBuff->data_ptr;


    _NFMSdebug(( fname, "Catalog      <%s>\n", data_ptr[0] ));
    _NFMSdebug(( fname, "Catalog No   <%s>\n", data_ptr[1] ));
    _NFMSdebug(( fname, "Item         <%s>\n", data_ptr[2] ));
    _NFMSdebug(( fname, "Revision     <%s>\n", data_ptr[3] ));
    _NFMSdebug(( fname, "Working Area <%s>\n", data_ptr[4] ));
    _NFMSdebug(( fname, "Transfer     <%s>\n", data_ptr[5] ));
    _NFMSdebug(( fname, "Delete       <%s>\n", data_ptr[6] ));
    _NFMSdebug(( fname, "Purge        <%s>\n", data_ptr[7] ));

    operation.transfer = atoi( data_ptr[5] );
    operation.delete   = atoi( data_ptr[6] );
    operation.purge    = atoi( data_ptr[7] );

    wf_info.workflow = atoi(data_ptr[8]);
    if( wf_info.workflow == NFM_WORKFLOW )
    {
	_NFMSdebug(( fname, "Command       <%s>\n", data_ptr[9] ));
	_NFMSdebug(( fname, "Workflow Name <%s>\n", data_ptr[10] ));
	_NFMSdebug(( fname, "Project Name  <%s>\n", data_ptr[11] ));
	_NFMSdebug(( fname, "Application   <%s>\n", data_ptr[12] ));
	strncpy( wf_info.command, data_ptr[9], NFM_COMMANDNAME );
	strncpy( wf_info.workflow_name, data_ptr[10], NFM_WORKFLOWNAME );
	strncpy( wf_info.project_name, data_ptr[11], NFM_PROJECTNAME );
	strncpy( wf_info.app_name, data_ptr[12], NFM_APPLICATION );	
    }

    ret_status = NFMftr_checkin_item( data_ptr[0], atol(data_ptr[1]), 
		data_ptr[2], data_ptr[3], data_ptr[4], wf_info, 
		operation, filesBuff, keyBuff );

    if (_NFMdebug_st.NFMSdebug_on == 1)
    {
      MEMprint_buffers("FTR FILES", filesBuff, _NFMdebug_st.NFMSdebug_file);
      MEMprint_buffers("FTR KEYWORDS", keyBuff, _NFMdebug_st.NFMSdebug_file);
    }

    _NFMSdebug(( fname, "NFMftr_checkin_item  <0x%.8x>\n", ret_status));

    MEMclose (&ciBuff);
    MEMclose (&filesBuff);
    MEMclose (&keyBuff);

    status = NFMSsend_error_buffers( ret_status, ret_status );
    _NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));

    return (ret_status);
}
