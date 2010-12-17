#include "machine.h"
#include <stdio.h>
#include "UNIX_or_VMS.h"
#include "NFMerrordef.h"
#include "NFMdef.h"
#include "MEMstruct.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFMRextern.h"
#include "ERR.h"
#include "NDXstruct.h"

long flag_project_archive ()

{
long   status;
static char *fname = "NFAflag_project_archive";

    _NFIdebug(( fname, "%s\n", "Entering ..." ));

    status = NFMRflag_project_archive (NFMuser_id, NFMproject );

    _NFIdebug(( fname, "Return from NFMRflag_project_archive -> <0x%.8x>\n",
		status));

    if (status != NFM_S_SUCCESS)
        return (status);
        
    return (NFI_S_SUCCESS);
}


long flag_project_backup ()

{
long   status;
static char *fname = "NFAflag_project_backup";
    
    _NFIdebug(( fname, "%s\n", "Entering ..." ));

    status = NFMRflag_project_backup (NFMuser_id, NFMproject );

    _NFIdebug(( fname, "Return from NFMRflag_project_backup -> <0x%.8x>\n", 
		status));

    if (status != NFM_S_SUCCESS)
        return (status);
        
    return (NFI_S_SUCCESS);
}


long flag_project_restore ()

{
long   status;
static char *fname = "NFAflag_project_restore";

    _NFIdebug(( fname, "%s\n", "Entering..." ));

    status = NFMRflag_project_restore (NFMuser_id, NFMproject );

    _NFIdebug(( fname, "Return from NFMflag_project_restore -> <0x%.8x>\n",
		status));

    if (status != NFM_S_SUCCESS)
        return (status);
        
    return (NFI_S_SUCCESS);
}
