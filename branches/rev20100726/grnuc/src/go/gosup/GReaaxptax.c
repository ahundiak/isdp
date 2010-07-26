/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME GReaaxptax
 
     Abstract: This is the router called by command objects for
	      constructing a partial ellipse given three events 
	      which specify the endpoint of the semi-major axis,
	      a point along the semi-major axis and the endpoint
	      of the semi-minor axis. The partial ellipse will
	      have a sweep angle of PI/2.0.

-----
%SC%

     value = GReaaxptax(msg,events,num_events,ea)

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

     ea		  IGRbsp_curve	 output partial ellipse
     
     VALUE (boolean) = {TRUE,FALSE}
                        TRUE - partial ellipse found
                        FALSE- no partial ellipse found

-----
%MD%

     MODULES INVOKED:
	             GRccschoice
		     GRprerout
-----
%NB%

     NOTES:
	    The storage for the partial ellipse must already be 
	   allocated. Allow for 7 poles, 7 weights, 10 knots.
-----
%CH%

     CHANGE HISTORY:
	
	RDH    03/27/86 : Design date.
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------
 This routine simply constructs the call list for the partial ellipse
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

extern    IGRboolean    GReaaxptax_rtr();
extern    IGRboolean    GRprerout();
extern    IGRboolean    GRccschoice();

IGRboolean GReaaxptax(msg,events,num_events,ea)

	   IGRlong             *msg;		/* return code		      */
	   struct GRevent      *events[];	/* events		      */
	   IGRshort            *num_events;	/* number of events	      */
	   struct IGRbsp_curve *ea;		/* partial ellipse	      */

{
  struct GRrtevent rtevents[GRMAX_EL_EVENTS];	/* router data structure      */

  IGRshort max_id,max_val;			/* max number of objects and  */
						/* values per ellipse  event  */
  IGRshort level;				/* Number of leveel we are    */
						/*willing to search for a sol-*/
						/*ution on extended/composites*/
  IGRshort ccw;					/* arc orientation flag       */

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

	  GRccschoice(msg,&level,rtevents,num_events,&view,&ccw,GReaaxptax_rtr,ea);
        }
    }
  else
    {
      *msg = MSINARG;
    }

  return( *msg == MSSUCC );

}/* This has been an R.D.H. production!!! */     
