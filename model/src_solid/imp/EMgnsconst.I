/*
 * DESCRIPTION:
 *
 *  This is the construct method for a surface to plane solid of projection.
 *
 * HISTORY:
 *
 *  jhw     : 04/15/91  Creation
 *  Tapadia : 03/15/92  Added support for solid of projection with trimming
 *			plane(s) (EMS_ASsolid_proj_by_trim_st_end_plane &
 *     				 EMS_ASsolid_proj_by_trim_end_plane)
 *  Sudhakar: 25May'93  Added support for thinwall solid from a composite
 *                      surface (EMS_ASthinwall_from_compsurf).
 *  Sudhakar: 30Jun'93  Fix for TR#119302045. Added an addl. arg to the two
 *                      functions 'EFget_axis_from_curve_one_pl()' and
 *                      'EFget_axis_from_curve_two_pls()'. Added code to
 *                      skip the call to 'EFplsolid_by_trimming_with_planes()'
 *                      if planes parallel.
 *  Sudhakar: 08Sep'93  Changed the name of the function
 *                      'EFcreate_outward_offset_compsf' to
 *                      'EFcreate_outward_offset_by_half_thickness' to make
 *                      it more representative of what it does and moved it
 *                      to the file 'src_funk/misc/EFcsoffsupp.I'.
 *  Sudhakar: 24Sep'93  Modified to handle new 'recompute' info. Pulled out
 *                      'edge' parents. Added an additional 'surface' parent
 *                      for 'dimensioning' of 'common thickness'.
 */
class implementation EMSgensolid;

#include "OMmacros.h"
#include "REgencompsf.h"
#include "REgensolid.h"
#include "REshsolid.h"
#include "emssfint.h"

%safe

static void EFget_compsurf_parent_types(),
            EFget_compsurf_parent_info();

%endsafe

extern OMuword OPP_EMSsfsolid_class_id;

from EMSdpr import EMmake_primitive1;
from EMSsfsolid import EMcap_thyself;

method EMconstruct_associative ( IGRlong               * msg; 
                                 IGRushort       opts;
                                 GRobjid                 old_objid;
                                 IGRint                  num_parents;
                                 IGRchar               * parent_info;
                                 IGRint                  type;
                                 IGRchar               * recomp_info;
                                 struct GRvg_construct * constr_list)
{
    IGRlong                   msg_loc, om_msg;
    IGRuint         * param_type;
    union EMSparent_info    * param;
    GRclassid   sfclass;
    IGRint      sftype;
    GRobjid     sfobjid;
    IGRshort    props = GRIS_ASSOCIATIVE;
    IGRshort    action = 0; /* ReSet the bit. - DLB 9/9/91*/
    extern IGRlong     EMgetsfclass(), EFplsolid_by_trimming_with_planes();
    OM_S_OBJID	solid_id;
    IGRboolean both_planes = TRUE;
    extern IGRlong EFget_axis_from_curve_one_pl();
    extern IGRlong EFget_axis_from_curve_two_pls();
    extern void EFcreate_outward_offset_by_half_thickness();
    IGRpoint axis[2], mid_point;
    IGRboolean convert_into_plane = TRUE;

 /* Following needed for 'EMS_ASthinwall_from_compsurf' type */
    struct EMSshell_solid      *ashell=NULL;
    struct mult_tk_surfs_views *s_views;
    IGRboolean                 is_symmetric = FALSE,
                               inward = TRUE; /* is_composite; */
    IGRint                     i, num_mult_tks = 0, *num_sfs=NULL;
    IGRdouble                  common_thickness, *vals_mult_thickness=NULL;
    struct GRobjid_set         *spec_tk_sf_sets=NULL;
    struct EMSerror_help       *errkey_list=NULL;



    *msg = EMS_S_Success;
    om_msg = OM_S_SUCCESS;

    /*
     * Get space for the parameter information.
     */
    param_type = (IGRuint *)alloca (num_parents * sizeof(IGRint));
    EMerr_hndlr (!param_type, *msg, EMS_E_NoStackMemory, ret_end);
    param = (union EMSparent_info *)alloca(num_parents * 
                                        sizeof (union EMSparent_info));
    EMerr_hndlr (!param, *msg, EMS_E_NoStackMemory, ret_end);

