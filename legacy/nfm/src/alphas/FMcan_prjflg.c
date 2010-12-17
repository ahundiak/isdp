#include "machine.h"
#include <stdio.h>
#include "NFMerrordef.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFMRextern.h"
#include "DEBUG.h"

long cancel_project_archive_flag ()

{
long   status;
static char *fname = "NFAcancel_project_archive_flag";

    _NFIdebug(( fname, "%s\n", "Entering ..."));

    status = NFMRcancel_project_archive_flag (NFMproject);

    _NFIdebug(( fname, "Return from NFMRcancel_project_archive_flag -> 0x%.8x\n", status));

    if (status != NFM_S_SUCCESS)
        return (status);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}

long cancel_project_backup_flag ()

{
long   status;
static char *fname = "NFAcancel_project_backup_flag";

    _NFIdebug(( fname, "%s\n", "Entering ..."));

    status = NFMRcancel_project_backup_flag (NFMproject);

    _NFIdebug(( fname, "Return from NFMRcancel_project_backup_flag -> 0x%.8x\n", status));

    if (status != NFM_S_SUCCESS)
        return (status);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}

long cancel_project_restore_flag ()

{
long   status;
static char *fname = "NFAcancel_project_restore_flag";

    _NFIdebug(( fname, "%s\n", "Entering ..."));

    status = NFMRcancel_project_restore_flag (NFMproject);

    _NFIdebug(( fname, "Return from NFMRcancel_project_restore_flag -> 0x%.8x\n", status));

    if (status != NFM_S_SUCCESS)
        return (status);

    NFAmake_msg (msg);
    _NFIdebug(( fname, "%s\n", msg));
    SCdisplay_ref (msg);
        
    return (NFI_S_SUCCESS);
}

