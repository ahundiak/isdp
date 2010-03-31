class implementation EMSsubbs;

#include "EMS.h"
#include "bserr.h"
#include "emsedgedef.h"
#include "bssfkttol2.h"

/*
 History     
	RC    11/22/87    Creation Date
	Sudha 06/23/93    Modified for BSprototype ansification

 This function makes a pole at caller provided uv_pts if
 there is not one already existing.

*/

from EMSgenbs import EMinsktln;
from EMSboundary import EMtree_traverse;
from EMSedge   import   EMset_type;

extern OMuword     OPP_EMSedge_class_id;
extern double  fabs();

static void  EMinsert_knot(
   EMmsg,
   knots,
   num_knots,
   new_entry,
   knot_tol,
   is_decided)

IGRlong      *EMmsg;
IGRdouble    *knots, new_entry, knot_tol;
IGRint       *num_knots;
IGRboolean   *is_decided;

{
  IGRint         i;
  IGRboolean     entry_exists = FALSE;


  *EMmsg = EMS_S_Success;
  
  i = 0;

  while (i < *num_knots && !entry_exists)
  {
    if ( fabs(knots[i] - new_entry) <= knot_tol ) entry_exists = TRUE;
    i++;
  }

  if (!entry_exists)
    knots[(*num_knots)++] = new_entry;

  *is_decided = TRUE;

  return;

}

void EMmake_poles_on_surface (
   EMmsg,
   sf_GRid,
   sf_geom,
   md_env,
   uv_pts,
   num_uv_pts)

 IGRlong                  *EMmsg;
 struct  GRid             *sf_GRid;
 struct  IGRbsp_surface   *sf_geom;
 struct  GRmd_env         *md_env;
 IGRdouble                *uv_pts;
 IGRint                   num_uv_pts;

