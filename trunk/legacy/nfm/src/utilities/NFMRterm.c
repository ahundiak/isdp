#include "machine.h"
#include "NFMRinclude.h"

#define    BUFFER_SIZE    1000

extern long NETid;

/*
 Doc: NFMRterminate
 
 Abstract:
     This function will terminate the NFM server.
     
 Returns:
     0 - Success
     3 - Network terminate failure
     
 History:
     kht    03-29-1989    Creation
     
 */
 
long NFMRterminate ()

{
long   status;

    _NFMR_str ("<%s> :", "NFMRterminate");

    status = NFMcl_fs_exit (&NETid);
    _NFMR_num ("NFMRterminate : NFMcl_fs_exit : status = <0x%.8x>", status);

    return (NFM_S_SUCCESS);
}

