#ifndef FIdial_included
#define FIdial_included		1

#include "FIgadget.h"
#include "FIrange.h"

/*
#define TOLERANCE		2
#define DIAL_BEZEL		1
#define DIAL_BORDER		2
#define DIAL_SHELF		5
   Changed because of Jeff's messing with box_size.
           GMD 4/3/91
*/

#define TOLERANCE		3
#define DIAL_BEZEL		2
#define DIAL_BORDER		3
#define DIAL_SHELF		6

#define NEEDLE_MARGIN		2
#define TICK_MARK_LENGTH	5

#define TOTAL_BORDER    ( DIAL_BORDER + DIAL_SHELF + DIAL_BEZEL )


struct FIdial_instance
{  
  float		offset;
  float		scale;
  float		angle;
    
  short		center_x;
  short		center_y;    

  short		needle_length;
  short		tick_length;

  short		minor_tick_inc;    
  short		major_tick_inc;    
    
  char		direction;
  char		border_style;
};


struct FIdial_obj
{
  struct FIgadget_instance FIgadget;
  struct FIrange_instance FIrange;    
  struct FIdial_instance FIdial;
};


#endif
