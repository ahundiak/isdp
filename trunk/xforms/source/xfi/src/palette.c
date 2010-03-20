/****************************************************/
/*													*/
/*			palette.c								*/
/*													*/
/****************************************************/

/*
  History
	25-JAN-93	sml		added MI_set_menu_button_creation routine()
						  to allow applications to manipulate different
						  buttons on menus.
*/


#include "FImin.h"

#include <stdio.h>
#include "MI.h"
#include "MIdef.h"


#include "XFIproto_pri.h"
#include "XFIproto_pub.h"

/* sml:01-25-93		Use this to creation mode-specific menus */
/*					Thanks to Mike Mathis and Paul Lebovitz  */

static int (*_MI_button_creation_routine)() = NULL;


int _MI_load_palette (char                 *menu_name,
                      struct FIgroup_obj  **palette)
{
  int status;
  int window_index;

  struct FIform_obj *menu;

	/* Load in menu without adding to the form list */

  status = _FI_f_new ( 0, menu_name, _FI_default_function, &menu );
  if ( status )
    {
      return ( status );
    }

	/* Assign the form group to the palette */

  *palette = menu->group;

	/* Store the remember bit into the effect part of a group */

  (*palette)->FIgadget.effect = menu->seq_label;

	/*** Store the menu name into the text part	***/
	/*** of the palette group.			***/

  _FI_s_rep ( ( char **) &(*palette)->FIgadget.text, menu_name );

  /*******************************************************/
  /* sml:03-31-94: NO TR                                 */
  /*  get menu's index and set slot to NULL              */
  /*******************************************************/

  window_index = _FI_Xwindow_to_index(menu->Xwindow);
/*
printf("_MI_load_palette %d: %d %d\n", window_index, FI_forms[window_index],
      _FI_index_to_Xwindow[window_index]);
*/
  if (window_index >= 0)
  {
      FI_forms[window_index] = 0;
      _FI_index_to_Xwindow[window_index] = None;
  }
/*
printf("  _MI_load_palette %d: %d %d\n", window_index, FI_forms[window_index],
      _FI_index_to_Xwindow[window_index]);
*/

	/*** Free memory associated with form and set to	***/
	/*** zero so the memory will not try to be freed	***/
	/*** when the menu is deleted.				***/

  _FI_s_free ( menu->name );

  /**********************************************************/
  /* sml:01-10-94:TR 249304932:Plug memory leak             */
  /*  this was never freed                                  */
  /**********************************************************/
  _FI_s_free ( menu->person ); 

  _FI_s_free ( menu->collapse_icon_file );

  if ( menu->num_desc )
    {
      int ii;

	/* Loop and free description */

      for ( ii = 0; ii < menu->num_desc; ii++ )
	{
		 _FI_s_free ( menu->description[ii]);
	}

      _FI_s_free ( ( char *) menu->description );
    }

  _FI_s_free ( (char *) menu );

  return ( MI_SUCCESS );
}


void MI_set_menu_button_creation_routine(p_function)
int (*p_function)();
{
    _MI_button_creation_routine = p_function;
}




/*  struct FIform_obj *form;	** Form to add this palette to */
/*  char *menu_name;		** Name of the palette */
/*  struct FIgroup_obj **palette;	** Pointer to the palette */

int _MI_create_palette (struct FIform_obj    *form,
                        char                 *menu_name,
                        struct FIgroup_obj  **palette)
{
  int	ii;
  int	status;
  float delta_x;
  float delta_y;


	/* Load menu */

  status = _MI_load_palette ( menu_name, palette );
  if ( status )
    {
      return ( status );
    }

	/* Store info into palette */

  if ( (struct menu_info_st *) form->menu_user_pointer )
    {
      (*palette)->FIgadget.label = ((struct menu_info_st *)
			 form->menu_user_pointer )->next_label++;
    }
  else
    {
      ( *palette )->FIgadget.label = 0;
    }

  (*palette)->FIgadget.type = FI_GROUP;
  (*palette)->FIgadget.form = form;

		/* Add to menu group */

  _FI_g_add_to_group ( (struct FIgadget_obj *)*palette, FI_FORM_GROUP, 1 );

