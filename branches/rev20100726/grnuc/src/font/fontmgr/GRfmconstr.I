/* #######################    APOGEE COMPILED   ######################## */


/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS NAME:              GRfm 
     METHOD NAME:             super_construct
 
     Abstract:

        This routine constructs a font manager object when
        initially creating an object space.
        
-----
%SC%

     VALUE =  super_construct()
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE               DESCRIPTION
     ----------   ------------   -----------------------------------

-----
%EX%

     ON EXIT:

        NAME       DATA TYPE               DESCRIPTION
     ----------   ------------   -----------------------------------
     VALUE (IGRlong) =    MSSUCC    - if successful
                          MSFAIL    - if failure
-----
%MD%

     MODULES AND METHODS INVOKED:

     ex$inq_locale

-----
%RL%

      RELATIONS REFERENCED: none

----- 
%NB%

     NOTES:  
-----

%CH%
     CHANGE HISTORY:
        
        DEK  01/09/86 : Design date.
        DEK  01/30/86 : Creation date.
        DEK  09/16/86 : OM 4.0 conversion.
        WBC  03/17/87 : Added a named object for the font manager to
                        the named object directoy IGENOD.
        WBC  10/09/87 : Look for the default font library using
                        ex$get_path
        DEK  11/10/87 : Changes for font server.
        WBC  12/31/87 : Removed code to add named object for the font
                        manager since the get super macro does it.
        DEK  04/27/88 : Added code for fraction fonts.
-----
%PD%
--------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
     OM constructs a font manager object.  If it succeeds the
instance data is filled in with the default values.

----*/
/*EH*/

class implementation   GRfm;

#include  "grimport.h"
#include  "OMmacros.h"
#include  "OMprimitives.h"
#include  "ex.h"
#include  "gr.h"
#include  "igrdp.h"
#include  "fontdef.h"
#include  <stdio.h>
#include  "exlocaledef.h"
#include  "exlocale.h"
#include  "grdpbdef.h"
#include  "grdpb.h"
#include  "grdpbmacros.h"

