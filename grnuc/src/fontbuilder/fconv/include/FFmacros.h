/*
$Log: FFmacros.h,v $
Revision 1.1.1.1  2001/12/17 22:39:12  hans
Initial import to CVS

 * Revision 340.0  1997/05/27  23:15:51  root
 * COMMENT : Initial checkin to 3.4.0 RCS from 3.3.0 src
 *
 * Revision 330.0  1996/01/11  21:30:06  root
 * COMMENT : Initial checkin to 3.3.0 RCS from 3.2.0 src
 *
 * Revision 320.0  1994/12/12  17:59:05  root
 * COMMENT : Initial checkin to 3.2 RCS from 3.1 src
 *
 * Revision 240.0  1992/12/06  23:52:20  tim
 * COMMENT : Initial checkin to 2.4 RCS
 *
 * Revision 220.0  1992/08/29  06:30:36  root
 * COMMENT : Corresponds to Rel201.2 in 2.0.1 RCS
 *
 * Revision 201.2  1992/07/13  20:42:34  tim
 * COMMENT : added Log variable
 *
*/

#ifndef FFmacros_include
#define FFmacros_include

#define KN_BUFF_LEN        (100)

#define FF_MESSAGE( str ) Display_message(1, 1, str)
#define FF_PROMPT( str )  Display_message(3, 2, str)
#define FF_STATUS( str )  Display_message(2, 1, str)

#define LEFT_UP      ((UP << 2) + LEFT_BUTTON)
#define MIDDLE_UP    ((UP << 2) + MIDDLE_BUTTON)
#define RIGHT_UP     ((UP << 2) + RIGHT_BUTTON)
#define LEFT_DOWN    ((DOWN << 2) + LEFT_BUTTON)
#define MIDDLE_DOWN  ((DOWN << 2) + MIDDLE_BUTTON)
#define RIGHT_DOWN   ((DOWN << 2) + RIGHT_BUTTON)
#define LEFT_CLICK   ((DOUBLE_CLICK << 2) + LEFT_BUTTON)
#define MIDDLE_CLICK ((DOUBLE_CLICK << 2) + MIDDLE_BUTTON)
#define RIGHT_CLICK  ((DOUBLE_CLICK << 2) + RIGHT_BUTTON)
#define LEFT_RESET   ((DOUBLE_CLICK << 2) + LEFT_BUTTON)
#define MIDDLE_RESET ((DOUBLE_CLICK << 2) + MIDDLE_BUTTON)
#define RIGHT_RESET  ((DOUBLE_CLICK << 2) + RIGHT_BUTTON)

#define FF_GET_BUTTON_DATA(pw_id, w_id, mask, xo, yo, but, tran, time) \
	mask  = w_id = but = tran = time = 0; \
FF_GET_BUTTON_DATA_again: \
	Enable_events( BUTTON_EVENT ); \
	Wait_for_events( KEYIN_EVENT | BUTTON_EVENT, &mask ); \
	if( BUTTON_EVENT & mask ) { \
		Get_button_data( &w_id, &xo, &yo, &but, &tran, &time ); \
		switch ((tran << 2) + but) { \
			case LEFT_UP : \
			case MIDDLE_UP : \
			case RIGHT_UP : \
			case LEFT_DOWN : \
			case MIDDLE_DOWN : \
			case RIGHT_DOWN : \
			case LEFT_CLICK : \
			case MIDDLE_CLICK : \
			case RIGHT_CLICK : \
			case LEFT_RESET : \
			case MIDDLE_RESET : \
			case RIGHT_RESET : \
				if( pw_id == w_id ) { \
					but =  tran << 2) + but; \
					break; \
					} \
			default : \
				goto FF_GET_BUTTON_DATA_again; \
			} \
		} \
	else \
		goto FF_GET_BUTTON_DATA_again;

#endif /* FFmacros_include */
