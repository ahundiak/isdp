#include "machine.h"
#include "NFMRextern.h"

#define    BUFFER_SIZE    1000

long NFMRdefine_set_information (catalog_name, catalog_no, set_name, 
	set_revision, file_status_check, members_to_define, members_info)
 
   char            *catalog_name;     /*  I  Set catalog name. */
   long            catalog_no;        /*  I  Optional. If known, n_catalogno
                                          will optimize processing; if not
                                          known, -1. */
   char            *set_name;         /*  I  Set item name. */
   char            *set_revision;     /*  I  Set item revision. */
   long            file_status_check; /*  I  Denotes whether or not to check
                                          the set's file status before
                                          allowing modification
                                          (NFM_NO_FILE_STATUS_CHECK or
                                          NFM_FILE_STATUS_CHECK). */
   long            members_to_define; /*  I  Number of NFMmember_info
                                          structions in the members_info
                                          argument to be manipulated. */
   struct
   NFMmember_info  *members_info;     /*  I  Pointer to the structure(s)
                                          containing the information
                                          required to manipulate the set
                                          member(s). */
{
MEMptr info = NULL;
MEMptr m_info = NULL;
char   str[256];
char   fmt[20];
long   status = 0;
long   ret_status = 0;
int    i;

static char *fname = "NFMRdefine_set_information";

    _NFMRdebug(( fname, "catalog         : <%s>\n", catalog_name));
    _NFMRdebug(( fname, "catalog_no      : <%ld>\n", catalog_no));
    _NFMRdebug(( fname, "set             : <%s>\n", set_name ));
    _NFMRdebug(( fname, "revision        : <%s>\n", set_revision ));
    _NFMRdebug(( fname, "status_check    : <%ld>\n", file_status_check));
    _NFMRdebug(( fname, "members_to_define : <%ld>\n", members_to_define));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
	ERRload_struct( NFM, NFM_E_MEM, fname, "MEMopen" );
	return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", NFM_CATALOGNAME );    
    status = MEMwrite_format (info, "catalog_name", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, fname, "MEMwrite_format" );
        return( NFM_E_MEM );
     }

    status = MEMwrite_format (info, "catalog_no", "integer" );
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, fname, "MEMwrite_format" );
        return( NFM_E_MEM );
    }
    
    sprintf( fmt, "char(%d)", NFM_ITEMNAME );    
    status = MEMwrite_format (info, "set_name", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, fname, "MEMwrite_format" );
        return( NFM_E_MEM );
     }
    
    sprintf( fmt, "char(%d)", NFM_ITEMREV );    
    status = MEMwrite_format (info, "set_revision", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, fname, "MEMwrite_format" );
        return( NFM_E_MEM );
     }
    
    status = MEMwrite_format (info, "status_check", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, fname, "MEMwrite_format" );
        return( NFM_E_MEM );
     }

    status = MEMwrite_format (info, "members_to_define", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
    }
    
    strcpy (str, catalog_name);
    strcat (str, "\1");
    sprintf(fmt, "%ld", catalog_no );
    strcat (str, fmt);
    strcat (str, "\1");
    strcat (str, set_name);
    strcat (str, "\1");
    strcat (str, set_revision);
    strcat (str, "\1");
    sprintf(fmt, "%ld", file_status_check );
    strcat (str, fmt);
    strcat (str, "\1");
    sprintf(fmt, "%ld", members_to_define );
    strcat (str, fmt);
    strcat (str, "\1");

    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, fname, "MEMwrite" );
        return( NFM_E_MEM );
     }

    status = MEMopen (&m_info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
	MEMclose (&m_info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, fname, "MEMopen" );
        return( NFM_E_MEM );
     }
    
    status = MEMwrite_format (m_info, "operation", "integer" );
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
	MEMclose (&m_info);       
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, fname, "MEMwrite_format" );
        return( NFM_E_MEM );
     }
    
    status = MEMwrite_format (m_info, "citno", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
	MEMclose (&m_info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, fname, "MEMwrite_format" );
        return( NFM_E_MEM );
     }

    sprintf( fmt, "char(%d)", NFM_CATALOGNAME);
    status = MEMwrite_format (m_info, "catalog_name", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
	MEMclose (&m_info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, fname, "MEMwrite_format" );
        return( NFM_E_MEM );
     }
        
    status = MEMwrite_format (m_info, "catalog_no", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
	MEMclose (&m_info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, fname, "MEMwrite_format" );
        return( NFM_E_MEM );
     }
    
    sprintf( fmt, "char(%d)", NFM_ITEMNAME );    
    status = MEMwrite_format (m_info, "item_name", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
	MEMclose (&m_info);
        ERRload_struct( NFM, NFM_E_MEM, fname, "MEMwrite_format" );
        return( NFM_E_MEM );
     }
    
    sprintf( fmt, "char(%d)", NFM_ITEMREV );    
    status = MEMwrite_format (m_info, "item_revision", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
	MEMclose (&m_info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, fname, "MEMwrite_format" );
        return( NFM_E_MEM );
     }
        
    status = MEMwrite_format (m_info, "item_no", "integer");
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
	MEMclose (&m_info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, fname, "MEMwrite_format" );
        return( NFM_E_MEM );
    }

    sprintf( fmt, "char(%d)", NFM_TYPE );    
    status = MEMwrite_format (m_info, "type", fmt);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
	MEMclose (&m_info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, fname, "MEMwrite_format" );
        return( NFM_E_MEM );
     }

    for( i=0; i<members_to_define; ++i )
    {
	_NFMRdebug(( fname, "Member <%s.%s.%s>\n",
(members_info+i)->catalog_name, (members_info+i)->item_name,
(members_info+i)->item_rev ));
	sprintf(fmt, "%d", (members_info+i)->operation );
	strcpy( str, fmt );
	strcat( str, "\1" );
        sprintf(fmt, "%ld", (members_info+i)->citno );
	strcat( str, fmt );
 	strcat( str, "\1" );
	strcat( str, (members_info+i)->catalog_name );
	strcat( str, "\1" );
 	sprintf(fmt, "%ld", (members_info+i)->catalog_no );
	strcat( str, fmt );
	strcat( str, "\1" );
	strcat( str, (members_info+i)->item_name );
	strcat( str, "\1" );
	strcat( str, (members_info+i)->item_rev );
	strcat( str, "\1" );
 	sprintf(fmt, "%ld", (members_info+i)->item_no );
	strcat( str, fmt );
	strcat( str, "\1" );
	strcat( str, (members_info+i)->type );
	strcat( str, "\1" );
	
        status = MEMwrite (m_info, str);
        if (status != MEM_S_SUCCESS)
        {
            MEMclose (&info);
	    MEMclose (&m_info);
            _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
            ERRload_struct( NFM, NFM_E_MEM, fname, "MEMwrite" );
            return( NFM_E_MEM );
         }
    }

    status = MEMappend (m_info, info);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
	MEMclose (&m_info);
        _NFMRdebug(( fname, "MEMappend : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, fname, "MEMwrite_format" );
        return( NFM_E_MEM );
    }

    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_DEFINE_SET_INFO, info);
    _NFMRdebug(( fname, "Send Buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
	MEMclose (&m_info);
        _NFMRdebug(( fname, "NFMcl_send_buffer : <0x%.8x>\n", status));
        return (status);
    }

    MEMclose (&info);
    MEMclose (&m_info);

    status = NFMRreceive_error_buffers (&NFMRglobal.NETid, &ret_status);
    _NFMRdebug((fname, "NFMRreceive_error_buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if( ret_status != NFM_S_SUCCESS )
        return (ret_status); 

    return( NFM_S_SUCCESS );
}

long NFMRget_set_messages (data_list)

MEMptr  *data_list;       /* o - list of data */
{
    long   status;
    long   ret_status;
    MEMptr info = NULL;
    static char *fname = "NFMRget_set_messages";

    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_GET_SET_MESSAGES, info );
    _NFMRdebug(( fname, "Send Buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        _NFMRdebug(( fname, "NFMcl_send_buffer : <0x%.8x>\n", status));
        return (status);
    }
    MEMclose( &info );

    status = NFMRreceive_one_buffer(&NFMRglobal.NETid, &ret_status, data_list);
    _NFMRdebug((fname, "NFMRreceive_one_buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
    {
        _NFMRdebug(( fname, "NFMRreceive_buffer : <0x%.8x>\n", status));
        return (status);
    }

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if( ret_status != NFM_S_SUCCESS )
        return (ret_status); 

    return( NFM_S_SUCCESS );
}
