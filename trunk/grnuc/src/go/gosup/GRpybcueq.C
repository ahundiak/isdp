/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME	GRpybcueqspace
 
     Abstract:  
	This routine acts as a driver for the BS routines
	to make them more compatible with the current 
	methods to place points equally spaced along an
	element.
-----
%SC%
     VALUE = GRpybcueqspace(message,curve,npts,startpt,stoppt,
			    dirpt,u1,u2,u3,polyline)
-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     curve        IGRbspcurve	 reference B-spline curve
     npts	  IGRlong	 number of points to generate
     startpt	  IGRpoint	 start point on curve
     stoppt	  IGRpoint	 stop point on curve
     dirpt	  IGRpoint	 direction point on curve for closed
                                 curve
     *u1	  IGRdouble	 u parameter of startpt
     *u2	  IGRdouble	 u parameter of stoppt
     *u3	  IGRdouble	 u parameter of dirpt
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     message      IGRlong 	 completion code
				    - MSSUCC if successful
				    - MSFAIL if error occured
                                    - MSINARG if number of points
				 requested is invalid.


     polyline 	  IGRpolyline	 polyline geometry containing the
				   equally spaced points

     VALUE (boolean) = TRUE	    - if successful
		       FALSE	    - if failure
-----
%MD%

     MODULES INVOKED:
		BSsplitcv2
		BSequalspac
		BScveval
		BSsplitcv
-----
%NB%

     NOTES:

-----
%CH%
     CHANGE HISTORY:
	
	MAS  7/07/86  : Creation date.

-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------
 This is a temporary module to protect the GRptseqspace method.

----*/
/*EH*/

#include "grimport.h"
#include "OMminimum.h"
#include "OMprimitives.h"
#include "igrtypedef.h"
#include "igr.h"
#include "msdef.h"
#include "godef.h"
#include "gocmacros.h"
#include "bserr.h"

#define A	  131	

extern    IGRboolean    BSequalspcs();

IGRboolean GRpybcueqspace(message,curve,npts,startpt,stoppt,dirpt,
			 u1,u2,u3,polyline)

IGRlong               *message;		/* return code			*/
struct IGRbsp_curve   *curve;           /* B-spline curve               */
IGRlong               *npts;            /* # of points to produce 	*/
IGRdouble	      *u1;		/* u for startpt		*/
IGRdouble	      *u2;		/* u for endpt			*/
IGRdouble	      *u3;		/* u for dirpt			*/
struct IGRpolyline    *polyline;        /* equal spaced polyline        */

{

  IGRboolean  value;
  IGRboolean  curves_malloced;

  IGRlong n;                            /* number of points left        */
  IGRlong nbytes,num_poles;
  IGRlong msg;     			/* return code                  */
 

  struct IGRbsp_curve *curve1,*curve2,
		      *curve3;		/* split curves			*/
  struct IGRbsp_curve cv1,cv2,cv3;

  IGRdouble  tpars[200],*tparms,u;
  IGRdouble  a,b;			/* u parameters			*/
					/* local storage for curves	*/
  IGRdouble  poles1[A*3],weights1[A],knots1[A+16];
  IGRdouble  poles2[A*3],weights2[A],knots2[A+16];
  IGRdouble  poles3[A*3],weights3[A],knots3[A+16];

    
    *message = MSSUCC;			/* initialize                   */
    curves_malloced = FALSE;
    value = TRUE;

    if (*npts > 200)			/* check to see if stack storage
					   is adaquate			*/
    {
	n = *npts * sizeof(IGRdouble);
	tparms = (double *)om$malloc(size = n);	/* allocate buffer		*/

	if (! tparms)
	{
	    *message = MSFAIL;
	    goto wrapup;
	}
    }
    else				/* storage is adaquate		*/
    {
	tparms = tpars;
    }    

