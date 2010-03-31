/* ###################   APOGEE COMPILED   ################## */
/*
 * METHOD:
 *  
 *  EMdim and EMdimparam
 *
 * DESCRIPTION:
 *
 *  These are the autodimension methods for general composite surfaces.
 *
 * HISTORY:
 *  Sudhakar:23Dec'93: Speeded up the auto-dimensioning by avoiding
 *                     projections for "outward" offset.
 *  Sudhakar:27Nov'93: Modified args of the function 
 *                     'EFget_edge_near_point_on_sf'.
 *  Sudhakar:24Sep'93: Modified to perform 'auto-dimensioning' based on
 *                     'surface' parents and 'uv' data in 'recompute' info.
 *                     Pulled out 'edge' parents dependence.
 *  Sudhakar:21Jun'93: Added code to handle autodimensioning of 
 *                     'thinwall from composite surface'. Works
 *                     only for uniform offset.
 *  Tapadia 03/16/92 - Do not dimension solid of projection with planes
 *   			(EMS_ASsolid_proj_by_trim_st_end_plane &
 *			EMS_ASsolid_proj_by_trim_end_plane) 
 *  DLB    mod fillet to use txt-w-leader 9/15/91
 *  jhw    Creation         06/12/91
 */
class implementation EMSgensolid;

#include "OMmacros.h"
#include "dimdef.h"
#include "gocmacros.h"
#include "bserr.h"
#include "dimplcmacros.h"
#include "REgencompsf.h"
#include "REgensolid.h"
#include "REshsolid.h"

#define SURFACE         0
#define OFFSET          1

#define XYZ_POINT   1
#define UV_POINT    2

#define USE_PROJECT 1
#define USE_KEY     2

#define REVERSE_NORMAL 1

from EMSparamgm import EMgetgeom;
from expression import NDgive_value;
from EMSedge import EMgetsurface_info, EMinternalpt, EMtangent;
from EMSsubbs import EMpartolbasis, EMget_unit_norm;
from EMSpointer import EMpass;


extern OMuword OPP_DMroot_class_id;

method EMdim ( IGRlong             * msg;
               struct GRmd_env     * mod_env;
               IGRushort     options;
               IGRint                type;
               IGRchar             * info;
               IGRint                num_parents;
               struct GRid         * parents )
{
    IGRlong       om_msg = OM_S_SUCCESS, msg_loc;
    struct GRid   assoc_id, source_id, dim_id;
    IGRpoint      dumpt;
    IGRint        trak_dir, ii;
    IGRdouble     trak_dist;
    struct EMSshell_solid  *recomp;
    IGRint        dimcount, add_value, num_mult_tks;

    msg_loc = *msg = EMS_S_Success;

    if(type == EMS_ASsolid_proj_by_trim_st_end_plane ||
	type == EMS_ASsolid_proj_by_trim_end_plane) {
	goto ret_end;
    }


    dumpt[0] = dumpt[1] = dumpt[2] = 0.0;

    assoc_id.objid = my_id;
    assoc_id.osnum = OM_Gw_current_OS;

    EFget_parent_source (&assoc_id, &source_id);

    dimcount = 1;
    add_value = 1;  /* Since the dimension parent is the second one for
                       other than thinwall from compsurf. */

    if(type == EMS_ASthinwall_from_compsurf)
    {
    /* Get the 'number of multiple thicknesses' from the recompute-info.
     *  The first one is the 'common thickness'. The rest are
     *  multiple thicknesses.
     */

      recomp = (struct EMSshell_solid *) info;
      num_mult_tks = recomp->num_mult_tks;
      dimcount = num_mult_tks + 1;
      add_value = 0;   /* Since dimensions are the first parents for
                          thinwall from compsurf. */
    }

    for(ii = 0; ii < dimcount; ii++)
    {
    /*
     * Perform the appropriate auto-dimensioning.
     */
            /*
             * If the offset value is not already dimensioned ...
             */
            if (!( EFselect_first_component( &parents[ii+add_value], 
                                             OPP_DMroot_class_id, 
                                             &dim_id ) & 1))
            {
                dim_id.objid = NULL_OBJID;

                trak_dir = 1;
                trak_dist = 0.0;

                dm$place_sglpara ( orig_grid    = &source_id,
                                   orig_pt      = dumpt,
                                   plane_grid   = &source_id,
                                   brk_pos      = BRK_LEFT,
                                   trak_dir     = trak_dir,
                                   trak_dist    = trak_dist,
                                   owner        = &parents[ii+add_value],
                                   dim_grid     = &dim_id );
                if (dim_id.objid == NULL_OBJID){*msg=EMS_E_Fail;goto ret_end;}

            }
     }
ret_end:

    EMWRAPUP (*msg, om_msg, "EMSgencompsf.EMdim")

    return (om_msg);
}

