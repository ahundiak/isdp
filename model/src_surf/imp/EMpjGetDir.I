/* ###################   APOGEE COMPILED   ################## */
class implementation EMSproject;

#include "EMS.h"
# include "OMmacros.h"
# include "EMSssprops.h"
# include "EMSproject.h"
# include "emserr.h"


method EMgetDirection(IGRlong *EMmsg; struct IGRbsp_surface *my_geom;
		      IGRboolean *along_v)

/*
Abstract

    This method gets the direction of projection (along U or V) in 
    parametric space.

Arguments

    my_geom		my geometry

    along_v		returned with TRUE if direction is along V
			FALSE if it is along U.

Return Status

    EMS_S_Success       - Success
    EMS_I_NoSolution    - Could not be resolved (see in-line comment)

History

    04/20/88	RV	Creation.
*/
{
  IGRlong       OM_stat = OM_S_SUCCESS;

  *EMmsg = EMS_S_Success;

  if (me^^EMSsubbs.ss_props & EMSformat == EMSprojectedFormat)
  	*along_v = TRUE;
  else if (me^^EMSsubbs.ss_props & EMSformat == EMSrevolvedFormat)  
  	*along_v = FALSE;
  else
  {
    if (my_geom->u_order == 2 && my_geom->v_order > 2) *along_v = FALSE;
    else if (my_geom->u_order > 2 && my_geom->v_order == 2) *along_v = TRUE;
    else	/* u_order = v_order = 2 */
    {
      if (my_geom->u_num_poles == 2 && my_geom->v_num_poles > 2)
	*along_v = FALSE;
      else if (my_geom->u_num_poles > 2 && my_geom->v_num_poles == 2)
	*along_v = TRUE;
      else if (my_geom->u_num_poles == 2 && my_geom->v_num_poles == 2)
	*along_v = TRUE;
      else 	/* u_num_poles, v_num_poles > 2 */
      {
	/* 
   	 * If such a case is possible, than collinearity checks could
	 * be made to resolve the ambiguity. For the time being, accept
	 * defeat.
	 */

	*EMmsg = EMS_I_NoSolution; goto wrapup;
      }
    }
  }

wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "EMSproject.EMgetDirection")
  return(OM_stat);
}

end implementation EMSproject;
