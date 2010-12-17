#include "machine.h"
#include <stdio.h>
#include "NFMerrordef.h"
#include "MEMstruct.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFMRextern.h"
#include "DEBUG.h"

long cancel_set_archive_flag ()

{
long   status;
static char *fname = "NFAcancel_set_archive_flag";

    _NFIdebug(( fname, "%s\n", "Entering ..."));

    status = NFMRcancel_set_archive_flag (NFMuser_id, NFMcatalog, NFMset, 
					  NFMset_rev);

    _NFIdebug(( fname, "Return from NFMcancel_set_archive_flag -> 0x%.8x\n", 
			status));

    if (status != NFM_S_SUCCESS)
        return (status);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}


long cancel_set_backup_flag ()

{
long   status;
static char *fname = "NFAcancel_set_backup_flag";

    _NFIdebug(( fname, "%s\n", "Entering ..."));

    status = NFMRcancel_set_backup_flag (NFMuser_id, NFMcatalog, NFMset, 
					 NFMset_rev);

    _NFIdebug(( fname, "Return from NFMcancel_set_backup_flag -> 0x%.8x\n", 
			status));

    if (status != NFM_S_SUCCESS)
        return (status);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}


long cancel_set_restore_flag ()

{
long   status;
static char *fname = "NFAcancel_set_restore_flag";

    _NFIdebug(( fname, "%s\n", "Entering ..."));

    status = NFMRcancel_set_restore_flag (NFMuser_id, NFMcatalog, NFMset, 
					  NFMset_rev);

    _NFIdebug(( fname, "Return from NFMcancel_set_restore_flag -> 0x%.8x\n", 
			status));

    if (status != NFM_S_SUCCESS)
        return (status);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}

