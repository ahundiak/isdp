
/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:40:37 $
$Locker:  $
*/

class implementation Root;

/*
 * This has to be a .I file so we can send messages to get the element 
 * properties.
 */

#define USE_SYMB_MODES 0

#define	BOUND_TOL	0.0000005	/* parametric 'fudge' value for bndries	*/

#include <stdio.h>

#include "wl.h"

#include "OMminimum.h"
#include "OMindex.h"
#include "OMDB.h"

#include "igrtypedef.h"
#include "igetypedef.h"
#include "igrdef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "dp.h"
#include "dpstruct.h"

#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "igewindef.h"
#include "igewinmacros.h"
#include "igecolordef.h"
#include "igecolor.h"
#include "igecolmacros.h"
#include "exdef.h"
#include "exmacros.h"
#include "madef.h"
#include "dpdef.h"

#include "hstiler.h"
#include "hslight.h"
#include "hsurf.h"
#include "hsdef.h"
#include "hsmacros.h"
#include "HStl_element.h"
#include "HStl_window.h"
#include "hsmacdef.h"
#include "hsmacros.h"

#include "HSe2_mesher.h"
#include "HSpr_driver.h"
#include "HStl_global.h"

from EMSsurface import EMgetactiveid;
from module import GRmod_passon;
from OMrtree import get_stat;
from EMSsubbs import EMpartolbasis;
from IGEuserramp import get_sim_user_ramp;
/*from IGEcolor import get_rgb_value, read_res_colors;*/

%safe
static IGRmatrix id_matrix = {	1.0, 0.0, 0.0, 0.0,
				0.0, 1.0, 0.0, 0.0,
				0.0, 0.0, 1.0, 0.0,
				0.0, 0.0, 0.0, 1.0 };

static IGRboolean      HSloopset_chandef_defined = FALSE;
static OM_S_CHANSELECT HSloopset_chandef;
%endsafe

extern OM_S_OBJID HSglobal_IGEcolor_id;
extern OMuword    HSglobal_IGEcolor_os;

from EMSloopset  import EMgetrange;


/*--- HSget_bounded_uv_range -------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HSget_bounded_uv_range( OM_S_OBJID objid,
					OMuword osnum,
			  struct IGRbsp_surface *surf,
				      IGRdouble u_range[2],
				      IGRdouble v_range[2] )
#else
	void HSget_bounded_uv_range( objid, osnum, surf, u_range, v_range )

	OM_S_OBJID objid;
	OMuword    osnum;
	struct IGRbsp_surface *surf;
	IGRdouble             u_range[2];
	IGRdouble             v_range[2];
#endif

/*
DESCRIPTION
	Given the object id, object space number, and geometry of a surface, this
	function determines the minimum UV space range box that encloses the entire
	solid area of the surface.

HISTORY
	S.P. Rogers  09/05/89  Creation Date
*/

	{
	IGRlong             sts;
 	IGRlong             msg;
	OMuint              chan_count;
	IGRdouble           uv_range[4];
	OM_S_OBJECT_LINKAGE loopset[1];


	u_range[0] = surf->u_knots[ surf->u_order - 1 ];
	u_range[1] = surf->u_knots[ surf->u_num_knots - surf->u_order ];
	v_range[0] = surf->v_knots[ surf->v_order - 1 ];
	v_range[1] = surf->v_knots[ surf->v_num_knots - surf->v_order ];

	if ( surf->num_boundaries > 0 )
	   {
	   /* get the loopset object */
	   if ( ! HSloopset_chandef_defined )
	      {
	      om$make_chanselect( channame     = "EMSsubbs.to_loopset",
	                          p_chanselect = &HSloopset_chandef );

	      HSloopset_chandef_defined = TRUE;
	      }

	   chan_count = 0;
	   sts = om$get_channel_objects( osnum        = osnum,
	                                 objid        = objid,
	                                 p_chanselect = &HSloopset_chandef,
	                                 list         = loopset,
	                                 size         = 1,
	                                 count        = &chan_count );

	   if ( chan_count != 0 )
	      {
	      /* get the uv space range box of the boundaries from the loopset */
	      sts = om$send( mode         = OM_e_wrt_object,
	                     msg          = message EMSloopset.EMgetrange( &msg,
	                                                                   uv_range ),
	                     senderid     = NULL_OBJID,
	                     targetid     = loopset[0].S_objid,
	                     targetos     = loopset[0].osnum );
	   	       
	      if ( 1 & sts & msg )
	         {
	         /* make sure the loopset uv range is within */
	         /* the uv range of the surface              */
	         if ( uv_range[0] - BOUND_TOL > u_range[0] )
	            u_range[0] = uv_range[0] - BOUND_TOL;

	         if ( uv_range[1] - BOUND_TOL > v_range[0] )
	            v_range[0] = uv_range[1] - BOUND_TOL;

	         if ( uv_range[2] + BOUND_TOL < u_range[1] )
	            u_range[1] = uv_range[2] + BOUND_TOL;

	         if ( uv_range[3] + BOUND_TOL < v_range[1] )
	            v_range[1] = uv_range[3] + BOUND_TOL;
	         }

	      }  /* end: if ( there is a loopset object ) */

	   }  /* end: if ( surface has boundaries ) */

	}  /* HSget_bounded_uv_range */


