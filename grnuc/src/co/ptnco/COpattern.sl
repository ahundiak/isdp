/* #######################    APOGEE COMPILED   ######################## */
/*
Name
        COpattern

Description
        This file contains actions and instance data referenced by the
        Pattern Element Area and Pattern Element Edge commands.

History
        mrm     08/26/88    COBbed from existing command
*/

class               COpattern
super_class         CEO_LOCATE
product_name        "$PLATFORM"
start_state         terminate
options             "t"


specification

#include "grsymdef.h"
#include "grsym.h"
#include "grptn.h"

instance
{
    IGRdouble                   range[6];   /* of master element */
    struct GRid                 ptn;        /* constructed object */
    struct GRevent              events[3];  /* input events */
    struct GRmd_env             const_env;  /* construct environment */
    struct GRactive_symbol_def  symbol;     /* symbol to pattern with */
}


implementation

#include "coimport.h"
#include "msdef.h"
#include "execmsg.h"
#include "grmessage.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "grsymmacros.h"
#include "lcmacros.h"
#include "dpmacros.h"
#include "grptn.h"

#define AREA            0
#define OPEN_EDGE       1
#define CLOSED_EDGE     2

from GRgraphics import GRconstruct, GRdisplay, GRdelete;
from GRvg import GRgeomprops, GRgetrang;
from GRmodule import GRmdremove;
from GRconnector import GRrigidconn, GRdisconn;
from GRpa import GRgenerate;

/*
Action
        store_event (int f, t)

Description
        This action store user input into COpattern instance data.  The
        argument "f" signals which CEO event to store; "t" specifies
        which COpattern event in which to store the data.

Notes
        The from argument "f" should be 1 or 2; the to argument "t" can
        range from 0 to the max number of COpattern args.
*/

action store_event (int f, t)
{
    struct GRevent *from_event;

    from_event = (f == 2) ? &me->event2 : &me->event1;

    if (t < 2)
    {
        me->ret = MSSUCC;
        me->events[t] = *from_event;
    }
    else
    {
        me->ret = MSFAIL;
    }
}

/*
Action
        get_symbol (int terminate_cmd)

Description
        This action stores the active symbol in me->symbol.  If the input
        argument terminate_cmd is nonzero, then failure to find a symbol 
        results in the termination of the command, after displaying an
        appropriate error message.
*/

action get_symbol (int terminate_cmd)
{
    status = gr$symget_active_symbol (msg = &me->ret,
                                      act_symbol_def = &me->symbol);

    if (status & me->ret & 1)
    {
        ex$message (msgnumb = GR_I_ActCel,
                    type = "%s",
                    var = `me->symbol.name`);
    }
    else if (terminate_cmd)
    {
        ex$message (msgnumb = GR_F_NoActCelDfn);
        me->state = _terminate;
    }

#ifdef DEBUG
    if (!(status & me->ret & 1)) printf ("COpattern.get_symbol failed\n");
    if (!(me->ret & 1)) printf ("me->ret = %#x\n", me->ret);
    if (!(status & 1)) om$report_error (sts = status);
#endif

}


/*
Action
        check_closure (int n)

Description
        This action checks whether the object in me->events[n] is physically
        closed.  If so, me->ret is set to TRUE; if it is not physically
        closed, me->ret is set to FALSE.  If the action fails, me->ret is
        set to MSFAIL.
*/

action check_closure (int n)
{
    struct GRlc_info   *obj;            /* object to check */
    struct GRprops      properties;     /* of the element */

    obj = &me->events[n].located_object[0];

    status = om$send (msg = message GRvg.GRgeomprops
                           (&me->ret, &obj->module_info.md_env.matrix_type,
                            obj->module_info.md_env.matrix, &properties),
                      targetid = obj->located_obj.objid,
                      targetos = obj->located_obj.osnum);

    if (status & me->ret & 1)
    {
        me->ret = properties.phy_closed;
    }
    else
    {
#ifdef DEBUG
        if (!(status & me->ret & 1)) printf ("COpattern.check_closure failed\n");
        if (!(me->ret & 1)) printf ("me->ret = %#x\n", me->ret);
        if (!(status & 1)) om$report_error (sts = status);
#endif
        me->ret = MSFAIL;
    }
}


