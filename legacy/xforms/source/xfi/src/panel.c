#include "FImin.h"

#include <stdio.h>
#include "MI.h"
#include "MIdef.h"
#include "MIext.h"

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"

extern int MI_palette_vert_offset;


void _MI_panel_set_button_off (struct FIgadget_obj *button)
{
  struct FIgroup_obj *palette_id = ((struct btn_info_st *)
		     button->FIgadget.menu_user_pointer )->palette_id;

	/* Erase the button's palette if it exists */

  if ( palette_id )
    {
      _MI_erase_palette ( palette_id );
    }

	/* Pop up the button */

  _FI_g_set_state ( button, UP_STATE );
}



int _MI_panel_notify_routine (int                 form_label,
                              int                 gadget_label,
                              double              value,
                              struct FIform_obj  *menu)
{
  struct FIgadget_obj	*gadget;
  struct FIbtn_obj	*button;
  struct FIbtn_obj	*last_button;
  struct pal_info_st	*curr_pal_info;
  float			 delta_x;
  int			 palette_x = 3;


  gadget = _FI_g_get_id ( menu, gadget_label );

	/* If something was selected on the panel	*/
	/* that was not a button, then return.		*/

  if (( ! gadget ) || ( gadget->FIgadget.type != FI_BUTTON ))
    {
      return ( FI_SUCCESS );	/* dmb:03/11/91:Examine this */
    }

  button = (struct FIbtn_obj *) gadget;

	/* Press the button in because form software will not */

  _FI_g_set_state ( (struct FIgadget_obj *)button, DOWN_STATE );

  curr_pal_info = ((struct btn_info_st *)
			 button->FIgadget.menu_user_pointer )->pal_info;


  /********************************************************************
  printf ("panel_notify: curr_pal_info = 0x%x\n\n", curr_pal_info );
  *********************************************************************/


	/* Check to see if another button is currently selected */
	/* on the same palette.					*/

  last_button = curr_pal_info->current_button;

  if (  last_button   && ( last_button != button ))
    {
      _MI_panel_set_button_off ( (struct FIgadget_obj *) last_button );
    }

	  /* Display the button's palette if it exists */

  if (  button->FIbtn.palette   &&   button->FIbtn.palette[0] )
    {
      struct FIgroup_obj *palette = ((struct btn_info_st *)
		 button->FIgadget.menu_user_pointer )->palette_id;

	/* If not loaded then load the palette from disk */

      if ( ! palette )
	{
	  struct pal_info_st *pal_info;

	  int status;
	  int ypos;

	        /* Load in the palette */

	  status = _MI_create_palette ( menu, button->FIbtn.palette,
						 &palette );
	  if ( ! status )
	    {
			/* Calculate the size of the palette */

	      _FI_grp_calculate_size ( palette );

			/* Assign the palette id */

	      ((struct btn_info_st *) button->
		     FIgadget.menu_user_pointer )->palette_id = palette;

			/* Set the location of the palette */

	      ypos = button->FIgadget.group->FIgadget.yhi +
		   MI_palette_vert_offset + 1;	/*** JAJ:10/26/90 ***/

		/**************************************************/
		/*** Adjust the x-location of the new palette,  ***/
		/*** in case parent menu has been scaled.    	***/
		/*****************************  JAJ:09/24/91 ******/

	      delta_x = (float) ( ( (float) (menu->xhi - menu->xlo) ) /
					( (float) menu->orig_xsize ) );

	      palette_x = (int) ( palette_x * delta_x );

	      FIg_set_location ( (Form) menu, palette->FIgadget.label,
						palette_x, ypos );


	           /*** Create a pal_info structure ***/
	           /*** for the palette of buttons ***/

	      pal_info = (struct pal_info_st *) calloc ( 1,
					 sizeof (struct pal_info_st ));

		/* Set each button in group with a btn_info structure */

	      _FI_grp_pass_on_id_int ( (struct FIgadget_obj *) palette,
			_MI_btn_set_user_pointer, (int)pal_info, 0 );
	    }
        else
          {
            return(status);
          }
	}

     /* Display the palette */

      _MI_display_palette ( palette );
    }

  /* Set the current_button in the palette of the selected button */

  curr_pal_info->current_button = button;


	  /* Call application notify routine */

  if ( form_label == TEAR_OFF_PANEL_MENU )
    {
	  /* Call tear-off routine if it exists */

      if ( MI_tear_off_notify )
	{
	  MI_tear_off_notify ( form_label, gadget_label, value, menu );
	}
    }
  else if ( menu->cmd_oid )
    {
      ( ( int (*) () ) menu->cmd_oid ) ( form_label, gadget_label,
					value, menu );
    }

	/* Process data associated with the button.	 */
	/* Call this last in case the menu is deleted.	 */

  _FI_g_common ( (struct FIgadget_obj *)button );

  return ( FI_SUCCESS );	/* dmb:03/11/91:Examine this */

} /*** _MI_panel_notify_routine () ***/
