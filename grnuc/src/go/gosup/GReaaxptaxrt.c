/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME GReaaxptax_rtr
 
     Abstract: This routine takes a list of events defining the end
	      point of the semi-major axes of a partial ellipse,
	      a point along the semi-major axis and the endpoint of the
	      semi-minor axis, preprocesses the data and routes the input 
	      to the appropriate math function to find the desired
	      partial ellipse. The order of events must be semi-major axis 
	      point,  point on semi-major axis, semi-minor axis point.
-----
%SC%

    VALUE = GReaaxptax_rtr(msg,events,num_events,out_geom)

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

     out_geom     IGRbsp_curve   output partial ellipse

     VALUE () = TRUE  -  partial ellipse found
		FALSE -  partial ellipse not found

-----
%MD%

     MODULES INVOKED:
			MAeasmpsmconstr

-----
%NB%

     NOTES:
	    The input points must be in the following order:
		axis point  point on axis axis point.

	    The output partial ellipse will have a sweep of
	   PI/2.0.
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

extern    IGRboolean    MAeasmpsmconstr();

IGRboolean GReaaxptax_rtr(msg,events,num_events,out_geom)

           IGRlong             *msg;        /* return code		      */
	   struct GRrtevent    *events;     /* array of events		      */
           IGRshort            *num_events; /* number of events               */
	   struct IGRbsp_curve *out_geom;   /* output partial ellipse	      */

{
  IGRlong poly;                             /* evaluated polynomial           */
  IGRlong base;				    /* base of the polynomial         */
  IGRlong power;			    /* base to the power of i         */
  IGRlong n;				    /* index			      */

  IGRshort coef;
  IGRshort event_types[GRMAX_EA_EVENTS];    /* event subtypes                 */

  IGRint i;                               /* indexes                        */


                                       
  *msg = MSSUCC;

  if( *num_events == GRMAX_EA_EVENTS )    
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

					    /* We do not sort the events      */
      poly = 0;
      power = 1;
      base  = 2 * GRrt_TOTAL;
      n = *num_events - 1;		    /* build the polynomial           */

      for(i=0; i < *num_events; ++i)
	 {
	   coef = event_types[ n - i ];

           poly += coef * power;

           power *= base;
	 }	   

      switch ( poly )                       /* Branch on the value of         */
      {		  		    	    /* the polynomial.                */
        case LABEL3(GRREG,GRREG,GRREG):
        {
	  MAeasmpsmconstr(msg,events[0].pt,events[1].pt,events[2].pt,out_geom);

	  break;
        }

        case LABEL3(CURVE(GRTT),GRREG,CURVE(GRTT)):
        {

	  *msg = GRNOTIMPLEMENTED;
 
 	  break;
        }
 
        case LABEL3(CURVE(GRTT),GRREG,GRREG):
        {

	  *msg = GRNOTIMPLEMENTED;

 	  break;
        }

        case LABEL3(GRREG,GRREG,CURVE(GRTT)):
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
