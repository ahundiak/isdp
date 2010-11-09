/*
$Author: hans $
$Revision: 1.1.1.1 $
$Date: 2001/12/17 22:39:32 $
$Locker:  $
$Log: anutils.I,v $
Revision 1.1.1.1  2001/12/17 22:39:32  hans
Initial import to CVS

# Revision 340.0  1997/05/27  23:09:35  root
# COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
#
# Revision 330.0  1996/01/11  21:23:40  root
# COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
#
# Revision 320.0  1994/12/12  17:53:06  root
# COMMENT : Initial checkin to 3.2 RCS from 3.1 src
#
# Revision 240.4  1994/11/01  10:12:35  gvk
# COMMENT : Included prototypes for BSfunctions and GRNUC calls which return double.
#
# Revision 240.3  1993/08/03  13:25:03  samuel
# COMMENT : Fix for TR# 119300474 -samuel
#
# Revision 240.2  1992/12/23  15:55:56  gvk
# COMMENT : Fixed compilation Error
#
# Revision 220.2  1992/12/18  22:07:13  gvk
# COMMENT : Message Sub System Changes
#
# Revision 220.1  1992/10/16  19:24:47  poo
# COMMENT : Checking in 2.1 Fixes to 2.2 RCS
#
# Revision 201.2  1992/10/05  18:28:57  poo
# COMMENT : Fix for Jogged Radial dimension highlighting & Locking.
#
# Revision 201.1  1992/08/26  13:17:19  poo
# COMMENT : Fixes for Cross-line hilite and modify dim.
#
Revision 201.13  1992/05/26  05:21:26  dimdp20
COMMENT : Deleting pre 140 dimension conversion code from 2.1 version.

Revision 201.12  1992/03/09  16:56:40  allen
COMMENT : Use new font for weld symbols.

Revision 201.10  1992/02/19  11:56:58  dimdp20
COMMENT : Dimension Fixes Release - S. Poovannan - Feb. 19 1992

Revision 201.9  1992/02/03  13:00:05  dimdp20
COMMENT : Dimensioning Fixes Release - S. Poovannan - Feb 3 1992

Revision 201.8  1992/01/31  18:17:37  dimdp20
COMMENT : DIMENSION FIXES RELEASE - 31-1-92

*/

class implementation DMannot;

#include "dpdef.h"
#include "fontdef.h"
#include "font.h"
#include "fontmacros.h"
#include "exmacros.h"
#include "OMmacros.h"
#include "dpmacros.h"
#include "gotextdef.h"
#include "gotext.h"
#include "dimfont.h"
#include "dimweld.h"
#include "fielddef.h"
#include "msdef.h"
#include "msmacros.h"

#include "DMcmd.h"
#include "DMmsg.h"
#include "maptsxfor.h"
#include "bsnorvec.h"
#include "bslenvec.h"
#include "bsdistptpts.h"
#include "bscrossp.h"

extern int Mmessage();
extern IGRboolean BSproj0();

#define AS_DEBUG 1

from GRfm import GRfm_retdata;
from GRtext import GRreplace_text, GRgettxattr;
from DMsrc import DMmodify, DMgive_structure;
from DMtxbln import give_bln_center;

/*------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
     This routine accepts a query for information about a specified
field. A query can be made on any or all of the field's data 
(contents, range, attributes, extents, or justification points). If
information is not required about a particular type of data a NULL
pointer must be passed in. If the specified field is not found, 
MSFAIL will be returned.
----*/

#argsused
IGRint GRfield_inquire (msg,
                        text_string,
                        attr,
			display_attr,
			lbsys,
			field_num,
			type,
			matrix,
			length,
			contents,
			attributes,
			extents,
			range,
			just_pts)
	 IGRlong  *msg;
	 IGRuchar  *text_string;
	 struct IGRestx  *attr;
	 struct IGRdisplay  *display_attr;
	 struct IGRlbsys  *lbsys;
	 IGRuchar  *field_num;
	 IGRshort  *type;
	 IGRmatrix  matrix;
	 IGRshort  *length;
	 IGRuchar  **contents;
	 IGRuchar  *attributes;
	 struct extents  *extents;
	 GRrange  range;
	 struct just_pts  *just_pts;
{
   extern IGRshort GRfwd_beg_esc_seq();

   IGRshort            beg_esc;        /* index of escape char in text
                                          string that begins specified
                                          escape sequence                */
   IGRshort            start_index;    /* position to start searching
                                          string for field               */
   IGRshort            prev_font;      /* "previous" font in string      */
   IGRshort            current_font;   /* current font in the string     */
   IGRshort            field_length;   /* length of field                */
   IGRshort            num_chars;      /* num esc codes to search for    */
   IGRshort            i;              /* index counter                  */
   IGRlong             num_pts;        /* number of points               */
   IGRuchar    *esc_nums[1];   /* array for numbers after esc
                                          sequences--NULL if numbers
                                          not needed                     */
   IGRchar             esc_chars[1];   /* character to be searched for
                                          following the escape char      */
   IGRdouble           pt[6];          /* points from underline used
                                          to get origin in world coord   */
   struct vfont_entry  font_info;      /* font information at the        */
                                       /* beginning of the text string   */
   struct vfont_entry  cur_font_info;  /* current font information       */
   struct extents      field_extents;  /* extents of field               */
   IGRmatrix           field_matrix;   /* view matrix of field           */
   struct IGRlbsys     lbs;            /* lbs of text string             */
   struct IGResintx    text_info;      /* text attrs for underline       */
   struct just_pts     just_points;    /* justification points           */
   IGRdouble           extent_pts[6];  /* extent pts of field for range  */
   struct GRid         fontmgr_obj;    /* font manager object            */
   GRspacenum          cur_mod_osnum;  /* current module's osnum         */
   OM_S_OBJID          cur_mod_id;     /* current module's objid         */
   struct GRcc_info    cc_info;        /* current character information  */
   IGRboolean          cc_info_flg;    /* true if already have cc_info   */
   IGRdouble           just_move;      /* justification move to fld char */

