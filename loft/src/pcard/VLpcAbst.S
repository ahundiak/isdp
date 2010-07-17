// -----------------------------------------------------------------------------
//      Class    :      VLpcAbst
//
//      Abstract :	This class implement a new protocol for consume.
//			Element consumed will place out of the range
//			tree. The keep intact there graphic properties
//			( GRIS_DISPLAYABLE, ... ) to stay a valid model
//			for Image.
//
//      History  :      Created 25-MAY-1994     Ludovic Le CORVEC
//
// -----------------------------------------------------------------------------

class specification VLpcAbst(0:0) of VLabstract;

#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"

instance VLpcAbst {};

// Modify consume protocol
override	ACconsume,
		ACunconsume;

override	NDupdate;	// dont replace object in rtree if consumed

end specification VLpcAbst;

