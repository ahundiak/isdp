/* ###################   APOGEE COMPILED   ################## */
/*
 * DESCRIPTION:
 *
 *  This is the function used to place a surface offset from another surface.
 *
 * HISTORY:
 *
 *  jhw  :  Creation  :  04/21/91
 *  sam  :  01/19/93  :  Added additional arguments to EMoffset call . 
 *  sam  :  03/12/93  :  Added code to pass multiple offset thickness 
 *                       values to EMoffset.
 *  sam  :  03/16/93  :  Added code for associative functionality for multiple
 *                       offset thickness values.
 *                       Auto dimensioning is not yet done , hence some errors 
 *                       will be printed on window. It is not advisable to 
 *                       set EMSasconst_noautodimension because this will
 *                       prevent attaching parents to the channel in 
 *                       EMinit_associative.
 * Sudhakar: 08/04/93 :  Added additional arguments to enable auto-dimensioning.
 * Sudhakar: 09/08/93 :  Shifted the 'call to the general algo. on failure
 *                       of special algo.' to the special methods.
 * Sudhakar: 09/20/93 :  Fixed a problem in the allocation of memory for
 *                       recompute info of 'offset' surface.
 * Sudhakar: 24Sep'93 :  Deleted 'two' arguments and added 'one'. This
 *                       carries the 'dimensioning info'.
 *                       Pulled out all the 'edge' parents. Added a
 *                       'surface' parent for dimensioning common thickness.
 *                       Modified to handle change in 'recompute' info.
 */
class implementation EMSgencompsf;

#include "DIdef.h"
#include "OMmacros.h"
#include "EMSas.h"
#include "bsparameters.h"
#include "emssfintdef.h"
#include "REshsolid.h"
#include "REgensolid.h"
#include "REgencompsf.h"
#include "emssfint.h"
#include "msmacros.h"
#include "ECmsg.h"


struct dimension_info
{
  GRobjid    surf;
  IGRpoint   uv_point;
  OMuword    view_index;
};

extern OMuword OPP_EMSgensolid_class_id;

