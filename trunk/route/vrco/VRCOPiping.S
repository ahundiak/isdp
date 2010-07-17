/* ******************************************************************

Autor	: O.N (isdc)

Date 	: Apr-17-1991

Subject	:	
	

History	:
---------

	Date	+ Autor	+	Description
	========+=======+==============================================
	06 Oct 93 Manyam	Added VRSetIdManData, override 
				initial_form_notif
	12 Oct 93 Manyam	Moved VRSetIdManData, override 
				initial_form_notif to VRProduct

***********************************************************************	*/

class specification VRCOPiping (1:0) of VRCOProduct;
#include "VRlivlkup.h"

instance VRCOPiping
{ 
  /* Next four added for CR179308634 - Livelookup of parts in db */
  IGRboolean    first_entry;    /* first entry flag for livelookup     */
  IGRboolean    new_live;       /* new form for livelookup             */
  IGRboolean    proc_livelook;
  struct PipingLiveLookup OB;
};

/* local messages */
/* ************** */
/* override messages */
/* ***************** */

/* We need to override this method in order	*/
/* to set the product flag 			*/
override status_disp;

override VRFillForm;
override form_notification;
override VRDisplayMessage;

end specification VRCOPiping;

