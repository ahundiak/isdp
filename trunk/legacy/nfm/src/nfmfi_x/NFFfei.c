
/* machine.h included to take care of platform variencies MVR 23 Dec 1993 */
#include "machine.h"

#include "NFF.h"
#include "NFFjournal.h"

/*  Global NFF structure  */

extern struct NFFglobal_st NFFglobal;

extern int JNL_init_journal (char *, int);
extern int JNL_init_playback (char *);
extern int JNL_record_new_window (int);
extern int JNL_echo_event (int, int *);
extern int JNL_process_info_event (int);
extern int JNL_process_del_info_event (void);
extern int JNL_record_info_event (int, int, char *);
extern int JNL_record_event (int);
extern int JNL_close_jnl (void);
extern int JNL_close_jnl_pbk (void);
extern int JNL_close_echo (void);
extern int JNL_record_input (int, char *);
extern int JNL_echo_input (int, char *);
extern int JNL_adjust_echo (void);
extern int JNL_adjust_echo_button (void);
extern int JNL_adjust_echo_refresh_button (void);
extern int JNL_adjust_echo_collapse_button (void);
extern int JNL_adjust_delete_button (void);
extern int JNL_wait_for_next (int, int *);
extern int JNL_inq_events (int *);
extern int JNL_inq_button_data (int *, int *, int *, int *, int *, int *);
extern int JNL_get_button_data (int *, int *, int *, int *, int *, int *);
extern int JNL_process_slow_echo (void);
extern int JNL_get_refresh_area_data (int *, int *, int *, int *, int *, int *,
                                      int *, int *, int *, int *, int *);
extern int JNL_inq_refresh_area_data (int *, int *, int *, int *, int *, int *,
                                      int *, int *, int *, int *, int *);
extern int JNL_get_collapse_data (int *, int *);
extern int JNL_inq_collapse_data (int *, int *);
extern int JNL_get_delete_data (int *);
extern int JNL_inq_delete_data (int *);
extern int JNL_inq_user_data (int *);
extern int JNL_get_user_data (int *);
extern int JNL_inq_win_user_icon_data (int *, int *);
extern int JNL_get_win_user_icon_data (int *, int *);
extern int JNL_start_timer (int, int, int *);
extern int JNL_stop_timer (int);
extern int JNL_get_timer_data (int *);
extern int JNL_echo_timer_data (int *);
extern int JNL_record_timer_data (int *);
extern int JNL_set_keyboard_buffer (char *, int);
extern int JNL_get_keyboard_data (int *);
extern int JNL_inq_keyboard_data (int *);
extern int JNL_inq_keyboard_buffer (char **, int *);
extern int JNL_set_timer_playback (int);
extern int JNL_playback (void);
extern int JNL_journal (void);

int FEI_get_refresh_area_data
(window, vs, xlo, ylo, xhi, yhi, axlo, aylo, axhi, ayhi, opmask)
  int    *window;
  int    *vs;
  int    *xlo;
  int    *ylo;
  int    *xhi;
  int    *yhi;
  int    *axlo;
  int    *aylo;
  int    *axhi;
  int    *ayhi;
  int    *opmask;
  {
#ifndef XWINDOWS
    JNL_get_refresh_area_data
        (window, vs, xlo, ylo, xhi, yhi, axlo, aylo, axhi, ayhi, opmask);

    if (JNL_playback ())
        *opmask |= WN_WAS_COVERED;
#endif
    return (FI_SUCCESS);
  }


int FEI_inq_button_data (window, x, y, button, trans, ttag)
  int    *window;
  int    *x;
  int    *y;
  int    *button;
  int    *trans;
  int    *ttag;
  {

#ifndef XWINDOWS
    int     label;
    Form    form;

    JNL_inq_button_data (window, x, y, button, trans, ttag);
    
    if (JNL_playback ())
      {
        FI_get_form (*window, &form);
         
        if (form)
          {
            /*  The button is on the form  */

            if (FIf_find_gadget
                (form, FI_FORM_GROUP, *x, *y, &label))
              {
                /*  Set the window to -1
                    so that the form will not claim this point */
    
                *window = -1;
              }
          }
      }
#endif
    return (FI_SUCCESS);
  }


int _NFFget_button_data (w, x, y, button, transition, timetag)

  int *w;
  int *x, *y;
  int *button;
  int *transition;
  int *timetag;
  {
    int        status = FI_SUCCESS;
    static     char *fname = "_NFFget_button_data";

    _NFIdebug(( fname, "Entering ...\n" ));
#ifndef XWINDOWS
    status = JNL_get_button_data (w, x, y, button, transition, timetag);
#endif
    _NFIdebug(( fname, "transition <%d>\n", *transition ));
    NFFglobal.button_transition = *transition;

    return (status);
  }

