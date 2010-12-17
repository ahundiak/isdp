#ifndef FIgauge_included
#define FIgauge_included	1

#include "FIgadget.h"


#define GAUGE_SPACE_RATIO 	0.35


struct FIgauge_instance
{
  float	minor_increments;

  short	space_width;
  short	rect_width;
  short	current_rect;

  char	type;
};


struct FIgauge_obj
{
  struct FIgadget_instance  FIgadget;
  struct FIrange_instance  FIrange;  
  struct FIgauge_instance  FIgauge;
};


#endif
