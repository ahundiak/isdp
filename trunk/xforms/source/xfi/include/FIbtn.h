#ifndef FIbtn_included
#define FIbtn_included		1

/*
#define CBAR_BEZEL_WIDTH	2
#define MENU_BEZEL_WIDTH	3

   Had to increase these by one, because of Jeff's changes to box size.
          GMD 4/3/91
*/

#define CBAR_BEZEL_WIDTH	3
#define MENU_BEZEL_WIDTH	4

struct FIbtn_instance
{
  char   auto_pop_up;
  char   menu_button;

  char  *palette;    /* Used for menu buttons */
};

struct FIbtn_obj
{
  struct FIgadget_instance FIgadget;
  struct FIbtn_instance    FIbtn;
};


#endif