   *msg = MSSUCC;

   /*
    *  get the index of the specified set field escape sequence
    */

   start_index = 0;        /* start at beginning of string */
   esc_chars[0] = 'F';     /* search for field esc sequence */
   num_chars = 1;
   esc_nums[0] = field_num;

   current_font = attr->font;
   prev_font = current_font;

   font$get_info(msg = msg,
                 font_num = &current_font,
                 font_info = &font_info);

   cur_font_info = font_info;

   if (GRfwd_beg_esc_seq(msg,text_string,&attr->text_length,
                         &num_chars,esc_chars,esc_nums,&start_index,
                         &prev_font,&current_font,&cur_font_info,&beg_esc))
   {
      /*
       * get the length of the field
       */

      GRget_field_len(msg,text_string,&attr->text_length,&beg_esc,
                      prev_font,current_font,cur_font_info.flags,&field_length);

      if (length)
      {
         *length = field_length + 2;    /* include end field esc seq */
      }

      if (*contents)
      {
         OM_BLOCK_MOVE(&(text_string[beg_esc]),*contents,field_length + 2);
      }

      if (attributes)
      {
         *attributes = text_string[beg_esc + 3];
      }

      if ((extents) || (range) || (just_pts))
      {
         /*
          *  find the current module's object space number
          */

         ex$get_cur_mod(osnum = &cur_mod_osnum);

         ex$get_modid(mod_osnum = cur_mod_osnum,
                      mod_id = &cur_mod_id);

         /*
          *  get the objid of the font manager using its named object
          */

         ex$get_super(mod_id = cur_mod_id,
                      mod_osnum = cur_mod_osnum,
                      super_name = FONTMGR_NO_NAME,
                      create = TRUE,
                      super_class = "GRfm",
                      super_id = &fontmgr_obj.objid,
                      super_osnum = &fontmgr_obj.osnum);

         om$send(mode = OM_e_wrt_object,
                 msg = message GRfm.GRfm_retdata(msg,&attr->font,&font_info),
                 senderid = NULL_OBJID,
                 targetid = fontmgr_obj.objid,
                 targetos = cur_mod_osnum);

         GRtx_extents(msg,text_string,&attr->text_length,
                      &font_info,display_attr,
                      attr->char_spac,attr->line_spac,
                      attr->width,attr->height,attr->font,beg_esc,
                      beg_esc + field_length - 1,&field_extents);
      }

      if (extents)
      {
         extents->top = field_extents.top;
         extents->cap = field_extents.cap;
         extents->base = field_extents.base;
         extents->bottom = field_extents.bottom;
         extents->left = field_extents.left;
         extents->right = field_extents.right;
      }

      if ((range) || (just_pts))
      {
         /*
          * get geometry of text string to use its transformation
          * matrix as the transformation matrix of the field
          */

	 lbs = *lbsys;
         /*
          * set up text_info structure for dp$get_char_under
          */

         text_info.estx = &cc_info.text_attr;
         text_info.font_id = OM_Gw_current_OS;
         text_info.flags = 0x1;
         text_info.just_moves[0] = ESC;
         text_info.just_moves[1] = 'h';
         text_info.just_moves[10] = ESC;
         text_info.just_moves[11] = 'v';
         text_info.text_string = (char *)text_string;

         cc_info_flg = FALSE;

         GRchar_pos_info(msg,text_string,beg_esc,cc_info_flg,
                         attr,&font_info,display_attr,
                         &cc_info);

         just_move = (cc_info.line_just_move + 
                      cc_info.wk_origin[0]) / 
                     cc_info.text_attr.width;

         OM_BLOCK_MOVE(&just_move,&text_info.just_moves[2],8);

         just_move = (cc_info.ss_v_move + 
                      cc_info.wk_origin[1]) / 
                     cc_info.text_attr.height;

         OM_BLOCK_MOVE(&just_move,&text_info.just_moves[12],8);

         /* 
          * get 'origin' point of field
          */

         dp$get_char_under(msg = msg,
                           lbsys = &lbs,
                           txt_ele = &text_info,
                           which_char = 0,
                           which_point = 1,
                           horizontal = FALSE,
                           point1 = pt,
                           point2 = &pt[3]);

         /*
          * fill in local bounded system of field using
          * the lbs of the text string
          */

         for (i = 0; i < 3; ++i)
         {
            field_matrix[i] = lbs.matrix[i];
            field_matrix[i + 4] = lbs.matrix[i + 4];
            field_matrix[i + 8] = lbs.matrix[i + 8];
            field_matrix[i + 12] = lbs.matrix[i + 12];
         }

         field_matrix[15] = lbs.matrix[15];
         field_matrix[3] = pt[0];
         field_matrix[7] = pt[1];
         field_matrix[11] = pt[2];

         if (range)
         {
            num_pts = 2;

            extent_pts[0] = field_extents.left;
            extent_pts[1] = field_extents.bottom;
            extent_pts[2] = 0;
            extent_pts[3] = field_extents.right;
            extent_pts[4] = field_extents.top;
            extent_pts[5] = 0;

            MAptsxform(msg,&num_pts,field_matrix,extent_pts,range);
         }

         if (just_pts)
         {
            /*
             * use the local bounded system matrix of the field
             * and the extents of the field to calculate the
             * justification points in world coordinates
             */

            just_points.left_bottom[0] = field_extents.left;
            just_points.left_bottom[1] = field_extents.bottom;
            just_points.left_bottom[2] = 0;

            just_points.left_base[0] = field_extents.left;
            just_points.left_base[1] = field_extents.base;
            just_points.left_base[2] = 0;

            just_points.left_center[0] = field_extents.left;
            just_points.left_center[1] = (field_extents.top + field_extents.bottom)/2;
            just_points.left_center[2] = 0;

            just_points.left_cap[0] = field_extents.left;
            just_points.left_cap[1] = field_extents.cap;
            just_points.left_cap[2] = 0;

            just_points.left_top[0] = field_extents.left;
            just_points.left_top[1] = field_extents.top;
            just_points.left_top[2] = 0;

            just_points.center_bottom[0] = (field_extents.left + field_extents.right)/2;
            just_points.center_bottom[1] = field_extents.bottom;
            just_points.center_bottom[2] = 0;
    
            just_points.center_base[0] = (field_extents.left + field_extents.right)/2;
            just_points.center_base[1] = field_extents.base;
            just_points.center_base[2] = 0;

            just_points.center_center[0] = (field_extents.left + field_extents.right)/2; 
            just_points.center_center[1] = (field_extents.top + field_extents.bottom)/2;
            just_points.center_center[2] = 0;

            just_points.center_cap[0] = (field_extents.left + field_extents.right)/2;
            just_points.center_cap[1] = field_extents.cap;
            just_points.center_cap[2] = 0;

            just_points.center_top[0] = (field_extents.left + field_extents.right)/2; 
            just_points.center_top[1] = field_extents.top;
            just_points.center_top[2] = 0;

            just_points.right_bottom[0] = field_extents.right;
            just_points.right_bottom[1] = field_extents.bottom;
            just_points.right_bottom[2] = 0;

            just_points.right_base[0] = field_extents.right;
            just_points.right_base[1] = field_extents.base;
            just_points.right_base[2] = 0;

            just_points.right_center[0] = field_extents.right;
            just_points.right_center[1] = (field_extents.top + field_extents.bottom)/2;
            just_points.right_center[2] = 0;

            just_points.right_cap[0] = field_extents.right;
            just_points.right_cap[1] = field_extents.cap;
            just_points.right_cap[2] = 0;

            just_points.right_top[0] = field_extents.right;
            just_points.right_top[1] = field_extents.top;
            just_points.right_top[2] = 0;

            num_pts = 15;

            MAptsxform(msg,&num_pts,field_matrix,just_points.left_bottom,
                       just_pts->left_bottom);
         }
      }
   }
   return(TRUE);
}

