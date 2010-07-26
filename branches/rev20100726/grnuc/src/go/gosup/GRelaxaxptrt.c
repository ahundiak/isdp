/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME GRelaxaxpt_rtr
 
     Abstract: This routine takes a list of events defining two axis
	      end points of an ellipse and another point on the ellipse
	      to be created, preprocesses the data and routes the input 
	      to the appropriate math function to find the desired
	      ellipse. The order of events must be axis point, axis
	      point, point on the ellipse.
-----
%SC%

    VALUE = GRelaxaxpt_rtr(msg,events,num_events,out_geom)

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

     out_geom     IGRbsp_curve   output ellipse

     VALUE () = TRUE  -  ellipse found
		FALSE -  ellipse not found

-----
%MD%

     MODULES INVOKED:

-----
%NB%

     NOTES:
	    The input points must be in the following order:
		axis point  axis point  point on the ellipse.

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

#define GREL_TOTAL GRrt_TOTAL

extern    IGRboolean    MAelsmconstr();

IGRboolean GRelaxaxpt_rtr(msg,events,num_events,out_geom)

           IGRlong             *msg;        /* return code		      */
	   struct GRrtevent    *events;     /* array of events		      */
           IGRshort            *num_events; /* number of events               */
	   struct IGRbsp_curve *out_geom;   /* output ellipse		      */

{
  IGRdouble axpts[6];			    /* endpoints of axis	      */

  IGRlong poly;                             /* evaluated polynomial           */
  IGRlong base;				    /* base of the polynomial         */
  IGRlong power;			    /* base to the power of i         */
  IGRlong n;				    /* index			      */

  IGRshort coef;
  IGRshort event_types[GRMAX_EL_EVENTS];    /* event subtypes                 */

  IGRint i,j;                               /* indexes                        */


                                       
  *msg = MSSUCC;

  if( *num_events == GRMAX_EL_EVENTS )    
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
	  for(j=0;j<3;++j)
	     {
	       axpts[j]   = events[0].pt[j];
	       axpts[j+3] = events[1].pt[j];
	     }

	  MAelsmconstr(msg,axpts,events[2].pt,out_geom);

	  break;
        }

        case LABEL3(GRREG,CURVE(GRTT),GRREG):
        {

	  *msg = GRNOTIMPLEMENTED;
  
 	  break;
        }
 
        case LABEL3(GRREG,CURVE(GRTT),CURVE(GRTT)):
        {

	  *msg = GRNOTIMPLEMENTED;

  	  break;
        }
 
        case LABEL3(CURVE(GRTT),CURVE(GRTT),GRREG):
        {
  
	  *msg = GRNOTIMPLEMENTED;

 	  break;
        }
 
        case LABEL3(CURVE(GRTT),GRREG,CURVE(GRTT)):
        {
  
	  *msg = GRNOTIMPLEMENTED;

 	  break;
        }
 
  	case LABEL3(CURVE(GRTT),CURVE(GRTT),CURVE(GRTT)):
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
