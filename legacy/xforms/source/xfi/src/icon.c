#include "FImin.h"

#include "MIext.h"
#include <stdio.h>
#include "MS.h"
#include "MI.h"
#include "MIdef.h"

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"

int _MI_window_routine (int                 menu_label,
                        int                 event,
                        struct FIform_obj  *menu)
{
   if ((event == FI_DELETE) && (MI_window_routine))
     {
	  MI_window_routine (menu_label, event, (Form) menu);
     }

   return (FI_SUCCESS);	/* dmb:03/11/91:Examine this */
}

/** OBSOLETE **/
/* ARGSUSED */
int _MI_process_icon (int                 menu_label,
                      int                 icon_id,
                      struct FIform_obj  *menu)
{
  struct FIform_obj *tear_off_menu;

  int status;
  int xlo, ylo, xhi, yhi;

  int center_screen;

   /** Env.V ******
   int marq_vs;
   int marq_window;
   **************/

  struct menu_info_st * menu_info;

  extern void    (*MI_tear_off_modify_routine)();

   if (icon_id == MI_BAR_MOVE_ICON)
   {
	/* Find the center of the screen and use this	*/
	/*      as a basis to determine which direction to	*/
	/*      pop menu to 					*/

	  center_screen = FI_current_screen_height / 2;

	  if (menu->ylo > center_screen)
	  {
         /* Pop to top of screen */

		 FIf_set_location ( (Form) menu, menu->xlo, 0);

		 if (MI_menu_move_routine)
		   {
			MI_menu_move_routine (menu->form_label, MI_TOP);
		   }
	  }
	  else
	  {
         /* Pop to bottom of screen */

	 FIf_set_location ( (Form) menu,
		 menu->xlo,
		 (FI_current_screen_height - (menu->yhi - menu->ylo)) );

		 if (MI_menu_move_routine)
		   {
			MI_menu_move_routine (menu->form_label, MI_BOTTOM);
		   }
	  }
   }
   else if (icon_id == MI_PANEL_MOVE_ICON)
   {
	/*** Find the center of the screen and use this as a	***/
	/*** basis to determine which direction to pop menu to	***/

	  center_screen = FI_current_screen_width / 2;

	  if (menu->xlo > center_screen)
	  {
         /* Pop to left of screen */

		 FIf_set_location ( (Form) menu, 0, 0);

		 if (MI_menu_move_routine)
		   {
			MI_menu_move_routine (menu->form_label, MI_LEFT);
		   }
	  }
	  else
	  {
         /* Pop to right of screen */

		 FIf_set_location ( (Form) menu,
			FI_current_screen_width -
				(menu->xhi - menu->xlo), 0);

		 if (MI_menu_move_routine)
		    {
			MI_menu_move_routine (menu->form_label, MI_RIGHT);
		    }
	  }
   }
   else if (icon_id == MI_TEAR_OFF_ICON)
   {
	  int menu_type = ((struct menu_info_st *) menu->menu_user_pointer)->menu_type;

	  int xsize = 0;
	  int ysize = 0;

	  int marq_orig_xsize;
	  int marq_orig_ysize;

      if (	( menu_type == BAR_MENU )			||
		( menu_type == FI_TEAR_OFF_BAR_MENU_TYPE )	 )
	  {

	/*** Calculate the coordinates of the tear_off so that	***/
	/*** it is next to the bar menu ( below or above 	***/
	/*** based on location )				***/

		 center_screen = FI_current_screen_height / 2;

		 xlo = menu->xlo;
		 xhi = menu->xlo + menu->orig_xsize;

		 if (menu->ylo > center_screen)
		 {
			yhi = menu->ylo - 3;
			ylo = yhi - menu->orig_ysize;
		 }
		 else
		 {
			ylo = menu->yhi + 3;
			yhi = ylo + menu->orig_ysize;
		 }

         /* dmb:03/11/91:Examine this return */
         /** Env.V status = Create_levwin_no_border  *************
	         (menu->vs_no, LEVEL_NORMAL_PRIORITY,
	         xlo, ylo, xhi, yhi, &marq_window);

         if(status)
         return(FI_SUCCESS);
         ********************************************************/

	/*** X11-4/18/90 - Creating a new form also	***/
	/*** creates new Xwindow 			***/

		 marq_orig_xsize = xhi - xlo;
		 marq_orig_ysize = yhi - ylo;

	/*** Set the window to be movable to the 	***/
	/*** other virtual screens			***/

         /** Env.V Set_win_vs_swap(marq_window, 1); **/

         /* Display the marq */

         /* dmb:03/11/91:Examine this */
         /** Env.V status = Display_win_marq(marq_window); ******
         if(status)
         {
         Delete_win(marq_window);
         return(FI_SUCCESS);
         }
         ********************************************************/

	/*** Create the palette and do not add	***/
	/*** to the form group of pointers	***/

	/*  _FI_f_new ( TEAR_OFF_BAR_MENU, menu->name, */

	/*** Add it to the list of form pointers --JAJ:01/20/92 ***/
	FIf_new ( TEAR_OFF_BAR_MENU, menu->name,
			_MI_bar_notify_routine, (Form *)&tear_off_menu);

		/*********************** BEGIN -- JAJ:01/20/92 ****/

			/* Create menu_info_st */

	  menu_info = ( struct menu_info_st * ) 
		calloc ( 1, sizeof ( struct menu_info_st ) );
	
			/* load menu_info with info */

	  menu_info->menu_type  = FI_TEAR_OFF_BAR_MENU_TYPE;

			/* Set the user pointer to be the menu type */

	  tear_off_menu->menu_user_pointer = (char *)menu_info;

		/*********************** END -- JAJ:01/20/92 ****/

         /* Set the window_notification routine */

	 FIf_set_window_event_routine ( (Form) tear_off_menu,
					_MI_window_routine);

         /* Set the initial_notification routine */

	 FIf_set_initial_notification_routine ( (Form) tear_off_menu,
			_MI_bar_notify_routine);

         /* Tell all button in bar that they are menu buttons */

	 _FI_grp_pass_on_id_int_always ( (struct FIgadget_obj *)
		tear_off_menu->group, _MI_btn_set_menu_button, 0, 0);

         /* Get the location of the marq */

         /** Env.V Inq_win_vs(marq_window, &marq_vs); ***************
         status = Inq_win_region(marq_window, &xlo, &ylo, &xhi, &yhi);
         ************************************************************/

		 if (tear_off_menu->Xwindow != None)
		 {
			XWindowAttributes attr;

			XGetWindowAttributes (_FI_display,
				tear_off_menu->Xwindow, &attr);

			xlo = attr.x;
			ylo = attr.y;
			xsize = attr.width;
			ysize = attr.height;
		 }

		 if ((marq_orig_xsize != xsize) || (marq_orig_ysize != ysize))
		 {
			FIf_set_size ( (Form) tear_off_menu, (int) xsize, (int) ysize);
		 }

         /* Set menu variables */

		 tear_off_menu->orig_xlo = xlo;
		 tear_off_menu->orig_ylo = ylo;

		 tear_off_menu->xlo = xlo;
		 tear_off_menu->ylo = ylo;
		 tear_off_menu->xhi = xhi;
		 tear_off_menu->yhi = yhi;

		 tear_off_menu->attr_mask = FI_LINE_BORDER;

         /** Env.V tear_off_menu->vs_no = marq_vs; **/

         /*** NOT USED ****************************
         tear_off_menu->adjusted_size = TRUE;
         ******************************************/

         /* Display the tear_off menu */

		 FIf_display ( (Form) tear_off_menu);

         /* Set the delete icon on */

         /** Env.V Set_win_sys_icon(tear_off_menu->win_no, ******
			 DELETE_ICON_VALUE, 1);
         Delete_win(marq_window);
	*********************************************************/

     /*********************************************************/
     /* sml:09-15-93 add ability to customize tear-off menus  */
     /*  Put this here, so people cannot override the         */
     /*  standard tearoff window event and initial noti       */
     /*  routines.                                            */
     /*********************************************************/

     if (MI_tear_off_modify_routine)
     {
       MI_tear_off_modify_routine(tear_off_menu);
     }


	  }
        else if ( ( menu_type == PANEL_MENU )			||
		  ( menu_type == FI_TEAR_OFF_PANEL_MENU_TYPE )	 )
	  {
		 int label;
		 int has_sub_palette = FALSE;

		 int menu_xlo;
		 int menu_ylo;
		 int menu_xhi;
		 int menu_yhi;

		 struct FIbtn_obj *button;
		 struct FIgroup_obj *group;

		 Window root, child;
		 int root_x, root_y;
		 unsigned int state;
		 XWindowAttributes attr;

         /* Get the location of the mouse */

         /** Env.V Mouseposition(menu->win_no, &xlo, &ylo, &status);**/

		 XQueryPointer (_FI_display, menu->Xwindow, &root, &child, &root_x, &root_y, &xlo, &ylo, &state);

         /* Get the coordinates of the menu window */

         /*** Env.V Inq_win_region(menu->win_no,   ******************
		&menu_xlo, &menu_ylo, &menu_xhi, &menu_yhi);
         **********************************************************/

		 XGetWindowAttributes (_FI_display, menu->Xwindow, &attr);

		 menu_xlo = attr.x;
		 menu_ylo = attr.y;
		 menu_xhi = attr.x + attr.width;
		 menu_yhi = attr.y + attr.height;

         /* Only concerned with the ypos of the mouse */

		 ylo -= MI_WIN_ICON_OFFSET;

         /* Find the button that correspond to the ypos of the mouse */

		 status = FIf_find_gadget ( (Form) menu, FI_FORM_GROUP, 5, ylo, &label);

	/*** If no gadget was found then set	***/
	/*** the group to the forms group	***/

		 if (status)
		 {
			group = menu->group;
		 }
		 else
		 {
			button = (struct FIbtn_obj *) _FI_g_get_id (menu, label);
			group = button->FIgadget.group;
		 }

	/*** Calculate the coordinates of the tear_off so that	***/
	/*** it is next to the panel menu ( to the left or the 	***/
	/*** right based on location )				***/

         /* Set the panels vertical coordinates */

		 if (group->FIgadget.label == FI_FORM_GROUP)
		 {
			ylo = menu_ylo;
			yhi = menu_ylo + menu->orig_ysize;

			has_sub_palette = TRUE;
		 }
		 else
		 {
			int ii;

            /* Check to see if a button in the group 
            has a palette. If it does not have a
            palette then it is a bottom level palette
            and can fit the window around the group */

			for (ii = 0; ii < (int)group->FIgroup.size; ii++)
			{
               /* If the gadget is not a button continue */

			   if (((struct FIgadget_obj *) group->FIgroup.gadgets[ii])->FIgadget.type != FI_BUTTON)
				  continue;

			   if (((struct FIbtn_obj *) group->FIgroup.gadgets[ii])->FIbtn.palette && ((struct FIbtn_obj *) group->FIgroup.gadgets[ii])->FIbtn.palette[0]!= (char) NULL)
			   {
				  has_sub_palette = TRUE;
				  break;
			   }
			}

			ylo = group->FIgadget.ylo + menu_ylo;

			if (has_sub_palette)
			 {
			   yhi = menu_yhi;
			 }
			else
			 {
			   yhi = group->FIgadget.yhi + 6 + menu_ylo;
			 }

		 }

		 center_screen = FI_current_screen_width / 2;

		 if (menu_xlo > center_screen)
		 {
			xhi = menu_xlo - 3;
			xlo = xhi - menu->orig_xsize;
		 }
		 else
		 {
			xlo = menu_xhi + 3;
			xhi = xlo + menu->orig_xsize;
		 }

         /** Env.V status = Create_levwin_no_border  **************
         (menu->vs_no, LEVEL_NORMAL_PRIORITY,
         xlo, ylo, xhi, yhi, &marq_window);
         **********************************************************/

		 if (status)
		   {
			return (FI_SUCCESS);	/* dmb:03/11/91:Examine this */
		   }

		 marq_orig_xsize = xhi - xlo;
		 marq_orig_ysize = yhi - ylo;

         /* Set to no stretch if not a command level palette */

         /** Env.V if(has_sub_palette) **********************
         Set_win_deltas(marq_window, 0, 0);
         *****************************************************/

         /* Set the window to be movable to the
         other virtual screens */

         /** Env.V Set_win_vs_swap(marq_window, 1);  *************

         / * Display the marq * /

         / * dmb:03/11/91:Examine this * /
         / ** Env.V status = Display_win_marq(marq_window);  ******
         if(status)
         {
         Delete_win(marq_window);
         return(FI_SUCCESS);
         }
         ********************************************************/

         /* Create the panel */

/* dmb:10/02/92: Passing menu->cmd_oid here looks very non-portable. */
/* dmb:10/02/92: Adding questionable casts for ANSI. */
	/*** If the group is the form group then create a	***/
	/*** new PANEL_MENU like the current one		***/

	 if ( group->FIgadget.label == FI_FORM_GROUP )
	   {
	     MIm_new ( PANEL_MENU, TEAR_OFF_PANEL_MENU,
			menu->name, (int (*)())menu->cmd_oid, (Form *)&tear_off_menu );
	   }
	 else	/* Create sub panel */
	   {
	     MIm_new ( PANEL_MENU, TEAR_OFF_PANEL_MENU,
		(char *)group->FIgadget.text, (int (*)())menu->cmd_oid, (Form *)&tear_off_menu );
	   }

		/*********************** BEGIN -- JAJ:01/20/92 ****/

	  ((struct menu_info_st *) tear_off_menu->menu_user_pointer)->
				menu_type = FI_TEAR_OFF_PANEL_MENU_TYPE;

		/*********************** END -- JAJ:01/20/92 ****/

         /* Set the window_notification routine */

		 FIf_set_window_event_routine ( (Form) tear_off_menu, _MI_window_routine);

		 if (! has_sub_palette)
		   {
			tear_off_menu->attr_mask &= ~ FI_NOT_SCALABLE;
		   }

         /* Set the original size */

		 tear_off_menu->orig_xsize = xhi - xlo;
		 tear_off_menu->orig_ysize = yhi - ylo;

         /* Set the initial_notification routine */

		 FIf_set_initial_notification_routine ( (Form) tear_off_menu, _MI_panel_notify_routine);

         /* Get the location of the marq */

         /*** Env.V Inq_win_vs(marq_window, &marq_vs); **************
         status = Inq_win_region(marq_window, &xlo, &ylo, &xhi, &yhi);
         ***********************************************************/

	/*** If the window changed size ( in the case	***/
	/*** of a command palette ) then scale the	***/
	/*** gadgets down in the form			***/

		 if (! has_sub_palette)
		 {
			xsize = xhi - xlo;
			ysize = yhi - ylo;

			if ((marq_orig_xsize != xsize) || (marq_orig_ysize != ysize))
			{
			   FIf_set_size ( (Form) tear_off_menu, (int) xsize, (int) ysize);
			}
		 }

         /* Set menu variables */

		 tear_off_menu->orig_xlo = xlo;
		 tear_off_menu->orig_ylo = ylo;

		 tear_off_menu->xlo = xlo;
		 tear_off_menu->ylo = ylo;
		 tear_off_menu->xhi = xhi;
		 tear_off_menu->yhi = yhi;

		 tear_off_menu->attr_mask |= FI_LINE_BORDER;

         /** Env.V tear_off_menu->vs_no = marq_vs; **/
         /* NOT USED *************************************
         tear_off_menu->adjusted_size = TRUE;
         ************************************************/

         /* Display the tear_off menu */

		 FIf_display ( (Form) tear_off_menu);

         /****************** Env.V ****************************
	 window = tear_off_menu->win_no;

         if(has_sub_palette)
         {
         char path[PATH_MAX + 1]
         int dummy;

         Set_win_deltas(window, 0, 1);

	/ *** Create the tear-off icon on 		*** /
	/ *** the pop-up window manipulation window	*** /

         FI_find_symbol_path_and_id(path, "FIsym", &dummy);

         Create_win_user_icon(window, path, 25, 
         RIGHT_SIDE_ICON, MI_TEAR_OFF_ICON);
         }
         / * Set the delete icon on * /
         Set_win_sys_icon(window, DELETE_ICON_VALUE, 1);
         Delete_win(marq_window);
         *****************************************************/
     /*********************************************************/
     /* sml:09-15-93 add ability to customize tear-off menus  */
     /*  Put this here, so people cannot override the         */
     /*  standard tearoff window event and initial noti       */
     /*  routines.                                            */
     /*********************************************************/

     if (MI_tear_off_modify_routine)
     {
       MI_tear_off_modify_routine(tear_off_menu);
     }


	}
   }
   return (FI_SUCCESS);	/* dmb:03/11/91:Examine this */
}
