/*
Name
        COgsmanip - init, wakeup, sleep, delete

Synopsis
        usual CO argument lists

Description
        init - initialize instance variables, construct and connect to 
            a graphics set, get the current module information

        wakeup - if elements should be highlighted, check to see if they are
            valid and highlight them, else if not valid restart command

        sleep -  unhighlight the elements in the graphics set, if any are
            present, clear prompt and message fields

        delete - delete graphics set & self
History
        JFH     05/01/86    creation
        mrm     06/06/86    added init method
        mrm     06/12/86    initialize locate & relocate prompts,
                            construct save set
        mrm     08/20/86    added delete method
        mrm     09/22/86    OM 4.0 conversion
        hgw/mrm 10/08/86    conversion to graphics set
        mrm     02/10/87    wakeup method check for objects on the graphic set
        mrm     03/09/87    revise include files
        mrm     03/23/87    clear Variable String Descriptor
        mrm     04/10/87    set up properties & owner action for locate
        mrm     07/06/87    or LC_REF_HEADER, LCREF_OBJECTS in owner action
        vasu    07/31/87    message file used to extract messages
        mrm     09/25/87    use dp$erase_hilite in sleep
*/

class implementation COgsmanip;

#include "msdef.h"
#include "grmessage.h"
#include "msmacros.h"
#include "dpmacros.h"
#include "ex.h"
#include "grio.h"
#include "griomacros.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "grgsmacros.h"

/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             init                                 */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method init (int type; char *string_ptr)
{
    IGRlong         status; /* return code */
    IGRlong         size;        /* # bytes sent to (& returned by) dpb call */

    /*
     *  Initialize instance data
     */

    me->init_status = OM_S_SUCCESS;
    me->state = NULL;
    me->locate_state = 0;
    me->mytype = type;
    me->action = 2;
    me->obj_hilited = FALSE;
    me->locate_stack.num_entries = 0;
    me->my_GRid.objid = my_id;
    me->my_GRid.osnum = OM_Gw_current_OS;
    me->event_size = sizeof (struct GRevent);
    me->mask1 = GRm_DATA | GRm_OBJID | GRm_TEXT_VALUE;
    me->mask2 = GRm_DATA;
    me->display_flag = ALL_WINDOWS
                     | ELEM_HILIGHT
                     | NO_PROJ_ACCEPT_POINT
                     | ACC_REJ_CYCLE
                     | RELOCATE
                     | LC_REGULAR_HIGHLIGHT
                     | LC_ERASE_ALL;
    me->attr.properties = LC_LC_ONLY | LC_DP_ONLY;
    me->attr.owner_action = LC_RIGID_OWNER | LC_FLEX_COMP | LC_FLEX_OWNER
                          | LC_REF_HEADER | LC_REF_OBJECTS;
    strcpy (me->attr.classes,"GRgraphics");
    ex$message (msgnumb = GR_P_IdEle, buff = me->loc_prompt);
    ex$message (msgnumb = GR_E_EleNotFnd, buff = me->reloc_prompt);

    /*
     *  fetch dpb variables
     */

    size = sizeof (struct GRmd_env);

    gr$get_module_env (msg = &status,
                       sizbuf = &size, 
                       buffer = &me->ModuleInfo,
                       nret = &size);

    if (!(status & 1))
    {
        me->init_status = OM_E_ABORT;
    }

    return (OM_S_SUCCESS);
}


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                        wakeup method                                 */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method wakeup (int pos)
{
    UI_status ("");
    if (me->obj_hilited)
    {
        IGRint          count;          /* # of objects on graphic set */
        IGRlong         status, msg;    /* return codes */
        OM_S_CHANSELECT chansel;

        om$make_chanselect (channame = "COgsmanip.to_graphics",
                            p_chanselect = &chansel);

        /*
         *  check to see if the graphic set contains any objects
         */

        status = gr$gsinqcount (msg = &msg,
                                count = &count,
                                p_chanselect = &chansel);
        if (count)
        {
            status = gr$gsdisplay (msg = &msg,
                                   dpmode = GRhd,
                                   p_chanselect = &chansel);

            if (!(status & msg & 1))
            {
                ex$message (msgnumb = GR_E_ErrEnc);
            }
        }
        else
        {
            ex$message (msgnumb = GR_E_MnpObjLost);
            me->state = 0;
            me->action = 2;
            me->obj_hilited = FALSE;
        }
    }

    return (OM_S_SUCCESS);
    
} /* method wakeup */


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                        SLEEP Method                                  */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method sleep (int pos)
{
    UI_message (""); /* clear command name */
    UI_prompt ("");  /* clear prompt field */
    UI_status ("");  /* clear status field */

    if (me->obj_hilited)
    {
        IGRlong         status, msg;    /* return codes */
        OM_S_CHANSELECT chansel;

        om$make_chanselect (channame = "COgsmanip.to_graphics",
                            p_chanselect = &chansel);

        status = dp$erase_hilite (msg = &msg,
                                  objid = me->ModuleInfo.md_id.objid,
                                  osnum = me->ModuleInfo.md_id.osnum);
        if (!(status & msg & 1))
        {
            ex$message (msgnumb = GR_E_ErrEnc);
        }
    }

    return (OM_S_SUCCESS);

} /* method sleep */


/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/
/*                             delete                               */
/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

method delete (int flag)
{
    IGRlong         status;
    IGRlong         msg;
    OM_S_CHANSELECT chansel;

    om$make_chanselect (channame = "COgsmanip.to_graphics",
                        p_chanselect = &chansel);

    /*
     *  Empty the Variable String Descriptor
     */

    clear_vsd;

    /*
     *  Empty the graphics set.
     */

    status = gr$gsempty (msg = &msg, p_chanselect = &chansel);

    /*
     *  delete the graphics set & self
     */

    status = gr$gsdissolve (msg = &msg, 
                            p_chanselect = &chansel);

    status = om$send (mode = OM_e_wrt_message,
                      msg = message Root.delete ( NULL),
                      senderid = my_id,
                      targetid = my_id);

    return (OM_S_SUCCESS);
}

end implementation COgsmanip;
