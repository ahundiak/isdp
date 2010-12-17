#include "machine.h"
#include <stdio.h>
#include "UNIX_or_VMS.h"
#include "NFMerrordef.h"
#include "NFMdef.h"
#include "MEMstruct.h"
#include "MEMerrordef.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFMRextern.h"
#include "ERR.h"
#include "NDXstruct.h"

extern long sqlstatus;

long lock_item ()

{
long   status;
static char *fname = "lock_item";

    _NFIdebug ((fname, "Enter.\n"));

    SCdisplay_msg ("Working..");    

    status = NFMRlock_item (NFMuser_id, NFMcatalog, NFMitem, NFMrev);

    _NFIdebug ((fname, "NFMRlock_item -> <0x%.8x>\n", status));

    if (status != NFM_S_SUCCESS)
         return (status);
 
    NFAmake_msg (msg);
    _NFIdebug ((fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}


long unlock_item ()

{
long   status;
static char *fname = "unlock_item";

    _NFIdebug ((fname, "Enter.\n"));

    SCdisplay_msg ("Working..");    

    status = NFMRunlock_item (NFMuser_id, NFMcatalog, NFMitem, NFMrev);

    _NFIdebug ((fname, "NFMRunlock_item -> <0x%.8x>\n", status));

    if (status != NFM_S_SUCCESS)
        return (status);

    NFAmake_msg (msg);
    _NFIdebug ((fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}



