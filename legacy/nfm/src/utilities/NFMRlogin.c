#include "machine.h"
#include "NFMRinclude.h"

#define    BUFFER_SIZE    1000

/* 
 Doc: NFMRlogin
 
 Abstract:
     This function will log a user into the NFM database.  The input buffers
     are from NFMRquery_login_attributes.
     
 Returns:
       0 - Success
      <0 - Invalid user name/password combination
         
 History:
     kht    03-29-1989    Creation
     
 */
 
long NFMRlogin (login_attr, login_data, login_wf, user_id )
MEMptr login_attr;    /* i - attributes for login */
MEMptr login_data;    /* i - data for login */
MEMptr login_wf;      /* i - workflow list for login */
long   *user_id;      /* o - user id */
{
MEMptr info = NULL;
MEMptr new_info = NULL;
MEMptr tmp_attr = NULL;
long   status = 0;
long   ret_status = 0;
long   id;
char   **data_ptr;

    _NFMR_str ("%s", "Enter NFMRlogin");

/*  Copy login_attr buffer to a local buffer and append data to the 
 *  local buffer. If there are successive tries to login ( 3 ) and
 *  data keeps getting appended to the login_attr buffer, the server
 *  side will not look at any buffers other than the first two.
 */
    status = MEMsplit_copy_buffer( login_attr, &tmp_attr, 0 );
    if (status != MEM_S_SUCCESS)
        {
        _NET_num ("NFMRlogin : MEMsplit_copy_buffer : <0x%.8x>", status);
        return (status);
        }
  
    status = MEMappend (login_data, tmp_attr);
    if (status != MEM_S_SUCCESS)
        {
        _NET_num ("NFMRlogin : MEMappend : <0x%.8x>", status);
        return (status);
        }
  
    status = MEMappend (login_wf, tmp_attr);
    if (status != MEM_S_SUCCESS)
        {
        _NET_num ("NFMRlogin : MEMappend : <0x%.8x>", status);
        return (status);
        }

    _NET_num ("NFMRlogin : call NFMcl_send_buffer : %d", NFM_LOGIN);

    status = NFMcl_send_buffer (&NETid, NFM_LOGIN, tmp_attr);
    if (status != NFM_S_SUCCESS)
        {
        NETclose_c (&NETid);
        _NET_num ("NFMRlogin : NFMcl_send_buffer : <0x%.8x>", status);
        return (status);
        }

    status = NFMRreceive_buffer (&NETid, &ret_status, &info);
    MEMclose( &tmp_attr );
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        NETclose_c (&NETid);
        _NET_num ("NFMRlogin : NFMRreceive_buffer : <0x%.8x>", status);
        return (status);
        }

    _NET_num ("NFMRlogin : Return Status : <0x%.8x>", ret_status);

    if (ret_status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (ret_status); 
        }
    
    status = MEMreset_buffer_no (info, 1);
    if (status == MEM_S_SUCCESS)
        {
        _NET_num ("After reset buffer <0x%.8x>", status);
        status = MEMsplit_copy_buffer (info, &new_info, 1);
        _NET_num ("After split copy buffer <0x%.8x>", status);
        if (status != MEM_S_SUCCESS)
            {
            MEMclose (&info);
            _NET_num ("NFMRquery_login : MEMsplit_copy_buffer : <0x%.8x>", status);
            return (status);
            }
        }

    status = MEMbuild_array (info);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NET_num ("NFMRquery_login : MEMbuild_array : <0x%.8x>", status);
        return (status);
        }

    data_ptr = (char**)new_info->data_ptr;

    _NET_num ("NFMRlogin : User ID : <%ld>", atol(data_ptr[0]));

    id = atol( data_ptr[0] );
    *user_id = id;

    MEMclose( &info );
    MEMclose( &new_info );

    if( *user_id < 0 )
	return( status );

    return (NFM_S_SUCCESS); 
}


/* 
 Doc: NFMRquery_login_attributes
 
 Abstract:
     This function will query for the parameters needed to login.  Output 
     buffers are for NFMRlogin.
     
 Returns:
       0 - Success
      <0 - Failure
         
 History:
     kht    9-18-1989    Creation
     
 */
 
