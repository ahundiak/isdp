#ifndef MIdef_included
#define MIdef_included	1

#include "FIbtn.h"
/* #include "FI.h" dmb:04/17/91: duplicate call*/

#define MI_START_LABEL		1000

#define MI_WIN_ICON_OFFSET	  70

#define MI_TOP_PALETTE		  99

#define UP_STATE		 0.0
#define DOWN_STATE		 1.0


struct pal_info_st
{
  struct FIbtn_obj  * current_button;
};


struct btn_info_st
{
  struct FIgroup_obj  * palette_id;
  struct pal_info_st  * pal_info;
};


struct menu_info_st
{
  int next_label;  
  int menu_type;
};

#endif
