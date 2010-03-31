#include "EMS.h"

# include "OMprimitives.h"  /* om$dealloc       */
# include "OMmacros.h"      /* OM_BLOCK_MOVE    */
# include "msdef.h"         /* MSSUCC           */
# include "EMSmsgdef.h"     /* EMS error codes  */
# include "EMSlogic.h"      /* EMSmsgReport     */
# include "EMStypedef.h"    /* EMSmsgReport     */
# include "EMScmacros.h"    /* EMSmsgReport     */
# include "OMminimum.h"     /* <I>GR...         */
# include "igetypedef.h"    /* <I>GR...         */
# include "igrtypedef.h"    /* <I>GR...         */
# include "madef.h"         /* <I>GR...         */
# include "godef.h"         /* <I>GR...         */
# include "gr.h"            /* <I>GR...         */
# include "igr.h"           /* <I>GR...         */
# include "igrdp.h"         /* <I>GR...         */
# include "go.h"            /* <I>GR...         */
#include "malnpspro.h"

/*
  HISTORY

       Sudha   25-Jun-93       Modified for BSprototype ansification
*/

# define BUFFER_SIZE 100

void EFrltKeyPt(surf, rlt, boreline, keypoint, key_parm, distance_squared,
                EMmsg)

struct IGRbsp_surface   *surf;
struct IGResqbs         *rlt;
struct IGRline          *boreline;
IGRpoint                keypoint;
struct GRparms          *key_parm;
IGRdouble               *distance_squared;
IGRlong                 *EMmsg;
{
  IGRint        num_points,
                buffer_size;
  IGRdouble     uvbuffer[2 * BUFFER_SIZE],
                xyzbuffer[3 * BUFFER_SIZE],
                my_distance_squared,
                *uv_points, *xyz_points;

  void EFrltEndPts();

  /*
   * Initialize
   */
  *EMmsg = MSSUCC;
  buffer_size = BUFFER_SIZE;
  num_points = 0;
  uv_points = uvbuffer;
  xyz_points = xyzbuffer;

  if(rlt->u_rules || rlt->v_rules)
  {
    /*
     * Get the endpoints
     */
    EFrltEndPts(EMmsg, surf, rlt, uvbuffer, xyzbuffer, buffer_size,
                &num_points, &uv_points, &xyz_points);
    if(! (1 & *EMmsg)) goto wrapup;

    /*
     * Find the endpoint closest to the boreline
     */
    if(num_points)
    {
      IGRlong               rc;
      IGRlong               pt_index;
      IGRdouble             t_parm;
      IGRpoint              pt_on_line, project_pt;
      struct IGRpointset    point_set;

      /*
       * Find the closest point
       */
      point_set.num_points = num_points;
      point_set.points = xyz_points;
      (void) MAlnpsproj(&rc, boreline, &point_set, pt_on_line, project_pt,
                        &t_parm, &pt_index);

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
        IGRint  index;

        pt_index --;
        index = pt_index * 2;
        key_parm->u = uv_points[index ++];
        key_parm->v = uv_points[index];
        index = pt_index * 3;
        keypoint[0] = xyz_points[index ++];
        keypoint[1] = xyz_points[index ++];
        keypoint[2] = xyz_points[index];
        *distance_squared = my_distance_squared;
      }

    } /* if num_points */
    else { *EMmsg = EMS_E_Fail; goto wrapup; }

  } /* if there are rule lines */

wrapup:
  if(uv_points ISNT uvbuffer) om$dealloc (ptr = uv_points);
  if(xyz_points ISNT xyzbuffer) om$dealloc (ptr = xyz_points);
  EMSmsgReport(*EMmsg, "EMSgradata.EMkeypoint", FALSE);
}
