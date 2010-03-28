/* #######################    APOGEE COMPILED   ######################## */

/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     MODULE NAME:             GResc_handler
 
     Abstract:

               This routine processes the escape sequences in a text
               string.
-----
%SC%

  VALUE = GResc_handler(msg,text_string,esc_seq_index,text_attr,wk_origin,
                        base_line,font_info,prev_font,disp_attr,just_info,
                        extents,esc_seq_size)
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                      DESCRIPTION
    ------------  ---------------   -------------------------------------
    *msg          IGRlong           completion code
    *text_string  IGRuchar          entire text string
    esc_seq_index IGRint            escape sequence position in the text
                                    string (char. immediately after esc.)
    *text_attr    struct IGRestx    text specific attributes
    *wk_origin    IGRdouble         working origin of the current char
    *base_line    IGRdouble         current base line of the text string
    *font_info    struct vfont_entry current font information
    *prev_font    IGRshort          font previously used in string
    *disp_attr    struct IGRdisplay current display attributes
    *just_info    struct just_info  justification information
    *extents      struct extents    extents of character
-----
%EX%

     ON EXIT:

        NAME         DATA TYPE                      DESCRIPTION
   ----------     --------------- -----------------------------------------
    *text_attr    struct IGRestx    text specific attributes
    *wk_origin    IGRdouble         working origin of the current char
    *base_line    IGRdouble         current base line of the text string
    *font_info    struct vfont_entry current font information
    *prev_font    IGRshort          font previously used in string
    *disp_attr    struct IGRdisplay current display attributes
    *just_info    struct just_info  justification information
    *extents      struct extents    extents of character
    *esc_seq_size IGRshort          size of processed escape  sequence
                                    (in bytes), excluding the escape char.

   VALUE (IGRboolean) =    TRUE    - if successful
                           FALSE   - if failure
-----
%MD%

     MODULES INVOKED:

     modules:
-----
%RL%

      RELATIONS REFERENCED:

----- 
%NB%

     NOTES:  
-----

%CH%
     CHANGE HISTORY:
        
        DEK      11/12/86 : Design date.
        DEK      11/12/86 : Creation date.
        WBC/DEK  11/11/87 : Updated to support font server
        DEK      09/07/88 : Added change weight and change color
                            escape sequences.
        SCW      07/21/92 : Ansi conversion
-----
%PD%
--------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
     This routine processes the escape sequences in a text string.

----*/
/*EH*/

class implementation GRtext;

#include "exmacros.h"
#include "fontdef.h"
#include "font.h"
#include "msdef.h"
#include "gotextdef.h"
#include "gotext.h"
#include "OMmacros.h"
#include "grimport.h"

from GRfm import GRfm_retdata;

IGRboolean GResc_handler(msg,text_string,esc_seq_index,text_attr,wk_origin,
                         base_line,font_info,prev_font,disp_attr,just_info,
                         extents,esc_seq_size)

IGRlong              *msg;                 /* completion code               */
IGRuchar             *text_string;         /* entire text string            */
IGRint               esc_seq_index;        /* position in text string after
                                              escape character              */
