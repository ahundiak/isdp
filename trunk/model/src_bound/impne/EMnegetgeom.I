class implementation EMSnatedge;

#include "emsmacros.h"                  /* for EMWRAPUP */
#include "bstypes.h"                    /* for BSrc */
#include "bserr.h"                              /* for BSSUCC */
#include "bsunwght_p.h"
#include "bsrev_cv.h"
#include "bspartofcv.h"
#include "bsconstprcv.h"

method EMget_bcxyz_geom (
  IGRlong               *EMmsg;
  struct GRmdenv_info   *mdenv;
  struct GRid           *srf_id;
  struct IGRbsp_surface *srf_geom;
  IGRint                from_spaninx;
  IGRint                num_spans;
  IGRboolean            reverse;
  struct EMSpartedinfo  *partinfo;
  struct IGRbsp_curve   *curve)

/*
 BUGS
        Currently the reverse, num_spns and spaninx is not
        supported for a natural edge.

History  
        RC      05/04/87  Creation Date
        RC      11/03/87  Modified for version 1.1.0
        RC      03/16/88  Added code to check if the
                          partedge is degenerate.
        SS      05/12/88  If order=2 and rational the xyz-curve's poles
                          are unweighted and the curve made non-rational.
	SS	05/19/88  Removed code to check if the
                          partedge is degenerate. 
        Sudha   06/04/93  modified to include BSprototype header files

*/

