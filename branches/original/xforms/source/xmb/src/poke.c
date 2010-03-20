
                      /********************************/
                      /*                              */
                      /*            poke.c            */
                      /*                              */
                      /* This set of functions allows */
                      /* for the operator to enter    */
                      /* either one or two datapoints */
                      /* within a specified window.   */
                      /*                              */
                      /*  Programmer: Mack Draper     */
                      /*                              */
                      /*  Date:      Nov. 12, 1988    */
                      /*                              */
                      /********************************/

#include <X11/Xlib.h>

#include <stdio.h>

#include "FI.h"
#include "XMBpriv.h"
#include "UMS.h"
#include "XMB.h"
#include "FEI.h"
#include "FImgt.h"

#include "FImin.h"
#include "FItext.h"

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"
#include "XMBproto_pri.h"

int global_crosshairs_flag;
int menu_bar_window;
int menu_panel_window;

Cursor  curs = None;
XSegment  segs[100];
int Segment_count = 0;



extern int command_is_active;
extern Form work_form;

extern struct  FIform_obj  *MS_bar_menu;
extern struct  FIform_obj  *MS_panel_menu;
extern struct  FIform_obj  *Message_form;

/*
extern GC xfb_GC, dyn_GC;
extern XGCValues GC_values, dyn_GC_values;
extern int hilite_plane;
*/
extern Display *display;

/*
extern int font_count;
extern Form Font_form;
extern Font Font_array[200];

#define TYPEFACE_LIST_FLD 22
#define RIGHT_DOWN 1
#define RIGHT_UP   2
#define LEFT_DOWN  3
#define LEFT_UP    4
*/


/**********************************************************************/
/*                                                                    */
/*                         Refresh_window()                           */
/*                                                                    */
/*   Routine used to force the refresh of a window, much like         */
/*   FIf_display() does in the I/FORMS world.                         */
/*                                                                    */
/**********************************************************************/


/*********************************************************************/
/*** This isn't used anywhere -- JAJ:01/26/92 ************************

int Refresh_window (Window window)
{
XEvent my_event;
int xsize, ysize;

   my_event.type = Expose;
   my_event.xexpose.type = Expose;
   my_event.xexpose.serial = 0;
   my_event.xexpose.send_event = False;
   my_event.xexpose.display = display;
   my_event.xexpose.window = window;
   my_event.xexpose.x = 0;
   my_event.xexpose.y = 0;
   my_event.xexpose.count = 0;

   FIf_get_size (work_form, &xsize, &ysize);
   my_event.xexpose.width = xsize;
   my_event.xexpose.height = ysize;

   XSendEvent (display, window, True, ExposureMask, &my_event);
}
*********************************************************************/



/**********************************************************************/
/*                        Poke_plain_point()                          */
/*                                                                    */
/*  This function is used to obtain a data point inside the specified */
/* form window.  The mouse will be used to enter the point, rather    */
/* than crosshairs.  So applications which use this function do not   */
/* call for a great degree of accuracy.                               */
/*                                                                    */
/*    By the way, this function returns an integer value of two to    */
/* indicate success and a value of one to indicate that the operator  */
/* wishes to terminate the command instead of entering a data point.  */
/**********************************************************************/

/* ARGSUSED */
static int Poke_plain_point (Window window,
                             int *x_pos,
                             int *y_pos)
{
int x_max, y_max;
int done;
Window root, child;
unsigned int flags;
XWindowAttributes window_attr;
int root_x, root_y;
int win_x, win_y;

XEvent event;
Window form_window;

   FIf_get_window (work_form, &form_window);

   XGetWindowAttributes (display, form_window, &window_attr);
   x_max = window_attr.width;
   y_max = window_attr.height;

   done = 0;
   
   while ( done == 0 )
   {
      XNextEvent (display, &event);

      switch (event.type)
      {
         case ButtonPress:
            if (event.xbutton.button == Button2)
            {
               XQueryPointer (display, form_window, &root, &child, 
                              &root_x, &root_y, &win_x, &win_y, &flags);

               if ((win_x >= 0) && (win_x < x_max) &&
                   (win_y >= 0) && (win_y < y_max))
               {
      	          *x_pos = win_x;
         	  *y_pos = win_y;
      	          done = 2;              /*  success  */
               }
               else   /* Added this case to handle selecting another */
                      /* command while the program is waiting for    */
                      /* a button to be selected.  GMD 10/11/91      */
               {
                  done = 1;

                  if (command_is_active == ADD_BUTTON)
                     kill_add_button();
                  else
                     if (command_is_active == EDIT_BUTTON)
                        kill_edit_button();
                  else
                     if (command_is_active == CUT_BUTTON)
                        kill_cut_button();
                  else
                     if (command_is_active == SWAP_BUTTONS)
                        kill_swap_buttons();

                  command_is_active = 0;
                  FI_process_event (&event, 0); /* add 2nd arg for ANSI */
               }
            }
            else if (event.xbutton.button == Button3)
            {
               done = 1;   /* User aborted command */
            }
            break;

            default:
               FI_process_event (&event, 0); /* add 2nd arg for ANSI */
               break;
      }
   }

   return (done);
}


