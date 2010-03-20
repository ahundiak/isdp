/*****************************************************************/
/* MS.h -						 	 */
/*	This is an X/Forms ( XFORMSDP SN01252 ) header file.	 */
/*****************************************************************/
/* Copyright 1992 Intergraph Corporation			 */
/* All Rights Reserved, Including this Release Note, the Product */
/* it Describes, its File Formats, and Visual Displays		 */
/*****************************************************************/


#ifndef MS_INCLUDED
#define MS_INCLUDED	1

/* Needed for MS_swap_menu */

#ifndef menu_types
#define menu_types	1

#define BAR_MENU	0
#define PANEL_MENU	1
#define POCKET_MENU	2

#endif

/* Return codes */

#define MS_SUCCESS	0
#define MS_READ_ERROR	1
#define MS_WRITE_ERROR	2

#endif
