#include "machine.h"
#include "NFMRextern.h"

#define    BUFFER_SIZE    1000

/* 
 Doc: NFMRvalidate_user_access
 
 Abstract:
     This function will see if the specified user can perform 
     a specified command and will validate whether or not this command
     can be performed on the given entity.  This function must be called prior
     to EVERY I/NFM command and every command must be followed by a call to 
     NFMRset_to_state.

 */
 
long NFMRvalidate_user_access (user_id, command, workflow, project,
                               catalog_name, item_name, item_rev)

long    user_id;       /* i - user id for access */
char    *command;      /* i - the command to be performed */
char    *workflow;     /* i - workflow name */
char    *project;      /* i - the active project */
char    *catalog_name; /* i - the active catalog */
char    *item_name;    /* i - the active item */
char    *item_rev;     /* i - the active item's revision */

{
MEMptr info = NULL;
char   str[1028];
long   status = 0;
long   ret_status = 0;
char   id[20];

static char *fname = "NFMRvalidate_user_access";

    _NFMRdebug(( fname, "user_id      : <%ld>\n", user_id));
    _NFMRdebug(( fname, "command      : <%s>\n", command));
    _NFMRdebug(( fname, "workflow     : <%s>\n", workflow));
    _NFMRdebug(( fname, "project      : <%s>\n", project));
    _NFMRdebug(( fname, "catalog      : <%s>\n", catalog_name));
    _NFMRdebug(( fname, "item_name    : <%s>\n", item_name));
    _NFMRdebug(( fname, "item_rev     : <%s>\n", item_rev));

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
        }
    
    status = MEMwrite_format (info, "user_id", "char(20)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
        }
    
    sprintf( id, "char(%d)", NFM_COMMANDNAME );
    status = MEMwrite_format (info, "n_commandname", id);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
        }
    
    sprintf( id, "char(%d)", NFM_WORKFLOWNAME );
    status = MEMwrite_format (info, "n_workflow", id);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
        }
    
    sprintf( id, "char(%d)", NFM_PROJECTNAME );
    status = MEMwrite_format (info, "n_project", id);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
        }
    
    sprintf( id, "char(%d)", NFM_CATALOGNAME );
    status = MEMwrite_format (info, "n_catalogname", id);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
        }
    
    sprintf( id, "char(%d)", NFM_ITEMNAME );
    status = MEMwrite_format (info, "n_itemname", id);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
        }
    
    sprintf( id, "char(%d)", NFM_ITEMREV );
    status = MEMwrite_format (info, "n_itemrev", id);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
        }
    
    sprintf (id, "%ld", user_id);

    strcpy (str, id);
    strcat (str, "\1");
    strcat (str, command);
    strcat (str, "\1");
    strcat (str, workflow);
    strcat (str, "\1");
    strcat (str, project);
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
        ERRload_struct( NFM, NFM_E_MEM, NULL, NULL );
        return (NFM_E_MEM);
        }
    
    status = NFMcl_send_buffer (&NFMRglobal.NETid, WF_VALIDATE_USER, info);
    _NFMRdebug(( fname, "NFMcl_send_buffer <0x%.8x>\n", status ));
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        return (status);
        }

    MEMclose (&info);

    status = NFMRreceive_error_buffers (&NFMRglobal.NETid, &ret_status);
    _NFMRdebug(( fname, "NFMRreceive_error_buffer <0x%.8x>\n", status ));
    if (status != NFM_S_SUCCESS)
        return (status);

    _NFMRdebug(( fname, "Return Status <0x%.8x>\n", status ));

    if( ret_status != NFM_S_SUCCESS )
        return( ret_status );

    return( NFM_S_SUCCESS );

}


