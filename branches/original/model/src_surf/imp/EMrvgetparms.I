class implementation EMSrevol;

# include "EMS.h"
# include "msdef.h"
# include "OMminimum.h"     /* needed for gocmacros.h */
# include "igrtypedef.h"    /* needed for gocmacros.h */
# include "gocmacros.h"     /* GRalign_* */
# include "EMSerrordef.h"
# include "bserr.h"
# include "bsgeom_cvsf.h"
# include "EMSsfparms.h"
# include "emsmacros.h"
# include "EMSssprops.h"    /* EMSIS...                 */
# include "EMSrevol.h"      /* EMSrevolvedSurfaceHeader */
# include "OMmacros.h"
# include "EMSommacros.h"

# define BUFFER_SIZE    400

static IGRlong ppallocate_curve(curve,num_poles,num_knots,rational)
struct IGRbsp_curve *curve;
IGRlong num_poles;
IGRlong num_knots;
IGRboolean rational;
{
  if (!curve->poles)
  {
    curve->poles = (IGRdouble *) om$malloc (size = 
                    sizeof (IGRdouble) * 3 * num_poles);
    curve->knots = (IGRdouble *)om$malloc (size = 
                    sizeof (IGRdouble) * num_knots);

    if (!curve->poles || !curve->knots)
     return (0);
    if (rational)
    {
     curve->weights = (IGRdouble *) om$malloc (size = 
                      sizeof (IGRdouble) * num_poles);
     if (!curve->weights) return (0);
    }
  }
 return (1);
}

method EMget_params(
 IGRlong *EMmsg;    /* Completion message */
 struct IGRbsp_surface *geom;    /* Surface geometry */
 struct GRmd_env *env;    /* module environment of the  surface */
 IGRushort *type;    /* surface type */
 struct EMsurface_params *params)
{
 IGRlong                status; /* OM return status */

 IGRboolean             bssts, is_360;  /* Math return code */

 BSrc                   rc;     /* Math completion code */

 IGRchar                *surf_ptr;
                                /* pointer to the abstract geometry of the
                                   surface */
 struct IGRbsp_surface  *rev_surface;
                                /* pointer to the abstract geometry of the
                                   surface */
 struct BSgeom_bsp_surf revsrf;
 struct EMrevolve_params *ptr = NULL;
 IGRint num_pts;
 IGRdouble     *doubles_buffer = NULL;
 IGRdouble     static_doubles_buffer[BUFFER_SIZE];
 IGRshort      gencv_flag;

  extern IGRboolean BSbx2();
  extern void BSsftgeomsf();  
  extern void BSaxsfrev();

  *EMmsg = EMS_S_Success;
  status = OM_S_SUCCESS;

  surf_ptr = NULL;
  rev_surface = NULL;

 if (type)
   *type = EMrevol;

