/* ###################   APOGEE COMPILED   ################## */
class implementation EMSsurface;

#include "EMS.h"
# ifndef msdef_include
# include "msdef.h" /* MS message definitions */
# endif

# include "OMminimum.h"
# include "OMmacros.h"
# include "OMstackalloc.h"
# include "emsdef.h"
# include "bserr.h"
# include "bsparameters.h"
# include "bstypes.h"
# include "godef.h"
# include "bssf_copy.h"
# include "bsu_spl_sf.h"
# include "bsv_spl_sf.h"
# include "bsallocsf.h"
# include "bsfreesf.h"
# include "bsquicksort.h"
# include "bsreparmsf.h"
# include "bsprptonsf.h"
# include "bssfptseval.h"

# ifndef gocmacros_include
# include "gocmacros.h" /* GRgetabsg */
# endif

#define U  0
#define V  1

extern OMuword OPP_EMSgenbs_class_id;

method EMsplit_surface(IGRlong                  *rc;
                       struct    GRmd_env       *my_env;
                       struct    GRvg_construct *construct_list;
                       IGRint                   option;
                       IGRlong                  in_numpars,
                                                *out_numpars;
                       IGRdouble                *in_parms,
                                                **out_parms;
                       struct    GRid           insrf_id;
                       GRobjid                  **out_surf_ids;
                       IGRboolean               *uv_closed,
                                                delete_flag)

/*
Notes 
      Upon exit the completion code will be one of

                - EMS_S_Success if successful
                        - EMS_E_Fail (severe) if failure
                - MSFAIL math failure
Assumption

Bugs

History
        
          gupta,doree   05/04/87:    design date
          doree         04/06/88     added GR_NOTIFY_LISTENERS
          Sudhakar      06Jul'93     Fix for TR# 119221377. Replaced the calls
                                     to 'BSu_spl_pch' and 'BSv_spl_pch'
                                     with 'BSu_spl_sf' and 'BSv_spl_sf'
                                     respectively to avoid splitting at the
                                     seam.

          Vadi          05/01/94     Modified so that if the surface is closed
                                     in U or V and the splitting is along U or
                                     V, then do not output the surface 
                                     resulting from the first split, provided
                                     the number of splits is more than one. 

          Vadi          12/01/94     Since 'BSu_spl_sf' and 'BSv_spl_sf'
                                     reparameterize the pieces resulting
                                     from split, the input parameters
                                     have to be evaluated again w.r.t.
                                     the split pieces in case of multiple
                                     splits.    
Algorithm

      Sort the incoming parameters in ascending order. Throw away all
      the parameters which are within knot tolerance of other parameters.
      Split the surface and keep the left surface. Split the right surface
      and keep the left surface. Repeat this process for all the
      parameters. Reparametrize all the resulting split surfaces from
      0 -- 1. Construct the split surface objects and post their geometry.
      Delete the old surface, if the delete_flag is ON. 
*/