{
   struct   IGRbsp_surface   *surface;

   IGRdouble                 u_pt, v_pt, knot_tol, *sf_u_knots, 
                             *sf_v_knots, *u_knots, *v_knots;

   IGRlong                   OM_stat, mthd_stat, sf_size, u_num_poles,
                             v_num_poles;

   IGRint                    i, j, k, num_u_knots, num_v_knots;

   OMuint                    num_ls;

   IGRshort                  u_order, v_order;

   IGRboolean                is_decided;

   OM_S_CHANSELECT           sf_ls_chan;

  extern    IGRdouble                 fabs();

 
   *EMmsg = EMS_S_Success;
   OM_stat = OM_S_SUCCESS;
   
   surface = sf_geom;
   u_knots = NULL;
   v_knots = NULL;
   num_u_knots = num_v_knots = NULL;

   /*
    * Allocate the space for possible u_knots and v_knots
    * to be inserted
    */

   u_knots = (IGRdouble *) om$malloc (size = num_uv_pts * 
                                             sizeof(IGRdouble));
   EMerr_hndlr (!u_knots, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

   v_knots = (IGRdouble *) om$malloc (size = num_uv_pts * 
                                             sizeof(IGRdouble));
   EMerr_hndlr (!v_knots, *EMmsg, EMS_E_NoDynamicMemory, wrapup);

   /*
    * get the surface geomtery if it is not sent in
    */

   if (!surface)
   {
     OM_stat = om$send (msg = message GRvg.GRgetsize ( &mthd_stat,
                         &md_env->md_env.matrix_type,
                          md_env->md_env.matrix,
                         &sf_size),
                      senderid = NULL_OBJID, 
                      targetid = sf_GRid->objid, 
                      targetos = sf_GRid->osnum);
     EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);     
     surface = (struct IGRbsp_surface *) om$malloc (size = sf_size);
     EMerr_hndlr (!surface, *EMmsg, EMS_E_NoDynamicMemory,wrapup);

     OM_stat = om$send (msg = message GRvg.GRgetgeom (&mthd_stat,
                         &md_env->md_env.matrix_type,
                          md_env->md_env.matrix,
                         (IGRchar *) surface),
                      senderid = NULL_OBJID,
                      targetid = sf_GRid->objid, 
                      targetos = sf_GRid->osnum);
     EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

   } /* if (!surface) */

   BSsfkttol2 (surface->u_order, surface->v_order, surface->u_knots,
            surface->v_knots, surface->u_num_poles, surface->v_num_poles,
            surface->poles, surface->weights, &knot_tol, &mthd_stat);
   EMerr_hndlr (mthd_stat!=BSSUCC,*EMmsg,EMS_E_BSerror,wrapup);

   u_order = surface->u_order;
   u_num_poles = surface->u_num_poles;
   sf_u_knots = surface->u_knots;

   /*
    * check if there is a knot of multiplicity of oreder -1 
    * at u values.
    */

   for (i = 0; i < num_uv_pts; i++)
   {
      u_pt = uv_pts[2*i];
      is_decided = FALSE;
           
      if ( fabs(u_pt - sf_u_knots[u_order-1]) <= knot_tol   ||
           fabs(u_pt - sf_u_knots[u_num_poles]) <= knot_tol)

        is_decided = TRUE;
        
      if ( (u_pt < sf_u_knots[u_order-1]) &&
           (fabs(u_pt - sf_u_knots[u_order-1]) > knot_tol) )
      {
        *EMmsg = EMS_E_InvalidArg;
        goto wrapup;
      }
      
      if ( (u_pt > sf_u_knots[u_num_poles]) &&
           (fabs(u_pt - sf_u_knots[u_num_poles]) > knot_tol))
      {
        *EMmsg = EMS_E_InvalidArg;
        goto wrapup;
      }

      j = u_order;

      while (j <= u_num_poles && !is_decided)
      {
        if ((sf_u_knots[j] - u_pt) > knot_tol)
        {
          EMinsert_knot(&mthd_stat, u_knots, &num_u_knots, u_pt,
                        knot_tol, &is_decided);
          EMerr_hndlr (!(1&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);
        }
        else 
         if (fabs(sf_u_knots[j] - u_pt) <= knot_tol)
         {  
           if (u_order == 2)
               is_decided = TRUE;
            
           else
             if ((j + u_order - 2) >= u_num_poles)
             {
                EMinsert_knot(&mthd_stat, u_knots, &num_u_knots, u_pt,
                        knot_tol, &is_decided);
                EMerr_hndlr (!(1&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);
             }
             else
             {
               k = j+1;

               while (k <= j+u_order-2 && !is_decided)
               {
                  if (fabs(u_pt - sf_u_knots[k]) > knot_tol)
                  {
                    EMinsert_knot(&mthd_stat, u_knots, &num_u_knots, u_pt,
                        knot_tol, &is_decided);
                    EMerr_hndlr (!(1&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);
                  }
               }
               is_decided = TRUE; 

             } 

         } /* if (fabs(sf_u_knots[j] - u_pt) <= knot_tol) */

         j++;

      } /* while (j <= u_num_poles && !is_decided) */

   } /* for (i = 0; i < num_uv_pts; i++) */

   v_order = surface->v_order;
   v_num_poles = surface->v_num_poles;
   sf_v_knots = surface->v_knots;

   /*
    * check if there is a knot of multiplicity of oreder -1 
    * at v values.
    */

   for (i = 0; i < num_uv_pts; i++)
   {
      v_pt = uv_pts[2*i+1];
      is_decided = FALSE;
           
      if ( fabs(v_pt - sf_v_knots[v_order-1]) <= knot_tol ||
           fabs(v_pt - sf_v_knots[v_num_poles]) <= knot_tol)

        is_decided = TRUE;
        
      if ( (v_pt < sf_v_knots[v_order-1]) &&
           (fabs(v_pt - sf_v_knots[v_order-1]) > knot_tol) )
      {
        *EMmsg = EMS_E_InvalidArg;
        goto wrapup;
      }
      
      if ( (v_pt > sf_v_knots[v_num_poles]) &&
           (fabs(v_pt - sf_v_knots[v_num_poles]) > knot_tol))
      {
        *EMmsg = EMS_E_InvalidArg;
        goto wrapup;
      }

      j = v_order;

      while (j <= v_num_poles && !is_decided)
      {
        if ((sf_v_knots[j] - v_pt) > knot_tol)
        {
          EMinsert_knot(&mthd_stat, v_knots, &num_v_knots, v_pt,
                        knot_tol, &is_decided);
          EMerr_hndlr (!(1&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);
        }
        else 
         if (fabs(sf_v_knots[j] - v_pt) <= knot_tol)
         {  
           if (v_order == 2)
               is_decided = TRUE;
            
           else
             if ((j + v_order - 2) >= v_num_poles)
             {
                EMinsert_knot(&mthd_stat, v_knots, &num_v_knots, v_pt,
                        knot_tol, &is_decided);
                EMerr_hndlr (!(1&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);
             }
             else
             {
               k = j+1;

               while (k <= j+v_order-2 && !is_decided)
               {
                  if (fabs(v_pt - sf_v_knots[k]) > knot_tol)
                  {
                    EMinsert_knot(&mthd_stat, v_knots, &num_v_knots, v_pt,
                        knot_tol, &is_decided);
                    EMerr_hndlr (!(1&mthd_stat),*EMmsg,EMS_E_Fail,wrapup);
                  }
               }
               is_decided = TRUE; 
             }

         } /* if (fabs(s_v_knots[j] - v_pt) <= knot_tol) */

         j++;

      } /* while (j <= v_num_poles && !is_decided) */

   } /* for (i = 0; i < num_uv_pts; i++) */

   /*
    * Insert u_knots and v_knots if any.
    */

   if (num_u_knots || num_v_knots)
   {
     OM_stat = om$send (msg = message EMSsubbs.EMmove_class (&mthd_stat,
                         md_env, &sf_GRid->objid),
                      senderid = NULL_OBJID,
                      targetid = sf_GRid->objid, 
                      targetos = sf_GRid->osnum);
     EMerr_hndlr(!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

     OM_stat = om$send (msg = message EMSgenbs.EMinsktln (&mthd_stat,
                        md_env, num_u_knots, u_knots, num_v_knots,
                        v_knots, NULL, TRUE, TRUE, TRUE, &sf_GRid->objid),
                       senderid = NULL_OBJID,
                       targetid = sf_GRid->objid, 
                       targetos = sf_GRid->osnum);
    EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_SurfaceError,wrapup);

    /*
     * Change the edge types to EMfreeform_curve
     */

    OM_stat = EMmake_chanselect (EMSsubbs_to_loopset, &sf_ls_chan);
    EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

    OM_stat = om$get_channel_count (osnum = sf_GRid->osnum,
                 objid = sf_GRid->objid, p_chanselect = &sf_ls_chan,
                 count = &num_ls);
    EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);
  
    if (num_ls)
    {
      OM_S_OBJECT_LINKAGE    ls_list;
      OMuint                   count;

      OM_stat = om$get_channel_objects (osnum = sf_GRid->osnum,
                  objid = sf_GRid->objid, p_chanselect = &sf_ls_chan,
                  list = &ls_list, size = 1,  count = &count);
      EMerr_hndlr (!(1&OM_stat),*EMmsg,EMS_E_OMerror,wrapup);

      OM_stat = om$send (msg = message EMSboundary.EMtree_traverse 
                          (&mthd_stat,
                          message EMSedge.EMset_type (&mthd_stat,
                           EMfreeform_curve), OM_K_MAXINT, 1, 
                           &OPP_EMSedge_class_id, TRUE, NULL, NULL, NULL),
                         senderid = NULL_OBJID,
                         targetid = ls_list.S_objid,
                         targetos = ls_list.osnum);
      EMerr_hndlr (!(1&OM_stat&mthd_stat),*EMmsg,EMS_E_LoopsetError,wrapup);
   
    } /* if (num_ls) */

   } /* if (num_u_knots || num_v_knots) */

wrapup:
   EMWRAPUP (*EMmsg, OM_stat, "In EMmake_poles_on_surface");

   if (!sf_geom)
     if (surface) om$dealloc (ptr = surface);
   
   if (u_knots) om$dealloc (ptr = u_knots);
   if (v_knots) om$dealloc (ptr = v_knots);

   return;
  
}  /* end EMmake_poles_on_surface */


end implementation EMSsubbs;
