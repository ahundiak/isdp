/* ###################   APOGEE COMPILED   ################## */
class implementation EMSproject;

# include "EMS.h"
# include "msdef.h"
# include "OMminimum.h"     /* needed for gocmacros.h */
# include "igrtypedef.h"    /* needed for gocmacros.h */
# include "gocmacros.h"     /* GRalign_* */
# include "EMSerrordef.h"
# include "bserr.h"
# include "EMSsfparms.h"
# include "emsmacros.h"
# include "OMmacros.h"

# define DEBUG 0
# define MAX_BUFF 4
# define U_DIR 0
# define V_DIR 1
 
method EMget_params(
 IGRlong *EMmsg;    /* Completion message */
 struct IGRbsp_surface *geom;    /* Surface geometry */
 struct GRmd_env *env;    /* module environment of the  surface */
 IGRushort *type;    /* surface type */
 struct EMsurface_params *params)

/* *********************************************************************

Description
             This method gets the parameters of a surface of projection when 
             specified the module environment.  

             Input
              env   Module environment
		
	      geom  Surface geometry
          
             Output
              EMmsg : Completion status
              type : geometric type of the surface. May be set to NULL if
                     not interested in the same.
              params : structure containing the type of the surface, which
                       in this case is EMproject and parameters to go with
                       the same. 
                       May be set to NULL if not interested in the same


Notes
             The structure of the bspline curve is passed in the
             curve field of params structure. The poles, knots, weights
             is expected to be freed by the caller through an
             om$dealloc.


             Upon exit the completion code will be one of the following:
               EMS_S_Success : if successful
               EMS_E_BSerror : if there was an error while calling 
                               the following math routines. 
                               BSconstprcv
                               BSbx2
               EMS_E_InvalidArg: if the surface of projection is not 
                                 linear in neither u or v direction.
               EMS_E_Fail :  catch all error.

             
Algorithm
             Get the abstract geometry of the surface.
             Call the appropriate math routine to get the properties.

History
             PP       : 08/09/88      Design date
             RC       : 03/22/89      Fixed a bug in testing collinearity
                                      of the projection vector and
                                      removed the restriction that the
                                      projection vector has to be along
                                      v direction.
             PP       : 07/22/89      Should there be an error I was
                                      freeing the poles ptr, knots ptr
                                      and weights ptr. Added code to set
                                      the same to NULL when this happens to
                                      prevent the calling method from freeing
                                      this too.
             PP       : 05/28/90      Made modifications to use a static
                                      buffer. 
             NP       : 08/19/92      Modified for ANSI compliance. Added
                                      typecasts to the om$realloc call.
********************************************************************** */