/*-- HSget_dpb_data ---------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	void HSget_dpb_data( IGRint objid,
			     IGRint osnum,
			     IGRint *accuracy_mode,
			     IGRint *accuracy,
			     IGRint *style_mode,
			     IGRint *style,
			     IGRint *fem_mesh,
			     IGRint *fem_style,
			     IGRint *finish,
			  IGRdouble *spec_refl,
			  IGRdouble *diff_refl,
			  IGRdouble *transparency )
#else
	void HSget_dpb_data( objid, osnum,
		             accuracy_mode, accuracy,
		             style_mode, style,
		             fem_mesh, fem_style,
		             finish, spec_refl, diff_refl, transparency )

	IGRint objid,	         /* input - object id for sending msg	*/
	       osnum,            /* input - osnum for sending msg       */
	       *accuracy_mode,   /* output - accuracy or window tol mode*/
	       *accuracy,        /* output - object's tile accuracy	*/
	       *style_mode,      /* output - active or ele style mode	*/
	       *style,	         /* output - object's style		*/
	       *fem_mesh,        /* output - object's FEM mesh mode	*/
	       *fem_style,       /* output - object's FEM style		*/
	       *finish;          /* output - object's finish		*/

	IGRdouble *spec_refl,    /* output - object's specular refl	*/
	          *diff_refl,    /* output - object's diffuse refl	*/
	          *transparency; /* output - object's transparency	*/
#endif