IGRlong EMplace_offset ( msg, 
                         opts, 
                         mdenv, 
                         level, 
                         disp, 
                         dispattr, 
                         objname,
                         surface,
                         distance,

			 num_spec_tks,
			 spec_tks,
			 num_sfs_per_tk,
			 spec_surf_ids,
                         dimensioning_info,
                         natural_normal,
                         trimming_required,
                         is_solid,
                         offobj )
    IGRlong                 * msg;
    IGRushort         opts;
    struct GRmd_env         * mdenv;
    IGRshort                  level;
    struct IGRdisplay       * disp;
    IGRchar                 * dispattr, * objname;
    struct EMSobject_info   * surface;
    struct EMSvalue_info    * distance;

    IGRint		      num_spec_tks;
    struct EMSvalue_info    * spec_tks;
    IGRint                  * num_sfs_per_tk;
    GRobjid                 * spec_surf_ids;
    struct dimension_info   *dimensioning_info;
    IGRboolean                natural_normal;
    IGRboolean                trimming_required;
    IGRboolean                is_solid;
    GRobjid                 * offobj;
{
    IGRshort                mattyp;
    IGRlong                 msg_loc, stat_func, om_msg;
    IGRdouble             * mat;
    struct GRmd_env         loc_mdenv;
    IGRchar                 loc_name[DI_PATH_MAX];
    struct IGRdisplay       loc_disp;
    struct GRvg_construct   vgcnstr;
    struct EMSobject_info   *parobjs;
    GRspacenum              constros;
    void                    EMinitvgcnstr();
    IGRboolean              EMgetvgcnstr(), convert_into_plane = TRUE;
    IGRlong                 EMgetparptobj(), EMgetparvalobj();
    extern OM_S_OBJID       current_creator;
    struct GRid             active_grid;
    int			    i,j;
    int 		    surf_count=0;
    struct GRobjid_set	    *spec_surf_set = NULL;
    IGRdouble		    *val_spec_thick = NULL;
    IGRint		    spec_sfs_obj_count=0;
    IGRint		    parent_count=0;

    *msg = EMS_S_Success;
    om_msg = OM_S_SUCCESS;

    EMinitvgcnstr (&msg_loc, &loc_mdenv, &loc_disp, loc_name, &vgcnstr);
    stat_func = EMgetvgcnstr (opts, EMSgrid, mdenv, level, disp, dispattr, 
                                                          objname, &vgcnstr);
    EMerr_hndlr (!stat_func, *msg, EMS_E_Fail, ret_end);

    constros = vgcnstr.env_info->md_id.osnum;
    mattyp = vgcnstr.env_info->md_env.matrix_type;
    mat = vgcnstr.env_info->md_env.matrix;

    if (opts & EMSasconst_notassociative)
    {
        struct GRlc_info        lc_info;
        IGRdouble               loc_distance;

        lc_info.module_info = surface->env;
        lc_info.located_obj = surface->grid;

        om_msg = EMgetparval_numeric (&msg_loc, distance, &loc_distance);
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

	if(num_spec_tks)
	{
	    val_spec_thick= (IGRdouble *)
	         om$malloc(size = num_spec_tks * sizeof(IGRdouble));
	    spec_surf_set = (struct GRobjid_set *)
	         om$malloc(size = num_spec_tks * sizeof(struct GRobjid_set));
   
	    for(i=0;i<num_spec_tks;i++)
	    {
	        EMgetparval_numeric(&msg_loc,&spec_tks[i],&val_spec_thick[i]);
   
	        spec_surf_set[i].num_ids = num_sfs_per_tk[i];
	        spec_surf_set[i].objids = (GRobjid *)
		        om$malloc(size = num_sfs_per_tk[i] * sizeof(GRobjid));
	        for(j=0;j<num_sfs_per_tk[i];j++)
	    	    spec_surf_set[i].objids[j]=spec_surf_ids[surf_count++];
	    }
	}
        if (is_solid)
        {
            om_msg = EMoffset_surface_to_solid ( &lc_info,
                                                 loc_distance,
                                                 natural_normal,
                                                 &vgcnstr,
                                                 NULL_OBJID,
                                                 offobj );
        }
        else
        {
            ex$message(msgnumb = EMS_S_OffsettingSurface);
            om_msg = om$send ( msg = message EMSsurface.EMoffset
                                 ( &msg_loc, 
                                   (trimming_required) ? 
                                   EMS_opt_offsetS_copy_topology : 0,
                                   &mattyp, mat,
                                   &vgcnstr,
                                   natural_normal,
                                   loc_distance,
                                   num_spec_tks,
				   val_spec_thick,
				   spec_surf_set,
                                   0, NULL, NULL,
                                   offobj,NULL),
                               senderid = NULL_OBJID,
                               targetid = surface->grid.objid,
                               targetos = surface->grid.osnum );
        }
        EMerr_hndlr (EMSerror (om_msg & msg_loc), *msg, EMS_E_Fail, ret_end);
        ex$message(msgnumb = EMS_I_00000);

	if(num_spec_tks)
	{
	    om$dealloc(ptr=val_spec_thick);
	    for(i=0;i<num_spec_tks;i++)
		om$dealloc(ptr=spec_surf_set[i].objids);
	    om$dealloc(ptr=spec_surf_set);
	}
    }
    else
    {
        struct EMSoffset_surface    *as_offset = NULL;
        struct surfs_per_thickness  *surfs_per_tk = NULL;
        IGRint number_of_parents, size=0;

	if(num_spec_tks)
	    for(i=0;i<num_spec_tks;i++)
		spec_sfs_obj_count+=num_sfs_per_tk[i];

        number_of_parents = 4 + num_spec_tks + spec_sfs_obj_count;
                  /* orig.surf , common_offset , optional_parent ,
                            common_offset_dimension_surface  = 4 */
        parobjs = (struct EMSobject_info *) alloca (number_of_parents *
               sizeof (struct EMSobject_info));
        EMerr_hndlr (!parobjs, *msg, EMS_E_NoStackMemory, ret_end);

        parobjs[0] = *surface;
      
        om_msg = EMgetparval_object (&msg_loc, constros, NULL, distance, &parobjs[1]);
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

/********* optional parent **********/
	om_msg  = om$send(msg = message EMSsurface.EMgetactiveid(&msg_loc,
    	        &active_grid, NULL),
    		senderid = NULL_OBJID,
    		targetid = surface->grid.objid,
    		targetos = surface->grid.osnum);

         parobjs[2].grid =  active_grid ;
         parobjs[2].env  =  surface->env;
/********* optional parent **********/

         parent_count=3;
	 if(num_spec_tks)
	 {
	     for(i=0;i<num_spec_tks;i++)
	     {
		  om_msg = EMgetparval_object (&msg_loc, constros, NULL,
			       &spec_tks[i],&parobjs[parent_count++]);
                  EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail,
			       ret_end);
	     }
         }

      /* Dimension Surface for the Common Thickness */

         parobjs[parent_count].grid.objid =
                        dimensioning_info[0].surf;
         parobjs[parent_count].grid.osnum = constros;
         OM_BLOCK_MOVE (mdenv, &parobjs[parent_count].env,
                                sizeof (struct GRmd_env));
         parent_count++;

      /* Specific Thickness Surfaces */

	 surf_count=0;
	 if(num_spec_tks)
	 {
	     for(i=0;i<num_spec_tks;i++)
	     {
		   for(j=0;j<num_sfs_per_tk[i];j++)
		   {

	       parobjs[parent_count].grid.objid =
			          spec_surf_ids[surf_count++];
		       parobjs[parent_count].grid.osnum = constros;
                       OM_BLOCK_MOVE (mdenv, &parobjs[parent_count].env,
                                  sizeof (struct GRmd_env));
		       parent_count++;
                   }
	     }
         }
	
#ifdef DEBUG
 printf(" parent_count = %d\n", parent_count);
 printf(" number_of_parents = %d\n", number_of_parents);
#endif

        size = sizeof(struct EMSoffset_surface) +
                 (num_spec_tks + 1) *
                        sizeof(struct surfs_per_thickness) +
                 sizeof(IGRint); /*pad*/

        as_offset = (struct EMSoffset_surface *)alloca(size);
   
        as_offset->props = 0;
        as_offset->num_spec_tks = num_spec_tks;

        if (natural_normal)     as_offset->props |= EMS_NATURAL_NORMAL;
        if (trimming_required)  as_offset->props |= EMS_TRIMMING;
        surfs_per_tk = as_offset->off_surf_views;

	for(i=0;i<=num_spec_tks;i++)
	{
	    surfs_per_tk[i].num_sfs_per_tks = 
                        (i == 0 ? 0 : num_sfs_per_tk[i-1]);

            if(dimensioning_info)
              surfs_per_tk[i].best_view_index
                          = dimensioning_info[i].view_index;   /*  ?????? */
            else
              surfs_per_tk[i].best_view_index = 1;   /*  ?????/ */
         surfs_per_tk[i].uv_point[0] = 
                        dimensioning_info[i].uv_point[0];/* u- value*/
         surfs_per_tk[i].uv_point[1] = 
                        dimensioning_info[i].uv_point[1];/* v- vlaue*/

	}
       
        om_msg = om$construct(classid = (is_solid) ?
                                OPP_EMSgensolid_class_id : 
                                OPP_EMSgencompsf_class_id,
                              osnum = constros, 
                              p_objid = offobj);
        if (1 & om_msg)
        {
          if(!is_solid)
          {
            ex$message(msgnumb = EMS_S_OffsettingSurface);
          } 
          current_creator = *offobj;
          om_msg = om$send(msg = message EMSassoc.EMinit_associative 
                   ( &msg_loc,
                     opts & ~EMSasconst_recompute,
                     number_of_parents, 
                     parobjs, 
                     is_solid ?
                     (convert_into_plane ? EMS_ASsolid_by_offsetting_surface1
                                         : EMS_ASsolid_by_offsetting_surface)
                                :
                    (convert_into_plane ? EMS_ASsurface_by_offsetting_surface1
                                        : EMS_ASsurface_by_offsetting_surface),
                     size,
                     (IGRchar *)as_offset,
                     &vgcnstr ),
                    senderid = NULL_OBJID,
                    targetid = *offobj,
                    targetos = constros);
          current_creator = NULL_OBJID;
        }
        EMerr_hndlr (EMSerror (msg_loc & om_msg), *msg, EMS_E_Fail, ret_end);

    }

   if((1&om_msg&msg_loc) && convert_into_plane)
    om_msg = EMconvert_into_plane(msg, NULL, NULL, NULL, NULL, NULL, NULL, 
             NULL, vgcnstr.env_info, *offobj, constros);
   ex$message(msgnumb = EMS_I_00000);

 ret_end:

        EMWRAPUP (*msg, om_msg, "EMplace_offset");
        return (om_msg);
}

end implementation EMSgencompsf;

