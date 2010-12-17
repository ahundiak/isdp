#include "machine.h"
#include "NFMRextern.h"

#define    BUFFER_SIZE    1000

/* 
 Doc: NFMRcancel_co_set
 
 Abstract:
     This function will cancel a checked out set.

 */
 
long NFMRcancel_co_set (user_id, catalog_name, set_name, set_rev)

long    user_id;       /* i - user id for access */
char    *catalog_name; /* i - catalog of set */
char    *set_name;     /* i - set name */
char    *set_rev;      /* i - set revision */

{
MEMptr info      = NULL;
MEMptr data_list = NULL;
char   str[256];
long   status = 0;
long   ret_status = 0;
char   id[20];
static char *fname = "NFMRcancel_co_set";

    _NFMRdebug(( fname, "user_id : <%ld>\n", user_id));
    _NFMRdebug(( fname, "catalog : <%s>\n", catalog_name));
    _NFMRdebug(( fname, "set     : <%s>\n", set_name));
    _NFMRdebug(( fname, "rev     : <%s>\n", set_rev));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return( NFM_E_MEM );
        }

    status = MEMwrite_format (info, "user_id", "char(20)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    sprintf (id, "%ld", user_id);

    strcpy (str, id);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    status = MEMopen (&data_list, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    sprintf( id, "char(%d)", NFM_CATALOGNAME );
    status = MEMwrite_format (data_list, "n_catalogname", id);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
	MEMclose (&data_list);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    sprintf( id, "char(%d)", NFM_ITEMNAME );
    status = MEMwrite_format (data_list, "n_setname", id);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
	MEMclose (&data_list);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    sprintf( id, "char(%d)", NFM_ITEMREV );
    status = MEMwrite_format (data_list, "n_setrev", id);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
	MEMclose (&data_list);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    strcpy (str, catalog_name);
    strcat (str, "\1");
    strcat (str, set_name);
    strcat (str, "\1");
    strcat (str, set_rev);
    strcat (str, "\1");
    status = MEMwrite (data_list, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
	MEMclose (&data_list);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = MEMappend (data_list, info);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
	MEMclose (&data_list);
        _NFMRdebug(( fname, "MEMappend : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_CANCEL_CHECKOUT_SET, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }

    MEMclose (&info);
    MEMclose (&data_list);
    
    status = NFMRreceive_error_buffers (&NFMRglobal.NETid, &ret_status);
    _NFMRdebug(( fname, "NFMRreceive_error_buffers <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if( ret_status != NFM_S_SUCCESS )
        return( ret_status );

    return( NFM_S_SUCCESS );

}


long NFMRcancel_check_out_set (catalog_name, catalog_no, set_name,
      set_revision, set_no, wf_info, member_operations, operation, level)

 char *catalog_name;		 /* I */
 long catalog_no;		 /* I: optional */
 char *set_name;   		 /* I */
 char *set_revision;		 /* I */
 long set_no;    		 /* I: optional */
 struct NFMwf_info wf_info;      /* I */
 long   member_operations; 	 /* I */
 struct NFMoperation *operation; /* I: contains the same information when
                                      NFMcheckout_set is called. */
 long level; 			 /* For future use */
{
MEMptr info = NULL;
MEMptr mem_op = NULL;
char   *str;
char   fmt[20];
long   status = 0;
long   ret_status = 0;
int    wf_flag = 0;
int    i;

static char *fname = "NFMRcancel_check_out_set";

    _NFMRdebug(( fname, "catalog         : <%s>\n", catalog_name));
    _NFMRdebug(( fname, "catalog_no	 : <%ld>\n", catalog_no ));
    _NFMRdebug(( fname, "set             : <%s>\n", set_name ));
    _NFMRdebug(( fname, "revision        : <%s>\n", set_revision ));
    _NFMRdebug(( fname, "set_no  	 : <%ld>\n", set_no ));
    _NFMRdebug(( fname, "member op	 : <%ld>\n", member_operations ));
    _NFMRdebug(( fname, "level		 : <%ld>\n", level ));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", NFM_CATALOGNAME );    
    status = MEMwrite_format (info, "catalog_name", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    status = MEMwrite_format (info, "catalog_no", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", NFM_ITEMNAME );    
    status = MEMwrite_format (info, "set_name", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    sprintf( fmt, "char(%d)", NFM_ITEMREV );    
    status = MEMwrite_format (info, "set_revision", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    status = MEMwrite_format (info, "set_no", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    status = MEMwrite_format (info, "member_op", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    status = MEMwrite_format (info, "level", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    status = MEMwrite_format (info, "workflow", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    if( wf_info.workflow == NFM_WORKFLOW )
    {
	wf_flag = 1;
        sprintf( fmt, "char(%d)", NFM_COMMANDNAME );
        status = MEMwrite_format (info, "command", fmt);
        if (status != MEM_S_SUCCESS)
        {
            MEMclose (&info);
            _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
            ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
            return( NFM_E_MEM );
        }
    
        sprintf( fmt, "char(%d)", NFM_WORKFLOWNAME );
        status = MEMwrite_format (info, "workflow_name", fmt);
        if (status != MEM_S_SUCCESS)
        {
            MEMclose (&info);
            _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
            ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
            return( NFM_E_MEM );
        }
     
        sprintf( fmt, "char(%d)", NFM_PROJECTNAME );
        status = MEMwrite_format (info, "project_name", fmt);
        if (status != MEM_S_SUCCESS)
        {
             MEMclose (&info);
             _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
            ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
            return( NFM_E_MEM );
        }
    
        sprintf( fmt, "char(%d)", NFM_APPLICATION );
        status = MEMwrite_format (info, "app_name", fmt);
        if (status != MEM_S_SUCCESS)
        {
            MEMclose (&info);
            _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
            ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
            return( NFM_E_MEM );
        }
    }
    
    status = MEMopen (&mem_op, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
	MEMclose (&mem_op);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    status = MEMwrite_format (mem_op, "transfer", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
	MEMclose (&mem_op);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    status = MEMwrite_format (mem_op, "delete", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
	MEMclose (&mem_op);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
    
    status = MEMwrite_format (mem_op, "purge", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
	MEMclose (&mem_op);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", NFM_CATALOGNAME );
    status = MEMwrite_format (mem_op, "catalog_name", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
	MEMclose (&mem_op);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", NFM_ITEMNAME );
    status = MEMwrite_format (mem_op, "item_name", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
	MEMclose (&mem_op);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", NFM_ITEMREV );
    status = MEMwrite_format (mem_op, "revision", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
	MEMclose (&mem_op);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    str = (char*)malloc( NFM_CATALOGNAME + NFM_ITEMNAME + NFM_ITEMREV +
          + (wf_flag*
	  (NFM_COMMANDNAME + NFM_WORKFLOWNAME + NFM_PROJECTNAME + 
	  NFM_APPLICATION)) + (INTEGER*5));
        
    strcpy (str, catalog_name);
    strcat (str, "\1");
    sprintf(fmt, "%ld", catalog_no );
    strcat (str, fmt );
    strcat (str, "\1" ); 
    strcat (str, set_name);
    strcat (str, "\1");
    strcat (str, set_revision);
    strcat (str, "\1");
    sprintf(fmt, "%ld", set_no );
    strcat (str, fmt );
    strcat (str, "\1" );
    sprintf(fmt, "%ld", member_operations );
    strcat (str, fmt );
    strcat (str, "\1" );
    sprintf(fmt, "%ld", level );
    strcat (str, fmt );
    strcat (str, "\1" );
    sprintf(fmt, "%d", wf_info.workflow );
    strcat (str, fmt );
    strcat (str, "\1");
    if( wf_flag )
    {
        strcat (str, wf_info.command );
        strcat (str, "\1");
        strcat (str, wf_info.workflow_name );
        strcat (str, "\1");
        strcat (str, wf_info.project_name );
        strcat (str, "\1");
        strcat (str, wf_info.app_name );
        strcat (str, "\1");
    }
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
	free (str);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    free (str);

    str = (char*)malloc( NFM_CATALOGNAME + NFM_ITEMNAME + NFM_ITEMREV +
			 (INTEGER*3));
    for( i=0; ; ++i )
    {
	if( strcmp( (operation+i)->catalog, "" ) == 0 )
	    break;		/*  End of array of structures */
        sprintf(fmt, "%d", (operation+i)->transfer );
        strcpy (str, fmt );
        strcat (str, "\1");
        sprintf(fmt, "%d", (operation+i)->delete );
        strcat (str, fmt );
        strcat (str, "\1");
        sprintf(fmt, "%d", (operation+i)->purge );
        strcat (str, fmt );
        strcat (str, "\1");
	strcat (str, (operation+i)->catalog );
	strcat (str, "\1" );
   	strcat (str, (operation+i)->item_name );
	strcat (str, "\1");   
	strcat (str, (operation+i)->item_rev );
	strcat (str, "\1" );

        status = MEMwrite (mem_op, str);
        if (status != MEM_S_SUCCESS)
        {
            MEMclose (&info);
	    MEMclose (&mem_op);
   	    free (str);
            _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
            ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
            return( NFM_E_MEM );
        }
    }
    free (str);

    status = MEMappend( mem_op, info );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose (&info);
	MEMclose (&mem_op);
	_NFMRdebug(( fname, "MEMappend : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }

    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_CANCEL_CHECK_OUT_SET,
			        info);
    _NFMRdebug(( fname, "Send Buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "NFMcl_send_buffer : <0x%.8x>\n", status));
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_error_buffers (&NFMRglobal.NETid, &ret_status);
    _NFMRdebug((fname, "NFMRreceive_error_buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if( ret_status != NFM_S_SUCCESS )
        return (ret_status); 

    return( NFM_S_SUCCESS );
}

 
