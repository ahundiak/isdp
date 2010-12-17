#include "machine.h"
#include "NFMRextern.h"

#define   BUFFER_SIZE  1000

long NFMRcopy_item_files (catalog_name, catalog_no, item_name, item_revision,
			  working_area, wf_info, operation)
   char            *catalog_name;  /* I  Item's catalog name. */
   long		   catalog_no;     /* I  Catalog number. */
   char            *item_name;     /* I  Item name. */
   char            *item_revision; /* I  Item revision. */
   char            *working_area;  /* I  The source working area of the
                                          files to be checked in. */
   struct
   NFMwf_info      wf_info;        /* I  Structure containing the
                                          information needed to call the
                                          workflow functions. */
   struct
   NFMoperation    operation;      /* I  Structure containing the
                                          information needed to transfer
                                          files, delete files, and purge
                                          files and records. */
{
MEMptr info = NULL;
char   *str;
char   fmt[20];
long   status = 0;
long   ret_status = 0;
int    wf_flag = 0;

static char *fname = "NFMRcopy_item_files";

    _NFMRdebug(( fname, "catalog         : <%s>\n", catalog_name));
    _NFMRdebug(( fname, "catalog_no      : <%ld>\n", catalog_no ));
    _NFMRdebug(( fname, "item            : <%s>\n", item_name ));
    _NFMRdebug(( fname, "revision        : <%s>\n", item_revision ));
    _NFMRdebug(( fname, "working area    : <%s>\n", working_area));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        return (status);
    }

    sprintf( fmt, "char(%d)", NFM_CATALOGNAME );    
    status = MEMwrite_format (info, "catalog_name", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        return (status);
    }

    status = MEMwrite_format (info, "catalog_no", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        return (status);
    }
    
    sprintf( fmt, "char(%d)", NFM_ITEMNAME );    
    status = MEMwrite_format (info, "item_name", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        return (status);
    }
    
    sprintf( fmt, "char(%d)", NFM_ITEMREV );    
    status = MEMwrite_format (info, "item_revision", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        return (status);
    }
    
    sprintf( fmt, "char(%d)", NFM_SANAME );
    status = MEMwrite_format (info, "working_area", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        return (status);
    }

    status = MEMwrite_format (info, "transfer", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        return (status);
    }
    
    status = MEMwrite_format (info, "delete", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        return (status);
    }
    
    status = MEMwrite_format (info, "purge", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        return (status);
    }
    
    status = MEMwrite_format (info, "workflow", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        return (status);
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
            return (status);
        }
     
        sprintf( fmt, "char(%d)", NFM_WORKFLOWNAME );
        status = MEMwrite_format (info, "workflow_name", fmt);
        if (status != MEM_S_SUCCESS)
        {
            MEMclose (&info);
            _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
            return (status);
        }
    
        sprintf( fmt, "char(%d)", NFM_PROJECTNAME );
        status = MEMwrite_format (info, "project_name", fmt);
        if (status != MEM_S_SUCCESS)
        {
            MEMclose (&info);
            _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
            return (status);
        }
    
        sprintf( fmt, "char(%d)", NFM_APPLICATION );
        status = MEMwrite_format (info, "app_name", fmt);
        if (status != MEM_S_SUCCESS)
        {
            MEMclose (&info);
            _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
            return (status);
        }
    }    
    str = (char*)malloc( NFM_CATALOGNAME + NFM_ITEMNAME + NFM_ITEMREV +
                         NFM_SANAME + (wf_flag*(NFM_COMMANDNAME + 
			 NFM_WORKFLOWNAME + NFM_PROJECTNAME + NFM_APPLICATION))
			 + (INTEGER*5));
     
    strcpy (str, catalog_name);
    strcat (str, "\1");
    sprintf(fmt, "%ld", catalog_no );
    strcat (str, fmt );
    strcat (str, "\1" );
    strcat (str, item_name);
    strcat (str, "\1");
    strcat (str, item_revision);
    strcat (str, "\1");
    strcat (str, working_area);
    strcat (str, "\1");
    sprintf(fmt, "%d", operation.transfer );
    strcat (str, fmt );
    strcat (str, "\1");
    sprintf(fmt, "%d", operation.delete );
    strcat (str, fmt );
    strcat (str, "\1");
    sprintf(fmt, "%d", operation.purge );
    strcat (str, fmt );
    strcat (str, "\1");
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
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
	free (str);
        return (status);
    }

    free (str);

    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_COPY_ITEM_FILES, info);
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

/* 
 Doc: NFMRcopy_item_n
 
 Abstract:
     This function will copy an item.  The input buffers are
     from NFMRget_item_attr_for_copy
     
 */
 
long NFMRcopy_item_n (catalog_name, attr_list, data_list,
		      attr_f_list, data_f_list) 

char    *catalog_name; /* i - storage location */
MEMptr  attr_list;     /* i - list of attributes catalog level*/
MEMptr  data_list;     /* i - list of data catalog level */
MEMptr  attr_f_list;     /* i - list of attributes f_catalog level */
MEMptr  data_f_list;     /* i - list of data data f_catalog level */

{
MEMptr info = NULL;
char   str[256];
long   status = 0;
long   ret_status = 0;
char   id[20];
static char *fname = "NFMRcopy_item_n" ;

    _NFMRdebug(( fname, "catalog name  <%s>\n", catalog_name)) ;

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }
    
    sprintf( id, "char(%d)", NFM_CATALOGNAME );    
    status = MEMwrite_format (info, "n_catalogname", id);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }
    
    strcpy (str, catalog_name);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        return (status);
        }
    
    status = MEMappend (attr_list, info);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMappend : <0x%.8x>\n", status));
        return (status);
        }

    status = MEMappend (data_list, info);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMappend : <0x%.8x>\n", status));
        return (status);
        }

    status = MEMappend (attr_f_list, info);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMappend : <0x%.8x>\n", status));
        return (status);
        }

    status = MEMappend (data_f_list, info);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMappend : <0x%.8x>\n", status));
        return (status);
        }

    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_COPY_ITEM_N, info);
    _NFMRdebug(( fname, "Send Buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }

    MEMclose (&info);

    status = NFMRreceive_error_buffers (&NFMRglobal.NETid, &ret_status);
    _NFMRdebug(( fname, "NFMRreceive_error_buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if( ret_status != NFM_S_SUCCESS )
        return (ret_status); 

    return( NFM_S_SUCCESS );
}





