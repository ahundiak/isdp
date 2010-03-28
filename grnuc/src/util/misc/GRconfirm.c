/*
Name
        GRconfirm

Description
        This function will use a form to prompt the user for a simple yes or
        no response to a question.

Notes
        This function has a GRNUC-based twin in src/co/misc/GRconfirm.C.  Any
        changes made here need to be mirrored there.  The only real difference
        between the functions is that the GRNUC version uses co$getevent so as
        to get along with RAP & journaling.  This version handles its own
        input, and is intended for use outside of GRNUC (like in revasm).

        This function is included in lib/utilmisc.a.  The other one is
        included in lib/libGRcoar.a, which should be placed ahead of
        utilmisc.a in the link order (see grnucmakelib).

Return Values
        int ()  TRUE or FALSE or -1 on error

History
        mrm     07/10/92    creation
        elp     01/12/92    port to NT
        mrm     10/26/93    cloned the GRNUC version of GRconfirm
*/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#ifdef ENV5
#include <tools.h>
#include <FIproto_pub.h>
#endif
#ifdef X11
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <XFIproto_pub.h>
#endif
#include <UMS.h>

/*
        Miscellaneous definitions
*/

#define TRUE    1
#define FALSE   0

#define FormLabel       90210
#define FieldLabel      11
#define YesLabel        12
#define NoLabel         13

/*
        These variables are probably not public, but hey, sue me.
*/

extern int FI_current_screen_height;
extern int FI_current_screen_width;
#ifdef X11
extern Display *_FI_display;
#endif

/*
        Static variables.
*/

static int form_dismissed = 0;
static int return_code = -1;

/*
        Callback function.
*/

/* ARGSUSED */

int GRconfirm_callback(int f_label, int g_label, double value, Form form)
{
    switch(g_label)
    {
      case YesLabel:
        return_code = TRUE;
        form_dismissed = TRUE;
        FIf_erase(form);
        break;

      case NoLabel:
        return_code = FALSE;
        form_dismissed = TRUE;
        FIf_erase(form);
        break;

      default:
        break;
    }

  return FI_SUCCESS;
}

/*
        Confirm function.
*/
int GRconfirm_box(char *message)
{
    int i, x, y, n, w, h, form_h;
    char text[64], centered[64];
    Form form;
#ifdef ENV5
    int event, sts;
#endif
#ifdef X11
    XEvent event;
    XSetWindowAttributes winatt;
    Window win;
#endif

    /* do a little input validation */
    if ((message == NULL) || ((int)strlen(message) < 1))
        return(-1);

    /* initialize return code and control flag */
    form_dismissed = 0;
    return_code = -1;

    /* create a form */
    if (FIf_new(FormLabel, "GRconfirm", GRconfirm_callback, &form) != 
        FI_SUCCESS)
        return(-1);

#ifdef X11
    /* make the form save-under */
    winatt.save_under = TRUE;
    if (FIf_get_window(form, &win) == FI_SUCCESS)
        XChangeWindowAttributes(_FI_display, win, CWSaveUnder, &winatt);
#endif

    /* put the message in the field */
    if (FIfld_set_text(form, FieldLabel, 0, 0, message, FALSE) != FI_SUCCESS)
        return(-1);

    /* make all the lines in the field visible */
    FIfld_get_num_rows(form, FieldLabel, &n);
    FIfld_set_num_vis_rows(form, FieldLabel, n);

#if 0
    /* This kludge can result in lost data, since the forms code rewraps each
       time a line is adjusted here.  Bummer */

    /* KLUDGE - automatic center justification doesn't seem to work */
    for (i = 0; i < n; i++)
    {
        FIfld_get_text(form, FieldLabel, i, 0, 64, (unsigned char *) text,
                       &x, &y);
        memset(centered, (int)' ', 32);
        strcpy(&centered[(40 - strlen(text)) / 2], text);
        FIfld_set_text(form, FieldLabel, i, 0, centered, FALSE);
    }
#endif
        
    /* display the gadget to make the changes take effect */
    FIg_display(form, FieldLabel);

    /* adjust the buttons to stay below the message field */
    FIg_get_size(form, FieldLabel, &w, &h);
    FIg_get_location(form, YesLabel, &x, &y);
    FIg_set_location(form, YesLabel, x, y + h);
    FIg_get_location(form, NoLabel, &x, &y);
    FIg_set_location(form, NoLabel, x, y + h);

    /* adjust the form so that everything is displayed */
    FIf_get_size(form, &w, &form_h);
    FIf_set_scaling_off(form);
    FIf_set_size(form, w, form_h + h);

    /* position the form in the center of the screen */
    FIf_get_size(form, &w, &h);
    x = (FI_current_screen_width - w) / 2;
    y = (FI_current_screen_height - h) / 2;
    FIf_set_location(form, x, y);

    /* display the form */
    FIf_display(form);

    /* wait for input */
    while (1)
    {
#ifdef ENV5
        Wait_for_next(BUTTON_EVENT, &event);
        sts = FI_process_event(event);
        if (sts == FALSE) {
          Clear_button_data();
        }
#endif
#ifdef X11
        XNextEvent(_FI_display, &event);
        FI_process_event(&event, 0);
#endif
        if (form_dismissed)
        {
            FIf_delete(form);
            break;
        }
    }

    return(return_code);
}

/*
        Confirm function using message system
*/

int GRconfirm(msgnum)
int msgnum;
{
    int sts;
    char buf[UMS_MAX_BUFLEN];

    /* retrieve the message string */
    sts = UMSGetByNum(buf, msgnum, 0);
    if (sts != UMS_S_SUCCESS) return(-1);

    /* invoke the confirmation box */
    sts = GRconfirm_box(buf);

    return(sts);
}
