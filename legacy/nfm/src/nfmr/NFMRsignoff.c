#include "machine.h"
#include "NFMRextern.h"

#define    BUFFER_SIZE    1000

/* 
 Doc: NFMRquery_acl_signoff_users
 
 Abstract:
     This function will return the attributes needed to add signoff users to
     an Access Control List in NFM.  Output buffers are for 
     NFMRenter_signoff_users.

 */
 
long NFMRquery_acl_signoff_users (user_id, acl_name, attr_list,
                                        data_list, value_list)

long    user_id;       /* i - user id for access */
char    *acl_name;     /* i - acl to add signoff users to */
MEMptr  *attr_list;    /* o - the returned attribute list */
MEMptr  *data_list;    /* o - the returned acl user data list */
MEMptr  *value_list;   /* o - the returned acl user value list */

{
MEMptr info = NULL;
char   str[100];
long   status = 0;
long   ret_status = 0;
char   id[20];
static char *fname = "NFMRquery_acl_signoff_users";

    _NFMRdebug(( fname, "user_id  : <%ld>\n", user_id));
    _NFMRdebug(( fname, "acl_name : <%s>\n", acl_name));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
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
    
    sprintf( id, "char(%d)", NFM_ACLNAME );
    status = MEMwrite_format (info, "n_aclname", id);
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
    strcat (str, acl_name);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    status = NFMcl_send_buffer (&NFMRglobal.NETid, WF_QUERY_ADD_SIGNOFF_USER, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }

    MEMclose (&info);

    status = NFMRreceive_three_buffers (&NFMRglobal.NETid, &ret_status,
			attr_list, data_list, value_list);
    _NFMRdebug(( fname, "NET rec 3 Buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if (ret_status != NFM_S_SUCCESS)
        return (ret_status); 

    if (_NFMdebug_st.NFMRdebug_on)
        {
        MEMprint_buffers ("SIGNOFF ATTR", *attr_list, 
				_NFMdebug_st.NFMRdebug_file);
        MEMprint_buffers ("SIGNOFF DATA", *data_list,
				_NFMdebug_st.NFMRdebug_file);
        MEMprint_buffers ("SIGNOFF VALUES", *value_list,
				_NFMdebug_st.NFMRdebug_file);
        }

    return( NFM_S_SUCCESS );
}


/* 
 Doc: NFMRupdate_acl_signoff_users
 
 Abstract:
     This function will add signoff users to an Access Control List given the
     updated buffers returned from NFMRquery_acl_signoff_users.

 */
 
long NFMRupdate_acl_signoff_users (user_id, attr_list, data_list)

long    user_id;       /* i - user id for access */
MEMptr  attr_list;     /* i - the attribute list (from NFMRquery_acl_signoff_users) */
MEMptr  data_list;     /* i - the acl data list (from NFMRquery_acl_signoff_users) */

{
MEMptr info = NULL;
char   str[100];
long   status = 0;
long   ret_status = 0;

static char *fname = "NFMRupdate_acl_signoff_users";

    _NFMRdebug(( fname, "user_id  : <%ld>\n", user_id));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
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
    
    sprintf (str, "%ld\1", user_id);
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = MEMappend (attr_list, info);
    if (status != MEM_S_SUCCESS)
        {
	MEMclose (&info);
        _NFMRdebug(( fname, "MEMappend : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    status = MEMappend (data_list, info);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMappend : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    status = NFMcl_send_buffer (&NFMRglobal.NETid, WF_ADD_SIGNOFF_USER, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }

    MEMclose (&info);

    status = NFMRreceive_error_buffers (&NFMRglobal.NETid, &ret_status);
    _NFMRdebug(( fname, "NET rec error Buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        return (status);
    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if( ret_status != NFM_S_SUCCESS )
        return( ret_status );

    return( NFM_S_SUCCESS );

}



/* 
 Doc: NFMRquery_signoff_attributes
 
 Abstract:
     This function will return the attributes needed to add signoff a user.

 */
 
long NFMRquery_signoff_attributes (user_id, attr_list, data_list, value_list)

long    user_id;       /* i - user id for access */
MEMptr  *attr_list;    /* o - the returned attribute list */
MEMptr  *data_list;    /* o - the returned data list */
MEMptr  *value_list;   /* o - the returned value list */

{
MEMptr info = NULL;
long   status = 0;
long   ret_status = 0;
char   id[20];
static char *fname = "NFMRquery_signoff_attributes";

    _NFMRdebug(( fname, "user_id  : <%ld>\n", user_id));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
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
    
    sprintf (id, "%ld\1", user_id);
    status = MEMwrite (info, id);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = NFMcl_send_buffer (&NFMRglobal.NETid, WF_QUERY_SIGNOFF_ATTR, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }

    MEMclose (&info);

    status = NFMRreceive_three_buffers (&NFMRglobal.NETid, &ret_status, 
		attr_list, data_list, value_list);
    _NFMRdebug(( fname, "NET rec 3 Buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if (ret_status != NFM_S_SUCCESS)
        return (ret_status); 

    if (_NFMdebug_st.NFMRdebug_on)
        {
        MEMprint_buffers ("SIGNOFF ATTR", *attr_list,
			_NFMdebug_st.NFMRdebug_file);
        MEMprint_buffers ("SIGNOFF DATA", *data_list,
			_NFMdebug_st.NFMRdebug_file);
        MEMprint_buffers ("SIGNOFF VALUES", *value_list,
			_NFMdebug_st.NFMRdebug_file);
        }

    return( NFM_S_SUCCESS );

}


/* 
 Doc: NFMRsignoff
 
 Abstract:
     This function will add signoff a user given the
     updated buffers returned from NFMRquery_signoff_attributes.
     
 */
 
long NFMRsignoff (user_id, attr_list, data_list)

long    user_id;       /* i - user id for access */
MEMptr  attr_list;     /* i - the attribute list (from NFMRquery_signoff_attributes) */
MEMptr  data_list;     /* i - the acl data list (from NFMRquery_signoff_attributes) */

{
MEMptr info = NULL;
long   status = 0;
long   ret_status = 0;
char   id[20];
static char *fname = "NFMRsignoff";

    _NFMRdebug(( fname, "user_id  : <%ld>\n", user_id));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
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
    
    sprintf (id, "%ld\1", user_id);
    status = MEMwrite (info, id);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = MEMappend (attr_list, info);
    if (status != MEM_S_SUCCESS)
        {
        _NFMRdebug(( fname, "MEMappend : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    status = MEMappend (data_list, info);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMappend : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    status = NFMcl_send_buffer (&NFMRglobal.NETid, WF_SIGNOFF, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }

    MEMclose (&info);

    status = NFMRreceive_error_buffers (&NFMRglobal.NETid, &ret_status);
    _NFMRdebug(( fname, "NET rec error Buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if( ret_status != NFM_S_SUCCESS )
        return( ret_status );

    return( NFM_S_SUCCESS );

}


long NFMRpurge_signoff (user_id, catalog_name, item_name, item_rev)

long    user_id;       /* i - user id for access */
char    *catalog_name; /* active catalog_name */
char    *item_name;    /* active item name */
char    *item_rev;     /* active item rev */

{
  MEMptr info = NULL ;
  char   str [100];
  long   status = 0;
  long   ret_status = 0;
  char   id[20];
  static char *fname = "NFMRpurge_signoff";
  
  _NFMRdebug(( fname, "user_id  : <%ld>\n", user_id));
  
  status = MEMopen (&info, BUFFER_SIZE);
  if (status != MEM_S_SUCCESS)
    {
      MEMclose (&info);
      _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
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
  
  sprintf( id, "char(%d)", NFM_CATALOGNAME );
  status = MEMwrite_format (info, "n_catalogname", id);
  if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
  sprintf( id, "char(%d)", NFM_ITEMNAME );
  status = MEMwrite_format (info, "n_itemname", id);
  if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
  
  sprintf( id, "char(%d)", NFM_ITEMREV );
  status = MEMwrite_format (info, "n_itemrev", id);
  if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
  
  sprintf (id, "%ld", user_id) ;
  
  strcpy (str, id) ;
  strcat (str, "\1") ;
  strcat (str, catalog_name) ;
  strcat (str, "\1") ;
  strcat (str, item_name) ;
  strcat (str, "\1") ;
  strcat (str, item_rev) ;
  strcat (str, "\1") ;
  
  status = MEMwrite (info, str);
  if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
  
  status = NFMcl_send_buffer (&NFMRglobal.NETid, WF_PURGE_SIGNOFF, info);
  _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
  if (status != NFM_S_SUCCESS)
    {
      MEMclose (&info);
      return (status);
    }
  
  MEMclose (&info);
  
  status = NFMRreceive_error_buffers (&NFMRglobal.NETid, &ret_status);
  _NFMRdebug(( fname, "NET rec error Buffer : <0x%.8x>\n", status));
  if (status != NFM_S_SUCCESS)
      return (status);
  
  _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));
  
    if( ret_status != NFM_S_SUCCESS )
        return( ret_status );

    return( NFM_S_SUCCESS );

}






