#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "NFMSextern.h"
#include "DEBUG.h"
#include "NFMapi.h"

long NFMScheckin_set (in_list)

MEMptr in_list;

{
int    i;
int    x;
int    rows;
int    cols;
long   status;
long   ret_status;
char   **data_ptr1;
char   **data_ptr2;
MEMptr buffer1 = NULL;
struct NFMwf_info wf_info;
struct NFMoperation *operation;

static char *fname = "NFMScheckin_set";

    _NFMSdebug(( fname, "%s\n", "Entering ..." ));

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        return (status);
    }

    status = MEMreset_buffer_no (in_list, 2);
    if (status == MEM_S_SUCCESS)
    {
    _NFMSdebug(( fname, "%s\n", "After reset_buffer_no" ));
        status = MEMsplit_copy_buffer (in_list, &buffer1, 0);
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
    _NFMSdebug(( fname, "Set No       <%s>\n", data_ptr1[4] ));
    _NFMSdebug(( fname, "Working Area <%s>\n", data_ptr1[5] ));
    _NFMSdebug(( fname, "Member Op    <%s>\n", data_ptr1[6] ));
    _NFMSdebug(( fname, "Level        <%s>\n", data_ptr1[7] ));
    _NFMSdebug(( fname, "Workflow     <%s>\n", data_ptr1[8] ));

    wf_info.workflow = atoi(data_ptr1[8]);
    if( wf_info.workflow == NFM_WORKFLOW )
    {
	_NFMSdebug(( fname, "Command       <%s>\n", data_ptr1[9] ));
	_NFMSdebug(( fname, "Workflow Name <%s>\n", data_ptr1[10] ));
	_NFMSdebug(( fname, "Project Name  <%s>\n", data_ptr1[11] ));
	_NFMSdebug(( fname, "Application   <%s>\n", data_ptr1[11] ));
	strncpy( wf_info.command, data_ptr1[9], NFM_COMMANDNAME );
	strncpy( wf_info.workflow_name, data_ptr1[10], NFM_WORKFLOWNAME );
	strncpy( wf_info.project_name, data_ptr1[11], NFM_PROJECTNAME );
	strncpy( wf_info.app_name, data_ptr1[12], NFM_APPLICATION );	
    }

    status = MEMbuild_array (buffer1);
    if (status != MEM_S_SUCCESS)
    {
	MEMclose( &buffer1 );
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        return (status);
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
	(operation+i)->catalog_no = atol( data_ptr2[x+4] );
	strncpy( (operation+i)->item_name, data_ptr2[x+5], NFM_ITEMNAME );
	strncpy( (operation+i)->item_rev, data_ptr2[x+6], NFM_ITEMREV );
    }
    MEMclose( &buffer1 );

    ret_status = NFMcheckin_set( data_ptr1[0], atol(data_ptr1[1]), 
	data_ptr1[2],data_ptr1[3], atol(data_ptr1[4]), data_ptr1[5], 
	wf_info, atol(data_ptr1[6]), operation, atol(data_ptr1[7]) );
    _NFMSdebug(( fname, "NFMdelete_copied_files <0x%.8x>\n", ret_status));

    status = NFMSsend_error_buffers( ret_status, ret_status );
    _NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));
    free( operation );

    if (ret_status != NFM_S_SUCCESS)
        return (ret_status);

    return (NFM_S_SUCCESS);
}

long NFMSftr_checkin_set (in_list)

MEMptr in_list;

