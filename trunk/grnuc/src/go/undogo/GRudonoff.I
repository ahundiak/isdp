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

/*
Name
        GRudonoff
Synopsis
        method GRudonoff (IGRlong *msg)

Description
        This method toggles the undo status -- i.e. if undo is on 
        then it is turned off and vice versa.  If anything is saved on the
        undo channel (from a previous manipulation) when undo is turned
        off then it is deleted.

History
        mrm     10/22/86    Creation
                04/29/88    channel name changes
                06/23/89    don't count on me->can_undo; check channel count
*/

class implementation GRundo;

#include "grimport.h"
#include "grgsmacros.h"
#include "OMerrordef.h"
#include "msdef.h"

from GRgraphics import GRdelete;

method GRudonoff (IGRlong *msg; IGRint *undo_on)
{
    IGRlong         sts;
    OMuint          object_count;
    OM_S_CHANSELECT undo_chansel;

#ifdef DEBUG
    puts ("GRundo.GRudonoff: entry");
#endif

    *msg = MSSUCC;
    sts = OM_S_SUCCESS;

    if (me->undo_on)
    {
#ifdef DEBUG
        puts ("GRundo.GRudonoff: undo is on, turning off");
#endif
        /*
         *  send delete message out undo_chan, if necessary
         */

        if (me->can_undo)   /* implies that something is on undo_chan */
        {
#ifdef DEBUG
            puts ("GRundo.GRudonoff: deleting saved object(s)");
#endif
            if (me->was_gra_set)
            {
                sts = om$make_chanselect (channame = "GRundo.to_grset",
                                          p_chanselect = &undo_chansel);

                if (!(sts & *msg & 1)) goto finish;

                /* make sure that there is something on the channel */

                sts = om$get_channel_count (object = me,
                                            p_chanselect = &undo_chansel,
                                            count = &object_count);

                if ((sts & 1) && object_count)
                {
                    sts = gr$gsdelete (msg = msg,
                                       p_chanselect = &undo_chansel);

                    if (!(sts & *msg & 1)) goto finish;

                    sts = gr$gsdissolve (msg = msg,
                                         p_chanselect = &undo_chansel);
                }
            }
            else
            {
                sts = om$make_chanselect (channame = "GRcmpowner.to_components",
                                          p_chanselect = &undo_chansel);

                if (!(sts & *msg & 1)) goto finish;

                /* make sure that there is something on the channel */

                sts = om$get_channel_count (object = me,
                                            p_chanselect = &undo_chansel,
                                            count = &object_count);

                if ((sts & 1) && object_count)
                {
                    sts = om$send (msg = message GRgraphics.GRdelete
                                           (msg, &me->context),
                                   p_chanselect = &undo_chansel);
                }
            }

            me->can_undo = FALSE;
#ifdef DEBUG
            puts ("GRundo.GRudonoff: object(s) deleted");
#endif
        }

        me->undo_on = FALSE;
        *undo_on = FALSE;
    }
    else
    {
#ifdef DEBUG
        puts ("GRundo.GRudonoff: undo is off, turning on");
#endif
        me->can_undo = FALSE;
        me->undo_on = TRUE;
        *undo_on = TRUE;
    }

finish:

#ifdef DEBUG
    puts ("GRundo.GRudonoff: exit");
    if (!(*msg & 1)) printf ("GRundo.GRudonoff: msg = 0x%x\n", *msg);
    if (!(sts & 1)) om$report_error (sts = sts);
#endif

    return (sts);
}
end implementation GRundo;
