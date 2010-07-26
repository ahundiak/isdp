#include <FI.h>
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "exdef.h"
#include "exmacros.h"
#include "tools.h"
#ifdef X11
#include <X11/X.h>
#endif
#include "adpdef.h"
#include "dpgraphics.h"

#define BorderSize      4

static int adp_xsize;
static int adp_ysize;

/*
Name
        GRget_adp_size

Description
        This function finds the x & y sizes of the ADP gadget portion of the
        menu bar form and sets the corresponding static variables.  The
        variables are used later to determine whether a user button action
        falls within the range of the ADP gadgets.
*/

void GRget_adp_size(form_ptr)
Form          form_ptr;   /* a pointer to the form */
{
    int x, y;

    FIg_get_size(form_ptr, ADP_LINE_LABEL, &adp_xsize, &y);
    FIf_get_size(form_ptr, &x, &adp_ysize);
}

#argsused
int GRadp_check(form, xpos, ypos, button, trans, t_tag)
Form          form;       /* a pointer to the form                          */
int           xpos;       /* x-coordinate of the point                      */
int           ypos;       /* y-coordinate of the point                      */
int           button;     /* button number (#defines in tools.h)            */
int           trans;      /* transition of the button (#defines in tools.h) */
int           t_tag;      /* time tag                                       */
{
    /*
     * if the user tapped the middle button and the point is not on the outside
     * edge of the form, bring up the Set Active Drawing Parameters form, else
     * send the button on to the form to interpret (a middle button on the
     * outside edge will bring up the window icon box)
     */

    if (adp_xsize == 0)
        (void)GRget_adp_size(form);

#ifdef X11
    if ((button == Button2) && 
#else
    if ((button == MIDDLE_BUTTON) && 
#endif
        /*    Xforms returns DOWN for transition if the dynamics is on. Now
              adp form can be invoked in place text command. --TR 119301305
              Mrudula
        */
        ((trans == SINGLE_CLICK) || ( trans == DOWN)) &&
        (xpos > BorderSize) && (xpos < (adp_xsize - BorderSize)) &&
        (ypos > BorderSize) && (ypos < (adp_ysize - BorderSize)) &&
        GRverify_adp_gadgets(form))
        return(TRUE);
    else
        return(FALSE);
}

/*
Name
        GRadp_intercept
 
Description
        This function processes buttons intercepted from the ADP form.  A data
        input will call a function to display the Set Active Drawings
        Parameters form.  Other input will be passed along to the menu
        intercept function to check for popups.

Synopsis
        GRadp_intercept(form_ptr,xpos,ypos,button,trans,t_tag)
        Form form_ptr   in - a pointer to the form
        int  xpos       in - x-coordinate of the point
        int  ypos       in - y-coordinate of the point
        int  button     in - button number (#defines in tools.h)
        int  trans      in - transition of the button (#defines in tools.h)
        int  t_tag      in - time tag

History
        WBC  06/12/89 : Design date.
        WBC  06/12/89 : Creation date.
        dhm  07/13/92 : ANSI conversion.
        mrm  07/24/92 : Changed to handle moving ADP gadgets to the menu bar
*/

void GRadp_intercept(form_ptr,xpos,ypos,button,trans,t_tag)

Form          form_ptr;   /* a pointer to the form                          */
int           xpos;       /* x-coordinate of the point                      */
int           ypos;       /* y-coordinate of the point                      */
int           button;     /* button number (#defines in tools.h)            */
int           trans;      /* transition of the button (#defines in tools.h) */
int           t_tag;      /* time tag                                       */

{
    IGRlong       msg;
    IGRlong       buffersize;
    IGRint        response;

    /* check whether the button is to invoke the ADP form */
    if (GRadp_check(form_ptr, xpos, ypos, button, trans, t_tag))
    {
        /* push a command on the queue to drive the ADP form */

        response = EX_CMD_KEY;
        buffersize = 8;  /* # of bytes in buffer string plus NULL terminator */

        ex$putque(msg = &msg,
                  response = &response,
                  byte = &buffersize,
                  buffer = "GRSDrPr");
    }
    else
    {
        /* check for popup or regular command selection */
        GRmenu_button_intercept_routine(form_ptr,xpos,ypos,button,trans,t_tag);
    }
}
