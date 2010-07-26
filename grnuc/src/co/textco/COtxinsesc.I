/* #######################    APOGEE COMPILED   ######################## */





 /*
 COPYRIGHT
                     COPYRIGHT INTERGRAPH CORPORATION
                              < 1986, 1987 >
  
              Including software  and  its  file formats, and
              audio-visual displays; all rights reserved; may
              only  be  used   pursuant   to  the  applicable
              software     license     agreement;    contains
              confidential  and  proprietary  information  of
              Intergraph and/or other  third parties which is
              protected  by  copyright,   trade  secret,  and
              trademark  law,  and  may  not  be  provided or
              otherwise made available  without prior written
              authorization.
  
  
                         RESTRICTED RIGHTS LEGEND
              Use, duplication,  or  disclosure  by  the U.S.
              Government is  subject  to  restrictions as set
              forth in subdivision  (b)(3)(ii)  of the Rights
              in Technical Data  and Computer Software clause
              at 52.227-7013.
  
  
              Intergraph Corporation
              One Madison Industrial Park
              Huntsville, Al 35807-4201
  
 */ 

/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS NAME:              COtext
     METHOD NAME:             COinsert_escape
 
     Abstract:
        This routine replaces a control character with the appropriate
        escape sequence in a text string.
-----
%SC%

     VALUE =  COinsert_escape(msg,text_string,text_length,text_buf_size,
                              position,cur_font_type,text_symb,disp_attr)
-----
%EN%
 
     ON ENTRY:

      NAME          DATA TYPE                        DESCRIPTION
  -------------  ----------------       ---------------------------------------
  **text_string  unsigned IGRchar       entire text string
  *text_length   IGRshort               length of text string
  *text_buf_size IGRshort               number of bytes currently allocated
                                        for the text string
  *position      IGRshort               position to start searching thru string
  *cur_font_type enum font_type         type of font currently active in string
  *text_symb     struct GRdpb_text_symb text symbology
  *disp_attr     struct IGRdisplay      display attributes
-----
%EX%

     ON EXIT:

      NAME          DATA TYPE                        DESCRIPTION
  -------------  -----------------      ---------------------------------------
  *msg           IGRlong                completion code
  **text_string  unsigned IGRchar       entire text string
  *text_length   IGRshort               length of text string
  *text_buf_size IGRshort               number of bytes currently allocated
                                        for the text string
  VALUE (IGRint) =     MSSUCC    - if successful
                       MSFAIL    - if failure
-----
%MD%

     MODULES INVOKED:  om$malloc
                       om$dealloc
                       om$realloc
                       GRfld_ref_pt
                       GRjust_field
                       OM_BLOCK_MOVE
-----
%RL%

      RELATIONS REFERENCED:

----- 
%NB%

     NOTES:  
-----

%CH%
     CHANGE HISTORY:
        
        DEK  11/17/86 : Design date.
        DEK  11/17/86 : Creation date.
        DEK  09/04/87 : Added field reference point move and 
                        justify field.
        DEK  06/10/88 : Included capability for 16-bit characters.
        DEK  06/21/88 : Changed method into a function.
        DEK  09/09/88 : Display attributes added.
        WBC  07/20/89 : Added argument "text_buf_size".
-----
%PD%
--------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
     This routine replaces a control character with the appropriate
escape sequence in a text string.
----*/
/*EH*/

class implementation COtext;

#include "msdef.h"
#include "grmessage.h"
#include "gotextdef.h"
#include "OMmacros.h"
#include "exmacros.h"
#include "fontdef.h"
#include "coimport.h"

from GRfm import GRfm_retdata, GRvirt_search;

IGRboolean COinsert_escape (msg,text_string,text_length,text_buf_size,position,
                            cur_font_type,text_symb,disp_attr)

IGRlong                   *msg;            /* completion code                */
IGRuchar          	  **text_string;   /* entire text string             */
IGRshort                  *text_length;    /* length of text string          */
IGRshort                  *text_buf_size;  /* number of bytes currently      */
                                           /* allocated for the text string  */
