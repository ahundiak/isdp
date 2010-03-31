#ifndef FIbtn_included
#define FIbtn_included 1

#include "FIgadget.h"

#define CBAR_BEZEL_WIDTH        2
#define MENU_BEZEL_WIDTH   	3


struct FIbtn_instance
{
  char	 auto_pop_up;
  char	 menu_button;

  char	*palette;	/* Used for menu buttons */
};


struct FIbtn_obj
{
  struct FIgadget_instance	FIgadget;
  struct FIbtn_instance 	FIbtn;
};


#endif
