/*****************************************************************/
/* MI.h -						 	 */
/*	This is an X/Forms ( XFORMSDP SN01252 ) header file.	 */
/*****************************************************************/
/* Copyright 1992 Intergraph Corporation			 */
/* All Rights Reserved, Including this Release Note, the Product */
/* it Describes, its File Formats, and Visual Displays		 */
/*****************************************************************/


#ifndef MI_INCLUDED
#define MI_INCLUDED	1


typedef char *   Menu;


#ifndef menu_types
#define menu_types 1

#define BAR_MENU	0
#define PANEL_MENU	1
#define POCKET_MENU	2

#endif


#define TEAR_OFF_BAR_MENU	  3
#define TEAR_OFF_PANEL_MENU	  4

#define MI_SUCCESS		  0

#define MI_TEAR_OFF_ICON	101
#define MI_BAR_MOVE_ICON	102
#define MI_PANEL_MOVE_ICON	103

#define MI_LEFT			  1
#define MI_RIGHT		  2
#define MI_TOP			  3
#define MI_BOTTOM		  4

#endif
