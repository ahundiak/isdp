/* ###################   APOGEE COMPILED   ################## */

/*
   History

         Sudha 06/04/93          modified to include BSprototype header files
         SM    07/30/93          Fixed a junk read beyond array bound
                                 introduced during the bsprototype (mis)usage.
                                 See the variable 'xyz'.
       Sampath 08/30/93          Added code to weed out duplicate poles to
                                 avoid wrong 'tangent' generation.
         NP    01/24/94          Previous checking was creating invalid geometry
                                 by not updating knots and weights. Retricted 
                                 removal of poles to order 2 curves ONLY. For 
                                 higher order, curve shape could change and 
                                 hence the tangent.
                                 MODIFICATION TO BE DONE: Use local variables if
                                 incoming edge geometry is modified. 
                 

*/

class implementation EMSedge;

#include "EMS.h"
#include "emsmacros.h"
#include "emserr.h"
#include "bserr.h"
#include "bsmdstptcv.h"
#include "bscvarrevt.h"
#include "bsrmdblpts.h"
#include "bslininter.h"

method EMtangent (IGRlong              *EMmsg;
                 struct GRmd_env       *my_env;
                 GRobjid               *my_surf_id;
                 IGRpoint              loc_pnt;
                 IGRdouble             disp_fac;
                 struct IGRbsp_curve   *my_geom;
                 IGRvector             tangent)
{
  IGRlong              stat_OM, msg;
  IGRint               i, num_parm, num_pts;
  IGRdouble            parm, dist;
  IGRpoint             base_point, xyz[1][2];
  struct GRid          surf_GRid;
  struct IGRbsp_curve  *edge_geom,
                       my_edge_geom;
  IGRdouble            *newpoles;
  IGRshort             newnum;
  IGRboolean           status;
  IGRvector            nvec;
  BSrc                 rc;

  *EMmsg = EMS_S_Success;
  stat_OM = OM_S_SUCCESS;
  newpoles = NULL;

  if (! my_surf_id)
   {
    stat_OM = om$send(msg = message EMSboundary.EMgetsurface_info
                            (&msg ,my_surf_id, NULL),
                      targetid = my_id);
    EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);
   }

  if (my_geom)
     edge_geom = my_geom;
  
  else
   {
    surf_GRid.objid = *my_surf_id;
    surf_GRid.osnum = OM_Gw_current_OS;

    my_edge_geom.weights = NULL;
    my_edge_geom.poles = NULL;
    my_edge_geom.knots = NULL;
    my_edge_geom.bdrys = NULL;

    stat_OM = om$send(msg = message EMSedge.EMget_bcxyz_geom(&msg,
                            &my_env->md_env, &surf_GRid, NULL, 0,
                            OM_K_MAXINT,
                            FALSE, NULL, &my_edge_geom),
                      targetid = my_id);
    EMerr_hndlr(! (1 & stat_OM & msg), *EMmsg, EMS_E_EdgeError, wrapup);
    edge_geom = &my_edge_geom;
   }

  BSmdstptcv(edge_geom, loc_pnt, &parm, base_point, &dist, &msg);
  EMerr_hndlr (msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

  /* Weed out ONLY if order is 2. If order is higher, there is verly little 
   * likelihood of duplicate poles, since we dont refine BSedges. Therefore, the
   * problem is probably limited to order 2 line strings. Secondly, it is always
   * a bad idea to modify input that is NOT also the output. Here we change the
   * input geometry, possibly. Not a good idea. Use local geometry to handle
   * this sometime later, after 3.0 goes out. Added missing error checks also.
   * Also, knots,  weights etc. had NOT been adjusted after removing poles.
   * (NP 1/24/93).
   */
  if (edge_geom->order == 2)
  {
   /* Code to weed out duplicate poles which cause wrong 'tangent' generation */
    newpoles = (IGRdouble *) om$malloc(size = edge_geom->num_poles *
                   sizeof(IGRpoint));
    BSrmdblpts(&rc,(IGRshort ) edge_geom->num_poles, 
                    (IGRpoint *) edge_geom->poles,
                    &newnum, (IGRpoint *) newpoles);
    EMerr_hndlr (rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

    num_pts = newnum; /* explicitly done to avoid casting problems*/

    /* recreate edge geometry */
    status = BSlininter( &rc, &num_pts, newpoles, edge_geom, nvec);
    EMerr_hndlr (!status || (rc != BSSUCC), *EMmsg, EMS_E_BSerror, wrapup);
  }
 
  num_parm = 1;
  BScvarrevt(edge_geom, &parm, num_parm, disp_fac, xyz, &msg);
  EMerr_hndlr(msg != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

  for (i=0; i<3; i++)
       tangent[i] = xyz[0][1][i] - xyz[0][0][i];

wrapup:
  if (! my_geom)
   {
    if (my_edge_geom.weights) om$dealloc (ptr = my_edge_geom.weights);
    my_edge_geom.weights = NULL;
    if (my_edge_geom.poles) om$dealloc (ptr = my_edge_geom.poles);
    my_edge_geom.poles = NULL;
    if (my_edge_geom.knots) om$dealloc (ptr = my_edge_geom.knots);
    my_edge_geom.knots = NULL;
    if (my_edge_geom.bdrys) om$dealloc (ptr = my_edge_geom.bdrys);
    my_edge_geom.bdrys = NULL;

   }
  if (newpoles)
   om$dealloc (ptr = newpoles); 

  EMWRAPUP (*EMmsg, stat_OM, "EMSedge.EMtangent");
  return (stat_OM);
}

end implementation EMSedge;
