


	/*
	 *
	 *  This set of macros defines the user interface to the 
	 *  window subsystem.  This include file is dependent on 
	 *  the following include files:
	 *
	 *	igewindef..h
	 *	igewindow.h
	 * 
	 */

	 
#ifndef igewinmacros_include
#define igewinmacros_include
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igewindef.h"
#include "igewindow.h"
/*----------------------------------------------------------------------------*/
#if defined(__STDC__) || defined(__cplusplus)
#ifndef __
#define __(args) args
#endif
#else
#ifndef __
#define __(args) ()
#endif
#endif

#if defined(__cplusplus)
extern "C" {
#endif

extern int DPsetinqwindow __((IGRlong *msg, IGRchar inq0_set1,
		IGRlong *which_error, struct win_var_list *var_list,
		GRspacenum osnum, GRobjid window_objid));
extern void IGEget_num_screens __((IGRint type, IGRint *num_screens));
extern void IGEget_num_screens __((IGRint type, IGRint *num_screens));
extern void IGEinq_term_info __((IGRint screen_no, IGRint *bg_planes,
		IGRint *hilite_plane, IGRint *vs_no, IGRint *num_of_planes,
		IGRint *plane_mask, IGRint *vlt_size, IGRint *dac_size,
		IGRint *x_extent, IGRint *y_extent, IGRint *fixed_vlt_start,
		IGRint *fixed_vlt_size, IGRint *db_enabled,
		IGRint *zb_enabled, IGRint *sr_vlt_enabled));
extern IGRint IGEsractive __((void));
extern int IGEwin_const __((GRobjid *win_objid, IGRlong *msg, 
		IGRchar *win_class, GRobjid mod_id, GRspacenum mod_osnum,
		IGRchar *name, int win_type, int screen, IGRboolean dep_indep,
		IGRdouble min_x, IGRdouble min_y, IGRdouble max_x,
		IGRdouble max_y, IGRint win_level, IGRshort right_space,
		IGRshort left_space, IGRshort top_space, IGRshort bottom_space,
		IGRboolean draw_border, IGRint icon_flags,
		IGRchar *symbol_name, IGRint symbol_number, IGRint collapse,
		IGRdouble *collapse_pos, IGRlong *cursor_enable_pattern,
		IGRlong *cursor_data_pattern, IGRlong *cursor_hot_spot));

#if defined(__cplusplus)
}
#endif

/*----------------------------------------------------------------------------*/

#omdef  ige$construct_win
                (  msg,
                   win_class = "IGEwindow",
		   win_objid,
		   mod_id = NULL_OBJID,
		   mod_osnum = OM_Gw_current_OS,
		   name = NULL,
		   symbol_name= NULL,
		   symbol_number = -1,
		   win_type = BORDER,
		   screen = RIGHT_SCREEN,
		   dep_indep = IGE_INDEPENDENT,
		   min_x,
		   min_y,
		   max_x,
		   max_y,
		   win_level = IGE_NORMAL,
		   right_space = 0,
		   left_space = 0,
		   top_space = 0,
		   bottom_space = 0,
		   draw_border = TRUE,
		   collapse = FALSE,
		   collapse_pos = NULL,
		   cursor_enable_pattern = NULL,
		   cursor_data_pattern = NULL,
		   cursor_hot_spot = NULL,
		   icon_flags = (IGE_WIN_DELETE_ICON 	|
				IGE_WIN_TOP_ICON	|
				IGE_WIN_BOTTOM_ICON	|
				IGE_WIN_COLLAPSE_ICON	|
				IGE_WIN_MODIFY_ICON)  )


#if !om$specified(symbol_name) && om$specified(symbol_number)

#omerror "If symbol_number is specified then symbol_name must be specified"

#else

#if om$specified(symbol_name) && !om$specified(symbol_number)

#omerror "If symbol_name is specified then symbol_number must be specified"

#else

IGEwin_const(win_objid,msg,win_class,mod_id,mod_osnum,name,win_type,screen,dep_indep,
	     min_x,min_y,max_x,max_y,win_level,right_space,left_space,
	     top_space,bottom_space,draw_border,icon_flags,symbol_name,
	     symbol_number,collapse,collapse_pos,cursor_enable_pattern,
	     cursor_data_pattern,cursor_hot_spot)

#endif
#endif

#endomdef


#omdef  ige$inq_term_info (	screen_no = IGE_RIGHT_SCREEN,
				background_planes = NULL,
				hilite_plane = NULL,
				vs_no = NULL,
				num_of_planes = NULL,
				plane_mask = NULL,
				vlt_size = NULL,
				dac_size = NULL,
				x_extent = NULL,
				y_extent = NULL,
				fixed_vlt_start = NULL,
				fixed_vlt_size = NULL,
				db_enabled = NULL,
				zb_enabled = NULL,
				sr_vlt_enabled = NULL)

	IGEinq_term_info(screen_no,background_planes,hilite_plane,vs_no,
			 num_of_planes,plane_mask,vlt_size,dac_size,x_extent,
			 y_extent,fixed_vlt_start,fixed_vlt_size,db_enabled,
			 zb_enabled,sr_vlt_enabled)

#endomdef
					
#omdef  ige$get_num_screens(	num_of_screens )

	IGEget_num_screens(0,num_of_screens)

#endomdef

#omdef  ige$get_num_phy_screens(num_phy_screens )

	IGEget_num_screens(1,num_phy_screens)

#endomdef


#omdef ige$inq_set_window ( msg,
			   inq0_set1=0,
			   osnum = -1,
			   window_objid,
			   which_error,
			   var_list)


   DPsetinqwindow ( msg, inq0_set1, which_error, var_list,osnum, window_objid)

#endomdef

#omdef ige$SR_active()

   IGEsractive()
   
#endomdef

#endif
