/* ###################   APOGEE COMPILED   ################## */
/*
History

    08/11/88	RV	Creation.
    21-Sep-88   SM	Tested and fixed some bugs before putting into the
			system.
    04-Feb-89	SM	If no partinfo is input, edge reversed property was
			not being considered. Fixed it. If partinfo is
			passed in, edge reversal is implicit in partedge
			bounds.    
    07/06/93    Sudha   modified for BSprototype includes
Notes 

*/
class implementation EMSlinedge;

#include "EMS.h"
#include "emsmacros.h"                  /* for EMWRAPUP */
#include "bstypes.h"                    /* for BSrc */
#include "bserr.h"                      /* for BSSUCC */
%safe
#include <math.h>			/* fabs	*/
#include "bsunwght_p.h"
#include "bsrev_cv.h"
#include "bspartofcv.h"
#include "bsconstprcv.h"
%endsafe

#define CONSTANT_U	1
#define CONSTANT_V	2

method EMget_iso_geom (
  IGRlong               *EMmsg;
  struct GRmdenv_info   *mdenv;
  struct GRid           *srf_id;
  struct IGRbsp_surface *srf_geom;
  IGRboolean            reverse;
  struct EMSpartedinfo  *partinfo;
  struct IGRbsp_curve   *curve)

{
    IGRboolean		    reversal,  whole_iso, inweights_malloced;
    IGRdouble               iso_par, beg_par, mid_par, end_par, temp_par;

    IGRlong                 OM_stat;
IGRlong   mthd_stat;
    BSrc                    rc;
    IGRushort       ed_props;
    IGRshort                option, num_poles, order;

    struct IGRbsp_surface   *surface;

    struct IGRbsp_curve     *iso_crv, *edg_crv, temp_crv1,  temp_crv2;

    IGRboolean              status, tst_planar;
    GRobjid                 user_id;
        
  
    *EMmsg = EMS_S_Success;
    OM_stat = OM_S_SUCCESS;

    if (curve->weights)
      inweights_malloced = TRUE;
    else
      inweights_malloced = FALSE;

    iso_crv = edg_crv = NULL;
    temp_crv1.poles = temp_crv1.knots = temp_crv1.weights = NULL;
    temp_crv2.poles = temp_crv2.knots = temp_crv2.weights = NULL;

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

    reversal = FALSE;
    if (fabs(ME.EMSlinedge->points[0] - ME.EMSlinedge->points[2]) <
        fabs(ME.EMSlinedge->points[1] - ME.EMSlinedge->points[3]))
    {
       option = CONSTANT_U;
       iso_par = (ME.EMSlinedge->points[0] + ME.EMSlinedge->points[2])/2;
       beg_par = ME.EMSlinedge->points[1];
       end_par = ME.EMSlinedge->points[3];
    }
    else
    {
       option = CONSTANT_V;
       iso_par = (ME.EMSlinedge->points[1] + ME.EMSlinedge->points[3])/2;
       beg_par = ME.EMSlinedge->points[0];
       end_par = ME.EMSlinedge->points[2];
    }
    if (beg_par > end_par)
    {
      temp_par = beg_par;
      beg_par = end_par;
      end_par = temp_par;
      reversal = !reversal;
    }

    if (beg_par != 0.0 || end_par != 1.0)  whole_iso = FALSE;
    else whole_iso = TRUE;

    if (!partinfo && whole_iso) iso_crv = curve;
    else  iso_crv = &temp_crv1;

    if ( option == CONSTANT_U)
    {
       num_poles = surface->v_num_poles;
       order = surface->v_order;
    }
    else
    {
       num_poles = surface->u_num_poles;
       order = surface->u_order;
    }

    if (!iso_crv->poles)
    {
       iso_crv->poles = (IGRdouble *) om$malloc(size=(int) num_poles *
                                                sizeof(IGRpoint));
       EMerr_hndlr(!iso_crv->poles,*EMmsg,EMS_E_NoDynamicMemory,wrapup);
    }

    if (!iso_crv->knots)
    {
       iso_crv->knots =  (IGRdouble *) om$malloc (size = (int) 
                                 (num_poles + order) * sizeof(IGRdouble));
       EMerr_hndlr(!iso_crv->knots,*EMmsg,EMS_E_NoDynamicMemory,wrapup);
    }

    if (surface->rational)
    {
     if (!iso_crv->weights)
     {
      iso_crv->weights = (IGRdouble *) om$malloc (size = (int) 
                                     num_poles * sizeof(IGRdouble));
      EMerr_hndlr(!iso_crv->weights,*EMmsg,EMS_E_NoDynamicMemory,wrapup);
     }
    }
    else iso_crv->weights = NULL;
 
    /* 
     * extract b_spline curve from the surface
     */

    tst_planar = TRUE;
    status = BSconstprcv (&rc, surface, &option, &iso_par, &tst_planar, 
                          iso_crv);
    EMerr_hndlr (!status || rc!=BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);
        

    /*
     * extract part of the iso curve if required.
     */

