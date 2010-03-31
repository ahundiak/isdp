#ifndef FItext_included
#define FItext_included		1

#include "FIgadget.h"


#define MLT_SIDE_SPACE		8
#define MLT_DIVISOR		8
#define NO_BORDERS		0
#define BORDERS			1
#define ERASE			1
#define NO_ERASE		0

#define YOFFSET_MULTIPLIER	((double)(0.17))


#define CENTER_X(xlo,xhi)      ( xlo + ( ( xhi - xlo ) / 2 ) )


#define MLT_OFFSET( gadget )			\
( ( gadget->FIgadget.num_lines *		\
    gadget->FIgadget.font_height ) +		\
  ( ( gadget->FIgadget.num_lines - 1   ) *	\
    ( gadget->FIgadget.font_height / 5 )	\
  )						\
)



struct FItext_instance
{
  short  rotation;
  short  spacing;
};


struct FItext_obj
{
  struct FIgadget_instance FIgadget;
  struct FItext_instance   FItext;    
};


#endif
