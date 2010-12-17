#include "machine.h"
#include "NFMRextern.h"

#define  BUFFER_SIZE  1000

long NFMRcopy_set_files (catalog_name, catalog_no, set_name, set_revision, 
	set_no, working_area, wf_info, member_operations, 
        operation, level )
   char            *catalog_name;    /* I  Set catalog name. */
   long            catalog_no;       /* I  Optional. If known, n_catalogno
                                          will optimize processing; if not
                                          known, -1. */
   char            *set_name;        /* I  Set item name. */
   char            *set_revision;    /* I  Set item revision. */
   long            set_no;           /* I  Optional. If known, n_itemno
                                          will optimize processing; if not
                                          known, -1. */
   char            *working_area;    /* I  The source working area of the
                                          files to be checked in. */
   struct
   NFMwf_info      wf_info;          /* I  Structure containing the
                                          information needed to call the
                                          workflow functions. */
   long            member_operations; /* I  Denotes how to treat the set
                                          members (NFM_SAME_OPERATION or
                                          NFM_MEMBER_OPERATIONS). */
   struct
   NFMoperation    *operation;        /* I  Pointer to the structure(s)
                                          containing the information needed
                                          to transfer files, delete files,
                                          and purge files and records. */
   long		   level;	      /* I  Reserved */
{
MEMptr info = NULL;
MEMptr mem_op = NULL;
char   *str;
char   fmt[20];
long   status = 0;
long   ret_status = 0;
int    wf_flag = 0;
int    i;

static char *fname = "NFMRcopy_set_files";

    _NFMRdebug(( fname, "catalog         : <%s>\n", catalog_name));
    _NFMRdebug(( fname, "catalog_no	 : <%ld>\n", catalog_no ));
    _NFMRdebug(( fname, "set             : <%s>\n", set_name ));
    _NFMRdebug(( fname, "revision        : <%s>\n", set_revision ));
    _NFMRdebug(( fname, "set_no  	 : <%ld>\n", set_no ));
    _NFMRdebug(( fname, "working area    : <%s>\n", working_area));
    _NFMRdebug(( fname, "member op	 : <%ld>\n", member_operations ));
    _NFMRdebug(( fname, "level		 : <%ld>\n", level ));

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
    status = MEMwrite_format (info, "set_name", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        return (status);
    }
    
    sprintf( fmt, "char(%d)", NFM_ITEMREV );    
    status = MEMwrite_format (info, "set_revision", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        return (status);
    }
    
    status = MEMwrite_format (info, "set_no", "integer");
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

    status = MEMwrite_format (info, "member_op", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        return (status);
    }

    status = MEMwrite_format (info, "level", "integer");
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
    
    status = MEMopen (&mem_op, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
	MEMclose (&mem_op);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        return (status);
    }
    
    status = MEMwrite_format (mem_op, "transfer", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
	MEMclose (&mem_op);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        return (status);
    }
    
    status = MEMwrite_format (mem_op, "delete", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
	MEMclose (&mem_op);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        return (status);
    }
    
    status = MEMwrite_format (mem_op, "purge", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
	MEMclose (&mem_op);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        return (status);
    }

    sprintf( fmt, "char(%d)", NFM_CATALOGNAME );
    status = MEMwrite_format (mem_op, "catalog_name", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
	MEMclose (&mem_op);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        return (status);
    }

    status = MEMwrite_format (mem_op, "catalog_no", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        return (status);
    }

    sprintf( fmt, "char(%d)", NFM_ITEMNAME );
    status = MEMwrite_format (mem_op, "item_name", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
	MEMclose (&mem_op);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        return (status);
    }

    sprintf( fmt, "char(%d)", NFM_ITEMREV );
    status = MEMwrite_format (mem_op, "revision", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
	MEMclose (&mem_op);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        return (status);
    }

    str = (char*)malloc( NFM_CATALOGNAME + NFM_ITEMNAME + NFM_ITEMREV +
          NFM_SANAME + (wf_flag*
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
    strcat (str, working_area);
    strcat (str, "\1");
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
        return (status);
    }

    free (str);

    str = (char*)malloc( NFM_CATALOGNAME + NFM_ITEMNAME + NFM_ITEMREV +
			 (INTEGER*3));

    if( member_operations == NFM_MEMBER_OPERATIONS )
    {
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
        sprintf(fmt, "%d", (operation+i)->catalog_no );
        strcat (str, fmt );
        strcat (str, "\1");
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
            return (status);
        }
      }
    }
    else
    {
        sprintf(fmt, "%d", operation->transfer );
        strcpy (str, fmt );
        strcat (str, "\1");
        sprintf(fmt, "%d", operation->delete );
        strcat (str, fmt );
        strcat (str, "\1");
        sprintf(fmt, "%d", operation->purge );
        strcat (str, fmt );
        strcat (str, "\1");
	strcat (str, operation->catalog );
	strcat (str, "\1" );
        sprintf(fmt, "%d", operation->catalog_no );
        strcat (str, fmt );
        strcat (str, "\1");
   	strcat (str, operation->item_name );
	strcat (str, "\1");   
	strcat (str, operation->item_rev );
	strcat (str, "\1" );
     
        status = MEMwrite (mem_op, str);
        if (status != MEM_S_SUCCESS)
        {
            MEMclose (&info);
	    MEMclose (&mem_op);
   	    free (str);
            _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
            return (status);
        }
    }

    free (str);

    status = MEMappend( mem_op, info );
    if( status != MEM_S_SUCCESS )
    {
	MEMclose (&info);
	MEMclose (&mem_op);
	_NFMRdebug(( fname, "MEMappend : <0x%.8x>\n", status ));
	return( status );
    }

    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_COPY_SET, info);
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
