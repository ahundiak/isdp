#include "FImin.h"

#include <stdio.h>
#include "FIgroup.h"
#include "MI.h"

#include "MIdef.h"
#include "MSext.h"

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"

int _FI_f_delete (struct FIform_obj *form)
{
  int slot, xx;
  int window_index;

	/*** X11-6/22/90-This removes it from the form list,	***/
	/***  so in the event code it will never find the form	***/
	/***  and can't call this routine a second time. If	***/
	/***  another client destroys the window, then this	***/
	/***  code will be called to clean up.			***/

  window_index = _FI_Xwindow_to_index ( form ->Xwindow );

  if ( window_index >= 0 )
    {
      FI_forms [ window_index ] = 0;
      /* sml:04-04-94:NO TR     Xerox problem             */
      /*  remove corresponding window for this form       */
      _FI_index_to_Xwindow [ window_index ] = None;
    }
  /***************************************************
    else
    {
      printf ("FORMS error: _FI_f_delete\n");
    }
  ***************************************************/

  form->Xwindow = None;	/* Prevent gadget erasing */

  if ( form->window_event_routine )
    {
     form->window_event_routine ( form->form_label, FI_DELETE,
						 (Form) form );
    }


  /*** Pass false because the group doesn't need	 ***/
  /*** to be re-calculated				 ***/

  _FI_grp_pass_on_id_int_always ( (struct FIgadget_obj *) form->group,
					_FI_g_delete, FALSE, 0 );

  /* delete form's group */

  /* NOTE Do not call _FI_grp_delete */

  if ( form->group->FIgroup.gadgets )
    {
      _FI_s_free ( ( char *) form->group->FIgroup.gadgets );
    }

  _FI_s_free ( ( char *) form->group );

  /* free memory associated with form */

  _FI_s_free ( form->name );

  /*** JAJ:03/15/91 ***/
  _FI_s_free ( form->person );
  /*** form->person = 0;  ***/

  _FI_s_free ( form->collapse_icon_file );

  if ( form->num_desc )
    {
     /* Loop and free description */

      for ( xx = 0; xx < form->num_desc; xx++ )
         {
	   _FI_s_free ( form->description[xx]);
         }

      _FI_s_free ( ( char *) form->description );
    }

  /* free memory associated with the child node */

  if ( form->child_node )
    {
      if ( form->child_node->childForm )
           {
		 _FI_s_free ( ( char *) form->child_node->childForm );
           }

      _FI_s_free ( ( char *) ((struct FIform_obj *) form)->child_node );
    }

  if ( form->Xgc )
    {
      XFreeGC ( _FI_display, form->Xgc );
    }

  if ( form->Xgc_text )		/*** JAJ:02/14/92 ***/
    {
      XFreeGC ( _FI_display, form->Xgc_text );
    }

  /* Find the slot where the form is */

  slot = _FI_grp_get_slot ( _FI_form_list, (struct FIgadget_obj *)form );

  /* Free this location */

  if ( slot > -1 )
    {
      _FI_form_list->FIgroup.gadgets[slot]= 0;
    }

			/*** JAJ:01/20/92 ***/
  if ( form->menu_user_pointer )
    {
      free ( form->menu_user_pointer );
    }

  _FI_s_free ( ( char *) form );

  return ( FI_SUCCESS );
}