	  /* Change button labels */

  for ( ii = 0; ii < (int)(*palette)->FIgroup.size; ii++ )
    {
      struct FIgadget_obj *gadget = ( *palette )->FIgroup.gadgets[ii];

      if ( ! gadget )
	{
	  continue;
	}

		/* Change label */

      if ( (struct menu_info_st *) form->menu_user_pointer )
	{
	  gadget->FIgadget.label = ((struct menu_info_st *)
			     form->menu_user_pointer )->next_label++;
	}
      else
	{
	  gadget->FIgadget.label = 0;
	}

		/* Change form pointer */

      gadget->FIgadget.form = form;

	     /* KLUDGE UNTIL BUILDER SET THE MENU_BUTTON */

      if ( gadget->FIgadget.type == FI_BUTTON )
	{
	   ((struct FIbtn_obj *) gadget)->FIbtn.menu_button = 1;
	}

			/****************************************************/
			/*													*/
			/*	sml:01-25-93									*/
			/*		with help from M. Mathis/P.Lebovitz			*/
			/*	Create buttons with application-supplied		*/
			/*	button-creation routine.  						*/
			/*													*/
 			/****************************************************/

    if (_MI_button_creation_routine)
	{
	  _MI_button_creation_routine(form, gadget->FIgadget.label);
	}	

    }


		/***********************************************/
		/*** Adjust the size of the new palette,     ***/
		/*** in case parent menu has been scaled.    ***/
		/*****************************  JAJ:09/24/91 ***/

  delta_x = (float) ( ( (float) ( form->xhi - form->xlo ) ) /
					( (float) form->orig_xsize ) );

  delta_y = (float) ( ( (float) ( form->yhi - form->ylo ) ) /
					( (float) form->orig_ysize ) );

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
     _FI_g_adjust_size ( (struct FIgadget_obj *)*palette, delta_x, delta_y );
    }

	/* Calculate the size of the group */

  _FI_grp_calculate_size ( form->group );

  return ( MI_SUCCESS );
}


void _MI_display_palette (struct FIgroup_obj  *palette)
{
  struct FIform_obj	*form = palette->FIgadget.form;
  struct FIbtn_obj	*button;


	/* If the palette is already displayed then return */

  if ( IT_IS_DISPLAYED ( palette ))
    {
      return;
    }


	/* Set the displayed flag to TRUE */

  palette->FIgadget.displayed = TRUE;


	/*** If any button is selected in a palette then	***/
	/***  display the palette associated with the button.	***/

  button = (struct FIbtn_obj *) palette->FIgroup.gadgets[0];

  if ( button )
    {
      struct btn_info_st	* temp_menu_user_pointer ;
      struct pal_info_st	* temp_pal_info ;
      struct FIbtn_obj	* active_button;
      struct FIgroup_obj	* btn_palette;

      temp_menu_user_pointer = (struct btn_info_st *)
				    button->FIgadget.menu_user_pointer ;

      if ( temp_menu_user_pointer )
	{
          temp_pal_info = temp_menu_user_pointer -> pal_info ;
	}
      else
	{
          temp_pal_info = 0;
	}

      if ( temp_pal_info )
	{
          active_button = temp_pal_info -> current_button;
	}
      else
	{
          active_button = 0;
	}

      if ( active_button )
	{
          temp_menu_user_pointer = (struct btn_info_st *)
			    active_button->FIgadget.menu_user_pointer;
	}
      else
	{
          temp_menu_user_pointer = 0;
	}

      if ( temp_menu_user_pointer )
	{
          btn_palette =  temp_menu_user_pointer -> palette_id ;
	}
      else
	{
          btn_palette =  0;
	}

		/*** The first time the palette is displayed,     ***/
		/***   current_button is 0, so active_button is 0 ***/

	/**************************************************************
	printf ( "_MI_display_palette : ...->current_button = 0x%x\n",
		   ( (struct pal_info_st *)
			( (struct btn_info_st *)
			  button->FIgadget.menu_user_pointer )
					->pal_info )->current_button );
	printf ( "                    : active_button = 0x%x\n\n",
						active_button );
	**************************************************************/


		/*** Set pass_on on so that the palette	***/
		/*** will display and get refreshed.	***/

      palette->FIgroup.dont_pass_on = FALSE;

		/*** If the palette is not suppost to	***/
		/*** remember the active button then	***/
		/*** set it to off.  Use effect for 	***/
		/*** the remember flag.			***/
     	        /*  ( -1 )- remember ( 0 )- don't remember */

      if ( ! palette->FIgadget.effect && active_button )
	{
	  _FI_g_set_state ( (struct FIgadget_obj *)active_button, 0.0 );
	}

		/* Display the palette */

      _FI_g_display ( (struct FIgadget_obj *) palette, form->Xwindow );

		/* If button has a palette and button 	*/
		/* is selected then display it.		*/

      if ( btn_palette  && active_button &&
	 ( active_button->FIgadget.value == 1.0 ))
	{
	  _MI_display_palette ( btn_palette );
	}
    }
}