    /*
     * Fill in the appropriate parameter requests.
     */
    switch (type)
    {
    case EMS_ASsurface_to_plane_solid_of_proj:
    case EMS_ASsurface_to_plane_solid_of_proj1:
        if (num_parents == 3)
        {
            param_type[0] = EMSlcinfo; /* Projected Surface       */
            param_type[1] = EMSvector; /* Direction of Projection */
            param_type[2] = EMSlcinfo; /* Plane Projected To      */
        }
        else goto ret_end;
        break;

    case EMS_ASsolid_by_offsetting_surface:
    case EMS_ASsolid_by_offsetting_surface1:
        if(num_parents == 3){
            param_type[0] = EMSlcinfo;
            param_type[1] = EMSdistance;
            param_type[2] = EMSgrid;
        }
        else goto ret_end;
        break;

    case EMS_ASthinwall_from_compsurf:

        /* Expand the Recompute Info into standard form */

        ashell = (struct EMSshell_solid *)recomp_info;
        is_symmetric = ashell->is_symmetric;
        inward       = ashell->inward;
        num_mult_tks = ashell->num_mult_tks;
        s_views = ashell->sfs_views;

        if(num_mult_tks)
        { 
          num_sfs  = (IGRint *) om$malloc(size = num_mult_tks * sizeof(IGRint));
          EMerr_hndlr (!num_sfs, *msg, EMS_E_NoStackMemory, ret_end);
          for (i=0; i<num_mult_tks; i++)
              num_sfs[i] = s_views[i+1].num_sfs_per_mult_tks;
        }

        EFget_compsurf_parent_types(num_mult_tks, num_sfs, param_type);

        break;

    case EMS_ASsolid_proj_by_trim_st_end_plane:
    case EMS_ASsolid_proj_by_trim_end_plane:
	break;

    default:
        goto ret_end;
    }        

    /*
     * Get the parameter information.
     */

    if(type != EMS_ASsolid_proj_by_trim_st_end_plane && 
	type != EMS_ASsolid_proj_by_trim_end_plane) {
    	om_msg = om$send ( msg = message EMSassoc.EMget_parent_info
                                            ( &msg_loc,
                                              NULL,
                                              num_parents,
                                              parent_info,
                                              param_type,
                                              param ),
                        targetid = my_id);
    	EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);
    }

    /*
     * Construct the appropriate plane.
     */
    switch (type)
    {
    case EMS_ASsurface_to_plane_solid_of_proj:
    case EMS_ASsurface_to_plane_solid_of_proj1:
    {
        struct IGRplane loc_plane;
        IGRdouble       loc_point[3];
        IGRdouble       loc_normal[3];

        loc_plane.point  = loc_point;
        loc_plane.normal = loc_normal;

        om_msg = om$send ( msg = message GRvg.GRdetplane
                                    ( &msg_loc,
                                      &param[2].lc_info.module_info.md_env.matrix_type,
                                       param[2].lc_info.module_info.md_env.matrix,
                                      &loc_plane),
                           targetid = param[2].lc_info.located_obj.objid,     
                           targetos = param[2].lc_info.located_obj.osnum );

        EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);

        om_msg = om$send ( msg = message EMSsolid.EMproj_4_bnd_on_plane
                                                    ( &msg_loc,
                                                      NULL,
                                                      &param[0].lc_info,
                                                      loc_point,
                                                      loc_normal,
                                                      param[1].vector,
                                                      constr_list),
                           targetid = my_id );

        EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);

        break;
    }

    case EMS_ASsolid_by_offsetting_surface:
    case EMS_ASsolid_by_offsetting_surface1:
    {
        unsigned long               offset_props;
        OM_S_CHANSELECT             to_comps;
        GRobjid                     offobj;
        struct GRid                 active_grid;
        IGRushort                   undo_option;
        struct GRlc_info            sflc_info;
        GRobjid                     newsurf;

     active_grid.objid = NULL_OBJID;
     active_grid.objid = NULL_OBJID;

   /*** get active_grid**********/
     if (EFisAncestryValid(&msg_loc, param[0].grobj.grid.objid,
                               param[0].grobj.grid.osnum,
                                OPP_EMSsurface_class_id, FALSE))
     {
         om_msg = om$send (msg = message EMSsurface.EMgetactiveid(&msg_loc,
                           &active_grid,NULL),
                      senderid = NULL_OBJID,
                      targetid = param[0].grobj.grid.objid,
                      targetos = param[0].grobj.grid.osnum);
         if (!(1&om_msg&msg_loc)) goto ret_end;
     }

     /*active_grid.objid*/

   if(active_grid.objid != param[0].grobj.grid.objid)
   {
     undo_option = EMS_UNDO_SAVE;
     om_msg = om$send (msg = message EMSsurface.EMmake_active_state(&msg_loc,
                             &undo_option,
                             &param[0].lc_info.module_info, NULL,NULL,
                             NULL,NULL,NULL,NULL),
                       targetid = param[2].grobj.grid.objid,
                       targetos = param[2].grobj.grid.osnum);
     if (!(1&om_msg&msg_loc)) goto ret_end;
   }

/*********************/
        offset_props = ((struct EMSoffset_simple_surface *)recomp_info)->props;

        OM_BLOCK_MOVE(&param[0].lc_info, &sflc_info, 
                                         sizeof(struct GRlc_info));
      
        if(offset_props & EMS_SYMMETRIC_OFFSET)
        {
          newsurf = param[0].lc_info.located_obj.objid;

         /* Create the 'half' outward offset surface. */
          EFcreate_outward_offset_by_half_thickness(&msg_loc, constr_list,
                                       param[1].value, 0,
                                       NULL, NULL,
                                       &newsurf, errkey_list);
          EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);

          sflc_info.located_obj.objid = newsurf;
        }

        om_msg = EMoffset_surface_to_solid ( &sflc_info,
                                             param[1].value,
                     (offset_props & EMS_SYMMETRIC_OFFSET ?
                                             TRUE         :
                                             offset_props & EMS_NATURAL_NORMAL),
                                             constr_list,
                                             NULL_OBJID,
                                             &offobj );

        if(offset_props & EMS_SYMMETRIC_OFFSET)
        {
           /* Delete the 'half' offset copy surface */
            om_msg = om$send(msg = message GRgraphics.GRdelete (&msg_loc,
                                        constr_list->env_info),
                            targetid = newsurf);
            EMerr_hndlr (EMSerror (om_msg & msg_loc),
                                          *msg, EMS_E_Fail, ret_end);
        }

