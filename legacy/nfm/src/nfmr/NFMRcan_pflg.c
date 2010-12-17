#include "machine.h"
#include "NFMRextern.h"

#define    BUFFER_SIZE    1000

long NFMRcancel_project_archive_flag (project)

char    *project;

{
MEMptr info = NULL;
long   status = 0;
long   ret_status = 0;
char   str[50];
static char *fname = "NFMRcancel_project_archive_flag";

    _NFMRdebug(( fname, "project : <%s>\n", project));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    sprintf( str, "char(%d)", NFM_PROJECTNAME );
    status = MEMwrite_format (info, "n_projectname", str );
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    sprintf (str, "%s\1", project);
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = NFMcl_send_buffer (&NFMRglobal.NETid, 
			NFM_CANCEL_PROJECT_ARCHIVE, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }

    MEMclose (&info);

    status = NFMRreceive_error_buffers (&NFMRglobal.NETid, &ret_status);
    _NFMRdebug(( fname, "NFMRreceive_error_buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if( ret_status != NFM_S_SUCCESS )
        return( ret_status );

    return( NFM_S_SUCCESS );

}

long NFMRcancel_project_backup_flag (project)

char    *project;

{
MEMptr info = NULL;
long   status = 0;
long   ret_status = 0;
char   str[50];
static char *fname = "NFMRcancel_project_backup_flag";

    _NFMRdebug(( fname, "project : <%s>\n", project));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    sprintf( str, "char(%d)", NFM_PROJECTNAME );
    status = MEMwrite_format (info, "n_projectname", str );
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    sprintf (str, "%s\1", project);
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = NFMcl_send_buffer (&NFMRglobal.NETid, 
			NFM_CANCEL_PROJECT_BACKUP, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }

    MEMclose (&info);

    status = NFMRreceive_error_buffers (&NFMRglobal.NETid, &ret_status);
    _NFMRdebug(( fname, "NFMRreceive_error_buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if( ret_status != NFM_S_SUCCESS )
        return( ret_status );

    return( NFM_S_SUCCESS );

}

long NFMRcancel_project_restore_flag (project)

char    *project;

{
MEMptr info = NULL;
long   status = 0;
long   ret_status = 0;
char   str[50];
static char *fname = "NFMRcancel_project_restore_flag";

    _NFMRdebug(( fname, "project : <%s>\n", project));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    sprintf( str, "char(%d)", NFM_PROJECTNAME );
    status = MEMwrite_format (info, "n_projectname", str );
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite_format : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    sprintf (str, "%s\1", project);
    status = MEMwrite (info, str);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMRdebug(( fname, "MEMwrite : <0x%.8x>\n", status));
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return( NFM_E_MEM );
        }
    
    status = NFMcl_send_buffer (&NFMRglobal.NETid, 
		NFM_CANCEL_PROJECT_RESTORE, info);
    _NFMRdebug(( fname, "Send Buffer : = <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }

    MEMclose (&info);

    status = NFMRreceive_error_buffers (&NFMRglobal.NETid, &ret_status);
    _NFMRdebug(( fname, "NFMRreceive_error_buffer : <0x%.8x>\n", status));
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status : <0x%.8x>\n", ret_status));

    if( ret_status != NFM_S_SUCCESS )
        return( ret_status );

    return( NFM_S_SUCCESS );

}
