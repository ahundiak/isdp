/* ###################   APOGEE COMPILED   ################## */
class implementation EMSedge;

/*
   History

         Sudha 06/04/93          modified to include BSprototype header files

*/

# include "EMSmsgdef.h"     /* EMS error codes      */
# include "EMSlogic.h"      /* EMSmsgReport         */
# include "EMStypedef.h"    /* EMSmsgReport         */
# include "EMScmacros.h"    /* EMSmsgReport         */
# include "bstypes.h"       /* BSrc                 */

#include "malnpspro.h"
#include "bssfeval.h"

extern void     EMSsubbs_get_locate_window();
extern IGRint   EFrule_lines_on_off();

method EMkeypoint(IGRlong *EMmsg; struct IGRbsp_surface *surface;
                  struct IGRline *boreline; IGRpoint keypoint;
                  struct GRparms *key_parm; IGRdouble *distance_squared)
{
  IGRlong       sts;
  GRobjid             window_id;
  GRspacenum          window_os;

  /*
   * Initialize
   */
  sts = OM_S_SUCCESS;
  *EMmsg = EMS_S_Success;

  if(me->ed_props & EMED_NO_DISPLAY) goto wrapup;

  EMSsubbs_get_locate_window(&window_id, &window_os);
  if((me->ed_props & EMED_SEAM) && (me->ed_props & EMED_TANGENT))
    if(! EFrule_lines_on_off(window_id, window_os)) goto wrapup;

  /* block */
  {
    BSrc          rc;
    IGRlong       pt_index;
    IGRdouble     my_distance_squared, t_parm, uv_point[2], xyz_point[3];
    IGRpoint      pt_on_line, project_pt;

    sts = om$send(msg = message EMSedge.EMendpts(EMmsg, uv_point, NULL,
                  NULL, NULL, NULL), targetid = my_id);
    if(! (1 & *EMmsg & sts)) goto wrapup;

    BSsfeval(surface, uv_point[0], uv_point[1], 0, (IGRpoint *)xyz_point, &rc);
    if(rc) { *EMmsg = EMS_E_Fail; goto wrapup; }

    {
      struct IGRpointset  point_set;

      point_set.num_points = 1;
      point_set.points = xyz_point;
      (void) MAlnpsproj(&rc, boreline, &point_set, pt_on_line, project_pt,
                        &t_parm, &pt_index);
    }

    /*
     * Find the distance squared
     */
    {
      IGRpoint    vector;

      vector[0] = pt_on_line[0] - project_pt[0];
      vector[1] = pt_on_line[1] - project_pt[1];
      vector[2] = pt_on_line[2] - project_pt[2];
      my_distance_squared = (vector[0] * vector[0]) +
                            (vector[1] * vector[1]) +
                            (vector[2] * vector[2]);
    }

    /*
     * Fill in the parameters
     */
    if(my_distance_squared < *distance_squared)
    {
      key_parm->u = uv_point[0];
      key_parm->v = uv_point[1];
      keypoint[0] = xyz_point[0];
      keypoint[1] = xyz_point[1];
      keypoint[2] = xyz_point[2];
      *distance_squared = my_distance_squared;
    }
  }

wrapup:
  EMSmsgReport(sts, "EMSedge.EMkeypoint", FALSE);
  EMSmsgReport(*EMmsg, "EMSedge.EMkeypoint", FALSE);
  *EMmsg = EMS_S_Success;
  return(OM_S_SUCCESS);
}

end implementation EMSedge;