{
  IGRchar    errmsg[EMMAXERRMSG_LEN], *surf;
  IGRlong    stat_OM, msg, sts, frominx, toinx,
             loc_out_numpars;
  IGRint     i, j;
 extern  IGRdouble  fabs();
  IGRdouble  knot_tol;
  IGRdouble **xyz_pts, uvpars[2],
              upar, vpar;
  extern   IGRboolean BSsf_copy();
IGRboolean   stat_func, is_valid,
             closed_in_u, closed_in_v,
             onsurf;
  /*extern   void       BSallocsf();*/
  GRobjid    *srf_ids;
  struct IGRbsp_surface   *insrf, **outsrf, **srfa, *srfb, *tempsrf,
                          *loc_surfs, *rem_surf = NULL;
  
/*------------------------------------------------------------------*/  
  *rc = MSSUCC;
  stat_OM = OM_S_SUCCESS;
  strcpy(errmsg, "EMSsurface.EMsplit_surface");
  
  *out_numpars = 0;
  *out_parms = NULL;
  srfb = NULL;
  tempsrf = NULL;
  srfa = NULL;
  outsrf = NULL;
  loc_surfs = NULL;
  closed_in_u = closed_in_v =
              FALSE;
  xyz_pts = NULL;
  
  (void) BSEXTRACTPAR(&msg, BSTOLKNOT, knot_tol);

  *out_parms = (IGRdouble *) OM_stack_alloc(
                 in_numpars * sizeof(IGRdouble));
  srfa = (struct IGRbsp_surface **) OM_stack_alloc(
                 in_numpars * sizeof(struct IGRbsp_surface *));
  outsrf = (struct IGRbsp_surface **) OM_stack_alloc(
                 (in_numpars+1) * sizeof(struct IGRbsp_surface *));
 
/*
 *  Get the abstract geometry of 
 *  the surface to be split
 */

  GRgetabsg (&msg, &my_env->md_env.matrix_type, my_env->md_env.matrix,
             &surf, i);
  EMerr_hndlr (EMis_error (msg), *rc, msg, ret_end);

  insrf = (struct IGRbsp_surface *) surf;

  uv_closed[0] = (insrf->u_phy_closed) ? TRUE : FALSE;
  uv_closed[1] = (insrf->v_phy_closed) ? TRUE : FALSE;

/*
 *  Sort the parameters in ascending order 
 */

  frominx = 0;
  toinx = in_numpars - 1;

  sts = BSquicksort(&msg, (IGRint *)&frominx, (IGRint *)&toinx,
                    (IGRint *) &in_numpars,
                    in_parms);
  EMerr_hndlr(!sts || msg != BSSUCC, *rc, MSFAIL, ret_end);

 /* 
  * remove parameters that are very close to each other 
  */

  for (i=0; i<in_numpars; i++)
   {
    is_valid = TRUE;
    for (j=i+1; j<in_numpars; j++)
     {
      if (fabs(in_parms[i] - in_parms[j]) <= knot_tol)
         {
          is_valid = FALSE;
         }
     }
    if ((fabs(in_parms[i] - 0.0) <= knot_tol) ||
       (fabs(in_parms[i] - 1.0) <= knot_tol))
       is_valid = FALSE;

    if (is_valid)
     {
      (*out_parms)[*out_numpars] = in_parms[i];
      (*out_numpars)++;
     }
   }

  if (! (*out_numpars))
      goto ret_end;
     
      xyz_pts = (IGRdouble **) OM_stack_alloc(
                 (*out_numpars) * sizeof(IGRdouble *));
      
      if(option == U)
         uvpars[1] = 0.0;
      else
         uvpars[0] = 0.0;
      for(i = 0; i < (*out_numpars); i++) 
          {
           if(option == U)
              uvpars[0] = (*out_parms)[i];
           else
              uvpars[1] = (*out_parms)[i];

           xyz_pts[i] = (IGRdouble *) OM_stack_alloc(
                                      3 * sizeof(IGRdouble));
           BSsfptseval(insrf, 1, uvpars, xyz_pts[i], &msg);
           EMerr_hndlr(msg != BSSUCC, *rc, MSFAIL, ret_end);
          }

  
/*
 *  Allocate memory for tempsrf so you won't wipe out insrf.
 *  Loop until the surface has been split along each parameter line.
 *  First allocate the memory for each output surface and then call the 
 *  appropriate math routine
 */

  BSallocsf(insrf->u_order, insrf->v_order, insrf->u_num_poles,
            insrf->v_num_poles, insrf->rational,
            insrf->num_boundaries, &tempsrf, &msg);
  EMerr_hndlr(msg != BSSUCC, *rc, MSFAIL, ret_end);

  stat_func = BSsf_copy(&msg, insrf, tempsrf);
  EMerr_hndlr (! stat_func || msg != BSSUCC, *rc, MSFAIL, ret_end);
  
  for (i=0; i < (*out_numpars); i++)
  {
      BSallocsf(tempsrf->u_order, tempsrf->v_order, 
                (option == U ? (tempsrf->u_num_poles + tempsrf->u_order - 1)
                             : tempsrf->u_num_poles),
                (option == V ? (tempsrf->v_num_poles + tempsrf->v_order - 1)
                             : tempsrf->v_num_poles),
                tempsrf->rational,
                tempsrf->num_boundaries, &srfa[i], &msg);
      EMerr_hndlr(msg != BSSUCC, *rc, MSFAIL, ret_end);

      BSallocsf(tempsrf->u_order, tempsrf->v_order, 
                (option == U ? (tempsrf->u_num_poles + tempsrf->u_order - 1)
                             : tempsrf->u_num_poles),
                (option == V ? (tempsrf->v_num_poles + tempsrf->v_order - 1)
                             : tempsrf->v_num_poles),
		tempsrf->rational,
                tempsrf->num_boundaries, &srfb, &msg);
      EMerr_hndlr(msg != BSSUCC, *rc, MSFAIL, ret_end);

      BSprptonsf(&msg, tempsrf, xyz_pts[i], &upar, &vpar, &onsurf);
      EMerr_hndlr(msg != BSSUCC, *rc, MSFAIL, ret_end);

      if (option == U)
      {
         BSu_spl_sf(tempsrf, upar, srfa[i], srfb, &msg);
         EMerr_hndlr(msg != BSSUCC, *rc, MSFAIL, ret_end);
         if(tempsrf->u_phy_closed)
            srfa[i]->u_phy_closed = FALSE;
      }
      else
      {
         BSv_spl_sf(tempsrf, vpar, srfa[i], srfb, &msg);
         EMerr_hndlr(msg != BSSUCC, *rc, MSFAIL, ret_end);
         if(tempsrf->v_phy_closed)
            srfa[i]->v_phy_closed = FALSE;
      }

      if(tempsrf->u_phy_closed || tempsrf->v_phy_closed)
           rem_surf = srfa[i];
      else
           rem_surf = srfb;

      if(tempsrf)
      {
       BSfreesf(&msg, tempsrf);
       tempsrf = NULL;
     }
      
     BSallocsf(rem_surf->u_order, rem_surf->v_order, 
               rem_surf->u_num_poles,
               rem_surf->v_num_poles,
	       rem_surf->rational,
               rem_surf->num_boundaries, &tempsrf, &msg);
     EMerr_hndlr(msg != BSSUCC, *rc, MSFAIL, ret_end);

      stat_func = BSsf_copy(&msg, rem_surf, tempsrf);
      EMerr_hndlr(! stat_func || msg != BSSUCC,*rc,MSFAIL,ret_end);

      if (i != (*out_numpars)-1)
       {
        if (srfb) BSfreesf(&msg, srfb);
        srfb = NULL;
       }
  }

/*
  tempsrf = NULL;
 *  Reparameterize the output surfaces returned from the
 *  math routine
 */

  if(insrf->u_phy_closed && option == U)
     closed_in_u = TRUE;
  else if(insrf->v_phy_closed && option == V)
     closed_in_v = TRUE;  

  if((closed_in_u && option == U && ((*out_numpars) > 1)) ||
     (closed_in_v && option == V) && ((*out_numpars) > 1)) {
     loc_out_numpars = (*out_numpars) - 1;

     loc_surfs = (struct IGRbsp_surface *) OM_stack_alloc((*out_numpars) *
                                           sizeof(struct IGRbsp_surface));   
     for(i = 0; i < loc_out_numpars; i++) 
         OM_BLOCK_MOVE(srfa[i+1], &loc_surfs[i],
                       sizeof(struct IGRbsp_surface));
     OM_BLOCK_MOVE(srfb, &loc_surfs[loc_out_numpars],
                   sizeof(struct IGRbsp_surface));    
     }
  else {
     loc_out_numpars = (*out_numpars);
     loc_surfs = (struct IGRbsp_surface *) OM_stack_alloc(((*out_numpars) + 1) *
                                           sizeof(struct IGRbsp_surface));
     for(i = 0; i < loc_out_numpars; i++) 
         OM_BLOCK_MOVE(srfa[i], &loc_surfs[i],
                       sizeof(struct IGRbsp_surface));
     OM_BLOCK_MOVE(srfb, &loc_surfs[loc_out_numpars],
                   sizeof(struct IGRbsp_surface));
     }   
         
  for (i=0; i <= loc_out_numpars; i++)
  {
   if (i == loc_out_numpars)
    {
      if(((*out_numpars) > 1 && option == U && closed_in_u) ||
         ((*out_numpars) > 1 && option == V && closed_in_v) ||
         (!closed_in_u && !closed_in_v)) {
      BSallocsf(loc_surfs[loc_out_numpars].u_order,
                loc_surfs[loc_out_numpars].v_order,
                loc_surfs[loc_out_numpars].u_num_poles,
                loc_surfs[loc_out_numpars].v_num_poles,
                loc_surfs[loc_out_numpars].rational,
                loc_surfs[loc_out_numpars].num_boundaries,
                &outsrf[i], &msg);
      EMerr_hndlr(msg != BSSUCC, *rc, MSFAIL, ret_end);

      BSreparmsf(&loc_surfs[loc_out_numpars], option, 0.0,1.0,0.0,1.0, 
                 outsrf[i], &msg);
      EMerr_hndlr(msg != BSSUCC, *rc , MSFAIL, ret_end);

      if(srfb) BSfreesf(&msg, srfb);
      srfb = NULL;
      }
    }
   else
    {
      BSallocsf(loc_surfs[i].u_order,
                loc_surfs[i].v_order,
                loc_surfs[i].u_num_poles,
                loc_surfs[i].v_num_poles,
                loc_surfs[i].rational,
                loc_surfs[i].num_boundaries,
                &outsrf[i], &msg);
      EMerr_hndlr(msg != BSSUCC, *rc, MSFAIL, ret_end);

      BSreparmsf(&loc_surfs[i], option, 0.0,1.0,0.0,1.0, outsrf[i], &msg);
      EMerr_hndlr(msg != BSSUCC, *rc , MSFAIL, ret_end);
  
      if(srfa[i]) BSfreesf(&msg, srfa[i]);
      srfa[i] = NULL;
    }
     /*  Needed for solids */

      if((closed_in_u && option == U && (*out_numpars) == 1 &&
          i == (*out_numpars)) ||
         (closed_in_v && option == V && (*out_numpars) == 1 && 
          i == (*out_numpars))) 
         continue;
      else
      outsrf[i]->pos_orient = (insrf->pos_orient == 1) ? 1 : 0;
  }

/* 
 *  Construct the new surfaces which were returned from the
 *  math routine.
 *
 *  Fix for TR#119415989. 
 */

  if((closed_in_u && option == U && (*out_numpars) == 1) || 
     (closed_in_v && option == V && (*out_numpars) == 1))
      {
      srf_ids = (GRobjid *) om$malloc(size = loc_out_numpars *
                                      sizeof(GRobjid));
      EMerr_hndlr(!srf_ids, *rc, MSNOMEM, ret_end);
      }
      else
      {
      srf_ids = (GRobjid *) om$malloc(size = (loc_out_numpars + 1) *
                                      sizeof(GRobjid));
      EMerr_hndlr(!srf_ids, *rc, MSNOMEM, ret_end);
      }

  *out_surf_ids = srf_ids;

  for (i=0; i <= loc_out_numpars; i++)
  {
      if((closed_in_u && (*out_numpars) == 1 && i == (*out_numpars)) ||
         (closed_in_v && (*out_numpars) == 1 && i == (*out_numpars)))
        continue;
      else {  
      construct_list->geometry = (IGRchar *) outsrf[i];

      stat_OM = om$construct(classid = OPP_EMSgenbs_class_id,
                            p_objid = &srf_ids[i],
                            msg = message GRgraphics.GRconstruct(
                                  construct_list));
      EMomerr_hndlr(stat_OM, ret_end, errmsg);

      if(outsrf[i]) BSfreesf(&msg,outsrf[i]);
      outsrf[i] = NULL;
      }
  }

/*
 *  Delete the input surface(myself), if the delete flag is on
 */

  if (delete_flag)
  {
     stat_OM = om$send(msg = message GRgraphics.GRdelete(&msg, my_env),
                      targetid = my_id);
     EMomerr_hndlr(stat_OM, ret_end, errmsg);
     EMerr_hndlr(EMis_error(msg), *rc, MSFAIL, ret_end);
  }


ret_end:

        if (srfb) BSfreesf(&msg,srfb);

        if (tempsrf) BSfreesf(&msg, tempsrf);

    if (srfa) OM_stack_dealloc(srfa);
    if (outsrf) OM_stack_dealloc(outsrf);
    if (loc_surfs) OM_stack_dealloc(loc_surfs);
    for(i = 0; i <(*out_numpars); i++) {
        if(xyz_pts[i]) OM_stack_dealloc(xyz_pts[i]);
           xyz_pts[i] = NULL;
        }
    if(xyz_pts) OM_stack_dealloc(xyz_pts);

    GR_NOTIFY_LISTENERS(rc, &stat_OM, GR_CLIPPED);

    return(stat_OM);
}

end implementation EMSsurface;
