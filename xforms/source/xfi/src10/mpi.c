#include "FImin.h"

#include <stdio.h>
#include "MS.h"
#include "MI.h"
#include "MIdef.h"
#include "MIext.h"

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"

extern int MI_palette_vert_offset;

int _MI_btn_set_user_pointer (struct FIgadget_obj  *gadget,
                              struct pal_info_st   *pal_info)
{
	/*** Return if not button gadget ***/

  if ( gadget->FIgadget.type != FI_BUTTON )
    {
      return ( FI_SUCCESS );	/* dmb:03/11/91:Examine this */
    }

	/*** Calloc space form the info structure	***/
	/*** used by each button on the PANEL_MENU	***/

  gadget->FIgadget.menu_user_pointer = calloc ( 1,
					sizeof (struct btn_info_st ));


	/*** Make the pal_info pointer point	***/
	/*** to the palette info structure	***/

  ((struct btn_info_st *) gadget->FIgadget.menu_user_pointer )->
						pal_info = pal_info;

  return ( FI_SUCCESS );	/* dmb:03/11/91:Examine this */
}



int _MI_btn_set_menu_button (struct FIgadget_obj *gadget)
{
	/*** Set the bit only if the gadget is a button ***/

  if ( gadget->FIgadget.type == FI_BUTTON )
    {
      ((struct FIbtn_obj *) gadget )->FIbtn.menu_button = 1;
    }

  return ( FI_SUCCESS );	/* dmb:03/27/91:Added */
}




int MIm_new (int   menu_type,
             int   menu_label,
             char *menu_name,
             int (*notification_routine) (),
             Form *menu)
{
  struct menu_info_st	*menu_info;
  struct FIform_obj	*mp;
  int			 ii;
  int			 status;

  if ( menu_type == PANEL_MENU )
    {
      struct FIgroup_obj *palette;
      struct FIgroup_obj *group;
      struct pal_info_st *pal_info;

	/*** Make the form system call this one	***/
	/*** before the one defined by interface.	***/

      status = FIf_new ( menu_label, menu_name,
			 _MI_panel_notify_routine, (Form *) menu );
      if ( status )
	{
	  return ( status );
	}

	/*** Set the initial notification routine ***/


/*      FIf_set_initial_notification_routine ( (Form *) *menu,  dmb:10/02/92:Original */

/* dmb:10/02/92: Changed for ANSI */
      FIf_set_initial_notification_routine ( (Form) *menu,
					 _MI_panel_notify_routine );

	/*** Create a palette to contain the buttons ***/
	/*** that are on the top-level menu ***/

      _FI_g_new ( (struct FIform_obj *) *menu, FI_GROUP,
					 MI_TOP_PALETTE, (struct FIgadget_obj **)&palette );

	/*** Store the menu name into the	***/
	/*** text part of the palette group	***/

      _FI_s_rep ( ( char **) &palette->FIgadget.text,
			 ((struct FIform_obj *) *menu )->name );

	/*** Set the location to 3, 3 ***/

      FIg_set_location ( (Form) *menu, MI_TOP_PALETTE, 3, 3 );

	/*** Add the button in the forms group ***/
	/*** to the palette group ***/

      group = ((struct FIform_obj *) *menu )->group;

      for ( ii = 0; ii < (int)group->FIgroup.size; ii++ )
	{
	  if (   group->FIgroup.gadgets[ii]			&&
		(((struct FIgadget_obj *) group->FIgroup.gadgets[ii])->
					FIgadget.type == FI_BUTTON )  )
	    {
	      _FI_g_add_to_group ( group->FIgroup.gadgets[ii],
						 MI_TOP_PALETTE, 0 );
	    }
	}

	/*** Create a pal_info structure	***/
	/*** for the palette of buttons.	***/

      pal_info = (struct pal_info_st *) calloc ( 1,
				 sizeof (struct pal_info_st ));

	/*** Set each button in group with a btn_info structure ***/

      _FI_grp_pass_on_id_int ( (struct FIgadget_obj *) palette,
			 _MI_btn_set_user_pointer, (int) pal_info, 0 );


	/**************************************** JAJ:09/25/91 ****
		/ *** Set form scaling off for panel *** /
      ((struct FIform_obj *) *menu )->attr_mask |= FI_NOT_SCALABLE;
	************************************************************/



	/*** Set the collapse symbol to be the menu symbol ***/

      FIf_set_collapse_symbol ( (Form) *menu, "collapse.icon", 2 );

	/*** KLUDGE UNTIL HAVE A BUILDER TO SUPPORT FORMAT ***/

      _FI_grp_pass_on_id_int_always ( (struct FIgadget_obj *) palette,
				       _MI_btn_set_menu_button, 0, 0 );

	/*** Calculate the size of the group ***/

      _FI_grp_calculate_size ( palette );
    }
  else if ( menu_type == BAR_MENU )
    {
	/* Make the form system call this one	*/
	/* before the one defined by interface	*/

      status = FIf_new ( menu_label, menu_name, _MI_bar_notify_routine,
						(Form *) menu );
      if ( status )
	{
	  return ( status );
	}

	/* Set the initial notification routine */

      FIf_set_initial_notification_routine ( (Form) *menu,
					_MI_bar_notify_routine );

     /* Set the collapse symbol to be the menu symbol */

      FIf_set_collapse_symbol ( (Form) *menu, "collapse.icon", 1 );
    }
  else	/** POCKET MENU **/
    {
      status = FIf_new ( menu_label, menu_name,
			 notification_routine, (Form *) menu );
      if ( status )
	{
	  return ( status );
	}
    }

	/* Assign local menu pointer to save code */

  mp = (struct FIform_obj *) *menu;

	/* Store the address of notification routine in cmd_oid */

  mp->cmd_oid = (unsigned int) notification_routine;

	/* Create menu_info_st */

  menu_info = (struct menu_info_st *) calloc ( 1,
					 sizeof (struct menu_info_st ));

	/* load menu_info with info */

  menu_info->menu_type = menu_type;
  menu_info->next_label = MI_START_LABEL;

	/* KLUDGE until mb comes */

  mp->seq_label = -1;

	/* Set the user pointer to be the menu type */

  mp->menu_user_pointer = (char *) menu_info;

	/* Set the adjusted size flag */

  /* CHUNN forms currently doesn't support scaling with screen size 

  if ( ! MI_adjust_size )
  mp->adjusted_size = TRUE;
  ***********************************************************/


	/* Set up icon for tear offs */

  FIf_set_window_icon_routine ( (Form) *menu, _MI_process_icon );

  if ( menu_type != PANEL_MENU )
    {
     /* KLUDGE UNTIL HAVE A BUILDER TO SUPPORT FORMAT */

      _FI_grp_pass_on_id_int_always ( (struct FIgadget_obj *) mp->group,
				 _MI_btn_set_menu_button, 0, 0 );
    }

  return ( MI_SUCCESS );

}	/*** MIm_new ()***/



