#include "FImin.h"

#include "MSext.h"
#include <stdio.h>
#include "MS.h"
#include "MI.h"

#include "MIdef.h"
#include "FIdyn.h"

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"

#define NULL_FORM (struct FIform_obj *) 0

static struct FIform_obj * MS_last_form_ptr	= NULL_FORM;
static int		   MS_last_gadget_label	= -1;
static char		 * MS_startup_file	= NULL;


/* GMD 3/31/92 */

static int last_x_loc = -1;
static int last_y_loc = -1;

void _MS_check_ptr (struct FIform_obj *menu_ptr)
{
  /*** If the menu being deleted is the last menu to be selected, ***/
  /***  then set the MS_last_form_ptr to null                     ***/

  if ( menu_ptr == MS_last_form_ptr )
    {
      MS_last_form_ptr = NULL_FORM;
    }
}


/* ARGSUSED */
int _MS_window_routine (int                form_label,
                        int                event,
                        struct FIform_obj *menu)
{
  if ( event == FI_DELETE )
    {
      _MS_check_ptr ( menu );
    }

  return ( MS_SUCCESS );
}


int _MS_menu_move (int menu_label,
                   int location)
{
	/* Only move the BAR_MENU if on the same vs */

  if (	( menu_label == PANEL_MENU )	&&   MS_bar_menu	&&
	( MS_panel_menu->Xscreen == MS_bar_menu->Xscreen )	 )
    {
      if ( location == MI_LEFT )
	{
	        /* Move the bar menu to the right, so that */
		/* it's up against the PANEL_MENU.	   */

	  FIf_set_location ( (Form) MS_bar_menu,
			MS_panel_menu->xhi + 1, MS_bar_menu->ylo );
	}
      else
	{
	        /* Move the bar menu to the left, so that */
		/* it's up against the PANEL_MENU.	   */

	  FIf_set_location ( (Form) MS_bar_menu,
			MS_panel_menu->xlo -
			( MS_bar_menu->xhi - MS_bar_menu->xlo ) - 1,
			MS_bar_menu->ylo );
	}
    }
  return ( MS_SUCCESS );
}


/* ARGSUSED */
int _MS_notify (int                form_label,
                int                gadget_label,
                double             value,
                struct FIform_obj *form_ptr)
{
  if (	( MS_last_form_ptr != form_ptr )	&&
	( MS_last_form_ptr != NULL_FORM )	 )
    {
      MI_pop_up_button ( (Menu) MS_last_form_ptr,
					 MS_last_gadget_label );
    }

  MS_last_form_ptr	= form_ptr;
  MS_last_gadget_label	= gadget_label;

  return ( MS_SUCCESS );
}


int MS_pop_up_last_button (void)
{
  if ( MS_last_form_ptr != NULL_FORM )
    {
      MI_pop_up_button ( (Menu) MS_last_form_ptr,
				 MS_last_gadget_label );
    }

  MS_last_form_ptr = NULL_FORM;

  return ( MS_SUCCESS );
}


/*
Name
        FIf_set_wm_offsets

Description
        This function allows an application to set the window manager
        decoration offsets used by FIf_overlay (and perhaps more, someday)
        when positioning forms on the screen.  Some applications (like I/EMS)
        already determine this up front, and there is no need to reinvent that
        wheel here unless necessary.

History
        Mike Mathis     04/09/93    creation
*/

static int local_xoffset = -1;
static int local_yoffset = -1;

void FIf_set_wm_offsets(int xoffset, int yoffset)
{
    local_xoffset = xoffset;
    local_yoffset = yoffset;
}

/*
Name
        FIf_get_wm_offsets

Description
        This function returns the values stored locally that reflect the sizes
        of the window manager decorations placed around a form.

Return Values
        FI_SUCCESS - offsets returned
        FI_ILLEGAL_VALUES - offsets not set up

History
        Mike Mathis     04/09/93    creation
*/

int FIf_get_wm_offsets(int *xoffset, int *yoffset)
{
    if (local_xoffset == -1)
    {
        *xoffset = 0;
        *yoffset = 0;
        return(FI_ILLEGAL_VALUES);
    }
    else
    {
        *xoffset = local_xoffset;
        *yoffset = local_yoffset;
        return(FI_SUCCESS);
    }
}

