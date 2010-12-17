#include "machine.h"
#include "NFMRextern.h"

#define    BUFFER_SIZE    1000

/* 
 Doc: NFMRquery_acl_attributes_condition
 
 Abstract:
     This function will return the attributes needed to add an ACL
     operations such as Copy ACL

 */
 
long NFMRquery_acl_attributes_condition (condition, 
					 attr_list, data_list, value_list)

char    *condition;    /* i - string part of where clause */
MEMptr  *attr_list;    /* o - the returned attribute list */
MEMptr  *data_list;    /* o - the returned acl data list */
MEMptr  *value_list;   /* o - the returned acl value list */

{
MEMptr info = NULL;
char   str[100];
long   status = 0;
long   ret_status = 0;
char   datatype [25] ;

static char *fname = "NFMRquery_acl_attributes_condition";

    _NFMRdebug(( fname, "condition <%s>\n", condition)) ;

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
	ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
	return( NFM_E_MEM );
        }
    
    sprintf (datatype, "char(%d)", strlen (condition)) ;
    status = MEMwrite_format (info, "condition", datatype) ;
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    strcpy (str, condition) ;
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = NFMcl_send_buffer (&NFMRglobal.NETid, WF_QUERY_ACL_ATTR_COND, 
				info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    MEMclose (&info);

    status = NFMRreceive_three_buffers (&NFMRglobal.NETid, &ret_status, 
			attr_list, data_list, value_list);
    _NFMRdebug(( fname, "NFMRreceive three Buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if (ret_status != NFM_S_SUCCESS)
        return (ret_status); 

    if (_NFMdebug_st.NFMRdebug_on)
        {
        MEMprint_buffers ("ACL ATTR LIST", *attr_list, 
			   _NFMdebug_st.NFMRdebug_file);
        MEMprint_buffers ("ACL DATA LIST", *data_list, 
			   _NFMdebug_st.NFMRdebug_file);
        MEMprint_buffers ("ACL VALUE LIST", *value_list, 
			   _NFMdebug_st.NFMRdebug_file);
        }

    if( ret_status != NFM_S_SUCCESS )
        return( ret_status );

    return( NFM_S_SUCCESS );
}


/* 
 Doc: NFMRget_acl_classes_for_copy
 
 Abstract:
     This function will add an Access Control List given the updated
     buffers returned from NFMRquery_acl_attributes.
     
 */
 
long NFMRget_acl_classes_for_copy (old_aclname, new_wfno,
				   attr_list, value_list)

     char    *old_aclname;   /* i - old aclname */
     long    new_wfno;      /* i - new wfno  */
     MEMptr  *attr_list;     /* o - the attribute list */
     MEMptr  *value_list;    /* o - the acl data list  */

{
  MEMptr info = NULL;
  char   str[100];
  long   status = 0;
  long   ret_status = 0;
  char   datatype[25] ;
  char   tmp_str [100] ;
  static char *fname = "NFMRget_acl_classes_for_copy" ;
  
  _NFMRdebug(( fname, "old aclname <%s> : new wfno <%d>\n",
	      old_aclname, new_wfno)) ;
  
  status = MEMopen (&info, BUFFER_SIZE);
  if (status != MEM_S_SUCCESS)
    {
      MEMclose (&info);
      _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
      ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
      return( NFM_E_MEM );
    }
  
  sprintf (datatype, "char(%d)", NFM_ACLNAME) ;
  status = MEMwrite_format (info, "old_aclname", datatype) ;
  if (status != MEM_S_SUCCESS)
    {
      MEMclose (&info);
      _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
      ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
      return( NFM_E_MEM );
    }
  
  status = MEMwrite_format (info, "old_wfno", "integer") ;
  if (status != MEM_S_SUCCESS)
    {
      MEMclose (&info);
      _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
      ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
      return( NFM_E_MEM );
    }
  
  strcpy (str, old_aclname);
  strcat (str, "\1");
  sprintf (tmp_str, "%d", new_wfno) ;
  strcat (str, tmp_str) ;
  strcat (str, "\1");
  status = MEMwrite (info, str);
  if (status != MEM_S_SUCCESS)
    {
      MEMclose (&info);
      _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
      ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
      return( NFM_E_MEM );
    }
  
  status = NFMcl_send_buffer (&NFMRglobal.NETid, WF_GET_COPY_ACL, info);
  _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
  if (status != NFM_S_SUCCESS)
    {
      MEMclose (&info);
      return (status);
    }
  
  MEMclose (&info);

  status = NFMRreceive_two_buffers (&NFMRglobal.NETid, &ret_status, 
				      attr_list, value_list) ;
  _NFMRdebug(( fname, "NFMRreceive two Buffers : <0x%.8x>\n", status));
  if (status != NFM_S_SUCCESS)
    return (status);
  
  _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));
  
  if (ret_status != NFM_S_SUCCESS)
    return (ret_status); 
  
  if (_NFMdebug_st.NFMRdebug_on)
    {
      MEMprint_buffers ("ACL ATTR LIST", *attr_list, 
			_NFMdebug_st.NFMRdebug_file);
      MEMprint_buffers ("ACL VALUE LIST", *value_list, 
			_NFMdebug_st.NFMRdebug_file);
    }
  
  if( ret_status != NFM_S_SUCCESS )
    return( ret_status );

  _NFMRdebug ((fname, "SUCCESSFUL\n")) ;
  return( NFM_S_SUCCESS );
}



/* 
 Doc: NFMRcopy_acl
 
 Abstract:
     This function will copy an Access Control List
 */
 
long NFMRcopy_acl_users (new_aclname, new_wfno, old_aclname, data_list)
     char    *new_aclname ; /* i - new aclname */
     long    new_wfno;      /* i - new workflow no */
     char    *old_aclname;  /* i - old acl name */
     MEMptr  data_list;     /* i - the acl data list  */

{
  MEMptr info = NULL;
  char   str[100];
  long   status = 0;
  long   ret_status = 0;
  char   tmp_str[512] ;
  static char *fname = "NFMRcopy_acl_users";
  
  _NFMRdebug(( fname, "new_aclname <%s> : new_wfno <%d> : old_aclname <%s>\n",
	      new_aclname, new_wfno, old_aclname)) ;
  
  status = MEMopen (&info, BUFFER_SIZE);
  if (status != MEM_S_SUCCESS)
    {
      MEMclose (&info);
      _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
      ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
      return( NFM_E_MEM );
    }
  
  sprintf (tmp_str, "char(%d)", NFM_ACLNAME) ;
  status = MEMwrite_format (info, "new_aclname", tmp_str) ;
  if (status != MEM_S_SUCCESS)
    {
      MEMclose (&info);
      _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
      ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
      return( NFM_E_MEM );
    }
  
  status = MEMwrite_format (info, "new_workflowno", "integer") ;
  if (status != MEM_S_SUCCESS)
    {
      MEMclose (&info);
      _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
      ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
    }
  
  sprintf (tmp_str, "char(%d)", NFM_ACLNAME) ;
  status = MEMwrite_format (info, "old_aclname", tmp_str);
  if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
      }
  
  strcpy (str, new_aclname) ;
  strcat (str, "\1");
  sprintf (tmp_str, "%ld", new_wfno) ;
  strcat (str, tmp_str) ;
  strcat (str, "\1");
  strcat (str, old_aclname) ;
  strcat (str, "\1");
  status = MEMwrite (info, str);
  if (status != MEM_S_SUCCESS)
    {
      MEMclose (&info);
      _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
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
  
  status = NFMcl_send_buffer (&NFMRglobal.NETid, WF_COPY_ACL, info);
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




