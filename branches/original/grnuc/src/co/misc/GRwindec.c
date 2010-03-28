/*
Name
        GRwindec - window decoration functions

Description
        This file contains functions relating to determining window
        manager decoration sizes.

History
        mrm     03/11/92    creation
        mrm     10/08/92    all functions changed to refer to an EXNUC 
                            version, which were cloned from the originals here
*/

#include "dpgraphics.h"
#ifdef X11
#include <FI.h>
#else
#include <FI.h>
#endif

/*
Name
        GRget_decoration

Description
        This function determines the dimensions of the decoration placed
        around a window by the window manager, as well as the offset of
        the window from the window frame, if any.  The offset is
        dependent on how the window manager.  Some window managers place
        the corner of the window at the position requested; others place
        the corner of the window frame at that position.  The window and
        its presumed origin are required as input; the decoration and
        offset sizes are returned.

History
        mrm     03/11/92    creation
*/

#ifdef X11

int GRget_decoration(w, x, y, xdecor, ydecor, xoffset, yoffset)
Window w;
int x, y;
int *xdecor, *ydecor, *xoffset, *yoffset;
{
    return(EXget_decoration(w, x, y, xdecor, ydecor, xoffset, yoffset));
}

#endif

/*
Name
        GRget_form_decoration

Description
        This function returns the sizes of the decoration placed around
        an I/FORM or XFORM.  It assumes that all forms are decorated
        equally.  The EXNUC message strip form is used to determine the
        decoration sizes.

History
        mrm     03/11/92    creation
*/

int GRget_form_decoration(xdecor, ydecor)
int *xdecor, *ydecor;
{
    return(EXget_form_decoration(xdecor, ydecor));
}

int GRget_form_offset(xoffset, yoffset)
int *xoffset, *yoffset;
{
    return(EXget_form_offset(xoffset, yoffset));
}
