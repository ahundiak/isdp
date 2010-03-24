#include <FI.h>

#ifdef NT
#include <shampub.h>
#endif

#ifdef ENV5
#include <tools.h>
#include <FIproto_pub.h>
#endif

#include <stdio.h>
#include <igewindef.h>
#include <igewinmacros.h>
#include <igewindef.h>
#include <igewinmacros.h>
#include <exdef.h>
#include <exmacros.h>
#include <exproto.h>
#include <stdlib.h>

#define debug 0
extern short MS_Gs_messages_on;
extern char EX_runname[];

#ifdef X11
#include <X11/Xlib.h>
#include <XFIproto_pub.h>

extern Display *EXdisplay;
extern int FIf_get_orig_location();
/* store values statically so they only have to be calculated once */

static int form_x_decor = -1, form_y_decor = -1;
static int form_x_adjustment = -1, form_y_adjustment = -1;
static Window window;

#endif

static Form form;

void EX_start_copyright()
{
  char logo[50];
  int status, ii;
#ifdef ENV5
  int		vs_no;
  int           num_planes, fixed_vlt_size, num_screen;
#endif
  int x;
  int y;

#ifdef ENV5
  struct vlt_slot   vlt[4];  
  vlt[0].v_slot = 0;
  vlt[0].v_red = 0;
  vlt[0].v_green = 0;
  vlt[0].v_blue = 0;


  vlt[1].v_slot = 7;
  vlt[1].v_red = 0xff00;
  vlt[1].v_green =0xff00 ;
  vlt[1].v_blue = 0xff00;

  vlt[2].v_slot = 13;
  vlt[2].v_red = 0xbb00 ;
  vlt[2].v_green =0xbb00 ;
  vlt[2].v_blue = 0xbb00 ;

  vlt[3].v_slot = 14;
  vlt[3].v_red = 0x8800 ;
  vlt[3].v_green =0x8800 ;
  vlt[3].v_blue = 0x8800 ;

  Inq_displayed_vs(&vs_no);

  ige$inq_term_info(num_of_planes = &num_planes,
                    fixed_vlt_size = &fixed_vlt_size);
  if( !fixed_vlt_size )
  {  
     ige$get_num_screens( num_of_screens = &num_screen);
     ige$inq_term_info( screen_no = IGE_RIGHT_SCREEN,  vs_no = &vs_no);
     Loadvlt( vs_no, vlt, 4 );
     FI_calc_closest_colors ( vs_no , vlt , 4 );
     if( num_screen == 2 )
     {
         ige$inq_term_info( screen_no = IGE_LEFT_SCREEN,  vs_no = &vs_no);
         Loadvlt( vs_no, vlt, 4 );
         FI_calc_closest_colors ( vs_no , vlt , 4 );
     }         

  }
#endif
#ifdef X11
  XEvent event;
#endif

  logo[0] = '\0';
  get_modtype_data(EX_runname, logo, NULL, NULL, NULL, NULL);
  for (ii=0; logo[ii]; ii++)
     if (logo[ii] == '_')
        logo[ii] = ' ';
  status = FIf_new(100,"EX_copy_right",0,&form);
  if (!status)
   {
    FIg_set_text(form,11,logo);
    FIf_display(form);
#ifdef X11
    FIf_get_window(form,&window);
    XWindowEvent(EXdisplay,window,ExposureMask,&event);
    FI_process_event(&event,1);
#endif
   }
  else
   {
   printf("error in creating form EX_copy_right\n");
   exit(1);
   }
EXget_form_decoration(&x,&y);/*set up static for future calls*/
}

int EX_end_copyright()
{
  FIf_delete(form);
  return(1);
}

/*
Name
        EXwindec - window decoration functions

Description
        This file contains functions relating to determining window
        manager decoration sizes.

History
        mrm     03/11/92    creation
*/
/*
Name
        EXget_decoration

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

int EXget_decoration(w, x, y, xdecor, ydecor, xoffset, yoffset)
Window w;
int x, y;
int *xdecor, *ydecor, *xoffset, *yoffset;
{
    unsigned int nchildren;
    int xorigin, yorigin;
    unsigned int width, height, borderwidth, depth;
    Window win, root, parent, *children;

    /* initialize data */
    *xdecor = 0;
    *ydecor = 0;
    *xoffset = 0;
    *yoffset = 0;
    win = w;

    /* walk up the ancestry adding offsets */
    do
    {
        XQueryTree(EXdisplay, win, &root, &parent, &children, &nchildren);
        XGetGeometry(EXdisplay, win, &root, &xorigin, &yorigin,
                     &width, &height, &borderwidth, &depth);
        if (parent != root)
        {
            *xdecor += xorigin;
            *ydecor += yorigin;
        }
        *xoffset += xorigin;
        *yoffset += yorigin;
        win = parent;
    } while (parent != root);

    /* adjust offsets */
    *xoffset -= x;
    *yoffset -= y;
    if(children)XFree((caddr_t)children);
    return(TRUE);
}

