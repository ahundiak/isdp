#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "NFMSextern.h"
#include "DEBUG.h"
#include "NFMapi.h"

long NFMScopy_item_files (in_list)

MEMptr in_list;

{
long   status;
long   ret_status;
char   **data_ptr;
struct NFMwf_info wf_info;
struct NFMoperation operation;

static char *fname = "NFMScopy_item_files";

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
	_NFMSdebug(( fname, "Command       <%s>\n", data_ptr[9]));
	_NFMSdebug(( fname, "Workflow Name <%s>\n", data_ptr[10]));
	_NFMSdebug(( fname, "Project Name  <%s>\n", data_ptr[11]));
	_NFMSdebug(( fname, "Application   <%s>\n", data_ptr[12]));
	strncpy( wf_info.command, data_ptr[9], NFM_COMMANDNAME );
	strncpy( wf_info.workflow_name, data_ptr[10], NFM_WORKFLOWNAME );
	strncpy( wf_info.project_name, data_ptr[11], NFM_PROJECTNAME );
	strncpy( wf_info.app_name, data_ptr[12], NFM_APPLICATION );	
    }

    ret_status = NFMcopy_item_files( data_ptr[0], atol(data_ptr[1]), 
		data_ptr[2],data_ptr[3], data_ptr[4], wf_info, operation );

/********
    Jujare 28, Dec 95 
    Here seems to be an EMT (signal 7)
    Reproduced by A.Ravi Kumar using DM/MGR 
********/

    _NFMSdebug(( fname, "NFMcopy_item_files <0x%.8x>\n", ret_status));

    status = NFMSsend_error_buffers( ret_status, ret_status );
    _NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));

    if (ret_status != NFM_S_SUCCESS)
        return (ret_status);

    return (NFM_S_SUCCESS);
}

long NFMScopy_item_n (in_list)

MEMptr in_list;

{
long status;
long ret_status;
char **data_ptr;
MEMptr attr_list = NULL;
MEMptr data_list = NULL;
MEMptr attr_f_list = NULL;
MEMptr data_f_list = NULL;
static char *fname = "NFMScopy_item_n" ;

_NFMSdebug((fname, "Entering\n")) ;

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    return (status);
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "catalog_name  : <%s>\n", data_ptr[0]));

status = MEMreset_buffer_no (in_list, 2);
if (status == MEM_S_SUCCESS)
    {
    status = MEMsplit_copy_buffer (in_list, &attr_list, 0);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&attr_list);
        _NFMSdebug(( fname, "MEMsplit_copy_buffer : <0x%.8x>\n", status));
        return (status);
        }
    }

status = MEMreset_buffer_no (in_list, 3);
if (status == MEM_S_SUCCESS)
    {
    status = MEMsplit_copy_buffer (in_list, &data_list, 0);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&data_list);
        _NFMSdebug(( fname, "MEMsplit_copy_buffer : <0x%.8x>\n", status));
        return (status);
        }
    }

status = MEMreset_buffer_no (in_list, 4);
if (status == MEM_S_SUCCESS)
    {
    status = MEMsplit_copy_buffer (in_list, &attr_f_list, 0);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&data_list);
        _NFMSdebug(( fname, "MEMsplit_copy_buffer : <0x%.8x>\n", status));
        return (status);
        }
    }

status = MEMreset_buffer_no (in_list, 5);
if (status == MEM_S_SUCCESS)
    {
    status = MEMsplit_copy_buffer (in_list, &data_f_list, 0);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&data_list);
        _NFMSdebug(( fname, "MEMsplit_copy_buffer : <0x%.8x>\n", status));
        return (status);
        }
    }

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    return (status);
    }

data_ptr = (char **) in_list->data_ptr;

if( _NFMdebug_st.NFMSdebug_on )
{
    MEMprint_buffers( "CAT ATTR LIST", attr_list, _NFMdebug_st.NFMSdebug_file);
    MEMprint_buffers( "CAT DATA LIST", data_list, _NFMdebug_st.NFMSdebug_file);
    MEMprint_buffers( "FCAT ATTR LIST", attr_f_list, _NFMdebug_st.NFMSdebug_file);
    MEMprint_buffers( "FCAT DATA LIST", data_f_list, _NFMdebug_st.NFMSdebug_file);
}
ret_status = NFMcopy_item_n (data_ptr[0], attr_list, data_list, 
			 attr_f_list, data_f_list) ;
_NFMSdebug(( fname, "NFMcopy_item_n <0x%.8x>\n", ret_status));

status = NFMSsend_error_buffers( ret_status, ret_status );
_NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));

MEMclose (&attr_list);
MEMclose (&data_list);
MEMclose (&attr_f_list);
MEMclose (&data_f_list);

if( ret_status != NFM_S_SUCCESS )
    return( ret_status );

return (NFM_S_SUCCESS);
}


long NFMSftr_copy_item_n (in_list)

MEMptr in_list;