/********** restore dpr tree *********/
  if(active_grid.objid != NULL_OBJID)
  {
     undo_option = EMS_UNDO_SAVE;
     om_msg = om$send (msg = message EMSsurface.EMmake_active_state(&msg_loc,
                             &undo_option,
                             &param[0].lc_info.module_info, NULL,NULL,
                             NULL,NULL,NULL,NULL),
                        targetid =  active_grid.objid,
                        targetos =  active_grid.osnum);
     if (!(1&om_msg&msg_loc)) goto ret_end;
  }
/********** restore dpr tree *********/

        EMerr_hndlr (EMSerror (om_msg & 1), *msg, EMS_E_Fail, ret_end);

        EMmake_chanselect (GRcmpowner_to_components, &to_comps);

        om_msg = om$send ( msg = message Root.move_chan 
                                                ( to_comps,
                                                  offobj,
                                                  OM_Gw_current_OS,
                                                  to_comps ),
                           targetid = my_id );

        if (om_msg & 1)
        {
            om_msg = om$send ( msg = message GRgraphics.GRconstruct
                                                ( constr_list ),
                               targetid = my_id );

        }
        om_msg = om$send(msg = message GRgraphics.GRdelete
                                        (&msg_loc, constr_list->env_info),
                         targetid = offobj );
        EMerr_hndlr (EMSerror (om_msg & msg_loc),
                                          *msg, EMS_E_Fail, ret_end);
    }
        break;

    case EMS_ASthinwall_from_compsurf:
    {
       IGRushort          offopts = 0;
       GRobjid            compsurf, gen_solid;
       OM_S_CHANSELECT    to_comps;

      /* Setup the parent information */
       EFget_compsurf_parent_info(&msg_loc, param, num_mult_tks, num_sfs,
                                  &compsurf, &common_thickness,
                                  &vals_mult_thickness, &spec_tk_sf_sets);
       EMerr_hndlr (EMSerror (msg_loc), *msg, EMS_E_Fail, ret_end);


      /* Construct thinwall of a Composite surface */
       om_msg = om$send(msg = message EMScompsurf.EMshell(&msg_loc,
                               offopts,
                               &constr_list->env_info->md_env.matrix_type,
                               constr_list->env_info->md_env.matrix,
                               constr_list,
                               inward,
                               is_symmetric,
                               common_thickness,
                               num_mult_tks, vals_mult_thickness,
                               spec_tk_sf_sets, 0, NULL,
                               NULL, &gen_solid, errkey_list),
                          mode = OM_e_wrt_message,
                          senderid = NULL_OBJID,
                          targetid = compsurf);

       EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);

       EMmake_chanselect (GRcmpowner_to_components, &to_comps);

       om_msg = om$send ( msg = message Root.move_chan
                                                ( to_comps,
                                                  gen_solid,
                                                  OM_Gw_current_OS,
                                                  to_comps ),
                           targetid = my_id );
       EMerr_hndlr (EMSerror (om_msg & 1), *msg, EMS_E_Fail, ret_end);

