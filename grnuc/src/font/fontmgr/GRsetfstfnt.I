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
              intergraph and/or other  third parties which is
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

     CLASS NAME:              GRfm 
     METHOD NAME:             GRset_fast_fnt
 
     Abstract:

                This routine sets either the fast character font to 
            the specified (virtual) font or the fast fraction font to
            the specified (virtual) font.  All the undefined fonts'
            font ids will point to the new fast font.
-----
%SC%

    VALUE = GRset_fast_fnt(IGRlong *msg; IGRshort *vfont_num; IGRchar type)
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                      DESCRIPTION
    -----------   ---------------   -----------------------------------
    *vfont_num    IGRshort          virtual font number
    type          IGRchar           type of font - TEXT or FRACTION
-----
%EX%

     ON EXIT:

        NAME         DATA TYPE                      DESCRIPTION
     ----------     -------------- -------------------------------------------
     *msg           IGRlong        completion code

     VALUE (IGRlong) =    MSSUCC   - if successful
                          MSFAIL   - if failure
-----
%MD%

     MODULES AND METHODS INVOKED:

     modules:

     methods:   GRchg_fst_fnt

-----
%RL%

      RELATIONS REFERENCED:

----- 
%NB%

     NOTES:  
-----

%CH%
     CHANGE HISTORY:
        
        WBC  04/01/86 : Design date.
        WBC  04/29/86 : Creation date.
        DEK  11/11/87 : Changed for font server.
        DEK  04/15/88 : Fraction capability added.
-----
%PD%
--------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
     This routine sets either the fast character font to the 
specified (virtual) font or the fast fraction font to the specified 
(virtual) font.  All the undefined fonts' font ids will point to the 
new fast font.
----*/
/*EH*/

class implementation GRfm;

#include  "grimport.h"
#include  "OMerrordef.h"
#include  "gr.h"
#include  "codef.h"
#include  "exmacros.h"

from GRmodule import GRchg_fst_fnt;

method GRset_fast_fnt(IGRlong *msg; IGRshort *vfont_num; IGRchar type)
{
   IGRlong     OMmsg;                   /* OM return code            */
   IGRshort    index;                   /* index counter             */
   struct GRid mod_id;                  /* module id                 */
   IGRshort    fraction_font;           /* fraction font to use for
                                           module                    */
   IGRshort    sixteen_font;            /* sixteen bit font to use   */

   *msg = MSSUCC;
   OMmsg = OM_S_SUCCESS;

   if (type == TEXT_FONT)
   {
      if (me^^GRfm.vfont[*vfont_num].flags & TEXT_FONT)
      {
         /*
          *  If "changing" to the current text fast font, do nothing.
          */

         if (*vfont_num != me^^GRfm.fast_font)
         {
            /*
             *  Change the fast text font indicator to the new fast
             *  font and the font ids of the undefined fonts to the
             *  character fast font's font id.
             */

            me^^GRfm.fast_font = *vfont_num;

            for (index=0; index < me^^GRfm.num_entries; ++index)
            {
               if ((me^^GRfm.vfont[index].def_flag != defined) &&
                   (me^^GRfm.vfont[index].flags & TEXT_FONT))
               {
                  me^^GRfm.vfont[index].fontid = me^^GRfm.vfont[*vfont_num].fontid;
               }
            }
         }
      }
      else               /* vfont_num font is not a text font */
      {
         *msg = MSFAIL;
      }           
   }
   else if (type == FRACTION_FONT)
   {
      if (me^^GRfm.vfont[*vfont_num].flags & FRACTION_FONT)
      {
         /*
          *  If "changing" to the current fraction fast font, do nothing.
          */

         if (*vfont_num != me^^GRfm.frac_fast_font)
         {
            /*
             *  Change the fast fraction font indicator to the new fast
             *  font and the font ids of the undefined fonts to the
             *  character fast font's font id.
             */

            me^^GRfm.frac_fast_font = *vfont_num;

            for (index = 0; index < me^^GRfm.num_entries; ++index)
            {
               if ((me^^GRfm.vfont[index].def_flag != defined) &&
                   (me^^GRfm.vfont[index].flags & FRACTION_FONT))
               {
                  me^^GRfm.vfont[index].fontid = me^^GRfm.vfont[*vfont_num].fontid;
               }
            }
         }
      }
      else               /* vfont_num font is not a fraction font */
      {
         *msg = MSFAIL;
      }           
   }

   if (*msg == MSSUCC)
   {
      /*
       *  Send a message to module notifying it of which font is now the
       *  fast font.
       */

      mod_id.osnum = OM_Gw_current_OS;
      ex$get_modid (mod_osnum = OM_Gw_current_OS, 
                    mod_id = &mod_id.objid);

      if (me^^GRfm.frac_fast_font == -1)
      {
          fraction_font = me^^GRfm.fast_font;
      }
      else 
      {
          fraction_font = me^^GRfm.frac_fast_font;
      }

      if (me^^GRfm.sixteen_fast_font == -1)
      {
         sixteen_font = me^^GRfm.fast_font;
      }
      else
      {
         sixteen_font = me^^GRfm.sixteen_fast_font;
      }

      OMmsg = om$send(mode = OM_e_wrt_object,
                      msg = message GRmodule.GRchg_fst_fnt
                            (msg,me^^GRfm.fast_font,fraction_font,
                             sixteen_font),
                      senderid = my_id,
                      targetid = mod_id.objid);

      if (COERROR(OMmsg))
      {
          OMmsg = OM_E_ABORT;
          *msg = MSFAIL;
      }
   }

   return(OMmsg);
}

end implementation GRfm;
