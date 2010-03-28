/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME GRcrcnrad
 
     Abstract: This is the router called by command objects for
	      constructing a circle given two events which define 
	      the center and radius of the circle.
-----
%SC%

     value = GRcrcnrad(msg,events,num_events,cr)

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

     cr		  IGRbsp_curve	 output circle
     
     VALUE (boolean) = {TRUE,FALSE}
                        TRUE - circle found
                        FALSE- no circle found

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

	    The order of inputs must be:
		center point, radius point or radius value
-----
%CH%

     CHANGE HISTORY:
	
	RDH    03/27/86 : Design date.
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------
 This routine simply constructs the call list for the circle
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

extern    IGRboolean    GRcrcnrad_rtr();
extern    IGRboolean    GRprerout();
extern    IGRboolean    GRccschoice();

IGRboolean GRcrcnrad(msg,events,num_events,cr)

	   IGRlong             *msg;		/* return code		      */
	   struct GRevent      *events[];	/* events		      */
	   IGRshort            *num_events;	/* number of events	      */
	   struct IGRbsp_curve *cr;		/* circle		      */

{
  struct GRrtevent rtevents[GRMAX_CR_EVENTS];	/* router data structure      */

  IGRshort max_id,max_val;			/* max number of objects and  */
						/* values per ellipse  event  */
  IGRshort level;				/* Number of leveel we are    */
						/*willing to search for a sol-*/
						/*ution on extended/composites*/
  IGRshort ccw;					/* arc orientation flag       */

  IGRboolean view;				/* view information flag      */


  *msg = MSSUCC;

  max_id =  1;					/* max number of ids for cr   */
  max_val = 1;					/* max number of vael for cr  */

  if( *num_events <= GRMAX_CR_EVENTS )		/* valid number of events?    */
    {
      if( GRprerout(msg,events,num_events,&max_id,&max_val,rtevents) )
	{
	  level = 3;
	  view = TRUE;
	  ccw = 1;

	  GRccschoice(msg,&level,rtevents,num_events,&view,&ccw,GRcrcnrad_rtr,cr);
        }
    }
  else
    {
      *msg = MSINARG;
    }

  return( *msg == MSSUCC );

}/* This has been an R.D.H. production!!! */     
