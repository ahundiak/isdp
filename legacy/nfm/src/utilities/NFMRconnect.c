#include "machine.h"
#include "NFMRinclude.h"

#define    BUFFER_SIZE    1000

long NETid; 

/*
 Doc: NFMRconnect
 
 Abstract:
     This function will connect to the NFM server.
     
 Returns:
     0 - Success
     3 - Network connection could not be made
     
 History:
     kht    03-29-1989    Creation
     
 */

long NFMRconnect (node)

char    *node;    /* i - server node name created at initilize */

{
long status;
int VAX_SERVER_PORT;

    VAX_SERVER_PORT = 1556;

    _NFMR_str ("NFMRconnect : node : <%s>", node);

    status = NETconnect (node, "", "", VAX_SERVER_PORT, VAX_SERVER_PORT,
                         &NETid, NET_XNS);

    _NFMR_num ("NFMRconnect : NET Connect = <0x%.8x>", status);

    if( status != NET_S_SUCCESS )
	return( status );

    return (NFM_S_SUCCESS);
}