/*
Name
        FIf_overlay

Synopsis
        int FIf_overlay(Form form_a, Form form_b)

Description
        This function overlays one form with another by aligning the upper
        left corner of form_b with that of form_a.  Window manager decoration
        is taken into account, provided form_a is displayed.  If form_a is not
        displayed, then the necessary offsets cannot be determined, since the
        window manager will not have mapped or parented the window yet.  Since
        the offsets are not likely to change often (only when the window
        manager is restarted with different decoration parameters), they are
        only determined once and stored using FIf_set_wm_offsets.

History
        Mike Mathis     04/09/93    creation
*/

int FIf_overlay(Form form_a, Form form_b)
{
    int sts, xpos, ypos, displayed;
    int xoffset = 0, yoffset = 0;

    sts = FIf_get_wm_offsets(&xoffset, &yoffset);
    if (sts != FI_SUCCESS)
    {
        FIf_is_displayed((Form)form_a, &displayed);
        if (displayed)
        {
            int x, y, xx, yy;
            int xdecor, ydecor;
            int xorigin, yorigin;
            unsigned int width, height, borderwidth, depth, nchildren;
            Window win, root, parent, *children;
            int xxoffset, yyoffset;

            FIf_get_window((Form)form_a, &win);
            FIf_get_orig_location((Form)form_a, &x, &y);
            FIf_get_location((Form)form_a, &xx, &yy);
            xxoffset = xx - x;
            yyoffset = yy - y;
            xoffset = yoffset = xdecor = ydecor = 0;

            /* walk up the window ancestry adding offsets */
            do
            {
                XQueryTree(_FI_display, win, &root, &parent,
                           &children, &nchildren);
                if (nchildren)
                    XFree((caddr_t)children);
                XGetGeometry(_FI_display, win, &root, &xorigin, &yorigin,
                             &width, &height, &borderwidth, &depth);
                if (parent != root)
                {
                    xdecor += xorigin;
                    ydecor += yorigin;
                }
                xoffset += xorigin;
                yoffset += yorigin;
                win = parent;
            } while (parent != root);
                
            /* adjust offsets */
            xoffset -= x;
            yoffset -= y;
            if ((xdecor != xxoffset) || (ydecor != yyoffset))
            {
                xoffset = xdecor;
                yoffset = ydecor;
            }

            /* store the offsets for the next time through */
            FIf_set_wm_offsets(xoffset, yoffset);
        }
    }

    /* adjust the location */
    FIf_get_location((Form)form_a, &xpos, &ypos);
    FIf_set_location((Form)form_b, xpos - xoffset, ypos - yoffset);

    return(FI_SUCCESS);
}



