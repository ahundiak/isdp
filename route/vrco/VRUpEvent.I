/*~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

 VRUpdateEvent function
 
 CHANGE HISTORY:  momo 22-11-1989 : Design date


 DESCRIPTION  : update event and LastPoint in the DPB

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~*/

class implementation VRPlHanger;

#include "igetypedef.h"
#include "igrtypedef.h"
#include "grdpbdef.h"
#include "grdpbmacros.h"
#include "comiscmac.h"
#include "igr.h"
#include "griodef.h"
#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"
#include "exdef.h"
#include "exmacros.h"
#include "ex.h"
#include "grio.h"
#include "AS_status.h"

#define	AS_DEBUG

IGRint VRUpdateEvent(  sts , Point , Event )
IGRlong	 	*sts;
IGRdouble 	*Point;
struct GRevent 	*Event;

{
  IGRlong		status;
  IGRlong  		Size = sizeof( struct EX_button ),
                	ReturnSize; /* both of these are used for DPB last   */
                                    /* point retrieval                       */
  struct EX_button	LastPoint;  /* from DPB                              */

  *sts   = MSSUCC;

  /* 
   * We need reliable window information from the last point
   */
  gr$get_last_point(  msg    = sts,
                      sizbuf = &Size,
                      buffer = &LastPoint,
                      nret   = &ReturnSize );

  /*| update the last point in the DPB */
  LastPoint.x = Point [0];
  LastPoint.y = Point [1];
  LastPoint.z = Point [2];

  status =  gr$put_last_point( 	msg = sts,
				sizbuf	= &Size,
				buffer	= ( IGRchar * ) &LastPoint );
  as$status( action = RET_STATUS );

  /* 
   *  Override the subtype and stuff the last end point coordinates
   *  into event1
  */

  Size = ( sizeof( struct GRevent ) - ( 2 * sizeof( IGRint ) ) );
  status = co$build_event( msg          = sts,
                           event_nbytes = Size,
                           event        = Event,
                           button       = &LastPoint  );
  as$status( action = RET_STATUS );
  
  return(OM_S_SUCCESS);
}

end implementation VRPlHanger;