long NFMRquery_login_attributes (app_id, env_type, attr_list, data_list,
				 value_list, wf_list)
char    *app_id;     /* i - application id */
char    *env_type;   /* i - environment type ("nfme_") */
MEMptr  *attr_list;  /* o - buffer for attributes */
MEMptr  *data_list;  /* o - buffer for data */
MEMptr  *value_list; /* o - buffer for values */
MEMptr  *wf_list;    /* o - buffer for workflows */
{
MEMptr info = NULL;
char   str[256];
long   status = 0;
long   ret_status = 0;

    _NET_str ("NFMRquery_login : env_type : <%s>", env_type);

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NET_num ("NFMRquery_login : MEMopen : <0x%.8x>", status);
        return (status);
        }
    
    status = MEMwrite_format (info, "app_env", "char(5)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NET_num ("NFMRquery_login : MEMwrite_format : <0x%.8x>", status);
        return (status);
        }

    strcpy (str, app_id);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NET_num ("NFMRquery_login : MEMwrite : <0x%.8x>", status);
        return (status);
        }

    strcpy (str, env_type);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NET_num ("NFMRquery_login : MEMwrite : <0x%.8x>", status);
        return (status);
        }

    _NET_num ("call NFMcl_send_buffer -> %d", NETid);

    MEMprint_buffers("Before cl_send_buffer", info, "pro_dd_nfm:nfmr.dbg");
    status = NFMcl_send_buffer (&NETid, NFM_QUERY_LOGIN, info);
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        NETclose_c (&NETid);
        _NET_num ("NFMRquery_login : NFMcl_send_buffer : <0x%.8x>", status);
        return (status);
        }

    MEMclose (&info);

    status = NFMRreceive_buffer (&NETid, &ret_status, &info);
    MEMprint_buffers("After receive", info, "pro_dd_nfm:nfmr.dbg");

    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        NETclose_c (&NETid);
        _NET_num ("NFMRquery_login : NFMRreceive_buffer : <0x%.8x>", status);
        return (status);
        }

    _NET_num ("NFMRquery_login : Return Status : <0x%.8x>", ret_status);

    if (ret_status != NFM_S_SUCCESS)
        {
        _NET_num ("NFMRquery_login : UNSUCCESSFUL : <0x%.8x>", ret_status);
        MEMclose (&info);
        return (ret_status); 
        }

    status = MEMbuild_array (info);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NET_num ("NFMRquery_login : MEMbuild_array : <0x%.8x>", status);
        return (status);
        }

    status = MEMreset_buffer_no (info, 1);
    if (status == MEM_S_SUCCESS)
        {
        status = MEMsplit_copy_buffer (info, attr_list, 0);
	if (status != MEM_S_SUCCESS)
	   {
            MEMclose (&info);
            _NET_num ("NFMRquery_login : MEMsplit_copy_buffer : <0x%.8x>", status);
            return (status);
 	   }
        }
    status = MEMreset_buffer_no (info, 2);
    if (status == MEM_S_SUCCESS)
        {
        status = MEMsplit_copy_buffer (info, data_list, 0);
        if (status != MEM_S_SUCCESS)
            {
            MEMclose (&info);
            _NET_num ("NFMRquery_login : MEMsplit_copy_buffer : <0x%.8x>", status);
            return (status);
            }
        }

    status = MEMreset_buffer_no (info, 3);
    if (status == MEM_S_SUCCESS)
        {
        status = MEMsplit_copy_buffer (info, wf_list, 0);
        if (status != MEM_S_SUCCESS)
            {
            MEMclose (&info);
            _NET_num ("NFMRquery_login : MEMsplit_copy_buffer : <0x%.8x>", status);
            return (status);
            }
        }

    status = MEMreset_buffer_no (info, 4);
    if (status == MEM_S_SUCCESS)
        {
        status = MEMsplit_copy_buffer (info, value_list, 1);
        if (status != MEM_S_SUCCESS)
            {
            MEMclose (&info);
            _NET_num ("NFMRquery_login : MEMsplit_copy_buffer : <0x%.8x>", status);
            return (status);
            }
        }

    MEMclose (&info);

    return (NFM_S_SUCCESS); 
}

