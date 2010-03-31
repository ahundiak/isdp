/*
 * Description
 *    Given a u,v parameter pair, this function returns the model space point,
 *    tangent vector, curvature as indicated by type_flag, and the point
 *    location information on a given surface.
 *
 * Arguments
 *    struct GRid   GRid_in     objid and osnum of the input surface.
 *    IGRdouble     parm_pnt[2] input u,v parameter pair on the surface.
 *    IGRpoint      outpoint    output model space point. NULL if not needed.
 *    IGRvector     tan[2]      output tangent vector at uparm and vparm.
 *                              tan[0] = tangent vector in u direction.
 *                              tan[1] = tangent vector in v direction.
 *                              NULL if not needed.
 *    unsigned int  crv_type    input type of curvature desired.
 *                              0 - radius of curvature (inverse of principal
 *                                  max curvature)
 *                              1 - Gaussian curvature
 *                              2 - Mean
 *                              3 - Principal max
 *                              4 - Principal min
 *                              5 - Absolute
 *    IGRdouble     *crv        output curvature value at uparm, vparm.
 *                              NULL if not needed.
 *    IGRint        *pt_location_flag   output flag to indicate if given point
 *                                      is in the "solid" or "hole" portion or
 *                                      on the boundary. NULL if not needed.
 *                                      Returned values are:
 *                                      EMS_L_ONEDGE
 *                                      EMS_L_ONVRTX   (defined in 
 *                                      EMS_L_INAREA    EMSbnddef.h)
 *                                      EMS_L_INHOLE
 *                                      EMS_L_UNKNWN
 *    IGRshort      *num_edges  output number of edges closest to the input
 *                              point on the surface.  NULL if not needed.
 *    GRobjid       *edge_id    output objid(s) of the nearest edge(s) to the
 *                              input point on the surface. NULL if not needed.
 *                              If specified, then num_edges must be specified.
 *                              Alloc memory as follows:
 *                                edge_id[MAX_LOCATED_EDGES] (defined in
 *                                                            EMSbnddef.h)
 *    IGRdouble     near_pt[][2] output u,v pair(s) of the projected point on 
 *                               the nearest edge(s).  NULL if not needed.
 *                               If specified, num_edges must be specified.
 *                               Alloc memory as follows:
 *                                 near_pt[MAX_LOCATED_EDGES]
 * History
 *    dhm    11/06/91    creation date.
 */

class implementation EMSsubbs;

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
#include "EMSbnddef.h"
#include "EMSopt.h"
#include "EMSbnd.h"

#define MAXRAD  1e+300

from EMSloopset import EMpt_location;

int MDget_surf_tan_crv_ptloc(GRid_in, parm_pnt, outpoint, tan, crv_type,
                             crv, pt_location_flag, num_edges, edge_id,
                             near_pt)
