/* #######################    APOGEE COMPILED   ######################## */

/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME  GRfld_ref_pt
 
     Abstract:  This routine returns the horizontal and vertical
                moves needed to move to a reference point of a field.
-----
%SC%

     VALUE =  GRfld_ref_pt(msg,text_string,text_length,field_num,font_info,
                           disp_attr,line_space,char_space,th,tw,font,just,
                           h_move,v_move)
-----
%EN%
 
     ON ENTRY:

        NAME         DATA TYPE                   DESCRIPTION
     ----------     ------------        -------------------------------
     text_string[]  IGRuchar            text string
     *text_length   IGRshort            length of text string
     *field_num     IGRshort            number of field
     *num_char      IGRshort            number of characters in text string
     *font_info     struct vfont_entry  font information
     *disp_attr     struct IGRdisplay   display attributes
     *line_space    IGRdouble           text's line spacing
     *char_space    IGRdouble           text's character spacing
     *th            IGRdouble           text height
     *tw            IGRdouble           text width
     *font          IGRshort            text's font
     *just          IGRchar             justification (0-14)
-----
%EX%

     ON EXIT:

        NAME         DATA TYPE                 DESCRIPTION
     ----------     ------------     -------------------------------------
     *msg           IGRlong          Completion code
                                          - MSSUCC if successful
                                          - MSFAIL (severe) if failure
     *h_move        IGRdouble        horizontal move
     *v_move        IGRdouble        vertical move

     VALUE (IGRboolean) = TRUE            - if successful
                          FALSE           - if failure
-----
%MD%

     MODULES INVOKED: FSGetTextVext
                      GResc_handler
                      GRfind_esc_char
                      GRfwd_beg_esc_seq
                      GRget_field_len
-----
%NB%

     NOTES:  
-----

%CH%
     CHANGE HISTORY:
        
        DEK  06/30/87 : Design date.
        DEK  07/01/87 : Creation date.
        DEK  11/30/87 : Updated for Font Server.
        DEK  05/04/88 : Font argument added to accomodate fractions.
        DEK  09/09/88 : Display attributes added.
        SCW  07/21/92 : Ansi conversion
        WBC  06/01/93 : Initialized members of the just_info struct to take
                        care of UMRs reported by Purify.
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------
     This routine returns the horizontal and vertical moves needed 
to move to a reference point of a field.

----*/
/*EH*/

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "gr.h"
#include "msdef.h"
#include "fontdef.h"
#include "font.h"
#include "igrdp.h"
#include "gotext.h"
#include "gotextdef.h"
#include "FS.h"
#include "FSOutl.h"
#include "OMprimitives.h"
#include "grimport.h"
#include "dpdef.h"

#ifdef NEVER_DEF
#include "dpgraphics.h"
#endif

IGRboolean GRfld_ref_pt(msg,text_string,text_length,field_num,font_info,
                        disp_attr,line_space,char_space,th,tw,font,just,
                        h_move,v_move)