/*
 * DESCRIPTION:
 * Finds out what the accuracy, translucency, style, and FEM parms
 * are for the object to be tiled by checking the mode for each option
 * and getting the actual data from either the element or the dpb.
 *
 * HISTORY: 10/22/86 created.			S. A. Rapa
 */

	{
#if USE_SYMB_MODES
	IGRint	  finish_mode, trans_mode, reflect_mode;
	IGRint    act_style, act_finish;
	IGRint    ele_style;
	IGRdouble act_trans;
	IGRdouble act_spec_reflect, act_diff_reflect;
	IGRint    ele_finish;
	IGRdouble ele_trans;
	IGRdouble ele_spec_reflect, ele_diff_reflect;
#endif


	hs$get_accuracy_mode( acc_mode = accuracy_mode );
	if ( *accuracy_mode == HS_ACCURACY_MODE_ACTIVE )
	   {
	   hs$get_shading_accuracy( accuracy = accuracy );
	   }
	else
	   *accuracy = 1;

#if USE_SYMB_MODES

	hs$get_element_shading_symb( objid        = objid,
	                             osnum        = osnum,
	                             style        = &ele_style,
                                     finish       = &ele_finish,
                                     spec_refl    = &ele_spec_reflect,
                                     diff_refl    = &ele_diff_reflect,
	                             transparency = &ele_trans );

	hs$get_active_shading_symb( style        = &act_style,
                                    finish       = &act_finish,
	                            spec_refl    = &act_spec_reflect,
	                            diff_refl    = &act_diff_reflect,
	                            transparency = &act_trans );

	hs$get_symbology_modes( style_mode   = style_mode,
                                finish_mode  = &finish_mode,
                                reflect_mode = &reflect_mode,
	                        trans_mode   = &trans_mode );

	*style = (*style_mode == HS_MODE_ELEMENT) ? ele_style : act_style;

	*finish = (finish_mode == HS_MODE_ELEMENT) ? ele_finish : act_finish;
	*spec_refl = (reflect_mode == HS_MODE_ELEMENT) ? ele_spec_reflect : act_spec_reflect;
	*diff_refl = (reflect_mode == HS_MODE_ELEMENT) ? ele_diff_reflect : act_diff_reflect;
	*transparency = (trans_mode == HS_MODE_ELEMENT) ? ele_trans : act_trans;
#else
	hs$get_element_shading_symb( objid        = objid,
	                             osnum        = osnum,
                                     finish       = finish,
                                     spec_refl    = spec_refl,
                                     diff_refl    = diff_refl,
	                             transparency = transparency );

	*style_mode = HS_MODE_ACTIVE;
	*style = active_window->shading_style;
#endif

	hs$get_fem_mesh( fem_mesh = fem_mesh );
	hs$get_fem_style( fem_style = fem_style );

	}  /* HSget_dpb_data */


/*-- HSfrom_solid ---------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRboolean HSfrom_solid( OM_S_OBJID surface_id,
				    OMuword surface_os )
#else
	IGRboolean	HSfrom_solid (surface_id, surface_os)

	OM_S_OBJID	surface_id;
	OMuword         surface_os;
#endif

/*
 * Returns TRUE if the surface is part of a solid, FALSE otherwise.
 *
 * HISTORY: 01/22/88 Created.			C. M. Jablonski
 */

 {
   IGRlong	sts, msg;
   OMuword	active_classid;
   struct GRid	active_id;

   sts = om$send(mode		= OM_e_wrt_object,
		 msg		= message EMSsurface.EMgetactiveid
					(&msg, &active_id, NULL),
		 senderid	= NULL_OBJID,
		 targetid 	= surface_id,
	         targetos	= surface_os);

   if (sts==OM_S_SUCCESS)
      {
      sts = om$get_classid(	osnum		= active_id.osnum,
				objid		= active_id.objid,
				p_classid	= &active_classid);
      if (sts==OM_S_SUCCESS)
         sts = om$is_ancestry_valid(	subclassid	= active_classid,
				      	superclassname	= "EMSsolid");
      }

   return(sts==OM_S_SUCCESS);
 }


