/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME GRar3pt_rtr
 
     Abstract: This routine takes a list of events defining the three
	      points of a circular arc to be created, preprocesses the
	      data and routes the input to the appropriate math function
	      to find the desired circular arc.
-----
%SC%

    VALUE = GRar3pt_rtr(msg,events,num_events,out_geom)

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     events       GRrtevent      array of events
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
				 not been implemented yet.

     out_geom     IGRbsp_curve   output circular arc

     VALUE () = TRUE  -  circular arc found
		FALSE -  circular arc not found

-----
%MD%

     MODULES INVOKED:
		     MAar3ptconstr
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
#include "grerr.h"

#define GRAR_TOTAL GRrt_TOTAL

extern    IGRboolean    GRsort_events();
extern    IGRboolean    MAar3ptconstr();
extern    IGRboolean    MAat3bc();

IGRboolean GRar3pt_rtr(msg,events,num_events,out_geom)

           IGRlong             *msg;        /* return code		     */
	   struct GRrtevent    *events;     /* array of events		     */
           IGRshort            *num_events; /* number of events              */
	   struct IGRbsp_curve *out_geom;   /* output arc		     */

{
  struct IGRplane pl;			    /* plane of arc		     */

  IGRpoint pl_point;			    /* point on plane		     */
  IGRpoint center;			    /* center of tangent arc 	     */

  IGRvector pl_normal;			    /* plane normal vector	     */

  IGRdouble pts[9];			    /* storage for 3 GRREG points    */
  IGRdouble tanpts[3];			    /* tangent point parameters	     */
  IGRdouble tol;			    /* tolerance		     */
  IGRdouble rad;			    /* radius of tangent arc	     */

  IGRlong poly;                             /* evaluated polynomial          */
  IGRlong base;				    /* base of the polynomial        */
  IGRlong power;			    /* base to the power of i        */
  IGRlong n;				    /* index			     */
  IGRlong num;				    /* number of points		     */
  IGRlong mess;				    /* return code		     */

  IGRshort coef;
  IGRshort order[GRMAX_AR_EVENTS];          /* order of events               */
  IGRshort event_types[GRMAX_AR_EVENTS];    /* event subtypes                */
  IGRshort ordered_types[GRMAX_AR_EVENTS];  /* ordered event subtypes	     */
  IGRshort total;			    /* total number of subtypes      */

  IGRint i,j;                               /* indexes                       */

                                       
  *msg = MSSUCC;

  if( *num_events == GRMAX_AR_EVENTS )    
    {
      for(i=0; i < *num_events; ++i)        /* Process the events            */
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
                   event_types[i] += GRrt_TOTAL; /* geometry                 */
                 }
             }
         }

      total = GRAR_TOTAL;		    /* sort the events		     */

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

      for(j=0; j<3; ++j)		    /* load the input points	     */
         {
           pts[j]   = events[ order[0] ].pt[j];
           pts[j+3] = events[ order[1] ].pt[j];
           pts[j+6] = events[ order[2] ].pt[j];
         }
      num = 3;

      switch ( poly )                       /* Branch on the value of        */
      {		  		    	    /* the polynomial.               */
        case LABEL3(GRREG,GRREG,GRREG):
        {

	  MAar3ptconstr(msg,pts,out_geom);

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
 	  tol = 0.000001;
 
 	  pl.point  = pl_point;
 	  pl.normal = pl_normal;
 
 	  if( MAdetplane(msg,pts,&num,&tol,&pl))
	    { 
 
 	      MAat3bc(msg,events[ 0 ].geoms[0],events[ 1 ].geoms[0],
		      events[ 2 ].geoms[0],events[ 0 ].pt,events[ 1 ].pt,
		      events[ 2 ].pt,pl_normal,&tol,tanpts,out_geom,
		      &rad,center);
 	    }

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
