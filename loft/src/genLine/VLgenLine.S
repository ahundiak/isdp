// -----------------------------------------------------------------------------
//      Class    :      VLgenLine.S
//
//      Abstract :	This abstract class define behavior of an associative
//			intersection between hull and graphic information.
//			The Immediate subclass are Butt, Seam and Water line.
//
//			Occurrence of this class can have different degree of
//			recompute.  The selection depend of template list.
//
//      History  :      Created 01-OCT-1992     Ludovic Le CORVEC
//                      Updated 11-APR-1994     Marc FOURNIER
// -----------------------------------------------------------------------------

class specification VLgenLine(0:0) of VLabstract;

#include "godef.h"
#include "gr.h"
#include "igr.h"
#include "igrdp.h"
#include "go.h"

instance VLgenLine
{
	short	cmpt_level;	// level of compute
};

override	ACconstruct_feet;

message	NDcheck_cmpt_level( IGRlong *msg; IGRshort count; struct GRid list[];
			struct GRmd_env *md_env; IGRshort *level; 
			IGRchar	*def_name; IGRboolean load ); 

/* --------- construct intersection -----------------------------------	*/
message ACconstruct_feet1( IGRlong *msg; IGRint cn_type;
			 IGRint count; struct GRid list [];
			 struct GRmd_env *md_env;
			 int *fcount; struct GRid  *feet_list );

/* -------- construct next at distance along surface ------------------	*/
message ACconstruct_feet2( IGRlong *msg; IGRint cn_type;
			 IGRint count; struct GRid list [];
			 struct GRmd_env *md_env;
			 int *fcount; struct GRid  *feet_list );

/* --------- construct next at min distance on vector direction -------	*/
message ACconstruct_feet3( IGRlong *msg; IGRint cn_type;
			 IGRint count; struct GRid list [];
			 struct GRmd_env *md_env;
			 int *fcount; struct GRid  *feet_list );

/* --------- construct element by intersection or by projection -------	*/
message ACconstruct_feet4( IGRlong *msg; IGRint cn_type;
			 IGRint count; struct GRid list [];
			 struct GRmd_env *md_env;
			 int *fcount; struct GRid  *feet_list );

// -------------- ACCESSOR ------------------
message VLgetLoftProps( long *props );

end specification VLgenLine;