void _MI_erase_palette (struct FIgroup_obj *palette)
{
  struct FIform_obj *form = palette->FIgadget.form;
  struct FIbtn_obj *button;
  int ii;

  Window window = form->Xwindow;

	/* Set the displayed flag to FALSE */

  palette->FIgadget.displayed = FALSE;

	/*****************************************/
	/* sml:09-15-93  NO TR                   */
	/* mark all the buttons as not displayed */
	/* code from Mike Mathis                 */
	/*****************************************/

  for (ii = 0; ii < (int) palette->FIgroup.size; ii++)
  {
    if (palette->FIgroup.gadgets[ii])
    {
       button = (struct FIbtn_obj  * ) palette->FIgroup.gadgets[ii];
       button->FIgadget.displayed = FALSE;
    }
  }

	/* Erase the palette */

  XSetForeground ( _FI_display, _FI_gc,
		 FI_translate_color ( form->Xscreen, form->bgcolor ));

	/**************************************************/
	/*** Re-Calculate the size of the palette	***/
	/***************************** JAJ:09/24/91 *******/
  _FI_grp_calculate_size ( palette );

  XFillRectangle ( _FI_display, window, _FI_gc,
		(int) palette->FIgadget.xlo,
		(int) palette->FIgadget.ylo,
        (int) ( palette->FIgadget.xhi - palette->FIgadget.xlo + 1 ),
        (int) ( palette->FIgadget.yhi - palette->FIgadget.ylo + 1 ));

      /* sml:01-18-94:TR 249400065                         */
      /*  Add check before flushing.  Don't flush if       */
      /*  initially displaying gadget.  OK to flush if     */
      /*  updating      */
  if (!_FI_dont_flush)
    XFlush ( _FI_display );

	/* If this palette has a button selected then	*/
	/* erase the palette associated with it.	*/

  button = (struct FIbtn_obj *) palette->FIgroup.gadgets[0];

  if ( button )
    {
      struct btn_info_st *btn_info;
      struct pal_info_st *pal_info;
      struct FIbtn_obj *active_button;

      btn_info = (struct btn_info_st *)
			 button->FIgadget.menu_user_pointer;
      if ( btn_info )
	{
	  pal_info = btn_info->pal_info;
	}
      else
	{
	  pal_info = 0;
	}

      if ( pal_info )
	{
	  active_button = (struct FIbtn_obj *) pal_info->current_button;
	}
      else
	{
	  active_button = 0;
	}

      if ( active_button )
	{
	  struct btn_info_st *active_btn_info;
	  struct FIgroup_obj *palette_id;

	  active_btn_info = (struct btn_info_st *)
			 active_button->FIgadget.menu_user_pointer;

	  if ( active_btn_info )
	    {
	      palette_id = active_btn_info->palette_id;
	    }
	  else
	    {
	      palette_id = 0;
	    }

	  if ( palette_id )
	    {
	      _MI_erase_palette ( palette_id );
	    }
	}
    }

	/*** Set pass_on off so that the palette	***/
	/*** will not get displayed by the form.	***/

  palette->FIgroup.dont_pass_on = TRUE;
}
