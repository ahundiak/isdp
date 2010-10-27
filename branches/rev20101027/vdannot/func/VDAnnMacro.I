/* $Id: VDAnnMacro.I,v 1.1.1.1 2001/01/04 21:07:40 cvs Exp $  */

/*************************************************************************
/* I/VDS
 *
 * File:         ~VDS/vdannot/func/VDAnnMacro.I
 *
 * Description: This file consists of functions to place annotation/item
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDAnnMacro.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:40  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.3  1997/09/18  03:08:20  pinnacle
# Replaced: vdannot/func/VDAnnMacro.I for:  by mdong for vds
#
# Revision 1.2  1997/08/26  22:09:44  pinnacle
# Replaced: vdannot/func/VDAnnMacro.I for:  by mdong for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.2  1996/08/12  22:18:10  pinnacle
# Replaced: vdannot/func/VDAnnMacro.I for:  by yzhu for vds.241
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.16  1996/05/09  22:26:44  pinnacle
# Replaced: vdannot/func/VDAnnMacro.I for:  by yzhu for vds.240
#
# Revision 1.15  1996/01/15  23:32:08  pinnacle
# Replaced: vdannot/func/VDAnnMacro.I for:  by jwfrosch for vds.240
#
# Revision 1.14  1996/01/10  17:18:24  pinnacle
# Replaced: vdannot/func/VDAnnMacro.I for:  by jwfrosch for vds.240
#
# Revision 1.13  1995/09/06  21:04:06  pinnacle
# Replaced: vdannot/func/VD[AIsg]*.I for:  by jwfrosch for vds.240
#
# Revision 1.12  1995/08/30  13:39:54  pinnacle
# Replaced: vdannot/func/VD[AlpsI]*.I for:  by jwfrosch for vds.240
#
# Revision 1.11  1995/08/29  21:25:42  pinnacle
# Replaced: vdannot/func/VD[ApTgsI]*.I for:  by jwfrosch for vds.240
#
# Revision 1.10  1995/08/23  18:00:02  pinnacle
# Replaced: vdannot/func/VD*I for:  by jwfrosch for vds.240
#
# Revision 1.9  1995/08/21  21:47:44  pinnacle
# Replaced: vdannot/func/VDAnnMacro.I for:  by jwfrosch for vds.240
#
# Revision 1.8  1995/08/18  23:04:08  pinnacle
# Replaced: vdannot/func/*.I for:  by jwfrosch for vds.240
#
# Revision 1.7  1995/07/25  22:43:46  pinnacle
# Replaced: vdannot/func/VDAnnMacro.I for:  by jwfrosch for vds.240
#
# Revision 1.6  1995/07/13  13:46:44  pinnacle
# Replaced: vdannot/func/VDAnnMacro.I for:  by jwfrosch for vds.240
#
 *
 * History:
 *      08/07/94        Chaya V. Rao    Create macro function for annotation. 
 *	09/09/94	cvr,adz		Expeand macro to return object.
 *	06/15/95	tlb		Modify for item number string, drop pfx
 *
 *	01/15/96    HF		TR 179528298
 *				Calculate offset for partially hidden objects.
 *
 *				TR 179528573
 *				Do NOT place VDitem when object is completely 
 *          			hidden
 *
 *				Added new function : VDget_cum_cnt_pt()
 *
 *      05/06/96        yzhu    Change VDtxbox to VDfrmtxt
 *      08/06/96        yzhu    Add VDannot_erase_dimension
 *************************************************************************/

class implementation Root;

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
/*				IMPLEMENTATION FUNCTIONS			*/
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

#include <stdio.h>
#include <string.h>
#include <stdlib.h>

// #if (!defined(_INGR_EXTENSIONS))
// # define      _INGR_EXTENSIONS
// #endif
#include <math.h>
#ifndef M_PI
#define M_PI		3.14159265358979323846
#endif

#include "OMminimum.h"
#include "OMerrordef.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igrdef.h"
#include "igetypedef.h"
#include "gr.h"
#include "fontdef.h"
#include "font.h"
#include "igr.h"
#include "igrdp.h"
#include "griodef.h"
#include "godef.h"
#include "dp.h"
#include "dpdef.h"
#include "dpstruct.h"
#include "go.h"
#include "exdef.h"
#include "ex.h"
#include "exmacros.h"
#include "grio.h"
#include "grmacros.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "madef.h"
#include "bs.h"
#include "asmacros.h"
#include "dpmacros.h"
#include "asbox.h"
#include "nddef.h"
#include "GM.h"
#include "ndmacros.h"
#include "macro.h"
#include "parametric.h"
#include "msdef.h"
#include "exfi.h"
#include "dim.h"
#include "dimdef.h"
#include "dimco.h"
#include "gotext.h"
#include "dimplan.h"
#include "dimannot.h"
#include "dimgraph.h"
#include "dm_status.h"
#include "dimmacros.h"
#include "dimacc.h"
#include "dimext.h"
#include "dimerror.h"
#include "dp.h"
#include "dpdef.h"
#include "dpstruct.h"
#include "expression.h"
#include "expmacros.h"

#include "growner.h"
#include "AS_status.h"
#include "dimdyn.h"
#include "VDSannot.h"
#include "coparadef.h"
#include "coparamac.h"
#include "vdandef.h"
#include "v_miscmacros.h"
#include "v_dbgmacros.h"

#define VD_DEBUG

#include "VDdebug.h"

from	text_exp	import	create;
from	ci_macro	import	init;
from	NDnode		import	NDchg_state, NDconnect, NDgive_structure,
				NDs_compute_node;
from	DMroot		import	DMplace, replace_text, set_dim_state;
from	VDfrmtxt	import	set_box_type;
from	DMsrc		import	DMgive_structure, DMdisplay_source, DMmodify;
from	IGEgragad	import	DPinrot;
from	GRgraphics	import	GRlnproject,GRdisplay;
from	NDmacro		import	ACreturn_foot;
from	GR3dpoint	import	GRgetpolyline;
from	expression	import	modify;
from	DMtxbln		import	get_active_balloon;

extern GRclassid	OPP_nci_macro_class_id,
			OPP_VDitem_class_id,
			OPP_VDfrmtxt_class_id,
			OPP_ACncpx_class_id,
			OPP_ACpretend_class_id,
			OPP_text_exp_class_id;

extern VDget_drawing_item_info_opt();
extern ASmake_source_from_env();
extern GRbuild_prism_helper();
extern MAtypemx();
extern MAoptsxform();
extern IGRdouble VDCmdtxldr_text_angle;

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
/*		Function to place annotation for an object			*/
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

 /*+fe
  Function VDannot_place

  Macro Name
	vd$place_annot ();

  Abstract
	Given an object, format, parameters, box option, window, this
	macro places the annotation for the object

  Arguments

	struct GRobj_env	*object		I	the object to be annotated
	IGRchar			*format		I	the annotation format
	IGRchar			*param		I	the object parameters
	IGRboolean		 box		I	box option TRUE/FALSE
	struct VDan_ldrline	*leader_line
	IGRdouble		 position	I	annotation placement position
	IGRpoint		 offset		I	offset from placement point
	struct EX_button	*window		I	needed to get the window id
	struct GRid		*p_annot	O	created annotation object

  Returns
	TRUE
	In case of failure as$status returns error messages

  -fe*/

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

