#include "machine.h"
#include <stdio.h>
#include "NFMerrordef.h"
#include "MEMstruct.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFMRextern.h"

long cancel_item_archive_flag ()

{
long   status;
static char *fname = "NFAcancel_item_archive_flag";

    _NFIdebug(( fname, "%s\n", "Entering ..."));

    status = NFMRcancel_item_archive_flag (NFMuser_id, NFMcatalog,
                          NFMitem, NFMrev );


    _NFIdebug(( fname, "Return from NFMRcancel_item_archive_flag -> 0x%.8x", 
		status));

    if (status != NFM_S_SUCCESS)
        return (status);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}


long cancel_item_backup_flag ()

{
long   status;
static char *fname = "NFAcancel_item_backup_flag";

    _NFIdebug(( fname, "%s\n", "Entering ..."));

    status = NFMRcancel_item_backup_flag (NFMuser_id, NFMcatalog,
                          NFMitem, NFMrev );

    _NFIdebug(( fname, "Return from NFMRcancel_item_backup_flag -> 0x%.8x", 
		status));

    if (status != NFM_S_SUCCESS)
        return (status);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}


long cancel_item_restore_flag ()

{
long   status;
static char *fname = "NFAcancel_item_restore_flag";

    _NFIdebug(( fname, "%s\n", "Entering ..."));

    status = NFMRcancel_item_restore_flag (NFMuser_id, NFMcatalog,
                          NFMitem, NFMrev );

    _NFIdebug(( fname, "Return from NFMRcancel_item_restore_flag -> 0x%.8x", 
		status));

    if (status != NFM_S_SUCCESS)
        return (status);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}


long cancel_item_delete_flag ()

{
long   status;
static char *fname = "NFAcancel_item_delete_flag";

    _NFIdebug(( fname, "%s\n", "Entering ..."));

    status = NFMRcancel_item_delete_flag (NFMuser_id, NFMcatalog,
                          NFMitem, NFMrev );

    _NFIdebug(( fname, "Return from NFMRcancel_item_delete_flag -> 0x%.8x", 
		status));

    if (status != NFM_S_SUCCESS)
        return (status);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}