int MS_swap_menu (int   menu_type,
                  char *menu_name)
{
  int		status;
  int		menu_label;
  int		(*menu_notify_func)();
  struct FIform_obj *temp_menu;

	/* If the menu name is "no" or "NO" then delete the menu */

  if (	! strcmp ( menu_name, "NO" )	||
	! strcmp ( menu_name, "no" )	||
	! strcmp ( menu_name, "none" )	 )
    {
      if ( ( menu_type == BAR_MENU ) &&  MS_bar_menu  )
	{
	  FIf_delete ( (Form) MS_bar_menu );
	  _MS_check_ptr ( MS_bar_menu );
	  MS_bar_menu = NULL_FORM;
	}
      else if ( ( menu_type == PANEL_MENU ) &&   MS_panel_menu  )
	{
      FIf_get_location ((Form) MS_panel_menu, &last_x_loc, &last_y_loc);
	  FIf_delete ( (Form) MS_panel_menu );
	  _MS_check_ptr ( MS_panel_menu );
	  MS_panel_menu = NULL_FORM;
	}
      else if ( ( menu_type == POCKET_MENU ) &&   MS_pocket_menu  )
	{
	  FIf_delete ( (Form) MS_pocket_menu );
	  _MS_check_ptr ( MS_pocket_menu );
	  MS_pocket_menu = NULL_FORM;

		/******************************************/
		/*** Reset the _MI_last_button variable ***/
		/*** ( a "static" in pocket.c ).	***/
		/*********************  JAJ:11/12/91    ***/

	  _MI_reset_mi_last_button ( );
	}

      return ( MS_SUCCESS );
    }

	  /* Create new menu */

	  /* Get the label from the old menu */

  if ( menu_type == BAR_MENU )
    {
      if (MS_bar_menu)
         menu_label	= MS_bar_menu->form_label;
      else
         menu_label     = BAR_MENU;
      menu_notify_func	= _MS_notify;
    }
  else if ( menu_type == PANEL_MENU )
    {
      if (MS_panel_menu)
         menu_label	= MS_panel_menu->form_label;
      else
         menu_label     = PANEL_MENU;
      menu_notify_func	= _MS_notify;
    }
  else
    {
      if (MS_pocket_menu)
         menu_label	= MS_pocket_menu->form_label;
      else
         menu_label     = POCKET_MENU;
      menu_notify_func	= 0;
    }

  status = MIm_new ( menu_type, menu_label, menu_name,
			 menu_notify_func, (Form *) &temp_menu );
  if ( status )
    {
      return ( MS_READ_ERROR );
    }

  MS_last_form_ptr = NULL_FORM;

  if ( menu_type == BAR_MENU )
    {
#if 1
        if (MS_bar_menu)
        {
            /* align the left corner of the new menu with the old */
            FIf_overlay((Form)MS_bar_menu, (Form)temp_menu);

            /* delete the old menu */
            FIf_delete((Form) MS_bar_menu);
        }

        /* display the new menu */
        MIm_display((Form)temp_menu);

        /* store the new menu pointer */
        MS_bar_menu = temp_menu;

#else   /* old code */

	/*** Copy all of the button gadgets from the new ***/
	/*** menubar form to the old menubar form.  Make ***/
	/*** sure that they adjust their size to fill    ***/
        /*** the menubar.                                ***/
        /* GMD 3/27/92  */

      if ( MS_bar_menu )
      {
      int xx, status, attr, index, type;
      int x_size, y_size, x_loc, y_loc, off_color, on_color;
      struct FIgadget_obj * old_gadget, * new_gadget;
      float bodysize;
      char t_str[1000];

         FIg_delete (MS_bar_menu, 0);   /* Delete all buttons on form */

         /* make sure that buttons will be the correct height and width */

         FIf_get_size (MS_bar_menu, &x_size, &y_size);
         FIf_set_size (temp_menu, x_size, y_size);

         FIf_get_name (temp_menu, t_str);
         _FI_s_rep (&MS_bar_menu->name, t_str);

         /* Now copy the gadgets */

         for (xx = 1; xx < 200; xx++)
         {
            status = FIg_get_type (temp_menu, xx, &type);

            if (status == FI_SUCCESS)
            {
            struct standard_st def_attr;
            char command[1000], fontname[1000], off_text[1000];
            char help_topic[1000];
 
               FIg_new (MS_bar_menu, FI_BUTTON, xx);

               FIg_get_location (temp_menu, xx, &x_loc, &y_loc);
               def_attr.xlo = (short) x_loc;
               def_attr.ylo = (short) y_loc;

               FIg_get_size (temp_menu, xx, &x_size, &y_size);
               def_attr.xhi = (short) (x_loc + x_size);
               def_attr.yhi = (short) (y_loc + y_size);

               FIg_get_attr (temp_menu, xx, &attr);
               def_attr.attr_mask = attr;

               FIg_get_off_color (temp_menu, xx, &off_color);
               def_attr.off_color = off_color;
            /* delete the old menu */
            FIf_delete( (Form) MS_bar_menu);
        }

               FIg_get_on_color (temp_menu, xx, &on_color);
               def_attr.on_color = on_color;

               FIg_get_command (temp_menu, xx, command);
               def_attr.command = command;

               help_topic[0] = '\0';
               def_attr.help_topic = help_topic;

               old_gadget = _FI_g_get_id (temp_menu, xx);
 
               if (attr & FI_TEXT_GADGET)
               {
                  FIg_get_font (temp_menu, xx, fontname, &bodysize);
                  def_attr.fontname = fontname;
                  def_attr.bodysize = bodysize;

                  FIg_get_off_text (temp_menu, xx, off_text);
                  def_attr.text = off_text;
               }
               else   /* symbol button */
               {
                  off_text[0] = '\0';
                  def_attr.text = off_text;

                  FIg_get_symbol_file (temp_menu, xx, fontname);
                  def_attr.fontname = fontname;

                  FIg_get_off_symbol_index (temp_menu, xx, &index);
                  def_attr.symbol_index = index;

                  if (old_gadget->FIgadget.on_symbol_ptr.sym_index != NULL)
                     def_attr.symbol_index2 = 
                          old_gadget->FIgadget.on_symbol_ptr.sym_index;
                  else
                     def_attr.symbol_index2 = 0;
               }

               FIg_set_standard_variables (MS_bar_menu, xx, &def_attr);

               new_gadget = _FI_g_get_id (MS_bar_menu, xx);
               ((struct FIbtn_obj *) new_gadget)->FIbtn.menu_button = 1;

              new_gadget->FIgadget.off_color2 = old_gadget->FIgadget.off_color2;
              new_gadget->FIgadget.on_color2 = old_gadget->FIgadget.on_color2;

               FIg_activate (MS_bar_menu, xx);

               /* GMD 3/30/92 */

               FIg_set_state_off (MS_bar_menu, xx);

               FIg_display (MS_bar_menu, xx);
            }
         }

         FIf_delete (temp_menu);
      }
      else
      {

	/* Display the new bar menu */

         MIm_display ( (Form) temp_menu );

         MS_bar_menu = temp_menu;
      }
#endif

    }
  else if ( menu_type == PANEL_MENU )
    {
     /*** Set the location of the new panel menu to be ***/
     /*** the same as the old panel being swapped out 	***/

      if ( MS_panel_menu )
        {
#if 1
            /* align the left corner of the new menu with the old - mrm 4/93 */
            FIf_overlay((Form)MS_panel_menu, (Form)temp_menu);
#else
	  FIf_set_location ( (Form) temp_menu,
			MS_panel_menu->xlo, MS_panel_menu->ylo );
#endif
        }
      else
        {
           if (last_x_loc != -1)
              FIf_set_location ( (Form) temp_menu, last_x_loc, last_y_loc);
        }

	     /* Display the new panel menu */

      MIm_display ( (Form) temp_menu );

	     /* Delete the old panel menu */

      if ( MS_panel_menu )
	{
	  _MS_check_ptr ( MS_panel_menu );
	  FIf_delete ( (Form)MS_panel_menu );
	}

      MS_panel_menu = temp_menu;
    }
  else if ( menu_type == POCKET_MENU )
    {
	     /* Delete the old pocket menu */

      if ( MS_pocket_menu )
	{
	  _MS_check_ptr ( MS_pocket_menu );
	  FIf_delete ( (Form)MS_pocket_menu );
	}

      MS_pocket_menu = temp_menu;

	/**************************************************/
        /*** Reset the _MI_last_button variable 	***/
        /*** ( a static in pocket.c )    JAJ:11/12/91   ***/
        /**************************************************/

      _MI_reset_mi_last_button ( );
    }

  return ( MS_SUCCESS );
}


