class implementation EMScomposite;

#include "EMScc.h"
#include "EMSmsgdef.h"
#include "msdef.h"
#include "igrdef.h"
#include "madef.h"
#include "emserr.h"

method GRgetattr(IGRlong *msg; IGRchar *attr)

/*
Description
     This method gets the element specific attributes of the composite.

Note
     Since the display attributes for a composite are undefined, this
     method will continue searching all components until it finds a
     valid set of attributes.

Return values for error code
        MSSUCC if successful
        MSFAIL (severe) if failure

History
        DLB     10/30/87 : Creation
        dhm     12/21/87 : initalized the to_comps chanselect
        DLB     06/10/92   Ignore OM_W_REJECTED_METHOD stat due to stupid
                            GR3dtext on comps chan (disjoint boolean stuff).
        Jack    07/02/93 : Modified to send to all components rather than just
                           the first.  This fixes 119305982, never found a valid
                           attr by just checking first component.
*/

{
  IGRlong         OM_stat,
                  ii;
  OM_S_CHANSELECT to_comps; 
  IGRuint         num_children;

  *msg = MSFAIL;

  to_comps.type = OM_e_addr;
  to_comps.u_sel.addr = &ME.GRcmpowner->to_components;

  OM_stat = om$get_channel_count(
            object = me,
            p_chanselect = &to_comps,
            count = &num_children);
  if (! (1 & OM_stat)) goto wrapup;

/*
 * Loop over all my children until one of them answers
 * properly or all are exhausted.
 */
 for (ii = 0; ii < num_children; ii++)
  {
    *msg = MSFAIL;
    OM_stat = om$send(msg = message GRvg.GRgetattr(
                                          msg,
                                          attr ),
                      p_chanselect = &to_comps,
                      from = ii, to = ii);
    if (( 1 & OM_stat ) && ( 1 & *msg )) return( OM_stat);
  }

 wrapup:
  EMWRAPUP(*msg, OM_stat, "EMScomposite.GRgetattr")
  if (1 & *msg) *msg = MSFAIL;
  if (1 & OM_stat) OM_stat = OM_E_ABORT;  
  return(OM_stat);
}
end implementation EMScomposite;