method EMdimparam ( IGRlong            * msg; 
                    struct GRmd_env    * mod_env;
                    IGRushort    options;
                    IGRint               type;
                    IGRchar            * info;
                    IGRint               num_parents;
                    struct GRid        * parents;
                    IGRint               index; 
                    struct IGRplane    * dim_plane;
                    IGRdouble          * dim_plane_xaxis;
                    struct EMSgeomdata * dim_geom;
                    IGRint             * dim_type )
{
    IGRlong                 msg_loc, ma_msg, om_msg = OM_S_SUCCESS;
    IGRint                  i, ii;
    IGRdouble               offset, half_offset;
    struct IGRbsp_surface * bspsurface;
    OM_S_CHANSELECT         to_components_chansel;
        struct GRid surf_id;
        IGRpoint    point1, point2;
        IGRdouble   parms[2];
        IGRvector   xaxis, yaxis, zaxis;
        struct EMSoffset_simple_surface  *ofset_info;

    IGRpoint            dimplpt;
    IGRvector           dimplnor, dimplxaxis;
    IGRdouble           dimgeom[6];
    IGRdouble           distance;
    struct EMSshell_solid  *recomp;
    struct mult_tk_surfs_views *mult_tk_sfs;
    IGRboolean          is_inward, is_symmetric;
    OMuword             best_view_index = 0;
    IGRint              parent_surf_index, num_mult_tks;
    struct  GRid        surf_pointer_GRid, dimension_surf_GRid,
                        dimension_edge_GRid;
    IGRpoint            uv_point;
    GRobjid             nearest_edge, new_surf, new_ed;

    extern IGRlong EFget_dimension_plane_and_geom();
    extern IGRlong EFget_edge_near_point_on_sf();
    extern IGRlong EFfind_outer_surface_and_edge_by_ptproject();

    EMmake_chanselect (GRcmpowner_to_components, &to_components_chansel);

    *msg = msg_loc = EMS_S_Success;
    
    if(type == EMS_ASthinwall_from_compsurf)
    {
      /* Determine whether the thinwall solid is 'inward', 'outward' or
         'symmetric' */

      recomp = (struct EMSshell_solid *) info;
      is_inward = recomp->inward;
      is_symmetric = recomp->is_symmetric;

      /* determine the shell solid thickness   */
      om_msg = om$send (msg = message expression.NDgive_value (&distance),
             targetid = parents[index].objid);
      EMerr_hndlr (EMSerror (om_msg), *msg, EMS_E_InvalidCase, ret_end);

      /* Determine the Dimension plane point, Dimension plane normal
         and the Dimension Geometry for the associative solid
         which may be a Drafted Solid, a Revolve Solid or a Projected Solid */

      /* Get the parent-index and dimension-edge-object corresponding to the
         current thickness  */

      num_mult_tks = recomp->num_mult_tks;
      parent_surf_index = 1 + num_mult_tks;

      mult_tk_sfs = recomp->sfs_views;

      if(index > 0)     /* refers to a multiple thickness */
      {
         parent_surf_index++;  /* Index to first multiple thick surface */

         for(ii=1; (ii<index) && (index <= num_mult_tks); ii++)
                parent_surf_index += mult_tk_sfs[ii].num_sfs_per_mult_tks;
      }

      OM_BLOCK_MOVE(&parents[parent_surf_index], &surf_pointer_GRid,
                                          sizeof(struct GRid));

      om_msg = om$send (msg = message EMSpointer.ASreturn_go
                               (&dimension_surf_GRid,
                                &mod_env->md_env.matrix_type,
                                mod_env->md_env.matrix),
                   targetid = surf_pointer_GRid.objid,
                   targetos = surf_pointer_GRid.osnum,
                   senderid = NULL_OBJID);
      EMerr_hndlr(!(1 & om_msg) || dimension_surf_GRid.objid == NULL_OBJID,
                                           *msg, EMS_E_Fail, ret_end);

      /* 'uv' point */
      uv_point[0] = mult_tk_sfs[index].uv_point[0];
      uv_point[1] = mult_tk_sfs[index].uv_point[1];

      /* Determine the edge nearest to the 'uv' point on the surface */

      om_msg = EFget_edge_near_point_on_sf(&msg_loc, mod_env,
                                          dimension_surf_GRid,
                                          UV_POINT,
                                          uv_point,
                                          NULL,  /* want an edge in anycase */
                                          &nearest_edge, NULL, NULL);
      EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_EdgeError, ret_end);

      dimension_edge_GRid.objid = nearest_edge;
      dimension_edge_GRid.osnum = dimension_surf_GRid.osnum;

     /* Obtain the surface and edge on the 'Gen. Solid' corresponding to these.
        The corresponding surface and edge will be used for dimensioning. 
        Do this only for the "symmetric" case as this is a time consuming op. */
      if(is_symmetric)
      {
     
        om_msg = EFfind_outer_surface_and_edge_by_ptproject(&msg_loc, mod_env,
                               USE_PROJECT,
                               is_inward, is_symmetric, distance,
                               my_id,
                               dimension_surf_GRid, dimension_edge_GRid,
                               &new_surf, &new_ed);
        EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);
        dimension_surf_GRid.objid = new_surf;
        dimension_edge_GRid.objid = new_ed;
      }

     /* Get the view index from the instance data */
      if(!(index > recomp->num_mult_tks))
        best_view_index =  mult_tk_sfs[index].best_view_index;
      else
      {
#ifdef DEBUG
        printf("Error - 'index' exceeds 'num_mult_tks' \n");
#endif
        goto ret_end;
      }

      EFget_dimension_plane_and_geom(&msg_loc, 
                                   mod_env, 
                                   (is_inward || is_symmetric ? 0 : 1),
                                   &distance,
                                   dimension_surf_GRid,
                                   dimension_edge_GRid,
                                   best_view_index,
                                   &dimplpt[0],
                                   &dimplnor[0],
                                   &dimplxaxis[0],
                                   &dimgeom[0]);

      if (dim_plane)
      {
          memcpy (dim_plane->point, dimplpt, sizeof(IGRpoint));
          memcpy (dim_plane->normal, dimplnor, sizeof (IGRvector));
      }

      if (dim_plane_xaxis)
      {
          memcpy (dim_plane_xaxis, dimplxaxis, sizeof (IGRvector));
      }
      if (dim_geom)
          for (i=0; i<3; ++i)
           {
            /* Ensure the dimension is always drawn outside for
               closed surface situations. */
            /* Reverse the dim. points only for outward offset */
             point1[i] =  ((is_inward || is_symmetric) ?
                                            dimgeom[i] : dimgeom[i+3]);
             point2[i] =  ((is_inward || is_symmetric) ?
                                            dimgeom[i+3] : dimgeom[i]);
           };
    }
    else
    {

        ma_msg = BSSUCC;

        ofset_info = (struct EMSoffset_simple_surface *)info;

        parms[0] = parms[1] = 0.0;

        /* get the parent surface id */

        om_msg = om$send ( msg = message NDnode.ASreturn_go 
                                                ( &surf_id,
                                                  &mod_env->md_env.matrix_type,
                                                  mod_env->md_env.matrix ),
                       targetid = parents[SURFACE].objid,
                       targetos = parents[SURFACE].osnum );

        EMerr_hndlr (EMSerror (om_msg), *msg, EMS_E_Fail, ret_end);

        /*   Determine my surface geometry.  */

        om_msg = om$send ( msg = message GRvg.GRgenabsg
                                            ( &msg_loc,
                                              &mod_env->md_env.matrix_type,
                                              mod_env->md_env.matrix,
                                              (IGRchar **)&bspsurface ),
                           targetid = surf_id.objid,
                           targetos = surf_id.osnum );
                           
        EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);

        BSsfptseval (bspsurface, 1, parms, point1, &ma_msg);

        parms[0] = parms[1] = 1.0;
        BSsfptseval (bspsurface, 1, parms, point2, &ma_msg);

        if (dim_geom || dim_plane || dim_plane_xaxis)
        {

            /* * Determine the xaxis; */

            EMavgsfnorm(&msg_loc,bspsurface,parms[0],parms[1],point1,xaxis);

	    om_msg = om$send(msg= message expression.NDgive_value(&offset),
			targetid = parents[OFFSET].objid,
			targetos = parents[OFFSET].osnum);
            EMerr_hndlr (EMSerror (om_msg), *msg, EMS_E_Fail, ret_end);

            if( !( ofset_info->props & EMS_NATURAL_NORMAL) )
               offset *= -1;
            
            if(ofset_info->props & EMS_SYMMETRIC_OFFSET)
            {
             /* Reposition the first point for symmetric offset case */
              half_offset = offset * -0.5;
              for(ii=0;ii<3;ii++)
                  point1[ii]=point1[ii] + xaxis[ii]*half_offset;
            } 

            for(ii=0;ii<3;ii++)
                point2[ii]=point1[ii] + xaxis[ii]*offset;

            /* * Determine the y and z axis.  */

            EFget_normal_from_axis (&msg_loc,
                                    &parents[OFFSET],
                                    mod_env,
                                    xaxis,
                                    yaxis,
                                    zaxis);

            /* * Determine the dimension plane.  */

            if (dim_plane)
            {
                memcpy (dim_plane->point, point1, sizeof(IGRpoint));
                memcpy (dim_plane->normal, zaxis, sizeof(IGRvector));
            }

            /* * Set x_axis.  */

            if (dim_plane_xaxis)
                memcpy (dim_plane_xaxis, xaxis, sizeof(IGRpoint));
        }
    }

    /* * Return the dimension type.  */

    if (dim_type)
          *dim_type = SINGLE_PARALLEL;

    /* * Return the dimension geometry.  */

    if (dim_geom)
    {
        dim_geom->geomtype = GEOMDATA_LINE;
        dim_geom->line.igr_line.point1 = dim_geom->line.line_pt1;
        dim_geom->line.igr_line.point2 = dim_geom->line.line_pt2;
        memcpy (dim_geom->line.line_pt1, point1, sizeof(IGRpoint));
        memcpy (dim_geom->line.line_pt2, point2, sizeof(IGRpoint));
    }

ret_end:
    EMWRAPUP (*msg, om_msg, "EMSgnsolid.EMdimparam");
    return (om_msg);
}
end implementation EMSgensolid;