{
    IGRboolean		    inweights_malloced;
    IGRdouble               uv, beg_par, mid_par, end_par;

    IGRlong                 OM_stat;
IGRlong   mthd_stat;
    BSrc                    rc;
    IGRushort       ed_props;
    IGRshort                option, num_poles, order;

    struct IGRbsp_surface   *surface;

    struct IGRbsp_curve     *nat_crv, temp_crv;

    IGRboolean              status, tst_planar;
    GRobjid                 user_id;
        
  
    *EMmsg = EMS_S_Success;
    OM_stat = OM_S_SUCCESS;

    nat_crv = NULL;
    temp_crv.poles = temp_crv.knots = temp_crv.weights = NULL;
    if (curve->weights)
      inweights_malloced = TRUE;
    else
      inweights_malloced = FALSE;

    surface = srf_geom;
    if (partinfo) user_id = partinfo->edid;
    else user_id = my_id;

    /*
     * find out if the surface is passed along
     */

    if (!surface )
    {
      struct GRid loc_srfid;

      if (!srf_id)
      {
        OM_stat = om$send (msg = message EMSboundary.EMgetsurface_info 
                   (&mthd_stat, &loc_srfid.objid, NULL), 
                   targetid = user_id);
        EMerr_hndlr (EMSerror (OM_stat & mthd_stat), *EMmsg, 
         EMS_E_EdgeError, wrapup);
        loc_srfid.osnum = OM_Gw_current_OS;
      }
      else
      {
        loc_srfid = *srf_id;
      }

      OM_stat = EMgetvggeom (&mthd_stat, &mdenv->matrix_type,
                 mdenv->matrix, &loc_srfid, &surface, NULL);
      EMerr_hndlr (EMSerror (OM_stat & mthd_stat), *EMmsg, 
       EMS_E_SurfaceError, wrapup);
    } /* if (!surface ) */

    if (!partinfo)
         nat_crv = curve;
    else
         nat_crv = &temp_crv;

    switch (ME.EMSnatedge->location & 0x3)
    {

      case 0:
        option = 1;
        uv = 0;
        break;

      case 1:
        option = 2;
        uv = 1;
        break;

      case 2:
        option = 1;
        uv = 1;
        break;

      case 3:
        option = 2;
        uv = 0;
        break;

     default:
       *EMmsg = EMS_E_InvalidArg;
       goto wrapup;

    } /* switch (ME.EMSnatedge->location & 0x3) */

    if ( option == 1)
    {
       num_poles = surface->v_num_poles;
       order = surface->v_order;
    }
    else
    {
       num_poles = surface->u_num_poles;
       order = surface->u_order;
    }

    if (!nat_crv->poles)
    {
       nat_crv->poles = (IGRdouble *) om$malloc(size=(int) num_poles *
                                                sizeof(IGRpoint));
       EMerr_hndlr(!nat_crv->poles,*EMmsg,EMS_E_NoDynamicMemory,wrapup);
    }

    if (!nat_crv->knots)
    {
       nat_crv->knots =  (IGRdouble *) om$malloc (size = (int) 
                                 (num_poles + order) * sizeof(IGRdouble));
       EMerr_hndlr(!nat_crv->knots,*EMmsg,EMS_E_NoDynamicMemory,wrapup);
    }

    if (surface->rational)
    {
     if (!nat_crv->weights)
     {
      nat_crv->weights = (IGRdouble *) om$malloc (size = (int) 
                                     num_poles * sizeof(IGRdouble));
      EMerr_hndlr(!nat_crv->weights,*EMmsg,EMS_E_NoDynamicMemory,wrapup);
     }
    }
    else nat_crv->weights = NULL;
 
    /* 
     * extract b_spline curve from the surface
     */

    tst_planar = TRUE;
    status = BSconstprcv (&rc, surface, &option, &uv, &tst_planar, 
                          nat_crv);
    EMerr_hndlr (!status || rc!=BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);
    if(ME.EMSedge->ed_props & EMED_XYZ_CLOSED)        
     nat_crv->phy_closed = TRUE;

    /*
     * EDGEU1 and EDGEV0 will have their
     * geometry reversed (poles will be placed
     * reversed to the edge direction). Therefore,
     * in order to have the geometry in the
     * direction of the edge, the poles, knots and weights
     * are reversed
     */

    if (((ME.EMSnatedge->location & 0x3) == 2) ||
        ((ME.EMSnatedge->location & 0x3) == 3))
    {
       status = BSrev_cv (&rc, nat_crv);
       EMerr_hndlr (!status || rc!=BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);
           
    }

    /*
     * In case of a partedge, extract the partial geometry
     * from the natural edge geometry.
     */
        
    if (partinfo)
    {
       IGRlong ped_num_poles;

       beg_par = partinfo->edbdry[0].param;
       end_par = partinfo->edbdry[1].param;

       if (nat_crv->phy_closed)  mid_par = (beg_par + end_par)/2.0;
       else mid_par = 0.0;

       ped_num_poles = num_poles + 2*order - 1;

       if (!curve->poles)
       {
         curve->poles = (IGRdouble *) om$malloc(size =
                              ped_num_poles * sizeof(IGRpoint));
         EMerr_hndlr(!curve->poles,*EMmsg,EMS_E_NoDynamicMemory,wrapup);
       }

       if (!curve->knots)
       {
          curve->knots =  (IGRdouble *) om$malloc (size =  
                 (ped_num_poles + order) * sizeof(IGRdouble));
          EMerr_hndlr(!curve->knots,*EMmsg,EMS_E_NoDynamicMemory,wrapup);
       }

       if (surface->rational)
       {
        if (!curve->weights)
        {
         curve->weights = (IGRdouble *) om$malloc (size = 
                                      ped_num_poles * sizeof(IGRdouble));
         EMerr_hndlr(!curve->weights,*EMmsg,EMS_E_NoDynamicMemory,wrapup);
        }
       }
       else curve->weights = NULL;

       status = BSpartofcv (&rc, nat_crv, beg_par, mid_par, end_par, 
                             curve);
       EMerr_hndlr (!status || rc != BSSUCC, *EMmsg,EMS_E_BSerror,wrapup);

    } /* if (partinfo) */

    else nat_crv = NULL;


   if (curve->rational && curve->order == 2)
      {
      /*
       * Some of the methods in the IGE-system do not take kindly
       * to having an order-2 curve which is rational. So change the
       * curve to non-rational.
       */
      
      BSunwght_p (&rc, curve->poles, curve->weights, &curve->num_poles,
       curve->poles);
      if (! inweights_malloced)
       om$dealloc (ptr = curve->weights);
      curve->weights = NULL;
      curve->rational = FALSE;
      }

  /*
   * There was code here that was checking for degeneracy in
   * model-space. Removed it (found below) and replaced it with the 
   * reliance on the property bit.
   */

  if (partinfo)
    ed_props = partinfo->edprops;
  else
    ed_props = ME.EMSedge->ed_props;

  if (ed_props & EMED_DEGENERATE)
    *EMmsg = EMS_I_DegenerateEdge;

wrapup:
  if (!srf_geom) om$dealloc (ptr = surface);
  if (nat_crv)
  {
    if (nat_crv->poles) om$dealloc (ptr = nat_crv->poles);
    if (nat_crv->knots) om$dealloc (ptr = nat_crv->knots);
    if (nat_crv->weights) om$dealloc (ptr = nat_crv->weights);
  }

  EMWRAPUP (*EMmsg, OM_stat, "In EMSnatedge.EMget_bcxyz_geom")
 
 return (OM_stat);

}

end implementation EMSnatedge;




/*
  Piece of code removed from above. Left verbatim, except for
  the forward slahes.

    *
     * It may be possible that part of natural edge is
     * degenerate in model space but is not flagged so.
     *

   if (partinfo)
   {
     OM_stat = om$send (msg = message EMSedge.EMget_props (&mthd_stat,
                         &ed_props),
                        targetid = user_id);
     EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_EdgeError,wrapup);

     if (!(ed_props & EMED_DEGENERATE))
     {
       OM_stat = EMmake_chanselect (EMSedge_to_common_edge, &cm_ed_chan);
       EMerr_hndlr (!(1&OM_stat),*EMmsg, EMS_E_OMerror, wrapup);

       OM_stat = om$get_channel_count (objid = user_id,  
                      p_chanselect = &cm_ed_chan, count = &num_cm_ed);
       EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

       if (!num_cm_ed)
       {
         (void) BStstcvdegn (curve, &is_degn, &rc);
          EMerr_hndlr (rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
         if (is_degn)
         {
          
           *EMmsg = EMS_I_DegenerateEdge;

          } * if (is_degn) *
     
        } * if (!num_cm_ed) *

     } * if (!(ed_props & EMED_DEGENERATE)) *

   } * if (partinfo) *

*/