/*-- HSget_top_range ---------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRboolean	HSget_top_range( IGRdouble *range )
#else
	IGRboolean	HSget_top_range( range )

	IGRdouble	*range;
#endif

/*
 * Returns the top-level range box for the current window.
 *
 * HISTORY: 02/15/88 Created.			C. M. Jablonski
 */

 {
IGRint		sts, ret, beg=0, fin=0;
IGRlong		msg;
IGRboolean	success = FALSE;
OM_S_OBJID	mod_id;
OMuword		mod_osnum;
OM_S_MESSAGE	rng_msg;
OM_S_RTREESTAT	rtree_info;
struct get_rng
 {
 OM_p_RTREESTAT	rt_stat;
 IGRint		*ret;
 }	rng_arg;

   rtree_info.request_type = RTREE_PAGE_STATUS;
   rtree_info.rtree_status.page.level_no = 0;

   rng_arg.rt_stat = &rtree_info;
   rng_arg.ret = &ret;

   /* get range of rtree */
   sts = om$make_message(	classname	= "OMrtree",
				methodname	= "get_stat",
				size		= sizeof(struct get_rng),
				p_arglist	= &rng_arg,
				p_msg		= &rng_msg);
   if (!(sts&1))
      {
      printf("Error in HSget_z_range's make message\n");
      om$report_error(sts=sts);
      }
   else
      {
      sts = ex$get_cur_mod (	id	= &mod_id,
				osnum	= &mod_osnum);
      if (!(sts&1))
         {
         printf("Error in HSget_z_range's get_cur_mod message\n");
         om$report_error(sts=sts);
         }
      else
         {
         sts = om$send (msg	= message module.GRmod_passon(&msg,&rng_msg,"module.primary",&beg,&fin),
			senderid	= NULL,
			targetid	= mod_id,
			targetos	= mod_osnum);
         if (!(sts&1))
            {
            printf("Error in HSget_z_range's send to module\n");
            om$report_error(sts=sts);
            }
         else if (ret!=DB_SUCCESS)
            {
            printf("error in HSget_z_range's send to the rtree\n");
            }
         else if (ret!=DB_I_EMPTYTREE)
            {     
            range[0] = rtree_info.rtree_status.page.page_range.r3ddkey.xmin;
            range[1] = rtree_info.rtree_status.page.page_range.r3ddkey.ymin;
            range[2] = rtree_info.rtree_status.page.page_range.r3ddkey.zmin;
            range[3] = rtree_info.rtree_status.page.page_range.r3ddkey.xmax;
            range[4] = rtree_info.rtree_status.page.page_range.r3ddkey.ymax;
            range[5] = rtree_info.rtree_status.page.page_range.r3ddkey.zmax;
            success = TRUE;
            }
         }
      }
   return (success);
 }


/*-- HSget_pt_basis ---------------------------------------------------------*/

#if defined(__STDC__) || defined(__cplusplus)
	IGRdouble	HSget_pt_basis( OM_S_OBJID surface_id,
					   OMuword surface_os )
#else
	IGRdouble	HSget_pt_basis (surface_id, surface_os)

	OM_S_OBJID	surface_id;
	OMuword		surface_os;
#endif

/*
 * Returns the partolbasis for the given surface.
 *
 * HISTORY: 03/03/89 Created.			C. M. Jablonski
 */

{
   IGRlong	sts, msg;
   IGRdouble	pt_basis;
   IGRboolean   dummy;
   IGRshort	mattyp;
   OMuword	active_classid;

   /* determine whether or not the object is a subclass of EMSsubbs */
   sts = om$get_classid(	objid		= surface_id,
				osnum		= surface_os,
				p_classid	= &active_classid);

   if (sts==OM_S_SUCCESS)
      {
      sts = om$is_ancestry_valid(	subclassid	= active_classid,
				      	superclassname	= "EMSsubbs");

      if (sts==OM_S_SUCCESS)
         {
         mattyp = MAIDMX;
         dummy = TRUE;

         sts = om$send(mode	= OM_e_wrt_object,
		 msg		= message EMSsubbs.EMpartolbasis
					(&msg, &mattyp, id_matrix, &dummy, TRUE, &pt_basis),
		 senderid	= NULL_OBJID,
		 targetid 	= surface_id,
		 targetos	= surface_os);

         if (sts==OM_S_SUCCESS)
            {
            return(pt_basis);
            }
         }
      }

   return(0.0);
}


/*-- HSget_rgb_value ---------------------------------------------------------*/

IGRint	HSget_rgb_value( IGRint color )
 
/*
 * Returns the packed rgb value for the given color.
 *
 * HISTORY: 03/21/90 Created.			C. M. Jablonski
 */