IGRshort                  *position;       /* position to start search from  */
enum font_type            *cur_font_type;  /* type of font currently active  */
struct GRdpb_text_symb    *text_symb;      /* text symbology                 */
struct IGRdisplay         *disp_attr;      /* display attributes             */
{
   extern IGRboolean      GRfld_ref_pt();

   IGRdouble              double_count;    /* size of esc sequence as double */
   IGRchar                *buffer;         /* used to hold size of esc when 
                                              converting to a double         */
   IGRuchar       	  result_1;        /* field number                   */
   IGRuchar       	  result_2;        /* attribute byte                 */
   IGRuchar       	  char_value;      /* numerical value of ascii number*/
   IGRint                 count;           /* number of ascii chars in esc   */
   IGRint                 save_count=0;      /* save count of field number     */
   IGRint                 add_count=0;       /* number of bytes needed to add to 
                                              the string to convert ascii chars
                                              in esc sequence to a double    */
   IGRshort               i,j,k;           /* index counters                 */
   IGRuchar       	  temp;            /* temporary storage              */
   IGRdouble              h_move;          /* store horizontal move as a 
                                              double                         */
   IGRdouble              v_move;          /* store vertical move as a double*/
   struct vfont_entry     font_info;       /* font information               */
   struct GRid            fontmgr_obj;     /* objid/osnum of font manager    */
   IGRlong                OMmsg;           /* status code                    */
   IGRuchar       	  fld_num;         /* number of fields in string     */
   IGRshort               fld[256];        /* position of field in string    */
   IGRboolean             fld_just[256];   /* justification of each field    */
   GRspacenum             cur_mod_osnum;   /* current module's osnum         */
   OM_S_OBJID             cur_mod_id;      /* current module's object id     */
   IGRboolean             field;           /* set field esc seq indicator    */
   IGRuchar       	  fraction[10];    /* fraction code string           */
   IGRuchar       	  frac_string[10]; /* ascii "fraction" string        */
   IGRshort               num_chars;       /* number chars in fraction string*/
   IGRuchar       	  font_name[64];   /* virtual font name in ESC f     */
   IGRshort               font_num;        /* virtual font number in ESC f   */
   IGRshort               tmp_short;
   enum font_type         active_font_type;/* initial type of font in string */

   *msg = MSSUCC;
   fld_num = 0;

   /*
    *  get the objid of the font manager using its named object
    */

   ex$get_cur_mod(osnum = &cur_mod_osnum,
                  id = &cur_mod_id);

   ex$get_super(mod_id = cur_mod_id,
                mod_osnum = cur_mod_osnum,
                super_name = FONTMGR_NO_NAME,
                create = TRUE,
                super_class = "GRfm",
                super_id = &fontmgr_obj.objid,
                super_osnum = &fontmgr_obj.osnum);

   /*
    * get information about specified font
    */

   OMmsg = om$send(mode = OM_e_wrt_object,
                   msg = message GRfm.GRfm_retdata(msg,
                         &(text_symb->Active_font),&font_info),
                   senderid = NULL_OBJID,
                   targetid = fontmgr_obj.objid,
                   targetos = cur_mod_osnum);

   if (font_info.flags & SIXTEEN_BIT)
   {
      active_font_type = sixteen;
   }
   else if (font_info.flags & EIGHT_BIT)
   {
      active_font_type = eight;
   }
   else
   {
      active_font_type = seven;
   }

   /*
    * search string for control characters and replace with
    * appropriate escape sequence
    */

   i = *position;