{
int    i;
int    x;
int    rows;
int    cols;
long   status;
long   ret_status;
char   **data_ptr1;
char   **data_ptr2;
MEMptr buffer1 = NULL;
MEMptr filesBuffer = NULL;
MEMptr keyBuffer = NULL;
struct NFMwf_info wf_info;
struct NFMoperation *operation;
char   cat_name[NFM_CATALOGNAME+10], set_name[NFM_ITEMNAME+200];
char   set_rev [NFM_ITEMREV+100], work_area[NFM_SANAME+10];
long   cat_no, set_no, mem_op, level;

static char *fname = "NFMSftr_checkin_set";

    _NFMSdebug(( fname, "%s\n", "Entering ..." ));


    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        return (status);
    }

    status = MEMreset_buffer_no (in_list, 2);
    if (status == MEM_S_SUCCESS)
    {
        status = MEMsplit_copy_buffer (in_list, &buffer1, 0);
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
	MEMclose( &buffer1 );
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        return (status);
    }

    data_ptr1 = (char**)in_list->data_ptr;

    _NFMSdebug(( fname, "Catalog      <%s>\n", data_ptr1[0] ));
    _NFMSdebug(( fname, "Catalog No   <%s>\n", data_ptr1[1] ));
    _NFMSdebug(( fname, "Set          <%s>\n", data_ptr1[2] ));
    _NFMSdebug(( fname, "Revision     <%s>\n", data_ptr1[3] ));
    _NFMSdebug(( fname, "Set No       <%s>\n", data_ptr1[4] ));
    _NFMSdebug(( fname, "Working Area <%s>\n", data_ptr1[5] ));
    _NFMSdebug(( fname, "Member Op    <%s>\n", data_ptr1[6] ));
    _NFMSdebug(( fname, "Level        <%s>\n", data_ptr1[7] ));
    _NFMSdebug(( fname, "Workflow     <%s>\n", data_ptr1[8] ));

    strcpy(cat_name,data_ptr1[0]);
    strcpy(set_name, data_ptr1[2]);
    strcpy(set_rev,data_ptr1[3]);
    strcpy(work_area,data_ptr1[5]);
    cat_no = atol (data_ptr1[1]);
    set_no = atol (data_ptr1[4]);
    mem_op = atol(data_ptr1[6]);
    level = atol (data_ptr1[7]);

    _NFMSdebug(( fname, "Catalog      <%s>\n", cat_name ));
    _NFMSdebug(( fname, "Catalog No   <%d>\n", cat_no ));
    _NFMSdebug(( fname, "Set          <%s>\n", set_name ));
    _NFMSdebug(( fname, "Revision     <%s>\n", set_rev ));
    _NFMSdebug(( fname, "Set No       <%d>\n", set_no ));
    _NFMSdebug(( fname, "Working Area <%s>\n", work_area ));
    _NFMSdebug(( fname, "Member Op    <%d>\n", mem_op ));
    _NFMSdebug(( fname, "Level        <%d>\n", level ));

    wf_info.workflow = atoi(data_ptr1[8]);
    if( wf_info.workflow == NFM_WORKFLOW )
    {
	_NFMSdebug(( fname, "Command       <%s>\n", data_ptr1[9] ));
	_NFMSdebug(( fname, "Workflow Name <%s>\n", data_ptr1[10] ));
	_NFMSdebug(( fname, "Project Name  <%s>\n", data_ptr1[11] ));
	_NFMSdebug(( fname, "Application   <%s>\n", data_ptr1[11] ));
	strcpy( wf_info.command, data_ptr1[9] );
	strcpy( wf_info.workflow_name, data_ptr1[10]);
	strcpy( wf_info.project_name, data_ptr1[11]);
	strcpy( wf_info.app_name, data_ptr1[12] );	
    }

    status = MEMbuild_array (buffer1);
    if (status != MEM_S_SUCCESS)
    {
	MEMclose( &buffer1 );
	_NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        return (status);
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
	(operation+i)->catalog_no = atol( data_ptr2[x+4] );
	strncpy( (operation+i)->item_name, data_ptr2[x+5], NFM_ITEMNAME );
	strncpy( (operation+i)->item_rev, data_ptr2[x+6], NFM_ITEMREV );
    }
    MEMclose( &buffer1 );

    status = MEMbuild_array (in_list);
    if (status != MEM_S_SUCCESS)
    {
        _NFMSdebug(( fname, "MEMbuild_array : <0x%.8x>\n", status));
        return (status);
    }

    status = MEMreset_buffer_no (in_list, 3);
    if (status == MEM_S_SUCCESS)
    {
        status = MEMsplit_copy_buffer (in_list, &filesBuffer, 0);
        if (status != MEM_S_SUCCESS)
        {
            _NFMSdebug(( fname, "MEMsplit_copy_buffer : <0x%.8x>\n", status));
            return (status);
        }
    }
    else
	_NFMSdebug(( fname, "MEMreset_buffer_no(3) <0x%.8x>\n", status));

    status = MEMreset_buffer_no (in_list, 4);
    if (status == MEM_S_SUCCESS)
    {
        status = MEMsplit_copy_buffer (in_list, &keyBuffer, 0);
        if (status != MEM_S_SUCCESS)
        {
	    MEMclose( &filesBuffer);
            _NFMSdebug(( fname, "MEMsplit_copy_buffer : <0x%.8x>\n", status));
            return (status);
        }
    }
    else
	_NFMSdebug(( fname, "MEMreset_buffer_no(4) <0x%.8x>\n", status));

if (_NFMdebug_st.NFMSdebug_on)
    {
    MEMprint_buffers ("FILES BUFFER", filesBuffer,_NFMdebug_st.NFMSdebug_file);
    MEMprint_buffers ("KEY BUFFER", keyBuffer, _NFMdebug_st.NFMSdebug_file);
    }

    ret_status = NFMftr_checkin_set( cat_name, cat_no, 
	set_name, set_rev, set_no, work_area, 
	wf_info, mem_op, operation, level, 
	filesBuffer, keyBuffer );

    _NFMSdebug(( fname, "NFMftr_checkin_set <0x%.8x>\n", ret_status));

    status = NFMSsend_error_buffers( ret_status, ret_status );
    _NFMSdebug(( fname, "NFMSsend_error_buffers <0x%.8x>\n", status ));

    MEMclose( &filesBuffer );
    MEMclose( &keyBuffer );

    free( operation );

    if (ret_status != NFM_S_SUCCESS)
        return (ret_status);

    return (NFM_S_SUCCESS);
}