int MS_save_locations (char  *file)
{
  FILE		*fout;
/* dmb:10/07/92:Do we need this? extern FILE	*fopen();  */


  fout = fopen ( file, "w");
  if ( fout )
    {
      if ( MS_bar_menu )
	{
	  fprintf ( fout, "BAR_MENU %d %d %d %d\n",
			 MS_bar_menu->xlo, MS_bar_menu->ylo,
			MS_bar_menu->xhi, MS_bar_menu->yhi );
	}

      if ( MS_panel_menu )
	{
	  fprintf ( fout, "PANEL_MENU %d %d %d %d\n",
			MS_panel_menu->xlo, MS_panel_menu->ylo,
			MS_panel_menu->xhi, MS_panel_menu->yhi );
	}

      fclose ( fout );
    }
  else
    {
      return ( MS_WRITE_ERROR );
    }

  return ( MS_SUCCESS );
}



int MS_set_startup_file (char *file)
{
  _FI_s_rep ( &MS_startup_file, file );

  return ( MS_SUCCESS );
}


int MS_get_startup_file (char file[])
{
  strcpy ( file, MS_startup_file );

  return ( MS_SUCCESS );
}


int MS_init_menus (void)
{
  FILE	*fin;
  int	status;
  float delta_x;
  float delta_y;
  int	bar_xlo = 0;
  int	bar_ylo = 0;
  int	bar_xhi = 0;
  int	bar_yhi = 0;
  int	panel_xlo = 0;
  int	panel_ylo = 0;
  int	panel_xhi = 0;
  int	panel_yhi = 0;
  int	bar_loc_defined = FALSE;
  int	panel_loc_defined = FALSE;


	/* Create menus */

  status = MIm_new ( BAR_MENU, BAR_MENU, "BAR_MENU", _MS_notify,
					 (Form *) &MS_bar_menu );
  if ( status )
    {
      MS_bar_menu = NULL_FORM;
    }

  status = MIm_new ( PANEL_MENU, PANEL_MENU, "PANEL_MENU", _MS_notify,
					 (Form *) &MS_panel_menu );
  if ( status )
    {
      MS_panel_menu = NULL_FORM;
    }

  status = MIm_new ( POCKET_MENU, POCKET_MENU, "POCKET_MENU",
				 _MS_notify, (Form *) &MS_pocket_menu );
  if ( status )
    {
      MS_pocket_menu = NULL_FORM;
    }


	/* If location file exists, then use it */

  fin = fopen ( MS_startup_file, "r");
  if ( fin )
    {
      char	menu_type[64];
      int	xlo, ylo, xhi, yhi;
      int	num_read = 0;

      for ( ; ; )
	{
	  num_read = fscanf ( fin, "%s%d%d%d%d",
			menu_type, &xlo, &ylo, &xhi, &yhi );

	  if ( feof ( fin ) )
	    {
		break;
	    }

	        /* If part of file gone continue */

	  if ( num_read < 3 )
	    {
		continue;
	    }

	  if ( ! strcmp ( menu_type, "PANEL_MENU") )
	    {
	      panel_xlo = xlo;
	      panel_ylo = ylo;

	      if ( num_read == 5 )
		{
		  panel_xhi = xhi;
		  panel_yhi = yhi;
		}
	      else
		{
		  panel_xhi = panel_xlo + MS_panel_menu->orig_xsize;

		  panel_yhi = panel_ylo + MS_panel_menu->orig_ysize;
		}

	      panel_loc_defined = TRUE;
	    }
	  else if ( ! strcmp ( menu_type, "BAR_MENU") )
	    {
	      bar_xlo = xlo;
	      bar_ylo = ylo;

	      if ( num_read == 5 )
		{
		  bar_xhi = xhi;
		  bar_yhi = yhi;
		}
	      else
		{
		  bar_xhi = bar_xlo + MS_bar_menu->orig_xsize;

		  bar_yhi = bar_ylo + MS_bar_menu->orig_ysize;
		}

	      bar_loc_defined = TRUE;
	    }
	}	/* END for */

      fclose ( fin );
    }

	/* Set panel location */

  if ( MS_panel_menu )
    {
      if ( ! panel_loc_defined )
	{
	  panel_xlo = FI_current_screen_width -
					 MS_panel_menu->orig_xsize ;
	  panel_ylo = 0;

	  panel_xhi = panel_xlo + MS_panel_menu->orig_xsize;
	  panel_yhi = panel_ylo + MS_panel_menu->orig_ysize;
	}

      MS_panel_menu->xlo = panel_xlo;
      MS_panel_menu->ylo = panel_ylo;

      MS_panel_menu->xhi = panel_xhi;
      MS_panel_menu->yhi = panel_yhi;

      FIf_set_size ( (Form) MS_panel_menu,
			(int) ( panel_xhi - panel_xlo ),
			(int) ( panel_yhi - panel_ylo )  );

      FIf_set_location ( (Form) MS_panel_menu,
				panel_xlo, panel_ylo );

      MS_panel_menu->orig_xlo = panel_xlo;    /*** JAJ:09/25/91 ***/
      MS_panel_menu->orig_ylo = panel_ylo;    /*** JAJ:09/25/91 ***/


		/***********************************************/
		/*** Adjust the size of the new palette,     ***/
		/*** in case parent menu has been scaled.    ***/
		/*****************************  JAJ:11/12/91 ***/

      delta_x = (float) ( ( (float) (MS_panel_menu->xhi -
					MS_panel_menu->xlo) ) /
				( (float) MS_panel_menu->orig_xsize ) );

      delta_y = (float) ( ( (float) (MS_panel_menu->yhi -
					MS_panel_menu->ylo) ) /
				( (float) MS_panel_menu->orig_ysize ) );

	/* Send change to gadgets to adjust	    */
	/* themselves relative to the new form size */

      if ( delta_x == 0.0 )
	{
	  delta_x = 1.0;
	}

      if ( delta_y == 0.0 )
	{
	  delta_y = 1.0;
	}

      if ( ( delta_x != 1.0 ) || ( delta_y != 1.0 ) )
	{
	  _FI_g_adjust_size ( (struct FIgadget_obj *)MS_panel_menu->group, delta_x, delta_y );
	}
    }

	/* Set bar location */

  if ( MS_bar_menu )
    {
      if ( ! bar_loc_defined )
	{
	  if ( MS_panel_menu )	/*** JAJ:09/25/91 ***/
	    {
		 bar_xlo = MS_panel_menu->xlo - MS_bar_menu->orig_xsize;
            }
          else
	    {
		bar_xlo = 0;
            }

          bar_ylo = 0;

          bar_xhi = bar_xlo + MS_bar_menu->orig_xsize;
          bar_yhi = /* bar_ylo + */ MS_bar_menu->orig_ysize;
	}

      FIf_set_size ( (Form) MS_bar_menu, (int) ( bar_xhi - bar_xlo ),
					 (int) ( bar_yhi - bar_ylo ) );

      FIf_set_location ( (Form) MS_bar_menu, bar_xlo, bar_ylo );

	/*** Make the bar menu be snugly fit up against the	***/
	/*** panel menu ( if any ).				***/
	/*** Added check for MS_panel_menu -- JAJ:11/12/91 	***/

      MS_bar_menu->orig_xlo = FI_current_screen_width -
				        MS_bar_menu->orig_xsize ;
      if ( MS_panel_menu )
	{
          MS_bar_menu->orig_xlo -= MS_panel_menu->orig_xsize ;
	}

      MS_bar_menu->orig_ylo = bar_ylo;
    }

  return ( MS_SUCCESS );
}


