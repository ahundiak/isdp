/*
Name
        LCcursor

Description
        The routines defined here will support changing the hardware
        cursor to reflect the locate tolerance by drawing a circle
        around the crosshair. 

History
	rc      07/20/87    Started documentation
        mrm     09/27/91    efficiency improvements, sparc changes
        scw     07/13/92    ANSI conversion
*/

class implementation Root;

#include "exsysdep.h"
#include "grimport.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "igrtypedef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "igr.h"
#include "madef.h"
#include "igewindef.h"
#include <alloca.h>

#define MAX_DIT_TOLERANCE 14.0

extern OMuword OPP_GRwindow_class_id;
extern OMuword EX_exec_osnum;
extern OM_S_OBJID EX_exec_id;

from IGEwindow import change_cusror_def, reset_cursor_def;

/*
Name
        LCdef_cursor

Description
        Define the locate cursor by using the dit tolerance in the dpb
        and sending to the object that represents the hardware window
        object.  The cursor should be restored to its previous state
        using LCrestore_cursor after the locate cycle is complete. 
*/

IGRint LCdef_cursor()
{
    static IGRlong c_e[32], c_d[32];    /* enabled and data bit arrays */
    static IGRlong hs[2] = {16, 16};    /* hot spot */
    static IGRdouble tolerance = 0.0;   /* locate tolerance */
    IGRdouble tol;

    /* get the locate tolerance from the dpb */

    gr$get_dit_tolerance(buffer = &tol);

    /* the bit patterns only need to be recalculated if the tolerance
       has changed */

    if (tol != tolerance)
    {
        /* calculate the locate cursor bit patterns */

        LCset_c_def(c_d, c_e, tol, hs[0], hs[1]);

        /* set tolerance to reflect the latest calculations */

        tolerance = tol;
    }

    /* set the cursor definition in graphic windows */

    LCset_window(1, c_e, c_d, hs);

    return(TRUE);
}

/*
Name
        LCrestore_cursor

Description
        Restore the cursor to its orginal definition in all graphic windows.
*/

IGRint LCrestore_cursor()
{
    LCset_window(0, NULL, NULL, NULL);
    return(TRUE);
}

/*
Name
        LCbit_set

Description
        Set a particular bit -- mat[row, column].
*/

void LCbit_set(row, column, dim, mat)
IGRint row, column, dim, *mat;
{
    if (row <= dim && column <= dim)
    {
        mat[row] |= 1 << column;
    }
}

/*
Name
        LCset_c_def

Description
        Set cursor data and enable patterns using a diameter of
        tolerance and the hot spot as a center.
*/

IGRint LCset_c_def(c_d, c_e, tolerance, hs_x, hs_y)
IGRint c_d[32], c_e[32], hs_x, hs_y;
IGRdouble tolerance;
{
#ifdef BIG_ENDIAN 
    IGRchar *p_byte, t_byte;
#endif
    IGRint i, row, column;
    IGRlong msg;
    IGRdouble theta;
    IGRdouble pts[200];
    struct IGRarc arc;
    struct IGRpolyline polyline;

    /* set up cursor data pattern for tolerance */

    arc.prim_axis = arc.sec_axis = MAminimum(tolerance, MAX_DIT_TOLERANCE);

    for (i = 0; i < 32; i++)
    {
        c_d[i] = c_e[i] = 0;
    }

    /* the hot spot is the origin of the circle (arc of 2 pi) */

    arc.origin[0] = (double) hs_x;
    arc.origin[1] = (double) hs_y;
    arc.origin[2] = 0;
    arc.start_angle = 0;
    arc.sweep_angle = 2 * PI;
    MAidmx(&msg, arc.rot_matrix);
    theta = (2 * PI) / 60;
    polyline.points = pts;   

    /* find the number of points necessary for a circle and stroke it */

    MApyfrar(&msg, &arc, &theta, &polyline);

    /* set the bits for the hardware cursor for each point generated */

    while (polyline.num_points--)
    {
        /* round up to the nearest row and column */

        row = *polyline.points++ + .5;
        column = *polyline.points++ + .5;
        polyline.points++;

        /* turn on bits in the data pattern */

        LCbit_set(row, column, 31, c_d);

        /* turn on bits in the enable pattern in a square around the data
           bit - this gives an opposite-color outline around the cursor */

        LCbit_set(row - 1, column - 1, 32, c_e);
        LCbit_set(row - 1, column,     32, c_e);
        LCbit_set(row - 1, column + 1, 32, c_e);
        LCbit_set(row,     column - 1, 32, c_e);
        LCbit_set(row,     column,     32, c_e);
        LCbit_set(row,     column + 1, 32, c_e);
        LCbit_set(row + 1, column - 1, 32, c_e);
        LCbit_set(row + 1, column,     32, c_e);
        LCbit_set(row + 1, column + 1, 32, c_e);
    }

    /* "or" the crosshairs into c_d and c_e */

    for (i = 1; i < 31; i++) c_d[i] |= 0x00010000;      /* vertical bar */
    c_d[16] = 0x7ffffffe;                               /* horizontal bar */
    for (i = 0; i < 32; i++) c_e[i] |= 0x00038000;      /* vertical bar */
    c_e[15] = 0xffffffff;                               /* horizontal bar */
    c_e[16] = 0xffffffff;                               /* horizontal bar */
    c_e[17] = 0xffffffff;                               /* horizontal bar */

#ifdef BIG_ENDIAN 

    /* reverse the byte order in the data and enable patterns */

    for (i = 0; i < 32; i++)
    {
        p_byte = (IGRchar *)&c_d[i];
        t_byte = p_byte[3];
        p_byte[3] = p_byte[0];
        p_byte[0] = t_byte;
        t_byte = p_byte[2];
        p_byte[2] = p_byte[1];
        p_byte[1] = t_byte;

        p_byte = (IGRchar *)&c_e[i];
        t_byte = p_byte[3];
        p_byte[3] = p_byte[0];
        p_byte[0] = t_byte;
        t_byte = p_byte[2];
        p_byte[2] = p_byte[1];
        p_byte[1] = t_byte;
    }

#endif

    return(TRUE);
}

