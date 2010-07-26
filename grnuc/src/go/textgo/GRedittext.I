/* #######################    APOGEE COMPILED   ######################## */

/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME: GRedit_text
 
     Abstract: 
        This routine edits a text string. The arrow keys
        will move up, down, and along the text string.
        The delete key will delete the previous character
        while other keys will insert the character at the
        current position in the string. The length of the
        text string will be updated.
-----
%SC%

     VALUE =  GRedit_text(msg,init_edit,keyin,keyin_nbytes,text_string,tx_attr,
                          text_buf_size,font_info,disp_attr,num_lines,
                          cc_info,text_info,ele_header,erase_mode,
                          display_mode,view_ind)
-----
%EN%
 
     ON ENTRY:

        NAME         DATA TYPE                   DESCRIPTION
     ----------   ---------------    -----------------------------------
     *msg            IGRlong         completion code
     init_edit       IGRint          TRUE if first time calling edit
                                     text for this text string
     *keyin          IGRuchar        keyin chars
     keyin_nbytes    IGRint          number of bytes in the keyin
     **text_string   IGRuchar        text string to edit
     *tx_attr        struct IGRestx  text string's text attributes
     *text_buf_size  IGRshort        # bytes memory allocated for the string
     *font_info      struct vfont_entry  font information
     *disp_attr      struct IGRdisplay display attributes
     *num_lines      IGRshort        number of lines in the text string
     *cc_info        struct GRcc_info info about the cur char in text string
     *text_info      struct IGResintx text specific information
     *ele_header     struct DPele_header info necessary to display the text
     erase_mode      enum GRdpmode   mode with which to erase the text
     display_mode    enum GRdpmode   mode with which to display the text
     view_ind        IGRint          TRUE if the text string is view
                                     independent, FALSE otherwise
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE                      DESCRIPTION
     ----------   ------------   -----------------------------------
     **text_string  IGRuchar         text string to edit
     *text_buf_size IGRshort         # bytes memory allocated for the string
     *num_lines     IGRshort         number of lines in the text string
     *cc_info       struct GRcc_info info about the cur char in text string

     VALUE (IGRboolean) = TRUE            - if successful
                          FALSE           - if failure
-----
%MD%

     MODULES INVOKED: 

-----
%NB%

     NOTES:  User position is the position in line that the user
             will see; i.e. escape sequences are not included in
             its count. However, the linefeed will be counted as
             a position.
-----

%CH%
     CHANGE HISTORY:
        
        DEK  08/13/86 : Design date.
        DEK  08/20/86 : Creation date.
        DEK  07/16/87 : Added capability for field reference point
                        moves.
        WBC  07/14/88 : Converted to a function.
        DEK  10/03/88 : Added sixteen bit capability.
        SCW  07/21/92 : Ansi conversion
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------
   This routine edits a text string. The arrow keys will move up,
down, and along the text string.  The delete key will delete the
previous character while other keys will insert the character at the
current position in the string. The length of the text string will
be updated.
----*/
/*EH*/

class implementation GRtext;

#include "grimport.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "gr.h"
#include "msdef.h"
#include "msmacros.h"
#include "grmessage.h"
#include "fontdef.h"
#include "font.h"
#include "gotextdef.h"
#include "gotext.h"
#include "OMmacros.h"
#include "OMprimitives.h"
#include "igrdef.h"
#include "dpdef.h"
#include "dp.h"
#include "dpmacros.h"
#include "grdpbmacros.h"
#include "exdef.h"
#include "ex.h"
#include "exmacros.h"
#include "fontdef.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "griodef.h"
#include "grio.h"
#include "griomacros.h"

#define DOWN_ARROW    EX_DOWN_ARROW
#define UP_ARROW      EX_UP_ARROW
#define RIGHT_ARROW   EX_RIGHT_ARROW
#define LEFT_ARROW    EX_LEFT_ARROW
#define INSERT_FONT   0x9            /* control i: insert font change */
#define NUM_IN_LF     2
#define UP_MOVE       0x1
#define DOWN_MOVE     0x2

from GRfm import GRfm_retdata;

IGRboolean GRedit_text(msg,init_edit,keyin,keyin_nbytes,text_string,tx_attr,
                       text_buf_size,font_info,disp_attr,num_lines,
                       cc_info,text_info,ele_header,erase_mode,
                       display_mode,view_ind)

IGRlong          *msg;             /* informational message                  */
IGRint           init_edit;        /* TRUE if first time calling edit text   */
                                   /* for this text string                   */
IGRuchar         *keyin;           /* keyin chars                            */
IGRint           keyin_nbytes;     /* number of bytes in the keyin           */
IGRuchar         **text_string;    /* text string to edit                    */
struct IGRestx   *tx_attr;         /* text string's text attributes          */
IGRshort         *text_buf_size;   /* # bytes memory allocated for the string*/
struct vfont_entry *font_info;     /* font information                       */
struct IGRdisplay *disp_attr;      /* display attributes                     */
IGRshort         *num_lines;       /* number of lines in the text string     */
struct GRcc_info *cc_info;         /* info about the cur char in text string */
struct IGResintx *text_info;       /* text specific information              */
struct DPele_header *ele_header;   /* info necessary to display the text     */
enum GRdpmode    erase_mode;       /* mode with which to erase the text      */
enum GRdpmode    display_mode;     /* mode with which to display the text    */
IGRint           view_ind;         /* TRUE if the text string is view        */
                                   /* independent, FALSE otherwise           */

