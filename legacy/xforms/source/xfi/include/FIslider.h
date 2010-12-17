#ifndef FIslider_included
#define FIslider_included	 1

#include "FIgadget.h"
#include "FImacros.h"
#include "FIrange.h"


#define SLIDER_TEXT_CLEARANCE	 6
#define SLIDER_MIN_BTN_WIDTH	20
#define SLIDER_SLOT_THICKNESS	10


/********************************************************************

                       button_size
     (xlo, ylo)        <-------->
     .                  ________
                 ^     |\______/|
      slot_offset|     ||      ||           high_clear
                 v     ||      ||           <---->
      100   ###########|| 300  ||###########   500
      <->              ||      ||              <->
   low_font_width      ||______||            high_font_width
      <---->           |/______\|
     low_clear                                    . (xhi,yhi)

********************************************************************/


struct FIslider_instance
{
  short		low_clear;
  short		high_clear;

  int		low_font_width;
  int		high_font_width;

  short		last_button_xlo;
  short		last_button_ylo;

  short		button_size;
  short		slot_offset;

  char		type;		/*** FI_VERTICAL or FI_HORIZONTAL ***/

  char		low_str  [ FI_MAX_VALUE_FORMAT + 1 ];
  char		high_str [ FI_MAX_VALUE_FORMAT + 1 ];
};


struct FIsld_obj
{
  struct FIgadget_instance	FIgadget;
  struct FIrange_instance	FIrange;
  struct FIslider_instance	FIslider;
};


#endif
