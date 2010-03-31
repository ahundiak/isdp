command_string		IDFFC_M_PjText,0,IDPjText
class			IDpjtext
super_class		ECcmd
spec_path		"$MODEL/spec"
product_name		"$MODEL"

specification
/*
Abstract
	This command projects 3d text string onto a general B-spline
	surface.

History
	11/15/91	JSY	Design and coding. The implementation
				is based on a program that converts a
				text string to 3d polyline strings.
	03/07/92	JSY	Change color of the two copied surface
				to active color before boolean operation.
				This is a measure to make the solid of 
				projected text all in active color (EMS
				default boolean will take surface to
				impose boundary).
	03/09/92	JSY	Add option to automatically union or
				difference the projected text with the
				input surface.
*/
#include "igrtypedef.h"
#include "OMtypes.h"
#include "igr.h"

/* ------------------------------------------------ */
/* INSTANCE DATA                                    */
/* ------------------------------------------------ */
instance
{
  uword	gd_os;
  OM_S_OBJID gd_id;
  struct IGRpolyline pjvect;
  IGRdouble vect_pts[6], off_dis;
  GRrange txt_range, surf_range;
  IGRint orient;
}


implementation
/*
Abstract
	This command projects 3d text string onto a general B-spline
	surface.

Algorithm
	First we verify the correctness of the projection direction.
	Then, for text written with area fillable font, we create a
	a boundary surface with text strokes as boundaries and next
	project the surface to construct a solid. After making two
	copies of the located surface, two boolean operations are
	performed to get projected text with input offset thickness.
	If the text is in nonfillable font or the offset thickness is
	zero, we convert the text into polyline string and call a EMS
	method: EMproject_curve_on_surface to get projections.

Notes
	o if the text is in nonfillable font and the input offset
	  thickness is nonzero, the program sets the offset thickness
	  zero
	o if the surface is a closed surface, like a cylinder, the
	  offset thickness may not be uniform if the text is projected
	  in the direction such that the projecting text is close to
	  the parting line of the surface.
*/

#include <math.h>
#include "OMmacros.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igrdef.h"
#include "igr.h"
#include "igrdp.h"
#include "grdpbmacros.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "grownerdef.h"
#include "grmacros.h"
#include "exmacros.h"
#include "fontdef.h"
#include "dpstruct.h"
#include "emssfintdef.h"
#include "bs.h"
#include "bsvalues.h"
#include "bsparameters.h"
#include "msdef.h"
#include "msmacros.h"
#include "IDffmsg.h"
#include "bsallocsf.h"    /* prototypes */
#include "bscrossp.h"    /* prototypes */
#include "bsdotp.h"    /* prototypes */
#include "bsfreesf.h"    /* prototypes */
#include "bslenvec.h"    /* prototypes */
#include "bslenvecsq.h"    /* prototypes */
#include "bsmkvec.h"    /* prototypes */
#include "bsnorvec.h"    /* prototypes */
#include "bsptonnsdsf.h"    /* prototypes */
#include "bssf3o4pts.h"    /* prototypes */
#include "bsxtractpar.h"    /* prototypes */
#include "matypemx.h"    /* prototypes */
#include <memory.h>    /* prototypes */
#include <string.h>    /* prototypes */

#define BG_COLOR 0	/* color table index for background color */
#define NUM_OBJ_A 50
#define NUM_STRK_DBLS 9000
#define NUM_STRK_PTS 3000
#define INC_STRK_PTS 1500
#define PJVECT_DYN 101	/* supply own dynamics */
#define IN_AGAIN 10001
#define GO_NEXT 10002

from GRgraphics import GRcopy, GRdelete, GRconstruct, GRaltconstruct, GRxform;
from GRvg	import GRgetsize, GRgetgeom, GRgetsymb, GRputsymb;
from GRtext 	import GRgenabsg, GRgetrang, GRgettxattr;
from GRfm       import GRfm_retdata;
from EMSsurface import EMshow_normals, EMrevorient;
from EMSsubbs   import EMproject_curve_onto_surface;
from EMSsfboolean import EMboolean;

/* function for dynamic rubberbanding */
#argsused
static IGRint IDpjvect(
    struct DPele_header *DYinfo, 
    struct EX_button *point, 
    IGRdouble *matrix, 
    struct GRid **objects, 
    IGRint *num_objects, 
    struct DPele_header **buffers, 
    IGRint *num_buffers, 
    IGRchar *dummy_in1, IGRchar *dummy_in2, IGRchar *dummy_in3, 
    IGRchar *dummy_out1, IGRchar *dummy_out2, IGRchar *dummy_out3)
{
  /* assign the second point */
  DYinfo->geometry.polyline->points[3] = point->x;
  DYinfo->geometry.polyline->points[4] = point->y;
  DYinfo->geometry.polyline->points[5] = point->z;

  *buffers = DYinfo;
  *num_buffers = 1;

  return OM_S_SUCCESS;
}

state_table

#include "OMtypes.h"
#include "griodef.h"
#include "lcdef.h"
#include "comndef.h"
#include "grmessage.h"
#include "IDffmsg.h"
#include "IDffcmd.h"
#include "ECmsg.h"

#define SURF_LC_DISFLAG ALL_WINDOWS | ELEM_HILIGHT | NO_PROJ_ACCEPT_POINT | \
                        ACC_REJ_CYCLE | RELOCATE | LC_REGULAR_HIGHLIGHT | \
                        LC_ERASE_LOC_ELEMENT
#define PJVECT_DYN 101	/* supply own defined dynamics */
#define IN_AGAIN 10001
#define GO_NEXT 10002

at wakeup
  do my_wakeup

state start
  on CMD_TYPE = 0
    state locate_ele

state locate_ele
  message_key IDFFC_M_PjText
  prompt_key IDFF_P_IdentTxt
  accept_key IDFF_P_AccptRejTxt
  relocate_key IDFF_E_RelocTxt
  locate_display MANIP_LC_DISFLAG
  locate_properties COPY_LC_PROPS
  locate_owner LC_NON_GEOM_MOD
  locate_mask "GRm_DATA | GRm_BACK_UP | GRm_RESTART"
  accept_mask "GRm_DATA | GRm_RESTART"
  locate_eligible "+GRtext"
  filter locate_noauto
  on EX_BACK_UP
    state start
  on EX_DATA
    /* save located curve in located_obj[1] */
    do ECcmd.EMsave_located_object( &me->event1, &me->located_obj[1] )
    do ECcmd.EMget_active_dpb
    do save_str_env()
    state locate_surf

