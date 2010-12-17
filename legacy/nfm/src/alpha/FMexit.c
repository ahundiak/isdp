#include "machine.h"
#include <stdio.h>
#include "UNIX_or_VMS.h"
#include "NFMerrordef.h"
#include "NFMdef.h"
#include "MEMstruct.h"
#include "SCstruct.h"
#include "SCdef.h"
#include "NFMRextern.h"

nfm_exit ()

{
long   status;
MEMptr logout_def = NULL;
static char *fname = "NFAexit";

    _NFIdebug ((fname, "Enter.\n"));


/*	Added by MVR to avoid the unconnected exit status -- 21 Jan 1994 
	This avoids odd behavior when PF3 is tried while not connected to
	any server  */

#ifndef COMBINED_CLIENT_SERVER
    if (NFMRglobal.NETid == -1)
      {
        /*  We're not connected  */
        _NFIdebug ((fname, "not connected to I/NFM server\n"));
        _NFIdebug ((fname, "returning SUCCESS <0x%.8x> ...\n", NFI_S_SUCCESS));
        return (NFI_S_SUCCESS);
      }
#endif

/*	End of addition MVR */

    status = NFAalpha_defaults_logout( &logout_def );
    if( status == NFI_S_SUCCESS )
    {
        status = NFMRwrite_user_defaults( logout_def );
        if( status != NFM_S_SUCCESS )
  	   _NFIdebug ((fname, "EXIT : NFMRset_user_defaults : <0x%.8x>\n", 
			status));
    }
    else
	_NFIdebug ((fname, "EXIT : NFAalpha_defaults : <0x%.8x>\n", status));

#ifndef COMBINED_CLIENT_SERVER
    status = NFMRget_host_info (NFMuser_id, 0) ;
     if (status != NFM_S_SUCCESS)
         _NFIdebug(( fname, "NFMget_host_info : <0x%.8x>\n", status) );
#endif

    SCdisplay_msg ("Working..");

    status = NFMRlogout( NFMuser_id );
    _NFIdebug ((fname, "EXIT : NFMRlogout : <0x%.8x>\n", status));

#ifndef COMBINED_CLIENT_SERVER
    SCdisplay_msg ("Working..");

    status = NFMRterminate ();
    if (status == NFM_S_SUCCESS)
        {
        _NFIdebug ((fname, "EXIT : FS Exit : status = <0x%.8x>\n", status));
        return (status); 
        }

    if (status != NFM_S_SUCCESS)
        {
        SCdisplay_msg ("NFM:  Cannot Exit.");
        return (status);
        }
#endif

    SCclear_msg ();

    return (NFI_S_SUCCESS);
}

