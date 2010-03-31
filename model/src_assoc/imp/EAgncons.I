/**********

NOTE, NOTE, NOTE:

DO NOT ACCESS ANY INSTANCE DATA DIRECTLY IN THIS METHOD!!!! THE CLASS OF
OBJECT MAY CHANGE DURING 'EMconvert_into_plane()' call. THE ONLY WAY TO ACCESS
INSTANCE DATA IN SUCH A CASE IS TO SEND A MESSAGE. FOR e.g DO NOT USE
ME.GRgraphics->properties DIRECTLY. INSTEAD SEND GRchgprops MESSAGE.

	SM	04-Jun-92	
       Jack     12-Feb-93  Changed om$send EMSgenbs.EMruled_surface to
                           EMSsubbs.EMruled_surface since message def.
                           was moved.  

       Sudha	06/01/93   Modified to add BSprototype headers

*************/
class implementation EMAgenbs;

#include "EMS.h"
#include "OMmacros.h" /* For OM_BLOCK_MOVE */
#include "EMSdpb.h"
#include <stdio.h>
#include "EMSas.h"
#include "REagrp.h"
#include "bserr.h"
#include "bsparameters.h"
#include "EMSdef.h"
#include "EMSopt.h"
#include "EMSconstruct.h"
#include "mascalvc.h"
#include "bsparameters.h"
#include "bscvarrev0.h"
#include "bschangepar.h"
#include "bssfeval.h"
#include "bsprptonsf.h"
#include "bssnorkts.h"


#define INITIAL 20
#define MAXIMUM_CURVES 200

#define BASE        0
#define WIDTH       1
#define WIDTH_VEC   2
#define HEIGHT      3
#define HEIGHT_VEC  4
#define LENGTH      5
#define LENGTH_VEC  6

#define X_BOX       0
#define Y_BOX       1
#define Z_BOX       2

#define DO_CONVERT_SURFACES_INTO_PLANES 0

/* Externs */


method EMconstruct_associative(IGRlong *EMmsg;
                                IGRushort const_options;
                                OM_S_OBJID old_objid;
                                IGRint nb_root;
                                IGRchar *parent_info;
                                IGRint type;
                                IGRchar *recomp_info;
                                struct GRvg_construct *construct_list)
/* ************************************************************************

Description

 This method serves as the central processing method for placing all
associative free form surfaces constructions.It expects construct_list
and module environment to be passes. The number of roots and the list
of roots has to be passed and the recomputation information.

Arguments
 Input
  nb_root : Number of roots.
  type : Type to interpret the recomputation information.
  old_objid : Objid of the object which has gotten a recompute message.
  const_options : Currently can be set to NULL.
  parent_info : Information about parents.
  env : Module environment of the master file.
  construct_list : construction information
  info : Recomputation information. This better not be NULL.

 Output
  EMmsg : Completion message.

Notes
 Upon exit the completion code will be one of the following:
  EMS_S_Success : If all goes well.
  EMS_E_SurfaceError : If there is an error in doing one of these:
           a) Get the surface definition
  EMS_E_Fail : For fatal errors whose exact cause cannot be determined.

History
 09/29/89 : PP     : Revamped the earlier methods to cause a significant amount
                     of code reduction.
 03/04/91 : PP     : Reworked for EMS 2.0
 04/02/91 : jhw    : Added box by 4pts and tube.
 06/17/91 : jhw    : Added autodimensioning for box by 4pts.
 08/25/94 : Sanjay : Added code for ruled surface recomputation to take care
                     of the non-normalized geometrices created before EMS 3.1.
*********************************************************************** */

