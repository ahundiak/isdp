/*
	I/STRUCT
*/
class specification VSdivJoint(0:0) of VSjoint, VSdivFeature ;

override

/*+o
Message GRconstruct

Abstract
	Constructs a join-division manager.
Arguments
	See message GRconstruct of class GRvg.
Note
	The construction list must be filled as follows:

	struct GRobj_env	parentJoint,
				divFeature,
				otherFeature ;
	struct GRvg_construct	cst ;
	struct VScnst_list	vsargs ;
	VSpartAttr		part ;
	VSjointAttr		attr ;
	VSdivArgs		dvargs ;
	VSsubJointInfo		jnInfo ;

	cst.env_info		= <mod. env. of object to construct>
	cst.display		= NULL ; <no display>
	cst.level		= 0 ; <level unused>
	cst.class_attr		= (char *) &vsrags ;
	vsargs.parent_list	= &parentJoint ; <parent of object>
	vsargs.parent_count	= 1 ;		 <count of parents>
	vsargs.representation	= AC_NO_REP ;	 <unused>
	vsargs.feature_att	= (char *) &dvargs ; <division arguments>
	dvargs.subFeatureAttr	= (char *) &part ;   <sub-joints' attr>
	dvargs.subFeatureClassid= OPP_VSsubJoint_class_id ; <sub-joints' class>
	dvargs.divInfo		= (void *) &jnInfo ;	<sub-joint information>
	jnInfo.divFeature	= &divFeature ;		<divided feature>	
	jnInfo.otherFeature	= &otherFeature ;	<other feature>
	jnInfo.dir		= <directory for sub-joint's names> 

	- `part' and `attr' must be filled as for a VSsrcJoint, actually one
	can fill this structure by sending a GRgetattr message to `parentJoin'

	- `parentJoin' is the join J which was between some feature F and
	another feature G (G is `otherFeature'):

		F ---- J ---- G

	F has undergone a division operation managed by a divided feature DF
	( DF is `divFeature' ) which resulted in several sub-features SF1, SF2
	... :

		F ==division==> F ----> DF ----> SF1, SF2 ...

	The old joint J is no longer valid and must now be replaced by joints
	( called sub-joints ) SJ1, SJ2 ... joining G to SF1, SF2 ... :

		SF1 ----- SJ1 ---- G
		SF2 ----- SJ2 ---- G

	Those sub-joints will be managed by a divided joint (this here class)
	DJ which will supervise their behaviors, this divided joint depends upon
	the old joint J. It will in its construct methods also generate the
	sub-joints SJ1, SJ2 ... between G and SF1, SF2 ... (It will retrieve
	SF1, SF2 via DF ).

	Hence the whole situation is summed up in the following 3 steps :

	1)	F ---- J ---- G			Initial state

	2)	F ---- J ---- G			Division of F
		|				(F and DF invisible)
		DF
		|
		+-------+ ...
		|	|
		SF1	SF2

	3)	F ------------- J ----- G	Division of J
		|		|	|	Creation of SJ1, depending on
		DF		DJ	|	DJ, SF1, G
		|		|	|	(Same diagram for SJ2 depending
		+-------+ ...	+	|	on DJ, SF2, G, not shown here)
		|	|	|	|
		SF1	SF2	|	|	(J and DJ invisible)
		|		|	|
		+-------------- | -+	|
				|  |	|
				+-------+
				    |
				    SJ1
-o*/
	GRconstruct,
	VSgetObjDef,
	ACconstruct_feet ;

from ACncpx  inherit
		NDget_virtual_objects ;
from VSjoint inherit
		ACset_db_info,
		ACget_db_info,
		ACcheckin_candidate,
		ACreturn_foot,
		ACgive_path,
		ACgive_structure,
		VSgetMassProperties,
		VSdescribeOutput,
		VSputJoint,
		VSgetJoints,
		VSputModJoints ;
		
reject VDget_prefix_name,
       VDget_trans_table_entries ;

end specification VSdivJoint ;
