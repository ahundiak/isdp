#include "machine.h"
#include <stdio.h>
#include "MEMstruct.h"
#include "NFMerrordef.h"
#include "NFMSextern.h"
#include "UTIerrordef.h"
#include "UTIstruct.h"
#include "UTIglobals.h"
#include "DEBUG.h"

#define BUFFER_SIZE 1000

UTIprocess_restore( flist )
    UTIpending  flist;
{
    long	status;
    int		group_no = 0;
    UTIarch	uti_arch_loc = NULL;
    static 	char *fname = "UTIprocess_restore";

    _UTIdebug(( fname, "%s\n", "Entering ..." ));

    status = UTIbuild_script( UTIrestore, group_no, uti_arch_loc, flist );
    if( status != UTI_S_SUCCESS )
 	return( status );

    _UTIdebug(( fname, "%s\n", "Exiting ..." ));

    return( UTI_S_SUCCESS );
}
