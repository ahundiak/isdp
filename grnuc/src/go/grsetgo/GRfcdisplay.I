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

/*
Name
        GSdisplay 

Description
        This method is used to display the objects owned by the fence set.
   
Synopsis
        IGRlong         *msg            return code
                                            MSSUCC  -- successful completion
                                            MSFAIL  -- failure
        enum GRdpode    *dpmode         An enum type representing display mode
        struct GRid     *display_id     Object id of the window or module

History
        Gray Winn   11/02/86    Creation date.
*/

class implementation GRfcset;

#include "grimport.h"
#include "msdef.h"
#include "grgsdef.h"

method GSdisplay (IGRlong *msg; enum GRdpmode *dpmode; struct GRid *display_id)
{
    IGRlong sts;

    *msg = MSSUCC;

    /*
     *  If dpmode == background erase and post processing is set
     *  then perform post processing.
     */

    if ((*dpmode == GRbe) || (*dpmode == GRbehe) || (*dpmode == GRbehd))
    {
        if (me->properties & GRIS_POST_PROCESSING)
        {
            sts = om$send (msg = message GRgrset.GSpost_processing
                                (msg, NULL, NULL, 0),
                           targetid = my_id);
        }
    }

    /*
     *  Send the display request to my owner.
     */

    sts = om$send (mode = OM_e_wrt_message,
                   msg = message GRgrset.GSdisplay (msg, dpmode, display_id),
                   targetid = my_id);

    return (sts);
}
end implementation GRfcset;

