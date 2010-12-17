#include "machine.h"
#include "NFMRinclude.h"

#define    BUFFER_SIZE    1000

/* 
 Doc: NFMRvalidate_user_access
 
 Abstract:
     This function will see if the specified user can perform 
     a specified command and will validate whether or not this command
     can be performed on the given entity.  This function must be called prior
     to EVERY I/NFM command and every command must be followed by a call to 
     NFMRset_to_state.
     
 Returns:
       0 - Success
      <0 - Failure
         
 History:
     kht    9-20-1989    Creation
     
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
MEMptr ret_info = NULL;
char   str[1028];
long   status = 0;
long   ret_status = 0;
char   id[20];

    _NFMR_num ("NFMRvalidate_user_access : user_id      : <%ld>", user_id);
    _NFMR_str ("NFMRvalidate_user_access : command      : <%s>", command);
    _NFMR_str ("NFMRvalidate_user_access : workflow     : <%s>", workflow);
    _NFMR_str ("NFMRvalidate_user_access : project      : <%s>", project);
    _NFMR_str ("NFMRvalidate_user_access : catalog      : <%s>", catalog_name);
    _NFMR_str ("NFMRvalidate_user_access : item_name    : <%s>", item_name);
    _NFMR_str ("NFMRvalidate_user_access : item_rev     : <%s>", item_rev);

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMR_num ("NFMRvalidate_user_access : MEMopen : <0x%.8x>", status);
        return (status);
        }
    
    status = MEMwrite_format (info, "user_id", "char(20)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMR_num ("NFMRvalidate_user_access : MEMwrite_format : <0x%.8x>", status);
        return (status);
        }
    
    status = MEMwrite_format (info, "n_commandname", "char(100)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMR_num ("NFMRvalidate_user_access : MEMwrite_format : <0x%.8x>", status);
        return (status);
        }
    
    status = MEMwrite_format (info, "n_workflow", "char(20)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMR_num ("NFMRvalidate_user_access : MEMwrite_format : <0x%.8x>", status);
        return (status);
        }
    
    status = MEMwrite_format (info, "n_project", "char(20)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMR_num ("NFMRvalidate_user_access : MEMwrite_format : <0x%.8x>", status);
        return (status);
        }
    
    status = MEMwrite_format (info, "n_catalogname", "char(20)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMR_num ("NFMRvalidate_user_access : MEMwrite_format : <0x%.8x>", status);
        return (status);
        }
    
    status = MEMwrite_format (info, "n_itemname", "char(60)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMR_num ("NFMRvalidate_user_access : MEMwrite_format : <0x%.8x>", status);
        return (status);
        }
    
    status = MEMwrite_format (info, "n_itemrev", "char(40)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMR_num ("NFMRvalidate_user_access : MEMwrite_format : <0x%.8x>", status);
        return (status);
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
        _NFMR_num ("NFMRvalidate_user_access : MEMwrite : <0x%.8x>", status);
        return (status);
        }
    
    _NFMR_num ("call NFMcl_send_buffer <%d>", NETid);

    status = NFMcl_send_buffer (&NETid, WF_VALIDATE_USER, info);
    _NFMR_num ("NFMRvalidate_user_access : Send Buffer : = <0x%.8x>", status);
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        NETclose_c (&NETid);
        _NFMR_num ("NFMRvalidate_user_access : NFMcl_send_buffer : <0x%.8x>", status);
        return (status);
        }

    MEMclose (&info);

    status = NFMRreceive_buffer (&NETid, &ret_status, &info);
    _NFMR_num ("NFMRvalidate_user_access : NET rec Buffer : <0x%.8x>", status);
    if (status != NFM_S_SUCCESS)
        {
        MEMclose (&info);
        NETclose_c (&NETid);
        _NFMR_num ("NFMRvalidate_user_access : NFMRreceive_buffer : <0x%.8x>", status);
        return (status);
        }

    _NFMR_num ("NFMRvalidate_user_access : Return Status : <0x%.8x>", ret_status);

    MEMclose (&info);

    if( ret_status != NFM_S_SUCCESS )
        return( ret_status );

    return( NFM_S_SUCCESS );

}


