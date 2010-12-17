#include "machine.h"
#include "NFMRextern.h"

#define  BUFFER_SIZE  1000
/* 
 Doc: NFMRlist_items_on_tape
 
 Abstract:
     This function will return the buffer needed to list the items
     archived to tape.
     
 Returns:
       0 - Success
      <0 - Failure
         
     
 */

long NFMRlist_items_on_tape (user_id, data_list)

long    user_id;       /* i - user id for access */
MEMptr  *data_list;    /* o - list of data */

{
MEMptr info = NULL;
long   status = 0;
long   ret_status;
char   id[20];

    _NFMR_num ("NFMRlist_items_on_tape : user_id     : <%ld>", user_id);

    status = MEMopen (&info, BUFFER_SIZE);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMR_num ("NFMRlist_items_on_tape : MEMopen : <0x%.8x>", status);
        return (status);
        }
    
    status = MEMwrite_format (info, "user_id", "char(20)");
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMR_num ("NFMRlist_items_on_tape : MEMwrite_format : <0x%.8x>", status);
        return (status);
        }
    sprintf (id, "%ld", user_id);
    strcat (id, "\1");
    status = MEMwrite (info, id);
    if (status != MEM_S_SUCCESS)
        {
        MEMclose (&info);
        _NFMR_num ("NFMRlist_items_on_tape : MEMwrite : <0x%.8x>", status);
        return (status);
        }

    SCdisplay_msg( "Working.." );
    status = NFMcl_send_buffer( &NFMRglobal.NETid, NFM_LIST_ITEMS_ON_TAPE, info );
    if( status != NFM_S_SUCCESS )
    {
        MEMclose (&info);
        _NFMR_num ("NFMRlist_items_on_tape : NFMcl_send_buffer : <0x%.8x>", status);
        return (status);
    }

    MEMclose (&info);

    status = NFMRreceive_buffer (&NFMRglobal.NETid, &ret_status, &info);
    if (status != NFM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMR_num("NFMRlist_items_on_tape : NFMRreceive_buffer : <0x%.8x>", status);
        return (status);
    }

    if (ret_status != NFM_S_SUCCESS)
    {
	MEMclose( &info );
        _NFMR_num ("NFMRlist_items_on_tape : UNSUCCESSFUL : <0x%.8x>", ret_status);
        return (ret_status); 
    }

    status = MEMsplit_copy_buffer (info, data_list, 0);
    if (status != MEM_S_SUCCESS)
    {
        MEMclose (&info);
        _NFMR_num("NFMRlist_items_on_tape : MEMsplit_copy_buffer : <0x%.8x>",
		   status);
        return (status);
    }
    
    MEMclose (&info);
 
    return (NFM_S_SUCCESS); 
}