/*
Action
        generate_pattern (int type)

Description
        This action generates a pattern.  The type of pattern is determined
        by the input type as shown below.

            type        function

             0          area pattern
             1          open edge pattern
             2          closed edge pattern
*/

action generate_pattern (int type)
{
    IGRchar                *c;          /* type of pattern to construct */
    IGRboolean              world;      /* get range in local coordinates */
    IGRint                  size, i;    /* for dpb call */
    IGRlong                 ptn_index;  /* index */
    IGRdouble               delta[2];   /* pattern delta */
    struct GRlc_info       *obj;        /* object to check */
    struct GRvg_construct   const_args; /* construction argument list */
    struct GRpaconstruct    pa;         /* pattern header construct args */
    struct GRapconstruct    ap;         /* specific to area patterning */
    struct GRepconstruct    ep;         /* specific to edge patterning */

#ifdef DEBUG
    printf ("COpattern.generate_pattern: entry\n");
#endif

    obj = &me->events[0].located_object[0];

    /*
     *  erase the hilite plane
     */

    dp$erase_hilite (msg = &me->ret,
                     objid = obj->module_info.md_id.objid,
                     osnum = obj->module_info.md_id.osnum);

    /*
     *  get the range of the master element
     */

    world = FALSE;

    status = om$send (msg = message GRvg.GRgetrang
                           (&me->ret, &obj->module_info.md_env.matrix_type,
                            obj->module_info.md_env.matrix,
                            &world, pa.range),
                      targetid = obj->located_obj.objid,
                      targetos = obj->located_obj.osnum);

    if (!(status & me->ret & 1))
    {
#ifdef DEBUG
        printf ("COpattern.generate_pattern: GRvg.GRgetrang failed\n");
#endif
        goto finish;
    }

    for (i = 0; i < 6; i++)
    {
        me->range[i] = pa.range[i];
    }

    /*
     *  get the current construct environment
     */

    size = sizeof (struct GRmd_env);
    status = gr$get_construct_env (msg = &me->ret,
                                   point = &me->events[0].event.button,
                                   sizbuf = &size,
                                   buffer = &me->const_env,
                                   nret = &size);

    /*
     *  set up type-specific arguments
     */

    if (type == AREA)
    {
        size = sizeof (IGRdouble) * 2;

        status = gr$get_patrn_area_deltas (msg = &me->ret,
                                           sizbuf = &size,
                                           buffer = delta,
                                           nret = &size);
        pa.class_spec = (IGRchar *)&ap;
        ap.dy = delta[1];
        c = "GRareaptn";
    }
    else /* EDGE */
    {
        size = sizeof (IGRdouble);
        status = gr$get_patrn_edge_delta (msg = &me->ret,
                                          sizbuf = &size,
                                          buffer = delta,
                                          nret = &size);

        c = "GRedgeptn";
        pa.class_spec = (IGRchar *)&ep;
        ep.stop_pt[0] = me->events[1].event.button.x;
        ep.stop_pt[1] = me->events[1].event.button.y;
        ep.stop_pt[2] = me->events[1].event.button.z;

        if (type == OPEN_EDGE)
        {
            ep.dir_pt[0] = (pa.origin[0] + ep.stop_pt[0]) / 2.0;
            ep.dir_pt[1] = (pa.origin[1] + ep.stop_pt[1]) / 2.0;
            ep.dir_pt[2] = (pa.origin[2] + ep.stop_pt[2]) / 2.0;
        }
        else /* CLOSED_EDGE */
        {
            ep.dir_pt[0] = me->events[2].event.button.x;
            ep.dir_pt[1] = me->events[2].event.button.y;
            ep.dir_pt[2] = me->events[2].event.button.z;
        }
    }

    /*
     *  set up generic construction data
     */

    pa.origin[0] = me->events[0].event.button.x;
    pa.origin[1] = me->events[0].event.button.y;
    pa.origin[2] = me->events[0].event.button.z;
    pa.dx = delta[0];
    pa.ref_env = obj->module_info;
    pa.sym_def = me->symbol;
    me->ptn.osnum = me->const_env.md_id.osnum;
    const_args.msg = &me->ret;
    const_args.newflag = FALSE;
    const_args.env_info = &me->const_env;
    const_args.class_attr = (IGRchar *)&pa;
    const_args.properties = GRIS_NEW | GRIS_DISPLAYABLE | GRIS_LOCATABLE;

    /*
     *  construct a pattern attribute object
     */

    status = om$construct (classname = c,
                           osnum = me->ptn.osnum,
                           p_objid = &me->ptn.objid,
                           msg = message GRgraphics.GRconstruct (&const_args));

    if (!(status & me->ret & 1))
    {
#ifdef DEBUG
        printf ("COpattern.generate_pattern: om$construct failed\n");
#endif
        goto finish;
    }

    /*
     *  connect the pattern object to the command object
     */

    status = lc$connect (p_chanselect = &me->const_chansel,
                         go_objid = me->ptn.objid,
                         go_osnum = me->ptn.osnum );

    if (!(status & 1))
    {
#ifdef DEBUG
        printf ("COpattern.generate_pattern: lc$connect failed\n");
#endif
        goto finish;
    }

    /*
     *  connect the pattern object to the located object as its owner
     */

    ptn_index = 0;

    status = om$send (msg = message GRconnector.GRrigidconn
                           (&me->ret, &me->ptn, &ptn_index),
                      targetid = obj->located_obj.objid,
                      targetos = obj->located_obj.osnum);

    if (!(status & me->ret & 1))
    {
#ifdef DEBUG
        printf ("COpattern.generate_pattern: GRconnector.GRrigidconn failed\n");
#endif
        goto finish;
    }

    /*
     *  generate the pattern
     */

    status = om$send (msg = message GRpa.GRgenerate (&me->ret, &me->const_env),
                      targetid = me->ptn.objid,
                      targetos = me->ptn.osnum);

    if (!(status & me->ret & 1))
    {
#ifdef DEBUG
        printf ("COpattern.generate_pattern: GRpa.GRgenerate failed\n");
#endif
        goto finish;
    }

finish:

#ifdef DEBUG
    printf ("COpattern.generate_pattern: exit\n");
    if (!(me->ret & 1)) printf ("me->ret = %#x\n", me->ret);
    if (!(status & 1)) om$report_error (sts = status);
#endif

}

/*
Action
        delete_pattern

Description
        This action attempts to clean up if generate_pattern fails.
*/

action delete_pattern ()
{
    struct GRlc_info       *obj;        /* object to check */

    obj = &me->events[0].located_object[0];

    /*
     *  disconnect the pattern object from the command
     */

    status = lc$wild_disconnect (p_chanselect = &me->const_chansel);

#ifdef DEBUG
    printf ("COpattern.delete_pattern: lc$wild_disconnect = %#x\n", status);
#endif

    /*
     *  delete the pattern object and any pattern components which were
     *  generated
     *
     *  KLUDGE: set me->ret to PATTERN_KLUDGE to avoid deleting the
     *  patterned object.
     */

    me->ret = PATTERN_KLUDGE;

    status = om$send (msg = message GRgraphics.GRdelete
                           (&me->ret, &me->const_env),
                      targetid = me->ptn.objid,
                      targetos = me->ptn.osnum);

#ifdef DEBUG
    if (!(status & me->ret & 1))
        printf ("COpattern.delete_pattern: GRgraphics.GRdelete failed\n");
    if (!(me->ret & 1)) printf ("me->ret = %#x\n", me->ret);
    if (!(status & 1)) om$report_error (sts = status);
#endif

}
