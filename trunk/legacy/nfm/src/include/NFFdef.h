#ifndef NFFDEF_H
#define NFFDEF_H

#ifndef TRUE
#define TRUE  1
#endif
#ifndef FALSE
#define FALSE 0
#endif

/*  Global NFMR structure  */

extern struct NFMRglobal_st NFMRglobal;

/*  Master Help file  */

#define NFF_HELP_FILE      "help_source/help_file.hp"

#define USER               0
#define ADMIN              1

#define NUMBER_OF_FORMS   34

#define UPPER_LEFT         0
#define LOWER_LEFT         1
#define LOWER_RIGHT        2
#define UPPER_RIGHT        3

#define UPPER_LEFT_X       0
#define UPPER_LEFT_Y      58
#define UPPER_RIGHT_X    497
#define UPPER_RIGHT_Y     58
#define LOWER_LEFT_X       0
#define LOWER_LEFT_Y     448
#define LOWER_RIGHT_X    497
#define LOWER_RIGHT_Y    448

#define NFF_MAX_MESSAGE  512

/*  All forms have the same definition for these labels  */

#define LEFT_SCROLL_BUTTON   700
#define RIGHT_SCROLL_BUTTON  701
#define ERROR_BEZEL          888
#define ERROR_TEXT           999

/*  Default screen positions for form centering  */

#define X_FORM_POS  50
#define Y_FORM_POS  55

/*  Height of the BAR_MENU (for form positioning)  */

#define BAR_MENU_HEIGHT  50

/*  Width of the PANEL_MENU (for form positioning)  */

#define PANEL_MENU_WIDTH 185

#endif
