/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME GRelcnaxpt
 
     Abstract: This is the router called by command objects for
	      constructing an ellipse given a center and two 
	      events which define the endpoint of the x-axis and
	      a point on the ellipse.
-----
%SC%

     value = GRelcnaxpt(msg,events,num_events,el)

-----
%EN%
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     events       GRevents	 array of pointers to events
     num_events	  IGRshort	 number of events
     
-----
%EX%

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
     msg	  IGRlong	 return code:
					MSSUCC - successful
					MSFAIL - an error occurred
					MSINARG - invalid event type

     el		  IGRbsp_curve	 output ellipse
     
     VALUE (boolean) = {TRUE,FALSE}
                        TRUE - ellipse found
                        FALSE- no ellipse found

-----
%MD%

     MODULES INVOKED:
	     	     GRccschoice
		     GRprerout

-----
%NB%

     NOTES:
	    The storage for the ellipse must already be allocated.
	   Allow for 7 poles, 7 weights, 10 knots.
            
-----

%CH%
     CHANGE HISTORY:
	
	RDH    03/27/86 : Design date.
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------
 This routine simply constructs the call list for the ellipse
router and calls GRccschoice which will process any complex object
and drive the router based on these elements (if any).

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

extern    IGRboolean    GRelcnaxpt_rtr();
extern    IGRboolean    GRprerout();
extern    IGRboolean    GRccschoice();

IGRboolean GRelcnaxpt(msg,events,num_events,el)

	   IGRlong             *msg;		/* return code		      */
	   struct GRevent      *events[];	/* events		      */
	   IGRshort            *num_events;	/* number of events	      */
	   struct IGRbsp_curve *el;		/* ellipse		      */

{
  struct GRrtevent rtevents[GRMAX_EL_EVENTS];	/* router data structure      */

  IGRshort max_id,max_val;			/* max number of objects and  */
						/* values per ellipse  event  */
  IGRshort level;				/* Number of leveel we are    */
						/*willing to search for a sol-*/
						/*ution on extended/composites*/
  IGRshort ccw;					/* arc orientation flag	      */

  IGRboolean view;				/* view information flag      */
 

  *msg = MSSUCC;

  max_id =  1;					/* max number of ids for el   */
  max_val = 0;					/* max number of vael for el  */

  if( *num_events <= GRMAX_EL_EVENTS )		/* valid number of events?    */
    {
      if( GRprerout(msg,events,num_events,&max_id,&max_val,rtevents) )
	{
	  level = 3;
	  view = FALSE;
	  ccw = 1;

	  GRccschoice(msg,&level,rtevents,num_events,&view,&ccw,GRelcnaxpt_rtr,el);
        }
    }
  else
    {
      *msg = MSINARG;
    }

  return( *msg == MSSUCC );

}/* This has been an R.D.H. production!!! */     