IGRint DMinquire_hilite(proj_pt,
			 prev_pt,
			 targetpt,
			 center,
			 src_dir,
			 src_dir1,
			 plan_info,
			 win_grid,
			 hilite)
	 IGRdouble  *proj_pt;
	 IGRdouble  *prev_pt;
	 IGRdouble  *targetpt;
	 IGRdouble  *center;
	 IGRdouble  *src_dir;
	 IGRdouble  *src_dir1;
	 struct DMplan_info  *plan_info;
	 struct GRid  *win_grid;
	 IGRint  *hilite;
/*.DMinquire_hilite*/
{
	IGRint status, i;
	IGRdouble tol_used, act_tol, tol_used_s;
	IGRdouble proj_line[6];
	IGRdouble perp_vec[3], norm_vec[3];
	BSrc bs_rc;

	DMget_dit_tol(win_grid, &tol_used);
	tol_used_s = tol_used * tol_used;

	for (i=0; i<3; i++)
	    norm_vec[i]= plan_info->win_plan.matrix[8+i];

	/*"tol_used(s):%lf\n",tol_used_s*/

	vec_equal(prev_pt,proj_line);
	
	/*|project point on to the source line direction */

	for (i=0; i<3; i++)
	    proj_line[i+3]= prev_pt[i] + src_dir[i];

	status = BSproj0(&bs_rc,proj_pt,proj_line,targetpt);
	dm$status(action = RET_STATUS);

	act_tol = BSdistptpts(&bs_rc,proj_pt,targetpt);

	/*"act_tol:%lf\n",act_tol*/
	
	if (act_tol < tol_used_s)
	{
		*hilite |= LOCKED_TO_SRC_DIR0_T;
		return(TRUE);
	}

	/*|project point on the perpendicular direction */

	status=
	BScrossp(&bs_rc,src_dir,norm_vec,perp_vec);
	dm$status(action=RET_STATUS);

	for (i=0; i<3; i++)
	    proj_line[3 + i] = prev_pt[i] + perp_vec[i];

	status = BSproj0(&bs_rc,proj_pt,proj_line,targetpt);
	dm$status(action = RET_STATUS);

	act_tol = BSdistptpts(&bs_rc,proj_pt,targetpt);	

	/*"act_tol:%lf\n",act_tol*/

	if (act_tol < tol_used_s)
	{
		*hilite |= LOCKED_TO_SRC_DIR0_N;
		return(TRUE);
	}

	/*|project point in the  y direction of target*/

	for (i=0; i<3; i++)
	    proj_line[3 + i] = prev_pt[i] + plan_info->win_plan.vec_ypos[i];

	status = BSproj0(&bs_rc,proj_pt,proj_line,targetpt);
	dm$status(action= RET_STATUS);

	act_tol = BSdistptpts(&bs_rc,proj_pt,targetpt);

	/*"act_tol:%lf\n",act_tol*/

	if( act_tol < tol_used_s)
	{
		*hilite |= LOCKED_TO_AXIS_VERTICAL;
		return(TRUE);
	}

	/*|project point on the horizontal direction */

	for (i=0; i<3; i++)
	    proj_line[3 + i] = prev_pt[i] + plan_info->win_plan.vec_xpos[i];

	status = BSproj0(&bs_rc,proj_pt,proj_line,targetpt);
	dm$status(action= RET_STATUS);

	act_tol = BSdistptpts(&bs_rc,proj_pt,targetpt);

	/*"act_tol:%lf\n",act_tol*/
	if (act_tol < (4 * tol_used_s))
	{
		*hilite |= LOCKED_TO_AXIS_HORIZ;
		return(TRUE);
	}

	if (src_dir1)
	{
		/*|- project on alternate src dir */

		for (i=0; i<3; i++)
		    proj_line[3+i] = prev_pt[i] + src_dir1[i];

		status = BSproj0(&bs_rc,proj_pt,proj_line,targetpt);
		dm$status(action= RET_STATUS);

		/*^ print_point("target_pt", targetpt); */

		act_tol = BSdistptpts(&bs_rc,proj_pt,targetpt);

		/*"act_tol:%lf\n",act_tol*/
		if (act_tol < tol_used_s)
		{
			*hilite |= LOCKED_TO_SRC_DIR1;
			return(TRUE);
		}
	}

	if (center)
	{
		/*|- inquire hilite on cross line */

		for (i=0; i<3; i++)
		{
		    proj_line[i] = center[i];
		    proj_line[i+3] = center[i] +
			plan_info->act_plan.vec_xpos[i];
		}

		/*|- check for horizantal line */

		status = BSproj0(&bs_rc,proj_pt,proj_line,targetpt);
		dm$status(action= RET_STATUS);

		act_tol = BSdistptpts(&bs_rc,proj_pt,targetpt);

		/*"act_tol:%lf\n",act_tol*/
		if (act_tol < (4 * tol_used_s))
		{
			*hilite |= LOCKED_TO_CENTER_H;
			return(TRUE);
		}

		for (i=0; i<3; i++)
		    proj_line[i+3] = center[i] +
			plan_info->act_plan.vec_ypos[i];

		/*|- check for vertical line */

		status = BSproj0(&bs_rc,proj_pt,proj_line,targetpt);
		dm$status(action= RET_STATUS);

		act_tol = BSdistptpts(&bs_rc,proj_pt,targetpt);

		/*"act_tol:%lf\n",act_tol*/
		if (act_tol < tol_used_s)
		{
			*hilite |= LOCKED_TO_CENTER_V;
			return(TRUE);
		}
	}

	/*|no hilite mode*/
	math_v_equal(targetpt, proj_pt);
	*hilite = 0;
	return(TRUE);
}