   while (i < *text_length)
   {
      buffer = 0;

      if (((*text_string)[i] == 0x14) || 
          ((*text_string)[i] == 0x16) ||
          ((*text_string)[i] == 0x18) ||
          ((*text_string)[i] == 0x19) ||
          ((*text_string)[i] == 0x13) ||
          ((*text_string)[i] == 0x11))
      {
         /*
          * cntrl character -- substitute escape sequence, and convert
          * following number to a 'double'
          */

         j = i + 1;
         count = 0;

         /*
          * horizontal or vertical moves could be negative: check
          * for a negative sign
          */

         if ((*text_string)[i] == 0x14 ||
             (*text_string)[i] == 0x16)
         {
            if ((*text_string)[j] == 0x2d)  /* minus sign */
            {
               ++count;     /* increment # of ascii chars in esc seq num */
               ++j;         /* increment position in string */
            }
         }

         /*
          * calculate how many characters are in the number--
          * valid characters are the . and 0-9
          */

         while (((*text_string)[j] == 0x2e ||
                ((*text_string)[j] >= 0x30 && 
                 (*text_string)[j] <= 0x39)) && 
                j < *text_length)
         {
            ++count;       /* increment # of ascii chars in esc seq num */
            ++j;           /* increment position in string */
         }

         /*
          * if necessary, increase the size of the string by the number of
          * bytes needed to store the escape sequence number
          * as a double and replace the control character with
          * an escape sequence
          */

         add_count = 9 - count;

         /*
          * check to see if the text length exceeds the maximum number of
          * characters; text length is stored in a signed short, so if the
          * length becomes negative, it's too big
          */

         tmp_short = *text_length + add_count;

         if (tmp_short >= 0)
         {
            *text_length = tmp_short;

            if (*text_length > *text_buf_size)
            {
               tmp_short = *text_length + TEXT_BUF_SIZE;

               if (tmp_short >= 0)
               {
                  *text_buf_size = tmp_short;
                  *text_string = (IGRuchar *)om$realloc(ptr = (char *)*text_string,
                                                                size = *text_buf_size);
               }
               else
               {
                  *msg = MSFAIL;
                  goto FINISH;
               }
            }
         }
         else
         {
            *msg = MSFAIL;
            goto FINISH;
         }

         if (add_count)
         {
            OM_BLOCK_MOVE(&((*text_string)[i + count + 1]),
                          &((*text_string)[i + add_count + count + 1]),
                          (IGRint)(*text_length - (i + add_count + count + 1)));
         }

         /*
          * convert escape sequence number to a double
          */

         if (count == 0)
         {
            double_count = 0;
         }
         else
         {
            buffer = om$malloc(size = count + 1);
            OM_BLOCK_MOVE(&((*text_string)[i + 1]),buffer,count);
            OM_BLOCK_MOVE(" ",buffer + count,1);
            sscanf(buffer,"%lf",&double_count);
         }

         /*
          * fill in escape sequence 
          */

         if ((*text_string)[i] == 0x14) 
         {
            /* 
             * cntrl t -- substitute horizontal move
             */

            (*text_string)[i + 1] = 'h';
         }
         else if ((*text_string)[i] == 0x16)
         {
            /*
             * cntrl v -- substitue vertical move
             */
    
            (*text_string)[i + 1] = 'v';
         }
         else if ((*text_string)[i] == 0x18)
         {
            /*
             * cntrl x -- substitue x scaling
             */
     
            (*text_string)[i + 1] = 'x';
         }
         else if ((*text_string)[i] == 0x19)
         {
            /*
             * cntrl y -- substitue y scaling
             */
     
            (*text_string)[i + 1] = 'y';
         }
         else if ((*text_string)[i] == 0x13)
         {
            /*
             * cntrl s -- substitue x and y scaling
             */
     
            (*text_string)[i + 1] = 's';
         }
         else if ((*text_string)[i] == 0x11)
         {
            /*
             * cntrl q -- substitue character spacing
             */
     
            (*text_string)[i + 1] = 'C';
         }

         (*text_string)[i] = ESC;

         OM_BLOCK_MOVE(&double_count,&((*text_string)[i + 2]),8);

         i += (add_count + count + 1);

         if (buffer != 0)
         {
            om$dealloc(ptr = buffer);
         }

      }      /* end if (cntrl t,v,x ...) */
      else if ((*text_string)[i] == 0x7)
      {
         /* 
          * justify field -- convert escape sequence number to a char
          */

         j = i + 1;
         count = 0;

         /*
          * calculate how many characters are in the number
          * can only have one or two
          */

         if ((*text_string)[j] >= 0x30 &&
             (*text_string)[j] <= 0x39)
         {
            ++count;     /* increment # of ascii chars in esc seq number */
            ++j;         /* increment position in string */

            if ((*text_string)[j] >= 0x30 &&
                (*text_string)[j] <= 0x39)
            {
               ++count;    /* increment # of ascii chars in esc seq number */
               ++j;        /* increment position in string */
            }
         }

         /*
          * increase the size of the text string by the number
          * of bytes needed to store the escape sequence number as
          * a short and replace the control character with an
          * an escape character
          */

         if (count == 2)
         {
            add_count = 16;
         }
         else if (count == 1)
         {
            add_count = 17;
         }
         else
         {
            add_count = 15;
         }

         /*
          * check to see if the text length exceeds the maximum number of
          * characters; text length is stored in a signed short, so if the
          * length becomes negative, it's too big
          */

         tmp_short = *text_length + add_count;

         if (tmp_short >= 0)
         {
            *text_length = tmp_short;

            if (*text_length > *text_buf_size)
            {
               tmp_short = *text_length + TEXT_BUF_SIZE;

               if (tmp_short >= 0)
               {
                  *text_buf_size = tmp_short;
                  *text_string = (IGRuchar *)om$realloc(ptr = (char *)*text_string,
                                                                size = *text_buf_size);
               }
               else
               {
                  *msg = MSFAIL;
                  goto FINISH;
               }
            }
         }
         else
         {
            *msg = MSFAIL;
            goto FINISH;
         }

         OM_BLOCK_MOVE(&((*text_string)[i + count + 1]),
                       &((*text_string)[i + count + add_count + 1]),
                       (IGRint)(*text_length - (i + add_count + count + 1)));

         result_1 = 0;

         for (k = 0; k < count; ++k)
         {
            char_value = (*text_string)[i + 1 + k] - '0';
            result_1 = result_1 * 10 + char_value;
         }

         (*text_string)[i] = ESC;
         (*text_string)[i + 1] = 'm';
         (*text_string)[i + 2] = result_1;

         h_move = 0.0;
         v_move = 0.0;

         OM_BLOCK_MOVE(&h_move,&((*text_string)[i + 3]),8);
         OM_BLOCK_MOVE(&v_move,&((*text_string)[i + 11]),8);

         i += (add_count + count + 1);

      }      /* end if (cntrl g) */
      else if ((*text_string)[i] == 0x6)
      {
         /*
          * change font -- convert escape sequence name to short number
          */

         j = i + 1;
         count = 0;

         /*
          * search string until comma is reached
          */

         while (((*text_string)[j] != 0x2c) && (j < *text_length))
         {
            ++count;
            ++j;
         }

         /*
          * copy virtual font name in text string into local string
          * and call GRvirt_search to get the virtual font number
          * actually stored in the change font escape sequence
          */

         OM_BLOCK_MOVE(&((*text_string)[i + 1]),font_name,(IGRint)(count));
         font_name[count] = '\0';
         font_num = -1;

         OMmsg = om$send(mode = OM_e_wrt_object,
                         msg = message GRfm.GRvirt_search(msg,
                               font_name,&font_num),
                         senderid = NULL_OBJID,
                         targetid = fontmgr_obj.objid,
                         targetos = cur_mod_osnum);

         if (*msg == MSSUCC)
         {
            /*
             * if necessary, change the size of the text string by the number
             * of bytes needed to store the escape sequence number as
             * a short and replace the control character with an
             * an escape character
             */

            add_count = 3 - (count + 1);

            /*
             * check to see if the text length exceeds the maximum number of
             * characters; text length is stored in a signed short, so if the
             * length becomes negative, it's too big
             */

            tmp_short = *text_length + add_count;

            if (tmp_short >= 0)
            {
               *text_length = tmp_short;

               if (*text_length > *text_buf_size)
               {
                  tmp_short = *text_length + TEXT_BUF_SIZE;

                  if (tmp_short >= 0)
                  {
                     *text_buf_size = tmp_short;
                     *text_string = (IGRuchar *)om$realloc(ptr = (char *)*text_string,
                                                                   size = *text_buf_size);
                  }
                  else
                  {
                     *msg = MSFAIL;
                     goto FINISH;
                  }
               }
            }
            else
            {
               *msg = MSFAIL;
               goto FINISH;
            }

            if (add_count)
            {
               OM_BLOCK_MOVE(&((*text_string)[i + count + 1]),
                             &((*text_string)[i + add_count + count + 1]),
                             (IGRint)(*text_length - (i + add_count + count + 1)));
            }

            (*text_string)[i] = ESC;
            (*text_string)[i + 1] = 'f';

            OM_BLOCK_MOVE(&font_num,&((*text_string)[i + 2]),2);

            i += (add_count + count + 1);

            /*
             * find the current font type (7 or 16 bit)
             */

            OMmsg = om$send(mode = OM_e_wrt_object,
                            msg = message GRfm.GRfm_retdata(msg,
                                  &font_num,&font_info),
                            senderid = NULL_OBJID,
                            targetid = fontmgr_obj.objid,
                            targetos = cur_mod_osnum);

            if (font_info.flags & SIXTEEN_BIT)
            {
               *cur_font_type = sixteen;
            }
            else if (font_info.flags & EIGHT_BIT)
            {
               *cur_font_type = eight;
            }
            else
            {
               *cur_font_type = seven;
            }
         }
         else        /* virtual font name does not exist */
         {
            /*
             * remove control sequence, virtual name, and comma from
             * the text string
             */

               OM_BLOCK_MOVE(&((*text_string)[j + 1]),
                             &((*text_string)[i]),
                             (IGRint)(*text_length - (j + 1)));

               *text_length -= (count + 2);
         }
      }      /* end if (cntrl f) */
      else if ((*text_string)[i] == 0x17)
      {
         /*
          * change weight -- convert escape sequence number to an unsigned char
          */

         result_1 = 0;
         j = i + 1;
         count = 0;

         /*
          * calculate number of chars in field number
          */

         while ((*text_string)[j] >= 0x30 &&
                (*text_string)[j] <= 0x39 && count < 3 &&
                j < *text_length)
         {
            ++count;
            ++j;
         }

         /*
          * convert escape sequence number to char
          */

         for (k = 0; k < count; ++k)
         {
            char_value = (*text_string)[i + 1 + k] - '0';
            result_1 = result_1 * 10 + char_value;
         }

         add_count = 2 - count;

         /*
          * check to see if the text length exceeds the maximum number of
          * characters; text length is stored in a signed short, so if the
          * length becomes negative, it's too big
          */

         tmp_short = *text_length + add_count;

         if (tmp_short >= 0)
         {
            *text_length = tmp_short;

            if (*text_length > *text_buf_size)
            {
               tmp_short = *text_length + TEXT_BUF_SIZE;

               if (tmp_short >= 0)
               {
                  *text_buf_size = tmp_short;
                  *text_string = (IGRuchar *)om$realloc(ptr = (char *)*text_string,
                                                                size = *text_buf_size);
               }
               else
               {
                  *msg = MSFAIL;
                  goto FINISH;
               }
            }
         }
         else
         {
            *msg = MSFAIL;
            goto FINISH;
         }

         if (add_count)
         {
            OM_BLOCK_MOVE(&((*text_string)[i + count + 1]),
                          &((*text_string)[i + add_count + count + 1]),
                          (IGRint)(*text_length - (i + add_count + count + 1)));
         }

         (*text_string)[i] = ESC;
         (*text_string)[i+1] = 'w';
         (*text_string)[i+2] = result_1;
         i += 3;  /* increment past the escape sequence */

      }      /* end if (cntrl w) */
      else if (((*text_string)[i] == 0x2) ||
               ((*text_string)[i] == 0x10))
      {
         field = FALSE;
         result_1 = 0;
         result_2 = 0;
         j = i + 1;
         count = 0;

         /*
          * calculate number of chars in field number
          */

         while ((*text_string)[j] >= 0x30 &&
                (*text_string)[j] <= 0x39 && count < 3 &&
                j < *text_length)
         {
            ++count;
            ++j;
         }

         /*
          * convert escape sequence number to char
          */

         for (k = 0; k < count; ++k)
         {
            char_value = (*text_string)[i + 1 + k] - '0';
            result_1 = result_1 * 10 + char_value;
         }

         /*
          * inclue comma, if there
          */

         if ((*text_string)[j] == 0x2c)
         {
            ++j;
            save_count = count + 1;
            count = 0;

            /*
             * calculate number chars in attribute
             */

            while ((*text_string)[j] >= 0x30 &&
                   (*text_string)[j] <= 0x39 && count < 3 &&
                   j < *text_length)
            {
               ++count;
               ++j;
            }

            /*
             * convert escape sequence to a char
             */

            for (k = 0; k < count; ++k)
            {
               char_value = (*text_string)[i + 1 + save_count + k] - '0';
               result_2 = result_2 * 10 + char_value;
            }
         }

         if ((*text_string)[i] == 0x2)
         {
            field = TRUE;
            add_count = 3 - (count + save_count);
         }
         else if ((*text_string)[i] == 0x10)
         {
            add_count = 19 - (count + save_count);
         }

         /*
          * check to see if the text length exceeds the maximum number of
          * characters; text length is stored in a signed short, so if the
          * length becomes negative, it's too big
          */

         tmp_short = *text_length + add_count;

         if (tmp_short >= 0)
         {
            *text_length = tmp_short;

            if (*text_length > *text_buf_size)
            {
               tmp_short = *text_length + TEXT_BUF_SIZE;

               if (tmp_short >= 0)
               {
                  *text_buf_size = tmp_short;
                  *text_string = (IGRuchar *)om$realloc(ptr = (char *)*text_string,
                                                                size = *text_buf_size);
               }
               else
               {
                  *msg = MSFAIL;
                  goto FINISH;
               }
            }
         }
         else
         {
            *msg = MSFAIL;
            goto FINISH;
         }

         if (add_count)
         {
            OM_BLOCK_MOVE(&((*text_string)[i + count + 1]),
                          &((*text_string)[i + add_count + count + 1]),
                          (IGRint)(*text_length - (i + add_count + count + 1)));
         }

         if (field)
         {
            /*
             * set field escape sequence
             */

            (*text_string)[i] = ESC;
            (*text_string)[i+1] = 'F';
            (*text_string)[i+2] = result_1;
            (*text_string)[i+3] = result_2;

            fld[fld_num] = i;

            if ((*text_string)[i + 4] == 0x7)
            {
               /*
                * make field justified
                */

               fld_just[fld_num] = TRUE;
            }
            else
            {
               fld_just[fld_num] = FALSE;
            }

            ++fld_num;
         }
         else
         {
            /*
             * field reference point move
             */

            (*text_string)[i] = ESC;
            (*text_string)[i + 1] = 'M';
            (*text_string)[i+2] = result_1;
            (*text_string)[i+3] = result_2;

            GRfld_ref_pt(msg,(*text_string),&i,&result_1,
                         &font_info,disp_attr,
                         &(text_symb->Active_linespac),
                         &(text_symb->Active_charspac),
                         &(text_symb->Active_height),
                         &(text_symb->Active_width),
                         &(text_symb->Active_font),
                         &result_2,&h_move,&v_move);

            OM_BLOCK_MOVE(&h_move,&((*text_string)[i + 4]),8);
            OM_BLOCK_MOVE(&v_move,&((*text_string)[i + 12]),8);
         }

         i += (add_count + count + save_count + 1);
      }                              /* end set field escape seq */
      else if ((*text_string)[i] == 0x5)
      {
         /*
          * end field escape sequence; increment length of text string
          */

         /*
          * check to see if the text length exceeds the maximum number of
          * characters; text length is stored in a signed short, so if the
          * length becomes negative, it's too big
          */

         tmp_short = *text_length + 1;

         if (tmp_short >= 0)
         {
            *text_length = tmp_short;

            if (*text_length > *text_buf_size)
            {
               tmp_short = *text_length + TEXT_BUF_SIZE;

               if (tmp_short >= 0)
               {
                  *text_buf_size = tmp_short;
                  *text_string = (IGRuchar *)om$realloc(ptr = (char *)*text_string,
                                                                size = *text_buf_size);
               }
               else
               {
                  *msg = MSFAIL;
                  goto FINISH;
               }
            }
         }
         else
         {
            *msg = MSFAIL;
            goto FINISH;
         }

         OM_BLOCK_MOVE(&((*text_string)[i + 1]),
                       &((*text_string)[i + 2]),
                       (IGRint)(*text_length - (i + 2)));

         (*text_string)[i] = ESC;
         (*text_string)[i + 1] = 'E';

         --fld_num;

         if (fld_just[fld_num] == TRUE)
         {
            OM_BLOCK_MOVE(&((*text_string)[fld[fld_num] + 2]),&temp,1);

            GRjust_field(msg,*text_string,text_length,&temp,&font_info,
                         disp_attr,&(text_symb->Active_linespac),
                         &(text_symb->Active_charspac),
                         &(text_symb->Active_height),
                         &(text_symb->Active_width),
                         &(text_symb->Active_font),
                         &h_move,&v_move);

            OM_BLOCK_MOVE(&h_move,&((*text_string)[fld[fld_num] + 7]),8);
            OM_BLOCK_MOVE(&v_move,&((*text_string)[fld[fld_num] + 15]),8);
         }

         i += 2;
      }
      else if (((*text_string)[i] == 0xa) ||    /* linefeed */
               ((*text_string)[i] == 0xd) ||    /* carriage return */
               ((*text_string)[i] == ESC))      /* escape character */
      {
         if ((*text_string)[i] == 0xd)
         {
            /*
             * change carriage returns into linefeeds
             */

            (*text_string)[i] = 0xa;
         }

         /*
          *  a linefeed or an escape character must be preceeded by
          *  an escape character
          */

         /*
          * check to see if the text length exceeds the maximum number of
          * characters; text length is stored in a signed short, so if the
          * length becomes negative, it's too big
          */

         tmp_short = *text_length + 1;

         if (tmp_short >= 0)
         {
            *text_length = tmp_short;

            if (*text_length > *text_buf_size)
            {
               tmp_short = *text_length + TEXT_BUF_SIZE;

               if (tmp_short >= 0)
               {
                  *text_buf_size = tmp_short;
                  *text_string = (IGRuchar *)om$realloc(ptr = (char *)*text_string,
                                                                size = *text_buf_size);
               }
               else
               {
                  *msg = MSFAIL;
                  goto FINISH;
               }
            }
         }
         else
         {
            *msg = MSFAIL;
            goto FINISH;
         }

         OM_BLOCK_MOVE(&((*text_string)[i]),
                       &((*text_string)[i + 1]),
                       (IGRint)(*text_length - (i + 1)));

         (*text_string)[i] = ESC;
         i += 2;
      }
      else if ((*text_string)[i] == FRACTION_KEY)
      {
         frac_string[0] = 0;
         j = i + 1;
         count = 0;

         while ((*text_string)[j] > 0x2e &&
                (*text_string)[j] < 0x3a &&
                j < *text_length)
         {
            frac_string[count] = (*text_string)[j];
            ++count;
            ++j;
            frac_string[count] = 0;
         }

         GRgen_fraction(msg,frac_string,fraction,&num_chars);

         if (*msg == MSFAIL)
         {
            /*
             * no active fraction font
             */

            ex$message(msgnumb = GR_E_NoActFracFont);

            *text_length -= count + 1;

            OM_BLOCK_MOVE(&((*text_string)[i + count + 1]),
                          &((*text_string)[i]),
                          (IGRint) (*text_length - i));
         }
         else
         {
            add_count = num_chars - count - 1;

            /*
             * check to see if the text length exceeds the maximum number of
             * characters; text length is stored in a signed short, so if the
             * length becomes negative, it's too big
             */

            tmp_short = *text_length + add_count;

            if (tmp_short >= 0)
            {
               *text_length = tmp_short;

               if (*text_length > *text_buf_size)
               {
                  tmp_short = *text_length + TEXT_BUF_SIZE;

                  if (tmp_short >= 0)
                  {
                     *text_buf_size = tmp_short;
                     *text_string = (IGRuchar *)om$realloc(ptr = (char *)*text_string,
                                                                   size = *text_buf_size);
                  }
                  else
                  {
                     *msg = MSFAIL;
                     goto FINISH;
                  }
               }
            }
            else
            {
               *msg = MSFAIL;
               goto FINISH;
            }

            if (add_count)
            {
               OM_BLOCK_MOVE(&((*text_string)[i + count + 1]),
                             &((*text_string)[i + num_chars]),
                             (IGRint)(*text_length - (i + add_count + count + 1)));
            }

            OM_BLOCK_MOVE(fraction,&((*text_string)[i]),num_chars);

            i += num_chars;
         }
      }
      else        /* "regular" character */
      {
         if (issixteen((*text_string)[i]))
         {
            if (*cur_font_type == seven)
            {
               if (active_font_type == eight || active_font_type == sixteen)
               {
                  /*
                   * if active font is 8 or 16 bit then change font
                   * and add character
                   */

                  /*
                   * check to see if the text length exceeds the maximum number of
                   * characters; text length is stored in a signed short, so if the
                   * length becomes negative, it's too big
                   */

                  tmp_short = *text_length + 4;

                  if (tmp_short >= 0)
                  {
                     *text_length = tmp_short;

                     if (*text_length > *text_buf_size)
                     {
                         tmp_short = *text_length + TEXT_BUF_SIZE;

                        if (tmp_short >= 0)
                        {
                           *text_buf_size = tmp_short;
                           *text_string = (IGRuchar *)om$realloc(ptr = (char *)*text_string,
                                                                         size = *text_buf_size);
                        }
                        else
                        {
                           *msg = MSFAIL;
                           goto FINISH;
                        }
                     }
                  }
                  else
                  {
                     *msg = MSFAIL;
                     goto FINISH;
                  }

                  OM_BLOCK_MOVE(&((*text_string)[i]),&((*text_string)[i + 4]),
                                (IGRint)(*text_length - (i + 4)));

                  (*text_string)[i] = ESC;
                  (*text_string)[i + 1] = 'f';

                  OM_BLOCK_MOVE(&(text_symb->Active_font),
                                &((*text_string)[i + 2]),2);

                  if (active_font_type == eight)
                  {
                     *cur_font_type = eight;
                     i += 5;
                  }
                  else
                  {
                     *cur_font_type = sixteen;
                     i += 6;
                  }
               }
               else
               {
                  /*
                   * cannot place 8 or 16 bit characters with a 7 bit
                   * font active
                   */

                  ex$message(msgnumb = GR_E_ActFntNotSxtnBit);

                  *text_length = i;
               }
            }
            else if (*cur_font_type == eight)
            {
               ++i;
            }
            else        /* current font is 16 bit */
            {
               i += 2;
            }
         }
         else      /* character with high order bit clear */
         {
            if (*cur_font_type == sixteen)
            {
               /*
                * current font was sixteen bit, change it to the
                * active ascii font and enter character
                */

               /*
                * check to see if the text length exceeds the maximum number of
                * characters; text length is stored in a signed short, so if the
                * length becomes negative, it's too big
                */

               tmp_short = *text_length + 4;

               if (tmp_short >= 0)
               {
                  *text_length = tmp_short;

                  if (*text_length > *text_buf_size)
                  {
                     tmp_short = *text_length + TEXT_BUF_SIZE;

                     if (tmp_short >= 0)
                     {
                        *text_buf_size = tmp_short;
                        *text_string = (IGRuchar *)om$realloc(ptr = (char *)*text_string,
                                                                      size = *text_buf_size);
                     }
                     else
                     {
                        *msg = MSFAIL;
                        goto FINISH;
                     }
                  }
               }
               else
               {
                  *msg = MSFAIL;
                  goto FINISH;
               }

               OM_BLOCK_MOVE(&((*text_string)[i]),
                             &((*text_string)[i + 4]),
                             (IGRint)(*text_length - (i + 4)));

               (*text_string)[i] = ESC;
               (*text_string)[i + 1] = 'f';

               OM_BLOCK_MOVE(&(text_symb->Active_ascii_font),
                             &((*text_string)[i + 2]),2);

               i += 5;
               *cur_font_type = seven;
            }
            else
            {
               /*
                * simply add character using current font
                */

               ++i;
            }
         }
      }
   }      /* end while (i < text_length ...) */

FINISH:
   return (OM_S_SUCCESS);
} 
end implementation COtext;
