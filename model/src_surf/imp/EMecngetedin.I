/* ###################   APOGEE COMPILED   ################## */

class implementation EMSelpcone;

#include "EMS.h"
# include "msdef.h"
# include "EMSerrordef.h" /* for EMSerror definitions */
# include "gocmacros.h"     /*  GRgetabsg macro */
# include "emsedgedef.h" /* for edge type definitions */
# include "EMSconstruct.h" /* for SEAM_EDGE declaration */
# include "bserr.h" /* For BSERROR macro */
# define CONSTANTU 1

method EMget_natedge_info (
    IGRlong                     *EMmsg;
    struct GRmdenv_info         *md_env;
    IGRuchar            *curve_type;
    IGRushort           *edge_props) 

/* *****************************************************************
Description
        The method returns the curve type and the edge properties
        of the natural edges belonging to an elliptical cone.

        Input
          md_env   : module enviroment information. May be set to NULL, as the
                     method does not use this information
          
        Output
          curve_type : the curve type of the natural edges. An array of size
                     four is expected to be allocated coming in.
          edge_props : the edge properties of the natural edges. An array of
                     size four is expected to be allocated coming in.
          EMmsg      : completion code

Notes
        Upon exit the completion code will be one of the following:
         EMS_E_Fail : if there was error in getting the abstract geometry
         EMS_E_InvalidArg : If invalid arguments in testing degeneracy.
         EMS_S_Success  : if successful 

History

        PP : 08/01/88     Fixed a bug with an else statement to do with
                          the edge type not getting set right
        PP : 01/18/88     Modified the code to set the degenerate bit right
        PP : 10/13/87           creation

******************************************************************** */

{
 IGRlong status;
 IGRint i;
 struct IGRbsp_surface *surf;
 IGRchar *cache_ptr = NULL;
 IGRboolean degn1 = FALSE, degn3 = FALSE;

 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;

 GRgetabsg (&status, &md_env->matrix_type, md_env->matrix,
              &cache_ptr, i);
 EMerr_hndlr (!(1&status),*EMmsg,EMS_E_Fail,wrapup);

 surf = (struct IGRbsp_surface *) cache_ptr;

 EMtestdegn (EMmsg, surf, 1, &degn1);
 if (!(1&*EMmsg)) goto wrapup;
  

 EMtestdegn (EMmsg, surf, 3, &degn3);
 if (!(1&*EMmsg)) goto wrapup;

 if (curve_type)
 {
  curve_type[0] = EMlinesegment;
  if (degn1)
   curve_type[1] = EMpoint;
  else
   curve_type[1] = EMellipse;

  curve_type[2] = EMlinesegment;
  if (degn3)
   curve_type[3] = EMpoint;
  else
   curve_type[3] = EMellipse;
 }

 if (edge_props)
 {
   edge_props[0] = SEAM_EDGE | EMED_SUBORDINATE | EMED_TANGENT;
   edge_props[1] = EMED_XYZ_CLOSED;
   edge_props[2] = SEAM_EDGE | EMED_TANGENT;
   edge_props[3] = EMED_XYZ_CLOSED;
   if (degn1) edge_props[1] |= EMED_DEGENERATE;
   if (degn3) edge_props[3] |= EMED_DEGENERATE;
 }

wrapup:
 if (cache_ptr) GRabsg_del(cache_ptr);
 return (status);

}

EMtestdegn (EMmsg, surf, location, is_degn)
IGRlong *EMmsg;
struct IGRbsp_surface *surf;
IGRint location;
IGRboolean *is_degn;

{
 struct IGRbsp_curve curve, *gen_curve;
 BSrc rc;
 IGRboolean             tst_plan = TRUE, memory_allocated = FALSE;  
 IGRboolean             bssts;
 IGRshort               option;
 IGRdouble		uv;
  extern  IGRboolean             BSconstprcv ();
  extern  void                   BSalloccv();

 *EMmsg = EMS_S_Success;
 gen_curve = NULL;

 switch(location)
 {
  case 1:
  case 3:
  {
    curve.num_poles = surf->u_num_poles;
    curve.order = surf->u_order;
    curve.rational = surf->rational;
    curve.periodic = surf->u_periodic;
    curve.phy_closed = surf->u_phy_closed;
    curve.planar = TRUE;
    curve.non_uniform = surf->u_non_uniform;
    curve.num_knots = surf->u_num_knots;
    curve.num_boundaries = 0;
    curve.bdrys = NULL;
    gen_curve = &curve;
    memory_allocated = FALSE;
    break;
  }

  case 0:
  case 2:
   {
     uv = 0.0;
     option = CONSTANTU;

     BSalloccv (surf->v_order, surf->v_num_poles, surf->rational, NULL,
                &gen_curve, &rc);
     EMerr_hndlr (BSERROR(rc),*EMmsg, EMS_E_BSerror, wrapup);
     memory_allocated = TRUE;
     break;
   }
  default:
   {
     *EMmsg = EMS_E_InvalidArg;
     return;
   }
 }

 switch (location)
 {
  case 1:
   gen_curve->poles = &surf->poles[(surf->u_num_poles) * 
                      (surf->v_num_poles - 1) * 3];
   gen_curve->knots = surf->u_knots;
   gen_curve->weights = &surf->weights[surf->u_num_poles 
                      * (surf->v_num_poles - 1)];

   break;
 
  case 3:
   gen_curve->poles = surf->poles;
   gen_curve->knots = surf->u_knots;
   gen_curve->weights = surf->weights;
   break;

  case 0:
    option = CONSTANTU;
    uv = 0.0;

    bssts = BSconstprcv (&rc, surf, &option, &uv, 
                         &tst_plan, gen_curve);
    EMerr_hndlr (!bssts, *EMmsg, EMS_E_Fail, wrapup);
   break;
  
  case 2:
    option = CONSTANTU;
    uv = 1.0;
    
    bssts = BSconstprcv (&rc, surf, &option, &uv, 
                         &tst_plan, gen_curve);
    EMerr_hndlr (!bssts, *EMmsg, EMS_E_Fail, wrapup);
   break;
 }

   (void) BStstcvdegn (gen_curve, is_degn, &rc);
   EMerr_hndlr (BSERROR(rc), *EMmsg, EMS_E_BSerror, wrapup);

wrapup:
   if (memory_allocated && gen_curve)
     BSfreecv (&rc, gen_curve);
   return;
   }
   

end implementation EMSelpcone;
