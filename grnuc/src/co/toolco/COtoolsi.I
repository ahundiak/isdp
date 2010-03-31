/******************************************************************************

Methods:

    store_event
    copy_event
    fetch_event
    push_event
    erase_highlight
    empty_channel
    translate
    change_name
    wait
    color_menu_button

Description:    

    These are misc methods.

History:    

    jay wallingford     04/10/89    creation date
    mrm                 07/22/93    added confirm
    mrm                 08/11/93    added color_menu_button
						  
Bugs:       

    There are no known bugs.

Notes:

******************************************************************************/

class implementation COtools;

// Prevent the Solaris wait() function definition from being defined.
#define	_WAIT_H
#define _SYS_WAIT_H

#include <FI.h>
#include <coimport.h>
#include <exmacros.h>
#include <dpdef.h>
#include <dp.h>
#include <dperr.h>
#include <dpmacros.h>
#include <grgsdef.h>
#include <grgs.h>
#include <grgsmacros.h>
#include <DIdef.h>
#include <DItypedef.h>
#include <DIglob.h>
#include <DImacros.h>
#include <DIprims.h>
#include "comisc.h"
/*#include <EXtools_pub.h>*/

#ifdef X11
#include <stdio.h>
#include <math.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/time.h>
#endif

from GRvg   import GRchgname;

method store_event ( struct GRevent * event;
                     IGRint to_index )
{
    IGRint  size, newsize, status = OM_S_SUCCESS;
    
    size = om$dimension_of ( varray = me->events );
    newsize = to_index + 1;

    if ( newsize > size ) 
    {
        status = om$vla_set_dimension ( varray = me->events,
                                        size = newsize );
        
    }

    if (status & 1) me->events[to_index] = *event;

    return (status);
}

method copy_event ( IGRint from_index;
                    IGRint to_index )
{
    IGRint  size;

    size = om$dimension_of ( varray = me->events );

    if ( (from_index <= size) && (to_index <= size) )
    {
        me->events[to_index] = me->events[from_index];
    }

    return OM_S_SUCCESS;
}

method fetch_event ( IGRint from_index;
                     struct GRevent * event )
{
    IGRint  size;

    size = om$dimension_of ( varray = me->events );

    if ( (from_index <= size) && event )
    {
        *event = me->events[from_index];
    }

    return OM_S_SUCCESS;
}
    
method push_event ( struct GRevent * event )
{
    IGRlong buffersize, msg;

    if ( event )
    {
        buffersize = sizeof(struct GRevent) - (2 * sizeof(IGRlong));

        ex$putque ( msg = &msg,
                    response = &event->response,
                    byte = &buffersize,
                    buffer = (IGRchar *)&event->event );

    }

    return OM_S_SUCCESS;
}

method erase_highlight ()
{
    IGRint      msg;
    OM_S_OBJID  mod_objid;
    OMuword     mod_osnum;

    ex$get_cur_mod ( id = &mod_objid,
                     osnum = &mod_osnum );

    dp$erase_hilite( msg = &msg,
                     objid = mod_objid,
                     osnum = mod_osnum );

    return OM_S_SUCCESS;
}

method empty_channel ( OM_S_CHANSELECT * p_chansel )
{
    IGRint msg;
    return (gr$gsempty ( msg = &msg, 
                         p_chanselect = p_chansel));
}

method translate ( IGRint * msg;
                   IGRchar * name;
                   OM_S_OBJID * objid;
                   OMuword * osnum )
{
    *msg = MSSUCC;
    *msg = di$translate ( objname = name, 
                          p_objid = objid );
    return (OM_S_SUCCESS);
}

method change_name ( IGRint * msg;
                     OM_S_CHANSELECT * p_chansel;
                     IGRchar * name )
{
    IGRint          status = OM_S_SUCCESS;    
    OM_S_OBJID      objid;
    IGRchar         path[256];
    struct GRmd_env mod_env;

    *msg = MSSUCC;

    ex$get_cur_mod ( id = &mod_env.md_id.objid,
                     osnum = &mod_env.md_id.osnum );

    status = di$translate ( objname = name, 
                            p_objid = &objid );

    if ( status == DIR_W_NAME_NOT_FOUND ) 
    {
        *msg = di$cvt_name_from_input ( u_path = name,
                                        s_path = path );

        if ( *msg & 1 ) {
            status = gr$gspass ( msg = msg,
                                 pass_msg = message GRvg.GRchgname((IGRlong *)msg, 
                                                                   &mod_env, 
                                                                   path),
                                 p_chanselect = p_chansel);
        }
    }
    else *msg = DIR_E_NAME_DUP;

    return(status);
}

method wait ( IGRint timer )
{
#ifdef X11
    struct timeval xtimer;
    double tmp_sec, xdsec, xdusec;

    tmp_sec = timer/60.0;
    xdusec = modf(tmp_sec, &xdsec);
    xtimer.tv_sec = (int)xdsec;
    xtimer.tv_usec = (int)(xdusec * 1000000);
    select(1, 0, 0, 0, &xtimer);
#else
    Wait_timer(timer);
#endif

    return (OM_S_SUCCESS);
}

method add (IGRint * i; IGRint j)
{
    *i += j;
    return (OM_S_SUCCESS);
}
    
method confirm(int message_key; int *answer)
{
    *answer = GRconfirm(message_key);
    return(OM_S_SUCCESS);
}

method color_menu_button(char *cmdkey; int color)
{
    GRcolor_menu_button(cmdkey, color);
    return(OM_S_SUCCESS);
}

end implementation COtools;