#endif

/*
Name
        EXget_form_decoration

Description
        This function returns the sizes of the decoration placed around
        an I/FORM or XFORM.  It assumes that all forms are decorated
        equally.  The EXNUC message strip form is used to determine the
        decoration sizes.

History
        mrm     03/11/92    creation
*/

int EXget_form_decoration(xdecor, ydecor)
int *xdecor, *ydecor;
{
#ifdef X11
    if (form_x_decor == -1)
    {
        int sts, form_x, form_y;
        /*
            Get the origin stored in the form.  This is assumed to be
            the position FORMS asked the window manager to place the
            form.  Note that misleading results might occur if the form
            used here asked to be placed nearer the top or left screen
            edge than the width of the screen manager decoration.
        */

        sts = FIf_get_orig_location(form, &form_x, &form_y);
        if (sts != FI_SUCCESS) return(FALSE);

        /* get the info */
        EXget_decoration(window, form_x, form_y, 
                         &form_x_decor, &form_y_decor,
                         &form_x_adjustment, &form_y_adjustment);
    }

    *xdecor = form_x_decor;
    *ydecor = form_y_decor;
#endif
#ifdef ENV5

    /* Environ V version */

    *xdecor = *ydecor = 0;

#endif
    return(TRUE);
}

int EXget_form_offset(xoffset, yoffset)
int *xoffset, *yoffset;
{
#ifdef X11
    if (form_x_adjustment == -1)
    {
        int x, y;

        EXget_form_decoration(&x, &y);
    }

    *xoffset = form_x_adjustment;
    *yoffset = form_y_adjustment;
#endif
#ifdef ENV5

    /* Environ V version */

    *xoffset = *yoffset = 0;

#endif
    return(TRUE);
}

/*
Name
        EXposition_form

Description
        This function positions a form near the edge of the screen.  The
        caller may specify which edge[s] to which to move with the input
        argument "position."

History
        mrm     10/25/91    creation
                03/11/92    call EXget_form_decoration to get decor size
*/

/*
Name
        EXposition_form

Description
        This function positions a form near the edge of the screen.  The
        caller may specify which edge[s] to which to move with the input
        argument "position."

History
        mrm     10/25/91    creation
                03/11/92    call EXget_form_decoration to get decor size
*/


int EXposition_form(form_p, position)
Form   form_p;
int position;
{
    int screen_xsize, screen_ysize;
    int form_xsize, form_ysize;
    int xdecor, ydecor, xoffset, yoffset;
    int xlocation, ylocation;

    /* get the pixel size of the screen */
    (void)ige$inq_term_info(x_extent = &screen_xsize,
                            y_extent = &screen_ysize);
#if DEBUG
    printf("screen dimensions: %d, %d\n", screen_xsize, screen_ysize);
#endif

    /* get the size of the form */
    FIf_get_size(form_p, &form_xsize, &form_ysize);
#if DEBUG
    printf("form dimensions: %d, %d\n", form_xsize, form_ysize);
#endif

    /* get the current location of the form */
    FIf_get_location(form_p, &xlocation, &ylocation);
#if DEBUG
    printf("form location: %d, %d\n", xlocation, ylocation);
#endif

    /* allow for window manager decoration and repositioning */
    EXget_form_offset(&xoffset, &yoffset);
    EXget_form_decoration(&xdecor, &ydecor);

    /* calculate new origin - priority is clockwise from the top */
    if (position & EX_TOP_EDGE)
    {
        ylocation = 0 - yoffset;
    }
    if (position & EX_RIGHT_EDGE)
    {
        xlocation = screen_xsize - form_xsize - xdecor - xoffset;
    }
    if (position & EX_BOTTOM_EDGE)
    {
        ylocation = screen_ysize - form_ysize - ydecor - yoffset;
    }
    if (position & EX_LEFT_EDGE)
    {
        xlocation = xoffset;
    }
#if DEBUG
    printf("new form location: %d, %d\n", xlocation, ylocation);
#endif
    FIf_set_location(form_p, xlocation, ylocation);
    return(TRUE);
}


