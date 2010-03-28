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
     METHOD NAME:             GRclean_up
 
     Abstract:
                This routine restores the memory a font is using.  
                If only one font manager using the font, the font
                is taken offline and deleted from the cache.

-----
%SC%

    VALUE = GRclean_up(IGRlong *msg; IGRshort *position)
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
        
        DEK  11/10/87 : Design date.
        DEK  11/10/87 : Creation date.
-----
%PD%
--------------------------------------------------------------------
               M E T H O D    D E S C R I P T I O N
--------------------------------------------------------------------
     This routine restores the memory a font is using.  If only one
font manager using the font, the font is taken offline and deleted
from the cache.

----*/
/*EH*/

class implementation GRfm;

#include  "grimport.h"
#include  "OMerrordef.h"
#include  "gr.h"
#include  "codef.h"
#include  "exmacros.h"
#include  "FS.h"
#include  "femacros.h"

from GRmodule import GRdel_fnt;

method GRclean_up(IGRlong *msg; IGRshort *position)
{
    IGRlong     OMmsg, temp_msg;
    struct GRid mod_id;

    OMmsg = OM_S_SUCCESS;
    *msg = MSSUCC;

    /*
     *  Call the font executive (FE) notifying it which font
     *  is to be deleted.
     */

    fe$rm_font(msg = &temp_msg,
               font_id = me^^GRfm.vfont[*position].fontid);

    /*
     *  Send a message to module notifying it which font is being deleted
     *  from which font manager.
     */

    mod_id.osnum = OM_Gw_current_OS;
    ex$get_modid (mod_osnum = OM_Gw_current_OS, mod_id = &mod_id.objid);

    OMmsg = om$send(mode = OM_e_wrt_object,
                    msg = message GRmodule.GRdel_fnt(&temp_msg,*position),
                    senderid = my_id,
                    targetid = mod_id.objid);

    if (COERROR(OMmsg))
    {
        *msg = MSFAIL;
        OMmsg = OM_E_ABORT;
    }
    else if (COERROR(temp_msg))
    {
        *msg = MSFAIL;
    }

    return(OMmsg);
}

end implementation GRfm;
