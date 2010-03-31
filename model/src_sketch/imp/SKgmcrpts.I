class implementation SKgeometry;

#include <math.h>
#include "OMmacros.h"
#include "EMSopt.h"
#include "maoptsxfo.h"
#include "mabcendpts.h"
#include "maang2vc.h"
#include "bsmkvec.h"
#include "bsdotp.h"
#include "bsdistptpt.h"
#include "bscveval.h"
#include "bscrossp.h"
#include "bsarccen.h"

#define FIRST  0
#define SECOND 1
#define THIRD  2

#define X 0
#define Y 1
#define Z 2

#define EMomerr_exit(sts, label) if (EMSerror (sts)) goto label;

from SKvariable import SKputvar, SKchgprops;
from SKmgr import SKconnect_to_ptvar, SKget_xymat;
from SKcircle import SKputradang;

extern GRclassid OPP_SKptvar_class_id;

method SKcreate_ptvars (IGRlong *msg; IGRushort opts;
                        IGRshort *mattyp; IGRdouble *mat;
                        IGRshort *to_xy_mattyp; IGRdouble *to_xy_mat;
                        GRobjid *skmgr;
                        IGRint *num_ptvars; GRobjid **ptvars)
{
  IGRboolean arc_opposed;
  IGRushort mygeomtype;
  IGRshort loc_xy_mattyp;
  IGRuint num;
  IGRint i, num_have, num_reqd, num_pts_create;
  IGRlong owner_index, stat_OM, msg_loc, one=1, two=2;
  IGRdouble radius, radangle, angle_info[3];
  IGRpoint pts[3], endpts[2], pttan[2], centre, xyz_centre;
  IGRvector radvec, xvec, zvec, crossvec, tanvec;
  IGRmatrix loc_xy_mat;
  GRobjid loc_skmgr, loc_ptvars[3], cenptid;
  struct IGRbsp_curve *cv;
  struct GRmd_env md_env;
  struct IGRdisplay display;
  struct GRid grid;
  struct GRvg_construct cnstr_list;
  enum GRdpmode dpmode;
  OM_S_CHANSELECT chan_to_defpts;
  OM_S_OBJECT_LINKAGE objlist[3];
  extern void EMinitvgcnstr() , SKgetgeomtype() ;
  extern IGRboolean EMgetvgcnstr();
  extern IGRlong EMgetabsg();
 
  *msg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;

  /*
   * Obtain the sketch manager
   */

  if (!skmgr)
  {
    stat_OM = om$send (msg = message SKgeometry.SKgetmgr (&msg_loc,
               &loc_skmgr), targetid = my_id);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  } 
  else
    loc_skmgr = *skmgr;

  /*
   * Obtain the XYZ-to-XY matrix that would take world-geometry (XYZ) and
   * transform it to local geometry (XY).
   */

  if (! (to_xy_mat || to_xy_mattyp))
  {
    stat_OM = om$send (msg = message SKmgr.SKget_xymat (&msg_loc,
               SK_OPT_GET_XYZ_TO_XY, mattyp, mat, &loc_xy_mattyp, loc_xy_mat),
               targetid = *skmgr);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  }
  else
  {
    loc_xy_mattyp = *to_xy_mattyp;
    OM_BLOCK_MOVE (to_xy_mat, loc_xy_mat, sizeof (IGRmatrix));
  }

  /*
   * In this method, the following geometry types are processed:
   * a) line, b) arc, c) circle and d) point. Any other type must have
   * an override (for example: composite-curve).
   */

  SKgetgeomtype (my_id, OM_Gw_current_OS, &mygeomtype);
  EMerr_hndlr (mygeomtype == NULL_GEOM, *msg, EMS_E_InvalidArg, ret_end);

  /*
   * Obtain this object's defining points in the local co-ordinate
   * system. Also, in the case of an arc/circle obtain the fact whether
   * the direction of the arc is positive w.r.t to the manager-normal
   * or is it opposed. In the case of a circle, the angle subtended by the
   * radius vector to the horizontal is recorded. The stop-point of the
   * circle is made to lie along the positive x-axis from the centre.
   */

  stat_OM = EMgetabsg (&msg_loc, mattyp, mat, OM_Gw_current_OS, my_id, &cv);
  EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
 
  MAbcendpts (&msg_loc, cv, endpts[FIRST], endpts[SECOND]);
  EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_MAerror, ret_end);

  if (loc_xy_mattyp != MAIDMX)
  {
    MAoptsxform (&msg_loc, &two, &loc_xy_mattyp, loc_xy_mat, endpts[0], endpts[0]);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_MAerror, ret_end);
    for (i=FIRST; i<=SECOND; i++)
      endpts[i][Z] = 0.0;
  }

  if (mygeomtype & (SK_ARC | SK_CIRCLE))
  {
    BSarccen (&msg_loc, cv, xyz_centre);
    EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

    OM_BLOCK_MOVE (xyz_centre, centre, sizeof (IGRpoint));
    if (loc_xy_mattyp != MAIDMX)
    {
      MAoptsxform (&msg_loc, &one, &loc_xy_mattyp, loc_xy_mat, centre, centre);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_MAerror, ret_end);
      centre[Z] = 0.0;
    }

    BSmkvec (&msg_loc, radvec, centre, endpts[FIRST]);
    EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

    BScveval (cv, 0.0, 1, pttan, &msg_loc);
    EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);
    for (i=X; i<=Z; i++)
      pttan[1][i] += pttan[0][i];
 
    if (loc_xy_mattyp != MAIDMX)
    {
      MAoptsxform (&msg_loc, &two, &loc_xy_mattyp, loc_xy_mat, pttan[0], pttan[0]);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_MAerror, ret_end);
      pttan[0][Z] = pttan[1][Z] = 0.0;
    }
  
    BSmkvec (&msg_loc, tanvec, pttan[0], pttan[1]);
    EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

    BScrossp (&msg_loc, radvec, tanvec, crossvec);
    EMerr_hndlr (msg_loc != BSSUCC, *msg, EMS_E_BSerror, ret_end);

    zvec[X] = zvec[Y] = 0.0; zvec[Z] = 1.0;
    if (BSdotp (&msg_loc, crossvec, zvec) < 0.0)
      arc_opposed = TRUE;
    else
      arc_opposed = FALSE;

    if (mygeomtype & SK_CIRCLE)
    {
      xvec[X] = 1.0; xvec[Y] = xvec[Z] = 0.0;
      MAang2vc (&msg_loc, xvec, radvec, angle_info);
      EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_MAerror, ret_end);
      radangle = angle_info[0];

      radius = BSdistptpt (&msg_loc, centre, endpts[FIRST]);
      OM_BLOCK_MOVE (centre, endpts[FIRST], sizeof (IGRpoint));
      endpts[FIRST][X] += radius;
      OM_BLOCK_MOVE (endpts[FIRST], endpts[SECOND], sizeof (IGRpoint));
    }
  }

  /*
   * Collate the points to be made ptvars out of.
   */

  if (mygeomtype & SK_LINE)
  {
    num_pts_create = opts & SK_PROCSKGR_PROCEND ? 2 : 1;
    OM_BLOCK_MOVE (endpts, pts, 2 * sizeof (IGRpoint));
  }
  else if (mygeomtype & SK_ARC)
  {
    num_pts_create = opts & SK_PROCSKGR_PROCEND ? 3 : 2;
    OM_BLOCK_MOVE (endpts[FIRST], pts[FIRST], sizeof (IGRpoint));
    OM_BLOCK_MOVE (centre, pts[SECOND], sizeof (IGRpoint));
    if (num_pts_create == 3)
      OM_BLOCK_MOVE (endpts[SECOND], pts[THIRD], sizeof (IGRpoint));
  }
  else if (mygeomtype & SK_CIRCLE)
  {
    num_pts_create = 2;
    OM_BLOCK_MOVE (endpts[FIRST], pts[FIRST], sizeof (IGRpoint));
    OM_BLOCK_MOVE (centre, pts[SECOND], sizeof (IGRpoint));
  }
  else
  {
    num_pts_create = 1;
    OM_BLOCK_MOVE (endpts[FIRST], pts[FIRST], sizeof (IGRpoint));
  }

  /*
   * Create the required ptvars and connect to manager and myself.
   * Initialize the point's geometry.
   */

  if (! (opts & SK_OPT_NO_CREATE_PTS))
  {
    for (i=0; i<num_pts_create; i++)
    {
      stat_OM = om$construct (classid = OPP_SKptvar_class_id,
                              p_objid = &loc_ptvars[i]);
      EMomerr_exit (stat_OM, ret_end);
  
      stat_OM = om$send (msg = message SKmgr.SKconnect_to_ptvar (&msg_loc,
                 loc_ptvars[i], NULL, MAXINT, MAXINT), targetid = loc_skmgr); 
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  
      stat_OM = om$send (msg = message SKgeometry.SKconnect_to_pt (&msg_loc,
                 NULL, loc_ptvars[i], MAXINT, MAXINT), targetid = my_id);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  
      stat_OM = om$send (msg = message SKvariable.SKputvar (&msg_loc, NULL,
                 NULL, NULL, pts[i]), targetid = loc_ptvars[i]);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
    }
  }
  else
  {
    EMmake_chanselect (SKgeometry_to_defpts, &chan_to_defpts);
    num = 0;
    om$get_channel_objects (object = me, p_chanselect = &chan_to_defpts,
     count = &num, size = 2, list = objlist);
    EMerr_hndlr (num != 2, *msg, EMS_E_InvalidCase, ret_end);

    for (i=FIRST; i<=SECOND; i++)
      loc_ptvars[i] = objlist[i].S_objid;
  }

  /*
   * In certain cases, some special treatment may be necessary:
   * Circle : The angle by which the circumference ptvar has to be rotated
   *          about the centre to obtain the true circumference point has to
   *          stored.
   * Arc, 
   * circle : An SKpoint is created at the centre for locatability.
   *          Record the direction of the arc/circle w.r.t to the normal
   *          of the sketch's defining plane. This is recorded in a bit
   *          in the variable for the centre of the arc/circle.   
   */

  if (mygeomtype & SK_CIRCLE)
  {
    stat_OM = om$send (msg = message SKcircle.SKputradang (&msg_loc,
               radangle), targetid = my_id);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
  }
  
  if (mygeomtype & (SK_CIRCLE | SK_ARC))
  {
    IGRboolean aflag;
    struct GRmd_env rfenv;

    EMinitvgcnstr (&msg_loc, &md_env, &display, NULL, &cnstr_list);
    aflag = pwIsActivationOn();
    if (aflag)
    {
      pwGetActiveModuleEnv(&rfenv);
      EMgetvgcnstr (NULL, NULL,&rfenv, ME.GRgraphics->level, NULL, NULL, NULL,
                  &cnstr_list);

    }
    else 
    {
      EMgetvgcnstr (NULL, NULL,NULL, ME.GRgraphics->level, NULL, NULL, NULL,
                  &cnstr_list);
    }

    EFplace_line_string (my_id, &cnstr_list, 1, xyz_centre, &cenptid, &msg_loc);
    EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);
 
    stat_OM = om$change_class (objid = cenptid, classname = "SKpoint");
    EMomerr_exit (stat_OM, ret_end);

    grid.objid = loc_skmgr;
    grid.osnum = OM_Gw_current_OS;
    owner_index = FIRST;
    stat_OM = om$send (msg = message GRconnector.GRrigidconn (&msg_loc,
               &grid, &owner_index),
               targetid = cenptid);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

    stat_OM = om$send (msg = message SKgeometry.SKconnect_to_pt (&msg_loc,
               NULL, loc_ptvars[SECOND], 0, 0), targetid = cenptid);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);

    dpmode = GRbd;
    stat_OM = om$send (msg = message GRgraphics.GRdisplay (&msg_loc,
               mattyp, mat, &dpmode, &cnstr_list.env_info->md_id),
               targetid = cenptid);
    EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end); 

    if (arc_opposed)
    {
      stat_OM = om$send (msg = message SKvariable.SKchgprops (&msg_loc,
                 EMS_O_ON, SK_VAR_NEGDIRGEOM), targetid = loc_ptvars[SECOND]);
      EMerr_hndlr (EMSerror (stat_OM & msg_loc), *msg, EMS_E_Fail, ret_end);
    }
  }

  /*
   * Add to the output arguments
   */
  
  if (ptvars && num_ptvars)
  {
    num = *num_ptvars;
    num_have = (num / SK_INCR_SIZE) + (num % SK_INCR_SIZE ? 1 : 0);
    num += num_pts_create;
    num_reqd = (num / SK_INCR_SIZE) + (num % SK_INCR_SIZE ? 1 : 0);
    if (num_reqd > num_have)
    {
      if (*ptvars)
        *ptvars = (GRobjid *) om$realloc (ptr = (char *) *ptvars, 
                   size = num_reqd * SK_INCR_SIZE * sizeof (GRobjid));
      else
        *ptvars = (GRobjid *) om$malloc (size = num_reqd * SK_INCR_SIZE *
                   sizeof (GRobjid));
      EMerr_hndlr (!*ptvars, *msg, EMS_E_NoDynamicMemory, ret_end);
    }
  
    OM_BLOCK_MOVE (loc_ptvars, &(*ptvars)[*num_ptvars],
     num_pts_create * sizeof (GRobjid));
  }

  if (num_ptvars)
    (*num_ptvars) += num_pts_create;

ret_end:
  EMWRAPUP (*msg, stat_OM, "SKgeometry.SKcreate_ptvars");
  return (stat_OM);
}

end implementation SKgeometry;