int MIm_display (Form menu)
{
  int menu_type = ( (struct menu_info_st *)
	    ((struct FIform_obj *) menu)->menu_user_pointer)->menu_type;

  if ( menu_type == POCKET_MENU )
    {
      _MI_setup_pocket ( (struct FIform_obj *) menu );
    }

  /*************** Let the PANEL_MENU be scaleable -- JAJ:09/25/91 ****
  else if ( menu_type == PANEL_MENU )
    {
	/ * If the menu is a PANEL, then set window * /
	/ * not to stretch horizontally.	    * /
	/ ** X11-5/2/90-Setting the hints.width_inc = 0 is BAD!! ** /

      XSizeHints hints;
      int width = ((struct FIform_obj *) menu )->xhi -
			((struct FIform_obj *) menu )->xlo;

      hints.flags = USSize | PMaxSize | PMinSize | USPosition;
      hints.x = ((struct FIform_obj *) menu )->xlo;
      hints.y = ((struct FIform_obj *) menu )->ylo;
      hints.width = width;
      hints.height = ((struct FIform_obj *) menu )->yhi -
			((struct FIform_obj *) menu )->ylo;
      hints.max_width = width;
      hints.max_height = ((struct FIform_obj *) menu )->max_ysize;
      hints.min_width = width;
      hints.min_height = ((struct FIform_obj *) menu )->min_ysize;

      XSetNormalHints ( _FI_display,
		((struct FIform_obj *) menu )->Xwindow, &hints );
    }
  ********************************************************************/

  FIf_display ( menu );

  if ( menu_type == POCKET_MENU )
    {
      _MI_process_pocket ( (struct FIform_obj *) menu );
    }

  return ( MI_SUCCESS );
}



int MI_pop_up_button (Menu menu,
                      int  gadget_label)
{
  struct FIgadget_obj *button;
  int menu_type = ( (struct menu_info_st *)
	    ((struct FIform_obj *) menu)->menu_user_pointer)->menu_type;

  button = _FI_g_get_id ( (struct FIform_obj *) menu, gadget_label );
  if ( ! button )
    {
      return ( FI_NO_SUCH_GADGET );
    }


  if (	( menu_type == PANEL_MENU )			||
	( menu_type == FI_TEAR_OFF_PANEL_MENU_TYPE )	 )
    {
      _MI_panel_set_button_off ( (struct FIgadget_obj *) button );
    }
  else
    {
      _FI_g_set_state ( button, 0.0 );
    }

  return ( MI_SUCCESS );
}



int MI_get_palette_vert_offset ( offset )
  int *offset;
{
  *offset = MI_palette_vert_offset;

  return ( MI_SUCCESS );
}



int MI_set_palette_vert_offset (int offset)
{
  MI_palette_vert_offset = offset;

  return ( MI_SUCCESS );
}

/***************************************************************
	 sml:09-24-93 new function to allow programmers to customize
		attributesof tear_off menus
****************************************************************/

void MI_set_tear_off_menu_modify_routine(void (*p_function)())
{
  extern void    (*MI_tear_off_modify_routine)();

    MI_tear_off_modify_routine = p_function;
}
