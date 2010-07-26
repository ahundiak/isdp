/* #######################    APOGEE COMPILED   ######################## */

/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     MODULE NAME:   GRfield_inquire
 
     Abstract:
                This routine accepts a query for information about a
                specified field. A query can be made on any or all of
                the field's data (contents, range, attributes, extents,
                or justification points). If information is not required
                about a particular type of data a NULL pointer must be
                passed in. If the specified field is not found, MSFAIL
                will be returned.
-----
%SC%

  VALUE = GRfield_inquire(msg,field_num,type,matrix,length,contents,
                          attributes,range,just_pts1,extents1)
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                      DESCRIPTION
    ------------  ---------------   ---------------------------------------
    *field_num    IGRchar           which field number to use
    *type         IGRshort          type of environment matrix
    matrix        IGRmatrix         environment matrix of text object
-----
%EX%

     ON EXIT:

        NAME         DATA TYPE                      DESCRIPTION
   ----------     --------------- -----------------------------------------
    *msg          IGRlong           completion code
    *length       IGRshort          length of field
    **contents    IGRuchar          contents of the field
    *attributes   IGRuchar          attributes of the field
    *extents1     struct extents    extents of the field
    range         GRrange           range of the field
    just_pts1     struct just_pts   justification points of the field

   VALUE (IGRlong) =    MSSUCC    - if successful
                        MSFAIL    - if failure
-----
%MD%

     MODULES INVOKED: GRfwd_beg_esc_seq
                      GRfm.GRfm_retdata
                      GRget_field_len
                      GRtx_extents
-----
%RL%

      RELATIONS REFERENCED:  none

----- 
%NB%

     NOTES:    The pointer to a particular type of data must be NULL
               if that type of data is not desired.

               Memory for the contents must be allocated by the caller
               before this method is called to return contents. If the
               length of the field is not known, this method must be
               called first to find it.
-----

%CH%
     CHANGE HISTORY:
        
        DEK  02/06/87 : Design date.
        DEK  02/09/87 : Creation date.
        DEK  03/02/87 : Added range and justification points.
        DEK  02/10/88 : Updated for font server.
        SCW  07/21/92 : Ansi conversion
-----
%PD%
--------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
     This routine accepts a query for information about a specified
field. A query can be made on any or all of the field's data 
(contents, range, attributes, extents, or justification points). If
information is not required about a particular type of data a NULL
pointer must be passed in. If the specified field is not found, 
MSFAIL will be returned.
----*/
/*EH*/

class implementation GRtext;

#include "fontdef.h"
#include "font.h"
#include "fontmacros.h"
#include "msdef.h"
#include "exmacros.h"
#include "OMmacros.h"
#include "dpmacros.h"
#include "gotextdef.h"
#include "gotext.h"
#include "grimport.h"

from GRfm import GRfm_retdata;

method GRfield_inquire(IGRlong *msg; IGRuchar *field_num;
                       IGRshort *type; IGRmatrix matrix; IGRshort *length;
                       IGRuchar **contents;
                       IGRuchar *attributes;
                       struct extents *extents1; GRrange range; 
                       struct just_pts *just_pts1)
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
   IGRuchar            *esc_nums[1];   /* array for numbers after esc
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

   current_font = me^^GRtext.attr.font;
   prev_font = current_font;

   font$get_info(msg = msg,
                 font_num = &current_font,
                 font_info = &font_info);

   cur_font_info = font_info;

   if (GRfwd_beg_esc_seq(msg,me->text_string,&me->attr.text_length,
                         &num_chars,esc_chars,esc_nums,&start_index,
                         &prev_font,&current_font,&cur_font_info,&beg_esc))
   {
      /*
       * get the length of the field
       */

      GRget_field_len(msg,me->text_string,&me->attr.text_length,&beg_esc,
                      prev_font,current_font,cur_font_info.flags,&field_length);

      if (length)
      {
         *length = field_length + 2;    /* include end field esc seq */
      }

      if (*contents)
      {
         OM_BLOCK_MOVE(&(me->text_string[beg_esc]),*contents,field_length + 2);
      }

      if (attributes)
      {
         *attributes = me->text_string[beg_esc + 3];
      }

      if ((extents1) || (range) || (just_pts1))
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
                 msg = message GRfm.GRfm_retdata(msg,&me->attr.font,&font_info),
                 senderid = NULL_OBJID,
                 targetid = fontmgr_obj.objid,
                 targetos = cur_mod_osnum);

         GRtx_extents(msg,me->text_string,&me->attr.text_length,
                      &font_info,&me^^GRvg.display_attr,
                      me->attr.char_spac,me->attr.line_spac,
                      me->attr.width,me->attr.height,me->attr.font,beg_esc,
                      beg_esc + field_length - 1,&field_extents);
      }

      if (extents1)
      {
         extents1->top = field_extents.top;
         extents1->cap = field_extents.cap;
         extents1->base = field_extents.base;
         extents1->bottom = field_extents.bottom;
         extents1->left = field_extents.left;
         extents1->right = field_extents.right;
      }

      if ((range) || (just_pts1))
      {
         /*
          * get geometry of text string to use its transformation
          * matrix as the transformation matrix of the field
          */

         om$send(mode = OM_e_wrt_object,
                 msg = message GRvg.GRgetgeom(msg,type,matrix,(IGRchar *)&lbs),
                 senderid = my_id,
                 targetid = my_id);

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
         text_info.text_string = (IGRchar *)me^^GRtext.text_string;

         cc_info_flg = FALSE;

         GRchar_pos_info(msg,me^^GRtext.text_string,beg_esc,cc_info_flg,
                         &me^^GRtext.attr,&font_info,&me->display_attr,
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

         if (just_pts1)
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
                       just_pts1->left_bottom);
         }
      }
   }
   return(TRUE);
}

end implementation GRtext;
