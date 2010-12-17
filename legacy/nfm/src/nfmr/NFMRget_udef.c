#include "machine.h"
#include "NFMRextern.h"

#define    BUFFER_SIZE    1000

/* 
 Doc: NFMRget_user_defaults
 
 Abstract:
     This function will return the user defaults for user-id in
     the nfmusers table.
     
 */
 

long NFMRget_user_defaults (user_id, data_list )
long    user_id;       /* i - user id for access */
MEMptr  *data_list;    /* o - the returned data list */

{
    MEMptr info = NULL;
    char   str[80];
    long   status = 0;
    long   ret_status = 0;

    static char *fname = "NFMRget_user_defaults";

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
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    sprintf (str, "%ld", user_id);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = NFMcl_send_buffer (&NFMRglobal.NETid, NFM_GET_USER_DEFAULTS, info);
    _NFMRdebug(( fname,"Send Buffer = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }

    MEMclose (&info);

    status = NFMRreceive_one_buffer (&NFMRglobal.NETid, &ret_status,data_list);
    _NFMRdebug(( fname, "NFMRreceive_one_buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if (ret_status != NFM_S_SUCCESS)
        return (ret_status); 

    if (_NFMdebug_st.NFMRdebug_on )
        MEMprint_buffers ("USER DATA", *data_list, 
			   _NFMdebug_st.NFMRdebug_file);

    return( NFM_S_SUCCESS );

}

/* 
 Doc: NFMRread_user_defaults
 
 Abstract:
     This function will return the user defaults written into
     the <env>/systems directory.
     
 */
 

long NFMRread_user_defaults ( data_list )

MEMptr  *data_list;    /* o - the returned data list */

{
    long   status = 0;
    long   ret_status = 0;
    MEMptr info = NULL;

    static char *fname = "NFMRread_user_defaults";

    status = NFMcl_send_buffer(&NFMRglobal.NETid,NFM_READ_USER_DEFAULTS, info);
    _NFMRdebug(( fname,"Send Buffer = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        return (status);

    status = NFMRreceive_one_buffer (&NFMRglobal.NETid, &ret_status,data_list);
    _NFMRdebug(( fname, "NFMRreceive_one_buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if (ret_status != NFM_S_SUCCESS)
        return (ret_status); 

    if (_NFMdebug_st.NFMRdebug_on )
        MEMprint_buffers ("USER DATA", *data_list, 
			   _NFMdebug_st.NFMRdebug_file);

    return( NFM_S_SUCCESS );

}