 if(params)
 {
  ptr = &params->params.revolve;
  ptr->curve.poles = NULL;
  ptr->curve.knots = NULL;
  ptr->curve.weights = NULL;

  if(!geom)
  {
   GRgetabsg (EMmsg, &env->md_env.matrix_type, env->md_env.matrix,
              &surf_ptr, i);
   if (! (1 & *EMmsg)) goto wrapup;

   rev_surface = (struct IGRbsp_surface *)surf_ptr;
  }
  else
   rev_surface = geom;

  num_pts = rev_surface->u_num_poles * rev_surface->v_num_poles;
  bssts = BSbx2(&rc, &num_pts, rev_surface->poles, rev_surface->weights,
                                &params->range[0], &params->range[3]);
  EMerr_hndlr(!bssts, *EMmsg, EMS_E_BSerror, wrapup);

  if(ME.EMSsubbs->ss_props & EMSrevolvedFormat) {
  status = om$send(msg = message EMSrevol.EMgetRevolvedFormat(EMmsg,
                      TRUE, &env->md_env.matrix_type,
                      env->md_env.matrix, &ptr->curve, NULL, NULL, NULL, NULL,
                      NULL), targetid = my_id);
        if(! (1 & status)) goto wrapup;

   ptr->curve.bdrys = NULL;
   status = ppallocate_curve(&ptr->curve,ptr->curve.num_poles,
                             ptr->curve.num_knots,
            ptr->curve.rational);
   EMerr_hndlr(!status, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);

  status = om$send(msg = message EMSrevol.EMgetRevolvedFormat(EMmsg,
                                          FALSE,
                                          &env->md_env.matrix_type,
                                          env->md_env.matrix,
                                          &ptr->curve,
                                          ptr->axis,
                                          &is_360,
                                          &ptr->start_angle,
                                          &ptr->sweep_angle,
                                          FALSE),
                                          targetid = my_id);
          if(!(status && (1&*EMmsg)))
            { *EMmsg = EMS_E_Fail;
               goto wrapup;
             }
  }
  else if(!(ME.EMSsubbs->ss_props & EMSrevolvedFormat)){
       struct IGRbsp_curve *gptr = NULL, *rptr = NULL;

       revsrf.geom_prop = FALSE;
       revsrf.type = BSSF_OF_REV;    
       revsrf.bounded = TRUE;
       revsrf.bspsf = rev_surface;
       revsrf.sfgen_cv = NULL;

       ptr->start_angle = 0;

       BSsfrevprop(&revsrf,EMmsg);
       if(*EMmsg != BSSUCC) { 
           *EMmsg = EMS_E_Fail;
           goto wrapup;
           }
          *EMmsg = EMS_S_Success;

       if (!revsrf.sfgen_cv)
       {
        *EMmsg = EMS_E_Fail;
        goto wrapup;
       }

       rptr = &ptr->curve;
       gptr = revsrf.sfgen_cv;

       rptr->num_poles = gptr->num_poles;
       rptr->num_knots = gptr->num_knots;
       rptr->rational = gptr->rational;
       rptr->non_uniform = gptr->non_uniform;
       rptr->periodic = gptr->periodic;
       rptr->order = gptr->order;
       rptr->planar = gptr->planar;
       rptr->phy_closed = gptr->phy_closed;
       rptr->num_boundaries = 0;
       rptr->bdrys = NULL;

       ptr->curve.bdrys = NULL;
       ptr->sweep_angle = revsrf.len1;
       status = ppallocate_curve(&ptr->curve,ptr->curve.num_poles,
                             ptr->curve.num_knots,
                             ptr->curve.rational);
       EMerr_hndlr(!status, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);

       OM_BLOCK_MOVE(gptr->poles,rptr->poles,rptr->num_poles * 3 *
                      sizeof (IGRdouble));
       OM_BLOCK_MOVE(gptr->knots,rptr->knots,rptr->num_knots * 
                      sizeof (IGRdouble));

       if (gptr->rational)
         OM_BLOCK_MOVE(gptr->weights,rptr->weights,rptr->num_poles *
                      sizeof (IGRdouble));

        if (gptr)
         BSfreecv(EMmsg, gptr);
     
       BSaxsfrev(rev_surface, revsrf.pt1, ptr->axis, &gencv_flag, EMmsg);
       if(*EMmsg != BSSUCC) {
           *EMmsg = EMS_E_Fail;  
           goto wrapup;
           }
          *EMmsg = EMS_S_Success;  
       }   
    else
    { *EMmsg = EMS_E_InvalidArg;
       goto wrapup;
     }
 } /* if (params) */

wrapup:

  if (!(1&status&*EMmsg))
  {
    if (ptr->curve.poles) free(ptr->curve.poles);
    if (ptr->curve.knots) free(ptr->curve.knots);
    if (ptr->curve.weights) free(ptr->curve.weights);
  }

  if (surf_ptr) GRabsg_del(surf_ptr); 

  EMWRAPUP(*EMmsg, status, "EMSrevol.EMget_params")
  return(status);
}

end implementation EMSrevol;
