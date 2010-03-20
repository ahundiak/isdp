#include "FImin.h"
#include "FEI.h"


#include "XFIproto_pri.h"
#include "XFIproto_pub.h"




int FI_modify_env (int    function,
                   int  (*func_ptr)())
{
   switch (function)
   {
   case FI_TRANSLATE_COLOR:
	  FI_translate_color = (unsigned long (*) ()) func_ptr;
	  break;

   case FI_FIND_FORM:
	  FI_find_form = func_ptr;
	  break;

   case FI_SET_WINDOW_ATTR:
	  FI_set_window_attr = func_ptr;
	  break;

   case FI_CALC_TEXT:
	  FI_calc_text = func_ptr;
	  break;

   case FI_DRAW_TEXT:
	  FI_draw_text = func_ptr;
	  break;

   case FI_FIND_SYMBOL_PATH_AND_ID:
	  FI_find_symbol_path_and_id = func_ptr;
	  break;

   case FI_FIND_FONT_ID:
	  FI_find_font_id = func_ptr;
	  break;

   case FI_PROCESS_DATA:
	  FI_process_data = func_ptr;
	  break;

   case FI_COLORMAP_NOTIFY:
	  FI_colormap_notify = func_ptr;
	  break;

   case FI_ACTIVATE_HELP:
	  FI_activate_help = func_ptr;
	  break;

   case FI_MAP_CHARACTER:
	  FI_map_character = func_ptr;
	  break;

   case FI_STRLEN:
	  FI_strlen = func_ptr;
	  break;

   case FI_MOVE_INDEX:
	  FI_move_index = func_ptr;
	  break;

   case FI_GET_KEYBOARD_DATA:
          FI_get_keyboard_data = func_ptr;

   default:
	  return (FI_NO_SUCH_ENV_FUNCTION);

   }

   return (FI_SUCCESS);
}


int FI_get_env (int     function,
                int  (**func_ptr)())
{
   switch (function)
   {
   case FI_TRANSLATE_COLOR:
	  *func_ptr = (int (*) ()) FI_translate_color;
	  break;

   case FI_FIND_FORM:
	  *func_ptr = FI_find_form;
	  break;

   case FI_SET_WINDOW_ATTR:
	  *func_ptr = FI_set_window_attr;
	  break;

   case FI_CALC_TEXT:
	  *func_ptr = FI_calc_text;
	  break;

   case FI_DRAW_TEXT:
	  *func_ptr = FI_draw_text;
	  break;

   case FI_FIND_SYMBOL_PATH_AND_ID:
	  *func_ptr = FI_find_symbol_path_and_id;
	  break;

   case FI_FIND_FONT_ID:
	  *func_ptr = FI_find_font_id;
	  break;

   case FI_PROCESS_DATA:
	  *func_ptr = FI_process_data;
	  break;

   case FI_COLORMAP_NOTIFY:
	  *func_ptr = FI_colormap_notify;
	  break;

   case FI_ACTIVATE_HELP:
	  *func_ptr = FI_activate_help;
	  break;

   case FI_MAP_CHARACTER:
	  *func_ptr = FI_map_character;
	  break;

   case FI_STRLEN:
	  *func_ptr = FI_strlen;
	  break;

   case FI_MOVE_INDEX:
	  *func_ptr = FI_move_index;
	  break;

   case FI_GET_KEYBOARD_DATA:
	  *func_ptr = FI_get_keyboard_data;

   default:
	  return (FI_NO_SUCH_ENV_FUNCTION);

   }
   return (FI_SUCCESS);
}