{
	IGRint rgb_value;
#	if COMMENT_OUT
	IGRint sts;
	IGRint red, green, blue;
	
	if( color == DPGRID_COLOR )
	{
		sts = om$send( msg = message IGEcolor.read_res_colors( (char *)&rgb_value,
				NULL, NULL, PACKED_COLORS ),
			targetid = HSglobal_IGEcolor_id,
			targetos = HSglobal_IGEcolor_os,
			senderid = NULL_OBJID );
	}
	else
	{
		sts = om$send( msg = message IGEcolor.get_rgb_value( IGE_RIGHT_SCREEN, color,
				(IGRchar *)&rgb_value, PACKED_COLORS ),
			targetid = HSglobal_IGEcolor_id,
			targetos = HSglobal_IGEcolor_os,
			senderid = NULL_OBJID );
	}

	IGEindex_to_rgb( active_window->vc_no, 3, color, &red, &green, &blue );

	rgb_value = (red << 22) | (green << 12) | (blue << 2);
	
#	endif /* COMMENT_OUT */

	ige$get_rgb_value( log_color=color, rgb_value=(char *)(&rgb_value) );
	return( rgb_value );
}  /* HSget_rgb_value */

/*---HSsetup_fem_simulated_ramp------------------------------------------------------*/

/*
NAME
   HSsetup_fem_simulated_ramp

DESCRIPTION
   This function sets up the color column rgb values and the slot number of the
   closest match.  Fem will use this to set it up.  The slot will be used in
   direct shading to fill area and the r g b will be used in blended mode to 
   call IGErgb_to_index to get a smooth shaded look.  A percentage of the distance
   between 2 adjacent colors in the column is used to come up with the target 
   rgb and then a closes match on that color is found with IGErgb_to_index

PARAMETERS

GLOBALS USED
   fem_column

NOTES
  
HISTORY
   07/28/92   Joel D. Underwood
      Creation Date
*/ 