state locate_surf
  prompt_key IDFF_P_IdentSurf
  accept_key IDFF_P_FstVectPt
  relocate_key IDFF_E_RelocSurf
  locate_display SURF_LC_DISFLAG
  locate_properties COPY_LC_PROPS
  locate_owner LC_NON_GEOM_MOD
  locate_mask "GRm_DATA | GRm_BACK_UP | GRm_RESTART"
  accept_mask "GRm_DATA | GRm_RESTART"
  locate_eligible "+EMSsubbs"
  filter locate_noauto
  on EX_BACK_UP
    do hilite_located( 1, FALSE )
    state locate_ele
  on EX_DATA
    /* save located surface in located_obj[0] */
    do ECcmd.EMsave_located_object( &me->event1, &me->located_obj[0] )
    do save_fst_pjpnt()
    do highlight_located 0
    state get_sndpt

state get_sndpt
  prompt_key IDFF_P_SndVectPt
  accept_key IDFF_P_SndVectPt
  mask "GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON | GRm_RESTART"
  dynamics PJVECT_DYN
  filter get_event
  on EX_BACK_UP
    do hilite_located( 1, TRUE )
    state locate_surf
  on EX_RJT_MOVEON
    do message_key IDFF_W_IGRJTMOVEON
    state get_sndpt
  on EX_DATA
    do chk_pj_dir
    on RETURN_CODE = IN_AGAIN
      do update_dpb_fstpt()
      state get_sndpt
    do show_surf_normal( TRUE )
    state det_surf_normal

state det_surf_normal
  prompt_key IDFF_P_SfVolSide
  accept_key IDFF_P_SfVolSide
  mask "GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON | GRm_RESTART | GRm_STRING"
  filter get_event
  on EX_BACK_UP
    do show_surf_normal( FALSE )
    do update_dpb_fstpt()
    state get_sndpt
  on EX_RJT_MOVEON
    do orient_surf( FALSE, FALSE )
    state get_pj_thkness
  on EX_DATA
    do orient_surf( TRUE, FALSE )
    state get_pj_thkness
  on EX_STRING.GRst_DEFAULT
    do orient_surf( TRUE, FALSE )
    state get_pj_thkness
  on EX_STRING
    do orient_surf( FALSE, TRUE )
    on RETURN_CODE = IN_AGAIN
      state det_surf_normal
    state get_pj_thkness

state get_pj_thkness
  prompt_key IDFF_P_GetThickness
  accept_key IDFF_P_GetThickness
  mask "GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON | GRm_RESTART | GRm_VALUE"
  filter get_event
  on EX_BACK_UP
    do show_surf_normal( TRUE )
    state det_surf_normal
  on EX_RJT_MOVEON
    do message_key IDFF_W_IGRJTMOVEON
    state get_pj_thkness
  on DISTANCE
    do save_off_dis
    on RETURN_CODE = GO_NEXT
      state accpt_auto_opt
    state start

state accpt_auto_opt
  prompt_key IDFF_P_AutoModSf
  accept_key IDFF_P_AutoModSf
  mask "GRm_DATA | GRm_BACK_UP | GRm_RJT_MOVEON | GRm_RESTART"
  filter get_event
  on EX_BACK_UP
    state get_pj_thkness
  on EX_RJT_MOVEON
    do proj_text( &me->ret, FALSE )
    state start
  on EX_DATA
    do proj_text( &me->ret, TRUE )
    state start

/* ********************************************************************	*
 * action part                                                          *
 * ******************************************************************** */

/* -------------------------------------------------------------------- *
 * Supply own wakeup to override default wakeup method                  *
 * -------------------------------------------------------------------- */
action my_wakeup
{
  struct GRmd_env act_mod;
  IGRshort act_os;
  IGRlong siz_buf, ret_bytes, msg;

  /* get active module info */
  siz_buf = sizeof( struct GRmd_env );
  gr$get_module_env( msg = &msg,
		     sizbuf = &siz_buf,
		     buffer = &act_mod,
		     nret = &ret_bytes );
  act_os = act_mod.md_id.osnum;

  /* verify whether either text or surface has been deleted */
  if ( om$is_objid_valid( objid = me->located_obj[1].located_obj.objid,
			  osnum = act_os ) != OM_S_SUCCESS )
  {
    ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_PjTxtInvTxt );
    me->state = _start;
    goto quit;
  }
  if ( om$is_objid_valid( objid = me->located_obj[0].located_obj.objid,
			  osnum = act_os ) != OM_S_SUCCESS )
  {
    ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_InvalidSurf );
    me->state = _start;
    goto quit;
  }

  switch ( me->state )
  {
  case _locate_surf:
    gr$display_object( object_id = &me->located_obj[1].located_obj,
		       mode = GRhd );
    break;
  case _det_surf_normal:
    status = om$send( msg = message IDpjtext.show_surf_normal( TRUE ),
		      targetid = my_id );
    break;
  }
}

/* -------------------------------------------------------------------- *
 * Save environment when string(s) is selected 			        *
 * -------------------------------------------------------------------- */
action save_str_env()
{
  me->gd_os = me->event1.event.button.osnum;
  me->gd_id = me->event1.event.button.objid;
}

/* -------------------------------------------------------------------- *
 * Highlight the located object                                         *
 * -------------------------------------------------------------------- */
action hilite_located( IGRint which; IGRint draw )
{
  gr$display_object( object_id = &me->located_obj[which].located_obj,
		     mode = ( draw ? GRhd : GRhe ));
}

/* -------------------------------------------------------------------- *
 * Save the first point of the projection vector                        *
 * -------------------------------------------------------------------- */
action save_fst_pjpnt()
{
  me->vect_pts[0] = me->event1.event.button.x;
  me->vect_pts[1] = me->event1.event.button.y;
  me->vect_pts[2] = me->event1.event.button.z;
}

/* -------------------------------------------------------------------- *
 * Update dpb by the first projection point                             *
 * -------------------------------------------------------------------- */
action update_dpb_fstpt()
{
  struct EX_button last_button;
  IGRlong sizbuf, nret, msg;
  
  sizbuf = sizeof( struct EX_button );
  gr$get_last_point( msg = &msg,
		     sizbuf = &sizbuf,
		     buffer = &last_button,
		     nret = &nret );
  last_button.x = me->vect_pts[0];
  last_button.y = me->vect_pts[1];
  last_button.z = me->vect_pts[2];
  gr$put_last_point( msg = &msg,
		     sizbuf = &sizbuf,
		     buffer = &last_button );
}

