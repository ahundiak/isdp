#include "machine.h"
#include "NFMRextern.h"

#define    BUFFER_SIZE    1000

long NFMRconnect (node)

char    *node;    /* i - server node name created at initilize */

{
long   status;
static char *fname = "NFMRconnect";

    _NFMRdebug(( fname, "node : <%s>\n", node));

    status = NFMconnect (node, "", "", NFM_SERVER_PORT, NFM_SERVER_PORT,
                         &NFMRglobal.NETid, NULL);

    _NFMRdebug(( fname, "NFMconnect <0x%.8x>\n", status));

    if( status != NFM_S_SUCCESS )
	return( status );

    return (NFM_S_SUCCESS);
}

