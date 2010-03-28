/*---- 
%GP%   CODE CLASSIFICATION


----
%HD%

     MODULE NAME -   DPrngcheck

          Abstract:    This routine will use the range of the element to
			determine if the element is completely within
			the range of the window or is small enough to
			be either drawn as a box or a dot.
----
%SC%

     VALUE = DPrngcheck(msg,win,rng,clip);
----
%EN%

      ON ENTRY:

        NAME              DATA TYPE                   DESCRIPTION
      ----------        --------------         -------------------------
      *win		struct DPwindow		window's instance data

      *rng		IGRdouble		range of the element

----
%EX%

        NAME            DATA TYPE                   DESCRIPTION
      ----------      -----------------      --------------------------

	*clip	      IGRboolean	     1 if the element needs to
						be clipped
					     0 if the element does not need
						to be clipped

	*msg	      IGRlong		         return status
				  	     MSSUCC - successfully completed
				  	     MSFAIL - unsuccessfully completed

      VALUE() =    TRUE if element needs to be stroked
                   FALSE if element does not need to be stroked

----
%MD%
 
     MODULES INVOKED:  


		DPsetrng()	

----
%NB%

      NOTES:   None

----
%CH%

       AET   06/25/86   : Creation date

----
%PD%
------------------------------------------------------------------------------
               P R O G R A M    D E S C R I P T I O N
------------------------------------------------------------------------------

	     This routine will use the world to view matrix to see
	which corners of the view volume are the low and high x, y, and
	z.
---*/
/*EH*/

#define	XLO	0
#define	YLO	1
#define	ZLO	2
#define	XHI	3
#define	YHI	4
#define	ZHI	5
#define DOT_TOL	1
#define BOX_TOL	3

#include "grimport.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "dpstruct.h"
#include "dpdef.h"
#include "msdef.h"
#include "wl.h"

/* prototype files */
#include "dpgetrng.h"


  struct rng_check
  {
	IGRdouble x;
	IGRdouble y;
	IGRdouble z;
  };

  IGRint DPrngcheck(msg,win,win_no, rng,clip)

    IGRlong 		*msg;
    struct DPgra_gad  	*win;
    IGRint		win_no;
    IGRdouble		*rng;
    IGRboolean	     	*clip;

     {

      IGRdouble		  	dit_range[6];
      IGRdouble		 	delta_x;
      IGRdouble			delta_y;
      IGRint		  	return_code = TRUE;
      struct WLpoint            point;

	*msg = MSSUCC;      

	DPgetrng(msg, (IGRdouble *)win->wld_to_viewport, &win->range_chk,
		rng, dit_range);

	delta_x = dit_range[XHI] - dit_range[XLO];
	delta_y = dit_range[YHI] - dit_range[YLO];


	if ((delta_x <= DOT_TOL) && (delta_y <= DOT_TOL))
	{
           point.x = ( short )( dit_range[XLO] + delta_x/2 + 0.5 );
           point.y = ( short )( dit_range[YLO] + delta_y/2 + 0.5 );
           WLdraw_2D_point_string( win_no, 1, &point );
	   return_code = FALSE;
	}
	else
	{
	      *clip = FALSE;

	      if ((dit_range[XLO] < win->dit_clip_range[XLO]) ||
		  (dit_range[YLO] < win->dit_clip_range[YLO]) ||
		  (dit_range[ZLO] < win->dit_clip_range[ZLO]) ||
		  (dit_range[XHI] > win->dit_clip_range[XHI]) ||
		  (dit_range[YHI] > win->dit_clip_range[YHI]) ||
		  (dit_range[ZHI] > win->dit_clip_range[ZHI]))
	      {
		 *clip = TRUE;
	      }

	      if ((dit_range[XLO] > win->dit_clip_range[XHI]) ||
		  (dit_range[YLO] > win->dit_clip_range[YHI]) ||
		  ((dit_range[ZLO] > win->dit_clip_range[ZHI]) &&
		   ((win->flags && FRONT_CLIP)))	       ||
		  (dit_range[XHI] < win->dit_clip_range[XLO]) ||
		  (dit_range[YHI] < win->dit_clip_range[YLO]) ||
		  ((dit_range[ZHI] < win->dit_clip_range[ZLO]) &&
		   ((win->flags && BACK_CLIP))))
	      {
		 return_code = FALSE;
	      }
	}

	return(return_code);
      }
