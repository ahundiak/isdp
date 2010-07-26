/* #######################    APOGEE COMPILED   ######################## */

/*----
%GP% CODE CLASSIFICATION                           
----
%HD%

     CLASS NAME:              GRfm
     METHOD NAME:             GRwake_up
 
     Abstract:

        This routine initializes a font manager object when
        bringing up an object space. The specified fonts will be
        retrieved and the undefined font's font id will be 
        initialized to the fast font's font id.
-----
%SC%

     VALUE =  GRwake_up
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

     modules:  

     methods:  GRmodule.GRadd_fnt_tbl
               GRmake_entry
-----
%RL%

      RELATIONS REFERENCED:

----- 
%NB%

     NOTES:  
-----

%CH%
     CHANGE HISTORY:
        
        DEK  05/07/86 : Design date.
        DEK  05/14/86 : Creation date.
        DEK  09/16/86 : OM 4.0 conversion.
        DEK  11/10/87 : Changed for font server.
        DEK  04/15/88 : Capability for fractions and use of locale added.
        WBC  02/09/93 : Changed the call to fill in error_msg using
                        "type" and "var".
-----
%PD%
--------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
   This routine initializes a font manager object when bringing up 
an object space. The specified fonts will be retrieved, the undefined
text fonts' fontid will be initialized to the fast text font's fontid,
and the undefined fraction fonts' fontid will be initialized to the
fast fraction font's fontid.
----*/
/*EH*/

class implementation   GRfm;

#include  "grimport.h"
#include  "OMerrordef.h"
#include  "gr.h"
#include  "codef.h"
#include  "exdef.h"
#include  "ex.h"
#include  "exmacros.h"
#include  "fontdef.h"
#include  <stdio.h>
#include  "exlocaledef.h"
#include  "exlocale.h"
#include  "grmessage.h"
#include  "msmacros.h"

#define LOCAL_ERROR_BUF_SIZE 128

from GRmodule import GRadd_fnt_tbl;

method wake_up ()

