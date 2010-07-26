/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsubbs;
#if 0
/*
 DESCRIPTION

 Given a surface classid, this function returns the classid of an
 iso-patch extracted from the surface. The iso-patch
 classid depends upon the original surface's classid and the split
 direction.

 HISTORY

 12/10/87   RC   Creation Date

 07/01/88	SAM	 Modified such as it would have extract parameters as the
				  arguments to see if iso patch class is same as parent
				  class id.
 08/30/88   RC   Added EMSxsplane class in the check list.
 04/28/91   jhw  Added associative primitives in the check list.
 05/29/93   Jack For 2.4, objects of class EM[SA]ptorus and EM[SA]psphere will get 
                 created so I added code here to handle them.
 06/11/93   Jack Added a condition for the above fix, only do it if WANT_POST220_BEHAVIOR.
 */
#endif

%safe
#include <math.h>
%endsafe

#include "igrtypedef.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "EMSerrordef.h"
#include "EMSerrnumdef.h"
#include "emserr.h"

extern OMuword OPP_EMSgenbs_class_id;
extern OMuword OPP_EMSrevol_class_id;
extern OMuword OPP_EMStorus_class_id;
extern OMuword OPP_EMSptorus_class_id;
extern OMuword OPP_EMSelpsoid_class_id;
extern OMuword OPP_EMSsphere_class_id;
extern OMuword OPP_EMSpsphere_class_id;
extern OMuword OPP_EMSproject_class_id;
extern OMuword OPP_EMSplane_class_id;
extern OMuword OPP_EMSelpcone_class_id;
extern OMuword OPP_EMSelpcyl_class_id;
extern OMuword OPP_EMScone_class_id;
extern OMuword OPP_EMSpcone_class_id;
extern OMuword OPP_EMScylindr_class_id;
extern OMuword OPP_EMSpcylindr_class_id;
extern OMuword OPP_EMSxsplane_class_id;

extern OMuword OPP_EMAgenbs_class_id;
extern OMuword OPP_EMAtorus_class_id;
extern OMuword OPP_EMAptorus_class_id;
extern OMuword OPP_EMAelpsoid_class_id;
extern OMuword OPP_EMAsphere_class_id;
extern OMuword OPP_EMApsphere_class_id;
extern OMuword OPP_EMAplane_class_id;
extern OMuword OPP_EMAelpcone_class_id;
extern OMuword OPP_EMAelpcyl_class_id;
extern OMuword OPP_EMAcone_class_id;
extern OMuword OPP_EMApcone_class_id;
extern OMuword OPP_EMAcylindr_class_id;
extern OMuword OPP_EMApcylindr_class_id;
extern OMuword OPP_EMArevol_class_id;
extern OMuword OPP_EMAproject_class_id;

extern IGRboolean WANT_POST220_BEHAVIOR;

#define u_dir    0
#define v_dir    1
#define both_dir 2

#define u_low_limit  0
#define v_low_limit  0

#define u_high_limit 1
#define v_high_limit 1


void  EFget_iso_patch_classid (
  objid,
  osnum,
  start_param,
  end_param,
  split_dir,
  sf_classid,
  patch_classid,
  EMmsg)

  OM_S_OBJID    objid;
  OMuword       osnum;
  IGRdouble 	*start_param, *end_param;
  IGRint        split_dir;
  OMuword       *sf_classid;
  OMuword       *patch_classid;
  IGRlong       *EMmsg;

