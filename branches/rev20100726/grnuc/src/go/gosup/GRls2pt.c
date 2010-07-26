/* #######################    APOGEE COMPILED   ######################## */
/*----
%GP% CODE CLASSIFICATION                           
----
%HD%
 
     MODULE NAME GRls2pt
 
     Abstract: This is the router called by command objects for
	      constructing a line segment from two events.
-----
%SC%

     value = GRls2pt(msg,events,num_events,ls)

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

     ls		  IGRbsp_curve	 output line segment
     
     VALUE (boolean) = {TRUE,FALSE}
                        TRUE - line segment found
                        FALSE- no line segment found

-----
%MD%

     MODULES INVOKED:
	     	     GRccschoice
		     GRprerout
-----
%NB%

     NOTES:
	    The storage for the line segment must already be allocated.
	   Allow for 2 poles and 4  knots.
-----

%CH%
     CHANGE HISTORY:
	
	RDH    03/27/86 : Design date.
-----
%PD%
--------------------------------------------------------------------
              P R O G R A M    D E S C R I P T I O N
--------------------------------------------------------------------
 This routine simply constructs the call list for the line segment
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

extern    IGRboolean    GRls2pt_rtr();
extern    IGRboolean    GRprerout();
extern    IGRboolean    GRccschoice();

IGRboolean GRls2pt(msg,events,num_events,ls)

	   IGRlong             *msg;		/* return code		     */
	   struct GRevent      *events[];	/* events		     */
	   IGRshort            *num_events;	/* number of events	     */
	   struct IGRbsp_curve *ls;		/* line segment		     */

{
  struct GRrtevent rtevents[GRMAX_LS_EVENTS];	/* router data structure     */

  IGRshort max_id,max_val;			/* max number of objects and */
						/* values per line seg event */
  IGRshort level;				/* Number of levels we are   */
						/*willing to search for a sol*/
 						/*ution on extended/composite*/
  IGRshort ccw;					/* arc orientation flag	     */

  IGRboolean view;				/* view information flag     */


  *msg = MSSUCC;

  max_id =  1;					/* max number of ids for ls  */
  max_val = 1;					/* max number of vals for ls */

  if( *num_events <= GRMAX_LS_EVENTS )		/* valid number of events?   */
    {
      if( GRprerout(msg,events,num_events,&max_id,&max_val,rtevents) )
	{
	  level = 2;
	  view = TRUE;
	  ccw = 1;

	  GRccschoice(msg,&level,rtevents,num_events,&view,&ccw,GRls2pt_rtr,
		      ls);
        }
    }
  else
    {
      *msg = MSINARG;
    }

  return( *msg == MSSUCC );

}/* This has been an R.D.H. production!!! */     
