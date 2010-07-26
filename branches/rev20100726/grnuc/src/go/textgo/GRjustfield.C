/* #######################    APOGEE COMPILED   ######################## */

/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME  GRjust_field
 
     Abstract:  This routine returns the horizontal and vertical
                moves needed to justify a field.
-----
%SC%

     VALUE =  GRjust_field(msg,text_string,text_length,field_num,font_info,
                           disp_attr,line_space,char_space,th,tw,font,
                           h_move,v_move)
-----
%EN%
 
     ON ENTRY:

        NAME         DATA TYPE                   DESCRIPTION
     ----------     ------------     -----------------------------------
     text_string[]  IGRuchar         text string
     *text_length   IGRshort         length of text string
     *field_num     IGRshort         position of field in text string
     *num_char      IGRshort         number of characters in text string
     *font_info     struct vfont_entry  font information
     *disp_attr     struct IGRdisplay display attributes
     *line_space    IGRdouble        text's line spacing
     *char_space    IGRdouble        text's character spacing
     *th            IGRdouble        text height
     *tw            IGRdouble        text width
     *font          IGRshort         text's font
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE               DESCRIPTION
     ----------   ------------   -------------------------------------
     *msg         IGRlong         Completion code
                                    - MSSUCC if successful
                                    - MSFAIL (severe) if failure
     *h_move       IGRdouble        horizontal move
     *v_move       IGRdouble        vertical move

     VALUE (IGRboolean) = TRUE            - if successful
                          FALSE           - if failure
-----
%MD%

     MODULES INVOKED: FSGetTextVect
                      GResc_handler
                      GRfwd_beg_esc_seq
                      GRget_field_len
-----
%NB%

     NOTES:  
-----

%CH%
     CHANGE HISTORY:
        
        DEK  08/07/87 : Design date.
        DEK  08/11/87 : Creation date.
        DEK  12/16/87 : Updated for font server.
        DEK  05/04/88 : Added font to accomodate fractions.
        DEK  09/09/88 : Display attributes added.
        SCW  07/21/92 : Ansi conversion
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------
     This routine returns the horizontal and vertical moves needed 
to justify a field.

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

IGRboolean GRjust_field(msg,text_string,text_length,field_num,font_info,
                        disp_attr,line_space,char_space,th,tw,font,
                        h_move,v_move)