    if (*npts < 2)
    {
 	*message = MSINARG;
    }
					/* split out portion for points	*/
    else 
    {
	num_poles = curve->num_poles + 2 * curve->order - 1;

	if ( (num_poles * 3) > A )
	{
					/* malloc storage for splitting	*/
  	    GRbc_size(curve->order,num_poles,
		      curve->rational,curve->num_boundaries,n);
	    
	    if (curve->phy_closed)
	    {
		nbytes =  n * 2 + 60;
	    }
	    else
	    {
	 	nbytes = n * 3 + 60;
	    }

	    curve1 = (struct IGRbsp_curve *)om$malloc(size = nbytes);

	    if (curve1)
	    {
	        curves_malloced = TRUE;

	        GRbc_partition(curve1,curve->order,num_poles,
		      curve->rational,curve->num_boundaries);

    	        n += 8;			/* allow for alignment		*/

	        curve2=(struct IGRbsp_curve*)
			(GRalign_quad((IGRchar *)curve1 + n));

	        GRbc_partition(curve2,curve->order,num_poles,
		     curve->rational,curve->num_boundaries);
		
		if (! curve->phy_closed)
		{

		    curve3 = (struct IGRbsp_curve *)
			(GRalign_quad((IGRchar *)curve2 + n + 16));

	            GRbc_partition(curve3,curve->order,num_poles,
		      curve->rational,curve->num_boundaries);
		}
	    }
	    else
	    {
		*message = MSFAIL;
	    }
	}
	else
	{				/* curve1 structure		*/
	    curve1 = &cv1;
	    cv1.poles = &poles1[0];
	    cv1.knots = &knots1[0];
					/* curve2 structure		*/
	    curve2 = &cv2;
	    cv2.poles = &poles2[0];
	    cv2.knots = &knots2[0];
					/* curve3 structure		*/
	    curve3 = &cv3;
	    cv3.poles = &poles3[0];
	    cv3.knots = &knots3[0];

	    if (curve->rational)
	    {
	        cv1.weights = &weights1[0];
	        cv2.weights = &weights2[0];
	        cv3.weights = &weights3[0];
	    }
	    else
	    {
		cv1.weights = 0;
	        cv2.weights = 0;
	        cv3.weights = 0;
	    }
	}
	if (*message == MSSUCC)
	{
	    if (((*u1 == curve->knots[curve->order-1] )&&
		 (*u2 == curve->knots[curve->num_poles])) ||
		((*u2 == curve->knots[curve->order-1] )&&
		 (*u1 == curve->knots[curve->num_poles])) )
	    {
		curve3 = curve;
		u = curve3->knots[curve3->order-1];
	    }
	    else
	    {
	        if (curve->phy_closed)
    	        {
		    if (*u1 == *u2)
		    {
			if ((*u1 == curve->knots[curve->order-1]) ||
			    (*u1 == curve->knots[curve->num_poles]))
			{
			    curve3 = curve;
			    u = curve->knots[curve->order-1];
			}
			else
			{
			    BSsplitcv(curve,*u1,curve1,curve2,&msg);
			    if (msg == BSSUCC)
			    {
			        curve3 = curve1;
			        u = curve3->knots[curve3->order-1];
			    }
			    else
			    {
			        *message = MSFAIL;
			    }
			}
		    }
		    else
		    {
		        BSsplitcv2(curve,*u1,*u2,curve1,curve2,&msg);
      	                if (msg == BSSUCC)	
	   	        {		/* determine which curve to use	*/
	    	            if ( ((*u1 < *u3) && (*u3 < *u2)) ||
		 	   	 ((*u1 < *u3) && (*u3 > *u2) && (*u1 > *u2)) ||
		 	   	 ((*u1 > *u3) && (*u3 < *u2) && (*u1 > *u2)))
	    	    	    {
			        curve3 = curve1;
	    	    	    }
	    	    	    else
	    	    	    {
			        curve3 = curve2;
			    }
			    u = curve3->knots[curve3->order-1];
			
	    	      	}
		    	else
		    	{
			    *message = MSFAIL;
			}
		    }
                }
    	        else		/* the curve is an open curve	*/
    	        {
		    if (*u1 < *u2)
		    {
	    	    	a = *u1;
	    	    	b = *u2;
		    }
		    else
		    {
	    	    	a = *u2;
	    	        b = *u1;
		    }
		    if (a == curve->knots[curve->order-1])
		    {
			u = b;
			curve2 = curve;
		    }
		    else
		    {
					/* split at low parameter	*/
	    	        BSsplitcv2(curve,a,b,curve1,curve2,&msg);

		        if (msg == BSSUCC)
		        {
	    	            u = curve->knots[curve->num_poles] - a;
 		
   		            if ( u != 0.0)/* compute adjusted u parameter*/
	    	            {
	        	    	u =  (b - a) / u;
	    	            }
	    	    	    else	/* would happen only due to 	*/
	    	    	    {		/* machine error		*/
			    	u = 0.0;
			    }
	   	    	}
			else
			{
			    *message = MSFAIL;
			}
		    }
		    if (*message == MSSUCC)
		    {
			if ((u == curve2->knots[curve2->num_poles]) ||
			    (u == curve2->knots[curve2->order-1]))
			{
			    curve3 = curve2;
        	            u = curve3->knots[curve->order-1];
			}
			else
			{
					/* split curve 			*/
      	    	            BSsplitcv2(curve2,u,u,curve3,curve1,&msg);
	    	            if (msg == BSSUCC)	
	    	            {
	        	        u = curve3->knots[curve->order-1];
	    	            }
	    	    	    else
	    	    	    {
			        *message = MSFAIL;
	    	    	    }
			}
		    }
		}
    	    }
	}
    	if (*message == MSSUCC)
    	{
            n = *npts - 1;

	    if (! BSequalspcs(&msg,curve3,&u,&n,tparms,polyline->points))
	    {
	    	*message = MSFAIL;
	    }
	    else
	    {
					/* evaluate last  point		*/
	        BScveval(curve3,curve3->knots[curve3->num_poles],0,
		             &polyline->points[n*3],&msg);
	    }
	}
    }

wrapup:

    if (curves_malloced)
    {
	om$dealloc(ptr = curve1);
    }
    if (*npts > 200)
    {
	om$dealloc(ptr = tparms);
    }

    value = 1 & *message;


  return( value );

}