{
   extern   IGRshort        GRfwd_esc_seq();
   extern   IGRshort        GRfwd_beg_esc_seq();
   extern   IGRshort        GRbwd_beg_esc_seq();
   extern   IGRboolean      GRbwd_del_char();

   static   IGRuchar         frac_chars[10];
   static   IGRboolean  fraction_flag = FALSE; /* TRUE if entering fraction */
   static   IGRboolean  end_fraction = FALSE;  /* TRUE if fraction finished */
   static   IGRshort    frac_index = 0;
   static   struct GRid      fontmgr_obj;      /* font manager object       */
   static   enum font_type   active_font_type;
   static   IGRshort         active_font;
   static   IGRshort         active_ascii_font;

   struct   GRdpb_text_symb text_symb;     /* text symbology            */
   struct   extents         text_extents;  /* justified extents of text */
   struct   IGRestx         cur_text_attr; /* current text attributes   */
   struct   vfont_entry     temp_font_info;/* font information          */
   struct   vfont_entry     save_font_info;/* font information          */
   struct   IGRdisplay      cur_disp_attr; /* current display attributes*/
   OM_S_OBJID               mod_id;        /* current module id         */
   OMuword                  mod_osnum;     /* current module os number  */
   IGRpoint                 view_ind_point;/* point view independ about */
   IGRchar                  esc_chars[2];
   IGRuchar                 *temp_keyin;
   IGRuchar                 fraction[10];/* string containing fraction code */
   IGRboolean  char_type;
   IGRboolean  overwrite_char;
   IGRboolean  delete_fraction;
   IGRboolean  status;
   IGRshort    current_font, prev_font, init_font, prev_font2;
   IGRshort    i, cc_index, num_chars, num_chars_delete;
   IGRshort    edt_char_index;       /* actual position of an editable */
                                     /* character                      */
   IGRshort    temp_index, esc_index, del_char_index;
   IGRshort    temp_line_num;
   IGRshort    temp_user_pos;
   IGRshort    *positions[4];        /* positions in the text string to*/
                                     /* update during the text string's*/
                                     /* justification                  */
   IGRshort    erase_index;          /* index to begin erasing         */
   IGRshort    chars_eol;            /* # chars from current char to   */
                                     /* to the end of the line         */
   IGRshort    tmp_short;
   unsigned short erase_flags;
   IGRint      num_positions;        /* # of positions to update       */
   IGRint      erase_from;           /* description of where to erase  */
                                     /* from                           */
   IGRint      erase_to;             /* description of where to erase  */
                                     /* to                             */
   IGRint      field_type;           /* type of field currently in     */
   IGRint      view_ind_type;        /* type of view independence      */
   IGRint      lf_mask;              /* if char_type is INSERT_LF or   */
                                     /* DELETE_LF, indicates if the    */
                                     /* linefeed (or vertical move) is */
                                     /* up, down or both:              */
                                     /* - UP_MOVE: a linefeed with a   */
                                     /* negative line spacing or a non-*/
                                     /* negative vertical move         */
                                     /* - DOWN_MOVE: a linefeed with a */
                                     /* non- negativeline spacing or a */
                                     /* negative vertical move         */
   IGRint      font_flags;
   IGRlong     temp_msg;
   IGRlong     nbytes_in_buffer, nbytes_transferred;
   IGRdouble   h_move, v_move, esc_value;
   IGRdouble   kern_value;
   IGRboolean  seven_sixteen_mix;    /* true if putting 7 bit char in 16
                                        bit part of string, or vice versa */

   status = TRUE;
   *msg = MSSUCC;
   seven_sixteen_mix = FALSE;
   i = 0;
   temp_keyin = NULL;
   ele_header->dis_att = &cur_disp_attr;
   view_ind_type = 0;
   lf_mask = 0;

   /*
    * if this is the initial callto edit text for this text string, must
    * initialize fraction_flag to FALSE and frac_index to zero since
    * fraction_flag may have been set when editting a previous text string
    */

   if (init_edit)
   {
      fraction_flag = FALSE;
      frac_index = 0;

      ex$message (in_buff = "",
                  field = KEYIN_FIELD);

      nbytes_in_buffer = sizeof(text_symb);

      gr$get_text_symb(msg = msg,
                       sizbuf = &nbytes_in_buffer,
                       buffer = &text_symb,
                       nret = &nbytes_transferred);

      ex$get_cur_mod(id = &mod_id,
                     osnum = &mod_osnum);

      ex$get_super(mod_id = mod_id,
                   mod_osnum = mod_osnum,
                   super_name = FONTMGR_NO_NAME,
                   create = TRUE,
                   super_class = "GRfm",
                   super_id = &fontmgr_obj.objid,
                   super_osnum = &fontmgr_obj.osnum);

      om$send(mode = OM_e_wrt_object,
              msg = message GRfm.GRfm_retdata
                    (msg,&text_symb.Active_font,&temp_font_info),
              senderid = NULL_OBJID,
              targetid = fontmgr_obj.objid,
              targetos = fontmgr_obj.osnum);

      active_font = text_symb.Active_font;
      active_ascii_font = text_symb.Active_ascii_font;

      if (temp_font_info.flags & SIXTEEN_BIT)
      {
         active_font_type = sixteen;
      }
      else if (temp_font_info.flags & EIGHT_BIT)
      {
         active_font_type = eight;
      }
      else
      {
         active_font_type = seven;
      }
   }

   /*
    *  process the keyin in sections of the following types: insert chars,
    *  delete chars and movement chars
    */

   while (i < keyin_nbytes)
   {
      /*
       * if fraction_flag is TRUE, the keyin chars indicate what fraction
       * to place
       */

      if (fraction_flag)
      {
         if (keyin[i] > 0x2e && keyin[i] < 0x3a)
         {
            /*
             * the current char is either a number or a slash (/);
             * save the char in the fraction buffer and display the
             * contents of the buffer in the keyin field
             */

            frac_chars[frac_index] = keyin[i];
            ++frac_index;
            frac_chars[frac_index] = '\0';

            ex$message (in_buff = (IGRchar *)frac_chars,
                        field = KEYIN_FIELD);

            ++i; 
         }
         else if (keyin[i] == DEL)
         {
            /*
             * if any chars are in the frac_chars buffer, delete the
             * last char in the buffer and redisplay the contents of
             * the buffer in the keyin field
             */

            if (frac_index)
            {
               --frac_index;
               frac_chars[frac_index] = '\0';

               ex$message (in_buff = (IGRchar *)frac_chars,
                           field = KEYIN_FIELD);
            }
            else  /* end fraction mode */
            {
               fraction_flag = FALSE;

               ex$message(msgnumb = GR_P_EdtTxt,
                          field = PROMPT_FIELD);
            }

            ++i; 
         }
         else       /* nonnumeric character ends fraction */
         {
            fraction_flag = FALSE;
            frac_index = 0;

            ex$message (in_buff = "",
                        field = KEYIN_FIELD);

            ex$message(msgnumb = GR_P_EdtTxt,
                       field = PROMPT_FIELD);

            GRgen_fraction(&temp_msg,frac_chars,fraction,&num_chars);

            if (temp_msg & 1)
            {
               /*
                * the specified fraction is defined in the fraction
                * font; insert the change font and pop font escape
                * sequences into the text string at the current position
                * and update the current char information structure
                */

               end_fraction = TRUE;

               /*
                * check to see if the text buffer size is within TEXT_BUF_SIZE
                * of exceeding the maximum number of characters currently
                * allowed in a text string, which is limited to a signed
                * short's greatest positive number
                */

               tmp_short = *text_buf_size + TEXT_BUF_SIZE;

               if (tmp_short >= 0)
               {
                  tx_attr->text_length += 7;

                  /*
                   *  may have to enlarge the text buffer if it isn't
                   *  large enough to hold the chars to be inserted
                   */

                  if (tx_attr->text_length > *text_buf_size)
                  {
                     *text_buf_size += TEXT_BUF_SIZE;

                     *text_string = (IGRuchar *)om$realloc(
                                               ptr = (IGRchar *) *text_string,
                                               size = (OMuint)*text_buf_size);
                  }
               }
               else
               {
                  status = FALSE;
                  *msg = MSFAIL;
                  goto FINISH;
               }

               OM_BLOCK_MOVE(&((*text_string)[cc_info->cur_char_index]),
                             &((*text_string)[cc_info->cur_char_index + 7]),
                             (IGRint)(tx_attr->text_length - cc_info->cur_char_index - 7));

               OM_BLOCK_MOVE(fraction,
                             &((*text_string)[cc_info->cur_char_index]),
                             4);
               OM_BLOCK_MOVE(&fraction[5],
                             &((*text_string)[cc_info->cur_char_index + 4]),
                             3);

               /*
                * increment the current char info to the position between
                * the change font and pop font escape sequences - the
                * position to insert the fraction char code
                */

               cc_index = cc_info->cur_char_index + 4;

               GRchar_pos_info(&temp_msg,*text_string,cc_index,
                               TRUE,tx_attr,font_info,disp_attr,cc_info);

               /*
                * create a new keyin buffer that contains the
                * specified fraction code and the remaining chars
                * in the original keyin buffer
                */

               keyin_nbytes -= i; /* # chars left in keyin */

               temp_keyin = (IGRuchar *)om$malloc(
                                         size = (OMuint)(1 + keyin_nbytes));

               temp_keyin[0] = fraction[4];

               OM_BLOCK_MOVE(&keyin[i],&temp_keyin[1],
                             (IGRint)(keyin_nbytes));

               ++keyin_nbytes; /* total # chars in keyin */
               keyin = temp_keyin;
               i = 0;  /* index from beginning of new keyin buffer */
            }
            else  /* specified fraction not defined in fraction font */
            {
               /*
                * create a new keyin buffer that contains the
                * specified fraction and the remaining chars in the
                * original keyin buffer
                */

               keyin_nbytes -= i; /* # chars left in keyin */

               temp_keyin = (IGRuchar *)om$malloc(
                                    size = (OMuint)(num_chars + keyin_nbytes));

               OM_BLOCK_MOVE(fraction,temp_keyin,(IGRint)num_chars);
               OM_BLOCK_MOVE(&keyin[i],&temp_keyin[num_chars],
                             (IGRint)(keyin_nbytes));

               keyin_nbytes += num_chars; /* total # chars in keyin */
               keyin = temp_keyin;
               i = 0;  /* index from beginning of new keyin buffer */
            }
         }
      }
      else  /* not inserting fraction input */
      {
         switch (keyin[i])
         {
            case DOWN_ARROW:

               /*
                * note: if on the last line cannot move down
                */

               if (cc_info->cur_line != *num_lines) /* not on last line */
               {
                  temp_line_num = cc_info->cur_line + 1;
                  temp_user_pos = cc_info->cur_user_pos;

                  GRline_user_position(&temp_msg,*text_string,
                                       tx_attr->text_length,FALSE,
                                       cc_info->cur_line,
                                       cc_info->cur_user_pos,
                                       cc_info->cur_char_index,
                                       font_info->flags,
                                       cc_info->font_info.flags,
                                       cc_info->prev_font,
                                       cc_info->text_attr.font,
                                       &temp_line_num,
                                       &temp_user_pos,
                                       &temp_index);

                  GRchar_pos_info(&temp_msg,*text_string,temp_index,
                                  TRUE,tx_attr,font_info,disp_attr,
                                  cc_info);

               }                            /* end if not on last line */
               i++;

               break;

            case UP_ARROW:

               /*
                * note: if on the first line cannot move up
                */

               if (cc_info->cur_line != 1)      /* not on first line */
               {
                  temp_line_num = cc_info->cur_line - 1;
                  temp_user_pos = cc_info->cur_user_pos;

                  GRline_user_position(&temp_msg,*text_string,
                                       tx_attr->text_length,TRUE,
                                       1,1,0,
                                       font_info->flags,
                                       font_info->flags,
                                       tx_attr->font,
                                       tx_attr->font,
                                       &temp_line_num,
                                       &temp_user_pos,
                                       &temp_index);

                  GRchar_pos_info(&temp_msg,*text_string,temp_index,
                                  FALSE,tx_attr,font_info,disp_attr,
                                  cc_info);
               }
               i++;

               break;

            case RIGHT_ARROW:

               if (cc_info->cur_char_index < tx_attr->text_length)
               {
                  prev_font = cc_info->prev_font;
                  current_font = cc_info->text_attr.font;
                  font_flags = cc_info->font_info.flags;

                  GRfwd_cursor_position(&temp_msg,*text_string,
                                        tx_attr->text_length,
                                        cc_info->cur_char_index,
                                        &prev_font,
                                        &current_font,
                                        &font_flags,
                                        &temp_index);

                  GRchar_pos_info(&temp_msg,*text_string,temp_index,
                                  TRUE,tx_attr,font_info,disp_attr,
                                  cc_info);
               }
               i++;

               break;

            case LEFT_ARROW:

               if (cc_info->cur_char_index)
               {
                  temp_index = 0;

                  GRvalid_cursor_position(&temp_msg,*text_string,
                                          tx_attr->text_length,
                                          prev_font,tx_attr->font,
                                          font_info->flags,
                                          cc_info->cur_char_index - 1,
                                          &temp_index);

                  GRchar_pos_info(&temp_msg,*text_string,temp_index,
                                  FALSE,tx_attr,font_info,disp_attr,
                                  cc_info);
               }
               i++;

               break;

            case DEL:

               /*
                *  searching backward from cc_info->cur_char_index, find
                *  character to delete; if none is found, can't delete
                */

               init_font = tx_attr->font;
               save_font_info = *font_info;
               prev_font2 = tx_attr->font;

               if (GRbwd_del_char(&temp_msg,*text_string,
                                  &cc_info->cur_char_index,&init_font,
                                  &save_font_info,&prev_font2,&del_char_index))
               {
                  ex$get_cur_mod(id = &mod_id,
                                 osnum = &mod_osnum);

                  /*
                   * if the text is view independent, must initialize
                   * info for display
                   */

                  if (view_ind)
                  {
                     view_ind_type = ROTATION_IND;
                     view_ind_point[0] = ele_header->geometry.lbsys->matrix[3];
                     view_ind_point[1] = ele_header->geometry.lbsys->matrix[7];
                     view_ind_point[2] = ele_header->geometry.lbsys->matrix[11];
                  }

                  /*
                   * if the char(s) being deleted are in a field that is
                   * justified or is followed by a move to field
                   * reference point escape sequence, a flag must be set
                   * to indicate this so special actions can be taken
                   * to erase, justify and display the text string
                   */

                  field_type = NO_FLD;

                  if (cc_info->field_delim)  /* currently in a field */
                  {
                     if (cc_info->flags & FIXED_LENGTH_FIELD)
                     {
                        field_type |= FIXED_LENGTH_FLD;
                     }

                     if (cc_info->flags & JUSTIFIED_FIELD)
                     {
                        field_type |= JUSTIFIED_FLD;
                     }
                  }
                  else  /* not currently in a field */
                  {
                     /*
                      * if a justified field or a move to field
                      * reference point is on the same line as and
                      * follows the char to be deleted, set the
                      * field_type flag accordingly
                      */

                     num_chars = 1;
                     esc_chars[0] = 'M';
                     prev_font = cc_info->prev_font;
                     current_font = cc_info->text_attr.font;
                     temp_font_info = cc_info->font_info;

                     if (GRfwd_beg_esc_seq(&temp_msg,*text_string,
                                           &tx_attr->text_length,
                                           &num_chars,esc_chars,NULL,
                                           &cc_info->cur_char_index,
                                           &prev_font,&current_font,
                                           &temp_font_info,&esc_index))
                     {
                        field_type |= MV_REF_PT_FLD;
                     }

                     num_chars = 2;
                     esc_chars[0] = 'm';
                     esc_chars[1] = LINEFEED;

                     if (GRfwd_beg_esc_seq(&temp_msg,*text_string,
                                           &tx_attr->text_length,
                                           &num_chars,esc_chars,NULL,
                                           &cc_info->cur_char_index,
                                           &prev_font,&current_font,
                                           &temp_font_info,&esc_index))
                     {
                        if ((*text_string)[esc_index + 1] == 'm')
                        {
                           field_type |= JUSTIFIED_FLD;
                        }
                     }
                  }

                  text_info->font_id = mod_osnum;
                  text_info->estx = &cur_text_attr;

                  /*
                   * determine if a fraction is being deleted; if a pop
                   * font esc seq immediately follows the char being
                   * deleted and a change font (fraction) esc seq
                   * immediately precedes the char being deleted,
                   * the char being deleted is a fraction
                   */

                  delete_fraction = FALSE;

                  if ((save_font_info.flags & FRACTION_FONT) &&
                      (del_char_index + 3 < tx_attr->text_length) &&
                      ((*text_string)[del_char_index + 1] == ESC) &&
                      ((*text_string)[del_char_index + 2] == 'p') &&
                      ((*text_string)[del_char_index + 3] & POP_FONT))
                  {
                     num_chars = 1;
                     esc_chars[0] = 'f';

                     if (GRbwd_beg_esc_seq(&temp_msg,*text_string,&num_chars,
                                           esc_chars,NULL,&del_char_index,
                                           font_info->flags,&temp_index) &&
                         (temp_index + 4 == del_char_index))
                     {
                        delete_fraction = TRUE;
                     }
                  }

                  if (delete_fraction)
                  {
                     char_type = DELETE_CHAR;

                     /*
                      * need to delete the change font escape sequence,
                      * the fraction char code and the pop font escape
                      * sequence; must decrement the del_char_index to
                      * the beginning of the change font escape sequence
                      */

                     num_chars_delete = 8;
                     del_char_index -= 4;

                     /*
                      * if the current char index is within the chars to
                      * deleted (on the pop font esc seq), increment it
                      * past the pop font esc seq since the current char
                      * index will be decremented by the number of chars
                      * deleted
                      */

                     if (cc_info->cur_char_index < del_char_index + 7)
                     {
                        cc_info->cur_char_index += 2;
                     }
                  }
                  else if (((*text_string)[del_char_index] == ESC) &&
                           ((*text_string)[del_char_index + 1] == LINEFEED))
                  {
                     /*
                      * find out the number of bytes to delete; if
                      * deleting only a linefeed delete 2 bytes; if also
                      * deleting a linefeed justification move delete 12
                      * bytes
                      */

                     if ((tx_attr->text_length > del_char_index + 11) &&
                         ((*text_string)[del_char_index + 2] == ESC) &&
                         ((*text_string)[del_char_index + 3] == 'H'))
                     {
                        num_chars_delete = 12;
                     }
                     else
                     {
                        num_chars_delete = 2;
                     }

                     --(*num_lines);

                     char_type = DELETE_LF;
                     lf_mask = (tx_attr->line_spac >= 0 ? DOWN_MOVE : UP_MOVE);

                     /*
                      * if there is a vertical move from the linefeed to delete
                      * to the end of the text string, must find out if the
                      * vertical move goes up or down
                      */

                     num_chars = 1;
                     esc_chars[0] = 'v';
                     temp_index = del_char_index + num_chars_delete;

                     while (GRfwd_beg_esc_seq(&temp_msg,*text_string,
                                              &tx_attr->text_length,
                                              &num_chars,esc_chars,NULL,
                                              &temp_index,&prev_font2,
                                              &init_font,&save_font_info,
                                              &esc_index))
                     {
                        OM_BLOCK_MOVE(&((*text_string)[esc_index + 2]),
                                      &esc_value,8);

                        if (esc_value >= 0)
                        {
                           lf_mask |= UP_MOVE;
                        }
                        else
                        {
                           lf_mask |= DOWN_MOVE;
                        }

                        temp_index = esc_index + 10;
                     }
                  }
                  else   /* delete displayable char */
                  {
                     char_type = DELETE_CHAR;

                     /*
                      * find out the number of bytes to delete; if
                      * deleting an escape char or sixteen bit char
                      * delete 2 bytes, otherwise delete 1 byte
                      */

                     if (((*text_string)[del_char_index] == ESC) ||
                         (save_font_info.flags & SIXTEEN_BIT))
                     {
                        num_chars_delete = 2;
                     }
                     else
                     {
                        num_chars_delete = 1;
                     }
                  }

                  /*
                   * find the text sub-string to erase
                   */

                  GRerase_chars(&temp_msg,*text_string,tx_attr,font_info,
                                disp_attr,char_type,lf_mask,
                                field_type,&del_char_index,cc_info,
                                text_info,&cur_disp_attr,&erase_from,
                                &erase_to,&erase_index,&chars_eol,
                                &erase_flags,&kern_value);

                  /*
                   * erase the specified portion of the text string
                   */

                  dp$display(msg = &temp_msg,
                             osnum = mod_osnum,
                             mode = erase_mode,
                             buffer = ele_header,
                             view_ind = view_ind,
                             view_ind_type = view_ind_type,
                             view_ind_point = view_ind_point);

                  /*
                   *  overwrite the char(s) to be deleted
                   */

                  tx_attr->text_length -= num_chars_delete;

                  OM_BLOCK_MOVE(&((*text_string)[del_char_index + num_chars_delete]),
                                &((*text_string)[del_char_index]),
                                (IGRint)(tx_attr->text_length - del_char_index));

                  cc_info->cur_char_index -= num_chars_delete;

                  /*
                   * if currently nested in a fixed length field, must
                   * insert a blank char at the end of the current field
                   * to replace the deleted char
                   */

                  if (cc_info->flags & FIXED_LENGTH_FIELD)
                  {
                     /*
                      * find the length of the current field in order to
                      * calculate the index of the end field escape
                      * sequence of the current field
                      */

                     GRget_field_len(&temp_msg,*text_string,
                                     &tx_attr->text_length,
                                     &cc_info->field_position,prev_font,
                                     current_font,save_font_info.flags,
                                     &esc_index);

                     temp_index = cc_info->field_position + esc_index;

                     /*
                      * insert a blank char immediately before the
                      * current field's end field escape sequence;
                      * number of chars to the end of the line must be
                      * incremented by the number of chars inserted
                      */

                     /*
                      * check to see if the text buffer size is within
                      * TEXT_BUF_SIZE of exceeding the maximum number of
                      * characters currently allowed in a text string, which
                      * is limited to a signed short's greatest positive number
                      */

                     tmp_short = *text_buf_size + TEXT_BUF_SIZE;

                     if (tmp_short >= 0)
                     {
                        ++(tx_attr->text_length);
                        ++chars_eol;

                        /*
                         *  may have to enlarge the text buffer if it isn't
                         *  large enough to hold the char to be inserted
                         */

                        if (tx_attr->text_length > *text_buf_size)
                        {
                           *text_buf_size += TEXT_BUF_SIZE;

                           *text_string = (IGRuchar *)om$realloc(
                                            ptr = (IGRchar *) *text_string,
                                            size = (OMuint)*text_buf_size);
                        }
                     }
                     else
                     {
                        status = FALSE;
                        *msg = MSFAIL;
                        goto FINISH;
                     }

                     OM_BLOCK_MOVE(&((*text_string)[temp_index]),
                                   &((*text_string)[temp_index + 1]),
                                   (IGRint)(tx_attr->text_length - temp_index - 1));

                     (*text_string)[temp_index] = BLANK;
                  }

                  /*
                   *  must update the text string's justification moves
                   */

                  text_symb.Active_font = tx_attr->font;
                  text_symb.Active_just = tx_attr->just;
                  text_symb.Active_width = tx_attr->width;
                  text_symb.Active_height = tx_attr->height;
                  text_symb.Active_charspac = tx_attr->char_spac;
                  text_symb.Active_linespac = tx_attr->line_spac;

                  /*
                   * if inserting chars into a field that is followed by
                   * a move to field reference point escape sequence or
                   * is a justified field, need to update the appropriate
                   * justification moves
                   */

                  if (field_type & MV_REF_PT_FLD)
                  {
                     /*
                      * search for any move to field reference point esc
                      * seq following the current field and update the
                      * vertical and horizontal moves
                      */

                     num_chars = 1;
                     esc_chars[0] = 'M';
                     temp_index = cc_info->cur_char_index;
                     prev_font = cc_info->prev_font;
                     current_font = cc_info->text_attr.font;
                     temp_font_info = cc_info->font_info;

                     while (GRfwd_beg_esc_seq(&temp_msg,*text_string,
                                              &tx_attr->text_length,&num_chars,
                                              esc_chars,NULL,&temp_index,
                                              &prev_font,&current_font,
                                              &temp_font_info,&esc_index))
                     {
                        OM_BLOCK_MOVE(&((*text_string)[esc_index + 4]),&h_move,8);
                        OM_BLOCK_MOVE(&((*text_string)[esc_index + 12]),&v_move,8);

                        GRfld_ref_pt(&temp_msg,*text_string,
                                     &esc_index,
                                     &((*text_string)[esc_index + 2]),
                                     font_info,disp_attr,
                                     &text_symb.Active_linespac,
                                     &text_symb.Active_charspac,
                                     &text_symb.Active_height,
                                     &text_symb.Active_width,
                                     &text_symb.Active_font,
                                     &((*text_string)[esc_index + 3]),
                                     &h_move,&v_move);

                        OM_BLOCK_MOVE(&h_move,&((*text_string)[esc_index + 4]),8);
                        OM_BLOCK_MOVE(&v_move,&((*text_string)[esc_index + 12]),8);
                        temp_index = esc_index + 20;  /* skip past escape sequence */
                     }
                  }  /* end "if (field_type & MV_REF_PT_FLD)" */

                  if (field_type & JUSTIFIED_FLD)
                  {
                     /*
                      * beginning at the current field and moving back to
                      * the outer most field the current field is nested in,
                      * update any justified field
                      */

                     num_chars = 1;
                     esc_chars[0] = 'm';
                     temp_index = cc_info->cur_char_index;

                     while (GRbwd_beg_esc_seq(msg,*text_string,&num_chars,
                                              esc_chars,NULL,&temp_index,
                                              font_info->flags,&esc_index))
                     {
                        esc_value = 0.0;

                        OM_BLOCK_MOVE(&esc_value,&((*text_string)[esc_index + 3]),8);
                        OM_BLOCK_MOVE(&esc_value,&((*text_string)[esc_index + 11]),8);

                        GRjust_field(&temp_msg,*text_string,
                                     &tx_attr->text_length,
                                     &((*text_string)[esc_index - 2]),
                                     font_info,disp_attr,
                                     &text_symb.Active_linespac,
                                     &text_symb.Active_charspac,
                                     &text_symb.Active_height,
                                     &text_symb.Active_width,
                                     &text_symb.Active_font,
                                     &h_move,&v_move);


                        OM_BLOCK_MOVE(&h_move,&((*text_string)[esc_index + 3]),8);
                        OM_BLOCK_MOVE(&v_move,&((*text_string)[esc_index + 11]),8);

                        temp_index = esc_index;
                     }  /* end "while (GRbwd_beg_esc_seq)" */
                  }  /* end "if (field_type & JUSTIFIED_FLD)" */

                  /*
                   * must update the current char position and the
                   * postion where erasing the text string began
                   */

                  num_positions = 3;
                  positions[0] = &cc_info->cur_char_index;
                  positions[1] = &erase_index;
                  positions[2] = &del_char_index;

                  /*
                   *  if currently in a field, must adjust the begin
                   *  field index if justification moves were removed
                   *  or inserted
                   */

                  if (cc_info->field_delim)
                  {
                     positions[num_positions] = &cc_info->field_position;
                     ++num_positions;
                  }

                  GRjust_string(&temp_msg,text_string,
                                &tx_attr->text_length,
                                text_buf_size,
                                font_info,disp_attr,&text_symb,
                                num_positions,positions,&text_extents);

                  /*
                   *  update the the cc_info struct
                   */

                  GRchar_pos_info(&temp_msg,*text_string,
                                  cc_info->cur_char_index,
                                  FALSE,tx_attr,font_info,disp_attr,
                                  cc_info);

                  /*
                   *  display the appropriate sub-string
                   */

                  GRdisplay_chars(&temp_msg,*text_string,
                                  &tx_attr->text_length,erase_from,
                                  erase_to,&cc_info->cur_char_index,
                                  &erase_index,&chars_eol,font_info->flags,
                                  erase_flags,kern_value,text_info);

                  /*
                   * display chars 
                   */

                  if (cur_text_attr.text_length)
                  {
                     /*
                      * display the editted text string
                      */

                     dp$display(msg = &temp_msg,
                                osnum = mod_osnum,
                                mode = display_mode,
                                buffer = ele_header,
                                view_ind = view_ind,
                                view_ind_type = view_ind_type,
                                view_ind_point = view_ind_point);
                  }
               }
               ++i; 

               break;

            case INSERT_FONT:

                /*
                 * get the insert font variable
                 */

                {
                    struct GRIOvar_def var_struct;
                    IGRlong            om_msg;
                    IGRint             sts;
                    IGRshort           font_index;

                    ex$get_cur_mod(id = &mod_id,
                                   osnum = &mod_osnum);

                    sts = co$cvtvar(msg = &temp_msg,
                                    alias = "Insert_font",
                                    osnum = mod_osnum,
                                    var = &var_struct);

                    if (sts & temp_msg & 1)
                    {
                        /*
                         * if the font to be inserted and the current font
                         * are the same, don't need to insert chanage font
                         */

                        font_index = (IGRshort) var_struct.contents.ivalue;

                        if (font_index != cc_info->text_attr.font)
                        {
                            /*
                             * see if the insert font is a valid font
                             */

                            ex$get_super(mod_id = mod_id,
                                         mod_osnum = mod_osnum,
                                         super_name = FONTMGR_NO_NAME,
                                         create = TRUE,
                                         super_class = "GRfm",
                                         super_id = &fontmgr_obj.objid,
                                         super_osnum = &fontmgr_obj.osnum);

                            om_msg = om$send(mode = OM_e_wrt_object,
                                             msg = message GRfm.GRfm_retdata
                                                       (&temp_msg, &font_index,
                                                        &temp_font_info),
                                             senderid = NULL_OBJID,
                                             targetid = fontmgr_obj.objid,
                                             targetos = fontmgr_obj.osnum);

                            if (om_msg & temp_msg & 1)
                            {
                                /*
                                 * check to see if the text buffer size
                                 * is within TEXT_BUF_SIZE of exceeding
                                 * the maximum number of characters
                                 * currently allowed in a text string,
                                 * which is limited to a signed short's
                                 * greatest positive number
                                 */

                                tmp_short = *text_buf_size + TEXT_BUF_SIZE;

                                if (tmp_short >= 0)
                                {
                                   tx_attr->text_length += 8;

                                   /*
                                    * may have to enlarge the text
                                    * buffer if it isn't large enough to
                                    * hold the char to be inserted
                                    */

                                   if (tx_attr->text_length > *text_buf_size)
                                   {
                                       *text_buf_size += TEXT_BUF_SIZE;
                                       *text_string = (IGRuchar *)om$realloc(
                                                ptr = (IGRchar *) *text_string,
                                                size = (OMuint)*text_buf_size);
                                   }
                                }
                                else
                                {
                                   status = FALSE;
                                   *msg = MSFAIL;
                                   goto FINISH;
                                }

                                /*
                                 * must insert a change font escape sequence to
                                 * the "insert" font and a pop font escape
                                 * sequence
                                 */

                                cc_index = cc_info->cur_char_index;

                                OM_BLOCK_MOVE(&((*text_string)[cc_index]),
                                              &((*text_string)[cc_index + 8]),
                                              (IGRint)(tx_attr->text_length - cc_index - 8));

                                (*text_string)[cc_index] = ESC;
                                (*text_string)[cc_index + 1] = 'f';

                                OM_BLOCK_MOVE(&font_index,
                                              &((*text_string)[cc_index + 2]),2);

                                (*text_string)[cc_index + 4] = ESC;
                                (*text_string)[cc_index + 5] = 'f';

                                OM_BLOCK_MOVE(&cc_info->text_attr.font,
                                              &((*text_string)[cc_index + 6]),2);

                                /*
                                 * move the cursor between the change font
                                 * escape sequences so that the next
                                 * characters entered will use this font
                                 */

                                cc_index += 4;

                                GRchar_pos_info(&temp_msg, *text_string,
                                                cc_index, TRUE, tx_attr,
                                                font_info, disp_attr, cc_info);
                            }
                            else
                            {
                                ex$message(msgnumb = GR_E_FtNotFnd,
                                           seconds = 20);
                            }
                        }
                    }
                    else  /* insert font variable is not defined */
                    {
                        ex$message(msgnumb = GR_E_FtNotFnd,
                                   seconds = 20);
                    }
                    i++;
                }
                break;

            default:     /* insert char(s) */

               ex$get_cur_mod(osnum = &mod_osnum);

               /*
                * if the text is view independent, must initialize
                * info for display
                */

               if (view_ind)
               {
                  view_ind_type = ROTATION_IND;
                  view_ind_point[0] = ele_header->geometry.lbsys->matrix[3];
                  view_ind_point[1] = ele_header->geometry.lbsys->matrix[7];
                  view_ind_point[2] = ele_header->geometry.lbsys->matrix[11];
               }

               /*
                * if the first char in the keyin buffer is the
                * FRACTION_KEY code and the end_fraction flag is not set, 
                * set fraction_flag to TRUE to indicate the user is about
                * to enter a fraction
                */

               if ((keyin[i] == FRACTION_KEY) &&
                   (!end_fraction))
               {
                  /*
                   * set fraction flag to indicate following keyin chars
                   * are to be interpreted as a fraction; clear out 
                   * static 'frac_chars' buffer from any characters that
                   * might have been left
                   */

                  fraction_flag = TRUE;

                  frac_index = 0;
                  frac_chars[frac_index] = '\0';
      
                  ex$message (msgnumb = GR_P_EnterFraction);

                  ++i; 
               }
               else
               {
                  /*
                   * find the number of consecutive chars to insert and
                   * if any of the chars are linefeeds or carriage
                   * returns
                   */

                  char_type = INSERT_CHAR;
                  temp_index = i;

                  /*
                   * if the first char in the keyin buffer is a
                   * FRACTION_KEY, treat it as a displayable char;
                   * any subsequent FRACTION_KEY chars in the keyin
                   * buffer may indicate a fraction is about to be
                   * entered
                   */

                  if (keyin[temp_index] == FRACTION_KEY)
                  {
                     ++temp_index;
                  }

                  do
                  {
                     if (keyin[temp_index] == 0xd) /* carraige return */
                     {
                        /*
                         * replace carraige returns with linefeeds
                         */

                        keyin[temp_index] = LINEFEED;
                        char_type = INSERT_LF;
                     }
                     else if (keyin[temp_index] == LINEFEED)
                     {
                        char_type = INSERT_LF;
                     }

                     if ((issixteen(keyin[temp_index])) &&
                         ((active_font_type == sixteen) ||
                          (cc_info->font_info.flags & SIXTEEN_BIT)))
                     {
                        temp_index += 2;
                     }
                     else
                     {                     
                        ++temp_index;
                     }
                  }
                  while((temp_index < keyin_nbytes) &&
                        (keyin[temp_index] != DEL) &&
                        (keyin[temp_index] != RIGHT_ARROW) &&
                        (keyin[temp_index] != LEFT_ARROW) &&
                        (keyin[temp_index] != UP_ARROW) &&
                        (keyin[temp_index] != DOWN_ARROW) &&
                        (keyin[temp_index] != FRACTION_KEY));

                  text_info->font_id = mod_osnum;
                  text_info->estx = &cur_text_attr;

                  /*
                   * if the chars being inserted are in a fixed length
                   * field, a justified field or a field that is followed
                   * by a move to field reference point escape sequence,
                   * a flag must be set to indicate this so special
                   * actions can be taken to erase, display and possibly
                   * justify the text string
                   */

                  field_type = NO_FLD;

                  if (cc_info->field_delim)  /* currently in a field */
                  {
                     if (cc_info->flags & FIXED_LENGTH_FIELD)
                     {
                        field_type |= FIXED_LENGTH_FLD;
                     }

                     if (cc_info->flags & JUSTIFIED_FIELD)
                     {
                        field_type |= JUSTIFIED_FLD;
                     }
                  }

                  num_chars = 1;
                  esc_chars[0] = 'M';
                  prev_font = cc_info->prev_font;
                  current_font = cc_info->text_attr.font;
                  temp_font_info = cc_info->font_info;

                  if (GRfwd_beg_esc_seq(&temp_msg,*text_string,
                                        &tx_attr->text_length,&num_chars,
                                        esc_chars,NULL,
                                        &cc_info->cur_char_index,&prev_font,
                                        &current_font,&temp_font_info,
                                        &esc_index))
                  {
                     field_type |= MV_REF_PT_FLD;
                  }

                  if (char_type == INSERT_LF)
                  {
                     lf_mask = (tx_attr->line_spac >= 0 ? DOWN_MOVE : UP_MOVE);

                     /*
                      * if there is a vertical move from the current char
                      * to the end of the text string, must find out if the
                      * vertical move goes up or down
                      */

                     num_chars = 1;
                     esc_chars[0] = 'v';
                     edt_char_index = cc_info->cur_char_index;
                     prev_font = cc_info->prev_font;
                     current_font = cc_info->text_attr.font;
                     temp_font_info = cc_info->font_info;

                     while (GRfwd_beg_esc_seq(&temp_msg,*text_string,
                                              &tx_attr->text_length,
                                              &num_chars,esc_chars,NULL,
                                              &edt_char_index,&prev_font,
                                              &current_font,&temp_font_info,
                                              &esc_index))
                     {
                        OM_BLOCK_MOVE(&((*text_string)[esc_index + 2]),
                                      &esc_value,8);

                        if (esc_value >= 0)
                        {
                           lf_mask |= UP_MOVE;
                        }
                        else
                        {
                           lf_mask |= DOWN_MOVE;
                        }

                        edt_char_index = esc_index + 10;
                     }
                  }

                  /*
                   *  find the text sub-string to erase
                   */

                  GRerase_chars(&temp_msg,*text_string,tx_attr,font_info,
                                disp_attr,char_type,lf_mask,
                                field_type,&del_char_index,cc_info,
                                text_info,&cur_disp_attr,&erase_from,
                                &erase_to,&erase_index,&chars_eol,
                                &erase_flags,&kern_value);

                  if (cur_text_attr.text_length)
                  {
                            dp$display(msg = &temp_msg,
                                       osnum = mod_osnum,
                                       mode = erase_mode,
                                       buffer = ele_header,
                                       view_ind = view_ind,
                                       view_ind_type = view_ind_type,
                                       view_ind_point = view_ind_point);
                  }

                  cc_index = cc_info->cur_char_index;
                  overwrite_char = FALSE;

                  /*
                   * check if chars are to be inserted into a
                   * fixed length field
                   */

                  if ((cc_info->field_delim == 0) ||
                      (!(cc_info->flags & FIXED_LENGTH_FIELD)))
                  {
                     /*
                      * not in a fixed length field
                      */

                     while (i < temp_index)
                     {
                        if (end_fraction)
                        {
                           /*
                            * insert a fraction char code; skip past
                            * the pop font escape sequence that
                            * follows it; must decrement the number of
                            * chars to the end of the line variable
                            * since skipping forward from the original
                            * position
                            */

                           /*
                            * check to see if the text buffer size is within
                            * TEXT_BUF_SIZE of exceeding the maximum number of
                            * characters currently allowed in a text string,
                            * which is limited to a signed short's greatest
                            * positive number
                            */

                           tmp_short = *text_buf_size + TEXT_BUF_SIZE;

                           if (tmp_short >= 0)
                           {
                              tx_attr->text_length += 1;

                              /*
                               * may have to enlarge the text buffer
                               * if it isn't large enough to hold the
                               * char to be inserted
                               */

                              if (tx_attr->text_length > *text_buf_size)
                              {
                                 *text_buf_size += TEXT_BUF_SIZE;

                                 *text_string = (IGRuchar *)om$realloc(
                                             ptr = (IGRchar *)*text_string,
                                             size = (OMuint)*text_buf_size);
                              }
                           }
                           else
                           {
                              status = FALSE;
                              *msg = MSFAIL;
                              goto FINISH;
                           }

                           OM_BLOCK_MOVE(&((*text_string)[cc_index]),
                                         &((*text_string)[cc_index + 1]),
                                         (IGRint)(tx_attr->text_length - cc_index - 1));
                           (*text_string)[cc_index] = keyin[i];

                           cc_index += 4;
                           chars_eol -= 3;
                           end_fraction = FALSE;

                           /*
                            * must update the cc_info structure since we
                            * have moved past the pop font for the
                            * fraction char
                            */

                           GRchar_pos_info(&temp_msg,*text_string,cc_index,
                                           TRUE,tx_attr,font_info,disp_attr,
                                           cc_info);
                        }
                        else if (keyin[i] == LINEFEED)
                        {
                           /*
                            * insert the linefeed esc sequence at the
                            * current position
                            */

                           /*
                            * check to see if the text buffer size is within
                            * TEXT_BUF_SIZE of exceeding the maximum number of
                            * characters currently allowed in a text string,
                            * which is limited to a signed short's greatest
                            * positive number
                            */

                           tmp_short = *text_buf_size + TEXT_BUF_SIZE;

                           if (tmp_short >= 0)
                           {
                              tx_attr->text_length += 2;

                              /*
                               * may have to enlarge the text buffer if
                               * it isn't large enough to hold the chars
                               * to be inserted
                               */

                              if (tx_attr->text_length > *text_buf_size)
                              {
                                 *text_buf_size += TEXT_BUF_SIZE;

                                 *text_string = (IGRuchar *)om$realloc(
                                                 ptr = (IGRchar *) *text_string,
                                                 size = (OMuint)*text_buf_size);
                              }
                           }
                           else
                           {
                              status = FALSE;
                              *msg = MSFAIL;
                              goto FINISH;
                           }

                           OM_BLOCK_MOVE(&((*text_string)[cc_index]),
                                         &((*text_string)[cc_index + 2]),
                                         (IGRint)(tx_attr->text_length - cc_index - 2));
                           (*text_string)[cc_index] = ESC;
                           (*text_string)[cc_index + 1] = keyin[i];
                           cc_index += 2;
                           ++(*num_lines);
                        }
                        else   /* regular char */
                        {
                           if (keyin[i] == ESC)
                           {
                              /*
                               * check to see if the text buffer size is within
                               * TEXT_BUF_SIZE of exceeding the maximum number
                               * of characters currently allowed in a text
                               * string, which is limited to a signed short's
                               * greatest positive number
                               */

                              tmp_short = *text_buf_size + TEXT_BUF_SIZE;

                              if (tmp_short >= 0)
                              {
                                 tx_attr->text_length += 2;

                                 /*
                                  * may have to enlarge the text buffer
                                  * if it isn't large enough to hold the
                                  * char to be inserted
                                  */

                                 if (tx_attr->text_length > *text_buf_size)
                                 {
                                    *text_buf_size += TEXT_BUF_SIZE;
                                    *text_string = (IGRuchar *)om$realloc(
                                                ptr = (IGRchar *) *text_string,
                                                size = (OMuint)*text_buf_size);
                                 }
                              }
                              else
                              {
                                 status = FALSE;
                                 *msg = MSFAIL;
                                 goto FINISH;
                              }

                              OM_BLOCK_MOVE(&((*text_string)[cc_index]),
                                            &((*text_string)[cc_index + 2]),
                                            (IGRint)(tx_attr->text_length - cc_index - 2));
                              (*text_string)[cc_index] = ESC;
                              (*text_string)[cc_index + 1] = ESC;
                              cc_index += 2;
                           }
                           else if (issixteen(keyin[i]))
                           {
                              if (cc_info->font_info.flags & SIXTEEN_BIT)
                              {
                                 /*
                                  * check to see if the text buffer size is
                                  * within TEXT_BUF_SIZE of exceeding the
                                  * maximum number of characters currently
                                  * allowed in a text string, which is limited
                                  * to a signed short's greatest positive
                                  * number
                                  */

                                 tmp_short = *text_buf_size + TEXT_BUF_SIZE;

                                 if (tmp_short >= 0)
                                 {
                                    tx_attr->text_length += 2;

                                    /*
                                     * may have to enlarge the text buffer
                                     * if it isn't large enough to hold the
                                     * char to be inserted
                                     */

                                    if (tx_attr->text_length > *text_buf_size)
                                    {
                                       *text_buf_size += TEXT_BUF_SIZE;
                                       *text_string = (IGRuchar *)om$realloc(
                                                ptr = (IGRchar *) *text_string,
                                                size = (OMuint)*text_buf_size);
                                    }
                                 }
                                 else
                                 {
                                    status = FALSE;
                                    *msg = MSFAIL;
                                    goto FINISH;
                                 }

                                 OM_BLOCK_MOVE(&((*text_string)[cc_index]),
                                               &((*text_string)[cc_index + 2]),
                                               (IGRint)(tx_attr->text_length - cc_index - 2));

                                 (*text_string)[cc_index] = keyin[i];
                                 (*text_string)[cc_index + 1] = keyin[i + 1];
                                 cc_index += 2;
                              }
                              else if (cc_info->font_info.flags & EIGHT_BIT)
                              {
                                 /*
                                  * check to see if the text buffer size is
                                  * within TEXT_BUF_SIZE of exceeding the
                                  * maximum number of characters currently
                                  * allowed in a text string, which is limited
                                  * to a signed short's greatest positive
                                  * number
                                  */

                                 tmp_short = *text_buf_size + TEXT_BUF_SIZE;

                                 if (tmp_short >= 0)
                                 {
                                    tx_attr->text_length += 1;

                                    /*
                                     * may have to enlarge the text buffer
                                     * if it isn't large enough to hold the
                                     * char to be inserted
                                     */

                                    if (tx_attr->text_length > *text_buf_size)
                                    {
                                       *text_buf_size += TEXT_BUF_SIZE;
                                       *text_string = (IGRuchar *)om$realloc(
                                                ptr = (IGRchar *) *text_string,
                                                size = (OMuint)*text_buf_size);
                                    }
                                 }
                                 else
                                 {
                                    status = FALSE;
                                    *msg = MSFAIL;
                                    goto FINISH;
                                 }

                                 OM_BLOCK_MOVE(&((*text_string)[cc_index]),
                                               &((*text_string)[cc_index + 1]),
                                               (IGRint)(tx_attr->text_length - cc_index - 1));

                                 (*text_string)[cc_index] = keyin[i];
                                 ++cc_index;
                                 
                                 i--;
                              }
                              else  /* 16 bit char in 7 bit part */
                              {
                                 if (active_font_type == sixteen)
                                 {
                                    /*
                                     * check to see if the text buffer size is
                                     * within TEXT_BUF_SIZE of exceeding the
                                     * maximum number of characters currently
                                     * allowed in a text string, which is
                                     * limited to a signed short's greatest
                                     * positive number
                                     */

                                    tmp_short = *text_buf_size + TEXT_BUF_SIZE;

                                    if (tmp_short >= 0)
                                    {
                                       /*
                                        * check to see if the text buffer size
                                        * is within TEXT_BUF_SIZE of exceeding
                                        * the maximum number of characters
                                        * currently allowed in a text string,
                                        * which is limited to a signed short's
                                        * greatest positive number
                                        */

                                       tmp_short = *text_buf_size + TEXT_BUF_SIZE;

                                       if (tmp_short >= 0)
                                       {
                                          tx_attr->text_length += 10;

                                          /*
                                           * may have to enlarge the text
                                           * buffer if it isn't large enough to
                                           * hold the char to be inserted
                                           */

                                          if (tx_attr->text_length > *text_buf_size)
                                          {
                                              *text_buf_size += TEXT_BUF_SIZE;
                                              *text_string = 
                                                (IGRuchar *)om$realloc(
                                                 ptr = (IGRchar *) *text_string,
                                                 size = (OMuint)*text_buf_size);
                                          }
                                       }
                                       else
                                       {
                                          status = FALSE;
                                          *msg = MSFAIL;
                                          goto FINISH;
                                       }
                                    }
                                    else
                                    {
                                       status = FALSE;
                                       *msg = MSFAIL;
                                       goto FINISH;
                                    }

                                    /*
                                     * must enter change font escape sequence;
                                     * change font to the active font (which
                                     * is 16 bit), enter the character, and
                                     * then change font back to current font
                                     */

                                    OM_BLOCK_MOVE(&((*text_string)[cc_index]),
                                                  &((*text_string)[cc_index + 10]),
                                                  (IGRint)(tx_attr->text_length - cc_index - 10));

                                    (*text_string)[cc_index] = ESC;
                                    (*text_string)[cc_index + 1] = 'f';

                                    OM_BLOCK_MOVE(&active_font,
                                                  &((*text_string)[cc_index + 2]),2);

                                    (*text_string)[cc_index + 4] = keyin[i];
                                    (*text_string)[cc_index + 5] = keyin[i + 1];
                                    (*text_string)[cc_index + 6] = ESC;
                                    (*text_string)[cc_index + 7] = 'f';

                                    OM_BLOCK_MOVE(&cc_info->text_attr.font,
                                                  &((*text_string)[cc_index + 8]),2);

                                    cc_index += 10;

                                    seven_sixteen_mix = TRUE;
                                 }
                                 else
                                 {
                                    ex$message(msgnumb = GR_E_ActFntNotSxtnBit);
                                 }
                              }
                              ++i; 
                           }
                           else  /* character with high order bit clear */
                           {
                              if (! (cc_info->font_info.flags & SIXTEEN_BIT))
                              {
                                 /*
                                  * check to see if the text buffer size
                                  * is within TEXT_BUF_SIZE of exceeding
                                  * the maximum number of characters
                                  * currently allowed in a text string,
                                  * which is limited to a signed short's
                                  * greatest positive number
                                  */

                                 tmp_short = *text_buf_size + TEXT_BUF_SIZE;

                                 if (tmp_short >= 0)
                                 {
                                    /*
                                     * adding character in 7 or 8 bit part
                                     * of string
                                     */

                                    tx_attr->text_length += 1;

                                    /*
                                     * may have to enlarge the text buffer
                                     * if it isn't large enough to hold the
                                     * char to be inserted
                                     */

                                    if (tx_attr->text_length > *text_buf_size)
                                    {
                                       *text_buf_size += TEXT_BUF_SIZE;
                                       *text_string = (IGRuchar *)om$realloc(
                                            ptr = (IGRchar *) *text_string,
                                            size = (OMuint)*text_buf_size);
                                    }
                                 }
                                 else
                                 {
                                    status = FALSE;
                                    *msg = MSFAIL;
                                    goto FINISH;
                                 }

                                 OM_BLOCK_MOVE(&((*text_string)[cc_index]),
                                               &((*text_string)[cc_index + 1]),
                                               (IGRint)(tx_attr->text_length - cc_index - 1));
                                 (*text_string)[cc_index] = keyin[i];
                                 ++cc_index;
                              }
                              else  /* 7 or 8 bit char in 16 bit part */
                              {
                                 /*
                                  * check to see if the text buffer size
                                  * is within TEXT_BUF_SIZE of exceeding
                                  * the maximum number of characters
                                  * currently allowed in a text string,
                                  * which is limited to a signed short's
                                  * greatest positive number
                                  */

                                 tmp_short = *text_buf_size + TEXT_BUF_SIZE;

                                 if (tmp_short >= 0)
                                 {
                                    tx_attr->text_length += 9;

                                    /*
                                     * may have to enlarge the text buffer
                                     * if it isn't large enough to hold the
                                     * char to be inserted
                                     */

                                    if (tx_attr->text_length > *text_buf_size)
                                    {
                                       *text_buf_size += TEXT_BUF_SIZE;
                                       *text_string = (IGRuchar *)om$realloc(
                                          ptr = (IGRchar *) *text_string,
                                          size = (OMuint)*text_buf_size);
                                    }
                                 }
                                 else
                                 {
                                    status = FALSE;
                                    *msg = MSFAIL;
                                    goto FINISH;
                                 }

                                 /*
                                  * must enter change font escape sequence;
                                  * change font to the active 7 bit font,
                                  * enter the character, and then change font
                                  * back to the current 16 bit font
                                  */

                                 OM_BLOCK_MOVE(&((*text_string)[cc_index]),
                                               &((*text_string)[cc_index + 9]),
                                               (IGRint)(tx_attr->text_length - cc_index - 9));

                                 (*text_string)[cc_index] = ESC;
                                 (*text_string)[cc_index + 1] = 'f';

                                 if (active_font_type == seven)
                                 {
                                    OM_BLOCK_MOVE(&active_font,
                                                  &((*text_string)[cc_index + 2]),2);
                                 }
                                 else
                                 {
                                    OM_BLOCK_MOVE(&active_ascii_font,
                                                  &((*text_string)[cc_index + 2]),2);
                                 }

                                 (*text_string)[cc_index + 4] = keyin[i];
                                 (*text_string)[cc_index + 5] = ESC;
                                 (*text_string)[cc_index + 6] = 'f';

                                 OM_BLOCK_MOVE(&cc_info->text_attr.font,
                                               &((*text_string)[cc_index + 7]),2);

                                 cc_index += 9;

                                 seven_sixteen_mix = TRUE;
                              }
                           }
                        }
                        ++i; 
                     }  /* end "while (i < temp_index)" */
                  }
                  else  /* inserting into a fixed length field */
                  {
                     while (i < temp_index)
                     {
                        /*
                         * find the last editable character in this
                         * fixed length field; if no editable char is
                         * found, can't insert char
                         */

                        init_font = tx_attr->font;
                        prev_font2 = init_font;
                        save_font_info = *font_info;

                        if (GRfield_end_char(&temp_msg,*text_string,
                                             tx_attr->text_length,
                                             cc_info->field_position,
                                             &prev_font2,&init_font,
                                             &save_font_info,&edt_char_index))
                        {
                           if ((*text_string)[edt_char_index] != ESC)
                           {
                              if (save_font_info.flags & SIXTEEN_BIT)
                              {
                                 num_chars = 2;
                              }
                              else
                              {
                                 num_chars = 1;
                              }
                           }
                           else if ((*text_string)[edt_char_index + 1] == ESC)
                           {
                              num_chars = 2;
                           }
                           else  /* char. to be "dropped" is a linefeed */
                           {
                              if ((tx_attr->text_length > edt_char_index + 11) &&
                                  ((*text_string)[edt_char_index + 2] == ESC) &&
                                  ((*text_string)[edt_char_index + 3] == 'H'))
                              {
                                 num_chars = 12;
                              }
                              else
                              {
                                 num_chars = 2;
                              }

                              --(*num_lines);   /* one less line */
                           }

                           /*
                            * overwrite the last editable character in
                            * the fixed length field by shifting
                            * backward the chars following it
                            */

                           OM_BLOCK_MOVE(&((*text_string)[edt_char_index + num_chars]),
                                         &((*text_string)[edt_char_index]),
                                         (IGRint)(tx_attr->text_length - edt_char_index - num_chars));

                           /*
                            * if the position for the char to be
                            * inserted follows the position of the
                            * char that was overwritten, the position
                            * to be inserted must be adjusted since
                            * the chars that followed the char that
                            * was overwritten were shifted backward;
                            * a char preceding the current char info
                            * has been overwitten and will be replaced
                            * by the char to insert, therefore the
                            * current char info must be adjusted
                            * accordingly so set the overwrite_char
                            * flag
                            */

                           if (edt_char_index < cc_index)
                           {
                              cc_index -= num_chars;
                              overwrite_char = TRUE;
                           }
                           else
                           {
                              /*
                               * must decrement chars_eol since chars
                               * following the current char index
                               * have been removed
                               */

                              chars_eol -= num_chars;
                           }

                           if (end_fraction)
                           {
                              /*
                               * inserting a fraction requires
                               * one char; if the char being
                               * overwritten does not require one
                               * char, the length of the text string
                               * must be adjusted accordingly
                               */

                              if (1 - num_chars)
                              {
                                 /*
                                  * check to see if the text buffer size
                                  * is within TEXT_BUF_SIZE of exceeding
                                  * the maximum number of characters
                                  * currently allowed in a text string,
                                  * which is limited to a signed short's
                                  * greatest positive number
                                  */

                                 tmp_short = *text_buf_size + TEXT_BUF_SIZE;

                                 if (tmp_short >= 0)
                                 {
                                    tx_attr->text_length += (1 - num_chars);

                                    /*
                                     * may have to enlarge the text
                                     * buffer if it isn't large enough
                                     * to hold the chars to be inserted
                                     */

                                    if (tx_attr->text_length > *text_buf_size)
                                    {
                                       *text_buf_size += TEXT_BUF_SIZE;

                                       *text_string = (IGRuchar *)om$realloc(
                                                 ptr = (IGRchar *)*text_string,
                                                 size = (OMuint)*text_buf_size);
                                    }
                                 }
                                 else
                                 {
                                    status = FALSE;
                                    *msg = MSFAIL;
                                    goto FINISH;
                                 }
                              }

                              /*
                               * shift the chars in the text string
                               * foward one position and insert the
                               * fraction char
                               */

                              OM_BLOCK_MOVE(&((*text_string)[cc_index]),
                                            &((*text_string)[cc_index + 1]),
                                            (IGRint)(tx_attr->text_length - cc_index - 1));

                              (*text_string)[cc_index] = keyin[i];

                              /*
                               * move past the fraction inserted and
                               * the pop font escape sequence that
                               * immediately follows it; must
                               * decrement chars_eol since moving
                               * past pop font escape sequence
                               */

                              cc_index += 4;
                              chars_eol -= 3;
                              end_fraction = FALSE;

                              /*
                               * must update the cc_info structure since we
                               * have moved past the pop font for the
                               * fraction char
                               */

                              GRchar_pos_info(&temp_msg,*text_string,cc_index,
                                              TRUE,tx_attr,font_info,disp_attr,
                                              cc_info);
                           }
                           else if (keyin[i] == LINEFEED)
                           {
                              ++(*num_lines);

                              /*
                               * inserting a linefeed requires two
                               * chars (ESC LINEFEED); if the char
                               * being overwritten does not require
                               * two chars, the length of the text
                               * string must be adjusted accordingly
                               */

                              if (2 - num_chars)
                              {
                                 /*
                                  * check to see if the text buffer size
                                  * is within TEXT_BUF_SIZE of exceeding
                                  * the maximum number of characters
                                  * currently allowed in a text string,
                                  * which is limited to a signed short's
                                  * greatest positive number
                                  */

                                 tmp_short = *text_buf_size + TEXT_BUF_SIZE;

                                 if (tmp_short >= 0)
                                 {
                                    tx_attr->text_length += (2 - num_chars);

                                    /*
                                     * may have to enlarge the text
                                     * buffer if it isn't large enough
                                     * to hold the chars to be inserted
                                     */

                                    if (tx_attr->text_length > *text_buf_size)
                                    {
                                       *text_buf_size += TEXT_BUF_SIZE;

                                       *text_string = (IGRuchar *)om$realloc(
                                                ptr = (IGRchar *) *text_string,
                                                size = (OMuint)*text_buf_size);
                                    }
                                 }
                                 else
                                 {
                                    status = FALSE;
                                    *msg = MSFAIL;
                                    goto FINISH;
                                 }
                              }

                              /*
                               * shift the chars in the text string
                               * foward two positions and insert the
                               * ESC LINEFEED chars
                               */

                              OM_BLOCK_MOVE(&((*text_string)[cc_index]),
                                            &((*text_string)[cc_index + 2]),
                                            (IGRint)(tx_attr->text_length - cc_index - 2));
                              (*text_string)[cc_index] = ESC;
                              (*text_string)[cc_index + 1] = LINEFEED;
                              cc_index += 2;
                           }
                           else if (keyin[i] == ESC) /* insert two consecutive escs */
                           {
                              /*
                               * inserting an escape requires two
                               * chars (ESC ESC); if the char
                               * being overwritten does not require
                               * two chars, the length of the text
                               * string must be adjusted accordingly
                               */

                              if (2 - num_chars)
                              {
                                 /*
                                  * check to see if the text buffer size
                                  * is within TEXT_BUF_SIZE of exceeding
                                  * the maximum number of characters
                                  * currently allowed in a text string,
                                  * which is limited to a signed short's
                                  * greatest positive number
                                  */

                                 tmp_short = *text_buf_size + TEXT_BUF_SIZE;

                                 if (tmp_short >= 0)
                                 {
                                    tx_attr->text_length += (2 - num_chars);

                                    /*
                                     * may have to enlarge the text
                                     * buffer if it isn't large enough
                                     * to hold the chars to be inserted
                                     */

                                    if (tx_attr->text_length > *text_buf_size)
                                    {
                                       *text_buf_size += TEXT_BUF_SIZE;

                                       *text_string = (IGRuchar *)om$realloc(
                                                ptr = (IGRchar *) *text_string,
                                                size = (OMuint)*text_buf_size);
                                    }
                                 }
                                 else
                                 {
                                    status = FALSE;
                                    *msg = MSFAIL;
                                    goto FINISH;
                                 }
                              }

                              /*
                               * shift the chars in the text string
                               * foward two positions and insert the
                               * ESC ESC chars
                               */

                              OM_BLOCK_MOVE(&((*text_string)[cc_index]),
                                            &((*text_string)[cc_index + 2]),
                                            (IGRint)(tx_attr->text_length - cc_index - 2));
                              (*text_string)[cc_index] = ESC;
                              (*text_string)[cc_index + 1] = ESC;
                              cc_index += 2;
                           }
                           else if (cc_info->font_info.flags & SIXTEEN_BIT) /* sixteen bit character */
                           {
                              /*
                               * inserting a sixteen bit character
                               * requires two bytes; if the char
                               * being overwritten does not require
                               * two bytes, the length of the text
                               * string must be adjusted accordingly
                               */

                              if (2 - num_chars)
                              {
                                 /*
                                  * check to see if the text buffer size
                                  * is within TEXT_BUF_SIZE of exceeding
                                  * the maximum number of characters
                                  * currently allowed in a text string,
                                  * which is limited to a signed short's
                                  * greatest positive number
                                  */

                                 tmp_short = *text_buf_size + TEXT_BUF_SIZE;

                                 if (tmp_short >= 0)
                                 {
                                    tx_attr->text_length += (2 - num_chars);

                                    /*
                                     * may have to enlarge the text
                                     * buffer if it isn't large enough
                                     * to hold the chars to be inserted
                                     */

                                    if (tx_attr->text_length > *text_buf_size)
                                    {
                                       *text_buf_size += TEXT_BUF_SIZE;

                                       *text_string = (IGRuchar *)om$realloc(
                                                ptr = (IGRchar *) *text_string,
                                                size = (OMuint)*text_buf_size);
                                    }
                                 }
                                 else
                                 {
                                    status = FALSE;
                                    *msg = MSFAIL;
                                    goto FINISH;
                                 }
                              }

                              /*
                               * shift the chars in the text string
                               * foward two positions and insert the
                               * sixteen bit character
                               */

                              OM_BLOCK_MOVE(&((*text_string)[cc_index]),
                                            &((*text_string)[cc_index + 2]),
                                            (IGRint)(tx_attr->text_length - cc_index - 2));

                              (*text_string)[cc_index] = keyin[i];
                              (*text_string)[cc_index + 1] = keyin[i + 1];
                              cc_index += 2;
                              ++i; 
                           }
                           else        /* insert regular character */
                           {
                              /*
                               * inserting a "regular" char requires
                               * one char; if the char being
                               * overwritten does not require one
                               * char, the length of the text string
                               * must be adjusted accordingly
                               */

                              if (1 - num_chars)
                              {
                                 /*
                                  * check to see if the text buffer size
                                  * is within TEXT_BUF_SIZE of exceeding
                                  * the maximum number of characters
                                  * currently allowed in a text string,
                                  * which is limited to a signed short's
                                  * greatest positive number
                                  */

                                 tmp_short = *text_buf_size + TEXT_BUF_SIZE;

                                 if (tmp_short >= 0)
                                 {
                                    tx_attr->text_length += (1 - num_chars);

                                    /*
                                     * may have to enlarge the text
                                     * buffer if it isn't large enough
                                     * to hold the chars to be inserted
                                     */

                                    if (tx_attr->text_length > *text_buf_size)
                                    {
                                       *text_buf_size += TEXT_BUF_SIZE;

                                       *text_string = (IGRuchar *)om$realloc(
                                                ptr = (IGRchar *) *text_string,
                                                size = (OMuint)*text_buf_size);
                                    }
                                 }
                                 else
                                 {
                                    status = FALSE;
                                    *msg = MSFAIL;
                                    goto FINISH;
                                 }
                              }

                              /*
                               * shift the chars in the text string
                               * foward one position and insert the
                               * regular char
                               */

                              OM_BLOCK_MOVE(&((*text_string)[cc_index]),
                                            &((*text_string)[cc_index + 1]),
                                            (IGRint)(tx_attr->text_length - cc_index - 1));

                              (*text_string)[cc_index] = keyin[i];
                              ++cc_index;
                           }
                        }
                        ++i; 

                     }  /* end "while (i < temp_index)" */
                  }  /* end inserting into a fixed length field */

                  if (cc_info->flags & EMPTY_FIELD)
                  {
                     /*
                      * have inserted chars into the empty field so
                      * clear the empty field bit
                      */

                     cc_info->flags &= ~EMPTY_FIELD;
                  }

                  text_symb.Active_font = tx_attr->font;
                  text_symb.Active_just = tx_attr->just;
                  text_symb.Active_width = tx_attr->width;
                  text_symb.Active_height = tx_attr->height;
                  text_symb.Active_linespac = tx_attr->line_spac;
                  text_symb.Active_charspac = tx_attr->char_spac;

                  /*
                   * if inserting chars into a field that is followed by
                   * a move to field reference point escape sequence or
                   * is a justified field, need to update the appropriate
                   * justification moves
                   */

                  if (field_type & MV_REF_PT_FLD)
                  {
                     /*
                      * search for any move to field reference point esc
                      * seq following the current field and update the
                      * vertical and horizontal moves
                      */

                     num_chars = 1;
                     esc_chars[0] = 'M';
                     temp_index = cc_index;
                     prev_font = cc_info->prev_font;
                     current_font = cc_info->text_attr.font;
                     temp_font_info = cc_info->font_info;

                     while (GRfwd_beg_esc_seq(&temp_msg,*text_string,
                                              &tx_attr->text_length,
                                              &num_chars,esc_chars,
                                              NULL,&temp_index,&prev_font,
                                              &current_font,&temp_font_info,
                                              &esc_index))
                     {
                        OM_BLOCK_MOVE(&((*text_string)[esc_index + 4]),&h_move,8);
                        OM_BLOCK_MOVE(&((*text_string)[esc_index + 12]),&v_move,8);

                        GRfld_ref_pt(&temp_msg,*text_string,
                                     &esc_index,
                                     &((*text_string)[esc_index + 2]),
                                     font_info,disp_attr,
                                     &text_symb.Active_linespac,
                                     &text_symb.Active_charspac,
                                     &text_symb.Active_height,
                                     &text_symb.Active_width,
                                     &text_symb.Active_font,
                                     &((*text_string)[esc_index + 3]),
                                     &h_move,&v_move);

                        OM_BLOCK_MOVE(&h_move,&((*text_string)[esc_index + 4]),8);
                        OM_BLOCK_MOVE(&v_move,&((*text_string)[esc_index + 12]),8);
                        temp_index = esc_index + 20;  /* skip past escape sequence */
                     }
                  }  /* end "if (field_type & MV_REF_PT_FLD)" */

                  if (field_type & JUSTIFIED_FLD)
                  {
                     /*
                      * beginning at the current field and moving back
                      * to the outer most field the current field is
                      * nested in, update any justified field
                      */

                     num_chars = 1;
                     esc_chars[0] = 'm';
                     temp_index = cc_index;

                     while (GRbwd_beg_esc_seq(msg,*text_string,&num_chars,
                                              esc_chars,NULL,&temp_index,
                                              font_info->flags,&esc_index))
                     {
                        esc_value = 0.0;

                        OM_BLOCK_MOVE(&esc_value,&((*text_string)[esc_index + 3]),8);
                        OM_BLOCK_MOVE(&esc_value,&((*text_string)[esc_index + 11]),8);

                        GRjust_field(&temp_msg,*text_string,
                                     &tx_attr->text_length,
                                     &((*text_string)[esc_index - 2]),
                                     font_info,disp_attr,
                                     &text_symb.Active_linespac,
                                     &text_symb.Active_charspac,
                                     &text_symb.Active_height,
                                     &text_symb.Active_width,
                                     &text_symb.Active_font,
                                     &h_move,&v_move);

                        OM_BLOCK_MOVE(&h_move,&((*text_string)[esc_index + 3]),8);
                        OM_BLOCK_MOVE(&v_move,&((*text_string)[esc_index + 11]),8);

                        temp_index = esc_index;
                     }  /* end "while (GRbwd_beg_esc_seq)" */
                  }  /* end "if (field_type & JUSTIFIED_FLD)" */

                  /*
                   * must update the current char position and the
                   * postion where erasing the text string began
                   */

                  num_positions = 3;
                  positions[0] = &cc_info->cur_char_index;
                  positions[1] = &erase_index;
                  positions[2] = &cc_index;

                  /*
                   *  if currently in a field, must adjust the begin
                   *  field index if justification moves were removed
                   *  or inserted
                   */

                  if (cc_info->field_delim)
                  {
                     positions[num_positions] = &cc_info->field_position;
                     ++num_positions;
                  }

                  GRjust_string(&temp_msg,text_string,
                                &tx_attr->text_length,
                                text_buf_size,font_info,disp_attr,
                                &text_symb,num_positions,
                                positions,&text_extents);

                  /*
                   *  update the stroke start moves in the cc_info struct
                   */

                  GRvertical_ss_move(&temp_msg,*text_string,
                                     &tx_attr->text_length,
                                     tx_attr->height,
                                     &cc_info->ss_v_move);

                  /*
                   * update the linefeed justification move in the
                   * cc_info struct for the first line that was erased
                   */

                  GRline_just_move(&temp_msg,*text_string,
                                   &tx_attr->text_length,
                                   &erase_index,text_info->estx->width,
                                   font_info->flags,
                                   &cc_info->line_just_move);

                  /*
                   *  display the appropriate sub-string
                   */

                  GRdisplay_chars(&temp_msg,*text_string,
                                  &tx_attr->text_length,
                                  erase_from,erase_to,&cc_index,
                                  &erase_index,&chars_eol,font_info->flags,
                                  erase_flags,kern_value,text_info);

                  dp$display(msg = &temp_msg,
                             osnum = mod_osnum,
                             mode = display_mode,
                             buffer = ele_header,
                             view_ind = view_ind,
                             view_ind_type = view_ind_type,
                             view_ind_point = view_ind_point);

                  /*
                   * if chars were inserted into a justified field or the
                   * last char in a fixed length field was overwritten,
                   * must find the cc_info starting at the beginning of
                   * the text string since justification moves that
                   * proceed the current char may have been changed;
                   * otherwise find cc_info from previous char to
                   * current char
                   */

                   if (seven_sixteen_mix)
                   {
                      /*
                       * want to remove unnecessary change font escape
                       * sequence(s) when changing from 7 to 16 and 16 to 7
                       * bit text
                       */

                      GRparse_escape_sequence(&temp_msg,
                                              *text_string,
                                              &tx_attr->text_length,
                                              tx_attr->font,-1,
                                              font_info,0,&cc_index);
                  }

                  if ((field_type & JUSTIFIED_FLD) || overwrite_char || 
                       seven_sixteen_mix)
                  {
                     GRchar_pos_info(&temp_msg,*text_string,
                                     cc_index,FALSE,tx_attr,
                                     font_info,disp_attr,cc_info);

                     seven_sixteen_mix = FALSE;
                  }
                  else
                  {
                     GRchar_pos_info(&temp_msg,*text_string,cc_index,
                                     TRUE,tx_attr,font_info,disp_attr,
                                     cc_info);
                  }
               }

               break;

         }  /* end switch (keyin[i]) */
      }  /* end if not entering fraction input */
   }   /* end while (i < keyin_nbytes) */

FINISH:

   if (temp_keyin)
   {
       om$dealloc(ptr = temp_keyin);
   }

   return(status);
}
end implementation GRtext;