IGRlong             *msg;              /* completion code                */
IGRuchar            *text_string;      /* entire text string             */
IGRshort            *text_length;      /* length of text string          */
IGRuchar            *field_num;        /* number of field in string      */
struct vfont_entry  *font_info;        /* font information               */
struct IGRdisplay   *disp_attr;        /* display attributes             */
IGRdouble           *line_space;       /* line spacing                   */
IGRdouble           *char_space;       /* character spacing              */
IGRdouble           *th;               /* text height                    */
IGRdouble           *tw;               /* text width                     */
IGRshort            *font;             /* font                           */
IGRdouble           *h_move;           /* horizontal move                */
IGRdouble           *v_move;           /* vertical move                  */
{
   extern IGRboolean GRtx_extents();
   extern IGRint     FSGetTextVect();
   extern IGRshort   GRfwd_beg_esc_seq();
   extern IGRboolean GRget_field_len();
   extern IGRboolean GRswap_bytes();
   extern IGRboolean GResc_handler();

   IGRshort          num_chars;        /* number of chars to search for  */
   IGRchar           esc_chars[1];     /* char to search for after ESC   */
   IGRuchar          *esc_nums[1];     /* field number to search for     */
   IGRshort          start_index;      /* position to start search       */
   IGRshort          beg_field;        /* position ESC sequence starts   */
   IGRboolean        value;            /* functional return code         */
   struct extents    fld_extents;      /* extents of reference field     */
   IGRchar           which_extent;     /* justification pt of ref field  */
   IGRdouble         fld_just_pt[2];   /* reference field just point     */
                                       /*   of the text sub-string         */
   IGRshort          field_length;     /* length of reference field      */
   IGRchar           just;             /* justification to use in field  */
   struct IGRestx    text_attr;        /* text specific attributes       */
   IGRdouble         wk_origin[2];     /* working origin of text string  */
   IGRdouble         base_line;        /* base line of text string       */
   IGRshort          prev_font;        /* font previously used in string */
   IGRshort          current_font;
   struct vfont_entry loc_font_info;   /* font information               */
   struct IGRdisplay loc_disp_attr;    /* display attributes             */

   /*
    * initialization
    */

   *msg = MSSUCC;
   value = TRUE;

   num_chars = 1;
   esc_chars[0] = 'F';               /* search for set field ESC sequence */
   esc_nums[0] = field_num;          /* with this field number */
   start_index = 0;                  /* starting at beginning of string */

   text_attr.font = *font;              /* current font */
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
       * get the justification to make the field
       */

      just = text_string[beg_field + 6];

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
                      beg_field + field_length - 1,&fld_extents);

         which_extent = just % 15;

         switch(which_extent)
         {
            case 0:                /* left bottom */

               fld_just_pt[0] = wk_origin[0] + fld_extents.left;
               fld_just_pt[1] = wk_origin[1] + fld_extents.bottom;
               break;

            case 1:                /* left base */

               fld_just_pt[0] = wk_origin[0] + fld_extents.left;
               fld_just_pt[1] = wk_origin[1] + fld_extents.base;
               break;

            case 2:                /* left center */

               fld_just_pt[0] = wk_origin[0] + fld_extents.left;
               fld_just_pt[1] = wk_origin[1] + ((fld_extents.bottom + fld_extents.top)/2);
               break;

            case 3:                /* left cap */

               fld_just_pt[0] = wk_origin[0] + fld_extents.left;
               fld_just_pt[1] = wk_origin[1] +fld_extents.cap;
               break;

            case 4:                /* left top */

               fld_just_pt[0] = wk_origin[0] + fld_extents.left;
               fld_just_pt[1] = wk_origin[1] + fld_extents.top;
               break;

            case 5:                /* center bottom */

               fld_just_pt[0] = wk_origin[0] + ((fld_extents.left + fld_extents.right)/2);
               fld_just_pt[1] = wk_origin[1] + fld_extents.bottom;
               break;

            case 6:                /* center base */

               fld_just_pt[0] = wk_origin[0] + ((fld_extents.left + fld_extents.right)/2);
               fld_just_pt[1] = wk_origin[1] + fld_extents.base;
               break;

            case 7:                /* center center */

               fld_just_pt[0] = wk_origin[0] + ((fld_extents.left + fld_extents.right)/2);
               fld_just_pt[1] = wk_origin[1] + ((fld_extents.bottom + fld_extents.top)/2);
               break;

            case 8:                /* center cap */

               fld_just_pt[0] = wk_origin[0] + ((fld_extents.left + fld_extents.right)/2);
               fld_just_pt[1] = wk_origin[1] + fld_extents.cap;
               break;

            case 9:                /* center top */

               fld_just_pt[0] = wk_origin[0] + ((fld_extents.left + fld_extents.right)/2);
               fld_just_pt[1] = wk_origin[1] + fld_extents.top;
               break;

            case 10:               /* right bottom */

               fld_just_pt[0] = wk_origin[0] + fld_extents.right;
               fld_just_pt[1] = wk_origin[1] + fld_extents.bottom;
               break;

            case 11:               /* right base */

               fld_just_pt[0] = wk_origin[0] + fld_extents.right;
               fld_just_pt[1] = wk_origin[1] + fld_extents.base;
               break;

            case 12:               /* right center */

               fld_just_pt[0] = wk_origin[0] + fld_extents.right;
               fld_just_pt[1] = wk_origin[1] + ((fld_extents.top + fld_extents.bottom)/2);
               break;

            case 13:               /* right cap */

               fld_just_pt[0] = wk_origin[0] + fld_extents.right;
               fld_just_pt[1] = wk_origin[1] + fld_extents.cap;
               break;

            case 14:               /* right top */

               fld_just_pt[0] = wk_origin[0] + fld_extents.right;
               fld_just_pt[1] = wk_origin[1] + fld_extents.top;
               break;

            default:

#ifdef DEBUG
               printf ("Invalid justification.  GRjustfield.C ");
#endif
               break;
         }        /* end switch */

         *h_move = wk_origin[0] - fld_just_pt[0];
         *v_move = wk_origin[1] - fld_just_pt[1];

         *h_move /= text_attr.width;
         *v_move /= text_attr.height;
      }
      else               /* GRget_field_len failed */
      {
         *msg = MSFAIL;
         value = FALSE;
      }
   }
   else                 /* GRfwd_beg_esc_seq couldn't find field */
   {
      *msg = MSFAIL;
      value = FALSE;
   }

   return(value);
}
