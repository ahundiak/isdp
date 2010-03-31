#ifndef FIscroll_included
#define FIscroll_included	1


#include "FIgadget.h"
#include "FIrange.h"


#define BEZEL		3
#define BEZEL2          2
#define BTN_SIZE	12
#define BTN_WD		19
#define MIN_SLIDE_AREA	12
#define BUTTON_SPACING  1

#define PG_UP		0
#define LN_UP		1
#define LN_DN		2
#define PG_DN		3

#define PG_UP_SYM	'\004'
#define LN_UP_SYM	'\005'
#define LN_DOWN_SYM	'\006'
#define PG_DOWN_SYM	'\007'

#define VW_LT		0
#define CH_LT		1
#define CH_RT		2
#define VW_RT		3

#define VIEW_LT_SYM	'\023'
#define LT_SYM		'\024'
#define RT_SYM		'\025'
#define VIEW_RT_SYM	'\026'

#define SCROLL_SIZE	26



struct FIscroll_instance
{
  unsigned short	track_xlo, track_ylo,
			track_xhi, track_yhi;

  unsigned short	btn_area_xlo, btn_area_ylo,
			btn_area_xhi, btn_area_yhi;

  double		view;
  char			type;

  struct FIbtn_obj	*puck;
  struct FIbtn_obj	**btns;
};


struct FIscrl_obj
{
  struct FIgadget_instance	FIgadget;
  struct FIrange_instance	FIrange;
  struct FIscroll_instance	FIscroll;
};


#endif
