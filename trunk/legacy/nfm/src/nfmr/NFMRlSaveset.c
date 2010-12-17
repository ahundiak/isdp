#include "machine.h"
#include "NFMRextern.h"

#define  BUFFER_SIZE  1000
/* 
 Doc: NFMRlist_savesets
 
 Abstract:
     This function will return the buffer needed to list the savesets
     the 'nfmsavesets' table.
     
 Returns:
       0 - Success
      <0 - Failure
         
     
 */

long NFMRlist_savesets (user_id, data_list)

long    user_id;       /* i - user id for access */
MEMptr  *data_list;    /* o - list of data */

{
MEMptr info = NULL;
long   status = 0;
long   ret_status;
char   id[20];

    _NFMR_num ("NFMRlist_savesets : user_id     : <%ld>", user_id);

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMR_num ("NFMRlist_savesets : MEMopen : <0x%.8x>", status);
        return (status);
        }
    
    status = MEMwrite_format (info, "user_id", "char(20)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMR_num ("NFMRlist_savesets : MEMwrite_format : <0x%.8x>", status);
        return (status);
        }
    sprintf (id, "%ld", user_id);
    strcat (id, "\1");
    status = MEMwrite (info, id);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMR_num ("NFMRlist_savesets : MEMwrite : <0x%.8x>", status);
        return (status);
        }

    SCdisplay_msg( "Working.." );
    status = NFMcl_send_buffer( &NFMRglobal.NETid, NFM_LIST_SAVESETS, info );
    if( status != NFM_S_SUCCESS )
    {
        MEMclose (&info);
        _NFMR_num ("NFMRlist_savesets : NFMcl_send_buffer : <0x%.8x>", status);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_buffer (&NFMRglobal.NETid, &ret_status, &info);
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMR_num("NFMRlist_savesets : NFMRreceive_buffer : <0x%.8x>", status);
        return (status);
    }

    if (ret_status != NFM_S_SUCCESS)
    {
	MEMclose( &info );
        _NFMR_num ("NFMRlist_savesets : UNSUCCESSFUL : <0x%.8x>", ret_status);
        return (ret_status); 
    }

    status = MEMsplit_copy_buffer (info, data_list, 0);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMR_num("NFMRlist_savesets : MEMsplit_copy_buffer : <0x%.8x>",
		   status);
        return (status);
    }
    
    MEMclose (&info);
 
    return (NFM_S_SUCCESS); 
}

