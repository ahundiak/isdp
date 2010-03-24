								/*+public*/
class	specification	OMFiledOS (4:0) of OMObjSpace,OMCluster; /*+cldesc*/

/*

Description:
	This class is used for filed object spaces. Creation of an object
	of this class implies that you will create a file or read an
	existing file with data in it. This 'instance' is actually the 
	OSO, or Object Space Object. Messages on this class allow writing
	of data. The 'name' of the object space becomes the filename.


*/
				    				/*-cldesc*/
/*
Revision History:

	25-aug-86  pre-release version.

*/
								/*-public*/
extern	OMuint			OM_Gi_filedOS_size;
extern	int			OM_Gi_filedOS_extsize;
extern	OMuint			OM_Gi_filedOS_numobjs;
extern	int			OM_Gi_filedOS_extobjs;
extern	OMuword			OM_Gw_major_version;
extern	OMuword			OM_Gw_minor_version;
extern	OMuword			OM_Gw_oid_type;
extern	OMuword			OM_Gw_opsys;
extern	OMuword			OM_Gw_machine_type;
extern	OMuword			OM_Gw_min_opp_major_version;
extern	OMuword			OM_Gw_last_opp_minor_version;
extern	int			OM_Gi_number_of_defns;
								/*+public*/
								/*+clincs*/
#include 	<stdio.h>
#include 	"OMOSfilehdr.h"
								/*-clincs*/
								/*+clid*/
/* OMFiledOS -- there is no instance data defined on this class.
/* the OSO is inherited from OMObjspace, the cluster 0 portion
/* is inherited from OMCluster.
*/
								/*-clid*/
								/*+clover*/
override	debug, delete;
								/*-clover*/
								/*+clmsg*/

message		write		(char *osname);
message		set_state	(int state_flag);
								/*-public*/
								/*+private*/

message		get_freelist_ptr(OM_S_OSHOLE **freelist);
message		init		();
								/*-clmsg*/
								/*-private*/


end	specification	OMFiledOS;

					