/*     if (om_msg & 1)
       {
           om_msg = om$send ( msg = message GRgraphics.GRconstruct
                                                ( constr_list ),
                              targetid = my_id );

       } */

       om_msg = om$send(msg = message GRgraphics.GRdelete
                                        (&msg_loc, constr_list->env_info),
                        targetid = gen_solid );
       EMerr_hndlr (EMSerror (om_msg & msg_loc),
                                          *msg, EMS_E_Fail, ret_end);
    }
        break;

    case EMS_ASsolid_proj_by_trim_st_end_plane:
    case EMS_ASsolid_proj_by_trim_end_plane:
        /*
         * Obtain the classid of my characteristic surface.
         */
        msg_loc = EMgetsfclass (type, &sfclass, &sftype);
        EMerr_hndlr (!msg_loc, *msg, EMS_E_InvalidCase, ret_end);

        /*
         * Construct a surface of this particular class and send it the
         * construct associative message. This would ensure that the characteristic
         * geometry has been created.
         */
        om_msg = om$construct ( classid = sfclass, 
                                msg = message EMSassoc.EMconstruct_associative 
                                                ( &msg_loc,
                                                  opts, 
                                                  old_objid, 
                                                  num_parents, 
                                                  parent_info, 
                                                  sftype, 
                                                  recomp_info,
                                                  constr_list ), 
                                 p_objid = &sfobjid );

        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);


        /*
         * Make sure the associative surface has IS_ASSOC bit off.
         *  
         */
        om_msg = om$send ( msg = message GRgraphics.GRchgprops 
                                                ( &msg_loc, &action, &props ),
                           targetid = sfobjid );

        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

        break;
    }

    /*
     * Get space for the parameter information.
     */

    switch (type)
    {
    case EMS_ASsolid_proj_by_trim_st_end_plane:
        param_type[0] = EMSlcinfo;
        param_type[1] = EMSlcinfo;
        param_type[2] = EMSlcinfo;
	break;

    case EMS_ASsolid_proj_by_trim_end_plane:
	both_planes = FALSE;
        param_type[0] = EMSlcinfo;
        param_type[1] = EMSlcinfo;
	break;
    
    default:
	break;
    }


    /*
     * Get the parameter information.
     */

    if(type == EMS_ASsolid_proj_by_trim_st_end_plane || 
	type == EMS_ASsolid_proj_by_trim_end_plane) {

        IGRboolean   parallel_pls = FALSE;
        OM_S_CHANSELECT    to_comps;
        
    	om_msg = om$send ( msg = message EMSassoc.EMget_parent_info
                                            ( &msg_loc,
                                              NULL,
                                              num_parents,
                                              parent_info,
                                              param_type,
                                              param ),
                        targetid = my_id);
    	EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);

    /*
     * The next step is to cap this characteristic surface off by sending
     * the cap yourself message. Ignore the caps that are degenerate.
     */
    	om_msg = om$construct(classid = OPP_EMSsfsolid_class_id,
				 msg = message EMSsfsolid.EMcap_thyself 
                                                ( &msg_loc,
                                                  constr_list, 
                                                  &sfobjid ), 
				p_objid = &solid_id,
				osnum = OM_Gw_current_OS);

    	EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

	if(type == EMS_ASsolid_proj_by_trim_end_plane) {
	    	om_msg = EFget_axis_from_curve_one_pl(&msg_loc, 
			&(param[0].lc_info), &(param[1].lc_info),
                	axis, mid_point, &parallel_pls);
    	    	EMerr_hndlr(EMSerror(msg_loc & om_msg), *msg, EMS_E_Fail, 
			ret_end);
	}
	if(type == EMS_ASsolid_proj_by_trim_st_end_plane) {
	    	IGRpoint cur_pt;

	    	om_msg = EFget_axis_from_curve_two_pls(&msg_loc, 
			&(param[0].lc_info), &(param[1].lc_info), 
			&(param[2].lc_info), cur_pt, axis, mid_point,
                        &parallel_pls);

    	    	EMerr_hndlr(EMSerror(msg_loc & om_msg), *msg, EMS_E_Fail, 
			ret_end);
	}

        if(!parallel_pls) {   
	  /* Trim the solid with plane(s) */
    	  om_msg = EFplsolid_by_trimming_with_planes(&msg_loc, opts,
		both_planes, &my_id, solid_id, &(param[1].lc_info), 
		(both_planes) ? &(param[2].lc_info): NULL,
		mid_point, constr_list);

           EMerr_hndlr(EMSerror(msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);
         }
         else {
           EMmake_chanselect (GRcmpowner_to_components, &to_comps);

           om_msg = om$send ( msg = message Root.move_chan
                                                ( to_comps,
                                                  solid_id,
                                                  OM_Gw_current_OS,
                                                  to_comps ),
                               targetid = my_id );
           EMerr_hndlr (EMSerror (om_msg & 1), *msg, EMS_E_Fail, ret_end);

         /*
          * Delete the constructed object 'solid_id'.
          */
           om_msg = om$send(msg = message GRgraphics.GRdelete(&msg_loc,
                                constr_list->env_info),
                          targetid = solid_id);
           EMerr_hndlr(EMSerror(om_msg & msg_loc), *msg, EMS_E_Fail,
                        ret_end);

         } /* else of if(!parallel_pls) */
    }

   if( ((type == EMS_ASsurface_to_plane_solid_of_proj1) ||
        (type == EMS_ASsolid_by_offsetting_surface1)) && convert_into_plane)
      om_msg = EMconvert_into_plane(msg, NULL, NULL, NULL, NULL, NULL, NULL, 
               NULL, constr_list->env_info, my_id, OM_Gw_current_OS);

   
