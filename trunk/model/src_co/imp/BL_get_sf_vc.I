

class implementation ECblendsf;


# include "bsparameters.h"
# include "bstypes.h"
# include "bserr.h"
# include <math.h>
# include "igr.h"




/*  prototypes  */

# include "bscveval.h"       /*  function prototype  */
# include "bssfeval.h"       /*  function prototype  */
# include "bsnorvec.h"       /*  function prototype  */

from GRvg      import  GRgetsize,
                       GRgetgeom;



/* ---
Name

     BL_get_sf_vc

Abstract

    This is a static function used to extract the tangent value of a 
    surface at the defined parameters.

Synopsis

    IGRint  BL_get_sf_vc(wrk_grid, env, par_u, par_v, ind, pos, vec, closed)

       struct GRid     wrk_grid   pointer to the abstract geometry 
       struct GRmd_env *env       environment
       IGRdouble       par_u      u-parameter on surface to evaluate tangent /
                                  parameter on curve to evaluate tangent
       IGRdouble       par_v      v-parameter on surface to evaluate tangent
       IGRint          ind        = 0: curve
				  > 0: surface, tangent switch  (u=1/v=2)   
       IGRpoint        pos        position at parameter
       IGRvector       vec        vector at parameter
       IGRboolean      *closed     curve is closed flag
Description

    This function allocates surface/curve space, get surface/curve date,
    evaluate tangent at wanted parameter(s) and returns space.

Return Value

    Returns TRUE if no error,  and FALSE if  error.

Notes

    None.

History

    12 mrz 94   HOB     Creation
*/


IGRint  BL_get_sf_vc(wrk_grid, env, par_u, par_v, ind, pos, vec, closed)

   struct GRid       wrk_grid; /*  pointer to the abstract geometry  */
   struct GRmd_env   *env;     /*  environment  */
          IGRdouble  par_u;    /*  u-parameter on surface to evaluate tangent */
          IGRdouble  par_v;    /*  v-parameter on surface to evaluate tangent */
          IGRint     ind;      /*  u/v tangent switch  (u=1/v=2)  */
          IGRpoint   pos;      /*  vector at parameter  */
          IGRvector  vec;      /*  vector at parameter  */
          IGRboolean *closed;  /*  TRUE if curve is closed  */
    

{

  IGRlong     sts = OM_S_SUCCESS;

  IGRlong    loc_msg;
  IGRlong    rc;
  IGRlong    num_bytes;
  IGRshort   i;
  struct IGRbsp_surface *sf;
  struct IGRbsp_curve   *cv;

  IGRpoint  eval[4];            /*  point and derivates  */


   
  cv = NULL;
  sf = NULL;
  *closed = FALSE;

  /*  get basic surface data  */
  sts = om$send(mode = OM_e_wrt_object,
                msg = message GRvg.GRgetsize (
                              &loc_msg,
                              &env->md_env.matrix_type, 
			       env->md_env.matrix,
                              &num_bytes ),
                senderid = NULL,
                targetid = wrk_grid.objid,
                targetos = wrk_grid.osnum);
  if (!(1&sts&loc_msg))  goto wrapup;

  if (ind)
  {
    sf = (struct IGRbsp_surface *) malloc(num_bytes);
    if (!sf)  goto wrapup;

    sts = om$send(mode = OM_e_wrt_object,
                  msg = message GRvg.GRgetgeom(
                                  &loc_msg,
                                  &env->md_env.matrix_type, 
                                  env->md_env.matrix, 
                                  (IGRchar *) sf),
                  senderid = NULL,
                  targetid = wrk_grid.objid,
                  targetos = wrk_grid.osnum);
    if (!(1&sts&loc_msg))  goto wrapup;

    /*  evaluate basepoint  */
    BSsfeval(sf, par_u, par_v, 1, eval, &rc);
    if (rc)  goto wrapup;
    /*   result[1][i]          u-direction      */
    /*   result[2][i]          v-direction      */
                                                          
    for (i=0; i<3; i++)
    {
      pos[i] = eval[0][i];        /*  copy evaluated point as base  */
      vec[i] = eval[ind][i];      /*  copy wanted tangent  */
    }
  }

  else

  {         
    cv = (struct IGRbsp_curve   *) malloc(num_bytes);
    if (!cv)  goto wrapup; 

    sts = om$send(mode = OM_e_wrt_object,
                  msg = message GRvg.GRgetgeom(
                                  &loc_msg,
                                  &env->md_env.matrix_type, 
                                  env->md_env.matrix, 
                                  (IGRchar *) cv),
                  senderid = NULL,
                  targetid = wrk_grid.objid,
                  targetos = wrk_grid.osnum);
    if (!(1&sts&loc_msg))  goto wrapup;

    *closed = cv->phy_closed;

    /*  evaluate basepoint  */
    BScveval(cv, par_u, 1, eval, &rc);
    if (rc)  goto wrapup;

    for (i=0; i<3; i++)
    {
      pos[i] = eval[0][i];        /*  copy evaluated point as base  */
      vec[i] = eval[1][i];        /*  copy tangent  */
    }
  }
  if (sf)  free(sf);
  if (cv)  free(cv); 
  return(TRUE);


wrapup:
  return (FALSE);
}


end implementation ECblendsf;



 
