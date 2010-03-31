/*
         G R A P H I C S    L I B R A R Y    I N C L U D E   F I L E

    This file contains the defined constants and some of the locally
    defined structures used within the graphics.c library.

  HISTORY

    SS  :  Long ago  :  Creation
    DHM :  Long ago  :  Altered somewhat
    SS  :  08/28/89  :  Altered it some more
*/

#ifndef _graphics_h
#define _graphics_h 

/*
 * General constants 
 */

#ifndef TRUE
#define TRUE 1
#endif
#ifndef FALSE
#define FALSE 0
#endif
#ifndef NULL
#define NULL 0
#endif

/*
 * These constants are watered down versions of
 * their definitions found in <values.h>.
 */

#ifndef MAXINT
#define MAXINT 0x7fffffff
#endif
#ifndef MAXFLOAT
#define MAXFLOAT 1e+30
#endif
#ifndef MAXDOUBLE
#define MAXDOUBLE 1e+300
#endif
#ifndef MINFLOAT
#define MINFLOAT 1e-30
#endif
#ifndef MINDOUBLE 
#define MINDOUBLE 1e-300
#endif

#define XLEFT 200
#define XRIGHT 1000
#define YTOP  155
#define YBOTTOM 800

#define CENTERED 1
#define RIGHTJUST 2
#define LEFTJUST 3
#define TOP_LEFT 1
#define TOP_RIGHT 2
#define BOTT_LEFT 3
#define BOTT_RIGHT 4

#define MATCH   0
#define NOMATCH 1
#define UNITY   1

#define MAX_COLORS 9
#define BACKGR 0
#define BLACK  1
#define BLUE   2
#define GREEN  3
#define RED    4
#define PINK   5
#define YELLOW 6
#define WHITE  7
#define FOREGR MAX_COLORS-1

#define MAX_KEYIN 40
#define MAX_KEYBRD 40

#define CHAR   0
#define SHORT  1
#define INT    2
#define DOUBLE 3

#define MAXVALS 100

#define INPUT_MODE	0x01
#define COLOR_MODE	0x02

#define DASHED_STYLE	0x0f0f
#define SOLID_STYLE	0xffff

#endif
