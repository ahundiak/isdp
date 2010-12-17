#include "machine.h"
#include "NFMRextern.h"

MSGptr SQLmsg_ptr = {0, "/dev/console", 0, ""};
MSGptr DBmsg_ptr = {0, "/dev/console", 0, ""};

#define    BUFFER_SIZE    1000

/* 
 Doc: NFMRclear_msg_ptrs
 
 Abstract:
     This function will clear all of the message pointers.
     
 Returns:
       0 - Success
      <0 - Failure
         
 History:
     kht    8-31-1989    Creation
     
 */
 
long NFMRclear_msg_ptrs ()

{
    NFMmsg_ptr.error_no = atol (NFM_S_SUCCESS);
    strcpy (NFMmsg_ptr.error_msg, "NFM:  Success.");

    SQLmsg_ptr.error_no = atol (SQL_S_SUCCESS);
    strcpy (SQLmsg_ptr.error_msg, "");

    DBmsg_ptr.error_no = atol (NFM_S_SUCCESS);
    strcpy (DBmsg_ptr.error_msg, "");

    MEMmsg_ptr.error_no = atol (MEM_S_SUCCESS);
    strcpy (MEMmsg_ptr.error_msg, "");

    return (NFM_S_SUCCESS); 
}


