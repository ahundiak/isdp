/******************************************************************************
*
* Description:
*
*    This method just passes on the message to the dominant surface.
*
* Overrides:
*    GRreport_defaults at GRgraphics.
*
*
* Abstract
*     
*    This method just passes on the message to the dominant surface.
*
*
* Method: GRreport_defaults
*
*  (O) IGRlong		 *msg		 Error Message
*  (O) IGRchar		 *form		 Name of the default form
*  (O) IGRint		 *label		 Title label to display (geometry type)
*  (O) IGRint		 *list_size	 Number of gadgets to fill in on form
*  (O) struct GRreport_processor *processor   Report information
*
* Description:
*
*  This method returns the report defaults including form name, title label,
*  list size, and the default report function in the GRreport_processor 
*  function.  NULL is returned for any arguments which do not
*  have a default.
*
* History:
*
*     msm     06/05/91      creation data
*
******************************************************************************/


class implementation EMSsfsolid;

#include "grimport.h"
#include "msdef.h"
#include "revieweledef.h"
#include "MDreveledef.h"

extern GRreport_output();


method GRreport_defaults(IGRlong *msg; IGRchar *form; IGRint *label;
                         IGRint *list_size; 
                         struct GRreport_processor *processor )
{
  IGRlong    status;
  OM_S_CHANSELECT to_components;

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