{
   IGRlong               OMmsg,temp_msg;        /* status return codes       */
   IGRshort              text_dwn_loaded_font;  /* last text font downloaded */
   IGRshort              frac_dwn_loaded_font;  /* last frac font downloaded */
   IGRint                i;                     /* index counter             */
 /*  IGRint                status = TRUE; */
   struct GRid           mod_id;                /* module id                 */
   struct EX_locale_var  var_list;              /* locale identifiers        */

   OMmsg = OM_S_SUCCESS;

   if (!ex$is_temp_wakeup())
   {
      mod_id.osnum = OM_Gw_current_OS;
      ex$get_modid (mod_osnum = OM_Gw_current_OS, mod_id = &mod_id.objid);

      text_dwn_loaded_font = -1;
      frac_dwn_loaded_font = -1;

      OMmsg = om$send(mode = OM_e_wrt_object,
                      msg = message GRmodule.GRadd_fnt_tbl(&temp_msg,
                            me^^GRfm.fast_font,me^^GRfm.frac_fast_font,
                            me^^GRfm.sixteen_fast_font),
                      senderid = my_id,
                      targetid = mod_id.objid);

      if ((!COERROR(OMmsg)) && (!COERROR(temp_msg)))
      {
         for (i = 0; i < me^^GRfm.num_entries; ++i)
         {
            if ((me^^GRfm.vfont[i].def_flag == defined) ||
                (me^^GRfm.vfont[i].def_flag == reserved))
            {
               /*
                * if font was previously defined, download it
                */

	       IGRshort ii;
	       ii = ( IGRshort ) i;
               OMmsg = om$send(mode = OM_e_wrt_object,
                               msg = message GRfm.GRmake_entry(&temp_msg,
                                     (IGRuchar *)me^^GRfm.vfont[i].fontfile,
                                     (IGRuchar *)me^^GRfm.vfont[i].vfontname,
                                     me^^GRfm.vfont[i].flags,&ii),
                               senderid = my_id,
                               targetid = my_id);

               if ((COERROR(OMmsg)) || (COERROR(temp_msg)))
               {
                  IGRchar   error_msg[LOCAL_ERROR_BUF_SIZE];

                  me^^GRfm.vfont[i].def_flag = reserved;

                  ex$message(msgnumb = GR_E_CantLdFt,
                             buff = error_msg,
                             type = "%s",
                             var = me^^GRfm.vfont[i].fontfile,
                             buffer_size = LOCAL_ERROR_BUF_SIZE);

                  printf("%s\n",error_msg);
               }
               else
               {
                  if (me^^GRfm.vfont[i].flags & TEXT_FONT)
                  {
                     text_dwn_loaded_font = i; /* last text font downloaded */
                  }
                  else if (me^^GRfm.vfont[i].flags & FRACTION_FONT)
                  {
                     frac_dwn_loaded_font = i; /* last frac font downloaded */
                  }
               }
            }               /* end if defined */
         }                /* end entry */

         /*
          *  If the fast text font was not downloaded but another text font
          *  was, make the last text font downloaded the fast font.  If no
          *  text fonts were downloaded, try to download the default text
          *  fast font.
          */

         if (me^^GRfm.vfont[me^^GRfm.fast_font].def_flag != defined)
         {
            if (text_dwn_loaded_font > -1)  /* at least one font downloaded */
            {
               me^^GRfm.fast_font = text_dwn_loaded_font;
            }
            else       /* no text fonts were downloaded */
            {
               IGRint          num_fonts;        /* number fonts in alias  */
               IGRchar         alias_name[13];
               IGRshort        font_flags;
               IGRshort        font_index;
               struct EX_fonts *default_font_params; /* locale font parameters */

               /*
                * find out how many fonts are included in the default alias
                */

               var_list.var = EX_number_alias;
               var_list.var_ptr = (IGRchar *)&num_fonts;
               strcpy(alias_name,"default_text");

               ex$inq_locale (msg = &temp_msg,
                              var = &var_list,
                              identifier = alias_name,
                              flags = EX_Text);

               if ((temp_msg == EX_Success) && (num_fonts > 0))
               {
                  /* 
                   * for each font get its font parameters
                   */

                  if (default_font_params = (struct EX_fonts *) om$malloc (size = num_fonts * sizeof(struct EX_fonts)))
                  {
                     var_list.var = EX_alias_fonts;
                     var_list.var_ptr = (IGRchar *)default_font_params;

                     ex$inq_locale (msg = &temp_msg,
                                    var = &var_list,
                                    flags = EX_Text | EX_Logical_Name,
                                    identifier = alias_name);

                     if (temp_msg == EX_Success)
                     {
                        /*
                         * find the default text font
                         */

                        for (i = 0; i < num_fonts; ++i)
                        {
                           if (default_font_params[i].properties & EX_Sixteen_Bit)
                           {
                              font_flags = SIXTEEN_BIT;
                           }
                           else if (default_font_params[i].properties & EX_Eight_Bit)
                           {
                              font_flags = EIGHT_BIT;
                           }
                           else  /* 7 bit text */
                           {
                              font_flags = 0;
                           }

                           if (default_font_params[i].properties & EX_Text_Font)
                           {
                              font_flags |= TEXT_FONT;
                           }
                           else if (default_font_params[i].properties & EX_Frac_Font)
                           {
                              font_flags |= FRACTION_FONT;
                           }
                           else if (default_font_params[i].properties & EX_Symb_Font)
                           {
                              font_flags |= SYMBOL_FONT;
                           }

                           font_index = -1;  /* use first available entry */

                           OMmsg = om$send(mode = OM_e_wrt_object,
                                           msg = message GRfm.GRmake_entry(&temp_msg,
                                                (IGRuchar *)default_font_params[i].name,
                                                (IGRuchar *)default_font_params[i].name,
                                                font_flags,
                                                &font_index),
                                           senderid = my_id,
                                           targetid = my_id);

                           if ((! COERROR(OMmsg)) && (! COERROR(temp_msg)))
                           {
                              me^^GRfm.vfont[font_index].def_flag = defined;
                              strcpy(
                                (char *)(me^^GRfm.vfont[font_index].fontfile),
                                 default_font_params[i].name);
                              strcpy(
                                (char *)(me^^GRfm.vfont[font_index].vfontname),
                                 default_font_params[i].name);
                              me^^GRfm.vfont[font_index].flags = font_flags;

                              if ((font_flags & TEXT_FONT) &&
                                  !(font_flags & SIXTEEN_BIT))
                              {
                                 me^^GRfm.fast_font = font_index;
                              }
                              else if (font_flags & FRACTION_FONT)
                              {
                                 me^^GRfm.frac_fast_font = font_index;
                              }
                              else if (font_flags & SYMBOL_FONT)
                              {
                                 me^^GRfm.symb_fast_font = font_index;
                              }
                              else if (font_flags & SIXTEEN_BIT)
                              {
                                 me^^GRfm.sixteen_fast_font = font_index;
                              }
                           }
                        }
                     }
                     om$dealloc(ptr = default_font_params);
                  }
               }
            }         /* end "if no fonts downloaded" */
         }

         /*
          *  initialize undefined text font entries' font id to the fast
          *  text font's font id
          */

         if (me^^GRfm.vfont[me^^GRfm.fast_font].def_flag == defined)
         {
            for (i=0; i < me^^GRfm.num_entries; ++i)
            {
               if ((me^^GRfm.vfont[i].def_flag != defined) &&
                   (me^^GRfm.vfont[i].flags & TEXT_FONT))
               {
                  me^^GRfm.vfont[i].fontid = me^^GRfm.vfont[me^^GRfm.fast_font].fontid;
               }
            }
         }

         /*
          *  If the fast fraction font was not downloaded but another fraction
          *  font was, make the last fraction font downloaded the fast font. If
          *  no fraction fonts were downloaded, set the fast fraction font to
          *  be undefined.
          */

         if (me^^GRfm.vfont[me^^GRfm.frac_fast_font].def_flag != defined)
         {
            if (frac_dwn_loaded_font > -1)  /* at least one font downloaded */
            {
               me^^GRfm.frac_fast_font = frac_dwn_loaded_font;
            }
            else      /* no fraction fonts were downloaded */
            {
               me^^GRfm.frac_fast_font = -1;
            }
         }

         /*
          *  initialize undefined fraction font entries' font id to the fast
          *  fraction font's font id
          */

         if ((me^^GRfm.frac_fast_font != -1) &&
             (me^^GRfm.vfont[me^^GRfm.frac_fast_font].def_flag == defined))
         {
            for (i=0; i < me^^GRfm.num_entries; ++i)
            {
               if ((me^^GRfm.vfont[i].def_flag != defined) &&
                   (me^^GRfm.vfont[i].flags & FRACTION_FONT))
               {
                  me^^GRfm.vfont[i].fontid = me^^GRfm.vfont[me^^GRfm.frac_fast_font].fontid;
               }
            }
         }
      }
      else          /* error in creating module's font table */
      {
         if (COERROR(OMmsg))
         {
            OMmsg = OM_E_ABORT;
         }
      }
   }

   return(OMmsg);
}

end implementation GRfm;