struct IGRestx       *text_attr;           /* text specific attributes      */
IGRdouble            wk_origin[2];         /* working origin of current char*/
IGRdouble            *base_line;           /* current base line of string   */
struct vfont_entry   *font_info;           /* current font information      */
IGRshort             *prev_font;           /* font previously used in string*/
struct IGRdisplay    *disp_attr;           /* current display attributes    */
struct just_info     *just_info;           /* justification information     */
struct extents       *extents;             /* extents of text string        */
IGRshort             *esc_seq_size;        /* size of processed escape seq  */
                                           /* (in bytes), excluding the esc */
{
   IGRdouble         d_hold;               /* used to store a double from
                                              the text string               */
   IGRshort          s_hold;               /* used to store a short from
                                              the text string               */
   IGRdouble         descent;              /* descent modified for font     */
   IGRdouble         temp_extent;          /* temporary extent value        */
   struct GRid       fontmgr_obj;          /* font manager object           */
   OM_S_OBJID        mod_id;               /* current module id             */
   OMuword           mod_osnum;            /* current module os number      */

   *msg = MSSUCC;        /* initialize success */

   descent = font_info->descent / (font_info->bodysize - font_info->descent);

   if (text_string[esc_seq_index] == LINEFEED)
   {
      /*
       *  escape sequence for a linefeed (newline);
       *  setting the working origin
       */

      wk_origin[0] = 0;
      wk_origin[1] = *base_line - ((text_attr->height +
                                   (text_attr->height * (font_info->descent /
                                   (font_info->bodysize - font_info->descent)))) *
                                   text_attr->line_spac);
      *base_line = wk_origin[1];

      /*
       *  calculate top, bottom, cap, and base extents
       */

      if ((temp_extent = wk_origin[1] + text_attr->height + 
                         (text_attr->height * descent)) > extents->top)
      {
         extents->top = temp_extent;
      }

      if ((temp_extent = wk_origin[1] + text_attr->height) > extents->cap)
      {
         extents->cap = temp_extent;
      }

      if (wk_origin[1] < extents->base)
      {
         extents->base = wk_origin[1];
      }

      if ((temp_extent = wk_origin[1] - (text_attr->height * descent )) < 
          extents->bottom)
      {
         extents->bottom = temp_extent;
      }

      just_info->just_esc_pos = esc_seq_index + 1;/* position after linefeed */
      ++just_info->num_lines;
      just_info->cur_line_left = 0.0;
      just_info->cur_line_right = 0.0;
      *esc_seq_size = 1;
   }
   else if (text_string[esc_seq_index] == 'h')
   {
      /*
       * escape sequence defining horizontal move;
       * set the size of the escape sequence move to a double,
       * set the working origin, and update the ends of current line
       */

      OM_BLOCK_MOVE(&text_string[esc_seq_index + 1],&d_hold,8);

      wk_origin[0] += (text_attr->width * d_hold);

      if (wk_origin[0] > just_info->cur_line_right)
      {
         just_info->cur_line_right = wk_origin[0];
      }
      else if (wk_origin[0] < just_info->cur_line_left)
      {
         just_info->cur_line_left = wk_origin[0];
      }
      *esc_seq_size = 9;
   }
   else if (text_string[esc_seq_index] == 'v')
   {
      /*
       * escape sequence defining vertical move;
       * set the size of the escape sequence move to a double and
       * set the working origin
       */
  
      OM_BLOCK_MOVE(&text_string[esc_seq_index + 1],&d_hold,8);

      wk_origin[1] += (text_attr->height * d_hold);

      /*
       *  calculate top, bottom, cap, and base extents
       */

      if ((temp_extent = wk_origin[1] - (text_attr->height * descent)) < 
          extents->bottom)
      {
         extents->bottom = temp_extent;
      }

      if (wk_origin[1] < extents->base)
      {
         extents->base = wk_origin[1];
      }

      if ((temp_extent = wk_origin[1] + text_attr->height)
          > extents->cap)
      {
         extents->cap = temp_extent;
      }

      if ((temp_extent = wk_origin[1] + text_attr->height +
           (text_attr->height * descent)) > extents->top)
      {
         extents->top = temp_extent;
      }

      *esc_seq_size = 9;
   }
   else if ((text_string[esc_seq_index] == 'J') ||
            (text_string[esc_seq_index] == 'j') ||
            (text_string[esc_seq_index] == 'H'))
   {
      *esc_seq_size = 9;
   }
   else if (text_string[esc_seq_index] == 'x')
   {
      /*
       * escape sequence defining scaling in x direction;
       * set the size of the escape sequence scale to a double
       */

      OM_BLOCK_MOVE(&text_string[esc_seq_index + 1],&d_hold,8);

      text_attr->width *= d_hold;

      *esc_seq_size = 9;
   }
   else if (text_string[esc_seq_index] == 'y')
   {
      /*
       * escape sequence defining scaling in y direction;
       * set the size of the escape sequence scale to a double
       */

      OM_BLOCK_MOVE(&text_string[esc_seq_index + 1],&d_hold,8);

      text_attr->height *= d_hold;

      /*
       *  since the y-scale has been changed, the vertical extents of
       *  the text string must be updated
       */

      if ((temp_extent = wk_origin[1] + text_attr->height +
                         text_attr->height * descent) > extents->top)
      {
         extents->top = temp_extent;
      }

      if ((temp_extent = wk_origin[1] + text_attr->height ) > extents->cap)
      {
         extents->cap = temp_extent;
      }

      if ((temp_extent = wk_origin[1] - (text_attr->height * descent)) < 
          extents->bottom)
      {
         extents->bottom = temp_extent;
      }

      *esc_seq_size = 9;
   }
   else if (text_string[esc_seq_index] == 's')
   {
      /*
       * escape sequence defining scaling in x and y direction;
       * set the size of the escape sequence scale to a double
       */

      OM_BLOCK_MOVE(&text_string[esc_seq_index + 1],&d_hold,8);

      text_attr->height *= d_hold;
      text_attr->width *= d_hold;

      /*
       *  since the y-scale has been changed, the vertical extents of
       *  the text string must be updated
       */

      if ((temp_extent = wk_origin[1] + text_attr->height +
                         text_attr->height * descent) > extents->top)
      {
         extents->top = temp_extent;
      }

      if ((temp_extent = wk_origin[1] + text_attr->height ) > extents->cap)
      {
         extents->cap = temp_extent;
      }

      if ((temp_extent = wk_origin[1] - (text_attr->height * descent)) < 
          extents->bottom)
      {
         extents->bottom = temp_extent;
      }

      *esc_seq_size = 9;
   }
   else if ((text_string[esc_seq_index] == 'f') ||
            ((text_string[esc_seq_index] == 'p') && 
             (text_string[esc_seq_index + 1] & POP_FONT)))
   {
      /*
       * escape sequence defining change font or change to previous font;
       * get the objid of the font manager using the named object directory
       */

      ex$get_cur_mod (id = &mod_id,
                      osnum = &mod_osnum);

      ex$get_super(mod_id = mod_id,
                   mod_osnum = mod_osnum,
                   super_name = FONTMGR_NO_NAME,
                   create = TRUE,
                   super_class = "GRfm",
                   super_id = &fontmgr_obj.objid,
                   super_osnum = &fontmgr_obj.osnum);

      if (text_string[esc_seq_index] == 'f')
      {
         /*
          * set the size of the escape sequence change font to a short
          */

         OM_BLOCK_MOVE(&text_string[esc_seq_index + 1],&s_hold,2);

         om$send(mode = OM_e_wrt_object,
                 msg = message GRfm.GRfm_retdata(msg,&s_hold,font_info),
                 senderid = NULL_OBJID,
                 targetid = fontmgr_obj.objid,
                 targetos = mod_osnum);

         *prev_font = text_attr->font;
         text_attr->font = s_hold;

         *esc_seq_size = 3;
      }
      else if (text_string[esc_seq_index] == 'p')
      {
         if (*prev_font != -1)
         {
            text_attr->font = *prev_font;

            om$send(mode = OM_e_wrt_object,
                    msg = message GRfm.GRfm_retdata(msg,&(text_attr->font),
                          font_info),
                    senderid = NULL_OBJID,
                    targetid = fontmgr_obj.objid,
                    targetos = mod_osnum);
         }

         *esc_seq_size = 2;
      }
   }
   else if (text_string[esc_seq_index] == 'F')
   {
      /*
       * escape sequence for set field; ignore (skip) it
       */

      *esc_seq_size = 3;
   }
   else if (text_string[esc_seq_index] == 'E')
   {
      /*
       * escape sequence for end field; ignore (skip) it
       */

      *esc_seq_size = 1;
   }
   else if (text_string[esc_seq_index] == 'w')
   {
      /*
       * escape sequence for change weight
       */

      disp_attr->weight = text_string[esc_seq_index + 1];

      *esc_seq_size = 2;
   }
   else if (text_string[esc_seq_index] == 'c')
   {
      /*
       * escape sequence for change color
       */

      OM_BLOCK_MOVE(&text_string[esc_seq_index + 1],&s_hold,2);
      disp_attr->color = s_hold;

      *esc_seq_size = 3;
   }
   else if (text_string[esc_seq_index] == 'C')
   {
      /*
       * escape sequence defining character spacing;
       * set the size of the escape sequence scale to a double
       */

      OM_BLOCK_MOVE(&text_string[esc_seq_index + 1],&d_hold,8);

      text_attr->char_spac = d_hold;

      *esc_seq_size = 9;
   }
   else if (text_string[esc_seq_index] == 'M')
   {
      /*
       * escape sequence for move to field reference point;
       * set the size of the horizontal escape sequence move to a double,
       * set the working origin, and update the ends of current line
       */

      OM_BLOCK_MOVE(&text_string[esc_seq_index + 3],&d_hold,8);

      wk_origin[0] += (text_attr->width * d_hold);

      if (wk_origin[0] > just_info->cur_line_right)
      {
         just_info->cur_line_right = wk_origin[0];
      }
      else if (wk_origin[0] < just_info->cur_line_left)
      {
         just_info->cur_line_left = wk_origin[0];
      }

      /* 
       * set the size of the vertical escape sequence move to a double
       * and set the working origin
       */
  
      OM_BLOCK_MOVE(&text_string[esc_seq_index + 11],&d_hold,8);

      wk_origin[1] += (text_attr->height * d_hold);

      /*
       *  calculate top, bottom, cap, and base extents
       */

      if ((temp_extent = wk_origin[1] - text_attr->height * descent) <
           extents->bottom)
      {
         extents->bottom = temp_extent;
      }

      if (wk_origin[1] < extents->base)
      {
         extents->base = wk_origin[1];
      }

      if ((temp_extent = wk_origin[1] + text_attr->height)
          > extents->cap)
      {
         extents->cap = temp_extent;
      }

      if ((temp_extent = wk_origin[1] + text_attr->height +
           (text_attr->height * descent)) > extents->top)
      {
         extents->top = temp_extent;
      }

      *esc_seq_size = 19;
   }
   else if (text_string[esc_seq_index] == 'm')
   {
      /*
       * escape sequence for justifying field;
       * set the size of the horizontal escape sequence move to a double,
       * set the working origin, and update the ends of current line
       */

      OM_BLOCK_MOVE(&text_string[esc_seq_index + 2],&d_hold,8);

      wk_origin[0] += (text_attr->width * d_hold);

      if (wk_origin[0] > just_info->cur_line_right)
      {
         just_info->cur_line_right = wk_origin[0];
      }
      else if (wk_origin[0] < just_info->cur_line_left)
      {
         just_info->cur_line_left = wk_origin[0];
      }

      /* 
       * set the size of the vertical escape sequence move to a double
       * and set the working origin
       */
  
      OM_BLOCK_MOVE(&text_string[esc_seq_index + 10],&d_hold,8);

      wk_origin[1] += (text_attr->height * d_hold);

      /*
       *  calculate top, bottom, cap, and base extents
       */

      if ((temp_extent = wk_origin[1] + text_attr->height + 
           text_attr->height * descent) > extents->top)
      {
         extents->top = temp_extent;
      }

      if ((temp_extent = wk_origin[1] + text_attr->height) > extents->cap)
      {
         extents->cap = temp_extent;
      }

      if (wk_origin[1] < extents->base)
      {
         extents->base = wk_origin[1];
      }

      if ((temp_extent = wk_origin[1] - text_attr->height * descent) < 
          extents->bottom)
      {
         extents->bottom = temp_extent;
      }
      *esc_seq_size = 18;
   }

   return(TRUE);
}
end implementation GRtext;
