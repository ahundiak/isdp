// -----------------------------------------------------------------------------
//      Class    :      VLpcView.S
//
//      Abstract :	Occurences of this class maintain the associative 
//			relation between an Object and its Query-context 
//			Interpreted with Strudel. The selection of Strudel 
//			code depends on the view-name;
//
//      History  :      Created 04-MAY-1994     Ludovic Le CORVEC
//
//			25-MAY-1994 LLC : Sub-Class of VLpcAbst to inherit
//				new consume protocol.
//
// -----------------------------------------------------------------------------

class specification VLpcView(0:0) of VLpcAbst;

#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"

instance VLpcView {};

override	ACconstruct_feet,
		GRgetobjinfo,           // Displays the object information.
		VDgetObjDef ;		// Get Object specific information.

end specification VLpcView;

