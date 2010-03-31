/* ###################   APOGEE COMPILED   ################## */
class implementation GRcompcurve;

#include "EMScc.h"
#include "msdef.h"
#include "go.h"
#include "gr.h"
#include "ma.h"
#include "OMmacros.h"
#include "emsdef.h"
#include "emserr.h"
#include "emsmacros.h"

method GRmidpoint(IGRlong 	*msg; IGRshort *mat_type; IGRmatrix matrix;
                  struct GRparms *ref_parms; IGRpoint midpoint)
/*
NOTES

	Upon exit the completion code will be one of

		- MSSUCC if successful
		- MSFAIL(severe) if failure

History
	
	pwd	7/7/87 : Creation date
	dhm 12/21/87 : converted to 1.1 and fixed some problems.
    dhm 04/08/88 : rewrote to be more efficient.

Abstract
        This method returns the midpoint of a composite curve
        and ref_parms reflects which component contains
        the midpoint.

*/		

{
  IGRchar	errmsg[EMMAXERRMSG_LEN];
  OMuint    count;
  IGRlong  	OM_stat, mthd_stat;
  IGRdouble arclength, midway;
  IGRpoint  point1, point2, prj_pt;
  struct GRparms   p1, p2;
  OM_S_CHANSELECT   to_comps;

  /*
   * Initialize variables.
   */

  *msg = MSSUCC;
  OM_stat = OM_S_SUCCESS;
  strcpy (errmsg, "GRcompcurve.GRmidpoint");

  OM_stat = EMmake_chanselect (GRcmpowner_to_components, &to_comps);
  EMomerr_hndlr(OM_stat, wrapup, errmsg);

  /*
   * get total arclength of the composite curve. 
   */

  arclength = 0.0;

  OM_stat = om$send(msg = message GRcurve.GRtotlength(&mthd_stat,
                          mat_type, matrix, &arclength),
                    targetid = my_id);
  EMomerr_hndlr(OM_stat, wrapup, errmsg);
  EMerr_hndlr(EMis_error(mthd_stat), *msg, MSFAIL, wrapup);

  midway = arclength / 2.0;       

  /* 
   * determine composites' midpoint by calculating appropriate
   * point on target segment
   */

  OM_stat = om$send(msg = message GRcurve.GRendpts(&mthd_stat, mat_type,
                          matrix, point1, point2),
				    targetid = my_id);
  EMomerr_hndlr(OM_stat, wrapup, errmsg);
  EMerr_hndlr(EMis_error(mthd_stat), *msg, MSFAIL, wrapup);

  p1.u = 0.0;
  p2.u = 1.0;
  OM_stat = om$get_objid_at_index(object = me,
                                 p_chanselect = &to_comps,
                                 index = 0,
                                 objidaddr = &p1.leaf_id.objid,
                                 osnumaddr = &p1.leaf_id.osnum);
  EMomerr_hndlr_action(OM_stat, *msg = MSFAIL; goto wrapup, errmsg);

  OM_stat = om$get_channel_count(object = me,
                                p_chanselect = &to_comps,
                                count = &count);
  EMomerr_hndlr(OM_stat, wrapup, errmsg);

  OM_stat = om$get_objid_at_index(object = me,
                                 p_chanselect = &to_comps,
                                 index = (count-1),
                                 objidaddr = &p2.leaf_id.objid,
                                 osnumaddr = &p2.leaf_id.osnum);
  EMomerr_hndlr(OM_stat, wrapup, errmsg);

  OM_stat = om$send(msg = message GRcurve.GRptalong(&mthd_stat, mat_type,
                          matrix, point1, point2, &p1, &p2, &midway,
                          midpoint),
				    targetid = my_id);
  EMomerr_hndlr(OM_stat, wrapup, errmsg);
  EMerr_hndlr(EMis_error(mthd_stat), *msg, MSFAIL, wrapup);

  OM_stat = om$send(msg = message GRgraphics.GRptproject(&mthd_stat,
                          mat_type, matrix, midpoint, prj_pt, ref_parms),
				    targetid = my_id);
  EMomerr_hndlr(OM_stat, wrapup, errmsg);
  EMerr_hndlr(EMis_error(mthd_stat), *msg, MSFAIL, wrapup);

wrapup:
    return(OM_stat);
}

end implementation GRcompcurve;