DMget_annot_txt_info (plan_info,
		      p_senv,
		      txt_vec_orie,
		      norm_vec,
		      txt_just,
		      prev_dir)
	 struct DMplan_info  *plan_info;
	 struct DMsenv_param  *p_senv;
	 IGRdouble  *txt_vec_orie;
	 IGRdouble  *norm_vec;
	 IGRshort  *txt_just;
	 IGRdouble  *prev_dir;
/*.DMget_ang_txt_info*/
{
	BSrc bs_rc;
	double scale;

	scale = BSlenvec(&bs_rc, plan_info->win_plan.vec_xpos);

	switch(p_senv->an_orie)
	{
	case TXT_ORIE_VERTICAL:
		if(p_senv->an_posn == ANNOT_JUST_ABOVE)
			*txt_just = LEFT_CAP;
		else if(p_senv->an_posn ==  ANNOT_JUST_CENTER)
			*txt_just = LEFT_CENTER;
		else if( p_senv->an_posn == ANNOT_JUST_BOTTOM)
			*txt_just = LEFT_BASE;
		else 	*txt_just = LEFT_BOTTOM;
		vec_equal(plan_info->win_plan.vec_ypos,txt_vec_orie);
		break;
	case TXT_ORIE_PERPENDICULAR:
		BScrossp(&bs_rc,norm_vec,prev_dir,txt_vec_orie);
		math_v_scale(txt_vec_orie, scale);
		if(p_senv->an_posn == ANNOT_JUST_ABOVE)
			*txt_just = RIGHT_BASE;
		else if(p_senv->an_posn ==  ANNOT_JUST_CENTER)
			*txt_just = CENTER_BASE;
		else if( p_senv->an_posn == ANNOT_JUST_BOTTOM)
			*txt_just = LEFT_BASE;
		else 	*txt_just = LEFT_CENTER;
		break;
	case TXT_ORIE_PARALLEL:
	case TXT_ORIE_HORIZONTAL:
		if(p_senv->an_posn == ANNOT_JUST_ABOVE)
			*txt_just = LEFT_CAP;
		else if(p_senv->an_posn ==  ANNOT_JUST_CENTER)
			*txt_just = LEFT_CENTER;
		else if( p_senv->an_posn == ANNOT_JUST_BOTTOM)
			*txt_just = LEFT_BASE;
		else 	*txt_just = LEFT_BOTTOM;
		if(p_senv->an_orie == TXT_ORIE_HORIZONTAL)
		{
			vec_equal(plan_info->win_plan.vec_xpos,txt_vec_orie);
		}
		else 
		{
			if( prev_dir[0] < 0)
			{
				vec_neg(prev_dir,txt_vec_orie);
			}
			else {
				vec_equal(prev_dir,txt_vec_orie);
			}
			math_v_scale(txt_vec_orie, scale);
		}
		break;
	}
	/*"p_senv->an_posn:%d\ttxt_just:%d\n",p_senv->an_posn,*txt_just*/
	return(TRUE);
}

