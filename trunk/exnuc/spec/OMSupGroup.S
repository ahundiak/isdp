						/*+public*/
class specification OMSupGroup (4:0) of Root;	/*+cldesc*/

/*
Description:
		This class implements the logical association of sets
		of groups or SuperGroups.  Its pass method will send
		a given message to the member objects of its sub-groups.
*/						/*-cldesc*/
						/*+clrev*/
/*
Revision History:

	May-26-1988	Initial release of this class.

*/						/*-clrev*/

#include 	"OMminimum.h"

instance OMSupGroup				/*+clid*/
{
variable char name[];		    /* my identifying name */
channel {(many_to_one)}	to_OSO;     /* channel to OSO */
channel {(many_to_many) OMGroup, OMSupGroup;} to_child;   /* channel to the child SupGroup/Group */
channel {(rel_ordered, many_to_many) OMSupGroup;} to_parent;  /* channel to the parent SupGroup */
};						/*-clid*/


						/*+clmsg*/
message init_OMSupGroup(char *name);
message add_member(OM_S_OBJID oid);
message remove_member(OM_S_OBJID oid);
message find(char *name; OM_p_OBJID p_oid; int search);
message pass(OM_p_MESSAGE msg; OM_p_CLASSLIST classlist; OM_E_WRT_FLAG flag);
						/*-public*/
						/*+private*/
message verGraph(OM_S_OBJID oid);
						/*-private*/
						/*-clmsg*/

end specification OMSupGroup;