IGRlong             *msg;              /* completion code                */
IGRuchar            *text_string;      /* entire text string             */
IGRshort            *text_length;      /* length of text string          */
IGRuchar            *field_num;        /* number of reference field      */
struct vfont_entry  *font_info;        /* font information               */
struct IGRdisplay   *disp_attr;        /* display attributes             */
IGRdouble           *line_space;       /* line spacing                   */
IGRdouble           *char_space;       /* character spacing              */
IGRdouble           *th;               /* text height                    */
IGRdouble           *tw;               /* text width                     */
IGRshort            *font;             /* font                           */
IGRchar             *just;             /* justification point of field   */
IGRdouble           *h_move;           /* horizontal move                */
IGRdouble           *v_move;           /* vertical move                  */
{
   extern IGRboolean GRtx_extents();
   extern IGRint     FSGetTextVect();
   extern IGRshort   GRfwd_beg_esc_seq();
   extern IGRboolean GRget_field_len();
   extern IGRshort   GRfind_esc_char();
   extern IGRboolean GRswap_bytes();
   extern IGRboolean GResc_handler();

   IGRshort          num_chars;        /* number of chars to search for  */
   IGRchar           esc_chars[1];     /* char to search for after ESC   */
   IGRuchar          *esc_nums[1];     /* field number to search for     */
   IGRshort          start_index;      /* position to start search       */
   IGRshort          beg_field;        /* position field starts          */
   IGRboolean        value;            /* functional return code         */
   IGRshort          i;                /* index counter                  */
   struct just_info  just_info;        /* justification information      */
   struct extents    field_extents;    /* extents of field               */
   struct extents    unjust_extents;   /* unjustified extents of string  */
   IGRdouble         rf_just_pt[2];    /* reference field just point     */
   IGRdouble         x_coord,y_coord;  /* x and y coordinates of the end
                                          of the text sub-string         */
   IGRshort          field_length;     /* length of reference field      */
   IGRuchar          *swapped_string;  /* pointer to 'swapped' chars     */
   struct IGRestx    text_attr;        /* text specific attributes       */
   IGRdouble         wk_origin[2];     /* working origin of text string  */
   IGRdouble         base_line;        /* base line of text string       */
   IGRshort          prev_font;        /* font previously used in string */
   IGRshort          current_font;     /* font at the current position   */
   struct vfont_entry loc_font_info;   /* font information               */
   struct IGRdisplay loc_disp_attr;    /* display attricutes             */

   /*
    * initialization
    */

   *msg = MSSUCC;
   value = TRUE;

   num_chars = 1;
   esc_chars[0] = 'F';               /* search for set field ESC sequence */
   esc_nums[0] = field_num;          /* with this field number            */
   start_index = 0;                  /* starting at beginning of string   */

   text_attr.font = *font;              /* current font */
   text_attr.just = *just;              /* current justification */
   text_attr.width = *tw;               /* current text width */
   text_attr.height = *th;              /* current text height */
   text_attr.char_spac = *char_space;   /* current character spacing */
   text_attr.line_spac = *line_space;   /* current line spacing */

   wk_origin[0] = 0.0;                  /* initialize working origin to zero */
   wk_origin[1] = 0.0;
   base_line = 0.0;

   prev_font = -1;                    /* no previous font */
   current_font = *font;
   loc_font_info = *font_info;        /* current font information */
   loc_disp_attr = *disp_attr;        /* current display attributes */

   /*
    * calculate the working origin of the beginning of the reference field;
    * first find the position in the string where the field begins
    */

   if (GRfwd_beg_esc_seq(msg,text_string,text_length,&num_chars,esc_chars,
                         esc_nums,&start_index,&prev_font,&current_font,
                         &loc_font_info,&beg_field))
   {
      /*
       * need to get the length of the field:
       */

      if (GRget_field_len(msg,text_string,text_length,&beg_field,prev_font,
                          current_font,loc_font_info.flags,&field_length))
      {
         GRtx_extents(msg,text_string,text_length,&loc_font_info,
                      &loc_disp_attr,text_attr.char_spac,
                      text_attr.line_spac,text_attr.width,
                      text_attr.height,text_attr.font,beg_field,
                      beg_field + field_length - 1,&field_extents);

         switch(*just)
         {
            case 0:                /* left bottom */

               rf_just_pt[0] = wk_origin[0] + field_extents.left;
               rf_just_pt[1] = wk_origin[1] + field_extents.bottom;
               break;

            case 1:                /* left base */

               rf_just_pt[0] = wk_origin[0] + field_extents.left;
               rf_just_pt[1] = wk_origin[1] + field_extents.base;
               break;

            case 2:                /* left center */

               rf_just_pt[0] = wk_origin[0] + field_extents.left;
               rf_just_pt[1] = wk_origin[1] + ((field_extents.bottom +
                               field_extents.top)/2);
               break;

            case 3:                /* left cap */

               rf_just_pt[0] = wk_origin[0] + field_extents.left;
               rf_just_pt[1] = wk_origin[1] +field_extents.cap;
               break;

            case 4:                /* left top */

               rf_just_pt[0] = wk_origin[0] + field_extents.left;
               rf_just_pt[1] = wk_origin[1] + field_extents.top;
               break;

            case 5:                /* center bottom */

               rf_just_pt[0] = wk_origin[0] + ((field_extents.left + 
                               field_extents.right)/2);
               rf_just_pt[1] = wk_origin[1] + field_extents.bottom;
               break;

            case 6:                /* center base */

               rf_just_pt[0] = wk_origin[0] + ((field_extents.left +
                               field_extents.right)/2);
               rf_just_pt[1] = wk_origin[1] + field_extents.base;
               break;

            case 7:                /* center center */

               rf_just_pt[0] = wk_origin[0] + ((field_extents.left + 
                               field_extents.right)/2);
               rf_just_pt[1] = wk_origin[1] + ((field_extents.bottom +
                               field_extents.top)/2);
               break;

            case 8:                /* center cap */

               rf_just_pt[0] = wk_origin[0] + ((field_extents.left +
                               field_extents.right)/2);
               rf_just_pt[1] = wk_origin[1] + field_extents.cap;
               break;

            case 9:                /* center top */

               rf_just_pt[0] = wk_origin[0] + ((field_extents.left + 
                               field_extents.right)/2);
               rf_just_pt[1] = wk_origin[1] + field_extents.top;
               break;

            case 10:               /* right bottom */

               rf_just_pt[0] = wk_origin[0] + field_extents.right;
               rf_just_pt[1] = wk_origin[1] + field_extents.bottom;
               break;

            case 11:               /* right base */

               rf_just_pt[0] = wk_origin[0] + field_extents.right;
               rf_just_pt[1] = wk_origin[1] + field_extents.base;
               break;

            case 12:               /* right center */

               rf_just_pt[0] = wk_origin[0] + field_extents.right;
               rf_just_pt[1] = wk_origin[1] + ((field_extents.top + 
                               field_extents.bottom)/2);
               break;

            case 13:               /* right cap */

               rf_just_pt[0] = wk_origin[0] + field_extents.right;
               rf_just_pt[1] = wk_origin[1] + field_extents.cap;
               break;

            case 14:               /* right top */

               rf_just_pt[0] = wk_origin[0] + field_extents.right;
               rf_just_pt[1] = wk_origin[1] + field_extents.top;
               break;

            default:

#ifdef DEBUG
               printf ("Invalid justification pairing.  GRjustfield.C ");
#endif
               break;
         }        /* end switch */

         i = beg_field;

         while (i < *text_length)
         {
            /*
             * find the number of consecutive non-escape characters
             */

            GRfind_esc_char(msg,&text_string[i],(IGRshort)*text_length - i,
                            loc_font_info.flags,&num_chars);

            if (num_chars)
            {
               if (!(loc_font_info.flags & SIXTEEN_BIT))
               {
                  /*
                   *  find the length of this text sub-string; update the
                   *  working origin of the text string according to the
                   *  sub-string length, text width, font body size and
                   *  character spacing
                   */
#ifdef NEVER_DEF
		{
		  Display	*display;
		  int		window;
		  GC		gc;

                  FSXGetTextVect(display,window,gc,loc_font_info.fontid,&(text_string[i]),
                               (IGRint)num_chars,0.0,0.0,&x_coord,&y_coord);
		}
#else
                  FSGetTextVect(loc_font_info.fontid,&(text_string[i]),
                               (IGRint)num_chars,0.0,0.0,&x_coord,&y_coord);
#endif
               }
               else       /* characters are sixteen bit */
               {
                  /* 
                   *  swap the bytes in the string that is send to Font
                   *  Server because it expects unsigned shorts if a
                   *  sixteen bit font
                   */

                  swapped_string = (IGRuchar *)om$malloc(size =(num_chars * 2));

                  GRswap_bytes(msg,&(text_string[i]),(num_chars * 2),
                               swapped_string);

                  /*
                   *  find the length of this text sub-string; update the 
                   *  working origin of the text string according to the 
                   *  sub-string length, text width, font body size and 
                   *  character spacing
                   */
#ifdef	NEVER_DEF
		{
		  Display	*display;
		  int		window;
		  GC		gc;

                  FSXGetTextVect(display,window,gc,loc_font_info.fontid,swapped_string,
                               (IGRint)num_chars,0.0,0.0,&x_coord,&y_coord);
		}
#else
                  FSGetTextVect(loc_font_info.fontid,swapped_string,
                               (IGRint)num_chars,0.0,0.0,&x_coord,&y_coord);
#endif

                  om$dealloc (ptr = swapped_string);
               }

               wk_origin[0] += (text_attr.width / (loc_font_info.bodysize
                                    - loc_font_info.descent) * x_coord) +
                                    (text_attr.width * (text_attr.char_spac -
                                    1.0) * (num_chars - 1));

               i += num_chars * (((loc_font_info.flags & SIXTEEN_BIT) >> 3) + 1);

               if (*msg == ESCAPE_TYPE)
               {
                   /*
                    * the last character in the sub-string is an escape (two
                    * consecutive escape chars); only the first one was
                    * included in num_chars since we only want the width of
                    * one, so we need to increment past the second escape char
                    */

                   ++i;
               }
            }
            else
            {
               /*
                * go process esc sequence, calculating working origin;
                * initializing the structures just_info and unjust extents
                * to take care of UMRs reported by Purify; the values returned
                * are relative to the beginning of the escape sequence that
                * is processed, i.e. the returned values are NOT relative to
                * the beginning of the text string
                */

               just_info.num_lines = 1;
               just_info.just_esc_pos = 0;
               just_info.cur_line_left = just_info.cur_line_right = 0.0;

               unjust_extents.right = unjust_extents.left = 0.0;
               unjust_extents.bottom = -(text_attr.height / 
                                        (loc_font_info.bodysize - loc_font_info.descent)) *
                                        loc_font_info.descent;
               unjust_extents.base = 0.0;
               unjust_extents.top = text_attr.height - unjust_extents.bottom;
               unjust_extents.cap = text_attr.height;

               GResc_handler(msg,text_string,i + 1,&text_attr,wk_origin,
                             &base_line,&loc_font_info,&prev_font,
                             &loc_disp_attr,&just_info,&unjust_extents,
                             &num_chars);

               i += num_chars + 1;
            }
         }                              /* end while i < *text_length */

         /*
          * kludge added for Patrice
          */

         if (*h_move != 0.001)
         {
            *h_move = rf_just_pt[0] - wk_origin[0];
            *h_move /= text_attr.width;
         }

         if (*v_move != 0.001)
         {
            *v_move = rf_just_pt[1] - wk_origin[1];
            *v_move /= text_attr.height;
         }
      }
      else                /* GRget_field_len failed */
      {
         *msg = MSFAIL;
         value = FALSE;
      }
   }
   else                 /* GRfwd_beg_field_seq couldn't find field */
   {
      *msg = MSFAIL;
      value = FALSE;
   }

   return(value);
}