DMupdate_feature_fonts (dim_grid,
			md_env)
	 struct GRid  dim_grid;
	 struct GRmd_env  *md_env;
/*.DMupdate_feature_fonts*/
{
	IGRint rc, status, i;
	IGRint dim_type, dual_mode, tol_symbol,symbol_num;
	IGRshort CurrIndex, text_length, FontIndex, tmp_font;
	IGRlong long_rc;
	IGRuchar *text_string;
	struct GTattr gtattr;
	struct IGRestx estx;
	struct GRmd_env mod_info;
	struct GRid text_grid;
	struct annot_attr attr;
	OMuword osnum;
	struct DMsenv_param par_senv;
	
	osnum = dim_grid.osnum;

	status =
	om$send(msg = message DMroot.return_dim_go(
					&rc,
					DIM_TEXT,
					FALSE,
					DM_TEXT,
					&mod_info,
					&text_grid),
		senderid = NULL_OBJID,
		targetid = dim_grid.objid,
		targetos = dim_grid.osnum);
	dm$status(action = RET_STATUS);

	/*^ print_grid("text_grid", &text_grid); */

	if (rc == DIM_E_NO_OBJECT) return(OM_S_SUCCESS);

	status =
	om$send(msg = message DMannot.get_edit_attr(0, &attr),
		senderid = NULL_OBJID,
		targetid = dim_grid.objid,
		targetos = dim_grid.osnum);
	dm$status(action = RET_STATUS);

	dim_type = attr.dim_type;
	dual_mode = attr.dual_mode;

	ANget_tol_symbol(attr.tol_symbol,&symbol_num,&gtattr,NULL);

	tol_symbol = gtattr.tol_symbol;

	/*^printf(" dim_type:%d, dual_mode:%d, tol_symbol:%d\n",
		 dim_type, dual_mode, tol_symbol);*/

	status =
	om$send(msg = message GRtext.GRgettxattr(
					&long_rc,
					&estx,
					&text_length,
					&text_string),
		senderid = NULL_OBJID,
		targetid = text_grid.objid,
		targetos = text_grid.osnum);
	dm$status(action = RET_STATUS);

	/*^
		printf("length = %d\n", text_length);
		analyse_string(text_string, text_length);
	*/

        DMupdt_disp_chars(text_string,
                          &text_length,
                          &gtattr,
                          dual_mode,
                          dim_type);

	/*^printf(" num disp char:%d\n",gtattr.num_disp_char);*/

	status =
	dm$get_dim_param(
		type = DM_SENV_PARAM,
		dim_objid = dim_grid.objid,
		dim_osnum = dim_grid.osnum,
		p_data = (char *) &par_senv);
	dm$status(action = RET_STATUS);

	gtattr.disp_char_index = 0;
	gtattr.geom_font = DMmap_font( osnum, FONT_100);
	gtattr.ter_font  = DMmap_font( osnum, FONT_102);
	gtattr.text_font = par_senv.text_font;
	gtattr.sep_symbol= 'l';

	tmp_font  = DMmap_font( osnum, FONT_31);

	/*^ printf("geom_font = %d, ter_font = %d, text_font = %d\n",
		gtattr.geom_font, gtattr.ter_font, gtattr.text_font);*/

	DMreplace_tol_sym(text_string,
			  &text_length,
			  tol_symbol,
			  dual_mode,
			  &estx,
			  &gtattr);

	for(i = 0 ;i< gtattr.num_disp_char; i++)
	{
		if(gtattr.disp_char[i] == GEOM_SYMBOL)
		{	gtattr.disp_char_index = i;
			DMcompute_valid_index(text_string, &text_length,
					      &CurrIndex,&gtattr,dim_type);

			if (text_string[CurrIndex +1] == 'x')
				FontIndex = CurrIndex + 12;
			else	FontIndex = CurrIndex + 2;
		
			DMreplace_geom_char( text_string, 
					     FontIndex,
					     gtattr.geom_font,
					     gtattr.ter_font,
					     tmp_font);
		}	
	}

	/*^
		printf("length = %d\n", text_length);
		analyse_string(text_string, text_length);
	*/

	status =
	om$send(msg = message GRtext.GRreplace_text(
						&long_rc,
						md_env,
						text_length,
						text_string),
		senderid = NULL_OBJID,
		targetid = text_grid.objid,
		targetos = text_grid.osnum);
	dm$status(action = RET_STATUS);

	return(TRUE);
}

