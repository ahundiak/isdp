/* ###################   APOGEE COMPILED   ################## */
/*
	This function returns the bounds of a span taking into consideration
   whether it is reversed or not.It assumes that each span is parametrized
   from 0 to 1.
	The boundaries of the edge should be passed.
*/

# include "EMS.h"
# include "OMminimum.h"
# include "igrtypedef.h"
# include "igr.h"
# include "igrdp.h"
# include "igetypedef.h"
# include "dp.h"
# include "godef.h"
# include "gr.h"
# include "go.h"
# include "EMSbnddef.h"
# include "EMSbnd.h"

void	EMspanbounds(bound,span_inx,left,right,reversed)
	struct EMSedgebound *bound,*left,*right;
	IGRshort span_inx;
	IGRboolean	reversed;
{  


	if(span_inx==bound[0].span_inx)
	  {
	     *left = bound[0];
	     right->span_inx = bound[0].span_inx;
	     if(reversed) 
		  right->param = 0;
	     else
		  right->param = 1.0;
	  }
	else if(span_inx==bound[1].span_inx)
	  {
	     *right = bound[1];
	     left->span_inx = bound[1].span_inx;
	     if(reversed) left->param = 1.0;
	     else left->param = 0;
	  }
	else
	  {
	     left->span_inx = right->span_inx = span_inx;
	     if(reversed) {left->param=1.0;right->param=0;}
	     else {left->param=0;right->param=1.0;}
	  }
	  	  
 }  