int _NFFinq_button_data (w, x, y, button, transition, timetag)

  int *w;
  int *x, *y;
  int *button;
  int *transition;
  int *timetag;
  {
    int        status = FI_SUCCESS;
    static     char *fname = "_NFFinq_button_data";

    _NFIdebug(( fname, "Entering ...\n" ));
#ifndef XWINDOWS
    status = JNL_inq_button_data (w, x, y, button, transition, timetag);
#endif
    _NFIdebug(( fname, "transition <%d>\n", *transition ));
    NFFglobal.button_transition = *transition;

    return (status);
  }


int FEI_get_keyboard_data (character, count, font_type)
  char   *character;
  int    *count;
  int    font_type;
  {
    int  i;

    /*  Just to shut up the compiler  */

    font_type = font_type;
#ifndef XWINDOWS
    JNL_get_keyboard_data (count);
#endif
    for (i = 0; i < *count; ++i)
      {
        switch (NFFglobal.keyboard_buffer[i])
          {
            case C_UP:
                NFFglobal.keyboard_buffer[i] = FI_UP;
                break;

            case C_DOWN:
                NFFglobal.keyboard_buffer[i] = FI_DOWN;
                break;

            case C_LEFT:
                NFFglobal.keyboard_buffer[i] = 12;
                break;

            case C_RIGHT:
                NFFglobal.keyboard_buffer[i] = 18;
                break;

            case ENTER:
                NFFglobal.keyboard_buffer[i] = 13;
                break;

            case KEYPAD_0:
                NFFglobal.keyboard_buffer[i] = '0';
                break;

            case KEYPAD_1:
                NFFglobal.keyboard_buffer[i] = '1';
                break;

            case KEYPAD_2:
                NFFglobal.keyboard_buffer[i] = '2';
                break;

            case KEYPAD_3:
                NFFglobal.keyboard_buffer[i] = '3';
                break;

            case KEYPAD_4:
                NFFglobal.keyboard_buffer[i] = '4';
                break;

            case KEYPAD_5:
                NFFglobal.keyboard_buffer[i] = '5';
                break;

            case KEYPAD_6:
                NFFglobal.keyboard_buffer[i] = '6';
                break;

            case KEYPAD_7:
                NFFglobal.keyboard_buffer[i] = '7';
                break;

            case KEYPAD_8:
                NFFglobal.keyboard_buffer[i] = '8';
                break;

            case KEYPAD_9:
                NFFglobal.keyboard_buffer[i] = '9';
                break;

            case KEYPAD_PLUS:
                NFFglobal.keyboard_buffer[i] = '+';
                break;

            case KEYPAD_MINUS:
                NFFglobal.keyboard_buffer[i] = '-';
                break;

            case KEYPAD_DOT:
                NFFglobal.keyboard_buffer[i] = '.';
                break;
          }

        character[i] = NFFglobal.keyboard_buffer[i];
      }

    return (FI_SUCCESS);
  }


int FEI_set_window_attr (window)
  int    window;
  {
#ifndef XWINDOWS
    JNL_record_new_window (window);
#endif
    return (FI_SUCCESS);
  }


int FEI_enter ()
  {
#ifndef XWINDOWS
    FI_modify_env (FI_GET_KEYBOARD_DATA,          FEI_get_keyboard_data );
    FI_modify_env (FI_SET_WINDOW_ATTR,            FEI_set_window_attr);
    
    FI_modify_graphic_env (FI_INQ_BUTTON_DATA,    FEI_inq_button_data );
    FI_modify_graphic_env (FI_GET_BUTTON_DATA,    _NFFget_button_data );

    FI_modify_graphic_env (FI_INQ_COLLAPSE_DATA,  JNL_inq_collapse_data );
    FI_modify_graphic_env (FI_GET_COLLAPSE_DATA,  JNL_get_collapse_data );

    FI_modify_graphic_env (FI_INQ_DELETE_DATA,    JNL_inq_delete_data );
    FI_modify_graphic_env (FI_GET_DELETE_DATA,    JNL_get_delete_data );

    FI_modify_graphic_env (FI_INQ_EVENTS,         JNL_inq_events );
    FI_modify_graphic_env (FI_WAIT_FOR_NEXT,      JNL_wait_for_next );

    FI_modify_graphic_env (FI_INQ_REFRESH_AREA_DATA,
                                                  JNL_inq_refresh_area_data );
    FI_modify_graphic_env (FI_GET_REFRESH_AREA_DATA,
                                                  FEI_get_refresh_area_data );
#endif
    return (FI_SUCCESS);           
  }