DMreplace_geom_char (text_string,
		     index,
		     geom_font,
		     ter_font,
		     tmp_font)
	 IGRuchar  *text_string;
	 int  index;
	 short  geom_font;
	 short  ter_font;
	 short  tmp_font;
 /*
IGRuchar *text_string;
int index;
short geom_font, ter_font;
 */
{
	if(text_string[index +2] == 'W') 
		memcpy(&text_string[index], &ter_font, 2);
	else if(text_string[index +2] == '`') 
		memcpy(&text_string[index], &tmp_font, 2);
	else
		memcpy(&text_string[index], &geom_font, 2);

	return(TRUE);
}

DMupdate_weld_font (dim_grid,
		    md_env)
	 struct GRid  dim_grid;
	 struct GRmd_env  *md_env;
/*.DMupdate_weld_font*/
{
	IGRint status, i, rc;
	IGRlong long_rc;
	IGRshort length, font_num;
	IGRuchar *string;
	struct GRmd_env mod_info;
	struct GRid text_grid;

        DMretrieve_font(&rc, dim_grid.osnum, (IGRuchar *) "99", &font_num);

	status =
	om$send(msg = message DMroot.return_dim_go(
					&rc,
					AATEXT,
					FALSE,
					DM_TEXT,
					&mod_info,
					&text_grid),
		senderid = NULL_OBJID,
		targetid = dim_grid.objid,
		targetos = dim_grid.osnum);
	dm$status(action = RET_STATUS);

	if (rc != DIM_E_NO_OBJECT)
	{
		status =
		om$send(msg = message GRtext.GRgettxattr(
					&long_rc,
					NULL,
					&length,
					&string),
			senderid = NULL_OBJID,
			targetid = text_grid.objid,
			targetos = text_grid.osnum);
		dm$status(action = RET_STATUS);

		i=0;
		while (!(string[i] == ESC
		&& string[i+1] == 'F' && string[i+2] == 2)
		&& (i < length))
		i++;

		if( i < length)
		{
			memcpy(&string[i+6], &font_num, 2);

			status =
			om$send(msg = message GRtext.GRreplace_text(
							&long_rc,
							md_env,
							length,
							string),
				senderid = NULL_OBJID,
				targetid = text_grid.objid,
				targetos = text_grid.osnum);
			dm$status(action = RET_STATUS);
		}
	}

	status =
	om$send(msg = message DMroot.return_dim_go(
					&rc,
					BATEXT,
					FALSE,
					DM_TEXT,
					&mod_info,
					&text_grid),
		senderid = NULL_OBJID,
		targetid = dim_grid.objid,
		targetos = dim_grid.osnum);
	dm$status(action = RET_STATUS);

	if (rc != DIM_E_NO_OBJECT)
	{
		status =
		om$send(msg = message GRtext.GRgettxattr(
					&long_rc,
					NULL,
					&length,
					&string),
			senderid = NULL_OBJID,
			targetid = text_grid.objid,
			targetos = text_grid.osnum);
		dm$status(action = RET_STATUS);

		i=0;
		while (!(string[i] == ESC
		&& string[i+1] == 'F' && string[i+2] == 3)
		&& (i < length))
		i++;

		if( i < length)
		{
			memcpy(&string[i+6], &font_num, 2);

			status =
			om$send(msg = message GRtext.GRreplace_text(
							&long_rc,
							md_env,
							length,
							string),
				senderid = NULL_OBJID,
				targetid = text_grid.objid,
				targetos = text_grid.osnum);
			dm$status(action = RET_STATUS);
		}
	}

	return(TRUE);
}

IGRint DMupdate_bln_src (msg,
			 src,
			 dim,
			 md_env)
	 IGRint  *msg;
	 struct GRid  *src;
	 struct GRid  *dim;
	 struct GRmd_env  *md_env;
