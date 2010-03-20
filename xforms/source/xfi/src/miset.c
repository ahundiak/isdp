#include "FImin.h"

#include "MIext.h"
#include "MIdef.h"

#include "XFIproto_pri.h"
#include "XFIproto_pub.h"

int MI_set_tear_off_notification_routine (int ( *tear_off_routine ) ())
{
  MI_tear_off_notify = tear_off_routine;

  return ( FI_SUCCESS );
}


int MI_get_tear_off_notification_routine (int ( **tear_off_routine ) ())
{
  *tear_off_routine = MI_tear_off_notify;

  return ( FI_SUCCESS );
}


int MI_set_menu_move_routine (int ( *menu_move_routine ) ())
{
  MI_menu_move_routine = menu_move_routine;

  return ( FI_SUCCESS );
}


int MI_get_menu_move_routine (int ( **menu_move_routine ) ())
{
  *menu_move_routine = MI_menu_move_routine;

  return ( FI_SUCCESS );
}


/* NOT USED BECAUSE form system doesn't support this **********

int MI_set_menu_adjust_on (void)
{
  MI_adjust_size = TRUE;

  return ( FI_SUCCESS );
}

int MI_set_menu_adjust_off (void)
{
  MI_adjust_size = FALSE;

  return ( FI_SUCCESS );
}
*************************************/


int MI_set_window_routine (int ( *window_routine ) ())
{
  MI_window_routine = window_routine;

  return ( FI_SUCCESS );
}


int MI_get_window_routine (int ( **window_routine ) ())
{
  *window_routine = MI_window_routine;

  return ( FI_SUCCESS );
}


int MI_enter (void)
{
  /* NOT USED *******
  MI_adjust_size = FALSE;
  *********************/

  MI_tear_off_notify = NULL;
  MI_menu_move_routine = NULL;
  MI_window_routine = NULL;

  return ( FI_SUCCESS );
}
