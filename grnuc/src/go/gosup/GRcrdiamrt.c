/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME GRcrdiam_rtr
 
     Abstract: This routine takes a list of events defining the two
	      diameter points of a circle to be created, preprocesses 
	      the data and routes the input to the appropriate math
	      function to find the circle.
-----
%SC%

    VALUE = GRcrdiam_rtr(msg,events,num_events,out_geom)

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
				 this router or a bad event type.
				    - GRILLDEFINITION if illegal 
				 definition for placing 
				    - GRNOTIMPLEMENTED if the input
				 events map to a function which has
				 not been implemented yet.

     out_geom     IGRbsp_curve   output circle

     VALUE () = TRUE  -  circle found
		FALSE -  circle not found

-----
%MD%

     MODULES INVOKED:
		GRsort_events
		MAcrdconstr

-----
%NB%

     NOTES:
            
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
#include "grerr.h"
#include "igrtypedef.h"
#include "OMminimum.h"
#include "igetypedef.h"
#include "igr.h"
#include "igrdp.h"
#include "madef.h"
#include "godef.h"
#include "gr.h"
#include "go.h"
#include "grrouterpriv.h"
#include "msdef.h"
#include "ex.h"
#include "grio.h"

#define GRCR_TOTAL GRrt_TOTAL

extern    IGRboolean    GRsort_events();
extern    IGRboolean    MAcrdconstr();

IGRboolean GRcrdiam_rtr(msg,events,num_events,out_geom)

           IGRlong             *msg;        /* return code		     */
	   struct GRrtevent    *events;     /* array of events 		     */
           IGRshort            *num_events; /* number of events              */
	   struct IGRbsp_curve *out_geom;   /* output circle                 */

{
  IGRdouble diam_pts[6];		    /* diameter points		     */
  IGRdouble sol_u1;			    /* u par of tangent point	     */
  IGRdouble sol_u2;			    /* u par of tangent point	     */

  IGRlong poly;                             /* evaluated polynomial          */
  IGRlong base;				    /* base of the polynomial        */
  IGRlong power;			    /* base to the power of i        */
  IGRlong n;				    /* index			     */
  IGRlong mess;				    /* return code		     */

  IGRshort coef;
  IGRshort order[GRMAX_CR_EVENTS];          /* order of events               */
  IGRshort event_types[GRMAX_CR_EVENTS];    /* event subtypes                */
  IGRshort ordered_types[GRMAX_CR_EVENTS];  /* ordered event subtypes	     */
  IGRshort total;			    /* total number of subtypes      */

  IGRint i,j;                               /* indexes                       */
  IGRint center_diam_flag = 1;

                                       
  *msg = MSSUCC;

  if( *num_events <= GRMAX_CR_EVENTS )    
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
	       *msg = MSINARG;
             }
       	 }

      total = GRCR_TOTAL;		    /* sort the events		     */

      GRsort_events(&mess,event_types,num_events,&total,ordered_types,order);

      poly = 0;
      power = 1;
      base  = 2 * GRrt_TOTAL;
      n = *num_events - 1;		    /* build the polynomial          */

      for(i=0; i < *num_events; ++i)
	 {
	   coef = ordered_types[ n - i ];

           poly += coef * power;

           power *= base;
	 }	   

      switch ( poly )                       /* Branch on the value of        */
      {		  		    	    /* the polynomial.               */
        case LABEL2(GRREG,GRREG):
        {
	  for(j=0;j<3;++j)
	     {
	       diam_pts[j]   = events[0].pt[j];
	       diam_pts[j+3] = events[1].pt[j];
	     }

	  MAcrdconstr(msg,diam_pts,events[0].vc,out_geom);

	  break;
        }

        case LABEL2(GRREG,CURVE(GRTT)):
        {
	  GOcttobc(msg,events[order[1]].geoms[0],events[order[0]].pt,
		   events[order[1]].pt,&center_diam_flag,&sol_u1,out_geom);

 	  break;
        }
 
 	case LABEL2(CURVE(GRTT),CURVE(GRTT)):
 	{
	  GOcdtto2bc(msg,events[0].geoms[0],events[1].geoms[0],
		     events[0].pt,events[1].pt,&sol_u1,&sol_u2,out_geom);

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

}/* This has been an R.D.H., S.D.G. production!!! */