int MS_display_menus (void)
{
  int	ii;
  struct FIform_obj * temp_form;
  int	menu_type;


  if ( MS_bar_menu )
    {
      MIm_display ( (Form) MS_bar_menu );
    }

  if ( MS_panel_menu )
    {
      MIm_display ( (Form) MS_panel_menu );
    }

	/*** Display the TEAR-OFF-MENUS -- JAJ:01/20/92 ***/

  for ( ii = 0; ii < (int)_FI_form_list->FIgroup.size ; ii++ )
    {
      temp_form = (struct FIform_obj *)
				_FI_form_list->FIgroup.gadgets[ii];

      if ( temp_form && temp_form->menu_user_pointer )
	{
      	  menu_type = ( (struct menu_info_st *)
			temp_form->menu_user_pointer)->menu_type;

	  if (	( menu_type == FI_TEAR_OFF_BAR_MENU_TYPE )	||
		( menu_type == FI_TEAR_OFF_PANEL_MENU_TYPE )	 )
	    {
	      MIm_display ( (Form)temp_form );
	    }
	}
    }

  return ( MS_SUCCESS );
}


int MS_erase_menus (void)
{
  int	ii;
  struct FIform_obj * temp_form;
  int	menu_type;


  /* Erase menus */

  if ( MS_bar_menu )
    {
      FIf_erase ( (Form) MS_bar_menu );
    }

  if ( MS_panel_menu )
    {
      FIf_erase ( (Form) MS_panel_menu );
    }

	/*** Erase the TEAR-OFF-MENUS -- JAJ:01/20/92 ***/

  for ( ii = 0; ii < (int)_FI_form_list->FIgroup.size ; ii++ )
    {
      temp_form = (struct FIform_obj *)
				_FI_form_list->FIgroup.gadgets[ii];

      if ( temp_form && temp_form->menu_user_pointer )
	{
      	  menu_type = ( (struct menu_info_st *)
			temp_form->menu_user_pointer)->menu_type;

	  if (	( menu_type == FI_TEAR_OFF_BAR_MENU_TYPE )	||
		( menu_type == FI_TEAR_OFF_PANEL_MENU_TYPE )	 )
	    {
	      FIf_erase ( (Form)temp_form );
	    }
	}
    }

  return ( MS_SUCCESS );
}


