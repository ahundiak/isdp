#include "machine.h"
#include <stdio.h>
#include "UNIX_or_VMS.h"
#include "NFMerrordef.h"
#include "NFMdef.h"
#include "MEMstruct.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFMRextern.h"

extern long sqlstatus;

logout ()

{
long   status;
MEMptr attr_buffer = NULL;
MEMptr data_buffer = NULL;
MEMptr value_buffer= NULL;
static char *fname = "nfm_logout";

    _NFIdebug ((fname, "Enter.\n"));

    SCdisplay_msg ("Working..");

    status = NFMRlogout(NFMuser_id);
    if (status == NFM_S_SUCCESS )
        {
        _NFIdebug ((fname, "NFMRlogout: status = <0x%.8x>\n", status));
        return (status); 
        }

    if (status != NFM_S_SUCCESS)
        {
        SCdisplay_msg ("NFM:  Cannot Exit Environment.");
        return (status);
        }

    return (NFI_S_SUCCESS);
}