ret_end:
    if(type == EMS_ASthinwall_from_compsurf)
     {
      /* Deallocated all the related memory */
      if(num_sfs) om$dealloc(ptr = num_sfs);
      if(vals_mult_thickness) om$dealloc(ptr = vals_mult_thickness);
      if(spec_tk_sf_sets)
        for(i=0; i<num_mult_tks; i++)
          if(spec_tk_sf_sets[i].objids) 
                   om$dealloc(ptr = spec_tk_sf_sets[i].objids);
      if(spec_tk_sf_sets)
            om$dealloc(ptr = spec_tk_sf_sets);
     }
      
    EMWRAPUP (*msg, om_msg, "EMSgensolid.EMconstruct_associative");
    return (om_msg);
}

/**********************************************************************/
  static void EFget_compsurf_parent_types(num_mult_thicknesses, 
                                          num_sfs_per_mult_thickness,
                                          param_type)
  IGRint    num_mult_thicknesses;       /* input */
  IGRint    *num_sfs_per_mult_thickness;/* input */
  IGRuint   *param_type;                /* filled in output */

{
  IGRint  i, j, parent_index, sfs_index, solid_inx;

 /* 'param_type' should already have been allocated */
  if(!param_type) goto ret_end;

  parent_index = 0;

  /* Common Thickness parent */
  param_type[parent_index] = EMSdistance;
  parent_index++;

  if(num_mult_thicknesses)
     {
      /* Specific Thickness Parents */
      for (i=0, j=parent_index; i< num_mult_thicknesses; i++, j++)
        {
         param_type[j] = EMSdistance;
        }
      parent_index += num_mult_thicknesses;
     } /* End of -  if(num_mult_thicknesses) */

  /* Surface Parents */

  /* Common Thickness Dimension Surface Parent */
  param_type[parent_index] = EMSgrid;
  parent_index++;

  /* Specific Thickness Surface Parents */
  if(num_mult_thicknesses)
     {
      sfs_index = 0;
      for (i=0; i< num_mult_thicknesses; i++)
       {
        for(j=sfs_index; j<sfs_index+num_sfs_per_mult_thickness[i]; j++)
         {
          param_type[parent_index+j] = EMSgrid;
         }
        sfs_index    += num_sfs_per_mult_thickness[i];
       }
      parent_index += sfs_index; /* 'sfs_index' has count of no. of surfs.
                                    It is used later in tha code */
     } /* End of -  if(num_mult_thicknesses) */

  solid_inx = parent_index;
  param_type[solid_inx] = EMSgrid;
  parent_index++;


#ifdef DEBUG
  printf("Number of parents (types) = %d\n", parent_index);
#endif

ret_end:

  return;
}
/***********************************************************************/
  static void EFget_compsurf_parent_info(msg, param, 
                                  num_mult_thicknesses,
                                  num_sfs_per_mult_thickness,
                                  compsurf, common_thickness,
                                  vals_mult_thickness, spec_tk_sf_sets)
  IGRlong              *msg;
  union EMSparent_info *param;
  IGRint               num_mult_thicknesses;
  IGRint               *num_sfs_per_mult_thickness;
  GRobjid              *compsurf;
  IGRdouble            *common_thickness;
  IGRdouble            **vals_mult_thickness;
  struct GRobjid_set   **spec_tk_sf_sets;
{ 
 /*  Assume 'vals_mult_thickness' and 'spec_tk_sf_sets' come in 
     as NULL and allocate memory in this routine.
 */

