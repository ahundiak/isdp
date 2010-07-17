// -----------------------------------------------------------------------------
//      Class    :      VLmrkLine.S
//
//      Abstract :      This object represents a mark on a Struct plate usually
//			representing the point of contact with a Struct
//			stiffener or another plate.
//
//      History  :      			Phil WILLIAMS
//                      Updated 11-APR-1994     Marc FOURNIER
//			Dec.		1994	PW
//			Rewritten due to intersection problems with
//			curved plates and stiffeners.
//
// -----------------------------------------------------------------------------

class specification VLmrkLine(0:0) of VLgenLine ;

#include	"godef.h"
#include	"gr.h"
#include	"igr.h"
#include	"igrdp.h"
#include	"go.h"

override	ACconstruct_feet,			/* actual placement  **/
		GRgetobjinfo;				/* give type name etc**/

override        VDgetObjDef;

/**

	PUBLIC Message	VLplace_mark

Abstract
	This is the public interface to this object for placement.  It expects
	TypeSide to say which side of plate to mark in the case of a plate to
	plate intersection and IntsTypeSide to specify which side of the 2nd
	plate defines the mark.  For the case of a plate to stiffener TypeSide
	isn't used, as this information is already available from the stiffener
	and IntsTypeSide defines which side of the stiffener to use 
	ie 0 => closest to axis, 1 => farthest from axis.

	List should comprise of the first entry being the plate to mark and the
	second being the object (stiffener or plate) defining the mark on this
	plate. All objects in list should be supplied with their context.

**/

message         VLplace_mark(
                    IGRlong		*msg; 		/* return code       **/
		    int		 	TypeSide;       /* Side of plate to mark
							*/
		    int			IntsTypeSide;  /* Side of defining plate
							or relation to stiffn
							ie take nearest or 
							farthest edge to axis*/
		    IGRint		count; 		/* num in list	      */
		    struct GRobj_env	list[];		/* list of objects    */
		    struct GRmd_env 	*md_env		/* current env	      */
		    );

/****
	Abstract:
		PUBLIC Message:		WhichSide
		Just a simple message to tell any enquirers which side
		of the plate this particular mark is attached to.
		The value returned follows the I/STRUCT convention for sides
		of a plate ie VS_K_baOnBotOfPlate | VS_K_baOnTopOfPlate
*****/

message		WhichSide(
				int * TypeSide 
			 );


end specification VLmrkLine;
