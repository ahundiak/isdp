/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME GRcrcnrad_rtr
 
     Abstract: This routine takes a list of events defining the center
	      and radius points of a circle to be created, preprocesses 
	      the data and routes the input to the appropriate math 
	      function to find the desired circle.
-----
%SC%

    VALUE = GRcrcnrad_rtr(msg,events,num_events,out_geom)

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
				    - GRNOTIMPLEMENTED if input
				 events map to a function which has
				 not been implemented yet

     out_geom     IGRbsp_curve   output 

     VALUE () = TRUE  -  circle found
		FALSE -  circle not found

-----
%MD%

     MODULES INVOKED:
			MAcrcptconstr
			GOcttobc
			MAcrrcconstr
-----
%NB%

     NOTES:
		The order of events must be:

			1). Center point
			2). radius point or radius value
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
 If the input is a regular point for the center and a radius value,
the circle is constructed using the vector normal to the view as the
circle normal vector. If the radius is a regular point, the z-axis 
of the center point's view is used to find the normal to the circle.
If the radius point is a Tangent-To point, the normal to the circle 
is determined using the tangent vector of the object.

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

#define GRCR_TOTAL GRrt_TOTAL

extern    IGRboolean    MAcrcptconstr();
extern    IGRboolean    GOcttobc();
extern    IGRboolean    MAcrrcconstr();

IGRboolean GRcrcnrad_rtr(msg,events,num_events,out_geom)

           IGRlong             *msg;        /* return code		     */
	   struct GRrtevent    *events;     /* array of event pointers       */
           IGRshort            *num_events; /* number of events              */
	   struct IGRbsp_curve *out_geom;   /* output line                   */

{
  IGRdouble sol_u;			    /* u par of tangent point	     */

  IGRlong poly;                             /* evaluated polynomial          */
  IGRlong base;				    /* base of the polynomial        */
  IGRlong power;			    /* base to the power of i        */
  IGRlong n;				    /* index			     */

  IGRint center_diam_flag = 0;
  
  IGRshort i;				    /* index			     */
  IGRshort coef;
  IGRshort event_types[GRMAX_CR_EVENTS];    /* event subtypes                */


                                       
  *msg = MSSUCC;


  if( *num_events == 2 )    
    {
      for(i=0; i < *num_events; ++i)        /* Process the events            */
         {  
	   if( events[i].type == GRD_POINT )
	     {
               if( events[i].subtype == GRREG )
                 {
	           event_types[i] = GRREG;
                 }
	       else
	         {
	           event_types[i] = events[i].subtype;

                   if( events[i].props[0].type == GRSURFACE )
				            /* add offset to differentiate   */
                     {			    /* between surface and other     */
                       event_types[i] += GRrt_TOTAL; /* geometry             */
                     }
                 }
	     }
	   else
	     {
	       event_types[i] = GRVL;
	     }
         }

      poly = 0;
      power = 1;
      base  = 2 * GRrt_TOTAL;
      n = *num_events - 1;		    /* build the polynomial          */

      for(i=0; i < *num_events; ++i)
	 {
	   coef = event_types[ n - i ];

           poly += coef * power;

           power *= base;
	 }	   

      switch ( poly )                       /* Branch on the value of        */
      {		  		    	    /* the polynomial.               */
        case LABEL2(GRREG,GRREG):
        {
	  MAcrcptconstr(msg,events[0].pt,events[1].pt,events[0].vc,out_geom);

	  break;
        }

        case LABEL2(GRREG,CURVE(GRTT)):
        {
	  GOcttobc(msg,events[1].geoms[0],events[0].pt,
		   events[1].pt,&center_diam_flag,&sol_u,out_geom);

	  break;
        }

        case LABEL2(GRREG,GRVL):
        {
	  MAcrrcconstr(msg,&events[1].val[0],events[0].pt,events[0].vc,
		       out_geom);

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
      *msg = MSINARG;			    /* Too many events for 	     */
    }

  return( *msg & 1 );

}/* This has been an R.D.H., S.D.G. production!!! */