     if (!whole_iso)
     {
       edg_crv = partinfo ? &temp_crv2 : curve;        

       if (iso_crv->phy_closed)  mid_par = (beg_par + end_par)/2.0;
       else mid_par = 0.0;

       num_poles = num_poles + 2*order - 1;

       if (!edg_crv->poles)
       {
         edg_crv->poles = (IGRdouble *) om$malloc(size =
                              num_poles * sizeof(IGRpoint));
         EMerr_hndlr(!edg_crv->poles,*EMmsg,EMS_E_NoDynamicMemory,wrapup);
       }

       if (!edg_crv->knots)
       {
          edg_crv->knots =  (IGRdouble *) om$malloc (size =  
                 (num_poles + order) * sizeof(IGRdouble));
          EMerr_hndlr(!edg_crv->knots,*EMmsg,EMS_E_NoDynamicMemory,wrapup);
       }

       if (surface->rational)
       {
        if (!edg_crv->weights)
        {
         edg_crv->weights = (IGRdouble *) om$malloc (size = 
                                      num_poles * sizeof(IGRdouble));
         EMerr_hndlr(!edg_crv->weights,*EMmsg,EMS_E_NoDynamicMemory,wrapup);
        }
       }
       else edg_crv->weights = NULL;

       status = BSpartofcv (&rc, iso_crv, beg_par, mid_par, end_par, 
                             edg_crv);
       EMerr_hndlr (!status || rc != BSSUCC, *EMmsg,EMS_E_BSerror,wrapup);

     }
     else edg_crv = iso_crv;

    /*
     * In case of a partedge, extract the partial geometry
     * from the iso edge geometry.
     */
        
    if (partinfo)
    {
       beg_par = partinfo->edbdry[0].param;
       end_par = partinfo->edbdry[1].param;

       if(reversal)
        {
	 beg_par = 1.0 - beg_par;
	 end_par = 1.0 - end_par;
	 reversal = !reversal;
        }

       if (beg_par > end_par)
       {
         temp_par = beg_par;
         beg_par = end_par;
         end_par = temp_par;
         reversal = !reversal;
       }

       if (iso_crv->phy_closed)  mid_par = (beg_par + end_par)/2.0;
       else mid_par = 0.0;

       num_poles = num_poles + 2*order - 1;

       if (!curve->poles)
       {
         curve->poles = (IGRdouble *) om$malloc(size =
                              num_poles * sizeof(IGRpoint));
         EMerr_hndlr(!curve->poles,*EMmsg,EMS_E_NoDynamicMemory,wrapup);
       }

       if (!curve->knots)
       {
          curve->knots =  (IGRdouble *) om$malloc (size =  
                 (num_poles + order) * sizeof(IGRdouble));
          EMerr_hndlr(!curve->knots,*EMmsg,EMS_E_NoDynamicMemory,wrapup);
       }

       if (surface->rational)
       {
        if (!curve->weights)
        {
         curve->weights = (IGRdouble *) om$malloc (size = 
                                      num_poles * sizeof(IGRdouble));
         EMerr_hndlr(!curve->weights,*EMmsg,EMS_E_NoDynamicMemory,wrapup);
        }
       }
       else curve->weights = NULL;

       status = BSpartofcv (&rc, edg_crv, beg_par, mid_par, end_par, 
                             curve);
       EMerr_hndlr (!status || rc != BSSUCC, *EMmsg,EMS_E_BSerror,wrapup);

    } /* if (partinfo) */

   else if(ME.EMSedge->ed_props & EMED_REVERSED)
      reversal = !reversal;

    if (curve->rational && curve->order == 2)
      {
      /*
       * Some of the methods in the IGE-system do not take kindly
       * to having an order-2 curve which is rational. So change the
       * curve to non-rational.
       */
      
      BSunwght_p (&rc, curve->poles, curve->weights, &curve->num_poles,
       curve->poles);
      if (!inweights_malloced)
       om$dealloc (ptr = curve->weights);
      curve->weights = NULL;
      curve->rational = FALSE;
      }

      if (reverse) reversal = !reversal;

      if (reversal)
      {
        status = BSrev_cv (&rc, curve);
        EMerr_hndlr (!status || rc!=BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);
      }

  if (partinfo)
    ed_props = partinfo->edprops;
  else
    ed_props = ME.EMSedge->ed_props;

  if (ed_props & EMED_DEGENERATE)
    {
    if (curve->rational && curve->weights)
      {
      BSunwght_p (&rc, curve->poles, curve->weights, &curve->num_poles,
       curve->poles);
      if (!inweights_malloced)
        {
        om$dealloc (ptr = curve->weights);
        curve->weights = NULL;
        }
      }
      curve->periodic = FALSE;
      curve->non_uniform = FALSE;
      curve->order = 2;
      curve->num_poles = 2;
      curve->num_knots = 4;
      curve->knots[0] = curve->knots[1] = 0.0;
      curve->knots[2] = curve->knots[3] = 1.0;
      curve->rational = FALSE;
      curve->planar = TRUE;
      curve->phy_closed = TRUE;
    *EMmsg = EMS_I_DegenerateEdge;
    }

wrapup:

  if (!srf_geom && surface) om$dealloc (ptr = surface);

  if (temp_crv1.poles) om$dealloc (ptr = temp_crv1.poles);
  if (temp_crv1.knots) om$dealloc (ptr = temp_crv1.knots);
  if (temp_crv1.weights) om$dealloc (ptr = temp_crv1.weights);

  if (temp_crv2.poles) om$dealloc (ptr = temp_crv2.poles);
  if (temp_crv2.knots) om$dealloc (ptr = temp_crv2.knots);
  if (temp_crv2.weights) om$dealloc (ptr = temp_crv2.weights);

  EMWRAPUP (*EMmsg, OM_stat, "In EMSlinedge.EMget_iso_geom")
 
 return (OM_stat);

}

end implementation EMSlinedge;