int VDannot_place
( 
  struct GRobj_env	* object,
  IGRchar		* format,
  IGRchar		* param,
  IGRuchar		  box,
  struct VDan_ldrline	* leader_line,
  IGRdouble		  position,
  IGRpoint		  offset,
  struct EX_button	* window,
  struct GRid		* p_annot
)
{
  long                    status;
  struct GRid             MACRO_OCC, an_grid;
  struct GRmd_env         loc_env;
  IGRint                  an_box_type;
  IGRint                  count, index;
  struct GRid             list[MAX_DIM_ROOTS];
  struct DMtxdynamics_info dyn_info;
  struct DMplan_info      plan_info;
  IGRint                  size, nret;
  IGRshort                rc;
  IGRdouble               out_point[3];
  IGRint                  annot_ldr;

  __enterFunction ( name = "VDannot_place" );

  count = NO_TEXT_LEADER_ROOTS;

  for ( index = 0; index < count; index++ )
  {
    list[index].objid = NULL_OBJID;
  }
  for ( index = 0; index < 3; index++ )
  {
    out_point[index] = 0.0;
  }

  /* get the environment for the as_os */

  size = sizeof ( struct GRmd_env );
  status =
  gr$get_module_env (	msg	= &rc,
			sizbuf	= &size,
			buffer	= &loc_env,
			nret	= &nret );
  as$status ();

  an_grid.objid = NULL_OBJID;
  an_box_type = box;

  if ( status = VDannot_create_macro ( object,
				       format,
				       param,
				       &MACRO_OCC,
				       &loc_env ) )
  {
    if ( status = VDannot_place_dimension ( object,
					    &an_grid,
					    an_box_type,
					    list,
					    &MACRO_OCC,
					    &loc_env,
					    window,
					    &plan_info,
					    &dyn_info,
					    position,
					    offset,
					    out_point,
					    leader_line,
					    &annot_ldr ) )
    {
      if ( status = VDannot_update_text_string ( &dyn_info,
						 &MACRO_OCC,
						 &loc_env,
						 &an_grid ) )
      {
	if ( status = VDannot_compute_dimension ( &loc_env, &an_grid ) )
	{
	  status = VDannot_display_dimension ( &loc_env, &an_grid );
	}
      }
    }
  }

  if ( p_annot && an_grid.objid != NULL_OBJID )
  {
    /*
     * return output structure.
     */
    *p_annot = an_grid;
  }

  _FREE ( dyn_info.info.text_string );

  __exitFunction ( name = "VDannot_place" );

  return ( status );
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
/*		Function To Place Item Number for an object			*/
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

 /*+fe
 Function VDitem_place

 Macro Name
       vd$place_item ();

 Abstract
       Given an object, item_number, position, this
       macro places the item number for the object

 Arguments

       struct GRobj_env		*object		I	the object to be annotated
       IGRint			*bln_type	I	balloon type
       IGRint			*bln_side	I	balloon sides if sides > 4,
       IGRdouble		*bln_size	I	balloon size ratio
       IGRint			 quantity	I	quantity
       struct VDan_ldrline	*leader_line
       IGRdouble		 position	I	item placement position
       IGRpoint			 offset		I	offset from placement point
       struct EX_button		*window		I	gives the window id to project
       struct GRid		*p_item		O	created object.
       IGRint			 item_num	I	item number string

 Returns
       TRUE
       In case of failure as$status returns error messages

 -fe*/

/* ----------------------------------------------------*/

int VDitem_place
(
  struct GRobj_env	* object,
  IGRint		* bln_type,
  IGRint		* bln_sides,
  IGRdouble		* bln_size,
  IGRint		  quantity,
  struct VDan_ldrline	* leader_line,
  IGRdouble		  position,
  IGRpoint		  offset,
  struct EX_button	* window,
  struct GRid		* p_item,
  IGRchar		* itemNo
)
{
  struct GRid             an_grid;
  struct GRmd_env         loc_env;
  long                    status;
  IGRint                  count, index;
  struct GRid             list[MAX_DIM_ROOTS];
  struct DMplan_info      plan_info;
  IGRint                  size, nret;
  IGRshort                rc;
  IGRdouble               out_point[3];
  struct DMsenv_param     par_senv;
  IGRint                  item_ldr;

  __enterFunction ( name = "VDitem_place" );

  count = NO_TEXT_LEADER_ROOTS;

  for ( index = 0; index < count; index++ )
  {
    list[index].objid = NULL_OBJID;
  }
  for ( index = 0; index < 3; index++ )
  {
    out_point[index] = 0.0;
  }

  __printf ( "window           = [%d,%d]", `window->osnum, window->objid` );

  /* get the environment for the as_os */

  size = sizeof ( struct GRmd_env );
  status =
  gr$get_module_env (	msg	= &rc,
			sizbuf	= &size,
			buffer	= &loc_env,
			nret	= &nret );
  as$status ();

  status =
  dm$get_dim_param (	type	= DM_SENV_PARAM,
			p_data	= ( char * ) &par_senv );
  as$status ();

  an_grid.objid = NULL_OBJID;

  if ( ( status = VDitem_place_dimension ( object,
					   &an_grid,
					   list,
					   &loc_env,
					   window,
					   &plan_info,
					   bln_type,
					   bln_sides,
					   bln_size,
					   quantity,
					   position,
					   offset,
					   out_point,
					   itemNo,
					   &item_ldr,
					   leader_line ) ) & 1 )
  {
    if ( status = VDannot_compute_dimension ( &loc_env, &an_grid ) )
    {
      status = VDannot_display_dimension ( &loc_env, &an_grid );
    }
  }

  if ( p_item && an_grid.objid != NULL_OBJID )
  {
    /*
     * return output structure.
     */
    *p_item = an_grid;
  }

  status =
  dm$put_dim_param (	type	= DM_SENV_PARAM,
			p_data	= ( char * ) &par_senv );
  as$status ();

  __exitFunction ( name = "VDitem_place" );

  return ( status );
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
/*	creates the nci_macro-format_text which is a parent of annotation	*/
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

int VDannot_create_macro
(
  struct GRobj_env       *object,
  IGRchar                *format,
  IGRchar                *param,
  struct GRid            *MACRO_OCC,
  struct GRmd_env        *loc_env
)
{
  long                    status = TRUE;
  IGRint                  msg;
  IGRint                  i;
  IGRchar                 loc_param[512], loc_format[512];
  IGRshort                rc;
  struct GRid             CI_TEMP[3];

  __enterFunction ( name = "VDannot_create_macro" );

  /* placing template expression in current os */

  loc_param [0] = '\0';
  loc_format[0] = '\0';

  if ( param != NULL )
  {
    strcpy ( loc_param, param );
  }
  if ( format != NULL )
  {
    strcpy ( loc_format, format );
  }

  if ( object->obj_id.objid == NULL_OBJID )
  {
    status = OM_W_ABORT;
    __print_goto ( "wrapup" );
    goto wrapup;
  }

  /* get the environment for the as_os */

  as$make_source (	go_grid	=  object->obj_id,
			mod_env	= &object->mod_env,
			as_os	= loc_env->md_id.osnum,
			as_grid	= CI_TEMP );
  as$status ();

  /* create text string expression */

  CI_TEMP[1].osnum = loc_env->md_id.osnum;
  status = om$construct ( msg	  = message text_exp.create ( 
							  NULL,
							  loc_format,
							  &rc ),
			  classid = OPP_text_exp_class_id,
			  p_objid = &CI_TEMP[1].objid,
			  osnum	  = CI_TEMP[1].osnum );
  as$status ();

  /* create parameters expression */

  CI_TEMP[2].osnum = loc_env->md_id.osnum;

  status = om$construct ( msg	  = message text_exp.create ( 
							  NULL,
							  loc_param,
							  &rc ),
			  classid = OPP_text_exp_class_id,
			  p_objid = &CI_TEMP[2].objid,
			  osnum	  = CI_TEMP[2].osnum );
  as$status ();

  /* make them support only */

  for ( i = 1; i < 3; i++ )
  {
    status =
    om$send (	msg	 = message NDnode.NDchg_state ( ND_DEL_NO_CH, ND_DEL_NO_CH ),
		senderid = NULL_OBJID,
		targetid = CI_TEMP[i].objid,
		targetos = CI_TEMP[i].osnum );
  }
  as$status ();

  MACRO_OCC->osnum = loc_env->md_id.osnum;

  /* create the ci_macro */

  status =
  om$construct ( classid = OPP_nci_macro_class_id,
		 p_objid = &MACRO_OCC->objid,
		 osnum	 = loc_env->md_id.osnum,
		 msg	 = message NDnode.NDchg_state ( ND_DEL_NO_CH,
						        ND_DEL_NO_CH ) );
  as$status ();

  __printf ( "CI_MACRO         = [%d,%d]", `MACRO_OCC->osnum, MACRO_OCC->objid` );

  status =
  om$send (	msg	 = message ci_macro.init ( &msg,
						   0,
						  "format_text",
						   3,
						   CI_TEMP,
						   NULL,
						   loc_env ),
		senderid = NULL_OBJID,
		targetid = MACRO_OCC->objid,
		targetos = MACRO_OCC->osnum );

  as$status ();

wrapup:

  __exitFunction ( name = "VDannot_create_macro" );

  return ( status );
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
/*	gets dim_param which is a parent of annotation/item			*/
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

int VDannot_get_dim_param
(
  struct GRid			*list,
  struct DMtxdynamics_info	*dyn_info
)
{
  int			 status = OM_S_SUCCESS;

  status =
  dm$get_dim_param (	type	= DM_SENV_PARAM,
			p_grid	= &list[DIM_ROOT_SENV] );
  as$status ();

  status =
  dm$get_dim_param (	type	= DM_MISC_PARAM,
			p_data	= ( char * ) &dyn_info->info.par_misc );
  as$status ();

  return ( status );
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
/*	gets DMplan which is a parent of annotation/item			*/
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

int VDannot_get_dim_plane
(
  struct EX_button       *window,
  struct GRmd_env        *loc_env,
  struct GRid            *list,
  struct DMplan_info     *plan_info
)
{
  long                    status;
  struct GRid             win_grid;

  win_grid.objid = window->objid;
  win_grid.osnum = window->osnum;

  status =
  dm$get_dim_plane (	win_grid = win_grid,
			md_env	 = loc_env,
			p_grid	 = &list[DIM_ROOT_PLAN] );
  as$status ();

  status =
  dm$get_plan_info (	plan_objid	= list[DIM_ROOT_PLAN].objid,
			osnum		= list[DIM_ROOT_PLAN].osnum,
			md_env		= loc_env,
			plan_info	= plan_info );
  as$status ();

  return ( status );
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
/*	places the point of annotation, also constructs the DMsrc which is a	*/
/*	parent of annotation							*/
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

int VDannot_place_dimension
(
  struct GRobj_env       *object,
  struct GRid            *an_grid,
  IGRint                  an_box_type,
  struct GRid            *list,
  struct GRid            *MACRO_OCC,
  struct GRmd_env        *loc_env,
  struct EX_button       *window,
  struct DMplan_info     *plan_info,
  struct DMtxdynamics_info *dyn_info,
  IGRdouble               position,
  IGRpoint                offset,
  IGRdouble              *out_point,
  struct VDan_ldrline    *leader_line,
  IGRint                 *annot_ldr
)
{
  struct GRid             new_src_obj, TEMP[2];
  struct GRobj_env        connect_pt;
  long                    sts;
  IGRint                  i, j, num_brkpt, arrow_index;
  IGRlong                 stat, retmsg;
  IGRint                  rc, msg;
  long                    status;
  IGRchar                *exp_name = NULL;
  struct GRmd_env         lc_env;
  IGRmatrix               matrix;
  struct IGRline          view_line;
  IGRpoint                norpt, dummy_pt, attach_pt1, attach_pt2;
  IGRdouble               dummy_par;
  IGRdouble              *local_attr;
  IGRint                  action, color, weight, text_len;
  struct DMobj_info       obj_info;
  struct IGRpolyline      polyline;
  IGRdouble               points[3], proj_pnt[3];
  IGRdouble              *brkpt = NULL;
  unsigned short          mask;
  struct GRid             attach_ele1, *attach_ele2, *owner, *win_id;
  IGRchar                *text_str;
  IGRint                  flds, myval, myval1, incr, mac, num_pts, 
			  pt_ind, new_ind;
  IGRdouble               x_old, y_old, z_old, mylen, alpha, adj, opp;
  IGRshort                wldmatx_type, locmatx_type;
  IGRdouble               wld_to_local_matrix[16], local_to_wld_matrix[16];
  IGRdouble               pts[3], new_pts[3];


  SetProc(VDannot_place_dimension); Begin

  __enterFunction ( name = "VDannot_place_dimension" );

  polyline.points = points;

  /* create the ci_macro src_obj */

  for ( i = 0; i < 2; i++ )
  {
    TEMP[i].objid = NULL_OBJID;
    TEMP[i].osnum = object->obj_id.osnum;
  }
  mac = 3;
  win_id = NULL;

  as$make_source ( go_grid =  object->obj_id,
		   mod_env = &object->mod_env,
		   as_grid = &TEMP[0] );

  new_src_obj.osnum = loc_env->md_id.osnum;

  action = 1;

  status =
  om$construct ( classid = OPP_nci_macro_class_id,
		 p_objid = &new_src_obj.objid,
		 osnum   = loc_env->md_id.osnum );
  as$status ();

  for ( i = 1; i < 2; i++ )
  {
    char	textbuffer[80];

    sprintf ( textbuffer, "%d %lf %lf %lf", 
		( int ) position, offset[0], offset[1], offset[2] );
    __DBGpr_str(" textbuffer ", textbuffer);

    status = exp$create ( exp_name	= exp_name,
			  exp_syntax	= textbuffer,
			  osnum		= loc_env->md_id.osnum,
			  p_exp_id	= &( TEMP[i].objid ),
			  p_osnum	= &( TEMP[i].osnum ),
			  type_rq	= EXP_TEXT );

    status = om$send ( msg	= message NDnode.NDchg_state ( 
			( char ) 16, ( char ) 16 ),
		       senderid = NULL_OBJID,
		       targetid = TEMP[i].objid,
		       targetos = TEMP[i].osnum );
  }

  __printf ( "CI_MACRO src_obj = [%d,%d]", 
			`new_src_obj.osnum, new_src_obj.objid` );

  status =
  om$send (	msg = message ci_macro.init (	&msg,
						0,
						"src_obj",
						2,
						TEMP,
						NULL,
						loc_env ),
		senderid = NULL_OBJID,
		targetid = new_src_obj.objid,
		targetos = new_src_obj.osnum );
  as$status ();

  /* return the graphic object (foot) from the nci_macro */

  status =
  om$send (	msg	 = message NDmacro.ACreturn_foot ( 
				    	&stat,
			    		"pnt",
					&connect_pt.obj_id,
					&connect_pt.mod_env.md_env.matrix_type,
				        connect_pt.mod_env.md_env.matrix ),
		senderid = NULL_OBJID,
		targetid = new_src_obj.objid,
		targetos = new_src_obj.osnum );
  as$status ();

  __printf ( "connect_pt       = [%d,%d]", 
			`connect_pt.obj_id.osnum, connect_pt.obj_id.objid` );

  /* make the point nonlocatable and nondisplayable */

  mask = GRIS_DISPLAYABLE | GRIS_LOCATABLE;

  gr$put_properties ( object_id = &connect_pt.obj_id,
		      action	= 0,
		      properties_mask = mask );

  gr$display_object ( object_id = &connect_pt.obj_id, mode = GRbeheo );

  /* get co-ordinates of the point */

  status =
  om$send (	msg	 = message GR3dpoint.GRgetpolyline ( 
				      &retmsg,
				      &connect_pt.mod_env.md_env.matrix_type,
				      connect_pt.mod_env.md_env.matrix,
				      &action,
				      &polyline ),
		senderid = NULL_OBJID,
		targetid = connect_pt.obj_id.objid,
		targetos = connect_pt.obj_id.osnum );

  as$status ();

  __DBGpr_vec( "points[] ", points );

  __printf ( "points[]         = %14.6lf %14.6lf %14.6lf", 
			`points[0], points[1], points[2]` );

  for ( j = 0; j < 3; j++ )
  {
    out_point[j] = points[j];
  }

  __printf ( "out_point[]      = %14.6lf %14.6lf %14.6lf", 
			`out_point[0], out_point[1], out_point[2]` );

  /*  create arrow ----  */

  lc_env = *loc_env;
  obj_info.grid = connect_pt.obj_id;

  status =
  om$send (	msg	 = message IGEgragad.DPinrot ( 
		( IGRlong * ) & rc, matrix ),
		senderid = NULL_OBJID,
		targetid = window->objid,
		targetos = window->osnum );
  as$status ();

  view_line.point1 = &polyline.points[0];

  norpt[0] = view_line.point1[0] + matrix[8];
  norpt[1] = view_line.point1[1] + matrix[9];
  norpt[2] = view_line.point1[2] + matrix[10];

  view_line.point2 = norpt;
  __DBGpr_vec( "view_line.point1[]", view_line.point1); 
  __DBGpr_vec( "view_line.point2[]", view_line.point2); 

  status =
  om$send (	msg	 = message GRgraphics.GRlnproject ( 
				     ( IGRlong * ) & rc,
				     &lc_env.md_env.matrix_type,
				     lc_env.md_env.matrix,
				     &view_line,
				     dummy_pt,
				     obj_info.lnproj,
				     &dummy_par,
				     &obj_info.par ),
		senderid = NULL_OBJID,
		targetid = obj_info.grid.objid,
		targetos = obj_info.grid.osnum );
  as$status ();

  status =
  GRfindcontext (
		    &rc,
		    &connect_pt.mod_env.md_env.matrix_type,
		     connect_pt.mod_env.md_env.matrix,
		    &obj_info.grid.osnum,
		    &obj_info.context );

  if ( status != OM_S_SUCCESS || rc != MSSUCC )
  {
    obj_info.context.objid = NULL_OBJID;
  }

  __printf ( "GRfindcontext status = %d, rc = %d", `status, rc` );

  arrow_index = AN_ROOT_ELEM1;

  __printf ( "obj_info.grid    = [%d,%d]", 
		`obj_info.grid.osnum, obj_info.grid.objid` );
  __printf ( "obj_info.context = [%d,%d]", 
		`obj_info.context.osnum, obj_info.context.objid` );
  __printf ( 
	"obj_info.point[] = %14.6lf %14.6lf %14.6lf, obj_info.u_par = %14.6lf",
 `obj_info.lnproj[0], obj_info.lnproj[1], obj_info.lnproj[2], obj_info.par.u` );
  __DBGpr_vec( "obj_info.point[]", obj_info.lnproj );
  __DBGpr_dbl( "obj_info.u_par", obj_info.par.u );

  status = VDannot_get_dim_plane ( window,
				   loc_env,
				   list,
				   plan_info );
  status =
  BSproj1 (	&rc,
		out_point,
		&plan_info->win_plan.matrix[8],
		obj_info.lnproj,
		proj_pnt );
  as$status ();
  if ( ! ( status & 1 ) )
  {
    __print_goto ( "wrapup" );
    goto wrapup;
  }

  __DBGpr_vec( "proj_pnt", proj_pnt );
  __DBGpr_int( "arrow_index", arrow_index );
  local_attr = &proj_pnt[0];

  /* creates DMsrc  */

  status =
  dm$create_root ( 
		     type	= DMptdist,
		     count	= 1,
		     list	= &obj_info.grid,
		     context	= &obj_info.context,
		     attr	= local_attr,
		     md_env	= &lc_env,
		     p_root	= &list[arrow_index] );
  as$status ();

  attach_ele2	= NULL;
  text_len	= 0;
  text_str	= NULL,
  color		= -1;
  weight	= -1;
  owner		= NULL;
  brkpt		= NULL;
  num_brkpt	= 0;
  attach_ele1	= list[arrow_index];

  for ( j = 0; j < 3; j++ )
  {
    attach_pt1[j] = proj_pnt[j];
    attach_pt2[j] = 0.0;
  }

  if ( leader_line )
  {
    *annot_ldr = 1;
    num_brkpt = leader_line->num_segs;

    __DBGpr_int(" num_brkpt ", num_brkpt); 
    /*
     *fill the brkpts values
     */

    flds   = ( leader_line->num_segs * 3 );
    brkpt  = _MALLOC ( flds, double );
    win_id = _MALLOC ( 1, struct GRid );

    if ( win_id == NULL )
    {
      printf ( "win_id - malloc failed " );
      __print_goto ( "wrapup" );
      goto wrapup;
    }

    win_id->objid = window->objid;
    win_id->osnum = window->osnum;

    status = GRbuild_prism_helper ( &retmsg, win_id, NULL,
				    NULL, NULL, NULL, NULL, local_to_wld_matrix,
				    wld_to_local_matrix, NULL );
    num_pts = 1;

    status = MAtypemx ( &retmsg, wld_to_local_matrix, &wldmatx_type );
    status = MAtypemx ( &retmsg, local_to_wld_matrix, &locmatx_type );

    pts[0] = proj_pnt[0];
    pts[1] = proj_pnt[1];
    pts[2] = proj_pnt[2];

    status = MAoptsxform ( &retmsg, &num_pts, &wldmatx_type,
			   wld_to_local_matrix, pts, new_pts );

    x_old = new_pts[0];
    y_old = new_pts[1];
    z_old = new_pts[2];

      __DBGpr_vec( "new_pts", new_pts);

    myval = 0;
    incr  = 0;

    while ( incr < num_brkpt )
    {
      alpha = leader_line->segs[incr].angle;
      mylen = leader_line->segs[incr].len;

      __DBGpr_dbl( "alpha", alpha);
      __DBGpr_dbl( "mylen", mylen);

      alpha = ( ( alpha / 180.0 ) *  M_PI );
      opp   = ( mylen * ( sin ( alpha ) ) );
      adj   = ( mylen * ( cos ( alpha ) ) );

	brkpt[myval] = x_old + adj;
	x_old = brkpt[myval];

      myval++;

	brkpt[myval] = y_old + opp;
	y_old = brkpt[myval];

      myval++;
      brkpt[myval] = z_old;
      z_old = brkpt[myval];

      __DBGpr_dbl( "x_old", x_old);
      __DBGpr_dbl( "y_old", y_old);
      __DBGpr_dbl( "z_old", z_old);
      myval++;
      incr++;
    }

    myval = 0;
    myval1 = 0;
    incr = 0;

    while ( incr < num_brkpt )
    {
      for ( pt_ind = 0; pt_ind < 3; pt_ind++ )
      {
	pts[pt_ind] = brkpt[myval];
	myval++;
      }

      status = MAoptsxform ( &retmsg, &num_pts, &locmatx_type,
			     local_to_wld_matrix, pts, new_pts );

      __DBGpr_vec( "new_pts", new_pts);
      for ( new_ind = 0; new_ind < 3; new_ind++ )
      {
	brkpt[myval1] = new_pts[new_ind];
	myval1++;
      }
      incr++;
    }
  }
  else
    *annot_ldr = 0;

  list[mac] = *MACRO_OCC;

  status = VDannot_get_dim_param ( list,
				   dyn_info );

  status =
  VDplace_annot2 (   TEXT_WITH_LEADER,
		     DIM_DRIVING,
		     &attach_ele1,
		     attach_ele2,
		     attach_pt1,
		     attach_pt2,
		     num_brkpt,
		     brkpt,
		     text_len,
		     text_str,
		     &list[DIM_ROOT_PLAN],
		     list,
		     owner,
		     color,
		     weight,
		     an_grid );
  if ( an_grid->objid == NULL_OBJID )
  {
    status = FALSE;
    __print_goto ( "wrapup" );
    goto wrapup;
  }

  status =
  om$send (	msg	 = message VDfrmtxt.set_box_type ( &sts, 
					( IGRuchar ) an_box_type ),
		targetid = an_grid->objid,
		targetos = an_grid->osnum,
		senderid = NULL_OBJID );
  as$status ();

wrapup:

  _FREE ( brkpt );
  _FREE ( win_id );

  __exitFunction ( name = "VDannot_place_dimension" );

  End
  return ( status );
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
/*	updates the text string associated with the annotation			*/
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

int VDannot_update_text_string
(
  struct DMtxdynamics_info *dyn_info,
  struct GRid            *MACRO_OCC,
  struct GRmd_env        *loc_env,
  struct GRid            *an_grid
)
{
  IGRint                  rc, an_type;
  long                    sts, status = OM_S_SUCCESS;
  struct ret_struct       ret_struct;

  __enterFunction ( name = "VDannot_update_text_string" );

  an_type = TEXT_WITH_LEADER;

  /* set text parameters */

  dyn_info->info.text_string = _MALLOC ( 1024, unsigned char );
  if ( ! dyn_info->info.text_string )
  {
    status =  OM_E_NODYNMEM;
    __print_goto ( "wrapup" );
    goto wrapup;
  }

  dyn_info->info.text_buff_size		= 1024;
  dyn_info->info.text_length		= 0;
  dyn_info->info.text_string[0]		= '\0';
  dyn_info->info.gtattr.fraction_flag	= 0;

  /* get structure of the nci_macro format_text */

  if ( MACRO_OCC->objid != NULL_OBJID )
  {
    status =
    om$send (	msg	 = message NDnode.NDgive_structure ( &sts, &ret_struct, loc_env ),
		targetid = MACRO_OCC->objid,
		targetos = MACRO_OCC->osnum,
		senderid = NULL_OBJID );
    as$status ();

    strcpy ( ( char * ) dyn_info->info.text_string,
	     &( ret_struct.var.text_st.text_string[0] ) );

    dyn_info->info.text_length = strlen ( ( char * ) dyn_info->info.text_string );

    DMinquire_add_seperator ( dyn_info->info.text_string,
			      &dyn_info->info.text_length,
			      &dyn_info->info.gtattr,
			      &dyn_info->info.text_buff_size,
			      an_type );

    status =
    om$send (	msg	 = message DMroot.replace_text ( 
						    &rc,
						    DIM_TEXT,
						    ( struct GRid * ) NULL,
						    loc_env,
						    dyn_info->info.text_length,
						    dyn_info->info.text_string ),
		senderid = NULL_OBJID,
		targetid = an_grid->objid,
		targetos = an_grid->osnum );
    as$status ();
  }

wrapup:

  __exitFunction ( name = "VDannot_update_text_string" );

  return ( status );
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
/*		computes the dimension						*/
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

int VDannot_compute_dimension
(
  struct GRmd_env        *loc_env,
  struct GRid            *an_grid
)
{
  int                     count, index;
  long                    status;
  IGRlong                 long_rc;
  struct GRid             list[10], root;

  __enterFunction ( name = "VDannot_compute_dimension" );

  count = 0;

  root.objid = an_grid->objid;
  root.osnum = an_grid->osnum;

  status =
  DMget_graph (   root,
		  ROOT | CHILDREN,
		  10,
		  list,
		  &count );
  as$status ();

  for ( index = 0; index < count; index++ )
  {
    status =
    om$send (	msg	 = message NDnode.NDs_compute_node ( 
							&long_rc,
							0,
							loc_env ),
		senderid = NULL_OBJID,
		targetid = list[index].objid,
		targetos = list[index].osnum );
    as$status ();
  }

  __exitFunction ( name = "VDannot_compute_dimension" );

  return ( status );
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
/*	displays the dimension							*/
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

int VDannot_display_dimension
(
  struct GRmd_env        *loc_env,
  struct GRid            *an_grid
)
{
  IGRint                  rc, count, index;
  IGRlong                 status;
  IGRshort                dim_state;
  struct GRid             list[10], root;
  IGRint                  level;
  IGRint                  control;

  __enterFunction ( name = "VDannot_display_dimension" );

  count = 0;
  level = ROOT;
  control = DISPLAY | ADDWRNG;

  root.objid = an_grid->objid;
  root.osnum = an_grid->osnum;

  status =
  DMget_graph (   root,
		  ROOT | CHILDREN,
		  10,
		  list,
		  &count );
  as$status ();

  for ( index = 0; index < count; index++ )
  {
    status =
    DMdisplay_dimension (   &rc,
			    level,
			    control,
			    loc_env,
			    &list[index] );
    as$status ();
  }

  dim_state = ( control & DISPLAY ) ? 0 : DIM_IN_PLACEMENT;

  status =
  om$send (	msg	 = message DMroot.set_dim_state ( BIT_SET, dim_state ),
		senderid = NULL_OBJID,
		targetid = an_grid->objid,
		targetos = an_grid->osnum );
  as$status ();

  __exitFunction ( name = "VDannot_display_dimension" );

  return ( status );
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
/*	places the point on object where item number has to be placed,		*/
/*	also creates the DMsrc which is a parent of item.			*/
/*	checks if the object already has an item number else			*/
/*	updates the string associated with item number.				*/
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

int VDitem_place_dimension
(
  struct GRobj_env	* object,
  struct GRid		* an_grid,
  struct GRid		* list,
  struct GRmd_env	* loc_env,
  struct EX_button	* window,
  struct DMplan_info	* plan_info,
  IGRint		* bln_type,
  IGRint		* bln_sides,
  IGRdouble		* bln_size,
  IGRint		  quantity,
  IGRdouble		  position,
  IGRpoint		  offset,
  IGRdouble		* out_point,
  IGRchar		* item_string,
  IGRint		* item_ldr,
  struct VDan_ldrline	* leader_line
)
{
  char                    st_quantity[80];
  IGRchar                *exp_name = NULL;
  IGRchar                *text_str;

  unsigned short          mask;
  IGRshort                wldmatx_type, locmatx_type;

  IGRint                  i, j, count, val, mac, arrow_index;
  IGRint                  rc, msg;
  IGRint                  action, color, weight, text_len, num_brkpt;
  IGRint                  VDquantity;
  IGRint                  flds, myval, myval1, incr, pt_ind, new_ind, num_pts;
  long                    status;
  IGRlong                 stat, retmsg;
  IGRlong                 loc_msg;

  IGRdouble               dummy_par;
  IGRdouble              *local_attr;
  IGRdouble               points[3], proj_pnt[3];
  IGRdouble               x_old, y_old, z_old, mylen, alpha, adj, opp;
  IGRdouble               wld_to_local_matrix[16], local_to_wld_matrix[16];
  IGRdouble               pts[3], new_pts[3];
  IGRdouble              *brkpt = NULL;
  IGRpoint                norpt, dummy_pt, attach_pt1, attach_pt2;
  IGRmatrix               matrix;
  struct IGRline          view_line;
  struct IGRpolyline      polyline;

  struct GRid             TEMP[2], TEMP1[1], ContextId;
  struct GRid             new_src_obj, foot;
  struct GRid             attach_ele1, *attach_ele2, *owner, *win_id;

  struct GRobj_env        connect_pt;
  struct GRmd_env         lc_env;
  struct DMobj_info       obj_info;

  __enterFunction ( name = "VDitem_place_dimension" );

  VDquantity = quantity;

  polyline.points = points;
  mac = 3;
  win_id = NULL;

  /* create the ci_macro src_obj */

  for ( i = 0; i < 2; i++ )
  {
    TEMP[i].objid = NULL_OBJID;
    TEMP[i].osnum = object->obj_id.osnum;
  }

  as$make_source ( go_grid =  object->obj_id,
		   mod_env = &object->mod_env,
		   as_grid = &TEMP[0] );

  __printf ( ">>>>>>>>>> object->obj_id [%d,%d] ==>> [%d,%d]", `object->obj_id.osnum, object->obj_id.objid, TEMP[0].osnum, TEMP[0].objid` );

//  ASmake_source_from_env ( &object->obj_id,
//			   &object->mod_env,
//			   &TEMP[0],
//			   0 );

  new_src_obj.osnum = loc_env->md_id.osnum;

  action = 1;

  status =
  om$construct ( classid = OPP_nci_macro_class_id,
		 p_objid = &new_src_obj.objid,
		 osnum	 = loc_env->md_id.osnum );
  as$status ();

  for ( i = 1; i < 2; i++ )
  {
    char	textbuffer[80];

    sprintf ( textbuffer, "%d %lf %lf %lf", ( int ) position, offset[0], offset[1], offset[2] );

    status = exp$create ( exp_name	= exp_name,
			  exp_syntax	= textbuffer,
			  osnum		= loc_env->md_id.osnum,
			  p_exp_id	= &( TEMP[i].objid ),
			  p_osnum	= &( TEMP[i].osnum ),
			  type_rq	= EXP_TEXT );

    status = om$send ( msg	= message NDnode.NDchg_state ( ( char ) 16, ( char ) 16 ),
		       senderid = NULL_OBJID,
		       targetid = TEMP[i].objid,
		       targetos = TEMP[i].osnum );

  }

  __printf ( "CI_MACRO src_obj = [%d,%d]", `new_src_obj.osnum, new_src_obj.objid` );

  status =
  om$send (	msg	 = message ci_macro.init ( &msg,
						    0,
						    "src_obj",
						    2,
						    TEMP,
						    NULL,
						    loc_env ),
		senderid = NULL_OBJID,
		targetid = new_src_obj.objid,
		targetos = new_src_obj.osnum );
  as$status ();

  /* return the graphic object (foot) from the nci_macro */

  status =
  om$send (	msg	 = message NDmacro.ACreturn_foot ( 
						    &stat,
						    "pnt",
						    &connect_pt.obj_id,
						    &connect_pt.mod_env.md_env.matrix_type,
						     connect_pt.mod_env.md_env.matrix ),
		senderid = NULL_OBJID,
		targetid = new_src_obj.objid,
		targetos = new_src_obj.osnum );

  as$status ();

  __printf ( "connect_pt       = [%d,%d]", `connect_pt.obj_id.osnum, connect_pt.obj_id.objid` );

  /* make the point nonlocatable and nondisplayable*/

  mask = GRIS_DISPLAYABLE | GRIS_LOCATABLE;

  gr$put_properties ( object_id = &connect_pt.obj_id,
		      action	= 0,
		      properties_mask = mask );

  gr$display_object ( object_id = &connect_pt.obj_id, mode = GRbeheo );

  /* get co-ordinates of the point */

  status =
  om$send (	msg	 = message GR3dpoint.GRgetpolyline ( 
						      &retmsg,
						      &connect_pt.mod_env.md_env.matrix_type,
						       connect_pt.mod_env.md_env.matrix,
						      &action,
						      &polyline ),
		senderid = NULL_OBJID,
		targetid = connect_pt.obj_id.objid,
		targetos = connect_pt.obj_id.osnum );

  as$status ();

  __printf ( "points[]         = %14.6lf %14.6lf %14.6lf", `points[0], points[1], points[2]` );

  for ( j = 0; j < 3; j++ )
  {
    out_point[j] = points[j];
  }

  __printf ( "out_point[]      = %14.6lf %14.6lf %14.6lf", `out_point[0], out_point[1], out_point[2]` );

  /*  create arrow ----  */

  lc_env = *loc_env;
  obj_info.grid = connect_pt.obj_id;

  status =
  om$send (	msg	 = message IGEgragad.DPinrot ( ( IGRlong * ) & rc, matrix ),
		senderid = NULL_OBJID,
		targetid = window->objid,
		targetos = window->osnum );
  as$status ();

  view_line.point1 = &polyline.points[0];

  norpt[0] = view_line.point1[0] + matrix[8];
  norpt[1] = view_line.point1[1] + matrix[9];
  norpt[2] = view_line.point1[2] + matrix[10];

  view_line.point2 = norpt;

  status =
  om$send (	msg	 = message GRgraphics.GRlnproject ( 
						     ( IGRlong * ) & rc,
						     &lc_env.md_env.matrix_type,
						      lc_env.md_env.matrix,
						     &view_line,
						      dummy_pt,
						      obj_info.lnproj,
						     &dummy_par,
						     &obj_info.par ),
		senderid = NULL_OBJID,
		targetid = obj_info.grid.objid,
		targetos = obj_info.grid.osnum );
  as$status ();

  status = GRfindcontext ( 
			   &rc,
			   &connect_pt.mod_env.md_env.matrix_type,
			   connect_pt.mod_env.md_env.matrix,
			   &obj_info.grid.osnum,
			   &obj_info.context );

  if ( status != OM_S_SUCCESS || rc != MSSUCC )
  {
    obj_info.context.objid = NULL_OBJID;
  }

  arrow_index = AN_ROOT_ELEM1;

  __printf ( "obj_info.grid    = [%d,%d]", `obj_info.grid.osnum, obj_info.grid.objid` );
  __printf ( "obj_info.context = [%d,%d]", `obj_info.context.osnum, obj_info.context.objid` );
  __printf ( "obj_info.point[] = %14.6lf %14.6lf %14.6lf, obj_info.u_par = %14.6lf",
		`obj_info.lnproj[0], obj_info.lnproj[1], obj_info.lnproj[2], obj_info.par.u` );

  status = VDannot_get_dim_plane ( window,
				   loc_env,
				   list,
				   plan_info );

  __printf ( "proj_pnt []      = %14.6lf %14.6lf %14.6lf", `proj_pnt[0], proj_pnt[1], proj_pnt[2]` );

  status =
  BSproj1 (	&rc,
		out_point,
		&plan_info->win_plan.matrix[8],
		obj_info.lnproj,
		proj_pnt );
  as$status ();
  if ( ! ( status & 1 ) )
  {
    __print_goto ( "wrapup" );
    goto wrapup;
  }

  __printf ( "win_pln.matrix[8]= %14.6lf %14.6lf %14.6lf (Plane Normal Vector)",
		`plan_info->win_plan.matrix[8], plan_info->win_plan.matrix[9], plan_info->win_plan.matrix[10]` );

  __printf ( "out_point[]      = %14.6lf %14.6lf %14.6lf (Point to Project)",
		`out_point[0], out_point[1], out_point[2]` );
  __printf ( "proj_pnt []      = %14.6lf %14.6lf %14.6lf (Point on Plane)",
		`proj_pnt[0], proj_pnt[1], proj_pnt[2]` );

  local_attr = &proj_pnt[0];

  /* create DMsrc as the root */

  status =
  dm$create_root (   type = DMptdist,
		     count = 1,
		     list = &obj_info.grid,
		     context = &obj_info.context,
		     attr = local_attr,
		     md_env = &lc_env,
		     p_root = &list[arrow_index] );
  as$status ();

  attach_ele2	= NULL;
  text_len	= 0;
  text_str	= NULL,
  color		= -1;
  weight	= -1;
  owner		= NULL;
  brkpt		= NULL;
  num_brkpt	= 0;
  attach_ele1	= list[arrow_index];

  for ( j = 0; j < 3; j++ )
  {
    attach_pt1[j] = proj_pnt[j];
    attach_pt2[j] = 0.0;
  }

  if ( leader_line )
  {
    *item_ldr = 1;
    num_brkpt = leader_line->num_segs;

    /*
     *fill the brkpts values
     */

    flds   = ( leader_line->num_segs * 3 );
    brkpt  = _MALLOC ( flds, double );
    win_id = _MALLOC ( 1, struct GRid );

    if ( win_id == NULL )
    {
      printf ( "win_id - malloc failed " );
      __print_goto ( "wrapup" );
      goto wrapup;
    }
    win_id->objid = window->objid;
    win_id->osnum = window->osnum;

    status = GRbuild_prism_helper ( &retmsg, win_id, NULL,
				    NULL, NULL, NULL, NULL, local_to_wld_matrix,
				    wld_to_local_matrix, NULL );
    num_pts = 1;

    status = MAtypemx ( &retmsg, wld_to_local_matrix, &wldmatx_type );
    status = MAtypemx ( &retmsg, local_to_wld_matrix, &locmatx_type );

    pts[0] = proj_pnt[0];
    pts[1] = proj_pnt[1];
    pts[2] = proj_pnt[2];

    status = MAoptsxform ( &retmsg, &num_pts, &wldmatx_type,
			   wld_to_local_matrix, pts, new_pts );

    x_old = new_pts[0];
    y_old = new_pts[1];
    z_old = new_pts[2];

    myval = 0;
    incr  = 0;

    while ( incr < num_brkpt )
    {
      alpha = leader_line->segs[incr].angle;
      mylen = leader_line->segs[incr].len;

      alpha = ( ( alpha / 180.0 ) *  M_PI );
      opp   = ( mylen * ( sin ( alpha ) ) );
      adj   = ( mylen * ( cos ( alpha ) ) );

	brkpt[myval] = x_old + adj;
	x_old = brkpt[myval];

      myval++;

	brkpt[myval] = y_old + opp;
	y_old = brkpt[myval];

      myval++;
      brkpt[myval] = z_old;
      z_old = brkpt[myval];
      myval++;
      incr++;
    }

    myval = 0;
    myval1 = 0;
    incr = 0;

    while ( incr < num_brkpt )
    {
      for ( pt_ind = 0; pt_ind < 3; pt_ind++ )
      {
	pts[pt_ind] = brkpt[myval];
	myval++;
      }
      status = MAoptsxform ( &retmsg, &num_pts, &locmatx_type,
			     local_to_wld_matrix, pts, new_pts );

      for ( new_ind = 0; new_ind < 3; new_ind++ )
      {
	brkpt[myval1] = new_pts[new_ind];
	myval1++;
      }
      incr++;
    }

  }
  else
    item_ldr = 0;

  /*
   * connect all macros to the place item
   */

  count = 0;

  status = GRfindcontext (	&retmsg,
				&object->mod_env.md_env.matrix_type,
				 object->mod_env.md_env.matrix,
				&object->obj_id.osnum,
				&ContextId );
  if( ! ( status & retmsg & 1 ) ) ContextId.objid = NULL_OBJID;

  __printf ( "status = %d, retmsg = %d, ContextId = [%d,%d]", `status, retmsg, ContextId.osnum, ContextId.objid` );

//  as$make_source (	go_grid		= object->obj_id,
//			context_grid	= ContextId,
//			as_os		= object->obj_id.osnum,
//			as_grid		= &TEMP1[0] );

  as$make_source ( go_grid =  object->obj_id,
		   mod_env = &object->mod_env,
		   as_grid = &TEMP1[0] );

  __printf ( "object->obj_id [%d,%d] ==>> [%d,%d]", `object->obj_id.osnum, object->obj_id.objid, TEMP1[0].osnum, TEMP1[0].objid` );

  val = VDitem_set_balloon_parameters ( bln_type, bln_sides, bln_size );

  list[mac] = TEMP1[0];
  status =
  VDplace_annot2 (   TEXT_WITH_BALLOON,
		     DIM_DRIVING,
		     &attach_ele1,
		     attach_ele2,
		     attach_pt1,
		     attach_pt2,
		     num_brkpt,
		     brkpt,
		     text_len,
		     text_str,
		     &list[DIM_ROOT_PLAN],
		     list,
		     owner,
		     color,
		     weight,
		     an_grid );

  if ( an_grid->objid == NULL_OBJID )
  {
    status = FALSE;
    __print_goto ( "wrapup" );
    goto wrapup;
  }

  /* 07/12/95 HF: exclude VDitem objects (they do not have foot "quantity" */

  if ( DMancestry_valid ( TEMP1[0], OPP_VDitem_class_id )	!= OM_S_SUCCESS
    && DMancestry_valid ( TEMP1[0], OPP_ACpretend_class_id )	!= OM_S_SUCCESS )
  {
    status =
    om$send (	msg	 = message NDmacro.ACreturn_foot ( 
						      &loc_msg, "quantity", &foot, NULL, NULL ),
		senderid = NULL_OBJID,
		targetid = TEMP1[0].objid,
		targetos = TEMP1[0].osnum );

    if ( status & loc_msg & 1 )
    {
      if ( VDquantity > 0 )
	sprintf ( st_quantity, "%d", VDquantity );
      else
	st_quantity[0] = '\0';

      if ( status & loc_msg & 1 )
      {
	status =
	om$send (   msg	 = message expression.modify ( NULL,
						      st_quantity,
						      ( short * ) &loc_msg ),
		    senderid = NULL_OBJID,
		    targetid = foot.objid,
		    targetos = foot.osnum );
      }
    }
  }

  /*
   * put the item number as the dimensional text
   */

  __printf ( "an_grid          = [%d,%d]", `an_grid->osnum, an_grid->objid` );

  status =
  om$send (	msg	 = message DMroot.replace_text ( 
						  &rc,
						  DIM_TEXT,
						  ( struct GRid * ) NULL,
						  loc_env,
						  strlen ( item_string ),
						  ( IGRuchar * ) item_string ),
		senderid = NULL_OBJID,
		targetid = an_grid->objid,
		targetos = an_grid->osnum );

  as$status ();

wrapup:

  _FREE ( brkpt );
  _FREE ( win_id );

  __exitFunction ( name = "VDitem_place_dimension" );

  return status;
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/
/*		sets the item number parameters					*/
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

int VDitem_set_balloon_parameters
(
  IGRint                 *bln_type,
  IGRint                 *bln_sides,
  IGRdouble              *bln_size
)
{
  IGRlong                 status = OM_S_SUCCESS;
  struct DMsenv_param     par_senv;
  IGRchar                 string[80];
  IGRint                  loc_type;
  IGRdouble               loc_size;

  __enterFunction ( name = "VDitem_set_balloon_parameters" );

  status =
  dm$get_dim_param ( type   = DM_SENV_PARAM,
		     p_data = ( char * ) &par_senv );
  as$status ();

  if ( bln_size == NULL )
  {
    loc_size = 3.0;
  }
  else
  {
    loc_size = *bln_size;
  }

  par_senv.bln_size = loc_size;

  if ( bln_type == NULL )
  {
    loc_type = BLN_TYPE_CIRCLE;
  }
  else
  {
    loc_type = *bln_type;
  }

//  __printf ( "loc_size = %14.6lf", loc_size );

  switch ( loc_type )
  {
    case BLN_TYPE_CIRCLE:
      {
	par_senv.bln_type = BLN_TYPE_CIRCLE;
	UI_status ( "balloon type=Circle" );
	break;
      }
    case BLN_TYPE_TRIANGLE:
      {
	par_senv.bln_type = BLN_TYPE_TRIANGLE;
	UI_status ( "balloon type=Triangle" );
	break;
      }
    case BLN_TYPE_SQUARE:
      {
	par_senv.bln_type = BLN_TYPE_SQUARE;
	UI_status ( "balloon type=Square" );
	break;
      }
    case BLN_TYPE_POLYGON:
      {
	par_senv.bln_type = BLN_TYPE_POLYGON;

	UI_status ( "balloon type=Polygon" );

	status =
	  dm$get_dim_param ( type = DM_SENV_PARAM,
			 p_data = ( char * ) &par_senv );
	as$status ();

	par_senv.num_sides = *bln_sides;

	sprintf ( ( char * ) string, "num sides=%d", par_senv.num_sides );

	UI_status ( string );

	break;
      }
    case BLN_TYPE_ELLIPSE:
      {
	par_senv.bln_type = BLN_TYPE_ELLIPSE;
	UI_status ( "balloon type=Ellipse" );
	break;
      }
    case BLN_TYPE_INV_TRIANGLE:
      {
	par_senv.bln_type = BLN_TYPE_INV_TRIANGLE;
	UI_status ( "balloon type=Inverted Triangle" );
	break;
      }
    case BLN_TYPE_RECTANGLE:
      {
	par_senv.bln_type = BLN_TYPE_RECTANGLE;
	UI_status ( "balloon type=Rectangle" );
	break;
      }
    case BLN_TYPE_ONE_LINE_TEXT:
      {
	par_senv.bln_type = BLN_TYPE_ONE_LINE_TEXT;
	UI_status ( "balloon type=One Line of Text (No balloon)" );
	break;
      }
    case BLN_TYPE_SPLIT_CIRCLE:
      {
	par_senv.bln_type = BLN_TYPE_SPLIT_CIRCLE;
	UI_status ( "balloon type=Split Circle" );
	break;
      }
    case BLN_TYPE_SPLIT_TRIANGLE:
      {
	par_senv.bln_type = BLN_TYPE_SPLIT_TRIANGLE;
	UI_status ( "balloon type=Split Triangle" );
	break;
      }
    case BLN_TYPE_SPLIT_SQUARE:
      {
	par_senv.bln_type = BLN_TYPE_SPLIT_SQUARE;
	UI_status ( "balloon type=Split Square" );
	break;
      }
    case BLN_TYPE_SPLIT_POLYGON:
      {
	par_senv.bln_type = BLN_TYPE_SPLIT_POLYGON;
	UI_status ( "balloon type=Split Polygon" );

	status =
	  dm$get_dim_param ( type = DM_SENV_PARAM,
			 p_data = ( char * ) &par_senv );
	as$status ();

	par_senv.num_sides = *bln_sides;

	sprintf ( ( char * ) string, "num sides=%d", par_senv.num_sides );

	UI_status ( string );
	break;
      }
    case BLN_TYPE_SPLIT_ELLIPSE:
      {
	par_senv.bln_type = BLN_TYPE_SPLIT_ELLIPSE;
	UI_status ( "balloon type=Split Ellipse" );
	break;
      }
    case BLN_TYPE_SPLIT_INV_TRIANGLE:
      {
	par_senv.bln_type = BLN_TYPE_SPLIT_INV_TRIANGLE;
	UI_status ( "balloon type=Split Triangle" );
	break;
      }
    case BLN_TYPE_SPLIT_RECTANGLE:
      {
	par_senv.bln_type = BLN_TYPE_SPLIT_RECTANGLE;
	UI_status ( "balloon type=Split Rectangle" );
	break;
      }
    case BLN_TYPE_TWO_LINES_TEXT:
      {
	par_senv.bln_type = BLN_TYPE_TWO_LINES_TEXT;
	UI_status ( "balloon type=Two Lines of Text (No balloon)" );
	break;
      }
    default:
      {
	par_senv.bln_type = BLN_TYPE_CIRCLE;

	break;
      }
  }

  status =
  dm$put_dim_param ( type   = DM_SENV_PARAM,
		     p_data = ( char * ) &par_senv );
  as$status ();

  __exitFunction ( name = "VDitem_set_balloon_parameters" );

  return ( status );
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~	*/

int VDget_cum_cnt_pt
(
  IGRlong	*msg,
  int		 NbGRvg,
  struct GRid	*GRvgId,
  IGRpoint	 offset )
{
  long		 status = OM_S_SUCCESS;
  int		 i0, BytesReceived = 0, NumberOfBytes;
  IGRpoint	 min_pt, max_pt;
  GRrange	 range;
  struct GRobj_env	tmp ;
  struct GRmd_env	mod_env;

  __enterFunction ( name = "VDget_cum_cnt_pt" );

  NumberOfBytes = sizeof(mod_env);
  gr$get_module_env (	msg	=  msg,
			sizbuf	= &NumberOfBytes,
			buffer	= &mod_env,
			nret	= &BytesReceived );

  tmp.mod_env = mod_env;

  NumberOfBytes = sizeof(IGRpoint);
  memset ( offset, 0, NumberOfBytes );
  memset ( min_pt, 0, NumberOfBytes );
  memset ( max_pt, 0, NumberOfBytes );

  for ( i0=0; i0 < NbGRvg; i0++ )
  {
    tmp.obj_id  = GRvgId[i0];

    VD_getRangeOfComposite( msg, &tmp, range );
/*
    __printf ( "Range[LO]  : %14.6lf %14.6lf %14.6lf", `range[0], range[1], range[2]` );
    __printf ( "Range[HI]  : %14.6lf %14.6lf %14.6lf", `range[3], range[4], range[5]` );
*/
    if ( i0 == 0 )
    {
      memcpy ( min_pt, &range[0], sizeof ( IGRpoint ) );
      memcpy ( max_pt, &range[3], sizeof ( IGRpoint ) );
    }
    else
    {
      min_pt[0] = MIN ( range[0], min_pt[0] );
      min_pt[1] = MIN ( range[1], min_pt[1] );
      min_pt[2] = MIN ( range[2], min_pt[2] );

      max_pt[0] = MAX ( range[3], max_pt[0] );
      max_pt[1] = MAX ( range[4], max_pt[1] );
      max_pt[2] = MAX ( range[5], max_pt[2] );
    }

    __printf ( "min_pt[%d]<<: %14.6lf %14.6lf %14.6lf", `i0, min_pt[0], min_pt[1], min_pt[2]` );
    __printf ( "max_pt[%d]>>: %14.6lf %14.6lf %14.6lf", `i0, max_pt[0], max_pt[1], max_pt[2]` );
  }

  offset[0] = ( max_pt[0] + min_pt[0] ) / 2;
  offset[1] = ( max_pt[1] + min_pt[1] ) / 2;
  offset[2] = ( max_pt[2] + min_pt[2] ) / 2;

  __printf ( "offset[E]  : %14.6lf %14.6lf %14.6lf", `offset[0], offset[1], offset[2]` );

  __exitFunction ( name = "VDget_cum_cnt_pt" );

  return ( status );
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/
/*      erase the dimension : added by yzhu 8/5/96
*/
/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
*/

int VDannot_erase_dimension
(
  struct GRmd_env        *loc_env,
  struct GRid            *an_grid
)
{
  IGRint                  rc, count, index;
  IGRlong                 status;
  IGRshort                dim_state;
  struct GRid             list[10], root;
  IGRint                  level;
  IGRint                  control;

  SetProc (VDannot_erase_dimension); Begin

  count = 0;
  level = ROOT;
  control = ERASE|REMWRNG;

  root.objid = an_grid->objid;
  root.osnum = an_grid->osnum;

  status =
  DMget_graph (   root,
                  ROOT | CHILDREN,
                  10,
                  list,
                  &count );
  as$status ();

  for ( index = 0; index < count; index++ )
  {
    status =
    DMdisplay_dimension (   &rc,
                            level,
                            control,
                            loc_env,
                            &list[index] );
    as$status ();
  }

  dim_state = ( control & DISPLAY ) ? 0 : DIM_IN_PLACEMENT;

  status =
  om$send (     msg      = message DMroot.set_dim_state ( BIT_SET, dim_state ),
                senderid = NULL_OBJID,
                targetid = an_grid->objid,
                targetos = an_grid->osnum );
  as$status ();

  End

  return ( status );
}

end implementation Root;