int MS_delete_menus (void)
{
  int	ii;
  struct FIform_obj * temp_form;
  int	menu_type;


	/* Delete menus */

  if ( MS_bar_menu )
    {
      FIf_delete ( (Form) MS_bar_menu );
    }

  if ( MS_panel_menu )
    {
      FIf_delete ( (Form) MS_panel_menu );
    }

  if ( MS_pocket_menu )
    {
      FIf_delete ( (Form) MS_pocket_menu );

	/**************************************************/
        /*** Reset the _MI_last_button variable 	***/
        /*** ( a static in pocket.c )    JAJ:11/12/91   ***/
        /**************************************************/

      _MI_reset_mi_last_button ( );
    }

	/*** Delete the TEAR-OFF-MENUS -- JAJ:01/20/92 ***/

  for ( ii = 0; ii < (int)_FI_form_list->FIgroup.size ; ii++ )
    {
      temp_form = (struct FIform_obj *)
				_FI_form_list->FIgroup.gadgets[ii];

      if ( temp_form && temp_form->menu_user_pointer )
	{
      	  menu_type = ( (struct menu_info_st *)
			temp_form->menu_user_pointer)->menu_type;

	  if (	( menu_type == FI_TEAR_OFF_BAR_MENU_TYPE )	||
		( menu_type == FI_TEAR_OFF_PANEL_MENU_TYPE )	 )
	    {
	      FIf_delete ( (Form)temp_form );
	    }
	}
    }

  /* Set variables to NULL_FORM */

  MS_bar_menu	 = NULL_FORM;
  MS_panel_menu  = NULL_FORM;
  MS_pocket_menu = NULL_FORM;

  /* Set MS_last_form_ptr to NULL_FORM */

  MS_last_form_ptr = NULL_FORM;

  return ( MS_SUCCESS );
}


