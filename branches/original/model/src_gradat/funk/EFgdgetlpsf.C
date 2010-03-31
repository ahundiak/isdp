#include "EMS.h"
/* igr.h replacement */


# ifndef msdef_include
# include "msdef.h" /* MS message codes */
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

/* end of igr.h replacement */

/* gr.h replacement */

# ifndef OM_D_MINIMUM
# include "OMminimum.h"
# endif

# ifndef igetypedef_include
# include "igetypedef.h"
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef dp_include
# include "dp.h"
# endif

# ifndef godef_include
# include "godef.h"
# endif

# ifndef gr_include
# include "gr.h"
# endif

# ifndef igr_include
# include "igr.h"
# endif

# ifndef igrdp_include
# include "igrdp.h"
# endif

# ifndef go_include
# include "go.h"
# endif

# ifndef igetypedef_include
# include "igetypedef.h"
# endif

# ifndef igrtypedef_include
# include "igrtypedef.h"
# endif

# ifndef gr_include
# include "gr.h"
# endif

#include "OMprimitives.h"
#include "OMmacros.h"
#include "OMerrordef.h"
#include "emserr.h"
#include <math.h>
#include "emsmacros_c.h"
#include "EMSerrordef.h"
#include "emsdef.h"

extern OMuword OPP_EMSloop_class_id;

/*

Notes

The following function gets the surface and/or loop attached
to the graphics data. This is written because EMShelper.to_requesters
channel is declared as rel_ordered instead of abs_ordered.
Thus, if the number objects attached is 1, it can not be determined
if the requester attached is a surface or a loop.


History

   11/02/88      RC    Creation Date
   02/13/97      SCW   included emsmacros_c.h rather than emsmacros.h

 */

void EFget_gd_lp_sf (EFmsg, gd_id, cur_os, lp_id, sf_id)
 IGRlong      *EFmsg;
 GRobjid      gd_id, *lp_id, *sf_id;
 GRspacenum   cur_os;

{
  OM_S_CHANSELECT      to_requesters;
  OM_S_OBJECT_LINKAGE  req_list[2];
  IGRlong              OM_stat;
  IGRint               num_req, count;
  OMuword              req_classid;

  *EFmsg = EMS_S_Success;
  OM_stat = OM_S_SUCCESS;

  if (lp_id) *lp_id = NULL_OBJID;
  if (sf_id) *sf_id = NULL_OBJID;

  OM_stat = EMmake_chanselect (EMShelper_to_requesters, &to_requesters);
  EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_OMerror, wrapup);

  OM_stat = om$get_channel_count (objid = gd_id, osnum = cur_os,
               p_chanselect = &to_requesters, count = (OMuint *) &num_req);
  EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_OMerror, wrapup);

  if (num_req)
  {
    OM_stat = om$get_channel_objects (objid = gd_id, 
                 osnum = cur_os, p_chanselect = &to_requesters,
                 list = req_list, size = 2, count = (OMuint *) &count);
    EMerr_hndlr (!(1&OM_stat),*EFmsg, EMS_E_OMerror, wrapup);

    /*
     * If there are 2 requesters attached to the graphics data object,
     * o The requester at 0 index will always be surface.
     * o The requester at 1 index will always be loop.
     *
     * If there is 1 requester attached to the graphics data object,
     * it can either be a surface or a loop. This is because the
     * EMShelper.to_requesters channel is rel_ordered and not abs_ordered.
     */

    if (num_req == 2)
    {
      if (sf_id) *sf_id = req_list[0].S_objid;
      if (lp_id) *lp_id = req_list[1].S_objid;
    } /* if (num_req == 2) */

    else                              /* num_reqs = 1 */
    {
      OM_stat = om$get_classid (objid = req_list[0].S_objid, 
                   osnum = cur_os, p_classid = &req_classid);
      EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_OMerror, wrapup);
   
      OM_stat = om$is_ancestry_valid (subclassid = req_classid,
                   superclassid = OPP_EMSloop_class_id);
      EMerr_hndlr (!(1&OM_stat), *EFmsg, EMS_E_OMerror, wrapup);

      if (OM_stat == OM_S_SUCCESS)
        if (lp_id) *lp_id = req_list[0].S_objid;
      else if (sf_id) *sf_id = req_list[0].S_objid;

    } /* else for if (num_req == 2) */
    
  } /* if (num_req) */

  wrapup:
   EMWRAPUP (*EFmsg, OM_stat, "In EFget_gd_lp_sf");
   return;

} /* void EFget_gd_lp_sf () */

