

class implementation ECblendsf;


# include <math.h>

# include "bsparameters.h"         /*  bspmath */
# include "bstypes.h"              /*  bspmath */


# include "EMSmsgdef.h"
# include "griomacros.h"
# include "exdef.h"
# include "igr.h"
# include "dp.h"
# include "lcdef.h"
# include "lc.h"
# include "lcmacros.h"
# include "grmsg.h"
# include "emserr.h"
# include "dpmacros.h"
# include "EMSasnuc.h"
# include "EMSasmacros.h"
# include "grdpbdef.h"
# include "grdpbmacros.h"
# include "EMSasnucdef.h"
# include "madef.h"
# include "godef.h"
# include "expression.h"
# include "expmacros.h"
# include "ASmsg.h"
# include "ECmsg.h"
# include "ecbls_macros.h"
# include "dpstruct.h"  
# include "igrtypedef.h" 
# include "igrdef.h"  
# include "msdef.h"            /*  MS message codes  */
# include "OMerrordef.h"       /*  OM error definitions  */
# include "msmacros.h"           
# include "emsmacros.h"
# include "igrdp.h"




# include "bsmdstptcv.h"      /*  function prototype  */
# include "bsconstprcv.h"     /*  function prototype  */
# include "bsalloccv.h"       /*  function prototype  */
# include "bsfreecv.h"        /*  function prototype  */
# include "bsallocsf.h"       /*  function prototype  */
# include "bsfreesf.h"        /*  function prototype  */

#include "bserr.h"            /*  for BSERROR  */


# define MAX(x,y)    ((x) < (y) ? (y) :(x))
# define ABS(x)      ((x) < 0 ? -(x) : (x))


from GRvg       import GRgetsize,
                       GRgenabsg,
                       GRgetgeom;






/*  --------------------------------------------------------------------- */
/*  This function finds the edge curve parameter of a normal point to a   */
/*  surface at defined edge.                                              */
/*  --------------------------------------------------------------------- */

IGRlong ECblendsf_gt(                            
           IGRlong           *msg,         /*  return status  (1 = no error)  */
           struct GRid       base_surface, /*  base surface id  */  
           IGRpoint          base_point ,  /*  base point  */ 
           struct GRmd_env   *env,         /*  work environment  */
           IGRint            index,        /*  base surface edge index  */
           IGRdouble         *param_edge   /*  param of normal point on edge  */
                                 )
 
{
  IGRlong     sts;
  IGRlong     loc_msg;
  IGRlong     rc;                        /*  BS return code  */
  IGRshort    opt;                       /*  1: u = const / 2: u = const  */
  IGRboolean  tst_plan = FALSE;          /*  dont check for planar curve  */
  IGRshort    iso_num_bound = NULL;  

  IGRshort    curve_order;               /*  order used (max)      */
  IGRshort    curve_num_poles;           /*  num poles used (max)  */
  IGRlong     num_bytes;                 /*  number of bytes used for srf  */

  IGRdouble   param;                     /*  param of iso curve  */ 
  struct IGRbsp_surface   *srf;          /*  base surface  */
  struct IGRbsp_curve     *edge;         /*  edge curve  */

  IGRpoint    point;                     /*  point on curve  */
  IGRdouble   dist;                      /*  shortest distance  */


  srf  = NULL;
  edge = NULL;

  /*  get basic surface data  */
  sts = om$send(mode = OM_e_wrt_object,
                msg = message GRvg.GRgetsize (
                              &loc_msg,
                              &env->md_env.matrix_type, 
			      env->md_env.matrix,
                              &num_bytes ),
                senderid = NULL,
                targetid = base_surface.objid,
                targetos = base_surface.osnum);
  if (!(1&sts&loc_msg))  goto wrapup; 

  srf = (struct IGRbsp_surface *) malloc(num_bytes);
  if (!srf)  goto wrapup;

  sts = om$send(mode = OM_e_wrt_object,
                msg = message GRvg.GRgetgeom
                              (&loc_msg,
                              &env->md_env.matrix_type, 
                              env->md_env.matrix, 
                              (IGRchar *) srf),
                senderid = NULL,
                targetid = base_surface.objid,
                targetos = base_surface.osnum);
  if (!(1&sts&loc_msg))  goto wrapup; 


  curve_order     = MAX(srf->u_order, srf->v_order);
  curve_num_poles = MAX(srf->u_num_poles, srf->v_num_poles);

  BSalloccv(curve_order, curve_num_poles, srf->rational, iso_num_bound,
            &edge, &rc );  
  if (BSERROR(rc))  goto wrapup;  

  /*  extract iso curve                                         */
  /*                   opt ---  1: u = const /    2: v = const  */

  if (index == 1)   {  opt = 2;  param = 0.0;  }
  if (index == 2)   {  opt = 1;  param = 0.0;  }
  if (index == 3)   {  opt = 2;  param = 1.0;  }
  if (index == 4)   {  opt = 1;  param = 1.0;  }
  BSconstprcv(&rc, srf, &opt, &param, &tst_plan, edge);
  if (BSERROR(rc))  goto wrapup;  

  /*  find shortest distance from point on this curve  */
   BSmdstptcv( edge, base_point, param_edge, point, &dist, &rc);
  if (BSERROR(rc))  goto wrapup;  

 
  /*  free of alloc memory  */  
  if (srf)    BSfreesf(&rc, srf);
  if (edge)   BSfreecv(&rc, edge);
  *msg = 1;
  return sts;


wrapup:
  if (srf)   BSfreesf(&rc, srf);
  if (edge)  BSfreecv(&rc, edge);
  *msg = 0;
  return sts;
}


end implementation ECblendsf;
