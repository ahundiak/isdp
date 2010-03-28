/*---- 
%GP%   CODE CLASSIFICATION


----
%HD%

     MODULE NAME -   DPgetrng

          Abstract:    This routine will use the range passed, the 
			matrix passed, and the range structure to 
			determine the true range.

----
%SC%

     VALUE = DPgetrng(msg,mtx,rng_check,range,new_range);
----
%EN%

      ON ENTRY:

        NAME              DATA TYPE                   DESCRIPTION
      ----------        --------------         -------------------------
      *rng		IGRdouble		range of the element

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

#include "grimport.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "dpstruct.h"
#include "dpdef.h"
#include "msdef.h"

  struct rng_check
  {
	IGRdouble x;
	IGRdouble y;
	IGRdouble z;
  };

/* prototype files */
#include "dpgetrng.h"



  IGRint DPgetrng(msg,matrix,range_chk,rng,new_range)

    IGRlong 			*msg;
    IGRdouble			*matrix;
    struct DPrange_check	*range_chk;
    IGRdouble  			*rng;
    IGRdouble			*new_range;


     {

      register struct DPrng_off	*rng_off;
      register struct rng_check *range;
      IGRint		  	status = TRUE;
      

	*msg = MSSUCC;
	
	
	range = (struct rng_check *) rng;
	
	rng_off = &range_chk->xlo;

	
	new_range[XLO] = matrix[0] * (range + rng_off->x)->x +
			 matrix[1] * (range + rng_off->y)->y +
			 matrix[2] * (range + rng_off->z)->z +
			 matrix[3];


	rng_off = &range_chk->ylo;


	new_range[YLO] = matrix[4] * (range + rng_off->x)->x +
			 matrix[5] * (range + rng_off->y)->y +
			 matrix[6] * (range + rng_off->z)->z +
			 matrix[7];


	rng_off = &range_chk->zlo;


	new_range[ZLO] = matrix[8] * (range + rng_off->x)->x +
			 matrix[9] * (range + rng_off->y)->y +
			 matrix[10] * (range + rng_off->z)->z +
			 matrix[11];


	rng_off = &range_chk->xhi;


	new_range[XHI] = matrix[0] * (range + rng_off->x)->x +
			 matrix[1] * (range + rng_off->y)->y +
			 matrix[2] * (range + rng_off->z)->z +
			 matrix[3];


	rng_off = &range_chk->yhi;


	new_range[YHI] = matrix[4] * (range + rng_off->x)->x +
			 matrix[5] * (range + rng_off->y)->y +
			 matrix[6] * (range + rng_off->z)->z +
			 matrix[7];


	rng_off = &range_chk->zhi;


	new_range[ZHI] = matrix[8] * (range + rng_off->x)->x +
			 matrix[9] * (range + rng_off->y)->y +
			 matrix[10] * (range + rng_off->z)->z +
			 matrix[11];



	return(status);
      }
