// -----------------------------------------------------------------------------
//      Class    :      VLpcText.S
//
//      Abstract :	Occurences of this class defines associatively
//			the text of a profile card generate by strudel.
//
//      History  :      Created 16-MAY-1994     Ludovic Le CORVEC
//
//			25-MAY-1994 LLC : Sub-Class of VLpcAbst to inherit
//				new consume protocol.
//
// -----------------------------------------------------------------------------

class specification VLpcText(0:0) of VLpcAbst;

#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"

instance VLpcText {};

override	ACconstruct_feet,
		GRdelete,		// Delete the correponding ASCII file
                GRgetobjinfo,           // Displays the object information.
                VDgetObjDef ;           // Get Object specific information.

end specification VLpcText;


