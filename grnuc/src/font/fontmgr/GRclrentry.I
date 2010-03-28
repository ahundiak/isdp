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
     METHOD NAME:             GRclear_entry
 
     Abstract:

                This routine deletes a specified font.  The fast character
                font and the fast fraction font will not be deleted. The 
                font entry's def_flag is set to undefined and the font file
                name and the virtual font name are set to NULL. If this is
                the only font manager using the font, the font is taken 
                offline and deleted from the cache.
-----
%SC%

    VALUE = GRclear_entry(IGRlong *msg; IGRshort *position)
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE                      DESCRIPTION
    -----------   ---------------   -----------------------------------
    *position     IGRshort          virtual font number
-----
%EX%

     ON EXIT:

        NAME         DATA TYPE                      DESCRIPTION
     ----------     -------------- -------------------------------------------
     *msg           IGRlong        completion code

     VALUE (IGRlong) =    MSSUCC   - if successful
                          MSFAIL   - if failure
                          MSINARG  - if attempting to delete the fast font
-----
%MD%

     MODULES AND METHODS INVOKED:

     modules:  fe$rm_font

     methods:  GRmodule.GRdel_fnt
-----
%RL%

      RELATIONS REFERENCED: none

----- 
%NB%

     NOTES:  
-----

%CH%
     CHANGE HISTORY:
        
        WBC  02/19/86 : Design date.
        WBC  02/21/86 : Creation date.
        DEK  04/28/86 : Modified to accept position instead of name.
        DEK  07/20/87 : Implemented font executive calls.
        DEK  11/10/87 : Changed for font server.
        DEK  04/15/88 : Fraction capability added.
-----
%PD%
--------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
     This method deletes a specified font.  The character fast font
and the fraction fast font will not be deleted. The virtual font 
number is given, and a macro call is sent to the font executive 
indicating which font is to be deleted. If no other font manager is 
using this font, the font is taken offline and deleted from cache.
Module is sent a message indicating which font is being deleted. The 
font is initialized to undefined and the font file and virtual font 
name are initialized to NULL.  
----*/
/*EH*/

class implementation GRfm;

#include  "grimport.h"
#include  "OMerrordef.h"
#include  "gr.h"
#include  "codef.h"
#include  "exmacros.h"
#include  "OMmacros.h"
#include  "FS.h"
#include  "femacros.h"

from GRmodule import GRdel_fnt;

method GRclear_entry(IGRlong *msg; IGRshort *position)
{
    IGRlong           OMmsg;                   /* status return codes    */
    struct GRid       mod_id;                  /* module os and objid    */

    OMmsg = OM_S_SUCCESS;
    *msg = MSSUCC;

    /*
     *  Not allowed to delete fast character font or fast fraction font
     */

    if ((*position != me^^GRfm.fast_font) && (*position != me^^GRfm.frac_fast_font))
    {
       /*
        *  Call the font executive (FE) notifying it which font
        *  is to be deleted.
        */

       fe$rm_font(msg = msg,
                  font_id = me^^GRfm.vfont[*position].fontid);

       /*
        *  Send a message to module notifying it which font is being deleted
        *  from which font manager.
        */

       mod_id.osnum = OM_Gw_current_OS;
       ex$get_modid (mod_osnum = OM_Gw_current_OS, mod_id = &mod_id.objid);


       OMmsg = om$send(mode = OM_e_wrt_object,
                       msg = message GRmodule.GRdel_fnt(msg,*position),
                       senderid = my_id,
                       targetid = mod_id.objid);

       if (COERROR(OMmsg))
       {
           *msg = MSFAIL;
           OMmsg = OM_E_ABORT;
       }
       else if (COERROR(*msg))
       {
           *msg = MSFAIL;
       }
       else
       {
          /*
           *  Change the font id to the fast font's id, set def_flag
           *  to undefined and delete (erase) the font file and the
           *  virtual font name.
           */

          if (me^^GRfm.vfont[*position].flags & TEXT_FONT)
          {
             me^^GRfm.vfont[*position].fontid = me^^GRfm.vfont[me^^GRfm.fast_font].fontid;
             me^^GRfm.vfont[*position].bodysize = me^^GRfm.vfont[me^^GRfm.fast_font].bodysize;
             me^^GRfm.vfont[*position].descent = me^^GRfm.vfont[me^^GRfm.fast_font].descent;
             me^^GRfm.vfont[*position].flags = me^^GRfm.vfont[me^^GRfm.fast_font].flags;
             me^^GRfm.vfont[*position].def_flag = undefined;
             me^^GRfm.vfont[*position].fontfile[0] = NULL;
             me^^GRfm.vfont[*position].vfontname[0] = NULL;
          }
          else if (me^^GRfm.vfont[*position].flags & FRACTION_FONT)
          {
             me^^GRfm.vfont[*position].fontid = me^^GRfm.vfont[me^^GRfm.frac_fast_font].fontid;
             me^^GRfm.vfont[*position].bodysize = me^^GRfm.vfont[me^^GRfm.frac_fast_font].bodysize;
             me^^GRfm.vfont[*position].descent = me^^GRfm.vfont[me^^GRfm.frac_fast_font].descent;
             me^^GRfm.vfont[*position].flags = me^^GRfm.vfont[me^^GRfm.frac_fast_font].flags;
             me^^GRfm.vfont[*position].def_flag = undefined;
             me^^GRfm.vfont[*position].fontfile[0] = NULL;
             me^^GRfm.vfont[*position].vfontname[0] = NULL;
          }
       }
    }
    else
    {
       *msg = MSFAIL;
    }


    return(OMmsg);
}

end implementation GRfm;