  IGRint i, j, k, parent_index, sf_index, list_index;
  IGRdouble *vals_mult= NULL;
  struct GRobjid_set *spec_sf_sets=NULL;
  GRobjid   *tmplist;
  
 
  *msg = EMS_S_Success;

  vals_mult = *vals_mult_thickness;
  spec_sf_sets = *spec_tk_sf_sets;

  parent_index = 0;

  *common_thickness = param[parent_index].value;
  parent_index++;

  if(num_mult_thicknesses)
     {
      /* Get Specific Thickness Values */
      vals_mult = (IGRdouble *) om$malloc(size = 
                                   num_mult_thicknesses * sizeof(IGRdouble));
      EMerr_hndlr (!vals_mult, *msg, EMS_E_NoStackMemory, ret_end);

      for (i=0, j=parent_index; i< num_mult_thicknesses; i++, j++)
        {
         vals_mult[i] = param[j].value;
        }
      parent_index += num_mult_thicknesses;
     } /* End of -  if(num_mult_thicknesses) */

 /* Skip Common Thickness Dimension Surface */
  parent_index++;

  if(num_mult_thicknesses)
     {
    /* Set data into a 'GRobjid_set' structure */
      spec_sf_sets = (struct GRobjid_set *) om$malloc(size =
                            num_mult_thicknesses * sizeof(struct GRobjid_set));
      EMerr_hndlr (!spec_sf_sets, *msg, EMS_E_NoStackMemory, ret_end);

      list_index = parent_index;
      for (j=0; j<num_mult_thicknesses; j++)
        {
         spec_sf_sets[j].num_ids = num_sfs_per_mult_thickness[j];

         tmplist = (GRobjid *) om$malloc(size = num_sfs_per_mult_thickness[j] *
                                     sizeof(GRobjid));

         for (k=0, sf_index=list_index; k<num_sfs_per_mult_thickness[j];
                                                         k++, sf_index++)
            tmplist[k] = param[sf_index].grobj.grid.objid;
         list_index += num_sfs_per_mult_thickness[j];

         spec_sf_sets[j].objids = tmplist;
        }
      parent_index = list_index;
     } /* End of -  if(num_mult_thicknesses) */

 /* Get the composite surface id - The last parent. */
  *compsurf = param[parent_index].grobj.grid.objid;
  parent_index++;

 /* Reassign the pointers */

  *vals_mult_thickness = vals_mult;
  *spec_tk_sf_sets     = spec_sf_sets;

#ifdef DEBUG
  printf("Number of parents (values) = %d\n", parent_index);
  printf("The composite surface id = %d\n", *compsurf);
#endif

ret_end:

 return;

}

end implementation EMSgensolid;

