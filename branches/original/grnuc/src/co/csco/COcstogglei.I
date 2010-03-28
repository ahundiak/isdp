/* #######################    APOGEE COMPILED   ######################## */





 /*
 COPYRIGHT
                     COPYRIGHT INTERGRAPH CORPORATION
                              < 1986, 1987 >
  
              Including software  and  its  file formats, and
              audio-visual displays; all rights reserved; may
              only  be  used   pursuant   to  the  applicable
              software     license     agreement;    contains
              confidential  and  proprietary  information  of
              Intergraph and/or other  third parties which is
              protected  by  copyright,   trade  secret,  and
              trademark  law,  and  may  not  be  provided or
              otherwise made available  without prior written
              authorization.
  
  
                         RESTRICTED RIGHTS LEGEND
              Use, duplication,  or  disclosure  by  the U.S.
              Government is  subject  to  restrictions as set
              forth in subdivision  (b)(3)(ii)  of the Rights
              in Technical Data  and Computer Software clause
              at 52.227-7013.
  
  
              Intergraph Corporation
              One Madison Industrial Park
              Huntsville, Al 35807-4201
  
 */ 

/*
Abstract
        This  command object turns the the display ON/OFF 
        for all coordinate systems.

History
        10/15/86  Kumar Talluri  Design and Implementation.
        08/11/87  vasu           Message file used to extract messages
        09/03/87  mrm            use current module for sends
*/

class implementation COcstoggle;

#include "coimport.h"
#include "msdef.h"
#include "grmessage.h"
#include "msmacros.h"
#include "csdef.h"
#include "exmacros.h"
#include "grdpbmacros.h"

from GRcsmgr     import GRcstoggle_display;

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                        COcstoggle execute method                    */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method execute (int *response; char *response_data; int pos)
{
    IGRint          display_on;     /* flag */
    IGRlong         sts, msg;       /* return codes */
    IGRlong         size;           /* for dpb inquiry */
    struct GRid     csmgr;          /* coordinate system manager */

    /*
     *  get the current module environment
     */

    size = sizeof (me->ModuleInfo);

    sts = gr$get_module_env (msg = &msg,
                             sizbuf = &size,
                             buffer = &me->ModuleInfo,
                             nret = &size);
    if (sts & msg & 1)
    {
        /*
         *  get the id of the coordinate system manager
         */

        sts = ex$get_super (mod_id = me->ModuleInfo.md_id.objid,
                            mod_osnum = me->ModuleInfo.md_id.osnum,
                            super_name = CoordSysMgr,
                            create = TRUE,
                            super_class = CoordSysMgrClass,
                            super_id = &csmgr.objid,
                            super_osnum = &csmgr.osnum);
        if (sts & 1)
        {
            /*
             *  Send "GRcstoggle_display" msg to GRcsmgr object
             */

            sts = om$send (msg = message GRcsmgr.GRcstoggle_display
                                (&msg, &me->ModuleInfo, &display_on),
                           targetid = csmgr.objid,
                           targetos = csmgr.osnum);
        }
    }
    if (!(sts & msg & 1))
    {
        ex$message (msgnumb = GR_E_ErrEncCmdTrm);
    }
    else if (display_on)
    {
        ex$message (msgnumb = GR_I_CorSysDspOn);
    }
    else /* if (!display_on) */
    {
        ex$message (msgnumb = GR_I_CorSysDspOff);
    }

    *response = TERMINATE;
    sleep (2);
    return (OM_S_SUCCESS);
}

end implementation COcstoggle;
