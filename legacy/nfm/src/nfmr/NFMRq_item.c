#include "machine.h"
#include "NFMRextern.h"

#define  BUFFER_SIZE  1000
/* 
 Doc: NFMRquery_add_item_attributes
 
 Abstract:
     This function will query for the attributes needed to add an item. 
     Output buffers are for NFMRadd_item.

 */
 
long NFMRquery_add_item_attributes (user_id, catalog_name, 
                                    attr_list, data_list, value_list)

long    user_id;          /* i - user id for access */
char    *catalog_name;    /* i - the catalog name to query */
MEMptr  *attr_list;       /* o - list of attributes */
MEMptr  *data_list;       /* o - list of data */
MEMptr  *value_list;      /* o - list of values */

{
MEMptr info = NULL;
char   str[256];
long   status = 0;
long   ret_status = 0;
char   id[20];

static char *fname = "NFMRquery_add_item_attributes";

    _NFMRdebug(( fname, "user_id : <%ld>\n", user_id));
    _NFMRdebug(( fname, "catalog : <%s>\n", catalog_name));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = MEMwrite_format (info, "user_id", "char(20)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    sprintf( id, "char(%d)", NFM_CATALOGNAME );
    status = MEMwrite_format (info, "n_catalogname", id);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    sprintf (str, "%ld", user_id);
    strcat (str, "\1");
    strcat (str, catalog_name);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_QUERY_ADD_ITEM, info);
    _NFMRdebug(( fname, "Send Buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }

    MEMclose (&info);

    status = NFMRreceive_three_buffers (&NFMRglobal.NETid, &ret_status, 
		attr_list, data_list, value_list );
    _NFMRdebug(( fname, "NFMRreceive_three_buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if (ret_status != NFM_S_SUCCESS)
        return (ret_status); 

    if (_NFMdebug_st.NFMRdebug_on)
        {
        MEMprint_buffers ("ITEM ATTR LIST", *attr_list,	
			   _NFMdebug_st.NFMRdebug_file);
        MEMprint_buffers ("ITEM DATA LIST", *data_list, 
			   _NFMdebug_st.NFMRdebug_file);
        MEMprint_buffers ("ITEM VALUE LIST", *value_list, 
			   _NFMdebug_st.NFMRdebug_file);
        }
  
    return (NFM_S_SUCCESS); 
}


/* 
 Doc: NFMRquery_item_attributes
 
 Abstract:
     This function will query for an item's attributes.
     
 */
 
long NFMRquery_item_attributes (user_id, catalog_name, item_name, item_rev,
                                attr_list, data_list, value_list)

long    user_id;          /* i - user id for access */
char    *catalog_name;    /* i - the catalog name to query */
char    *item_name;       /* i - the item to query */
char    *item_rev;        /* i - the item's revision */
MEMptr  *attr_list;       /* o - list of attributes */
MEMptr  *data_list;       /* o - list of data */
MEMptr  *value_list;      /* o - list of values */

{
MEMptr info = NULL;
char   str[256];
long   status = 0;
long   ret_status = 0;
char   id[20];

static char *fname = "NFMRquery_item_attributes";

    _NFMRdebug(( fname, "user_id : <%ld>\n", user_id));
    _NFMRdebug(( fname, "catalog : <%s>\n", catalog_name));
    _NFMRdebug(( fname, "item    : <%s>\n", item_name));
    _NFMRdebug(( fname, "rev     : <%s>\n", item_rev));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = MEMwrite_format (info, "user_id", "char(20)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    sprintf( id, "char(%d)", NFM_CATALOGNAME );    
    status = MEMwrite_format (info, "n_catalogname", id);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    sprintf( id, "char(%d)", NFM_ITEMNAME );
    status = MEMwrite_format (info, "n_itemname", id);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    sprintf( id, "char(%d)", NFM_ITEMREV );
    status = MEMwrite_format (info, "n_itemrev", id);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    sprintf (str, "%ld", user_id);
    strcat (str, "\1");
    strcat (str, catalog_name);
    strcat (str, "\1");
    strcat (str, item_name);
    strcat (str, "\1");
    strcat (str, item_rev);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_QUERY_ITEM_ATTR, info);
    _NFMRdebug(( fname, "Send Buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }

    MEMclose (&info);

    status = NFMRreceive_three_buffers (&NFMRglobal.NETid, &ret_status, 
		attr_list, data_list, value_list );
    _NFMRdebug(( fname, "NFMRreceive_three_buffers : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if (ret_status != NFM_S_SUCCESS)
        return (ret_status); 

    if( _NFMdebug_st.NFMRdebug_on )
    {
        MEMprint_buffers ("ITEM ATTR LIST", *attr_list, 
			   _NFMdebug_st.NFMRdebug_file);
        MEMprint_buffers ("ITEM DATA LIST", *data_list, 
			   _NFMdebug_st.NFMRdebug_file);
        MEMprint_buffers ("ITEM VALUE LIST", *value_list, 
			   _NFMdebug_st.NFMRdebug_file);
        }

    return (NFM_S_SUCCESS); 
}

long NFMRquery_item_versions (user_id, catalog_name, item_name, item_rev,
                                attr_list, data_list)

long    user_id;          /* i - user id for access */
char    *catalog_name;    /* i - the catalog name to query */
char    *item_name;       /* i - the item to query */
char    *item_rev;        /* i - the item's revision */
MEMptr  *attr_list;       /* o - list of attributes */
MEMptr  *data_list;       /* o - list of data */

{
MEMptr info = NULL;
char   str[256];
long   status = 0;
long   ret_status = 0;
char   id[20];

static char *fname = "NFMRquery_item_versions";

    _NFMRdebug(( fname, "user_id : <%ld>\n", user_id));
    _NFMRdebug(( fname, "catalog : <%s>\n", catalog_name));
    _NFMRdebug(( fname, "item    : <%s>\n", item_name));
    _NFMRdebug(( fname, "rev     : <%s>\n", item_rev));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = MEMwrite_format (info, "user_id", "char(20)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    sprintf( id, "char(%d)", NFM_CATALOGNAME );
    status = MEMwrite_format (info, "n_catalogname", id);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    sprintf( id, "char(%d)", NFM_ITEMNAME );
    status = MEMwrite_format (info, "n_itemname", id);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    sprintf( id, "char(%d)", NFM_ITEMREV );
    status = MEMwrite_format (info, "n_itemrev", id);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    sprintf (str, "%ld", user_id);
    strcat (str, "\1");
    strcat (str, catalog_name);
    strcat (str, "\1");
    strcat (str, item_name);
    strcat (str, "\1");
    strcat (str, item_rev);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_QUERY_ITEM_VERSIONS, info);
    _NFMRdebug(( fname, "Send Buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }

    MEMclose (&info);

    status = NFMRreceive_two_buffers (&NFMRglobal.NETid, &ret_status, 
		attr_list, data_list);
    _NFMRdebug(( fname, "NFMRreceive_two_buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if (ret_status != NFM_S_SUCCESS)
        return (ret_status); 

    if (_NFMdebug_st.NFMRdebug_on)
        {
        MEMprint_buffers("ITEM ATTR LIST", *attr_list, 
			  _NFMdebug_st.NFMRdebug_file);
        MEMprint_buffers("ITEM DATA LIST", *data_list, 
			  _NFMdebug_st.NFMRdebug_file);
        }

    return (NFM_S_SUCCESS); 
}

/* 
 Doc: NFMRget_item_attr_for_copy
 
 Abstract:
     This function will query for the attributes needed to copy an item. 
     Output buffers are for NFMRcopy_item_n
         
 */
 
long NFMRget_item_attr_for_copy (catalog_name, itemname, itemrev,
				 attr_list, data_list, value_list,
				 attr_f_list, data_f_list, value_f_list)

char    *catalog_name;    /* i - the catalog name to query */
char    *itemname;        /* i - the item name to query */
char    *itemrev;         /* i - the item rev to query */
MEMptr  *attr_list;       /* o - list of attributes */
MEMptr  *data_list;       /* o - list of data */
MEMptr  *value_list;      /* o - list of values */
MEMptr  *attr_f_list;       /* o - list of attributes */
MEMptr  *data_f_list;       /* o - list of data */
MEMptr  *value_f_list;      /* o - list of values */
{
  MEMptr info = NULL;
  char   str[256];
  long   status = 0;
  long   ret_status = 0;
  char   id[20];
  
  char *fname = "NFMRget_item_attr_for_copy" ;
  
  _NFMRdebug(( fname, "catalog <%s>\n", catalog_name ));
  _NFMRdebug(( fname, "item name <%s>\n", itemname ));
  _NFMRdebug(( fname, "item rev <%s>\n", itemrev )); 
  
  status = MEMopen (&info, BUFFER_SIZE);
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      _NFMRdebug ((fname, "MEMopen : status = <0x%.8x>\n", status)) ;
      MEMclose (&info);
      return (NFM_E_MEM);
    }

  sprintf( id, "char(%d)", NFM_CATALOGNAME );
  status = MEMwrite_format (info, "n_catalogname", id);
  if (status != MEM_S_SUCCESS)
    {
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      _NFMRdebug ((fname, "MEMwrite_format : status = <0x%.8x>\n",
		   status)) ;
      MEMclose (&info);
      return (NFM_E_MEM);
    }
  
  sprintf( id, "char(%d)", NFM_ITEMNAME );
  status = MEMwrite_format (info, "n_itemname", id);
  if (status != MEM_S_SUCCESS)
    {
      _NFMRdebug ((fname, "MEMwrite_format : status = <0x%.8x>\n",
		  status)) ;
      MEMclose (&info);
      return (NFM_E_MEM);
    }
  
  sprintf( id, "char(%d)", NFM_ITEMREV );
  status = MEMwrite_format (info, "n_itemrev", id);
  if (status != MEM_S_SUCCESS)
    {
      _NFMRdebug ((fname, "MEMwrite_format : status = <0x%.8x>\n", status)) ;
      MEMclose (&info);
      return (NFM_E_MEM);
    }

  strcpy (str, catalog_name);
  strcat (str, "\1");
  strcat (str, itemname) ;
  strcat (str, "\1");
  strcat (str, itemrev) ;
  strcat (str, "\1");
  status = MEMwrite (info, str);
  if (status != MEM_S_SUCCESS)
    {
      MEMclose (&info);
      ERRload_struct (NFM, NFM_E_MEM, "", "") ;
      _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
      return (NFM_E_MEM);
    }
  
  status = NFMcl_send_buffer( &NFMRglobal.NETid, NFM_GET_ITEM_ATTR_FOR_COPY,
		 info);
  _NFMRdebug(( fname, "Send Buffer : <0x%.8x>\n", status));
  if (status != NFM_S_SUCCESS)
    {
      MEMclose (&info);
      return (status);
    }
  
  MEMclose (&info);

  status = NFMRreceive_six_buffers(&NFMRglobal.NETid, &ret_status, 
		attr_list, data_list, value_list, attr_f_list, data_f_list,
		value_f_list);
  _NFMRdebug(( fname, "NFMRreceive_six_buffers : <0x%.8x>\n", status));
  if (status != NFM_S_SUCCESS)
  {
      _NFMRdebug(( fname, "NFMRreceive_six_buffer : <0x%.8x>\n", status));
      return (status);
  }
  
  _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));
  
  if (ret_status != NFM_S_SUCCESS)
    return (ret_status); 
    
  if (_NFMdebug_st.NFMRdebug_on)
    {
      MEMprint_buffers ("ITEM ATTR LIST", *attr_list,	
			_NFMdebug_st.NFMRdebug_file);
      MEMprint_buffers ("ITEM DATA LIST", *data_list, 
			_NFMdebug_st.NFMRdebug_file);
      MEMprint_buffers ("ITEM VALUE LIST", *value_list, 
			_NFMdebug_st.NFMRdebug_file);
      MEMprint_buffers ("ITEM F ATTR LIST", *attr_f_list,	
			_NFMdebug_st.NFMRdebug_file);
      MEMprint_buffers ("ITEM F DATA LIST", *data_f_list, 
			_NFMdebug_st.NFMRdebug_file);
      MEMprint_buffers ("ITEM F VALUE LIST", *value_f_list, 
			_NFMdebug_st.NFMRdebug_file);
    }
 
  return (NFM_S_SUCCESS); 
}