/*
Name
        LCset_window

Description
        This function will redefine or reset the cursor in all graphic
        windows (defined as all subclasses or subclasses of GRwindow)
        connected to the exec object on the hw_win (hardware window
        channel). 
*/

IGRint LCset_window(mode, c_e, c_d, hs)
IGRint mode;
IGRlong *c_e, *c_d, *hs;
{
    static IGRboolean have_chanselect = FALSE;
    IGRint  size, i;
    IGRlong sts;
    OMuint  count;
    OMuword window_class_id;
    OM_S_MESSAGE *p_message;
    OM_p_OBJECT_LINKAGE list;
    static OM_S_CHANSELECT exec_channel;

    /* get a channel selector from the exec to the windows */
    if (!have_chanselect)
    {
        sts = om$make_chanselect(channame = "exec.hw_win",
                                 p_chanselect = &exec_channel);

        if (!(sts & 1)) goto finish;

        have_chanselect = TRUE;
    }

    /* figure out how many windows are active */
    sts = om$get_channel_count(osnum = EX_exec_osnum,
                               objid = EX_exec_id,
                               p_chanselect = &exec_channel,
                               count = &count);

    if (!(sts & 1)) goto finish;

    if (count)
    {
        size = sizeof (OM_S_OBJECT_LINKAGE) * count;
        list = (OM_S_OBJECT_LINKAGE *)alloca(size);

        /* get the window ids */
        sts = om$get_channel_objects(osnum = EX_exec_osnum,
    				     objid = EX_exec_id,
				     p_chanselect = &exec_channel,
				     list = list,
				     size = count,
				     count = &count);
        if (!(sts & 1)) goto finish;

        /* build the message structures only once (outside of the window
           loop); also reduces the number of calls to om$send */

        if (mode)
        {
            p_message = message IGEwindow.change_cusror_def
                       (&sts, OVERRIDE_CURSOR_DEF, c_e, c_d, hs);
        }
        else
        {
            p_message = message IGEwindow.reset_cursor_def(&sts);
        }

        for (i = 0; i < count; i++)
        {
            /* check whether this is a graphic window - the definition of
               the cursor should not change over forms and windows */

            sts = om$get_classid(objid = list[i].S_objid,
                                 osnum = list[i].osnum,
                                 p_classid = &window_class_id);

            if (sts == OM_S_SUCCESS)
            {
                sts = om$is_ancestry_valid(subclassid = window_class_id,
                                         superclassid = OPP_GRwindow_class_id);

                if (sts == OM_S_SUCCESS)
                {
                    /* send the prepacked message */

                    om$send(msg = p_message,
                            senderid = NULL_OBJID,
                            targetid = list[i].S_objid,
                            targetos = list[i].osnum);
                }
            }
        }
    }

finish:

    return(sts & 1);
}

end implementation Root;