IGRint HSsetup_fem_simulated_ramp(void)
{
   IGRint i, status;
   IGRlong msg;
   OMuint count = 0;
   OM_S_CHANSELECT   chandef;
   GRobjid      modid;
   GRobjid      clr_id, app_id;
   GRspacenum   modos, app_osnum;
   IGRint *test_userramp,num_userramp_colors,which_userramp;
   IGRshort abs_color;
   IGRushort IGEcompensate_array[MAX_NUM_FEM_SHADES * 3];
   IGRdouble gamma[3];
   int (*gamma_compensate)( IGRint, IGRushort *, IGRdouble *, IGRboolean );
   struct IGEcontext_info IGEcontext_info;
   IGEload_context( active_window->context_no, &IGEcontext_info);

   msg = om$make_chanselect(channame = "IGEcolor2.to_IGEuserramp", p_chanselect = &chandef);
   ex$get_cur_mod( id = &modid, osnum = &modos);
   IGEget_col_id(modid,modos,&clr_id);
   msg = om$get_channel_count(osnum = modos,objid = clr_id, p_chanselect = &chandef, count = (OMuint *)&count);

   if (count)
   {
      /* get the application object id and osnum */
      status = om$get_objid_at_index( osnum		= modos,
                                      objid		= clr_id,
                                      p_chanselect	= &chandef,
                                      index		= count - 1,
                                      objidaddr	= &app_id,
                                      osnumaddr	= &app_osnum );

      /* get parameters from object */
      which_userramp = 0;
      num_userramp_colors = -1;
      test_userramp = NULL;
      msg = om$send( msg = message IGEuserramp.get_sim_user_ramp( &which_userramp, &num_userramp_colors,
                                    &test_userramp ), 
                     senderid = clr_id,
                     targetid = app_id,
                     targetos = app_osnum );

      if (IGEcontext_info.user_ramp_start_slot == -1)
      {
         /* the ramp hasn't been setup in IGEload_ramps, so set up fem_column */
         for (i = 0; i < num_userramp_colors; i ++ )
         {
            CLunpack_colors(test_userramp[i], &IGEcompensate_array[(i * 3)], 
               &IGEcompensate_array[(i * 3) + 1], &IGEcompensate_array[(i * 3) + 2]);
         }
         
         for (i = 0; i < num_userramp_colors; i ++ )
         {
            /* the red green and blue here are only used for PSEUDO_TRUE_COLOR dithered */
            /* the values we give should be uncompensated because the cube in physical  */
            /* table is compensated already                                             */
            fem_column[i].red = IGEcompensate_array[(i * 3)] >> 8;
            fem_column[i].green = IGEcompensate_array[(i * 3) + 1] >> 8;
            fem_column[i].blue = IGEcompensate_array[(i * 3) + 2] >> 8;
         }
   
         ige$set_inq_colortable_parameters( gamma_correction = gamma );
         if (gamma[0] != 1.0 || gamma[1] != 1.0 || gamma[2] != 1.0)   
         {
            /* compensate if compensation is on */
            gamma_compensate = IGEget_gamma_compensate_ptr   ( );
            (*gamma_compensate)( num_userramp_colors, IGEcompensate_array, gamma, 1);
         }
   
         for (i = 0; i < num_userramp_colors; i ++ )
         {
            /* the slot to map to is used in direct PSUEDO_TRUE_COLOR and should be compensated */
            /* because this is getting the closest map to physical table which has been         */
            /* compensated and that is what we want to match                                    */
            IGEcmap_color_to_index( active_window->context_no, 0, (WLuint32) IGEcompensate_array[(i * 3)], 
               (WLuint32) IGEcompensate_array[(i * 3) + 1], (WLuint32) IGEcompensate_array[(i * 3) + 2], 
               WL_COLOR_RGB, &fem_column[i].slot);
         }
      }   

      if (test_userramp)
      {
         free(test_userramp);
      }

      /* protect against unknown objects */
      if (msg == OM_E_NOSUCHCLASS ) 
      {
         msg = OM_S_SUCCESS;
      }
      
      if (!(msg & 1))
      {
        om$report_error(sts = msg);
      }
   }
   else
   {
      /* you are trying to set up a fem ramp and the fem object is not there */
      num_userramp_colors = 0;
   }

   /* this is used in both ramp and PSUEDO_TRUE_COLOR modes because simulated ramp */
   HSset_fem_ramp(num_userramp_colors, IGEcontext_info.user_ramp_start_slot);  

   ige$get_abs_color_index(context_no = active_window->context_no, 
                           log_color = 0, 
                           abs_color = &abs_color);
   fem_background = abs_color;

   ige$get_abs_color_index(context_no = active_window->context_no, 
                           log_color = IGE_LOGICAL_HILITE, 
                           abs_color = &abs_color);
   fem_meshcolor = abs_color;

   return(OM_S_SUCCESS);
}

/*--- HSlogical_to_physical_slot -------------------------------*/

int HSlogical_color_to_physical_slot(
   IGRint log_color,
   WLuint32 context_no )

/*
NAME
   HSlogical_color_to_physical_slot

DESCRIPTION
   This function gets the physical slot of a logical color;
   It should only be used for ramp based shading

SYNOPSIS
   int HSlogical_color_to_physical_slot(
      IGRint log_color,
      WLuint32 context_no )

PARAMETERS
   log_color - the logical color to map
   context_no - the context number to map to

GLOBALS USED
   none

RETURN VALUES
   The physical slot for 'abs_color' is returned

HISTORY
   08/20/93 S.P. Rogers
      Creation date
*/

{
   IGRshort abs_color;

#  if defined (XGL)

   /*  In XGL mode, we want to use the forms 8bit context to convert our */
   /*  logical color index to a physical one because the active context is */
   /*  24bit and would return a bad value  */

   CMget_exnuc_forms_context( active_window->vs_no, &context_no );
#  endif

   ige$get_abs_color_index( context_no = context_no,
                            log_color = log_color,
                            abs_color = &abs_color );

   return( abs_color );
}

   

end implementation Root;
