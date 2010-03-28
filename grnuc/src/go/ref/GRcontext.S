/*
Abstract
	The class GRcontext is a subclass of Root and represents
	the context for representing objects in a specified 
	reference file in the master file.
Notes
	None
History	
	MAS	05/18/87:   Creation date.

*/


class specification GRcontext (1:1) of Root;

#include "OMminimum.h"
#include "OMindex.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "igr.h"
#include "ref.h"
#include "OMerrordef.h"
#include "gr.h"

taggable;

instance  GRcontext
{
    channel {(many_to_one,initial=1,increment=1)
		Super_rfmgr.to_context;} to_super;

    channel {(many_to_one,initial=1,increment=1)GRreffile;} to_reffile;

    channel {(many_to_many,initial=1,increment=1)} to_misc;

    channel {(many_to_many,rel_ordered,initial=1,increment=1)
		GRcontext.to_nested_files;} to_nested_files;

    IGRshort	mx_type;	/* type of environment matrix	*/
    IGRmatrix	matrix;		/* environment matrix		*/
    IGRshort	flags;		/* special indicator flags	*/
    GRspacenum  osnum;

};


message GRcheckcriteria(IGRlong *msg; IGRlong  *levels; 
	IGRlong *locate_attributes; IGRlong *new_levels);
/*     
Abstract: 	
	This method is for use by name locate to determine if a
	named object in a reference files passes the locate criteria
	acquired from the reference file.

Arguments

     *msg	   IGRlong   O	  completion code
     *levels	   IGRlong   I	  level array for comparision
     *locate_attributes
		   IGRlong   I	  the locate attributes mask, the
				  checks that are done are:
					Displayable
					Locatable
					Read / Write
     *new_levels   IGRlong   O	  new levels for locate to pass to 
				  the object
     					
Return Values
    - MSSUCC if successful and object passes all checks
    - GRINVOBJECT object does not pass
*/


message GRgetmodule_env(IGRlong *msg; struct GRmd_env *env);

/*     
Abstract: 	

	This method returns the environment information for objects
	in the reference file space represented by this context 
	object.

Arguments
     *msg	   IGRlong      O  completion code
     *env	struct GRmd_env	O  module environment structure
     					
Return Values
    - MSSUCC if successful 
    - MSFAIL if error
*/

message GRchkconnection(IGRlong *msg; struct GRid *graphics_oid;
	struct GRid *context_id);


/*
 * THE FOLLOWING METHODS ARE PRIVATE MESSAGES AND SHOULD NOT 
 * BE USED BY APPLICATIONS
 */

message GRloadctx(IGRlong *msg; IGRshort *mx_type;
	IGRmatrix matrix; GRspacenum *osnum; IGRshort *flag);

message GRconsemptyctx(IGRlong *msg);

message GRputosnum(IGRlong *msg; GRspacenum *osnum);

message GRcheckctx(IGRlong *msg; IGRshort *mx_type;
	IGRmatrix matrix; GRspacenum *osnum; 
	struct GRid *context_id; IGRboolean *same);

message GRdeletectx(IGRlong *msg; struct GRmd_env *env);

message GRupdatectx(IGRlong *msg; IGRshort *mx_type;
	IGRmatrix matrix);

message GRgetinstance(IGRlong *msg; IGRshort *mx_type;
	IGRmatrix matrix; GRspacenum *osnum; 
	IGRshort *flag; struct GRid *context_id);


message GRcopyctx(IGRlong *msg; struct GRmd_env *new_env; 
	struct GRid *reffile_id; struct GRid *new_context_id);

message GRgetflag(IGRlong *msg; IGRshort *flag);

message GRchgflag(IGRlong *msg; IGRshort *action; IGRshort *flag);

message GRpasscheck(IGRlong *msg; IGRboolean *reached_root;
	IGRlong *levels; IGRlong *criteria; IGRlong *new_levels);

message GRrefcheck(IGRlong *msg; GRspacenum *super_osnum;
	IGRmatrix ref_to_master_matrix; struct GRid *context_id; 
	IGRboolean *same);

message GRgetosnum(IGRlong *msg; GRspacenum *osnum);

message GRregenerate(IGRlong *msg; struct GRmdenv_info *env_info; 
	 IGRint	*change_flag; struct GRid *context_id);

message GRnotifymisc(IGRlong *msg );

override debug;

end specification GRcontext;