/*.DMupdate_bln_src*/
{
	IGRint status, rc;
	IGRshort first;
	IGRdouble text_offset, start_pt[3];
	IGRdouble point1[3];
	struct GRid prev;
	struct DMplan_info plan_info;
	struct DMsenv_param par_senv;	
	struct IGRline boreline;
	IGRchar src_state;
	struct dim_ret_struct ret_st;

	*msg = MSSUCC;

	status =
	om$send(msg = message DMroot.get_dimension_plane(
					msg,
					md_env,
					&plan_info),
		senderid = NULL_OBJID,
		targetid = dim->objid,
		targetos = dim->osnum);
	dm$status(action = RET_STATUS);

	status =
	om$send(msg = message DMroot.give_previous(msg, &first, &prev),
		senderid = NULL_OBJID,
		targetid = dim->objid,
		targetos = dim->osnum);
	dm$status(action = RET_STATUS);

	if (first)
	{
		printf("Cannot Update the first balloon\n");
		return(OM_E_ABORT);
	}

	status =
	om$send(msg = message DMannot.get_active_senv(&par_senv),
		senderid = NULL_OBJID,
		targetid = dim->objid,
		targetos = dim->osnum);
	dm$status(action = RET_STATUS);

	text_offset = par_senv.txt_heig * 0.5;

	status=
	om$send(msg = message DMtxbln.give_bln_center(
				msg,
				&text_offset,
				start_pt,
				&prev,
				&plan_info,
				md_env),
		senderid = NULL_OBJID,
		targetid = dim->objid,
		targetos = dim->osnum);
	dm$status(action = RET_STATUS);

 	status =
	om$send(msg = message NDnode.NDget_state(&src_state),
		senderid = NULL_OBJID,
		targetid = src->objid,
		targetos = src->osnum);
	if ((status & 1) && (src_state & ND_DEGRADED))
	{
		/*|- Parent is already degraded*/

		status =
		om$send(msg = message DMsrc.DMgive_structure(
						&rc,
						0,
						FALSE,
						&ret_st,
						md_env),
			senderid = NULL_OBJID,
			targetid = src->objid,
			targetos = src->osnum);
		dm$status(action = RET_STATUS);

		/*|- Initialise the DMsrc instance with new pt*/

		math_v_equal(ret_st.var.dm_ptdist.point, start_pt);

		status =
		om$send(msg = message DMsrc.DMgive_structure(
						&rc,
						0,
						TRUE,
						&ret_st,
						md_env),
			senderid = NULL_OBJID,
			targetid = src->objid,
			targetos = src->osnum);
		dm$status(action = RET_STATUS);
	}
	else
	{
		boreline.point1 = start_pt;
	
		point1[0] = boreline.point1[0] + plan_info.act_plan.matrix[8];
		point1[1] = boreline.point1[1] + plan_info.act_plan.matrix[9];
		point1[2] = boreline.point1[2] + plan_info.act_plan.matrix[10];

		boreline.point2 = point1;

		status =
		om$send(msg = message DMsrc.DMmodify(
						msg,
						md_env,
						TRUE,
						TRUE,
						&boreline),
			senderid = NULL_OBJID,
			targetid = src->objid,
			targetos = src->osnum);
		dm$status(action = RET_STATUS);
	}

	return(OM_S_SUCCESS);
}

DMupdate_text_fonts (dim_type,
		     dim_grid,
		      osnum,
		      to_env)
	 IGRint  dim_type;
	 struct GRid  dim_grid;
	 OMuword  osnum;
	 struct GRmd_env  *to_env;
/*.DMupdate_text_fonts*/
{
	IGRint rc, status;
	IGRlong long_rc;
	IGRshort font_num, font_index;
	struct GRid font_mgr;
	struct DMenv_param par_env;
	struct DMsenv_param par_senv;
	struct vfont_entry font_info;

	if ((1 << dim_type) & ANNOTATION_MASK)
	{
		status =
		dm$get_dim_param(
			type = DM_SENV_PARAM,
			dim_objid = dim_grid.objid,
			dim_osnum = dim_grid.osnum,
			p_data = (char *) &par_senv);
		dm$status(action = RET_STATUS);

		font_num = par_senv.text_font;
	}
	else
	{
		status =
		dm$get_dim_param(
			type = DM_ENV_PARAM,
			dim_objid = dim_grid.objid,
			dim_osnum = dim_grid.osnum,
			p_data = (char *) &par_env);
		dm$status(action = RET_STATUS);

		font_num = par_env.text_font;
	}

	/*"get the font manager of the osnum %d\n", osnum*/

	font_mgr.osnum = osnum;

	status =
	ex$get_objid_from_NOD(
		NODname = "IGENOD",
		objname = "GRFONTMGR",
		pobjid = &font_mgr.objid,
		mod_osnum = osnum);
	dm$status(action = RET_STATUS);

	/*"Get font info for old index from font mgr(%d, %d)\n", font_mgr.objid, font_mgr.osnum*/

	status =
	font$get_info(
		msg = &long_rc,
		font_num = &font_num,
		fontmgr = &font_mgr,
		font_info = &font_info);
	dm$status(action = RET_STATUS);

	/*"Retrieve the font <%s> to the osnum %d", font_info.vfontname, to_env->md_id.osnum*/
		
	DMretrieve_font(
		&rc,
		to_env->md_id.osnum,
		font_info.vfontname,
		&font_index);
	if (rc != DIM_S_SUCCESS)
	{
		ex$message(msgnumb = DM_I_ErrRetFont,  
			   type ="%s",
	 		   var =font_info.vfontname);
		return(FALSE);
	}

	/*"Font retrieved at index %d, old index was %d\n",font_index, font_num*/

	if (font_num != font_index)
	{
		/*| Set dim to state EDIT */

		status =
		om$send(msg = message DMroot.set_dim_state(BIT_OR, DIM_IN_EDIT),
			senderid = NULL_OBJID,
			targetid = dim_grid.objid,
			targetos = dim_grid.osnum);
		dm$status(action = RET_STATUS);

		/*| Put environment */

		if ((1 << dim_type) & ANNOTATION_MASK)
		{
			par_senv.text_font = font_index;

			status =
			dm$put_dim_param(
				type = DM_SENV_PARAM,
				dim_objid = dim_grid.objid,
				dim_osnum = dim_grid.osnum,
				p_data = (char *) &par_senv);
			dm$status(action = RET_STATUS);
		}
		else
		{
			par_env.text_font = font_index;

			status =
			dm$put_dim_param(
				type = DM_ENV_PARAM,
				dim_objid = dim_grid.objid,
				dim_osnum = dim_grid.osnum,
				p_data = (char *) &par_env);
			dm$status(action = RET_STATUS);
		}

		/*| Clear EDIT state */

		status =
		om$send(msg = message DMroot.set_dim_state(BIT_XOR, DIM_IN_EDIT),
			senderid = NULL_OBJID,
			targetid = dim_grid.objid,
			targetos = dim_grid.osnum);
		dm$status(action = RET_STATUS);
	}

	if (dim_type == FEATURE_CONTROL_FRAME)
	{
		DMupdate_feature_fonts(dim_grid, to_env);
	}

	if (dim_type == WELD)
	{
		DMupdate_weld_font(dim_grid, to_env);
	}

	return(TRUE);
}

