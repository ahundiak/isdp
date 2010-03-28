/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME GRcr2ptrad_rtr
 
     Abstract: This routine takes a list of events defining two points
	      on a circle, a radius and a select point for a circle
	      to be created, and preprocesses the data and routes the 
	      input to the appropriate math function to find the circle.
	      The order of input must be point on circle, point on circle,
	      radius and select point.
-----
%SC%

    VALUE = GRcr2ptrad_rtr(msg,events,num_events,out_geom)

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
				    - GRNOTIMPLEMENTED  if input
				 events map to a function which has
				 not been implemented yet.
				    - GRILLDEFINITION if illegal 
				 definition for placing 

     out_geom     IGRbsp_curve   output circle

     VALUE () = TRUE  - circle found
		FALSE - circle not found
     

-----
%MD%

     MODULES INVOKED:
			GRcrc2ptr
			MAct2bc

-----
%NB%

	    The order of input events must be:
		point,  point,  radius, point used to select 
	    circle returned

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
#include "igr.h"
#include "grerr.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igrdp.h"
#include "madef.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "grrouterpriv.h"
#include "ex.h"
#include "grio.h"
#include "msdef.h"

#define GRCR_TOTAL GRrt_TOTAL

extern    IGRboolean    GRcrc2ptr();
extern    IGRboolean    MAct2bc();

IGRboolean GRcr2ptrad_rtr(msg,events,num_events,out_geom)

           IGRlong             *msg;        /* return code		     */
	   struct GRrtevent    *events;     /* array of events               */
           IGRshort            *num_events; /* number of events              */
	   struct IGRbsp_curve *out_geom;   /* output line                   */

{
  IGRvector view;

  IGRdouble tol;			    /* tolerance		     */
  IGRdouble upars[2];			    /* solution u parameters	     */

  IGRlong poly;                             /* evaluated polynomial          */
  IGRlong base;				    /* base of the polynomial        */
  IGRlong power;			    /* base to the power of i        */
  IGRlong n;				    /* index			     */

  IGRshort coef;
  IGRshort event_types[GRMAX_CR_EVENTS];    /* event subtypes                */
  IGRshort num;				    /* number of events - 1	     */

  IGRint i;                               /* indexes                       */

  IGRboolean flag;			    /* return arc/circle flag	     */

                                       
  *msg = MSSUCC;

  if( *num_events == GRMAX_CR_EVENTS+1 )
    {
      num = *num_events - 1;

      for(i=0; i < num; ++i)        	    /* Process the events            */
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
      n = *num_events - 2;		    /* build the polynomial          */

      for(i=0; i < num; ++i)
	 {
	   coef = event_types[ n - i ];

           poly += coef * power;

           power *= base;
	 }	   

      flag = FALSE;			    /* indicate return circle	     */

      switch ( poly )                       /* Branch on the value of        */
      {		  		    	    /* the polynomial.               */
        case LABEL3(GRREG,GRREG,GRVL):
        {
	  GRcrc2ptr(msg,events[3].pt,events[0].pt,events[1].pt,
		    &events[2].val[0],events[0].vc,out_geom);

	  break;
        }

        case LABEL3(GRREG,CURVE(GRTT),GRVL):
        {
	  GOarcptrdcv(msg,events[0].pt,&events[2].val[0],events[1].geoms[0],
	  	      &events[1].objs[0].parms.u,events[1].pt,events[3].pt,
	  	      events[0].vc,&flag,out_geom);
 
 	  break;
        }
 
  
        case LABEL3(CURVE(GRTT),GRREG,GRVL):
        {
	  view[0] = -events[0].vc[0];
	  view[1] = -events[0].vc[1];
	  view[2] = -events[0].vc[2];

	  GOarcptrdcv(msg,events[1].pt,&events[2].val[0],events[0].geoms[0],
	  	      &events[0].objs[0].parms.u,events[0].pt,events[3].pt,
	  	      view,&flag,out_geom);

 	  break;
        }

	case LABEL3(CURVE(GRTT),CURVE(GRTT),GRVL):
        {
	  /* need to find normal from the curves instead of view normal */
	  tol = 0.00001;

 	  MAct2bc(msg,events[0].geoms[0],events[1].geoms[0],events[0].pt,
		  events[1].pt,&events[2].val[0],events[0].vc,&tol,upars,
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
      *msg = MSINARG;			    /* Too many events for 	      */
    }

  return( *msg & 1 );

}/* This has been an R.D.H. production!!! */