int MS_process_pocket (int Xscreen,
                       int xpos,
                       int ypos)
{
	  /* If the pocket menu does not exist then return */

  if ( ! MS_pocket_menu )
    {
      return ( MS_SUCCESS );
    }

	  /* Assign the vs */

  MS_pocket_menu->Xscreen = Xscreen;

	  /* Set the location to that of the mouse */

  FIf_set_location ( (Form) MS_pocket_menu, xpos, ypos );

	  /* Call menu interface to display and process pocket */

  MIm_display ( (Form) MS_pocket_menu );

  return ( MS_SUCCESS );
}


int MS_enter (void)
{
  MS_bar_menu      = NULL_FORM;
  MS_panel_menu    = NULL_FORM;
  MS_pocket_menu   = NULL_FORM;

  MS_last_form_ptr = NULL_FORM;
  MS_last_gadget_label = -1;

  MI_enter ();

	/*** Set up routine that will notify subsystem of	***/
	/***  any notifications upon a tear-off menu.		***/

  MI_set_tear_off_notification_routine ( _MS_notify );

	/*** Set up routine that will notify subsystem of	 ***/
	/*** any moves made by the user ( move icons on menus )  ***/

  MI_set_menu_move_routine ( _MS_menu_move );

	/*** Set up the routine that's called when any of the menu  ***/
	/*** windows receive a window event from the forms system.  ***/

  MI_set_window_routine ( _MS_window_routine );

	/* Set the startup file to be menu_locations by default */

  _FI_s_rep ( &MS_startup_file, "./menu_locations");

  return ( MS_SUCCESS );
}
