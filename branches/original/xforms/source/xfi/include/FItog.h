#ifndef FItog_included
#define FItog_included		 1

#include "FIgadget.h"


/*
#define TOGGLE_BEZEL_WIDTH	 2
#define PUCK_BEZEL_WIDTH	 3
#define PUCK_WIDTH		12

   Had to change these because of Jeff's changes to box_size.
            GMD 4/3/91
*/


#define TOGGLE_BEZEL_WIDTH	 3
#define PUCK_BEZEL_WIDTH	 4
#define PUCK_WIDTH		13


struct FItog_instance
{
  int		  on_text_length;  
  unsigned char * on_text;
  unsigned int	  on_num_lines;
};


struct FItog_obj
{
  struct FIgadget_instance FIgadget;
  struct FItog_instance    FItog;
};

#endif