/* -------------------------------------------------------------------- *
 * Supply dynamics when rubberbanding projection vector                 *
 * -------------------------------------------------------------------- */
action dynamics
{
  struct DPele_header header;

  me->pjvect.num_points = 2;
  me->pjvect.points = me->vect_pts;

  /* build the display buffer */
  dp$build_dis_buffer( buffer = &header,
		       type = IGRPY,
		       display_att = &me->ActiveDisplay,
		       geometry = ( struct IGRpolyline * ) &me->pjvect );

  /* do dynamics */
  dp$dynamics( dyn_fun = IDpjvect,
	       information = &header );
}

/* -------------------------------------------------------------------- *
 * Check to see whether the projection direction is correct             *
 * -------------------------------------------------------------------- */
action chk_pj_dir
{
  IGRvector pj_vec, cnt_vec;
  struct GRmd_env txt_mod, surf_mod;
  IGRboolean wd_loc = TRUE;
  IGRpoint txt_cnt, surf_cnt;
  IGRlong msg;

  me->ret = OM_S_SUCCESS;

  /* get the projection vector */
  pj_vec[0] = me->event1.event.button.x - me->vect_pts[0];
  pj_vec[1] = me->event1.event.button.y - me->vect_pts[1];
  pj_vec[2] = me->event1.event.button.z - me->vect_pts[2];
  me->vect_pts[3] = me->event1.event.button.x;
  me->vect_pts[4] = me->event1.event.button.y;
  me->vect_pts[5] = me->event1.event.button.z;
  
  /* get text and surface module info */
  txt_mod = me->located_obj[1].module_info;
  surf_mod = me->located_obj[0].module_info;

  /* get range of the input text */
  status = om$send( msg = message GRtext.GRgetrang( &msg,
						    &txt_mod.md_env.matrix_type,
						    txt_mod.md_env.matrix,
						    &wd_loc,
						    me->txt_range ),
		    targetid = me->located_obj[1].located_obj.objid,
		    targetos = me->located_obj[1].located_obj.osnum );

  /* compute the center of the text */
  txt_cnt[0] = ( me->txt_range[0] + me->txt_range[3] ) / 2.0;
  txt_cnt[1] = ( me->txt_range[1] + me->txt_range[4] ) / 2.0;
  txt_cnt[2] = ( me->txt_range[2] + me->txt_range[5] ) / 2.0;

  /* get range of the input surface */
  status = om$send( msg = message GRgraphics.GRgetrang( &msg,
						        &surf_mod.md_env.matrix_type,
						        surf_mod.md_env.matrix,
						        &wd_loc,
						        me->surf_range ),
		    targetid = me->located_obj[0].located_obj.objid,
		    targetos = me->located_obj[0].located_obj.osnum );

  /* compute the center of the surface */
  surf_cnt[0] = ( me->surf_range[0] + me->surf_range[3] ) / 2.0;
  surf_cnt[1] = ( me->surf_range[1] + me->surf_range[4] ) / 2.0;
  surf_cnt[2] = ( me->surf_range[2] + me->surf_range[5] ) / 2.0;

  /* we use a simple rule to judge the projection direction:
     if the dot product of the vector from the center of the text to
     the center of the surface and the projection vector is negative,
     then the projection will not meet the surface. */
  BSmkvec( &msg, cnt_vec, txt_cnt, surf_cnt );
  if ( BSdotp( &msg, cnt_vec, pj_vec ) <= 0 )
  { 
    ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_PjTxtWrgDir );
    me->ret = IN_AGAIN;
  }
}

/* -------------------------------------------------------------------- *
 * Show the surface normal of the located surface                       *
 * -------------------------------------------------------------------- */
action show_surf_normal( IGRint draw )
{
  IGRlong msg;

  status = om$send( msg = message EMSsurface.EMshow_normals( &msg,
							     &me->located_obj[0].module_info,
							     &me->ActiveDisplay,
							     ( draw ? GRhd : GRhe )),
		    targetid = me->located_obj[0].located_obj.objid,
		    targetos = me->located_obj[0].located_obj.osnum );
}

/* -------------------------------------------------------------------- *
 * Orient the surface normal properly according to input                *
 * -------------------------------------------------------------------- */
action orient_surf( IGRint button, char_p )
{
  IGRlong msg;
  IGRboolean flag = TRUE;

  if ( char_p )
  {
    if ( strcmp( me->event1.event.keyin, "n" ) == 0 )
      me->orient = FALSE;
    else if ( me->event1.event.keyin[0] != '\0' && strcmp( me->event1.event.keyin, "y"))
    {
      me->ret = IN_AGAIN;
      ex$message( field = ERROR_FIELD, msgnumb = IDFF_W_INVALIDOPT );
      flag = FALSE;
    }
    else
      me->orient = TRUE;
  }
  else
    me->orient = button;

  if ( flag == TRUE )
    status = om$send( msg = message EMSsurface.EMshow_normals( &msg,
							       &me->located_obj[0].module_info,
							       &me->ActiveDisplay,
							       GRhe ),
		      targetid = me->located_obj[0].located_obj.objid,
		      targetos = me->located_obj[0].located_obj.osnum );
}

/* -------------------------------------------------------------------- *
 * Save offset distance                                                 *
 * -------------------------------------------------------------------- */
action save_off_dis
{
  me->off_dis = me->event1.event.value;
  if ( me->off_dis )
    me->ret = GO_NEXT;
  else
  {
    /* do project text */
    status = om$send( msg = message IDpjtext.proj_text( &me->ret, FALSE ),
		      targetid = my_id );
  }
}

/* -------------------------------------------------------------------- *
 * The following code is based on IDplytext.sl which converts text      *
 * string(s) to polyline string(s)                                      *
 * -------------------------------------------------------------------- */
