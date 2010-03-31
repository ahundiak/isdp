class implementation EMSsubbs;

/*
DESCRIPTION

This method extends input surface polynomially along its parametric directions
(U_LEFT, U_RIGHT, V_LEFT and V_RIGHT) by the specified distances.

OPTIONS

EMS_opt_extendS_deextend_if_needed:
Option is provided to de-extend the surface if an extension causes the surface
to close in a parametric direction, such that the extended surface continues
to remain open both parametric directions.

RETURN VALUES

Returns the objid of the extended surface as it could potentially change.
Also returns the actual distances by which the surface geometry was extended.

CAVEATS

Actual distances by which the surface geometry was extended is not always
correct. Problem with Math ?

HISTORY
 
 10 Aug 1995 Hari      Added self-intersection check for the extended-offset
                       surface. This seems to be important as the self inter  
                       -section case might lead to invalid-solid formation.

 29 Dec 1993 sudhakar  Fixed a problem arising when some of the extensions
                       are non-zero, but no extension takes place due to the
                       surface being closed in the extension direction.
 25 Nov 1993 ashok     Modified to construct appropriate class for the surface
  		       after extension(s) based on the surface type returned by
 		       math after the geometry is extended.
 ?? May 1993 ashok     Creation
*/

%safe
#include <math.h>
%endsafe

# include "bsgeom_cvsf.h"
# include "bsprintbsps.h"
# include "bsfreesf.h"
# include "ems_m_inc.h"
# include "go.h"
# include "gocmacros.h"
# include "EMS_E.h"     
# include "emssfint.h"
#include "msmacros.h" /* for ex$message */

#define NUM_PARAMS 4
# define U_LEFT  0
# define U_RIGHT 1
# define V_LEFT  2
# define V_RIGHT 3

# define POLY_EXT 0
# define LINE_EXT 1
# define REPARAMETRIZE_IN_U_AND_V  2

extern OMuword  OPP_EMScylindr_class_id,
                OPP_EMSproject_class_id;

