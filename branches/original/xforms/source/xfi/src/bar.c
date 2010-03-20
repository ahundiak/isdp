#include "FImin.h"

#include "MIext.h"
#include <stdio.h>
#include "MI.h"
#include "MIdef.h"

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"

int _MI_bar_notify_routine (int                 form_label,
                            int                 gadget_label,
                            double              value,
                            struct FIform_obj  *menu)
{
  struct FIgadget_obj	* gadget;
  struct FIbtn_obj	* button;
  struct FIgroup_obj	* group = menu->group;
  int ii;


  gadget = _FI_g_get_id ( menu, gadget_label );

  if (  ! gadget   || ( gadget->FIgadget.type != FI_BUTTON ))
    {
      return ( FI_SUCCESS );
    }

	/***********************************************************/
	/*** Press the button in because form software will not. ***/
	/***********************************************************/

  _FI_g_set_state ( gadget, DOWN_STATE );

	/**************************************************/
	/*** If any other button on the bar menu 	***/
	/*** is selected then pop it up.		***/
	/**************************************************/

  for ( ii = 0; ii < (int)group->FIgroup.size; ii++ )
    {
      button = (struct FIbtn_obj *) group->FIgroup.gadgets[ii];

      if (  ! button   || ( button->FIgadget.type != FI_BUTTON ))
	{
	  continue;
	}

      if ( ( button != (struct FIbtn_obj *) gadget )	&&
	   ( button->FIgadget.value == DOWN_STATE )	 )
	{
	  _FI_g_set_state ( (struct FIgadget_obj *)button, UP_STATE );
	  break;
	}
    }

	/***************************************/
	/*** Call application notify routine ***/
	/***************************************/

  if ( form_label == TEAR_OFF_BAR_MENU )
    {
	/**************************************/
	/* Call tear-off routine if it exists */
	/**************************************/

      if ( MI_tear_off_notify )
	{
	  MI_tear_off_notify ( form_label, gadget_label, value, menu );
	}
    }
  else if ( menu->cmd_oid )
    {
      ( ( int (*)() ) menu->cmd_oid ) ( form_label, gadget_label,
						 value, menu );
    }

	/************************************************/
	/* Process data associated with the button	*/
	/* Call this last in case the menu is deleted	*/
	/************************************************/

  _FI_g_common ( gadget );

  return ( FI_SUCCESS );
}