action proj_text( IGRlong *rc; IGRint auto_union_diff )
{
  struct GRmd_env act_mod, surf_mod, txt_mod;
  IGRshort act_os, surf_os, txt_os;
  GRobjid surf_id, txt_id;
  struct GRvg_construct cnst_list;
  OM_S_OBJID ggid;
  struct GRid gg_grid;
  IGRvector pj_vec;
  IGRmatrix trans;
  IGRpoint txt_p1, txt_p2, txt_cnt, surf_p1, surf_p2;
  struct IGRbsp_surface *plane;
  struct GRid pj_solid;
  IGRchar sts_buf[55];
  IGRlong msg, siz_buf, ret_bytes;

  me->ret = OM_S_SUCCESS;

  /* get the projection vector */
  pj_vec[0] = me->vect_pts[3] - me->vect_pts[0];
  pj_vec[1] = me->vect_pts[4] - me->vect_pts[1];
  pj_vec[2] = me->vect_pts[5] - me->vect_pts[2];
  BSnorvec( &msg, pj_vec );

  /* get active module info */
  siz_buf = sizeof( struct GRmd_env );
  gr$get_module_env( msg = &msg,
		     sizbuf = &siz_buf,
		     buffer = &act_mod,
		     nret = &ret_bytes );
  act_os = act_mod.md_id.osnum;

  /* verify whether either text or surface has been deleted */
  if ( om$is_objid_valid( objid = me->located_obj[1].located_obj.objid,
			  osnum = act_os ) != OM_S_SUCCESS )
  {
    ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_PjTxtInvTxt );
    *rc = FALSE;
    goto quit;
  }
  if ( om$is_objid_valid( objid = me->located_obj[0].located_obj.objid,
			  osnum = act_os ) != OM_S_SUCCESS )
  {
    ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_InvalidSurf );
    *rc = FALSE;
    goto quit;
  }

  /* style must be solid 0 */
  me->ActiveDisplay.style = 0;
			      
  /* initialize standard construction list */
  cnst_list.msg = &msg;
  cnst_list.newflag = 0;
  cnst_list.level = me->ActiveLevel;
  cnst_list.properties = GRIS_DISPLAYABLE | GRIS_LOCATABLE;
  cnst_list.display = &me->ActiveDisplay;
  cnst_list.name = NULL;
  cnst_list.class_attr = NULL;
  cnst_list.env_info = &act_mod;

  /* create a graphic group to put zero thickness or stick font projection */
  status = om$construct( osnum = act_os,
			 classname = "GRgrgrp",
			 p_objid = &ggid,
			 msg = message GRgraphics.GRconstruct( &cnst_list ));
  gg_grid.objid = ggid;
  gg_grid.osnum = act_os;

  /* initialize translation matrix */
  {
    IGRint i;

    for ( i = 0; i < 16; i++ )
      trans[i] = 0.0;
    trans[0] = trans[5] = trans[10] = trans[15] = 1.0;
  }

  /* get text string id & os */
  txt_mod = me->located_obj[1].module_info;
  txt_id = me->located_obj[1].located_obj.objid;
  txt_os = me->located_obj[1].located_obj.osnum;

  /* get surface id & os */
  surf_mod = me->located_obj[0].module_info;
  surf_id = me->located_obj[0].located_obj.objid;
  surf_os = me->located_obj[0].located_obj.osnum;

  /* get text cornor points */
  memcpy((char *)txt_p1, (char *)me->txt_range, 3 * sizeof( IGRdouble ));
  memcpy( (char *)txt_p2, (char *)(me->txt_range + 3), 3 * sizeof( IGRdouble ));

  /* txt_cnt = ( txt_p1 + txt_p2 ) / 2 */
  txt_cnt[0] = ( txt_p1[0] + txt_p2[0] ) / 2.0;
  txt_cnt[1] = ( txt_p1[1] + txt_p2[1] ) / 2.0;
  txt_cnt[2] = ( txt_p1[2] + txt_p2[2] ) / 2.0;

  /* get surface cornor points */
  memcpy( (char *)surf_p1, (char *)me->surf_range, 3 * sizeof( IGRdouble ));
  memcpy( (char *)surf_p2, (char *)(me->surf_range + 3), 3 * sizeof( IGRdouble ));

  /* if the offset thickness is not zero, then construct a rectangular
     plane enclosing the text string */
  if ( me->off_dis )
  {
    IGRchar *absg;
    struct IGRlbsys *lbs;
    IGRvector x_axis, y_axis;
    IGRpoint blk_pt1, blk_pt2, blk_pt11, blk_pt21;
    IGRvector vec1, vec2, vec3;
    IGRdouble par;
    IGRboolean nat_side;
    IGRshort num_bdry = 0;	/* shut off stupid compiler warning */

    /* get local coordinate system of the text */
    status = om$send( msg = message GRtext.GRgenabsg( &msg,
						      &txt_mod.md_env.matrix_type,
						      txt_mod.md_env.matrix,
						      &absg ),
		      targetid = txt_id,
		      targetos = txt_os );
    lbs = ( struct IGRlbsys * ) absg;

    x_axis[0] = lbs->matrix[0];
    x_axis[1] = lbs->matrix[4];
    x_axis[2] = lbs->matrix[8];
    y_axis[0] = lbs->matrix[1];
    y_axis[1] = lbs->matrix[5];
    y_axis[2] = lbs->matrix[9];

    /* determine block diagonals from range points to ensure
       that the block encloses the text string. txt_p1 and
       txt_p2 are from the text range. blk_pt1, blk_pt2 defines
       the enlarged the range. blk_pt11 and blk_pt21 are the
       other two corners of the rectangle */
    blk_pt1[0] = 1.5 * txt_p1[0] - 0.5 * txt_p2[0];
    blk_pt1[1] = 1.5 * txt_p1[1] - 0.5 * txt_p2[1];
    blk_pt1[2] = 1.5 * txt_p1[2] - 0.5 * txt_p2[2];
    blk_pt2[0] = 1.5 * txt_p2[0] - 0.5 * txt_p1[0];
    blk_pt2[1] = 1.5 * txt_p2[1] - 0.5 * txt_p1[1];
    blk_pt2[2] = 1.5 * txt_p2[2] - 0.5 * txt_p1[2];

    /* vec1 is the vector from blk_pt1 to blk_pt2 */
    BSmkvec( &msg, vec1, blk_pt1, blk_pt2 );

    /* vec2 = vec1 x y_axis; vec3 = x_axis x y_axis */
    BScrossp( &msg, vec1, y_axis, vec2 );
    BScrossp( &msg, x_axis, y_axis, vec3 );
  
    /* par = dot( vec2, vec3 ) / dot( vec3, vec3 ) */
    par = BSdotp( &msg, vec2, vec3 ) / BSlenvecsq( &msg, vec3 );

    blk_pt11[0] = blk_pt1[0] + par * x_axis[0];
    blk_pt11[1] = blk_pt1[1] + par * x_axis[1];
    blk_pt11[2] = blk_pt1[2] + par * x_axis[2];

    /* vec1 = blk_pt1 - blk_pt11; vec2 = blk_pt2 - blk_pt11 */
    BSmkvec( &msg, vec1, blk_pt11, blk_pt1 );
    BSmkvec( &msg, vec2, blk_pt11, blk_pt2 );

    /* vec3 = vec1 + vec2 */
    vec3[0] = vec1[0] + vec2[0];
    vec3[1] = vec1[1] + vec2[1];
    vec3[2] = vec1[2] + vec2[2];
    
    blk_pt21[0] = blk_pt11[0] + vec3[0];
    blk_pt21[1] = blk_pt11[1] + vec3[1];
    blk_pt21[2] = blk_pt11[2] + vec3[2];

    /* construct a rectangular plane */
    num_bdry = 0;
    BSallocsf( 2, 2, 2, 2, FALSE, num_bdry, &plane, &msg );
    plane->u_order = 2;
    plane->v_order = 2;
    plane->u_num_poles = 2;
    plane->v_num_poles = 2;
    BSsf3o4pts( blk_pt1, blk_pt11, blk_pt2, blk_pt21, plane, &msg );
    BSptonnsdsf( plane, txt_cnt, &nat_side, &msg );
    if ( nat_side )
      plane->pos_orient = 1;
    else
      plane->pos_orient = 0;
  }

  /* get text related information */
  {
    struct var_list var_list[5];
    IGRint win_no, gpipe_id, gragad_flags;
    struct DPfnt_os_tbl *fnt_os_ptr;
    struct IGRlbsys lbs;
    struct IGResintx txt_ele_info;
    struct IGRestx text_attr;
    IGRshort text_lng, nostrokes, malc_buf;
    IGRuchar *text_string;
    struct GRid fnt_mgr;
    struct vfont_entry fnt_info;
    IGRdouble strk_buf[NUM_STRK_DBLS], *ptr_strk_buf, *start_pt;
    IGRint num_points, malloc_size, num_pts, tot_num_pts, count, num_bdrys = 0;
    IGRlong which_error;
    IGRboolean ststf, intersect = FALSE;
    IGRdouble cht_tol, par_tol;

    BSxtractpar( &msg, BSTOLCHRDHT, &cht_tol );
    BSxtractpar( &msg, BSTOLPARAM, &par_tol );

    var_list[0].var = WIN_NO;
    var_list[0].var_ptr = ( IGRchar * ) &win_no;
    var_list[0].num_bytes = sizeof( IGRint );
    var_list[0].bytes_returned = &ret_bytes;
    
    var_list[1].var = GPIPE_ID;
    var_list[1].var_ptr = ( IGRchar * ) &gpipe_id;
    var_list[1].num_bytes = sizeof( IGRint );
    var_list[1].bytes_returned = &ret_bytes;
    
    var_list[2].var = FONT_OS_PTR;
    var_list[2].var_ptr = ( IGRchar * ) &fnt_os_ptr;
    var_list[2].num_bytes = 4;
    var_list[2].bytes_returned = &ret_bytes;

    var_list[3].var = GRAGAD_FLAGS;
    var_list[3].var_ptr = ( IGRchar * ) &gragad_flags;
    var_list[3].num_bytes = sizeof( IGRint );
    var_list[3].bytes_returned = &ret_bytes;

    var_list[4].var = END_PARAM;

    status = dp$inq_set_gragad( msg = &msg,
			        osnum = me->gd_os,
			        gragad_objid = me->gd_id,
			        which_error = &which_error,
			        var_list = var_list );
    if ( !( status & 1 & msg ))
    {
      status = OM_E_ABORT;
      om$report_error( sts = status );
      *rc = FALSE;
      goto quit;
    }

    status = om$send( msg = message GRtext.GRgetgeom( &msg, 
						      &txt_mod.md_env.matrix_type,
						      txt_mod.md_env.matrix,
						      (IGRchar *) &lbs ),
		      targetid = txt_id,
		      targetos = txt_os );
    status = om$send( msg = message GRtext.GRgettxattr( &msg, 
						        &text_attr,
						        &text_lng,
						        &text_string ),
		      targetid = txt_id,
		      targetos = txt_os );

    txt_ele_info.font_id = txt_os;
    txt_ele_info.flags = 0;
    txt_ele_info.prev_font = text_attr.font;
    txt_ele_info.estx = &text_attr;
    txt_ele_info.text_string = ( IGRchar * ) text_string;

    ptr_strk_buf = strk_buf;
    nostrokes = TRUE;
    num_points = NUM_STRK_PTS;
    malc_buf = FALSE;

    /* get text stroke points */
    while ( nostrokes )
    {
      ststf = DPtxstrk( &msg, &lbs, &txt_ele_info, &me->ActiveDisplay,
		        win_no, gpipe_id, fnt_os_ptr, gragad_flags,
		        0, 1.0, 0, ptr_strk_buf, &num_points);
      if ( ststf == FALSE )
      {
	num_points = num_points + INC_STRK_PTS;
	if ( malc_buf )
	  om$dealloc( ptr = ptr_strk_buf );
	malc_buf = TRUE;
	malloc_size = sizeof( IGRdouble ) * num_points * 3.0;
	ptr_strk_buf = ( IGRdouble * ) om$malloc( size = malloc_size );
	if ( ptr_strk_buf == NULL )
	{
	  ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_SYSERR1 );
	  *rc = FALSE;
	  if ( malc_buf )
	    om$dealloc( ptr = ptr_strk_buf );
	  goto quit;
	}
      }
      else
	nostrokes = FALSE;
    } /* close for while */
    om$dealloc( ptr = text_string );

    /* determine the text font is a fillable font or stroke font
       o if the font is a stroke font and the offset thickness is
         nonzero, the offset thickness is automatically converted
	 to zero thickness since lifting stroked projection does
	 not make sense */

    /* first, get font manager */
    ex$get_super( mod_id = act_mod.md_id.objid,
		  mod_osnum = act_os,
		  super_name = FONTMGR_NO_NAME,
		  create = TRUE,
		  super_class = "GRfm",
		  super_id = &fnt_mgr.objid,
		  super_osnum = &fnt_mgr.osnum );

    /* get font specific fillable information */
    status = om$send( msg = message GRfm.GRfm_retdata( &msg,
						       &text_attr.font,
						       &fnt_info ),
		      targetid = fnt_mgr.objid,
		      targetos = fnt_mgr.osnum );

    /* if it is a nonfillable font, set off_dis to zero */
    if ( !( fnt_info.flags & FILLABLE_FONT ))
      me->off_dis = 0.0;

    tot_num_pts = 0;
    if ( me->off_dis )
    {
      plane->num_boundaries = 0;
      plane->bdrys = ( struct IGRbsp_bdry_pts * ) om$malloc( size = NUM_OBJ_A * sizeof( struct IGRbsp_bdry_pts ));
      if ( plane->bdrys == NULL )
      {
	ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_SYSERR1 );
	*rc = FALSE;
	goto quit;
      }
      num_bdrys = NUM_OBJ_A;
    }

    /* print Processing . . . */
    ex$message( msgnumb = IDFF_M_ProcSts,
	        buff = sts_buf );
    strcat( sts_buf, ". . ." );
    ex$message( field = ERROR_FIELD, in_buff = sts_buf );

    while( tot_num_pts < num_points )
    {
      start_pt = ptr_strk_buf;
      count = 0;
      while ( !( fabs( fabs( *ptr_strk_buf/MAXDOUBLE ) - 1 ) < 1e-6 ))
      {
	ptr_strk_buf = ptr_strk_buf + 3;
	count = count + 3;
      }
      num_pts = count / 3;
      tot_num_pts = tot_num_pts + num_pts + 1;

      /* if the offset thickness is nonzero, then construct surface and
	 proceed with projecting the surface into solid;
	 else just project the line string into surface */
      if ( me->off_dis )
      { /* offset thickness is nonzero */
	IGRdouble *uv_pts;
	struct IGRbsp_bdry_pts *txt_ln_bdry;
	IGRboolean in_rang, on_sf;

	siz_buf = sizeof( IGRdouble ) * 2 * num_pts;
	uv_pts = ( IGRdouble * ) om$malloc( size = siz_buf );
	if ( uv_pts == NULL )
	{
	  ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_SYSERR1 );
	  *rc = FALSE;
	  goto quit;
	}

	/* map the xyz polyline string to uv polyline string */
	EFmap_xyz_to_uv_for_planes( &msg, plane, cht_tol, par_tol,
				    num_pts, start_pt, &in_rang, &on_sf,
				    TRUE, uv_pts );
	txt_ln_bdry = ( struct IGRbsp_bdry_pts * ) om$malloc( size = sizeof( struct IGRbsp_bdry_pts ));
	if ( txt_ln_bdry == NULL )
	{
	  ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_SYSERR1 );
	  *rc = FALSE;
	  goto quit;
	}

	txt_ln_bdry->num_points = num_pts;
	txt_ln_bdry->points = uv_pts;
	
	if ( plane->num_boundaries >= num_bdrys )
	{
	  while ( num_bdrys <= plane->num_boundaries )
	    num_bdrys += NUM_OBJ_A;
	  plane->bdrys = ( struct IGRbsp_bdry_pts * ) om$realloc( ptr = (IGRchar *) plane->bdrys,
								  size = num_bdrys * sizeof( struct IGRbsp_bdry_pts ));
	  if ( plane->bdrys == NULL )
	  {
	    ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_SYSERR1 );
	    *rc = FALSE;
	    goto quit;
	  }
	}
	plane->bdrys[(plane->num_boundaries)++] = *txt_ln_bdry;
      }
      else
      { /* offset thickness is zero, do projection of linestrings */
	struct IGRpolyline ply_ln;
	struct GRid ply_txt, dp_id;
	struct GRlc_info ply_txt_obj;
	IGRlong num_pj_ln;
	GRobjid *pj_lns;
	IGRint i;

	ply_ln.num_points = num_pts;
	ply_ln.points = start_pt;

	cnst_list.geometry = ( IGRchar * ) &ply_ln;

	status = om$construct( classname = "GR3dlinestr",
			       osnum = act_os,
			       p_objid = &ply_txt.objid,
			       msg = message GRgraphics.GRaltconstruct( &cnst_list ));
	ply_txt.osnum = act_os;
	
	ply_txt_obj.located_obj = ply_txt;
	memcpy( (char *)&ply_txt_obj.module_info, (char *)&act_mod, sizeof( struct GRmd_env ));

	/* note that the following two parameters have to be
	   initialized before passing to EMproject_curve_onto_surface */
	num_pj_ln = 0;
	pj_lns = NULL;

	/* project linestrings and get resulting linestrings on the surface */
	status = om$send( msg = message EMSsubbs.EMproject_curve_onto_surface(
					&ply_txt_obj,
					&me->located_obj[0],
					&cnst_list,
					pj_vec,
					FALSE,
					TRUE,
					&num_pj_ln,
					&pj_lns,
					&msg ),
			  targetid = surf_id,
			  targetos = surf_os );
	if ( !( status & 1 & msg ))
	{
	  ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_PjTxtPjLn );
	  *rc = FALSE;
	  goto quit;
	}

	if ( !intersect && num_pj_ln > 0 )
	  intersect = TRUE;

	/* display the projection */
	for ( i = 0; i < num_pj_ln; i++ )
	{
	  dp_id.objid = pj_lns[i];
	  dp_id.osnum = act_os;

	  /* put object into the graphic group */
	  GRconnect_object( &msg, act_os, dp_id.objid, &gg_grid, GR_FLEXIBLE,
			    GR_OVERRIDE, OM_K_MAXINT, OM_K_MAXINT );

	  /* display the object */
	  gr$display_object( object_id = &dp_id,
			     mode = GRbd );
	}

	/* delete the polyline string created when converting text string */
	status = om$send( msg = message GRgraphics.GRdelete( &msg,
							     &act_mod ),
			  targetid = ply_txt.objid,
			  targetos = act_os );
      }
      ptr_strk_buf = ptr_strk_buf + 3;
    } /* close for while constructing projection from text string */

    if ( malc_buf )
      om$dealloc( ptr = ptr_strk_buf );

    /* if there is no projection, then echo a message */
    if ( !( me->off_dis ) && ( intersect == FALSE ))
      ex$message( field = ERROR_FIELD, msgnumb = IDFF_M_PjTxtEmpty );
      
  }

  /* zero thickness offset has been taken care of. Now we construct
     surface consisting of text exclusively for nonzero offset thickness */
  if ( me->off_dis )
  {
    struct GRid txt_plane, cp_txt_plane, cp_surf1, cp_surf2;
    IGRvector trans_vec;
    IGRdouble trans_dis;
    IGRshort m_type;
    GRobjid trans_id, bool_id1, bool_id2;
    struct GRlc_info pj_surf;
    IGRpoint proj_pt1, proj_pt2;
    IGRushort opts;

    /* create boundary surface consisting of the text */
    cnst_list.geometry = ( IGRchar * ) plane;
    status = om$construct( classname = "EMSsubbs",
			   osnum = act_os,
			   p_objid = &txt_plane.objid,
			   msg = message GRgraphics.GRconstruct( &cnst_list ));
    if ( status != OM_S_SUCCESS )
    {
      ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_ImpBdry );
      *rc = FALSE;
      goto quit;
    }
    txt_plane.osnum = act_os;

    /* print Processing . . . . . .*/
    ex$message( msgnumb = IDFF_M_ProcSts,
	        buff = sts_buf );
    strcat( sts_buf, ". . . . . ." );
    ex$message( field = ERROR_FIELD, in_buff = sts_buf );

    /* make a copy of the original text surface */
    status = om$send( msg = message GRgraphics.GRcopy( &msg,
						       &act_mod,
						       &act_mod,
						       &cp_txt_plane.objid ),
		      targetid = txt_plane.objid,
		      targetos = txt_plane.osnum );
    cp_txt_plane.osnum = act_os;

    /* translate the copy of the text plane to make sure the following
       conditions are met:
       o the projection solid will always intersect surface
       o the plane is away from the surface far enough such that the
         thickness of the text is guaranteed ( this is used to deal
	 with cases that the text is in the interior of either closed
	 surface like cylinder or other types of surfaces )
       since we know the range of the surface, we used the distance
       between those two points as the base distance to translate */
    BSmkvec( &msg, trans_vec, surf_p1, surf_p2 );
    trans_dis = BSlenvec( &msg, trans_vec );

    /* add the thickness to the trans_dis */
    trans_dis += fabs( me->off_dis );

    /* set up translation matrix according to trans_dis */
    trans[3] = -trans_dis * pj_vec[0];
    trans[7] = -trans_dis * pj_vec[1];
    trans[11] = -trans_dis * pj_vec[2];
    MAtypemx( &msg, trans, &m_type );

    /* translate the appropriate copy to the right place */
    status = om$send( msg = message GRgraphics.GRxform( &msg,
						        &act_mod,
						        &m_type,
						        trans,
						        &trans_id ),
		      targetid = cp_txt_plane.objid,
		      targetos = act_os );

    /* initialize surface of projection */
    pj_surf.located_obj = cp_txt_plane;
    pj_surf.module_info = act_mod;

    /* assign starting and ending projection points */
    proj_pt1[0] = me->vect_pts[0];
    proj_pt1[1] = me->vect_pts[1];
    proj_pt1[2] = me->vect_pts[2];
    proj_pt2[0] = proj_pt1[0] + 2 * trans_dis * pj_vec[0];
    proj_pt2[1] = proj_pt1[1] + 2 * trans_dis * pj_vec[1];
    proj_pt2[2] = proj_pt1[2] + 2 * trans_dis * pj_vec[2];

    /* projecting the text to make a solid */
    status = EMsweep_surface_via_lift_face_mod( &pj_surf,
					        proj_pt1,
					        proj_pt2,
					        &cnst_list,
					        my_id,
					        &pj_solid.objid,
					        FALSE,
					        &msg );
    if ( msg == MSFAIL )
    {
      ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_PjTxtPjSf );
      *rc = FALSE;
      /* delete the copy of the text surface */
      status = om$send( msg = message GRgraphics.GRdelete( &msg,
							   &act_mod ),
		        targetid = cp_txt_plane.objid,
		        targetos = act_os );
      goto quit;
    }
    pj_solid.osnum = act_os;

    /* delete the copy of the text surface */
    status = om$send( msg = message GRgraphics.GRdelete( &msg,
							 &act_mod ),
		      targetid = cp_txt_plane.objid,
		      targetos = act_os );

    /* make a copy of the original surface */
    status = om$send( msg = message GRgraphics.GRcopy( &msg,
						       &surf_mod,
						       &act_mod,
						       &cp_surf1.objid ),
		      targetid = surf_id,
		      targetos = surf_os );
    cp_surf1.osnum = act_os;

    /* if we do not want to modify surface then make another copy of
       the original surface */
    if ( auto_union_diff == FALSE )
    {
      status = om$send( msg = message GRgraphics.GRcopy( &msg,
							 &surf_mod,
							 &act_mod,
							 &cp_surf2.objid ),
		        targetid = surf_id,
		        targetos = surf_os );
      cp_surf2.osnum = act_os;
    }

    /* reverse surface orientation if it is needed */
    if ( me->orient == FALSE )
    {
      status = om$send( msg = message EMSsurface.EMrevorient( &msg ),
		        targetid = cp_surf1.objid,
		        targetos = act_os );
      if ( auto_union_diff == FALSE )
	status = om$send( msg = message EMSsurface.EMrevorient( &msg ),
			  targetid = cp_surf2.objid,
			  targetos = act_os );
      else
	status = om$send( msg = message EMSsurface.EMrevorient( &msg ),
			  targetid = surf_id,
			  targetos = act_os );
    }

    /***********************************************************/
    /* the following is added so that copied surfaces have the */
    /* active color which will be used later in Boolean ops    */
    /* -------------- JSY; 03/07/92 -------------------------- */

    {
      struct GRsymbology surf_symb;

      /* get symbology of copied surface */
      status = om$send( msg = message GRvg.GRgetsymb( &msg, &surf_symb ),
		        targetid = cp_surf1.objid,
		        targetos = act_os );

      /* change the color to active color */
      surf_symb.display_attr.color = me->ActiveDisplay.color;

      /* put symbology back to copied surface */
      status = om$send( msg = message GRvg.GRputsymb( &msg, &surf_symb ),
		        targetid = cp_surf1.objid,
		        targetos = act_os );

      if ( auto_union_diff == FALSE )
      {
	/* get symbology of copied surface */
	status = om$send( msg = message GRvg.GRgetsymb( &msg, &surf_symb ),
			  targetid = cp_surf2.objid,
			  targetos = act_os );

	/* change the color to active color */
	surf_symb.display_attr.color = me->ActiveDisplay.color;

	/* put symbology back to copied surface */
	status = om$send( msg = message GRvg.GRputsymb( &msg, &surf_symb ),
			  targetid = cp_surf2.objid,
			  targetos = act_os );
      }
    }
    
    /* set up translation matrix according to input thickness */
    trans[3] = -me->off_dis * pj_vec[0];
    trans[7] = -me->off_dis * pj_vec[1];
    trans[11] = -me->off_dis * pj_vec[2];
    MAtypemx( &msg, trans, &m_type );

    /* translate the appropriate copy to the right place */
    if ( auto_union_diff == FALSE )
      status = om$send( msg = message GRgraphics.GRxform( &msg,
							  &act_mod,
							  &m_type,
							  trans,
							  &trans_id ),
		        targetid = ( me->off_dis > 0 ? cp_surf1.objid
				                     : cp_surf2.objid ),
		        targetos = act_os );
    else
      status = om$send( msg = message GRgraphics.GRxform( &msg,
							  &act_mod,
							  &m_type,
							  trans,
							  &trans_id ),
		        targetid = cp_surf1.objid,
		        targetos = act_os );

    /* do two boolean operations to get projected text */
    opts = EMSsfbool_opt_display;

    status = om$construct( classname = "EMSsfboolean",
			   p_objid = &bool_id1,
			   osnum = act_os );
    status = om$construct( classname = "EMSsfboolean",
			   p_objid = &bool_id2,
			   osnum = act_os );

    /* print Processing . . . . . . . . .*/
    ex$message( msgnumb = IDFF_M_ProcSts,
	        buff = sts_buf );
    strcat( sts_buf, ". . . . . . . . ." );
    ex$message( field = ERROR_FIELD, in_buff = sts_buf );

    if ( auto_union_diff == FALSE ||
	 ( auto_union_diff == TRUE && me->off_dis > 0 ))
    {
      status = om$send( msg = message EMSsfboolean.EMboolean( &msg,
							      &act_mod.md_env.matrix_type,
							      act_mod.md_env.matrix,
							      pj_solid.objid,
							      1,
							      &cp_surf1.objid,
							      &cnst_list,
							      EMSbool_intersect,
							      opts,
							      NULL,
							      NULL,
							      NULL,
							      NULL,
							      NULL ),
		        targetid = bool_id1,
		        targetos = act_os );
      if ( !( status & 1 & msg ))
      {
	ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_BoolOpErr );
	*rc = FALSE;

	/* clean up */
	status = om$send( msg = message GRgraphics.GRdelete( &msg,
							     &act_mod ),
			  targetid = pj_solid.objid,
			  targetos = act_os );
	status = om$send( msg = message GRgraphics.GRdelete( &msg,
							     &act_mod ),
			  targetid = cp_surf1.objid,
			  targetos = act_os );
	if ( auto_union_diff == FALSE )
	  status = om$send( msg = message GRgraphics.GRdelete( &msg,
							       &act_mod ),
			    targetid = cp_surf2.objid,
			    targetos = act_os );
	status = dp$update( msg = &msg );
	goto quit;
      }

      /* print Processing . . . . . . . . . . . .*/
      ex$message( msgnumb = IDFF_M_ProcSts,
		  buff = sts_buf );
      strcat( sts_buf, ". . . . . . . . . . . ." );
      ex$message( field = ERROR_FIELD, in_buff = sts_buf );

      if ( auto_union_diff == TRUE )
      {
	status = om$send( msg = message EMSsfboolean.EMboolean( &msg,
							        &act_mod.md_env.matrix_type,
							        act_mod.md_env.matrix,
							        bool_id1,
							        1,
							        &surf_id,
							        &cnst_list,
							        EMSbool_union,
							        opts,
							        NULL,
							        NULL,
							        NULL,
							        NULL,
							        NULL ),
			  targetid = bool_id2,
			  targetos = act_os );
      }
      else
      {
	status = om$send( msg = message EMSsfboolean.EMboolean( &msg,
							        &act_mod.md_env.matrix_type,
							        act_mod.md_env.matrix,
							        bool_id1,
							        1,
							        &cp_surf2.objid,
							        &cnst_list,
							        EMSbool_difference,
							        opts,
							        NULL,
							        NULL,
							        NULL,
							        NULL,
							        NULL ),
			  targetid = bool_id2,
			  targetos = act_os );
      }
      if ( !( status & 1 & msg ))
      {
	ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_BoolOpErr );
	*rc = FALSE;
	goto quit;
      }
    }
    else
    {
      status = om$send( msg = message EMSsfboolean.EMboolean( &msg,
							      &act_mod.md_env.matrix_type,
							      act_mod.md_env.matrix,
							      pj_solid.objid,
							      1,
							      &cp_surf1.objid,
							      &cnst_list,
							      EMSbool_difference,
							      opts,
							      NULL,
							      NULL,
							      NULL,
							      NULL,
							      NULL ),
		        targetid = bool_id1,
		        targetos = act_os );
      if ( !( status & 1 & msg ))
      {
	ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_BoolOpErr );
	*rc = FALSE;

	/* clean up */
	status = om$send( msg = message GRgraphics.GRdelete( &msg,
							     &act_mod ),
			  targetid = pj_solid.objid,
			  targetos = act_os );
	status = om$send( msg = message GRgraphics.GRdelete( &msg,
							     &act_mod ),
			  targetid = cp_surf1.objid,
			  targetos = act_os );
	status = dp$update( msg = &msg );
	goto quit;
      }

      /* print Processing . . . . . . . . . . . .*/
      ex$message( msgnumb = IDFF_M_ProcSts,
		  buff = sts_buf );
      strcat( sts_buf, ". . . . . . . . . . . ." );
      ex$message( field = ERROR_FIELD, in_buff = sts_buf );

      status = om$send( msg = message EMSsfboolean.EMboolean( &msg,
							      &act_mod.md_env.matrix_type,
							      act_mod.md_env.matrix,
							      surf_id,
							      1,
							      &bool_id1,
							      &cnst_list,
							      EMSbool_difference,
							      opts,
							      NULL,
							      NULL,
							      NULL,
							      NULL,
							      NULL ),
		        targetid = bool_id2,
		        targetos = act_os );
      if ( !( status & 1 & msg ))
      {
	ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_BoolOpErr );
	*rc = FALSE;
	goto quit;
      }
    }

    /* finally compress the state tree of boolean operation */
    /* comment out the compress state tree code to accommodate
       request from Jed. This fixes TR#92M0497 */
    /*
    status = om$send( msg = message EMSdpr.EMmake_primitive1( &msg,
							      &act_mod,
							      &cmpr_obj ),
		      targetid = bool_id2,
		      targetos = act_os );
    if ( msg != EMS_S_Success )
    {
      ex$message( field = ERROR_FIELD, msgnumb = IDFF_E_CmprBoolObj );
      *rc = FALSE;
      goto quit;
    }
    */
    
    /* update display */
    status = dp$update( msg = &msg );

    /* free allocated dynamic memory */
    BSfreesf( &msg, plane );
  }
  UI_status( " " );

} /* close action proj_text */