method EMextend_by_dist(
               IGRlong *msg;		/* O */
               struct GRmd_env *env;	/* I */
               IGRdouble dist_in[4];	/* I */
	       IGRdouble dist_out[4];	/* O */
               IGRint option;		/* I */
	       GRobjid *newid		/* O */
               )
{
     IGRint 	 i, extnd_option;
     OMuword	 old_classid, new_classid;
     IGRboolean  u_left, u_right, v_left, v_right, stat_func, mem_allocated,
		 uv_closed[2];
     IGRdouble	 ext_dist, loc_dist_in[4];
     struct      IGRbsp_surface  *surface=NULL, *p_fixsf=NULL, *p_sf=NULL;
  
     IGRshort    out_code = 0;

     struct      BSgeom_bsp_surf extended_surface, surface_to_extend;
     IGRlong     msg_loc, stat_OM, rc;

     IGRboolean   GRabsg_del_all();
     void        BSxgmsfdst();

      
     *msg = EMS_S_Success;
     stat_OM = OM_S_SUCCESS;  
     *newid = my_id;

     surface = NULL;
     extended_surface.bspsf = NULL;
     extended_surface.sfgen_cv = NULL;
     mem_allocated = FALSE;

     if(dist_in[0] == 0.0 && dist_in[1] == 0.0 && dist_in[2] == 0.0 &&
	dist_in[3] == 0.0) goto wrapup;

     for(i=0; i<NUM_PARAMS; i++) loc_dist_in[i] = dist_in[i];

     GRgetabsg(&msg_loc, &env->md_env.matrix_type, env->md_env.matrix,
               (IGRchar **) &surface, i);
     EMerr_hndlr(!(msg_loc & 1), *msg, EMS_E_Fail, wrapup);

     getsftype( my_id, OM_Gw_current_OS, &surface_to_extend.type );
     surface_to_extend.bspsf = surface;
     surface_to_extend.bounded = TRUE;
     surface_to_extend.urange[ 0 ] = surface_to_extend.vrange[ 0 ] = 0.0;
     surface_to_extend.urange[ 1 ] = surface_to_extend.vrange[ 1 ] = 1.0;
     surface_to_extend.sfgen_cv = NULL;
     surface_to_extend.geom_prop = FALSE;

     uv_closed[0] = surface->u_phy_closed;
     uv_closed[1] = surface->v_phy_closed;

/* Get the classid of the surface */
     stat_OM = om$get_classid(object = me, p_classid = &old_classid);

/* Now to extend the surface */
     extnd_option = 1; /* polynomial extension */
     for(i=0; i<NUM_PARAMS; i++)
     {
	if(loc_dist_in[i] == 0.0) continue;

       /* No need to extend along a particular direction if the
          surface is closed in that direction  */
        if ((((i == U_LEFT) || (i == U_RIGHT)) && uv_closed[0]) ||
            (((i == V_LEFT) || (i == V_RIGHT)) && uv_closed[1]))
           continue;

	u_left = u_right = v_left = v_right = FALSE;
	switch(i)
	{
	      case U_LEFT:
		u_left = TRUE;
		break;
	      case U_RIGHT:
		u_right = TRUE;
		break;
	      case V_LEFT:
		v_left = TRUE;
		break;
	      case V_RIGHT:
		v_right = TRUE;
		break;
	      default:
		EMerr_hndlr(TRUE, *msg, EMS_E_Fail, wrapup);
	}
        extended_surface.bspsf = NULL;
	BSxgmsfdst(&surface_to_extend, loc_dist_in[i], extnd_option, u_left,
              u_right, v_left, v_right, &extended_surface, &ext_dist,
              &rc);
      EMerr_hndlr((rc != BSSUCC), *msg, EMS_E_BSerror, wrapup);

	dist_out[i] = ext_dist;

	extended_surface.bspsf->pos_orient = 
					surface_to_extend.bspsf->pos_orient;

	if(mem_allocated && surface_to_extend.bspsf)
	   stat_func = BSfreesf(&rc, surface_to_extend.bspsf);
        surface_to_extend.bspsf = extended_surface.bspsf;
	surface_to_extend.geom_prop = FALSE;
	mem_allocated = TRUE;
     
        surface = extended_surface.bspsf;

        if(option & EMS_opt_extendS_deextend_if_needed)
        {
	  IGRboolean 	orig_uv_closed, ext_uv_closed;
	  IGRdouble	cht, shrink_dist;

          BSEXTRACTPAR(&rc, BSTOLCHRDHT, cht);
	  orig_uv_closed = (i > U_RIGHT ? uv_closed[1] :
				          uv_closed[0]);
	  ext_uv_closed = (i > U_RIGHT ? surface->v_phy_closed :
				         surface->u_phy_closed);

	  shrink_dist = 0.0;
	  if(!orig_uv_closed && ext_uv_closed) /* needs de-extension */
	  {
	    shrink_dist = 2 * cht;
	    if((i == U_LEFT || i == V_LEFT))
	      if(loc_dist_in[i + 1] > 0)     /* ext. dist in U_RIGHT or V_RIGHT
						is greater than zero
					     */
	      {
	        loc_dist_in[i + 1] = shrink_dist;  /* reduce the extension
						      in the other direc to 
						      a minimum.
						   */
	        shrink_dist = 2 * shrink_dist;   /* ensure the surface will
						    remain open.
						 */
	      }
	      else if( loc_dist_in[i + 1] < 0 ) 
		shrink_dist = 0.0;             /* de-extension not needed */

	    dist_out[i] = dist_out[i] - shrink_dist;

	    if(shrink_dist > 0.0)
	    {
	      BSxgmsfdst(&surface_to_extend, -1.0 * shrink_dist, extnd_option, 
			 u_left, u_right, v_left, v_right, &extended_surface, 
			 &ext_dist, &rc);
	      EMerr_hndlr((rc != BSSUCC), *msg, EMS_E_BSerror, wrapup);

	      surface = extended_surface.bspsf;
	      ext_uv_closed = (i > U_RIGHT ? surface->v_phy_closed :
				             surface->u_phy_closed);

	      EMerr_hndlr(ext_uv_closed, *msg, EMS_E_Fail, wrapup);

	      extended_surface.bspsf->pos_orient = 
					surface_to_extend.bspsf->pos_orient;

	      if(mem_allocated && surface_to_extend.bspsf)
	         stat_func = BSfreesf(&rc, surface_to_extend.bspsf);
              surface_to_extend.bspsf = extended_surface.bspsf;
	      surface_to_extend.geom_prop = FALSE;
	      mem_allocated = TRUE;
	    } /* if(shrink_dist > 0.0) */
	  } /* if(!orig_uv_closed && ext_uv_closed) */
        } /* if(option & .... ) */
        surface_to_extend.type = extended_surface.type;
     } /* for(i=0; .... */

     if(extended_surface.bspsf && 
             (option & EMS_opt_extendS_reparametrize_surface))
     {
          void BSarclnpars();

          /* Reparametrize the surface */
          BSarclnpars(&msg_loc, REPARAMETRIZE_IN_U_AND_V,
                                   extended_surface.bspsf);
          if(msg_loc != BSSUCC)
          {
             *msg = MSFAIL;
             goto wrapup;
          }
     }

   p_sf = extended_surface.bspsf;
   BSallocsf (p_sf->u_order, p_sf->v_order, p_sf->u_num_poles, 
              p_sf->v_num_poles, p_sf->rational, p_sf->num_boundaries,
              &p_fixsf, &rc);
   EMerr_hndlr( rc != BSSUCC, *msg, EMS_E_BSerror, wrapup);
   
   /* Check the surface for self-intersection. If so, error out rather
      than proceeding further and creating an invalid solid. Hari
    */
   
   BSchkfxsf (extended_surface.bspsf,0, p_fixsf, &out_code, &rc);
   BSfreesf (&rc, p_fixsf); p_fixsf = NULL;
   EMerr_hndlr( rc != BSSUCC, *msg, EMS_E_BSerror, wrapup);

   if(out_code == 16)  /* surface is self-intersecting */
   {
      /* ex$message(msgnumb = EMS_E_OperationFailed);   */
     *msg = EMS_E_Fail;
     goto wrapup; 
   }

     
/* Post the modified geometry into the surface instance data */
  if(extended_surface.bspsf)
  {
    struct GRpost_info	postinfo;

    surface = extended_surface.bspsf;
    postinfo.construct_flag = FALSE;
    stat_OM = om$send(msg = message GRvg.GRpostabsg(&msg_loc, env, &postinfo, 
				                    (IGRchar *)surface, newid),
                      targetid = my_id);
    EMerr_hndlr (!(1&stat_OM&msg_loc), *msg, EMS_E_Fail, wrapup);

    if(mem_allocated && extended_surface.bspsf)
    {
       stat_func = BSfreesf(&rc, extended_surface.bspsf);
       stat_func = GRabsg_del_all();
       mem_allocated = FALSE;
    }
    getsfclassid(extended_surface.type, &new_classid);
    if(new_classid != old_classid)
    {
	    IGRchar cname[OM_K_MAXCLASS_LEN];

	    stat_OM = om$get_classname(classid = new_classid,
				       classname = cname);
    	    EMerr_hndlr (!(1&stat_OM), *msg, EMS_E_Fail, wrapup);

            stat_OM = om$change_class (
                objid = *newid,
                classname = cname,
                sd_override = OM_K_change_class_sd_override);
    	    EMerr_hndlr (!(1&stat_OM), *msg, EMS_E_Fail, wrapup);
    }
    GR_NOTIFY_LISTENERS(*msg, &stat_OM, GR_GEOM_MODIFIED);
  }
wrapup:

    if(mem_allocated && extended_surface.bspsf)
    {
       stat_func = BSfreesf(&rc, extended_surface.bspsf);
       stat_func = GRabsg_del_all();
       mem_allocated = FALSE;
    }
/*
    if(extended_surface.sfgen_cv);
       BSfreecv(&loc_msg, extended_surface.sfgen_cv);
*/
    return(stat_OM);

}

