/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME	MArang2vc
 
     Abstract:	This routine computes the angle (in radians)
	     between 2 vectors. The angle is measured counter
	     clockwise as determined by an input vector. The
	     sine and cosine of the angle are returned also.

-----
%SC%
     VALUE = MArang2vc(message,a,b,z,angle)
-----
%EN%
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     a		  IGRvector      input vector: [x, y, z]
     b		  IGRvector	 input vector: [x, y, z]
     z		  IGRvector	 vector to determine "counter clockwise"
     
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     message	  IGRlong	 the completion code
				    MSSUCC - successful completion
				    MAIDGENRAT - information, one of
				    the input vectors was the zero
				    vector
				    MSFAIL - error occurred.

     angle	  IGRdouble	 the relative angle between the vectors
				 
     VALUE (IGRboolean) = FALSE; failure of the routine.
		          TRUE;  successful completion.
-----
%MD%

     MODULES INVOKED:
			MAdotvc
			MAcrossvc
			MAlenvc
-----
%NB%
     NOTES:  The angle returned is between 0 and 2*PI and is 
     	    counter clockwise with respect to the input vector.
-----
%CH%
     CHANGE HISTORY:
	
     07/08/87 : Creation date
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------
	This function uses the algorithm found in any calculus or
linear algegra book for computing the angle between two vectors.
Then the angle is adjusted so that it is measured counter clockwise
with respect to the input vector.

----*/
/*EH*/

#include "igrtypedef.h"
#include "igrdef.h"
#include "igr.h"
#include "ma.h"
#include "msdef.h"

/* prototypes */
#include "marang2vc.h"   /* defining prototype file */
#include "maatan2.h"
#include "macrossvc.h"
#include "madotvc.h"
#include "malenvc.h"


IGRboolean MArang2vc(message,a,b,z,angle)

IGRlong	*message;		/* completion code		*/
IGRvector  a; 	        	/* input vector			*/
IGRvector  b;			/* input vector			*/
IGRvector  z;			/* vector to determein direction*/
IGRdouble  *angle;		/* angle			*/

{
  IGRvector 	a_cross_b;	/* a cross b			*/
  IGRdouble	dot_prod;	/* dot product result		*/
  IGRdouble	mag_a_cross_b;  /* magnitude of a cross b	*/
  IGRdouble 	a_magnitude;	/* magnitude of a 		*/
  IGRdouble 	b_magnitude;	/* magnitude of b		*/
  IGRdouble	sine,cosine;	/* sine and cosine		*/
  extern    IGRdouble    MAatan2();

  IGRlong	mess;		/* return message		*/

  extern    IGRboolean    MAdotvc();
  extern    IGRboolean    MAcrossvc();
  extern    IGRboolean    MAlenvc();


  *message = MSSUCC;	

  MAdotvc(&mess,a,b,&dot_prod);

  MAcrossvc(&mess,a,b,a_cross_b);

  MAlenvc(&mess,a_cross_b,&mag_a_cross_b);

  MAlenvc(&mess,b,&b_magnitude);

  MAlenvc(&mess,a,&a_magnitude);

  if( a_magnitude != 0.0  &&  b_magnitude != 0.0 && mag_a_cross_b != 0.0 )
  {
    sine = mag_a_cross_b / (a_magnitude * b_magnitude);
    cosine = dot_prod / (a_magnitude * b_magnitude);

    *angle = MAatan2(message,&sine,&cosine);

    if( 1 & *message )
    { 
      MAdotvc(&mess,a_cross_b,z,&dot_prod);

      if( dot_prod < 0 )
      {
      	*angle = 2.0 * PI - *angle;
      }
    }
  }
  else
  {
    *message = MAIDGENRAT;
    *angle = 0.0;
  }
        
  return( 1 & *message );
  
}/* This has been an R.D.H. production!!! */