{
 IGRlong status;
 union EMSparent_info *roots = NULL;
 IGRuint root_count;
 IGRshort i, j;
 IGRuint *root_type = NULL;
 IGRint surface_type;
 struct GRid my_GRid;
 IGRboolean convert_into_plane = FALSE;

 status = OM_S_SUCCESS;
 *EMmsg = EMS_S_Success;

 my_GRid.objid = my_id;
 my_GRid.osnum = OM_Gw_current_OS;
 surface_type = type;

 root_count = nb_root;
 root_type = (IGRuint *) stackalloc(sizeof(IGRint) * root_count);
 EMerr_hndlr(!root_type, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);

 status = om$send (msg = message EMAgenbs.EMget_parent_type(EMmsg, 
                         surface_type,
                         root_count,
                         root_type),
                   targetid = my_id);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);

 roots = (union EMSparent_info *)stackalloc(root_count*
              sizeof(union EMSparent_info));
 EMerr_hndlr(!roots, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);

 status = om$send (msg = message EMSassoc.EMget_parent_info(EMmsg, NULL,
                         root_count,
                         parent_info,root_type, roots),
                   targetid = my_id);
 EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);

 switch (type)
 {
  case EMS_ASsurface_by_bound:
  {
   union EMSparent_info *ptr_root_struct = NULL;
   struct GRlc_info **lc_info = NULL;

   lc_info = (struct GRlc_info **) stackalloc(
                     sizeof (struct GRlc_info *) * root_count);
   EMerr_hndlr(!lc_info, *EMmsg, EMS_E_DynamicMemoryAllocated, 
               wrapup);

   ptr_root_struct = roots;

   for (i=0;i<root_count;i++)
   {
      lc_info[i] = (struct GRlc_info *) ptr_root_struct;
/*
 * The cross-sections are never reversed.
 */
      lc_info[i]->geom_parms.polygon_inx = 0;
      ++(ptr_root_struct);
   }

    status = om$send(
      msg = message EMSgenbs.EMbs4cvs(
       EMmsg,
       lc_info[0], NULL,       /* No buffer */
       lc_info[1], NULL,       /* No buffer */
       lc_info[2], NULL,       /* No buffer */
       ((root_count == 4 ) ? lc_info[3] : NULL), NULL,
       FALSE,                                   /* Natural side */
       construct_list),
      targetid = my_id);
     EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);
  }
  break;

  case EMS_ASdirect_fit_surface:
  case EMS_ASsurface_by_poles:
  case EMS_ASleast_squares_fit_surface:
  case EMS_ASdirect_fit_surface_by_curves:
  case EMS_ASnetwork_of_curves:
  case EMS_ASfitted_surface:
  {
   struct EMdpbinfo dpbinfo;
   IGRlong	u_order;
   IGRlong	v_order;
   IGRboolean	u_periodic;
   IGRboolean	v_periodic;
   unsigned char *rev_info;
   struct IGRbsp_surface surf;
   IGRdouble	average_error, maximum_error;
   IGRlong max_indicator[2];
   IGRpoint error_line[2];
   union EMSparent_info *ptr_root_struct = NULL;
   struct GRlc_info *lc_info = NULL;
   struct EMSnetwork_of_curves *network_info;
   struct EMSfitted_surface *fitted_surface_info;
   IGRint i;

   lc_info = (struct GRlc_info *) stackalloc(
                     sizeof (struct GRlc_info) * root_count);
   EMerr_hndlr(!lc_info, *EMmsg, EMS_E_DynamicMemoryAllocated, 
               wrapup);

   switch (surface_type)
   {
    case EMS_ASsurface_by_poles:
    case EMS_ASdirect_fit_surface:
    case EMS_ASdirect_fit_surface_by_curves:
     rev_info = (unsigned char *)recomp_info;
    break;

    case EMS_ASnetwork_of_curves:
     network_info = (struct EMSnetwork_of_curves *) recomp_info;
     rev_info = (unsigned char *) network_info->rev_info;
    break;

    case EMS_ASfitted_surface:
     fitted_surface_info = (struct EMSfitted_surface *) recomp_info;
     rev_info = (unsigned char *) fitted_surface_info->rev_info;
    break;
   }

   ptr_root_struct = roots;

   for (i=0;i<root_count;i++)
   {
      OM_BLOCK_MOVE(ptr_root_struct, &lc_info[i], sizeof (struct GRlc_info));
      lc_info[i].geom_parms.polygon_inx = rev_info[i];
      ++(ptr_root_struct);
   }

   if (old_objid == NULL_OBJID)
   {
    EMdpb_getinfo(EMmsg, &dpbinfo);
    EMerr_hndlr(!(1&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

    u_order = dpbinfo.u_order;
    v_order = dpbinfo.v_order;
    u_periodic = (dpbinfo.props & EMDPB_U_PERIODIC ? 1 : 0);
    v_periodic = (dpbinfo.props & EMDPB_V_PERIODIC ? 1 : 0);
   }
   else 
   {
    status = om$send (msg = message EMSsubbs.EMgetbsdef( EMmsg,
                            &surf),
                      targetid = old_objid);
    EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_SurfaceError, wrapup);
    u_order = surf.u_order;
    v_order = surf.v_order;
    u_periodic = surf.u_periodic;
    v_periodic = surf.v_periodic;
   }

    switch (surface_type)
    {
     case EMS_ASsurface_by_poles:
     status = om$send (
              msg = message EMSgenbs.EMsurface_by_poles(
                    u_order,
                    v_order,
                    u_periodic,
                    v_periodic,
                    root_count,
                    lc_info,
                    construct_list),
              targetid = my_id);
     EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);
     break;


     case EMS_ASdirect_fit_surface:
     status = om$send(
              msg = message EMSgenbs.EMdirect_fit_surface(
                    u_order,
                    v_order,
                    u_periodic,
                    v_periodic,
                    root_count,
                    lc_info,
                    construct_list),
              targetid = my_id);
     EMerr_hndlr(!(1&status), *EMmsg, EMS_E_Fail, wrapup);
     break;

     case EMS_ASdirect_fit_surface_by_curves:
     status = om$send(
              msg = message EMSgenbs.EMdirect_fit_surface_by_curves(
                    v_order,
                    v_periodic,
                    root_count,
                    lc_info,
                    construct_list),
              targetid = my_id);
     EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
     break;

     case EMS_ASleast_squares_fit_surface:
     break;

     case EMS_ASfitted_surface:
     {
       IGRdouble save_cht;
       IGRlong rc;
       BSEXTRACTPAR(&rc, BSTOLCHRDHT, save_cht);
       BSchangepar(&rc, BSTOLCHRDHT, fitted_surface_info->cht);
      
       status = om$send (
           msg = message EMSgenbs.EMleast_squares_fit_surface(
                 u_order,
                 v_order,
                 u_periodic,
                 v_periodic,
                 root_count,
                 lc_info,
                 0, 
                 0,
                 &average_error,
                 &maximum_error,
                 max_indicator,
                 error_line,
                 construct_list),
           targetid = my_id);
       BSchangepar(&rc, BSTOLCHRDHT, save_cht);
       EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
     }
     break;

     case EMS_ASnetwork_of_curves:
     {
      IGRint number_of_curves_1,
             number_of_curves_2; 

      number_of_curves_1 = network_info->numu;
      number_of_curves_2 = network_info->numv;

      status = om$send (
               msg = message EMSgenbs.EMnetwork_of_curves(
                EMmsg, construct_list, number_of_curves_1,
                lc_info, number_of_curves_2, &lc_info[number_of_curves_1]),
               targetid = my_id);
      EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
     }
     break;
    }
  }
  break;

  case EMS_ASskinning_surface:
  {
   IGRlong curve_index;
   struct EMSskinning_surface *cs_info;
   struct GRlc_info *cross_sections;
   struct GRlc_info *traces;
   struct GRlc_info *tangent_surfaces;
   struct IGRbsp_curve *shape_law, *orient_law;
   union EMSparent_info *ptr_root_struct = NULL;
   IGRint cnt = 0;
   IGRboolean surface_is_open = FALSE, absolute_orientation = FALSE, 
      no_height_scaling = FALSE;
   extern void EMget_lawcurve();

   cross_sections = NULL;
   traces = NULL;
   tangent_surfaces = NULL;
   shape_law = NULL;
   orient_law = NULL;

   cs_info = (struct EMSskinning_surface *) recomp_info;

   cross_sections = (struct GRlc_info *) stackalloc ( 
                      sizeof (struct GRlc_info) * cs_info->number_of_sections);
   EMerr_hndlr(!cross_sections, *EMmsg, EMS_E_DynamicMemoryAllocated, 
                wrapup);

   traces = (struct GRlc_info *) stackalloc ( 
                sizeof (struct GRlc_info) * cs_info->number_of_trace_curves);
    EMerr_hndlr(!traces, *EMmsg, EMS_E_DynamicMemoryAllocated, 
                wrapup);

    if (cs_info->tangent_surf_props)
    {
     tangent_surfaces = (struct GRlc_info *) stackalloc ( 
                sizeof (struct GRlc_info) * 4);
     EMerr_hndlr(!tangent_surfaces, *EMmsg, EMS_E_DynamicMemoryAllocated, 
                wrapup);
    }
    
    ptr_root_struct = roots;

   for (i=0;i<cs_info->number_of_sections;i++,cnt++)
   {
      cross_sections[i].located_obj = ptr_root_struct->grobj.grid;
      cross_sections[i].module_info = ptr_root_struct->grobj.env;
      cross_sections[i].geom_parms.polygon_inx = cs_info->chardata[cnt];
      ++(ptr_root_struct);
   }
    
   for (i=0;i<cs_info->number_of_trace_curves;i++,cnt++)
    {
      traces[i].located_obj = ptr_root_struct->grobj.grid;
      traces[i].module_info = ptr_root_struct->grobj.env;
      traces[i].geom_parms.polygon_inx = cs_info->chardata[cnt];
      ++(ptr_root_struct);
    }

    if ((cs_info->number_of_trace_curves <= 2) &&
        (cs_info->number_of_sections == 2) &&
         (cs_info->skinning_surf_props & EMS_IS_SURFACE_OPEN))
    {
     if (cs_info->skinning_surf_props & EMS_IS_ORIENTATION_LAW)
     {
      EMget_lawcurve(
        EMmsg,
        &cs_info->chardata[cnt],
        &curve_index,
        &orient_law);
      cnt += strlen(cs_info->chardata[cnt]) + 1;
     }

     if (cs_info->skinning_surf_props & EMS_IS_SHAPE_LAW)
     {
      EMget_lawcurve(
        EMmsg,
        &cs_info->chardata[cnt],
        &curve_index,
        &shape_law);
     }
    }

    if (cs_info->tangent_surf_props)
    {
    if (cs_info->tangent_surf_props & EMS_FIRST_SURF)
    {
      tangent_surfaces[0].located_obj = ptr_root_struct->grobj.grid;
      tangent_surfaces[0].module_info = ptr_root_struct->grobj.env;
      ++(ptr_root_struct);
    }
    else
      tangent_surfaces[0].located_obj.objid = NULL_OBJID;

    if (cs_info->tangent_surf_props & EMS_SECOND_SURF)
    {
      tangent_surfaces[1].located_obj = ptr_root_struct->grobj.grid;
      tangent_surfaces[1].module_info = ptr_root_struct->grobj.env;
      ++(ptr_root_struct);
    }
    else
      tangent_surfaces[1].located_obj.objid = NULL_OBJID;

    if (cs_info->tangent_surf_props & EMS_THIRD_SURF)
    {
      tangent_surfaces[2].located_obj = ptr_root_struct->grobj.grid;
      tangent_surfaces[2].module_info = ptr_root_struct->grobj.env;
      ++(ptr_root_struct);
    }
    else
      tangent_surfaces[2].located_obj.objid = NULL_OBJID;

    if (cs_info->tangent_surf_props & EMS_FOURTH_SURF)
    {
      tangent_surfaces[3].located_obj = ptr_root_struct->grobj.grid;
      tangent_surfaces[3].module_info = ptr_root_struct->grobj.env;
      ++(ptr_root_struct);
    }
    else
      tangent_surfaces[3].located_obj.objid = NULL_OBJID;
    }
    else
      tangent_surfaces = NULL;

    if (!(cs_info->skinning_surf_props & EMS_IS_HEIGHT_SCALING))
      no_height_scaling = TRUE;
    if (cs_info->skinning_surf_props & EMS_IS_SURFACE_OPEN)
      surface_is_open = TRUE;
    if (cs_info->skinning_surf_props & EMS_IS_ABSOLUTE_ORIENTATION)
      absolute_orientation = TRUE;

    if (cs_info->skinning_surf_props & EMS_IS_ARC_LENGTH_PARAM)
     *EMmsg = EMS_I_ArcLenPar;

    status = om$send(
            msg = message EMSgenbs.EMplace_skinning_surface(
             EMmsg, 
             construct_list, 
             cs_info->number_of_trace_curves,
             traces,
             cs_info->number_of_sections,
             cross_sections,
             surface_is_open,
             tangent_surfaces,
             absolute_orientation,
             no_height_scaling,
             shape_law,
             orient_law),
            targetid = my_id);
    if (shape_law) free(shape_law);
    if (orient_law) free(orient_law);
    EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
   }
   break; 

  case EMS_ASblend_exterior:
  {
   IGRboolean is_blend_reversed;
   struct EMSblend_surface_exterior *blend_info;
   IGRshort side_1, side_2;
   IGRpoint blend_dir_pt1, blend_dir_pt2;
   IGRboolean surf1_reversed, surf2_reversed;

   blend_info = (struct EMSblend_surface_exterior *) recomp_info;
   if (blend_info->props & EMS_SURF1_REVERSED)
     surf1_reversed = TRUE;
   else
     surf1_reversed = FALSE;

   if (blend_info->props & EMS_SURF2_REVERSED)
     surf2_reversed = TRUE;
   else
     surf2_reversed = FALSE;
   side_1 = blend_info->side_1;
   side_2 = blend_info->side_2;

   if (blend_info->props & EMS_BLEND1_REVERSED)
    is_blend_reversed = 1;
   else
    is_blend_reversed = 0;

   status = EFret_blend_dirinfo (EMmsg, EMS_OPT_RET_BLEND_POINT, 
                                 side_1, blend_dir_pt1,
                                 &is_blend_reversed, &roots[0]);
   EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

   if (blend_info->props & EMS_BLEND2_REVERSED)
    is_blend_reversed = 1;
   else
    is_blend_reversed = 0;

   status = EFret_blend_dirinfo (EMmsg, EMS_OPT_RET_BLEND_POINT, 
                                 side_2, blend_dir_pt2,
                                 &is_blend_reversed, &roots[1]);
   EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);

   status = om$send (msg = message EMSgenbs.EMblend_surface(
                           (struct GRlc_info *) &roots[0],
                           side_1,
                           surf1_reversed,
                           blend_dir_pt1,
                           (struct GRlc_info *) &roots[1],
                           side_2,
                           surf2_reversed,
                           blend_dir_pt2,
                          construct_list),
                     targetid = my_id);
   EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
  }
  break;

  case EMS_ASdefault_ruled_surface:
  case EMS_ASarclength_ruled_surface:
  case EMS_ASdevelopable_ruled_surface:
  {
    IGRchar *absgeom = NULL;
    IGRint creation_option;
    BSrc   rc;
    IGRdouble *param = NULL;
    IGRdouble *control_points = NULL;
    struct IGRbsp_curve *curve = NULL;
    struct EMSruled_surface *rlsf = NULL;
    struct GRmdenv_info *cvenv;
    struct GRid *cvgrid;
    extern IGRlong EMgetabsg();
    extern OMuword OPP_EMSagrp_class_id;
    
    switch(surface_type)
    {
     case EMS_ASdefault_ruled_surface:
      creation_option = 0;
     break;

     case EMS_ASarclength_ruled_surface:
      creation_option = 1;
     break;

     case EMS_ASdevelopable_ruled_surface:
      creation_option = 2;
     break;
    }

    cvenv = &roots[0].lc_info.module_info.md_env;
    cvgrid = &roots[0].lc_info.located_obj;

    /*
     * During recomputation one need to do the following for the models
     * created before EMS 3.1 for the surfaces created by the options 0 
     * and * 1 as their geometry is not normalized. So, do the follwoing 
     * only during computation.
     */  
    if( (old_objid != NULL_OBJID) && 
        (creation_option == 0 || creation_option == 1) )
    {
       OMuword               classid;
       IGRboolean            normalized = FALSE;
       struct GRid           sfgrid, *asgrps = NULL;
       OMuint                num_children=0, num_asgrps = 0, temp_count;
       OM_S_CHANSELECT       children;
       OM_S_OBJECT_LINKAGE   *link_ptr = NULL;
       struct IGRbsp_surface *sfgeom = NULL; 

       sfgrid.objid = old_objid;
       sfgrid.osnum = cvgrid->osnum;

       /*
        * get my number of dependents
        */
       status = om$make_chanselect( channame     = "NDchildren.children",
                                    p_chanselect = &children );
       EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, loc_wrapup);

       status = om$get_channel_count( objid  = sfgrid.objid,
                                osnum        = sfgrid.osnum, 
                                p_chanselect = &children,
                                count        = (OMuint *) &num_children );
       EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, loc_wrapup);

       /*
        * if there are children do the following:
        *    get my dependents and collect all the dependents of class EMSagrp
        *    in a temporary array. 
        */
       if( num_children )
       {
          link_ptr = (OM_S_OBJECT_LINKAGE *) om$malloc(size = num_children *
                     sizeof(OM_S_OBJECT_LINKAGE));
          EMerr_hndlr (!link_ptr, *EMmsg, EMS_E_DynamicMemoryAllocated, wrapup);

          status = om$get_channel_objects(objid = sfgrid.objid,
                                          osnum = sfgrid.osnum, 
                                          p_chanselect = &children,
                                          list = link_ptr,
                                          size = num_children,
                                          count = (OMuint *)&temp_count);
          EMerr_hndlr (!status, *EMmsg, EMS_E_OMerror, loc_wrapup);

          for(i=0; i<num_children; i++)
          {
              status = om$get_classid( objid = link_ptr[i].S_objid,
                                       osnum = link_ptr[i].osnum,
                                       p_classid = &classid );
              EMerr_hndlr(!(1&status), *EMmsg, EMS_E_OMerror, loc_wrapup);

              if(om$is_ancestry_valid( subclassid = classid,
                      superclassid = OPP_EMSagrp_class_id) == OM_S_SUCCESS )
              {
                 num_asgrps ++;
                 if( num_asgrps == 1 )
                    asgrps = (struct GRid *) om$malloc( size = 
                                                        sizeof(struct GRid)); 
                 else
                    asgrps = (struct GRid *) om$realloc(
                                             ptr = (IGRchar *)asgrps, size = 
                                             num_asgrps * sizeof(struct GRid));
                 asgrps[num_asgrps - 1].objid = link_ptr[i].S_objid;
                 asgrps[num_asgrps - 1].osnum = link_ptr[i].osnum;
              }
          } 
       }

       /*
        * If there are any dependents of class EMSagrp then do the following.
        */ 
       if( num_asgrps ) 
       {
          /*
           * get  my (surface's) geometry
           */
          status = EMgetvggeom( EMmsg, 
                          &construct_list->env_info->md_env.matrix_type,   
                          &construct_list->env_info->md_env.matrix, &sfgrid,
                          (IGRchar **) &sfgeom, NULL );
          EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_SurfaceError, 
                      loc_wrapup);

          /*
           * check whether the geometry is normalized or not 
           */
          if( (sfgeom->u_knots[0] == 0.0) && 
              (sfgeom->u_knots[sfgeom->u_num_knots - 1] == 1.0) &&
              (sfgeom->v_knots[0] == 0.0) &&
              (sfgeom->v_knots[sfgeom->v_num_knots - 1] == 1.0) )
              normalized = TRUE;

          /*
           * if the geometry is not normalized one, then do the following:
           */
          if( !normalized )
          {
             IGRuint                 info_size, info_type;
             IGRdouble               val;
             struct EMSisoparametric_curves *info = NULL;
           
             /*
              * for each of my depenedent of class EMSagrp:
              *      i.e. This is a iso-parametric curve.  Get the recompute 
              *      information of this object and get the parameter values 
              *      associated with it. Normalize these parameter values and
              *      post the normalized parameter values back to the recomp-
              *      utation info.
              */
             for(i=0; i<num_asgrps; i++)
             {
                 /*
                  * get the recompute information 
                  */
                 info = NULL; info_size = 0; info_type = 0;
                 status = om$send( msg = message EMSassoc.EMget_info( EMmsg,
                                                 NULL, &info_type,&info_size, 
                                                 (IGRchar **) &info ),
                                   targetid = asgrps[i].objid,
                                   targetos = asgrps[i].osnum );
                 EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_OMerror, 
                             loc_wrapup1);

                 /*
                  * Normalize the parameter values.
                  */
                 if( info->props & EMS_USE_U_DIRECTION )
                 {
                     val = sfgeom->u_knots[ sfgeom->u_num_poles ] -
                           sfgeom->u_knots[ sfgeom->u_order - 1] ;
                 }
                 else
                 {
                     val = sfgeom->v_knots[ sfgeom->v_num_poles ] -
                           sfgeom->v_knots[ sfgeom->v_order - 1] ;
                 } 

                 info->start_param /= val; 
                 info->end_param   /= val; 

                 /*
                  * put the modified recompute information structure
                  */
                 status = om$send( msg = message EMSassoc.EMput_info( 
                                                 EMmsg, NULL, info_type, 
                                                 info_size,
                                                 (IGRchar *) info),
                                   targetid = asgrps[i].objid,
                                   targetos = asgrps[i].osnum );
                 EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_OMerror, 
                             loc_wrapup1);

                 loc_wrapup1 :
                     if( info ) om$dealloc( ptr = info ); info = NULL;
              } 
           }
        }
        loc_wrapup : 
          if( asgrps )   om$dealloc( ptr = asgrps );
          if( sfgeom )   om$dealloc( ptr = sfgeom ); 
          if( link_ptr ) om$dealloc( ptr = link_ptr );
          status = OM_S_SUCCESS;
          *EMmsg = EMS_S_Success;
    } 

    rlsf = (struct EMSruled_surface *)recomp_info;
    
    control_points = (IGRdouble *)stackalloc(sizeof(IGRpoint) * 2 *
                     rlsf->num_cp);
    param = (IGRdouble *)stackalloc(sizeof(IGRdouble) * 2 * rlsf->num_cp);
    EMerr_hndlr(!control_points || !param, *EMmsg, EMS_E_DynamicMemoryAllocated,
                 wrapup);

    OM_BLOCK_MOVE(&rlsf->chardata[0],param,
                  rlsf->num_cp*sizeof(IGRdouble)*2);


    status = EMgetabsg(EMmsg, 
                       &cvenv->matrix_type, 
                       cvenv->matrix,
                       cvgrid->osnum,
                       cvgrid->objid,
                       &absgeom);
    EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_DynamicMemoryAllocated,
                wrapup);
    curve = (struct IGRbsp_curve * )absgeom;
    BScvarrev0 (&rc, curve,param, rlsf->num_cp, control_points); 
    EMerr_hndlr(BSERROR(rc), *EMmsg, EMS_E_BSerror, wrapup);


    cvenv = &roots[1].lc_info.module_info.md_env;
    cvgrid = &roots[1].lc_info.located_obj;
    absgeom = NULL;

    status = EMgetabsg(EMmsg, 
                       &cvenv->matrix_type, 
                       cvenv->matrix,
                       cvgrid->osnum,
                       cvgrid->objid,
                       &absgeom);
    EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_DynamicMemoryAllocated,
                wrapup);
    curve = (struct IGRbsp_curve * )absgeom;
    BScvarrev0 (&rc, curve, &param[rlsf->num_cp], rlsf->num_cp, 
                 &control_points[3*rlsf->num_cp]); 
    EMerr_hndlr(BSERROR(rc), *EMmsg, EMS_E_BSerror, wrapup);
  
   status = om$send (msg = message EMSsubbs.EMruled_surface(
                            NULL, /* No buffer for curve 1 */
                    (struct GRlc_info *) roots,/* Curve 1 locate information */
                            NULL,/* No buffer for curve 2 */
                    (struct GRlc_info *) &roots[1],
                            rlsf->num_cp,
                            (IGRpoint *) &control_points[0],
                            (IGRpoint *) &control_points[3*(rlsf->num_cp)],
                            NULL,
                            FALSE, /* Natural side is random */
                            (rlsf->rlsf_props & EMS_FIRST_CURVE_REVERSED),
                            (rlsf->rlsf_props & EMS_SECOND_CURVE_REVERSED),
                            creation_option,
                            NULL,
                            construct_list,
                            EMmsg),
             targetid = my_id);
    EMerr_hndlr(!(1&status&*EMmsg), *EMmsg, EMS_E_Fail, wrapup);
   
  }
  break;

  case EMS_ASbox_by_4pts:
  {
     IGRlong     msg_loc;
     IGRshort    k, l;
     IGRpoint    points[4];
     IGRvector   vector;

     if (root_count < 7) goto wrapup; /* Data lost, leave in last state. */

     memcpy(points[0], roots[BASE].point, sizeof(IGRpoint));

     for (i=1,j=WIDTH,k=WIDTH_VEC; i<4; ++i, j+=2, k+=2)
     {
         MAscalvc (&msg_loc, &roots[j].value, roots[k].vector, vector);
         for (l=0; l<3; ++l)
            points[i][l] = points[0][l] + vector[l];
     }

     status = om$send ( msg = message EMSgenbs.EMboxby4
                                            ( construct_list,
                                              (IGRdouble (*)[3]) points,
                                              (int *) EMmsg ),
                        targetid = my_id );

     EMerr_hndlr (EMSerror (status & *EMmsg), *EMmsg, EMS_E_Fail, wrapup);

  }
     break;

  case EMS_AStube_by_linear_and_radii:
  {
    IGRint                num_bend_radii;
    IGRdouble             loc_radius;
    IGRdouble           * loc_bend_radii;
    struct IGRbsp_curve * curve_info;
    enum EMSdatatype      curve_type;

    status = OM_S_SUCCESS; *EMmsg = MSSUCC;

    if (root_count < 2) goto wrapup; /* Data loss, leave in last state. */

    status = EMgetvggeom ( EMmsg,
                           &roots[0].grobj.env.md_env.matrix_type,
                           roots[0].grobj.env.md_env.matrix,
                           &roots[0].grobj.grid,
                           &curve_info,
                           &curve_type );

    EMerr_hndlr (EMSerror (status & *EMmsg), *EMmsg, EMS_E_Fail, wrapup);

    loc_radius = roots[1].value;

    num_bend_radii = curve_info->num_poles - 2;

    loc_bend_radii = (IGRdouble *)stackalloc(num_bend_radii * sizeof(IGRdouble));

    for (j=0, i=2; i<root_count; ++i, ++j)
        loc_bend_radii[j] = roots[i].value; 

    for (; j<num_bend_radii; ++j)
        loc_bend_radii[j] = loc_radius;

    /*
     * Construct the tube.
     */
    status = om$send ( msg = message EMSgenbs.EMplctbesrf
                                               ( EMmsg,
                                                 &roots[0].grobj.env,
                                                 roots[0].grobj.grid,
                                                 loc_radius,
                                                 loc_bend_radii,
                                                 construct_list ),
                       targetid = my_id );

    EMerr_hndlr (EMSerror (status & *EMmsg), *EMmsg, EMS_E_Fail, wrapup);
/* fix for mlk */
    if(curve_info) om$dealloc(ptr = curve_info);
 }
    break;

 default:
  {
    *EMmsg = EMS_E_InvalidArg;
    goto wrapup;
  }
 }

#if DO_CONVERT_SURFACES_INTO_PLANES
 convert_into_plane = TRUE;
#endif

 if(convert_into_plane && construct_list->env_info)
  status = EMconvert_into_plane(EMmsg, NULL, NULL, NULL, NULL, NULL, NULL, 
           NULL, construct_list->env_info, my_id, OM_Gw_current_OS);

wrapup:
/*
 * Only free the first ptr returned by stackalloc.
 */
 if (root_type) stackfree (root_type);
 EMWRAPUP (status, *EMmsg, "In EMAgenbs:EMplace_associative_const error"); 
 return (status);
}
end implementation EMAgenbs;
