						/*+public*/
class specification OMGroup (4:0) of Root;	/*+cldesc*/

/*
Description:
		This class implements the logical association
		of sets of objects.  Its pass method will send
		a given message to its member objects.
*/						/*-cldesc*/
						/*+clrev*/
/*
Revision History:

	31-jul-1986	Initial release of this class.

*/						/*-clrev*/

#include 	"OMminimum.h"

instance OMGroup				/*+clid*/
{

OM_S_OBJID 	groupid;  	/* my identifying number == my objid */
char       	name[OM_K_MAXGROUPNAME_LEN ];  /* my identifying name */
OMuword		clusternum;	/* associated cluster id number */
OMuint     	size;		/* total size */
OMuint		initial_size;	/* initial number of oids in group */
OMuint     	extend_size;	/* amount to extend spacemap by */
OM_S_OBJID      next_avail;     /* next free objid */
channel {(many_to_one)}	to_OSO; /* channel to OSO */
channel {(rel_ordered, many_to_many) OMSupGroup;} to_parent; /* channel to SupGroup */
variable OM_S_GROUP_EXTENT extent[1];
};						/*-clid*/

override delete, debug;				/*+clover*/
						/*-clover*/
						/*+clmsg*/
message init_spacemap(OMuint extend_size; OMuint init_size;
	     OM_S_OBJID oid; OMbyte ostype; OMuint init_flag);
message get_oid(OM_p_OBJID oid; OM_p_NEIGHBOR p_neighbor);
message my_name(char *name; OM_p_OBJID p_groupoid);
message my_oid(OM_S_OBJID oid; OM_p_OBJID p_groupoid);
message mergeinto(OM_p_VARLENARR_DESCR frextd; OMuint frextsz, frtotsz);
message pass(OM_p_MESSAGE msg; OM_p_CLASSLIST classlist;
		OM_E_WRT_FLAG flag);

message init_OMGroup(char *groupname; int init_count,
		     extend_count; OMuword clusternum);
message remove();
message merge(OM_S_OBJID groupoid);
						/*-clmsg*/

end specification OMGroup;			/*-public*/
