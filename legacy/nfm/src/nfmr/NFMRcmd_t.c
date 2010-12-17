#include "machine.h"
#include "NFMRextern.h"

#define    BUFFER_SIZE    1000

/* 
 Doc: NFMRget_command_no
 
 Abstract:
     This function will return a command number given a command name.
 */
 
long NFMRget_command_no (user_id, command_name, command_num)

long    user_id;       /* i - user id for access */
char    *command_name; /* i - the name of the command */
char    *command_num;  /* o - the number of the command */

{
MEMptr info = NULL;
char   str[200];
long   status = 0;
long   ret_status = 0;
char   id[20];
char   **data_ptr;
static char *fname = "NFMRget_command_no";

    _NFMRdebug(( fname, "user_id    : <%ld>\n", user_id));
    _NFMRdebug(( fname, "command name : <%s>\n", command_name));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        _NFMRdebug(( fname, "MEMopen <0x%.8x>\n", status ));
        return (NFM_E_MEM);
        }
    
    status = MEMwrite_format (info, "user_id", "char(20)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        return (NFM_E_MEM);
        }
    
    status = MEMwrite_format (info, "n_commandname", "char(20)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        return (NFM_E_MEM);
        }
    
    sprintf (id, "%ld", user_id);

    strcpy (str, id);
    strcat (str, "\1");
    strcat (str, command_name);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        _NFMRdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return (NFM_E_MEM);
        }
    
    status = NFMcl_send_buffer (&NFMRglobal.NETid, WF_GET_COMMAND_NO, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }

    MEMclose (&info);

    status = NFMRreceive_one_buffer (&NFMRglobal.NETid, &ret_status, &info);
    _NFMRdebug(( fname, "NFMRreceive_one_buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
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
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        _NFMRdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
        return (NFM_E_MEM);
        }

    data_ptr = (char **) info->data_ptr;

    strcpy (command_num, data_ptr[0]);

    _NFMRdebug(( fname, "command_num : <%s>\n", command_num));

    MEMclose (&info);

    if( ret_status != NFM_S_SUCCESS )
        return( ret_status );

    return( NFM_S_SUCCESS );

}


/* 
 Doc: NFMRget_command_name
 
 Abstract:
     This function will return a command name given a command number.
 */
 
long NFMRget_command_name (user_id, command_num, command_name)

long    user_id;       /* i - user id for access */
char    *command_num;  /* i - the number of the command */
char    *command_name; /* o - the name of the command */

{
MEMptr info = NULL;
char   str[200];
long   status = 0;
long   ret_status = 0;
char   id[20];
char   **data_ptr;
static char *fname = "NFMRget_command_name";

    _NFMRdebug(( fname, "user_id   : <%ld>\n", user_id));
    _NFMRdebug(( fname, "command num : <%s>\n", command_num));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        _NFMRdebug(( fname, "MEMopen <0x%.8x>\n", status ));
        return (NFM_E_MEM);
        }
    
    status = MEMwrite_format (info, "user_id", "char(20)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        return (NFM_E_MEM);
        }
    
    status = MEMwrite_format (info, "n_commandnum", "char(20)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        _NFMRdebug(( fname, "MEMwrite_format <0x%.8x>\n", status ));
        return (NFM_E_MEM);
        }
    
    sprintf (id, "%ld", user_id);

    strcpy (str, id);
    strcat (str, "\1");
    strcat (str, command_num);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        _NFMRdebug(( fname, "MEMwrite <0x%.8x>\n", status ));
        return (NFM_E_MEM);
        }
   
    status = NFMcl_send_buffer (&NFMRglobal.NETid, WF_GET_COMMAND_NAME, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }

    MEMclose (&info);

    status = NFMRreceive_one_buffer (&NFMRglobal.NETid, &ret_status, &info);
    _NFMRdebug(( fname, "NFMRreceive_one_buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
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
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        _NFMRdebug(( fname, "MEMbuild <0x%.8x>\n", status ));
        return (NFM_E_MEM);
        }

    data_ptr = (char **) info->data_ptr;

    strcpy (command_name, data_ptr[0]);

    _NFMRdebug(( fname, "command_name : <%s>\n", command_name));

    MEMclose (&info);

    if( ret_status != NFM_S_SUCCESS )
        return( ret_status );

    return( NFM_S_SUCCESS );

}