int FI_set_graphic_env (int    function,
                        int  (*func_ptr)())
{
   switch (function)
   {
   case FI_NEXT_EVENT:
	  FI_next_event = func_ptr;
	  break;

   case FI_CREATE_WINDOW:
          /* dmb:10/02/92: */
/*          FI_create_window = (int (*) ())func_ptr;  dmb:10/02/92 Original */
          FI_create_window = (Window (*) ())func_ptr; /* dmb:10/02/92 For ANSI */
          break;

   case FI_MASK_EVENT:
          FI_mask_event = func_ptr;
          break;

   case FI_CHECK_MASK_EVENT:
          FI_check_mask_event = func_ptr;
          break;

   case FI_IF_EVENT:
          FI_if_event = func_ptr;
          break;

   case FI_PUT_BACK_EVENT:
          FI_put_back_event = func_ptr;
          break;

   case FI_SEND_EVENT:
          FI_send_event = func_ptr;
          break;

   case FI_GRAB_POINTER:
          FI_grab_pointer = func_ptr;
          break;

   case FI_UNGRAB_POINTER:
          FI_ungrab_pointer = func_ptr;
          break;

   case FI_CHECK_IF_EVENT:
          FI_check_if_event = func_ptr;
          break;

   /* sml:TR 249305874	add override for XWindowEvent */
   case FI_WINDOW_EVENT:
          FI_window_event = func_ptr;
          break;

   /* sml:TR 249305874	add override for XCheckWindowEvent */
   case FI_CHECK_WINDOW_EVENT:
          FI_check_window_event = func_ptr;
          break;

   case FI_MAP_RAISED:
          FI_map_raised = func_ptr;
          break;

   case FI_MAP_WINDOW:
          FI_map_window = func_ptr;
          break;

   case FI_CONFIGURE_WINDOW:
          FI_configure_window = func_ptr;
          break;

   case FI_DESTROY_WINDOW:
          FI_destroy_window = func_ptr;
          break;

   case FI_ICONIFY_WINDOW:
          FI_iconify_window = func_ptr;
          break;

   case FI_QUERY_POINTER:
          FI_query_pointer = func_ptr;
          break;

   case FI_UNMAP_WINDOW:
          FI_unmap_window = func_ptr;
          break;

   case FI_WITHDRAW_WINDOW:
          FI_withdraw_window = func_ptr;
          break;

   default:
	  return (FI_NO_SUCH_ENV_FUNCTION);

   }

   return (FI_SUCCESS);
}

int FI_get_graphic_env (int     function,
                        int  (**func_ptr)())
{
   switch (function)
   {
   case FI_NEXT_EVENT:
	  *func_ptr = FI_next_event;
	  break;

   case FI_CREATE_WINDOW:
          *func_ptr = (int (*) ()) FI_create_window;
          break;

   case FI_MASK_EVENT:
          *func_ptr = FI_mask_event;
          break;

   case FI_CHECK_MASK_EVENT:
          *func_ptr = FI_check_mask_event;
          break;

   case FI_IF_EVENT:
          *func_ptr = FI_if_event;
          break;

   case FI_PUT_BACK_EVENT:
          *func_ptr = FI_put_back_event;
          break;

   case FI_SEND_EVENT:
          *func_ptr = FI_send_event;
          break;

   case FI_GRAB_POINTER:
          *func_ptr = FI_grab_pointer;
          break;

   case FI_UNGRAB_POINTER:
          *func_ptr = FI_ungrab_pointer;
          break;

   case FI_CHECK_IF_EVENT:
          *func_ptr = FI_check_if_event;
          break;

   /* sml:TR 249305874	add override for XWindowEvent */
   case FI_WINDOW_EVENT:
          *func_ptr = FI_window_event;
          break;

   /* sml:TR 249305874	add override for XCheckWindowEvent */
   case FI_CHECK_WINDOW_EVENT:
          *func_ptr = FI_check_window_event;
          break;

   case FI_MAP_RAISED:
          *func_ptr = FI_map_raised;
          break;

   case FI_MAP_WINDOW:
          *func_ptr = FI_map_window;
          break;

   case FI_CONFIGURE_WINDOW:
          *func_ptr = FI_configure_window;
          break;

   case FI_DESTROY_WINDOW:
          *func_ptr = FI_destroy_window;
          break;

   case FI_ICONIFY_WINDOW:
          *func_ptr = FI_iconify_window;
          break;

   case FI_QUERY_POINTER:
          *func_ptr = FI_query_pointer;
          break;

   case FI_UNMAP_WINDOW:
          *func_ptr = FI_unmap_window;
          break;

   case FI_WITHDRAW_WINDOW:
          *func_ptr = FI_withdraw_window;
          break;

   default:
	  return (FI_NO_SUCH_ENV_FUNCTION);

   }
   return (FI_SUCCESS);
}

