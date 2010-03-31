/* ###################   APOGEE COMPILED   ################## */

class implementation EMSsubbs;

#include "emsmacros.h"
#include "EMSopt.h"
#include "EMS.h"


method EMtoggle_polygon(
 IGRlong *EMmsg;
 struct GRid *md_grid;
 IGRchar *attr)

/* 
DESCRIPTION
    
    This method is called when the polygon is toggled for a surface.
     It first loads the "class specific" attributes into a surface
     object and then calls "...put_range_" to modify the rtree range if
     need be.

RETURN VALUES

    EMmsg               EMS_S_Success if success.
			EMS_E_Fail    if failure.

HISTORY
    19 Aug 88   SAM     Genesis.
*/
{
  IGRlong    OM_stat;


OM_stat = OM_S_SUCCESS;
*EMmsg = EMS_S_Success;


OM_stat = om$send(msg = message GRvg.GRputattr(
        	      	 EMmsg,
        	         attr),
	          targetid = my_id);
EMerr_hndlr(!(1&OM_stat&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

OM_stat = om$send(msg = message EMSsubbs.EMput_range_in_rtree(
			 EMmsg,
			 NULL,  /* geometry of the surface */
			 NULL, /* old range of the surface */
			 NULL, /* new range of the surface */
			 POLYGON_TOGGLE, /* surface change */
			 md_grid),
		  targetid = my_id);
EMerr_hndlr(!(1&OM_stat&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

wrapup:
  EMWRAPUP(*EMmsg, OM_stat, "In EMSsubbs.EMtoggle_polygon")
  return (OM_stat);
}

end implementation EMSsubbs;

