// -----------------------------------------------------------------------------
//      Class    :      VLrolLine.S
//
//      Abstract :      This object represents a mark on a Struct plate usually
//                      representing the point of contact with a Struct
//                      stiffener or another plate.
//
//      History  :                              Phil WILLIAMS
//                      Updated 11-APR-1994     Marc FOURNIER
// -----------------------------------------------------------------------------

class specification VLrolLine(0:0) of VLgenLine;

#include	"godef.h"
#include	"gr.h"
#include	"igr.h"
#include	"igrdp.h"
#include	"go.h"

override	ACconstruct_feet,			// actual placement
		GRgetobjinfo;				// give type name etc

override        VDgetObjDef;

/**

Message	VLplace_rollLine

Abstract
		This is the general method to place a roll line object.
**/

message         VLplaceRollLine(
                    IGRlong		*msg; 	   // return code
		    IGRint	 	TypeSide;  // Side of plate to mark
		    IGRint		ProcessType;
		    IGRboolean		Direction; /* direction of the roll line
							along the defining 
							surface of the plate  */
		    IGRvector		shipsAxis;	/* the axis used to 
							  to define the 
							orienation of the ship's
							structure 	      */
		    IGRint		count; 		// num in list
		    struct GRobj_env	list[];		// list of objects
		    struct GRmd_env 	*md_env;	// current env
		    IGRint		*nbCrvs;
		    struct GRobj_env	Crvs[]
		    );

end specification VLrolLine;
