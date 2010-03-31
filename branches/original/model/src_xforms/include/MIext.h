#ifndef MIext_included
#define MIext_included

#include "FIform.h"
#include "FIbtn.h"

extern int    (*MI_tear_off_notify)();
extern int    (*MI_menu_move_routine)();
extern int    (*MI_window_routine)();

extern int    _MI_bar_notify_routine();
extern int    _MI_panel_notify_routine();
extern int    _MI_btn_set_menu_button();
extern int    _MI_btn_set_user_pointer();
extern int    _MI_process_icon();
/*
extern void    (*_MI_tear_off_modify_routine)();
*/
extern struct  FIbtn_obj * _MI_find_first_button();
/* extern struct  FIbtn_obj * _MI_last_button; dmb:03/07/91:exp */

#endif