struct GRid      GRid_in;
IGRdouble        parm_pnt[2];
IGRpoint         outpoint;
IGRvector        tan[2];
IGRuint  crv_type;
IGRdouble        *crv;
IGRint           *pt_location_flag;
IGRint           *num_edges;
GRobjid          *edge_id;
IGRdouble        near_pt[][2];
{

  IGRlong    status, msg;
  IGRint     i;
  IGRpoint   poly[3];
  struct GRmd_env   md_env;
  struct EMSptloc_info  loc;
  struct EMSpartolbasis ptb;

  status = OM_S_SUCCESS;

  gr$get_module_env(buffer = &md_env);

  /*
   * Return the point at the input u,v parameter pair.
   */

  if (outpoint)
  {
    status = om$send(msg = message EMSsubbs.EMptatpr(&msg,
                           &md_env.md_env.matrix_type, md_env.md_env.matrix,
                           parm_pnt, 2, outpoint),
                     senderid = NULL_OBJID,
                     targetid = GRid_in.objid,
                     targetos = GRid_in.osnum);
    if (!(1&status))
    {
      printf("\n EMSsubbs.EMpratpt failed in EMsftancrv.I \n");
      goto quit;
    }

  }

  /*
   * Get the tangent vector in the u and v directions.
   */

  if (tan)
  {
    status = om$send(msg = message EMSsubbs.EMsftanorm(&msg,
                           &md_env.md_env.matrix_type, md_env.md_env.matrix,
                           NULL, 1, &parm_pnt[0], 1, &parm_pnt[1], 1.0, NULL,
                           TRUE, FALSE, (IGRdouble *) poly, NULL),
                     senderid = NULL_OBJID,
                     targetid = GRid_in.objid,
                     targetos = GRid_in.osnum);
    if (!(1&status))
    {
      printf("\n EMSsubbs.EMsftanorm failed in EMsftancrv.I \n");
      goto quit;
    }

    tan[0][0] = poly[0][0] - poly[1][0];
    tan[0][1] = poly[0][1] - poly[1][1];
    tan[0][2] = poly[0][2] - poly[1][2];

    tan[1][0] = poly[2][0] - poly[1][0];
    tan[1][1] = poly[2][1] - poly[1][1];
    tan[1][2] = poly[2][2] - poly[1][2];
  }

  /*
   * Get the curvature value.
   */

  if (crv)
  {
    status = om$send(msg = message EMSsubbs.EMsfradcrv(&msg,
                           &md_env.md_env.matrix_type, md_env.md_env.matrix,
                           NULL, crv_type, 1, &parm_pnt[0], 1, &parm_pnt[1],
                           MAXRAD, crv, NULL, NULL),
                     senderid = NULL_OBJID,
                     targetid = GRid_in.objid,
                     targetos = GRid_in.osnum);
    if (!(1&status))
    {
      printf("\n EMSsubbs.EMsfradcrv failed in EMsftancrv.I \n");
      goto quit;
    }

  }

  /*
   * Get the point location information.
   */

  if ( pt_location_flag || num_edges )
  {
    loc.location = EMS_L_UNKNWN;
    loc.options = EMS_PTLOC_BOXCHECK || EMS_PTLOC_ACTLOOP ||
                  EMS_PTLOC_LS_INFINITE || EMS_PTLOC_USECHTTOL ||
                  EMS_PTLOC_CLOSEST_EDGE;

    ptb.is_valid = FALSE;
    ptb.in_world = TRUE;
    ptb.mattyp = &md_env.md_env.matrix_type;
    ptb.mat = md_env.md_env.matrix;

    status = om$send(msg = message EMSsubbs.EMpassloop(&msg, message
                           EMSloopset.EMpt_location(&msg, parm_pnt, &loc,
                           &ptb)),
                     senderid = NULL_OBJID,
                     targetid = GRid_in.objid,
                     targetos = GRid_in.osnum);
    if (status == OM_I_CHAN_EMPTY)
    {
      status = OM_S_SUCCESS;
      if ( pt_location_flag )  *pt_location_flag = EMS_L_UNKNWN;
      if ( num_edges )  *num_edges = 0;
      if ( edge_id )    edge_id[0] = NULL_OBJID;
      if ( near_pt )    near_pt[0][0] = -1;
      goto quit;
    }
    else if (! (1&status) )
    {
      printf("\n EMSloopset.EMpt_location failed in EMsftancrv.I \n");
      goto quit;
    }

    if ( pt_location_flag )
      *pt_location_flag = loc.location;

    if ( num_edges )
      *num_edges = loc.num_located_edges;

    if ( edge_id )
    {
      for ( i = 0; i < *num_edges; i++)
         edge_id[i] = loc.edge[i].edge_id;
    }

    if ( near_pt )
    {
      for ( i = 0; i < *num_edges; i++ )
      {
         near_pt[i][0] = loc.edge[i].nst_pt.proj_pt[0];
         near_pt[i][1] = loc.edge[i].nst_pt.proj_pt[1];
      }
    }

  }

quit:
  return(status);

}

end implementation EMSsubbs;
