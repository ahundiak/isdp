#include "machine.h"
#include "NFMRextern.h"

#define    BUFFER_SIZE    1000

/* 
 Doc: NFMRload_workflow
 
 Abstract:
     This function will load a predefined workflow file into NFM.  This 
     file must reside on the NFMserver node.
     
 */
 
long NFMRload_workflow (user_id, appl_name, wf_file_name)

long    user_id;       /* i - user id for access */
char    *appl_name;    /* i - application */
char    *wf_file_name; /* i - a workflow data file on the NFMserver node */

{
MEMptr info = NULL;
char   str[100];
long   status = 0;
long   ret_status = 0;
char   id[20];
static char *fname = "NFMRload_workflow";

    _NFMRdebug(( fname, "user_id       : <%ld>\n", user_id));
    _NFMRdebug(( fname, "Application   : <%s>\n", appl_name));
    _NFMRdebug(( fname, "Workflow file : <%s>\n", wf_file_name));

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
    
    sprintf( id, "char(%d)", NFM_APPLICATION );
    status = MEMwrite_format (info, "n_application", id);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    sprintf( id, "char(%d)", NFM_FILENAME );
    status = MEMwrite_format (info, "n_filename", id);
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
    strcat (str, appl_name);
    strcat (str, "\1");
    strcat (str, wf_file_name);
    strcat (str, "\1");
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }

    status = NFMcl_send_buffer (&NFMRglobal.NETid, WF_LOAD_WORKFLOW, info);
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



