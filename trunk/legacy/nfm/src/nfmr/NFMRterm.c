#include "machine.h"

/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFMRextern.h"

#define    BUFFER_SIZE    1000

/*
 Doc: NFMRterminate
 
 Abstract:
     This function will terminate the NFM server.
     
 */
 
long NFMRterminate ()

{
long   status;

    static char *fname = "NFMRterminate";
    status = NFMcl_fs_exit (&NFMRglobal.NETid);
    _NFMRdebug(( fname, "NFMcl_fs_exit : status = <0x%.8x>\n", status));

    return (NFM_S_SUCCESS);
}

