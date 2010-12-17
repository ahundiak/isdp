#include "machine.h"
#include "NFMRextern.h"

#define    BUFFER_SIZE    1000

/* 
 Doc: NFMRlogin
 
 Abstract:
     This function will log a user into the NFM database.  The input buffers
     are from NFMRquery_login_attributes.
     
 */
 
long NFMRlogin (login_attr, login_data, login_wf, user_id )
MEMptr login_attr;    /* i - attributes for login */
MEMptr login_data;    /* i - data for login */
MEMptr login_wf;      /* i - workflow list for login */
long   *user_id;      /* o - user id */
{
MEMptr info = NULL;
MEMptr tmp_attr = NULL;
long   status = 0;
long   ret_status = 0;
char   **data_ptr;

static char *fname = "NFMRlogin";

/*  Copy login_attr buffer to a local buffer and append data to the 
 *  local buffer. If there are successive tries to login ( 3 ) and
 *  data keeps getting appended to the login_attr buffer, the server
 *  side will not look at any buffers other than the first two.
 */
    status = MEMsplit_copy_buffer( login_attr, &tmp_attr, 0 );
    if (status != MEM_S_SUCCESS)
        {
        _NFMRdebug(( fname, "MEMsplit_copy_buffer : <0x%.8x>\n", status));
        return (status);
        }
  
    status = MEMappend (login_data, tmp_attr);
    if (status != MEM_S_SUCCESS)
        {
        _NFMRdebug(( fname, "MEMappend : <0x%.8x>\n", status));
        return (status);
        }
  
    status = MEMappend (login_wf, tmp_attr);
    if (status != MEM_S_SUCCESS)
        {
        _NFMRdebug(( fname, "MEMappend : <0x%.8x>\n", status));
        return (status);
        }

    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_LOGIN, tmp_attr);
    if (status != NFM_S_SUCCESS)
        {
        _NFMRdebug(( fname, "NFMcl_send_buffer : <0x%.8x>\n", status));
        return (status);
        }

    MEMclose( &tmp_attr );

    status = NFMRreceive_one_buffer (&NFMRglobal.NETid, &ret_status, &info);
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "NFMRreceive_one_buffer : <0x%.8x>\n", status));
        return (status);
        }

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if (ret_status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (ret_status); 
        }

    status = MEMbuild_array (info);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMbuild : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    data_ptr = (char**)info->data_ptr;

    *user_id = atol( data_ptr[0] );

    MEMclose( &info );

    if( *user_id < 0 )
	return( ret_status );

    status = NFMRget_host_info (*user_id, 1) ;
    if (status != NFM_S_SUCCESS)
        _NFMRdebug(( fname, "NFMget_host_info : <0x%.8x>\n", status) );

    return (NFM_S_SUCCESS); 
}


/* 
 Doc: NFMRquery_login_attributes
 
 Abstract:
     This function will query for the parameters needed to login.  Output 
     buffers are for NFMRlogin.

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
static char *fname = "NFMRquery_login";

    _NFMRdebug(( fname, "env_type : <%s>\n", env_type));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMopen : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = MEMwrite_format (info, "app_env", "char(5)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    strcpy (str, app_id);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    strcpy (str, env_type);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_QUERY_LOGIN, info);
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "NFMcl_send_buffer : <0x%.8x>\n", status));
        return (status);
        }

    MEMclose (&info);

    status = NFMRreceive_four_buffers (&NFMRglobal.NETid, &ret_status, 
		attr_list, data_list, wf_list, value_list);
    if (status != NFM_S_SUCCESS)
        {
        _NFMRdebug(( fname, "NFMRreceive_four_buffer : <0x%.8x>\n", status));
        return (status);
        }

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if (ret_status != NFM_S_SUCCESS)
        return (ret_status); 

    return (NFM_S_SUCCESS); 
}

