#ifndef FImacros_included
#define FImacros_included	    1

#ifndef NULL
#define NULL                        0
#endif

#ifndef FALSE
#define FALSE                       0
#endif

#ifndef TRUE
#define TRUE                        1
#endif 

#define OFF                         0
#define ON                          1
#define FI_MAX_VALUE_FORMAT        15

/*	dmb:03/18/91: 6/12/90 sh Added FI_DATA_LEN */
#define FI_DATA_LEN			1000

#define FI_DATA_OFFSET          77777
#define BEGIN_USER_LABEL           11
#define SQUARE                      0
#define CHAMFERED                   1

/*
#define BUTTON_BEZEL_WIDTH          3

   Had to change this because of Jeff'f changes to box_size.
              GMD 4/3/91
*/
#define BUTTON_BEZEL_WIDTH          4

#define FI_EFFECT_WIDTH             1


#ifndef M_PI
#include <math.h>
#endif

#define TWO_PI ((double)(M_PI * (double)2.0))



#define IT_IS_DISABLED(gadget)         \
			  (gadget->FIgadget.attr_mask & FI_NOT_ENABLED)

#define IT_IS_DISPLAYABLE(gadget)      \
		(!(gadget->FIgadget.attr_mask & FI_NOT_DISPLAYED))

#define IT_IS_NOT_DISPLAYABLE(gadget)  \
		  (gadget->FIgadget.attr_mask & FI_NOT_DISPLAYED)

#define IT_IS_NOT_DISPLAYED(gadget)	 (! gadget->FIgadget.displayed)

#define IT_IS_DISPLAYED(gadget)		 (gadget->FIgadget.displayed)

#define IT_HAS_INITIAL_NOTIFY(gadget)  \
			(gadget->FIgadget.attr_mask & FI_INITIAL_NOTIFY)

#define IT_HAS_COMPLETE_NOTIFY(gadget) \
		(!(gadget->FIgadget.attr_mask & FI_NO_COMPLETE_NOTIFY))

#define IT_IS_HILITED(gadget) (gadget->FIgadget.attr_mask & FI_HILITED)

#define IT_HAS_TEXT(gadget)		\
			  (gadget->FIgadget.attr_mask & FI_TEXT_GADGET)

#define IT_HAS_SYMBOL(gadget)          \
			(!(gadget->FIgadget.attr_mask & FI_TEXT_GADGET))

#define IT_IS_CONTROL(gadget)          \
			(gadget->FIgadget.label < FI_PROMPT_FIELD)

#define DISPLAY_LOW_VALUE(gadget)      \
			  (gadget->FIrange.display_mask & FI_LOW_VALUE)

#define DISPLAY_VALUE(gadget)          \
			  (gadget->FIrange.display_mask & FI_VALUE)

#define DISPLAY_HIGH_VALUE(gadget)     \
			  (gadget->FIrange.display_mask & FI_HIGH_VALUE)

#define DISPLAY_MAX_MIN(gadget)        \
			  (gadget->FIrange.display_mask & FI_MAX_MIN)

#define ERASE_COLOR(gadget)           				  \
			  ((gadget->FIgadget.erase_color > -1) ?  \
			   (gadget->FIgadget.erase_color) :	  \
			   (gadget->FIgadget.form->bgcolor))

#define OFF_COLOR(gadget)              (gadget->FIgadget.off_color)
#define ON_COLOR(gadget)               (gadget->FIgadget.on_color)
#define OFF_COLOR2(gadget)             (gadget->FIgadget.off_color2)
#define ON_COLOR2(gadget)              (gadget->FIgadget.on_color2)

#define MAX(x,y)                       (((x)>(y)) ? (x):(y))
#define MIN(x,y)                       (((x)<(y)) ? (x):(y))
#define ABS(x)                         ((x >= 0) ? (x) : -(x))
#define FABS(x)                        ((x >= 0.0) ? (x) : -(x))

#define POINT_IN_RECT(x,y,xlo,ylo,xhi,yhi)	\
	  ((x >= xlo) && (y >= ylo) && (x <= xhi) && (y <= yhi))

#define STATE_GADGET(type)	             \
  ((type == FI_BUTTON) || (type == FI_TOGGLE) || (type == FI_CHECKLIST))


#define IT_HAS_OFF_SYMBOL(gadget)      \
			      (gadget->FIgadget.symbol_ptr.sym_width)

#define IT_HAS_ON_SYMBOL(gadget)       \
			   (gadget->FIgadget.on_symbol_ptr.sym_width)

#define XSCREEN(gadget)		(gadget->FIgadget.form->Xscreen)
#define XWINDOW(gadget)		(gadget->FIgadget.form->Xwindow)


#ifndef sbitset
/* This macro returns 1 if the sign bit is set */
#define sbitset(c) ((c) & 128 ? 1 : 0 )
#endif

#endif
