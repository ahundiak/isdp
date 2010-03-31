/******************************************************************************
*
* Description:
*
*    This method just passes on the message to the dominant surface.
*
* Overrides:
*    GRreport at GRgraphics.
*
*
*     
* Abstract
*        This method may be used in the following ways:
*
*
* Method: GRreport
*
*  (O) IGRlong		 	   *msg		   Error Message
*  (I) struct GRnd_env             *md_env         Module Environment
*  (IO)IGRint                      *list_size      List size
*  (IO)struct GRreport_item        *list           Reported items buffer
*  (I) struct GRreport_processor   *processor      Report information

* Description:
*
*   This method just passes on the message to the dominant surface.
*
* Completion codes return in msg argument:
*       - MSSUCC if successful
*       - MSINARG if list_size does not equal the number of report items
*       - MSFAIL (severe) if other error
*
* History:
*
*    msm	06/05/91    creation date.
*
******************************************************************************/


class implementation EMSsfsolid;

#include "grimport.h"
#include "msdef.h"
#include "msmacros.h"
#include "gocmacros.h"
#include "grmessage.h"
#include "go.h"
#include "revieweledef.h"
#include "MDreveledef.h"
#include "EMSsfparms.h"

method GRreport(IGRlong *msg; struct GRmd_env *md_env; IGRint *list_size;
                struct GRreport_item *list; 
                struct GRreport_processor *processor )
{
  IGRlong    status;
  OM_S_CHANSELECT to_components;

  /*
   * Initalize variables.
   */

  status = OM_S_SUCCESS;
  *msg = MSSUCC;

  to_components.type = OM_e_addr;
  to_components.u_sel.addr = &me^^GRcmpowner.to_components;

   status = om$send (msg = OPPmargs,
                     p_chanselect = &to_components,
                     from = 0,
                     to = 0);
   EMerr_hndlr(!(1&status&*msg), *msg, *msg, ret_end);


  ret_end:
    return (status);
}
end implementation EMSsfsolid;