method super_construct()
{
   IGRlong               msg;                     /* status return code      */
   IGRuchar      alias_name[PATH_LEN];    /* locale logical name     */
   struct EX_fonts       *font_parameters;        /* locale font parameters  */
   struct EX_locale_var  var_list;                /* locale identifiers      */
   IGRlong               nbytes_in_buffer;        /* size of text symb buffer*/
   IGRlong               nbytes_transferred;      /* size actually returned  */
   struct GRdpb_text_symb  text_symbology;        /* dpb text symbology      */
   IGRint                num_fonts;               /* number fonts in alias   */
   IGRshort              i;                       /* index counter           */

   msg = MSSUCC;

   me^^GRfm.fast_font = -1;         /* character fast font undefined */
   me^^GRfm.frac_fast_font = -1;    /* fraction fast font undefined */
   me^^GRfm.symb_fast_font = -1;    /* symbol fast font undefined */
   me^^GRfm.sixteen_fast_font = -1; /* sixteen bit fast font undefined */

   strcpy((char *)alias_name,"default_text");

   /*
    * find out how many fonts are included in the default alias
    */

   var_list.var = EX_number_alias;                                     
   var_list.var_ptr = (char *)&num_fonts;

   ex$inq_locale (msg = &msg,
                  var = &var_list,
                  identifier = (char *)alias_name,
                  flags = EX_Text);

   /* 
    * for each font get its font parameters
    */

   font_parameters = (struct EX_fonts *) om$malloc (size = num_fonts * sizeof(struct EX_fonts));

   var_list.var = EX_alias_fonts;
   var_list.var_ptr = (char *)&font_parameters[0];

   ex$inq_locale (msg = &msg,
                  var = &var_list,
                  flags = EX_Text | EX_Logical_Name,
                  identifier = (char *)alias_name);

   if (msg == EX_Font_Not_Found)
   {
      printf ("ERROR retrieving DEFAULT font. \nNot found in font_table\n");
   }
   else
   {
      om$vla_set_dimension(varray = me^^GRfm.vfont,
                           size = num_fonts);

      i = 0;
      me^^GRfm.num_entries = 0;

      while (i < num_fonts)
      {
         strcpy((char *)(me^^GRfm.vfont[i].fontfile),font_parameters[i].name);
         strcpy((char *)(me^^GRfm.vfont[i].vfontname),font_parameters[i].name);

         ++me^^GRfm.num_entries;
         me^^GRfm.vfont[i].def_flag = defined;

         if (font_parameters[i].properties & EX_Sixteen_Bit)
         {
            if (font_parameters[i].properties & EX_Text_Font)
            {
               me^^GRfm.vfont[i].flags = TEXT_FONT | SIXTEEN_BIT;
            }
            else if (font_parameters[i].properties & EX_Frac_Font)
            {
               me^^GRfm.vfont[i].flags = FRACTION_FONT | SIXTEEN_BIT;
            }
            else if (font_parameters[i].properties & EX_Symb_Font)
            {
               me^^GRfm.vfont[i].flags = SYMBOL_FONT | SIXTEEN_BIT;
            }
         }
         else if (font_parameters[i].properties & EX_Eight_Bit)
         {
            if (font_parameters[i].properties & EX_Text_Font)
            {
               me^^GRfm.vfont[i].flags = TEXT_FONT | EIGHT_BIT;
            }
            else if (font_parameters[i].properties & EX_Frac_Font)
            {
               me^^GRfm.vfont[i].flags = FRACTION_FONT | EIGHT_BIT;
            }
            else if (font_parameters[i].properties & EX_Symb_Font)
            {
               me^^GRfm.vfont[i].flags = SYMBOL_FONT | EIGHT_BIT;
            }
         }
         else      /* seven bit font */
         {
            if (font_parameters[i].properties & EX_Text_Font)
            {
               me^^GRfm.vfont[i].flags = TEXT_FONT;
            }
            else if (font_parameters[i].properties & EX_Frac_Font)
            {
               me^^GRfm.vfont[i].flags = FRACTION_FONT;
            }
            else if (font_parameters[i].properties & EX_Symb_Font)
            {
               me^^GRfm.vfont[i].flags = SYMBOL_FONT;
            }
         }

         if ((font_parameters[i].properties & EX_Text_Font) &&
             !(font_parameters[i].properties & EX_Sixteen_Bit) &&
             (me^^GRfm.fast_font == -1))
         {
            me^^GRfm.fast_font = i;
         }
         else if ((font_parameters[i].properties & EX_Frac_Font) &&
                  (me^^GRfm.frac_fast_font == -1))
         {
            me^^GRfm.frac_fast_font = i;
         }
         else if ((font_parameters[i].properties & EX_Symb_Font) &&
                  (me^^GRfm.symb_fast_font == -1))
         {
            me^^GRfm.symb_fast_font = i;
         }
         else if ((font_parameters[i].properties & EX_Sixteen_Bit) &&
                  (me^^GRfm.sixteen_fast_font == -1))
         {
            me^^GRfm.sixteen_fast_font = i;
         }

         ++i;
      }

      om$dealloc(ptr = font_parameters);

      /*
       * need to set active fonts in the dpb also
       */

      nbytes_in_buffer = sizeof(struct GRdpb_text_symb);

      gr$get_text_symb(msg = &msg,
                       sizbuf = &nbytes_in_buffer,
                       buffer = &text_symbology,
                       nret = &nbytes_transferred);

      text_symbology.Active_font = me^^GRfm.fast_font;
      text_symbology.Active_fraction_font = me^^GRfm.frac_fast_font;
      text_symbology.Active_symbol_font = me^^GRfm.symb_fast_font;

      gr$put_text_symb(msg = &msg,
                       sizbuf = &nbytes_in_buffer,
                       buffer = &text_symbology);
   }

   return(msg);

}

end implementation GRfm;
