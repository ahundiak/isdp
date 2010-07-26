#include "grimport.h"
#include "igrtypedef.h"
#include "wl.h"

/* prototype files */
#include "dpexbell.h"

static IGRint bell_on = TRUE;
#if defined (X11)
extern Display *EXdisplay;
#endif

void	EX_bell()

 {
   if (bell_on)
   {
#if defined( X11 )
      XBell(EXdisplay,0);
#else
      keybd_bell(0);
#endif
   }
 }

IGRint	DPsetinq_bell(set0_inq1,bell_value)

  IGRint	set0_inq1;
  IGRint	*bell_value;
{
	if (set0_inq1)
	{
	   *bell_value = bell_on;
	}
	else
	{ 
	   bell_on = *bell_value;
	}

	return(1);
}



