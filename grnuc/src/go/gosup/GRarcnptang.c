/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME GRarcnptang
 
     Abstract: This is the router called by command objects for
	      constructing an arc given a center and two 
	      events which define the endpoint of the x-axis and
	      a point which is used to determine the sweep angle.
-----
%SC%

     value = GRarcnptang(msg,events,num_events,ccw,ar)

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

     ccw	  IGRshort	 flag for counter-clockwise orientation
     ar		  IGRbsp_curve	 output arc
     
     VALUE (boolean) = {TRUE,FALSE}
                        TRUE - arc found
                        FALSE- no arc found

-----
%MD%

     MODULES INVOKED:
	     		GRccschoice
			GRprerout
-----
%NB%

     NOTES:
	    The storage for the arc must already be allocated.
	   Allow for 7 poles, 7 weights, 10 knots.

	    The order of events must be:
		center, endpoint of x-axis, point defining angle or angle
-----

%CH%
     CHANGE HISTORY:
	
	RDH    03/27/86 : Design date.
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------
 This routine simply constructs the call list for the arc
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



extern    IGRboolean    GRarcnptang_rtr();
extern    IGRboolean    GRprerout();
extern    IGRboolean    GRccschoice();
 
IGRboolean GRarcnptang(msg,events,num_events,ccw,ar)

	   IGRlong             *msg;		/* return code		      */
	   struct GRevent      *events[];	/* events		      */
	   IGRshort            *num_events;	/* number of events	      */
	   IGRshort	       *ccw;		/* flag for orientation of ar */
	   struct IGRbsp_curve *ar;		/* arc			      */

{
  struct GRrtevent rtevents[GRMAX_AR_EVENTS];	/* router data structure      */

  IGRshort max_id,max_val;			/* max number of objects and  */
						/* values per ellipse  event  */
  IGRshort level;				/* Number of leveel we are    */
						/*willing to search for a sol-*/
						/*ution on extended/composites*/

  IGRboolean view;				/* view information flag      */

  *msg = MSSUCC;

  max_id =  1;					/* max number of ids for ar   */
  max_val = 1;					/* max number of val for ar   */

  if( *num_events <= GRMAX_AR_EVENTS )		/* valid number of events?    */
    {
      if( GRprerout(msg,events,num_events,&max_id,&max_val,rtevents) )
	{
	  level = 3;
	  view = TRUE;

	  GRccschoice(msg,&level,rtevents,num_events,&view,ccw,GRarcnptang_rtr,ar);
        }
    }
  else
    {
      *msg = MSINARG;
    }

  return( *msg == MSSUCC );

}/* This has been an R.D.H. production!!! */     
