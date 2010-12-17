#include "machine.h"
#include "NFMRextern.h"

#define    BUFFER_SIZE    1000

/* 
 Doc: NFMRget_wf_and_completed_acl_list
 
 Abstract:
     This function will return the attributes needed to list the workflows
     and completed ACLs.
 */
 
long NFMRget_wf_and_completed_acl_list (syn_list, data_list)
     MEMptr *syn_list ;    /* output - */
     MEMptr *data_list ;   /* output - */
{
MEMptr info = NULL;
long   status = 0;
long   ret_status = 0;
char   fmt[NFM_SYNONYM+1];
static char *fname = "NFMRget_wf_and_completed_acl_list";

    _NFMRdebug(( fname, "<%s>\n", "Entering ..." ));
    
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_GET_WF_AND_COMPLETED_ACL_LIST,  info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }

    MEMclose (&info);

    status = NFMRreceive_two_buffers (&NFMRglobal.NETid, &ret_status,
				      syn_list, data_list);
    _NFMRdebug(( fname, "NFMRreceive_two_buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if (ret_status != NFM_S_SUCCESS)
        return (ret_status); 

    if(_NFMdebug_st.NFMRdebug_on)
    {
        MEMprint_buffers( "SYN LIST",  *syn_list,
                           _NFMdebug_st.NFMRdebug_file );
        MEMprint_buffers( "DATA LIST", *data_list,
                           _NFMdebug_st.NFMRdebug_file );
    }

    return( NFM_S_SUCCESS );

}

/* 
 Doc: NFMRget_state_list_for_workflow
 
 Abstract:
     This function will return the attributes needed to list the states defined
     for a given workflow.
 */
 
long NFMRget_state_list_for_workflow (wf_name, syn_list, data_list)
     char *wf_name ;       /* input - wf name */
     MEMptr *syn_list ;    /* output - */
     MEMptr *data_list ;   /* output - */
{
MEMptr info = NULL;
long   status = 0;
long   ret_status = 0;
char   fmt[NFM_SYNONYM+1];
char   *str;
static char *fname = "NFMRget_state_list_for_workflow";

    _NFMRdebug(( fname, "wf name : <%s>\n", wf_name));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    sprintf( fmt, "char(%d)", NFM_WORKFLOWNAME );
    status = MEMwrite_format (info, "n_workflowname", fmt);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    str = (char*) malloc (NFM_WORKFLOWNAME + INTEGER );

    strcpy (str, wf_name );
    strcat (str, "\1" );
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    free( str );
    
    status = NFMcl_send_buffer (&NFMRglobal.NETid,NFM_GET_STATE_LIST_FOR_WORKFLOW, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }

    MEMclose (&info);

    status = NFMRreceive_two_buffers (&NFMRglobal.NETid, &ret_status,
				      syn_list, data_list);
    _NFMRdebug(( fname, "NFMRreceive_two_buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if(_NFMdebug_st.NFMRdebug_on)
    {
        MEMprint_buffers( "SYN LIST",  *syn_list,
                           _NFMdebug_st.NFMRdebug_file );
        MEMprint_buffers( "DATA LIST", *data_list,
                           _NFMdebug_st.NFMRdebug_file );
    }

    if (ret_status != NFM_S_SUCCESS)
        return (ret_status); 

    return( NFM_S_SUCCESS );

}


/* 
 Doc: NFMRchange_wf_item
 
 Abstract:
     This function will change the workflow of an item given
     an input acl and state.
     
 */
 
long NFMRchange_wf_item (catalog_name, item_name, item_rev, workflow, 
	acl_name, acl_no, state_name, state_no)
     char *catalog_name ;   /** input - catalog name **/
     char *item_name ;      /** input - item name **/
     char *item_rev ;       /** input - item rev **/
     char *workflow;	    /** input - workflow **/
     char *acl_name;	    /** input - acl name **/
     long acl_no ;          /** input - acl no   **/
     char *state_name;	    /** input - state name **/
     long state_no ;        /** input - state no **/
{
MEMptr info = NULL;
char   *str;
long   status = 0;
long   ret_status = 0;
char   fmt[NFM_SYNONYM+1];
static char *fname = "NFMRchange_wf_item";

    _NFMRdebug(( fname, "catalog name  : <%s>\n", catalog_name));
    _NFMRdebug(( fname, "item name     : <%s>\n", item_name));
    _NFMRdebug(( fname, "item rev      : <%s>\n", item_rev));
    _NFMRdebug(( fname, "workflow      : <%s>\n", workflow));
    _NFMRdebug(( fname, "acl name      : <%s>\n", acl_name ));
    _NFMRdebug(( fname, "acl no        : <%ld>\n", acl_no));
    _NFMRdebug(( fname, "state name    : <%s>\n", state_name ));
    _NFMRdebug(( fname, "state no      : <%ld>\n", state_no));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    sprintf( fmt, "char(%d)", NFM_CATALOGNAME );    
    status = MEMwrite_format (info, "n_catalogname", fmt);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    sprintf( fmt, "char(%d)", NFM_ITEMNAME );    
    status = MEMwrite_format (info, "n_itemname", fmt);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    sprintf( fmt, "char(%d)", NFM_ITEMREV );    
    status = MEMwrite_format (info, "n_itemrev", fmt);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    sprintf( fmt, "char(%d)", NFM_WORKFLOWNAME );    
    status = MEMwrite_format (info, "n_workflowname", fmt);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }


    sprintf( fmt, "char(%d)", NFM_ACLNAME );    
    status = MEMwrite_format (info, "n_aclname", fmt);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    status = MEMwrite_format (info, "n_aclno", "integer");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }


    sprintf( fmt, "char(%d)", NFM_STATENAME );    
    status = MEMwrite_format (info, "n_statename", fmt);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    status = MEMwrite_format (info, "n_stateno", "integer");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    str = (char*)malloc( NFM_CATALOGNAME+NFM_ITEMNAME+NFM_ITEMREV+
		NFM_WORKFLOWNAME+NFM_ACLNAME+NFM_STATENAME+(INTEGER*2));

    sprintf (str, "%s\1%s\1%s\1%s\1%s\1%ld\1%s\1%ld\1", 
	catalog_name, item_name, item_rev, workflow, 
	acl_name, acl_no, state_name, state_no);

    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
	free( str );
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    free( str );
    
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_CHANGE_WF_ITEM,
				 info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }

    MEMclose (&info);

    status = NFMRreceive_error_buffers (&NFMRglobal.NETid, &ret_status);
    _NFMRdebug(( fname, "NFMRreceive_error_buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if( ret_status != NFM_S_SUCCESS )
        return( ret_status );

    return( NFM_S_SUCCESS );

}



