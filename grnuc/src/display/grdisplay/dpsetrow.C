/*---- 
%GP%   CODE CLASSIFICATION


----
%HD%

     MODULE NAME -   DPsetrow

          Abstract:    This routine will set the the lows and highs 
			using a row of the world to view matrix

----
%SC%

     VALUE = DPsetrow(msg,row,lo,hi);
----
%EN%

      ON ENTRY:

        NAME              DATA TYPE                   DESCRIPTION
      ----------        --------------         -------------------------
      *row		IGRdouble		row used to see which
						point is the low and
						high
----
%EX%

        NAME            DATA TYPE                   DESCRIPTION
      ----------      -----------------      --------------------------

      *lo	      struct DPrng_off	     low point of the cube

      *hi 	      struct Dprng_off	     high point of the cube

	*msg	      IGRlong		         return status
				  	     MSSUCC - successfully completed
				  	     MSFAIL - unsuccessfully completed

      VALUE() =    TRUE if successful
                   FALSE if something went wrong.

----
%MD%
 
     MODULES INVOKED:  




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

	     This routine will use a row of the world to view matrix to see
	which corners of the view volume are the low and high x, y, and
	z depending on which row is sent.   The philosiphy here is to see
	which corners of the unit cube define the lo and high x, y, and
	z.  This information is then used when we do a range check on an
	element because we already know which corners of the range are 
	going to be the low x, y, and z's.

---*/
/*EH*/

#include "grimport.h"
#include "OMminimum.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "dpstruct.h"
#include "msdef.h"

/* prototype files */
#include "dpsetrow.h"


 IGRint DPsetrow(msg,row,lo,hi)

   IGRlong   *msg;
   IGRdouble *row;
   struct    DPrng_off	*lo;
   struct    DPrng_off  *hi;

     {


	IGRdouble temp_lo;
	IGRdouble temp_hi;
	IGRdouble temp;


	*msg = MSSUCC;
	temp_lo = temp_hi = 0;

	lo->x = 0;
	lo->y = 0;
	lo->z = 0;
	hi->x = 0;
	hi->y = 0;
	hi->z = 0;


  /*   check point (1,0,0)  */

	if (row[0] < temp_lo)
	{
	   temp_lo = row[0];
	   lo->x = 1;
	   lo->y = 0;
	   lo->z = 0;
	}
	else
	{
	   if (row[0] > temp_hi)
	   {
	      temp_hi = row[0];
	      hi->x = 1;
	      hi->y = 0;
	      hi->z = 0;
	   }
	}

  /*  check point (0,1,0)   */

	if (row[1] < temp_lo)
	{
	   temp_lo = row[1];

	   lo->x = 0;
	   lo->y = 1;
	   lo->z = 0;

	}
	else
	{
	   if (row[1] > temp_hi)
	   {
	      temp_hi = row[1];
	      hi->x = 0;
	      hi->y = 1;
	      hi->z = 0;

	   }
	}


  /*  check point (0,0,1)  */

	if (row[2] < temp_lo)
	{
	   temp_lo = row[2];

	   lo->x = 0;
	   lo->y = 0;
	   lo->z = 1;

	}
	else
	{
	   if (row[2] > temp_hi)
	   {
	      temp_hi = row[2];

	      hi->x = 0;
	      hi->y = 0;
	      hi->z = 1;

	   }
	}

  /*  check point (1,1,0)  */

	temp = row[0] + row[1];

	if (temp < temp_lo)
	{
	   temp_lo = temp;
	   lo->x = 1;
	   lo->y = 1;
	   lo->z = 0;
	}
	else
	{
	   if (temp > temp_hi)
	   {
	      temp_hi = temp;

	      hi->x = 1;
	      hi->y = 1;
	      hi->z = 0;
	   }
	}

  /*  check point (1,0,1)  */

	temp = row[0] + row[2];

	if (temp < temp_lo)
	{
	   temp_lo = temp;
	   lo->x = 1;
	   lo->y = 0;
	   lo->z = 1;
	}
	else
	{
	   if (temp > temp_hi)
	   {
	      temp_hi = temp;

	      hi->x = 1;
	      hi->y = 0;
	      hi->z = 1;
	   }
	}

  /*  check point (0,1,1)  */

	temp = row[1] + row[2];

	if (temp < temp_lo)
	{
	   temp_lo = temp;
	   lo->x = 0;
	   lo->y = 1;
	   lo->z = 1;
	}
	else
	{
	   if (temp > temp_hi)
	   {
	      temp_hi = temp;

	      hi->x = 0;
	      hi->y = 1;
	      hi->z = 1;
	   }
	}


  /*  check point (1,1,1)  */

	temp = row[0] + row[1] +
			row[2];

	if (temp < temp_lo)
	{
	   temp_lo = temp;
	   lo->x = 1;
	   lo->y = 1;
	   lo->z = 1;
	}
	else
	{
	   if (temp > temp_hi)
	   {
	      temp_hi = temp;

	      hi->x = 1;
	      hi->y = 1;
	      hi->z = 1;
	   }
	}


	return(TRUE);
   }