{
  struct  IGRbsp_surface    sf_def;
  IGRlong                   OM_stat, mthd_stat;
  OMuword                   parent_classid;
  IGRint                    phy_clsd_dir;
  
  OM_stat = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  /*
   * Get the input object's classid, if not sent
   */

  if (!sf_classid)
  {
    OM_stat = om$get_classid (osnum = osnum, objid = objid, 
                              p_classid = &parent_classid);
    EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);
  }
  else parent_classid = *sf_classid;

  /*
   * get the surface patch's classid
   */

  if( (start_param[0] == u_low_limit) && (start_param[1] == v_low_limit)
									  &&
	  (end_param[0] == u_high_limit)  && (end_param[1] == v_high_limit)
	)
    {
	  *patch_classid = parent_classid;
	  goto wrapup;
    }

  if ((parent_classid == OPP_EMSgenbs_class_id) ||
      (parent_classid == OPP_EMAgenbs_class_id))
      *patch_classid = OPP_EMSgenbs_class_id;
  else  if (WANT_POST220_BEHAVIOR && ((parent_classid == OPP_EMStorus_class_id) ||
            (parent_classid == OPP_EMAtorus_class_id)))
      *patch_classid = OPP_EMSptorus_class_id;
  else  if (WANT_POST220_BEHAVIOR &&((parent_classid == OPP_EMSptorus_class_id) ||
            (parent_classid == OPP_EMAptorus_class_id)))
      *patch_classid = OPP_EMSptorus_class_id;
  else  if ((parent_classid == OPP_EMSelpsoid_class_id) ||
            (parent_classid == OPP_EMAelpsoid_class_id))
      *patch_classid = OPP_EMSrevol_class_id;
  else  if (WANT_POST220_BEHAVIOR &&
           ((parent_classid == OPP_EMSsphere_class_id) ||
            (parent_classid == OPP_EMAsphere_class_id)))
      *patch_classid = OPP_EMSpsphere_class_id;
  else  if (WANT_POST220_BEHAVIOR &&
           ((parent_classid == OPP_EMSpsphere_class_id) ||
            (parent_classid == OPP_EMApsphere_class_id)))
      *patch_classid = OPP_EMSpsphere_class_id;
  else  if ((parent_classid == OPP_EMSplane_class_id) ||
            (parent_classid == OPP_EMAplane_class_id))
      *patch_classid = OPP_EMSplane_class_id;
  else  if (parent_classid == OPP_EMSxsplane_class_id)
      *patch_classid = OPP_EMSxsplane_class_id;
  else  if ((parent_classid == OPP_EMSpcylindr_class_id) ||
            (parent_classid == OPP_EMApcylindr_class_id))
      *patch_classid = OPP_EMSpcylindr_class_id;
  else  if ((parent_classid == OPP_EMSpcone_class_id) ||
            (parent_classid == OPP_EMApcone_class_id))
      *patch_classid = OPP_EMSpcone_class_id;
  else  if ((parent_classid == OPP_EMSrevol_class_id) ||
            (parent_classid == OPP_EMArevol_class_id))
      *patch_classid = OPP_EMSrevol_class_id;
  else  if ((parent_classid == OPP_EMSproject_class_id) ||
            (parent_classid == OPP_EMAproject_class_id))
      *patch_classid = OPP_EMSproject_class_id;
  else  
  {
    OM_stat = om$send (msg = message EMSsubbs.EMgetbsdef (&mthd_stat,
                        &sf_def),
                       senderid = NULL_OBJID,
                       targetid = objid, targetos = osnum);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

    phy_clsd_dir = sf_def.u_phy_closed ? v_dir : 
                   (sf_def.v_phy_closed ? u_dir : NULL);

    if ((parent_classid == OPP_EMSelpcone_class_id) ||
        (parent_classid == OPP_EMAelpcone_class_id))
    {                 
      if (split_dir == phy_clsd_dir)  
           *patch_classid = OPP_EMSelpcone_class_id;
      else *patch_classid = OPP_EMSproject_class_id;
     }
     else  if ((parent_classid == OPP_EMSelpcyl_class_id) ||
               (parent_classid == OPP_EMAelpcyl_class_id))
     {
       if (split_dir == phy_clsd_dir)  
           *patch_classid = OPP_EMSelpcyl_class_id;
       else *patch_classid = OPP_EMSproject_class_id;
      }
      else  
      if ((parent_classid == OPP_EMScone_class_id) ||
          (parent_classid == OPP_EMAcone_class_id))
      {
        if (split_dir == phy_clsd_dir)  
           *patch_classid = OPP_EMScone_class_id;
        else *patch_classid = OPP_EMSpcone_class_id;
      }
      else  
      if ((parent_classid == OPP_EMScylindr_class_id) ||
          (parent_classid == OPP_EMAcylindr_class_id))
      {
        if (split_dir == phy_clsd_dir)  
           *patch_classid = OPP_EMScylindr_class_id;
        else *patch_classid = OPP_EMSpcylindr_class_id;
      }
      else    *EMmsg = EMS_E_InvalidArg;

  }

wrapup:
  EMWRAPUP (*EMmsg, OM_stat, "EFget_iso_patch_classid");

return;

}

end implementation EMSsubbs;