method EMextend_by_dist_from_orig_surf(
               IGRlong *msg;            /* O */
               struct GRmd_env *env;    /* I */
               IGRdouble dist_in[4];    /* I */
               IGRdouble dist_out[4];   /* O */
               IGRint option;           /* I */
               GRobjid orig_surf_id;    /* I */
               GRobjid *newid           /* O */
               )

{
     IGRint      i, extnd_option;
     OMuword     old_classid, new_classid,tmp_cls_id;
     IGRboolean  u_left, u_right, v_left, v_right, stat_func, mem_allocated,
                 uv_closed[2];
     IGRdouble   ext_dist, loc_dist_in[4];
     struct      IGRbsp_surface *surface=NULL, *p_fixsf=NULL;
     struct      IGRbsp_surface *p_sf=NULL, *temp_sf=NULL, *temp_fixsf=NULL;
     IGRshort    out_code = 0;

     struct      BSgeom_bsp_surf extended_surface, surface_to_extend;
     IGRlong     msg_loc, stat_OM, rc;

     IGRboolean   GRabsg_del_all();
     void        BSxgmsfdst();


     *msg = EMS_S_Success;
     stat_OM = OM_S_SUCCESS;
     *newid = my_id;

     surface = NULL;
     extended_surface.bspsf = NULL;
     extended_surface.sfgen_cv = NULL;
     mem_allocated = FALSE;

     if(dist_in[0] == 0.0 && dist_in[1] == 0.0 && dist_in[2] == 0.0 &&
        dist_in[3] == 0.0) goto wrapup;

      for(i=0; i<NUM_PARAMS; i++) loc_dist_in[i] = dist_in[i];
     GRgetabsg(&msg_loc, &env->md_env.matrix_type, env->md_env.matrix,
               (IGRchar **) &surface, i);
     EMerr_hndlr(!(msg_loc & 1), *msg, EMS_E_Fail, wrapup);
    
     getsftype( my_id, OM_Gw_current_OS, &surface_to_extend.type );
     surface_to_extend.bspsf = surface;
     surface_to_extend.bounded = TRUE;
     surface_to_extend.urange[ 0 ] = surface_to_extend.vrange[ 0 ] = 0.0;
     surface_to_extend.urange[ 1 ] = surface_to_extend.vrange[ 1 ] = 1.0;
     surface_to_extend.sfgen_cv = NULL;
     surface_to_extend.geom_prop = FALSE;

     uv_closed[0] = surface->u_phy_closed;
     uv_closed[1] = surface->v_phy_closed;

     /* Get the classid of the surface */
     stat_OM = om$get_classid(object = me, p_classid = &old_classid);
     stat_OM = om$get_classid(objid = orig_surf_id, p_classid = &tmp_cls_id);

/* Now to extend the surface */

   extnd_option = 1; /* polynomial extension */

   for(i=0; i<NUM_PARAMS; i++)
     {
        if(loc_dist_in[i] == 0.0) continue;

       /* No need to extend along a particular direction if the
          surface is closed in that direction  */
        if ((((i == U_LEFT) || (i == U_RIGHT)) && uv_closed[0]) ||
            (((i == V_LEFT) || (i == V_RIGHT)) && uv_closed[1]))
           continue;

        u_left = u_right = v_left = v_right = FALSE;
        switch(i)
        {
              case U_LEFT:
                u_left = TRUE;
                break;
              case U_RIGHT:
                u_right = TRUE;
                break;
              case V_LEFT:
                v_left = TRUE;
                break;
              case V_RIGHT:
                v_right = TRUE;
                break;
              default:
                EMerr_hndlr(TRUE, *msg, EMS_E_Fail, wrapup);
        }
        extended_surface.bspsf = NULL;
        BSxgmsfdst(&surface_to_extend, loc_dist_in[i], extnd_option, u_left,
              u_right, v_left, v_right, &extended_surface, &ext_dist,
              &rc);
      EMerr_hndlr((rc != BSSUCC), *msg, EMS_E_BSerror, wrapup);

        dist_out[i] = ext_dist;
       extended_surface.bspsf->pos_orient =
                                        surface_to_extend.bspsf->pos_orient;

        if(mem_allocated && surface_to_extend.bspsf)
           stat_func = BSfreesf(&rc, surface_to_extend.bspsf);
        surface_to_extend.bspsf = extended_surface.bspsf;
        surface_to_extend.geom_prop = FALSE;
        mem_allocated = TRUE;

        surface = extended_surface.bspsf;
   
        if(option & EMS_opt_extendS_deextend_if_needed)
        {
          IGRboolean    orig_uv_closed, ext_uv_closed;
          IGRdouble     cht, shrink_dist;
          IGRboolean    new_shrink_dist = FALSE;

          BSEXTRACTPAR(&rc, BSTOLCHRDHT, cht);
          orig_uv_closed = (i > U_RIGHT ? uv_closed[1] :
                                          uv_closed[0]);
          ext_uv_closed = (i > U_RIGHT ? surface->v_phy_closed :
                                         surface->u_phy_closed);

/* It is possible sometimes that ext_uv_closed is not present and surface is
   still a self intersecting. This was encountred in TR# 11924856. So surface
   degenracy check was made first and shrink_distance is increased.
*/
   if((extended_surface.type == 97)
              && (! ext_uv_closed)
              && (old_classid == OPP_EMSproject_class_id)
              && (tmp_cls_id == OPP_EMScylindr_class_id))
   {
    temp_sf = extended_surface.bspsf;

    BSallocsf(temp_sf->u_order, temp_sf->v_order, temp_sf->u_num_poles,
              temp_sf->v_num_poles, temp_sf->rational, temp_sf->num_boundaries,
              &temp_fixsf, &rc);
   if( rc == BSSUCC)

   /* Check the surface for self-intersection.
    */
    {
     BSchkfxsf (extended_surface.bspsf,1, temp_fixsf, &out_code, &rc);
     if(rc == BSSUCC)
      {
       BSfreesf (&rc, temp_fixsf);
       temp_fixsf = NULL;
      }
    else out_code = 0;
    }
    if((extended_surface.type == 97)&& (out_code == 16)&& (! ext_uv_closed))
     {
          new_shrink_dist = 1;
          ext_uv_closed = 1;
     }
      else     new_shrink_dist = 0;
    }
    shrink_dist = 0.0;
    if(!orig_uv_closed && ext_uv_closed) /* needs de-extension */
     {
      if(new_shrink_dist) {
                           shrink_dist =(((dist_in[i]/9.0 - cht) < cht)?
                                          (dist_in[i]/9.0) :
                                          (dist_in[i]/5.0));
                           }
      else shrink_dist = 2 * cht;

       if((i == U_LEFT || i == V_LEFT))
       if(loc_dist_in[i + 1] > 0)     /* ext. dist in U_RIGHT or V_RIGHT
                                         is greater than zero
                                       */

     {
       loc_dist_in[i + 1] = shrink_dist;  /* reduce the extension
                                             in the other direc to
                                             a minimum.
                                          */
       shrink_dist = 2 * shrink_dist;   /* ensure the surface will
                                           remain open.
                                         */
     }

     else if( loc_dist_in[i + 1] < 0 )
           shrink_dist = 0.0;             /* de-extension not needed */

           dist_out[i] = dist_out[i] - shrink_dist;
     
            if(shrink_dist > 0.0)
            {
              BSxgmsfdst(&surface_to_extend, -1.0 * shrink_dist, extnd_option,
                         u_left, u_right, v_left, v_right, &extended_surface,
                         &ext_dist, &rc);
              EMerr_hndlr((rc != BSSUCC), *msg, EMS_E_BSerror, wrapup);

              surface = extended_surface.bspsf;
              ext_uv_closed = (i > U_RIGHT ? surface->v_phy_closed :
                                             surface->u_phy_closed);

              EMerr_hndlr(ext_uv_closed, *msg, EMS_E_Fail, wrapup);

              extended_surface.bspsf->pos_orient =
                                        surface_to_extend.bspsf->pos_orient;

              if(mem_allocated && surface_to_extend.bspsf)
                 stat_func = BSfreesf(&rc, surface_to_extend.bspsf);
              surface_to_extend.bspsf = extended_surface.bspsf;
              surface_to_extend.geom_prop = FALSE;
              mem_allocated = TRUE;
            } /* if(shrink_dist > 0.0) */
           } /* if(!orig_uv_closed && ext_uv_closed) */
          } /* if(option & .... ) */
        surface_to_extend.type = extended_surface.type;
       } /* for(i=0; .... */

    if(extended_surface.bspsf &&
             (option & EMS_opt_extendS_reparametrize_surface))
     {
          void BSarclnpars();

          /* Reparametrize the surface */
          BSarclnpars(&msg_loc, REPARAMETRIZE_IN_U_AND_V,
                                   extended_surface.bspsf);
          if(msg_loc != BSSUCC)
          {
             *msg = MSFAIL;
             goto wrapup;
          }
     }
     p_sf = extended_surface.bspsf;
     BSallocsf (p_sf->u_order, p_sf->v_order, p_sf->u_num_poles,
              p_sf->v_num_poles, p_sf->rational, p_sf->num_boundaries,
              &p_fixsf, &rc);
     EMerr_hndlr( rc != BSSUCC, *msg, EMS_E_BSerror, wrapup);

    /* Check the surface for self-intersection. If so, error out rather
      than proceeding further and creating an invalid solid. Hari
    */

    BSchkfxsf (extended_surface.bspsf,0, p_fixsf, &out_code, &rc);
    BSfreesf (&rc, p_fixsf); p_fixsf = NULL;
    EMerr_hndlr( rc != BSSUCC, *msg, EMS_E_BSerror, wrapup);

   if(out_code == 16)  /* surface is self-intersecting */
   {
      ex$message(msgnumb = EMS_E_OperationFailed);
     *msg = EMS_E_Fail;
     goto wrapup;
   }
/* Post the modified geometry into the surface instance data */
  if(extended_surface.bspsf)
  {
    struct GRpost_info  postinfo;

    surface = extended_surface.bspsf;
    postinfo.construct_flag = FALSE;
    stat_OM = om$send(msg = message GRvg.GRpostabsg(&msg_loc, env, &postinfo,
                                                    (IGRchar *)surface, newid),
                      targetid = my_id);
    EMerr_hndlr (!(1&stat_OM&msg_loc), *msg, EMS_E_Fail, wrapup);

    if(mem_allocated && extended_surface.bspsf)
    {
       stat_func = BSfreesf(&rc, extended_surface.bspsf);
       stat_func = GRabsg_del_all();
       mem_allocated = FALSE;
    }
    getsfclassid(extended_surface.type, &new_classid);
    if(new_classid != old_classid)
    {
     IGRchar cname[OM_K_MAXCLASS_LEN];
     stat_OM = om$get_classname(classid = new_classid,
                                classname = cname);
     EMerr_hndlr (!(1&stat_OM), *msg, EMS_E_Fail, wrapup);

     stat_OM = om$change_class (
                                objid = *newid,
                                classname = cname,
                                sd_override = OM_K_change_class_sd_override);
     EMerr_hndlr (!(1&stat_OM), *msg, EMS_E_Fail, wrapup);
    }
    GR_NOTIFY_LISTENERS(*msg, &stat_OM, GR_GEOM_MODIFIED);
  }
  wrapup:

    if(mem_allocated && extended_surface.bspsf)
    {
       stat_func = BSfreesf(&rc, extended_surface.bspsf);
       stat_func = GRabsg_del_all();
       mem_allocated = FALSE;
    }
/*
    if(extended_surface.sfgen_cv);
       BSfreecv(&loc_msg, extended_surface.sfgen_cv);
*/

     return(stat_OM);
}

end implementation EMSsubbs;
  