{
 struct IGRbsp_surface     *surf;
 struct EMproject_params   *cptr;
 IGRdouble                 *pj_vector = NULL, uv;

 BSrc                      rc;
 IGRlong                   status, i;
 IGRint                    num_pts, j, inx, num_cv_poles;
 
 IGRboolean                bssts, pj_vec_col = FALSE, tst_planar;
 IGRshort                  option, pj_vec_direction;
 IGRdouble                 poles_buff[3*MAX_BUFF];

 IGRchar                   *surf_ptr;

 extern IGRboolean         BScollinmny(), BSconstprcv(), BSbx2();

/* ***************************
   Initialization
   *************************** */
 
 *EMmsg = EMS_S_Success;
 status = OM_S_SUCCESS;
 surf_ptr = NULL;
 surf = NULL;

 if (type)
   *type = EMproject;

 if (params)
 {
   cptr = &params->params.project;
   cptr->curve.poles = NULL;
   cptr->curve.knots = NULL;
   cptr->curve.weights = NULL;

   if(!geom)
   {
     GRgetabsg(EMmsg, &env->md_env.matrix_type, env->md_env.matrix, 
               &surf_ptr, i);
     if (! (1 & *EMmsg)) goto wrapup;

     surf = (struct IGRbsp_surface *)surf_ptr;
   }
   else
     surf = geom;
   
   {
   /*
    * First check if poles in v direction is collinear. If
    * not check if u direction poles are collinear or not.
    * If neither u or v direction poles are collinear, 
    * return invalid argument.
    */

    if (surf->v_num_poles > MAX_BUFF)
    {
     pj_vector = (IGRdouble *) om$malloc (size = surf->v_num_poles * 
                                          3 * sizeof(IGRdouble));
     EMerr_hndlr (!pj_vector, *EMmsg, EMS_E_NoDynamicMemory,wrapup);
    }
    else pj_vector = poles_buff;

    for (i = 0; i < surf->v_num_poles; i++)
    {
      inx = i * surf->u_num_poles * 3;
      for (j = 0; j < 3; j++)
      {
       pj_vector[i*3+j] = surf->poles[inx+j];
      }

    } /* for (i = 0; i < surf->v_num_poles; i++) */

    if (surf->rational) 
    {
     for (i = 0; i < surf->v_num_poles; i++)
     {
      inx = i * surf->u_num_poles;
      for (j = 0; j < 3; j++)
        pj_vector[i*3+j] /= surf->weights[inx];

     } /* for (i = 0; i < surf->v_num_poles; i++) */
       
    } /* if (surf->rational) */

    pj_vec_col = BScollinmny (&rc, &surf->v_num_poles, pj_vector);
    EMerr_hndlr (rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);

    if (pj_vec_col)
      pj_vec_direction = V_DIR;
    else
    {
     if (surf->u_num_poles > surf->v_num_poles)
     {
      if (pj_vector && (pj_vector != poles_buff))
      {
       /* typecast correctly for ANSI */
       pj_vector = (IGRdouble *) om$realloc (ptr = (IGRchar *)pj_vector,
                      size = surf->u_num_poles * 3 * sizeof(IGRdouble));
       EMerr_hndlr (!pj_vector, *EMmsg, EMS_E_NoDynamicMemory,wrapup);
      }
      else if (surf->u_num_poles > MAX_BUFF) 
      {
       pj_vector = (IGRdouble *) om$malloc (
                      size = surf->u_num_poles * 3 * sizeof(IGRdouble));
       EMerr_hndlr (!pj_vector, *EMmsg, EMS_E_NoDynamicMemory,wrapup);
      }
      else
       pj_vector = poles_buff;

     } /* if (surf->u_num_poles > surf->v_num_poles) */

     OM_BLOCK_MOVE (surf->poles, pj_vector, sizeof(IGRdouble) * 3 *
                    surf->u_num_poles);

     if (surf->rational)
        for (i = 0; i < surf->u_num_poles; i++)
          for (j = 0; j < 3; j++)
            pj_vector[i*3+j] /= surf->weights[i];
       
     pj_vec_col = BScollinmny (&rc, &surf->u_num_poles, pj_vector);
     EMerr_hndlr (rc != BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
  
     if (pj_vec_col)
       pj_vec_direction = U_DIR;
     else
     {
        *EMmsg = EMS_E_InvalidArg;
        goto wrapup;
     } 

    } /* else for if (pj_vec_col) */
   }

   OM_BLOCK_MOVE (pj_vector, cptr->axis_point0, sizeof(IGRdouble) * 3);
   OM_BLOCK_MOVE (&pj_vector[((pj_vec_direction == U_DIR ? 
                        surf->u_num_poles : surf->v_num_poles) - 1 ) * 3],
                  cptr->axis_point1, sizeof(IGRdouble) * 3);

  {
   num_cv_poles = pj_vec_direction == U_DIR ? surf->v_num_poles :
                                              surf->u_num_poles;

   cptr->curve.poles = (IGRdouble *) om$malloc (size = num_cv_poles *
                                        sizeof(IGRdouble) * 3);
   EMerr_hndlr (!cptr->curve.poles, *EMmsg, EMS_E_NoDynamicMemory,wrapup);

   if (surf->rational)
   {
    cptr->curve.weights = (IGRdouble *) om$malloc (size = num_cv_poles *
                                                   sizeof(IGRdouble));
    EMerr_hndlr(!cptr->curve.weights,*EMmsg,EMS_E_NoDynamicMemory,wrapup);
   }

   cptr->curve.knots = (IGRdouble *) om$malloc (size = sizeof(IGRdouble) *
      (pj_vec_direction == U_DIR ? surf->v_num_knots : surf->u_num_knots));
   EMerr_hndlr (!cptr->curve.knots,*EMmsg,EMS_E_NoDynamicMemory,wrapup);

   option = pj_vec_direction == U_DIR ? 1 : 2;
   uv = 0;
   tst_planar = TRUE;

   status = BSconstprcv(&rc, surf, &option, &uv, &tst_planar, 
                        &cptr->curve);
   EMerr_hndlr(!status || rc!=BSSUCC, *EMmsg, EMS_E_BSerror, wrapup);
  }

   num_pts = surf->u_num_poles * surf->v_num_poles;

   bssts = BSbx2(&rc,&num_pts, surf->poles, surf->weights, 
           &params->range[0], &params->range[3]);
   EMerr_hndlr(!bssts, *EMmsg, EMS_E_BSerror, wrapup);

#if DEBUG
{
 IGRshort i;

  EFdraw_range_box(params->range);
  for (i=0;i<6;i++)
   fprintf (stderr, "Range %d %f \n", i, params->range[i]);
}
#endif
 } /* if (params) */


 wrapup:
  if (!(1&status&*EMmsg))
  {
    if (params)
    {
      if (cptr->curve.poles) om$dealloc(ptr = cptr->curve.poles);
      if (cptr->curve.knots) om$dealloc(ptr = cptr->curve.knots);
      if (cptr->curve.weights) om$dealloc(ptr = cptr->curve.weights);
      cptr->curve.poles = NULL;
      cptr->curve.weights = NULL;
      cptr->curve.knots = NULL;
    }
  }
  if (pj_vector && (pj_vector != poles_buff)) om$dealloc (ptr = pj_vector);
  if (surf_ptr) GRabsg_del(surf_ptr);

#if DEBUG
  EMWRAPUP(*EMmsg, status, "In EMSproject:  EMget_params error");
#endif
  return (status);

}

end implementation EMSproject;      
