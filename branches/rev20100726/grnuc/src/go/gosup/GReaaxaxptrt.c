/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME GReaaxaxpt_rtr
 
     Abstract: This routine takes a list of events defining the 
	      endpoints an axis and a point on an elliptical arc
	      to be created, preprocesses the data and routes 
	      the input to the appropriate math function to find 
	      the desired arc.
-----
%SC%

    VALUE = GReaaxaxpt_rtr(msg,events,num_events,out_geom)

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     events       GRevent	 array of events
     num_events   IGRshort       number of events
     
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     message	  IGRlong	 completion code
				    - MSSUCC if successful
				    - MSFAIL (severe) if failure
				    - MSINARG if too many events for
				 this router.
				    - GRILLDEFINITION if illegal 
				 definition for placing 
				    - GRNOTIMPLEMENTED if the input
				 events map to a function which has
				 not been implemented yet.

     out_geom     IGRbsp_curve   output elliptical arc

     VALUE () = TRUE  -  elliptical arc found
		FALSE -  elliptical arc not found

-----
%MD%

     MODULES INVOKED:
		     MAeasmconstr
		     GRsort_events
-----
%NB%

     NOTES:
	   The order of input must be:
		axis point, point on ellipse, axis point
-----

%CH%
     CHANGE HISTORY:
	
	RDH     03/05/86 : Design date.
	RDH     03/05/86 : Creation date.
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------
 This routine determines which events have occurred and builds a
label for the case statment which will route the input data to the
appropriate math function to construct to circle.

----*/
/*EH*/

#include "grimport.h"
#include "igrtypedef.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "madef.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "msdef.h"
#include "grrouterpriv.h"
#include "ex.h"
#include "grio.h"
#include "grerr.h"

#define GREA_TOTAL GRrt_TOTAL

extern    IGRboolean    GRsort_events();
extern    IGRboolean    MAeasmconstr();

IGRboolean GReaaxaxpt_rtr(msg,events,num_events,out_geom)

           IGRlong             *msg;        /* return code		      */
	   struct GRrtevent    *events;     /* array of events		      */
           IGRshort            *num_events; /* number of events               */
	   struct IGRbsp_curve *out_geom;   /* output elliptical arc	      */

{
  IGRdouble smj_pts[6];			    /* s-major axis endpoints	      */

  IGRlong poly;                             /* evaluated polynomial           */
  IGRlong base;				    /* base of the polynomial         */
  IGRlong power;			    /* base to the power of i         */
  IGRlong n;				    /* index			      */
  IGRlong mess;				    /* return code		      */

  IGRshort coef;
  IGRshort order[GRMAX_AR_EVENTS];          /* order of events                */
  IGRshort event_types[GRMAX_AR_EVENTS];    /* event subtypes                 */
  IGRshort ordered_types[GRMAX_AR_EVENTS];  /* ordered event subtypes	      */
  IGRshort total;			    /* total number of event subtypes */

  IGRint i,j;                               /* indexes                        */


                                       
  *msg = MSSUCC;

  if( *num_events == GRMAX_AR_EVENTS )    
    {
      for(i=0; i < *num_events; ++i)        /* Process the events             */
         {  
           if( events[i].subtype == GRREG )
             {
	       event_types[i] = GRREG;
             }
	   else
	     {
	       event_types[i] = events[i].subtype;

               if( events[i].props[0].type == GRSURFACE )
				            /* add offset to differentiate    */
                 {			    /* between surface and other      */
                   event_types[i] += GRrt_TOTAL; /* geometry                  */
                 }
             }
         }

      total = GREA_TOTAL;		    /* sort the events		      */

      GRsort_events(&mess,event_types,num_events,&total,ordered_types,order);

      poly = 0;
      power = 1;
      base  = 2 * GRrt_TOTAL;
      n = *num_events - 1;		    /* build the polynomial           */

      for(i=0; i < *num_events; ++i)
	 {
	   coef = ordered_types[ n - i ];

           poly += coef * power;

           power *= base;
	 }	   

      switch ( poly )                       /* Branch on the value of         */
      {		  		    	    /* the polynomial.                */
        case LABEL3(GRREG,GRREG,GRREG):
        {
	  for(j=0;j<3;++j)
	     {
	       smj_pts[j]   = events[0].pt[j];
	       smj_pts[j+3] = events[2].pt[j];
             }

	  MAeasmconstr(msg,smj_pts,events[1].pt,out_geom);

	  break;
        }

        case LABEL3(GRREG,GRREG,CURVE(GRTT)):
        {

	  *msg = GRNOTIMPLEMENTED;

 	  break;
        }
 
        case LABEL3(GRREG,CURVE(GRTT),CURVE(GRTT)):
        {
 
	  *msg = GRNOTIMPLEMENTED;

 	  break;
        }
 
        case LABEL3(CURVE(GRTT),CURVE(GRTT),CURVE(GRTT)):
        {
 
	  *msg = GRNOTIMPLEMENTED;

 	  break;
        }

        default:
        {
          *msg = GRILLDEFINITION; 

	  break;  
        }

      }/* END OF SWITCH */

    } 
  else
    {
      *msg = MSINARG;			    /* Too many events for 	      */
    }

  return( *msg & 1 );

}/* This has been an R.D.H. production!!! */