{
long status;
long ret_status;
char **data_ptr;
MEMptr attr_list = NULL;
MEMptr data_list = NULL;
MEMptr attr_f_list = NULL;
MEMptr data_f_list = NULL;
MEMptr filesBuffer = NULL;
MEMptr keyBuffer = NULL;

static char *fname = "NFMSftr_copy_item_n" ;

_NFMSdebug((fname, "Entering\n")) ;

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    return (status);
    }

data_ptr = (char **) in_list->data_ptr;

_NFMSdebug(( fname, "catalog_name  : <%s>\n", data_ptr[0]));

status = MEMreset_buffer_no (in_list, 2);
if (status == MEM_S_SUCCESS)
    {
    status = MEMsplit_copy_buffer (in_list, &attr_list, 0);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&attr_list);
        _NFMSdebug(( fname, "MEMsplit_copy_buffer : <0x%.8x>\n", status));
        return (status);
        }
    }

status = MEMreset_buffer_no (in_list, 3);
if (status == MEM_S_SUCCESS)
    {
    status = MEMsplit_copy_buffer (in_list, &data_list, 0);
    if (status != MEM_S_SUCCESS)
        {
	MEMclose (&attr_list);
	MEMclose (&data_list);
        _NFMSdebug(( fname, "MEMsplit_copy_buffer : <0x%.8x>\n", status));
        return (status);
        }
    }

status = MEMreset_buffer_no (in_list, 4);
if (status == MEM_S_SUCCESS)
    {
    status = MEMsplit_copy_buffer (in_list, &attr_f_list, 0);
    if (status != MEM_S_SUCCESS)
        {
	MEMclose (&attr_list);
        MEMclose (&data_list);
	MEMclose (&attr_f_list);
        _NFMSdebug(( fname, "MEMsplit_copy_buffer : <0x%.8x>\n", status));
        return (status);
        }
    }

status = MEMreset_buffer_no (in_list, 5);
if (status == MEM_S_SUCCESS)
    {
    status = MEMsplit_copy_buffer (in_list, &data_f_list, 0);
    if (status != MEM_S_SUCCESS)
        {
	MEMclose (&attr_list);
        MEMclose (&data_list);
	MEMclose (&attr_f_list);
        MEMclose (&data_f_list);
        _NFMSdebug(( fname, "MEMsplit_copy_buffer : <0x%.8x>\n", status));
        return (status);
        }
    }

status = MEMreset_buffer_no (in_list, 6);
if (status == MEM_S_SUCCESS)
    {
    status = MEMsplit_copy_buffer (in_list, &filesBuffer, 0);
    if (status != MEM_S_SUCCESS)
        {
	MEMclose (&attr_list);
        MEMclose (&data_list);
	MEMclose (&attr_f_list);
        MEMclose (&data_f_list);
        MEMclose (&filesBuffer);
        _NFMSdebug(( fname, "MEMsplit_copy_buffer : <0x%.8x>\n", status));
        return (status);
        }
    }

status = MEMreset_buffer_no (in_list, 7);
if (status == MEM_S_SUCCESS)
    {
    status = MEMsplit_copy_buffer (in_list, &keyBuffer, 0);
    if (status != MEM_S_SUCCESS)
        {
	MEMclose (&attr_list);
        MEMclose (&data_list);
	MEMclose (&attr_f_list);
        MEMclose (&data_f_list);
        MEMclose (&filesBuffer);
        MEMclose (&keyBuffer);
        _NFMSdebug(( fname, "MEMsplit_copy_buffer : <0x%.8x>\n", status));
        return (status);
        }
    }

status = MEMbuild_array (in_list);
if (status != MEM_S_SUCCESS)
    {
    return (status);
    }

data_ptr = (char **) in_list->data_ptr;

if( _NFMdebug_st.NFMSdebug_on )
{
    MEMprint_buffers( "CAT ATTR LIST", attr_list, _NFMdebug_st.NFMSdebug_file);
    MEMprint_buffers( "CAT DATA LIST", data_list, _NFMdebug_st.NFMSdebug_file);
    MEMprint_buffers("FCAT ATTR LIST",attr_f_list,_NFMdebug_st.NFMSdebug_file);
    MEMprint_buffers("FCAT DATA LIST",data_f_list,_NFMdebug_st.NFMSdebug_file);
    MEMprint_buffers( "FTR FILES", filesBuffer, _NFMdebug_st.NFMSdebug_file);
    MEMprint_buffers( "FTR KEYWORDS", keyBuffer, _NFMdebug_st.NFMSdebug_file);
}
ret_status = NFMftr_copy_item_n (data_ptr[0], attr_list, data_list, 
			 attr_f_list, data_f_list, filesBuffer, keyBuffer) ;
_NFMSdebug(( fname, "NFMftr_copy_item_n <0x%.8x>\n", ret_status));

status = NFMSsend_error_buffers( ret_status, ret_status );
_NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));

MEMclose (&attr_list);
MEMclose (&data_list);
MEMclose (&attr_f_list);
MEMclose (&data_f_list);
MEMclose (&filesBuffer);
MEMclose (&keyBuffer);

if( ret_status != NFM_S_SUCCESS )
    return( ret_status );

return (NFM_S_SUCCESS);
}