/*--------------------------------------------------------------------*/

void FIf_gadgets_in_point (Form form,
                           int xpos,
                           int ypos,
                           int *num_gadgets,
                           int gadget_array[100])
{
int x;
int status;
int gadget_type;
int loc_x, loc_y;
int x_size, y_size;
int count;
int attr;

   count = 0;
   
   for (x = 1; x < 1000; x++)
   {
      status = FIg_get_type (form, x, &gadget_type);

      if ((status == FI_SUCCESS) &&
          (gadget_type != FI_GROUP))
      {
         FIg_get_attr (form, x, &attr);

         if (attr & FI_NOT_DISPLAYED)
         {
            /* Do nothing */
         }
         else
         {
            FIg_get_location (form, x, &loc_x, &loc_y);
         
            FIg_get_size (form, x, &x_size, &y_size);         

            if (((xpos >= loc_x) &&
                 (xpos <= loc_x + x_size)) &&
                ((ypos >= loc_y) &&
                 (ypos <= loc_y + y_size)))
            {
               gadget_array[count] = x;
               count++;
            }
         }
      }
   }
   
   *num_gadgets = count;
}


/*********************************************************************/
/*** This isn't used anywhere -- JAJ:01/26/92 ************************

int FIf_gadgets_inside_area (Form form,
                             int xlo,
                             int ylo,
                             int xhi,
                             int yhi,
                             int *num_gadgets,
                             int gadget_array[100])
{
int x, y;
int status;
int gadget_type;
int loc_x, loc_y;
int x_size, y_size;
char font_name[80];
float bodysize, dummy_float;
char off_text[2000];
int font_id;
int width;
int count;
int temp_x, temp_y;

   count = 0;
   
   for (x = 1; x < 1000; x++)
   {
      status = FIg_get_type (form, x, &gadget_type);

      if ((status == FI_SUCCESS) &&
          (gadget_type != FI_GROUP))
      {
         FIg_get_location (form, x, &loc_x, &loc_y);
         
         FIg_get_size (form, x, &x_size, &y_size);         
      }
   }
   
   *num_gadgets = count;
}
*********************************************************************/


/**********************************************************************/
/*                        Poke_point_or_keyin()                       */
/*                                                                    */
/*  This function is used to obtain a data point inside the specified */
/* form window.  The mouse will be used to enter the point, rather    */
/* than crosshairs.  So applications which use this function do       */
/* not call for a great degree of accuracy.                           */
/*                                                                    */
/*    The operator is also allowed to type in the gadget label that   */
/* he wishes to select.                                               */
/*                                                                    */
/*    By the way, this function returns an integer value of two to    */
/* indicate success and a value of one to indicate that the operator  */
/* wishes to terminate the command instead of entering a data point.  */
/**********************************************************************/


/*********************************************************************/
/*** This isn't used anywhere -- JAJ:01/26/92 ************************

int Poke_point_or_keyin (int window,
                         int *x_pos,
                         int *y_pos,
                         int *label)
{
int x_line_ptr;
int y_line_ptr;
int x_min, x_max, y_min, y_max, x, y;
int done;
int cur_event_mask;
int button_window, button, transition, timetag;
int plane_mask;
int status;
int old_x, old_y;
char t_str[2000];
char character[200];
int count;
char number_string[100];
int number_index;
char c;
int type;
}
*********************************************************************/



/*--------------------------------------------------------------------*/

/* ARGSUSED */
int Select_gadget (int *gadget_label,
                   int *xsize,
                   int *ysize,
                   int *display_flag,
                   int *hilite_flag,
                   int *accept_x,
                   int *accept_y,
                   int mode)
{
  int xpos, ypos;
  Window window;
  int status;
  int num_gadgets;
  int gadget_array[100];
  char t_str[2000];
  int temp_mode, label;

   FIf_get_window (work_form, &window);

   temp_mode = mode; 
   label = 0;
 
   while ( 1 )
   {
      if (temp_mode == 0)   /* Force operator to poke a point */
      {
         UMSGetByNum (t_str, MB_P_SELGDTKEY, 0);
         FIfld_set_text ((Form)Message_form, 33, 0, 0, t_str, 0);
   
         FIfld_set_text ((Form)Message_form, 44, 0, 0, "", 0);

         status = Poke_plain_point (window, &xpos, &ypos);
         
         temp_mode = mode;
      }
      else  /* Use MB supplied data point */
      {
      	 status = 2;
      	 xpos = *accept_x;
      	 ypos = *accept_y;
      }
      
      if (status == 2)
      {
      	    FIf_gadgets_in_point (work_form, xpos, ypos, &num_gadgets,
      	                                                 gadget_array);
      	 
      	    if (num_gadgets > 0)
      	    {
               FIg_hilite (work_form, gadget_array[0]);	

               XSync (_FI_display, 0);

               if (mode == 1)
                  temp_mode = 0;

               *gadget_label = gadget_array[0];
               return (2);
            }
            else
               if (mode == 1)
                  temp_mode = 0;
      }
      else
      {
         FIfld_set_mode ((Form)Message_form, 44, 0, FI_REVIEW);
         return(1);
      }
   }
}

