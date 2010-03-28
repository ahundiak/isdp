#ifndef cpattrco_include
#define cpattrco_include

#include "dpbco.h"

#define CO_copysymb (CO_level | CO_color | CO_weight | CO_style)
#define CO_copytxpa (CO_level | CO_color | CO_weight | CO_font | CO_just | CO_height | CO_width | CO_charsp | CO_linesp )

/* 
 * Command Types 
 */
#define COPYSYMB        91
#define COPYTXSYMB      92
#define LISTNAMES       93

/* 
 * Error Codes 
 */
#define INVALIDINPUT  	1001
#define FILEEXISTS	1003
#define FILENOTOPEN	1005
#define FILEISDIR	1007

/* 
 * Copy Symbology Gadget Labels 
 */
#define LEVEL_VALUE_FIELD       23
#define LEVEL_ALPHA_FIELD       18
#define LEVEL_TOGGLE            21
#define COLOR_VALUE_FIELD       12
#define COLOR_ALPHA_FIELD       13
#define COLOR_TOGGLE            19
#define WEIGHT_VALUE_FIELD      14
#define WEIGHT_TOGGLE           20
#define STYLE_VALUE_FIELD       16
#define STYLE_TOGGLE            22
#define FONT_ALPHA_FIELD        27
#define FONT_TOGGLE             28
#define HEIGHT_ALPHA_FIELD      43
#define HEIGHT_TOGGLE           31
#define WIDTH_ALPHA_FIELD       42
#define WIDTH_TOGGLE            33
#define CHARSP_VALUE_FIELD      40
#define CHARSP_TOGGLE           36
#define LINESP_VALUE_FIELD      39
#define LINESP_TOGGLE           35
#define JUST_VALUE_FIELD        37
#define JUST_ALPHA_FIELD        38
#define JUST_TOGGLE             32

/* 
 * Copy Symbology Form Function Labels 
 */
#define QUIT_BUTTON              1        /* Quit Button                */
#define MSG_FIELD               10        /* Message Field              */
#define ACTIVE_BUTTON           25        /* Copy Symb to Active Symb   */

#endif
