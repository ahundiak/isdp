/*
 * Description
 *    This function returns the point and u parameter at a given distance from
 *    one end of a curve.
 *
 * Arguments
 *    struct GRid   GRid_in     object id and osnum of the input curve.
 *    IGRint        endflag     flag telling which end to calculate the
 *                              distance from. 0 - start point.  1 - end point.
 *    IGRpoint      dirpoint    direction point used in closed curves case.
 *    IGRint        num         number of distance's given.
 *    IGRdouble     *dist       array of input distances.
 *    IGRdouble     *uparm      output -- array of u values.
 *                              NULL if not needed, else memory pointer.
 *    IGRdouble     *out_point  output -- array of points. NULL if not needed,
 *                              else memory pointer.
 *    struct GRid   *cmp_id     output -- array of component id's. Useful if 
 *                              input object was a composite curve. NULL if not
 *                              needed, else a memory pointer.
 *
 * Notes
 *    If used, memory needs to be allocated for the following like so:
 *      uparm = (IGRdouble *) om$malloc(size = sizeof(IGRdouble) * num);
 *      out_point = (IGRdouble *) om$malloc(size = sizeof(IGRdouble)*num*3);
 *      cmp_id = (struct GRid *) om$malloc(size = sizeof(struct GRid) * num);
 *
 * History
 *    dhm    11/01/91    creation date
 *    dhm    11/24/91    changed to handle an input array
 */

class implementation GRcurve;

#include <stdio.h>
#include "OMminimum.h"
#include "OMmacros.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "OMminimum.h"
#include "OMlimits.h"
#include "exdef.h"
#include "ex.h"
#include "godef.h"
#include "go.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"

int GRpoint_along_curve(GRid_in, endflag, dirpoint, num, dist, uparm,
                        out_point, cmp_id)
struct GRid   GRid_in;
IGRint        endflag;
IGRpoint      dirpoint;
IGRint        num;
IGRdouble     *dist;
IGRdouble     *uparm;
IGRdouble     *out_point;
struct GRid   *cmp_id;
{

  IGRlong   status, msg;
  IGRint    i;
  IGRpoint  startpoint, endpoint, point, outpoint, prjpoint, dpnt;
  struct GRparms   epar, dpar, prjpar;
  struct GRmd_env  md_env;

  status = OM_S_SUCCESS;

  gr$get_module_env(buffer = &md_env);

  /*
   * Get the endpoints of the curve.
   */

  status = om$send(msg = message GRcurve.GRendpts(&msg,
                         &md_env.md_env.matrix_type, md_env.md_env.matrix,
                         startpoint, endpoint),
                   senderid = NULL_OBJID,
                   targetid = GRid_in.objid,
                   targetos = GRid_in.osnum);
  if ( !(1&status) )
  {
    printf("\n GRcurve.GRendpts failed in GRptalongcv.I \n");
    goto quit;
  }

  /*
   * See which end point to take the distance from.
   */

  if (endflag) /* end of curve */
  {
    epar.u = 1.0;
    OM_BLOCK_MOVE( endpoint, point, sizeof(IGRdouble)*3 );
  }
  else   /* start of curve */
  {
    epar.u = 0.0;
    OM_BLOCK_MOVE( startpoint, point, sizeof(IGRdouble)*3 );
  }

  /*
   * Get the u parameter value of the direction point to pass to the
   * GRptalong method.
   */

  status = om$send(msg = message GRgraphics.GRptproject(&msg,
                         &md_env.md_env.matrix_type, md_env.md_env.matrix,
                         dirpoint, dpnt, &dpar),
                   senderid = NULL_OBJID,
                   targetid = GRid_in.objid,
                   targetos = GRid_in.osnum);
  if ( !(1&status) )
  {
    printf("\n GRgraphics.GRptproject failed in GRptalongcv.I \n");
    goto quit;
  }

  for (i = 0; i < num; i++)
  {
    /*
     * Get the point that is input distance from one end of the curve.
     */

    status = om$send(msg = message GRcurve.GRptalong(&msg,
                           &md_env.md_env.matrix_type, md_env.md_env.matrix,
                           point, dpnt, &epar, &dpar, &dist[i], outpoint),
                     senderid = NULL_OBJID,
                     targetid = GRid_in.objid,
                     targetos = GRid_in.osnum);
    if ( !(1&status) )
    {
      printf("\n GRcurve.GRptalong failed in GRptalongcv.I \n");
      goto quit;
    }

    /*
     * Get the output point's u value.
     */

    status = om$send(msg = message GRgraphics.GRptproject(&msg, 
                           &md_env.md_env.matrix_type, md_env.md_env.matrix,
                           outpoint, prjpoint, &prjpar),
                     senderid = NULL_OBJID,
                     targetid = GRid_in.objid,
                     targetos = GRid_in.osnum);
    if ( !(1&status) )
    {
      printf("\n GRgraphics.GRptproject failed in GRptalongcv.I \n");
      goto quit;
    }

    if (uparm)
      uparm[i] = prjpar.u;

    if (out_point)
    {
      out_point[i*3] = prjpoint[0];
      out_point[(i*3)+1] = prjpoint[1];
      out_point[(i*3)+2] = prjpoint[2];
    }

    if (cmp_id)
    {
      cmp_id[i].objid = prjpar.leaf_id.objid;
      cmp_id[i].osnum = prjpar.leaf_id.osnum;
    }

  }  /* end for loop */

quit:
  return(status);

}

end implementation GRcurve;