IGRint DMconv_txldr_text(length, chstr)
IGRshort  *length;
IGRchar  **chstr;
/*.DMconv_txldr_text*/
{
	IGRshort num_chars,loc_length;
	extern IGRshort GRfwd_esc_seq();
	IGRchar *txt_ptr, *s, loc_string[80];

	if(!*length)
	{
	 	dbg$print(msg = "null text string");
		return(TRUE);
	}

	/*^ analyse_string(*chstr, *length); */

	num_chars = loc_length = 0;

	s = *chstr;
	while( TRUE)
	{
		if (*s == ESC)
		{
			if (s[1] == 'j'	|| s[1] == 'J')
			{
				if(*length == 10)
					return(FALSE);
				DMdelete_text((IGRuchar *) s, length, 0, 10);
			}
			else	break;
		}
		else	break;
	}

	if(s[0] == ESC && s[1] == 'F')
		return(TRUE);
	txt_ptr = loc_string;
	start_field(txt_ptr,2,0,loc_length);

	num_chars = *length + loc_length + 2;

	s = *chstr = om$realloc(ptr = *chstr, size = num_chars);
	DMinsert_text((IGRuchar *) s, (IGRuchar *) loc_string, 0, loc_length, length);
	s[*length] = 27;
	s[*length + 1] = 'E';
	*length += 2;

	return(TRUE);
}

IGRint ANget_disp_par(par_senv,text_st,font_os)
/*
	(
	 struct DMsenv_param  *par_senv,
	 struct ANtext_data  *text_st,
	 short  font_os
	)
*/
struct DMsenv_param *par_senv;
struct ANtext_data *text_st;
short font_os;
/*.ANget_disp_par*/
{
	IGRint sizebuf,nbytes;
	IGRint status;
	IGRlong msg;
	struct IGResintx *text_info;

	text_st->active_symb.Active_font = par_senv->text_font;
   	text_st->active_symb.Active_width = par_senv->txt_widt;
   	text_st->active_symb.Active_height = par_senv->txt_heig;
     	text_st->active_symb.Active_linespac = par_senv->lin_spac;
   	text_st->active_symb.Active_charspac = par_senv->car_spac;
   	text_st->active_symb.Active_flags = 1;  /* filled text */

	sizebuf = sizeof(text_st->active_display);
	gr$get_active_display( msg= &msg,
			       sizbuf = &sizebuf,
			       buffer = &text_st->active_display,
			       nret = &nbytes);

	text_st->active_display.color =	par_senv->dim_colr;
	text_st->active_display.weight = par_senv->dim_weig;
	text_st->active_display.style = 0;

	status=
        font$get_info(msg = &msg,
            font_num = &text_st->active_symb.Active_font,
            font_info = &text_st->font_info);
	dm$status(action = RET_STATUS);

	text_info = &text_st->text_info;
	text_info->estx = &text_st->estx;
	text_info->font_id = font_os;
   	text_info->flags = 0;
   	text_info->prev_font = text_st->active_symb.Active_font;
   	text_info->estx->font = text_st->active_symb.Active_font;
   	text_info->estx->just = text_st->active_symb.Active_just;
   	text_info->estx->width = text_st->active_symb.Active_width;
   	text_info->estx->height = text_st->active_symb.Active_height;
   	text_info->estx->flag = text_st->active_symb.Active_flags;
   	text_info->estx->num_char = 0;
   	text_info->estx->line_spac = text_st->active_symb.Active_linespac;
   	text_info->estx->char_spac = text_st->active_symb.Active_charspac;
  
	return(TRUE);
}

end implementation DMannot;
