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
        This method is used to display the objects owned by the graphics set.
   
Synopsis
        IGRlong         *msg            return code
                                           MSSUCC: successful completion
                                           MSFAIL: failure
        enum GRdpmode   *dpmode         An enum type representing display mode
        struct GRid     *display_id     Object id of the window or module

History
        Gray Winn   11/02/86    Creation date
        mrm         08/31/89    allow highlight
                    10/04/89    send display to overlap objects for fences
*/

class implementation GRgrset;

#include "grimport.h"
#include "msdef.h"
#include "grgsdef.h"

method GSdisplay (IGRlong *msg;
                  enum GRdpmode *dpmode; 
                  struct GRid *display_id)
{
    IGRlong           sts, cmsg;
    OM_S_CHANSELECT   chansel;

    *msg = MSSUCC;

    if (!(me->properties & GRIS_DISPLAY_ALL))
    {
        switch (*dpmode)
        {
            case GRbdhd:
            case GRbdhe:
                if (me->properties & GRIS_BACKGROUND_DISPLAY)
                {  
                    return (OM_S_SUCCESS);
                }
                else
                {
                    me->properties |= GRIS_BACKGROUND_DISPLAY;
                }
                break;

            case GRbehe:
            case GRbehd:
                if (me->properties & GRIS_BACKGROUND_DISPLAY)
                {  
                    me->properties &= (0xffffffff ^ GRIS_BACKGROUND_DISPLAY);
                }
                else
                {
                    return (OM_S_SUCCESS);
                }
                break;
        }
    }
   
    /*
     *  Send the display message to the save sets
     */

    om$make_chanselect (channame = "GRgrset.to_sets",
                        p_chanselect = &chansel);

    sts = om$send (msg = message GRgrset.GSdisplay (msg, dpmode, display_id),
                   p_chanselect = &chansel);

    /*
     *  send the display message to the objects on the clip_overlap
     *  channel - this will only work for fence sets
     */

    om$make_chanselect (channame = "GRfcset.clip_overlap",
                        p_chanselect = &chansel);

    om$send (msg = message GRgrset.GSdisplay (&cmsg, dpmode, display_id),
             p_chanselect = &chansel);


    return (sts);
}
end implementation GRgrset;
