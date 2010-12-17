#ifndef FIcklst_included
#define FIcklst_included	 1

/*
#define BOX_SIZE		20
#define CKLST_BEZEL_WIDTH	 2

   Had to change these because of Jeff's changes to box size.
           GMD 4/3/91
*/

#define BOX_SIZE		21
#define CKLST_BEZEL_WIDTH	 3

struct FIcklst_instance
{
  int	box_size;
  int	box_offset;
  int	checkmark_id;    
  int	font_width;
  int	font_height;    
};


struct FIcklst_obj
{
  struct FIgadget_instance FIgadget;
  struct FIcklst_instance   FIcklst;  
};


#endif
