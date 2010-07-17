/*
	I/STRUCT
*/
class specification VSmodPlate(0:0) of VSplate, VSmodFeature ;

/*+c
	Abstract class for a modified plate, ie. a plate which is the RESULT
	of an OPERATION performed on another plate.
-c*/

/*+d
Message VSforceParentRep

Abstract
	Forces parent representation to change to the one desired.
Arguments
	OUT	long		*msg		Completion code.
	IN	struct GRmd_env	*myEnv		My module environment.
	IN	struct GRid	*parentId	Id of parent.
	IN	VSdspRep	badRep1		Mask indicating 1st not wanted
						reps.
	IN	VSdspRep	badRep2		Mask indicating 2nd not wanted
						reps.
	IN	VSdspRep	repToSet1	Rep that parent must take if
						is rep is in bad rep 1.
	IN	VSdspRep	repToSet2	Rep that parent must take if
						is rep is in bad rep 2.
	OUT	VSdspRep	*oldRep		Rep of parent before change.
-d*/
message VSforceParentRep(	long		*msg ;
				struct GRmd_env	*myEnv ;
				struct GRid	*parentId ;
				VSdspRep	badRep1,
						badRep2,
						repToSet1,
						repToSet2,
						*oldRep ) ;

from VSplate inherit	GRdetplane,
			NDdrawing_copy_geom,
			ACreturn_foot,
			ACgive_path,
			ACgive_structure,
			VSdescribeOutput,
			VSshowOrientation,
			VSgetMassProperties,
			VStransIPATHToName,
			VStransNameToIPATH,
			VScreateFrozenCopy,
			VSgetSupportedElements,
			VDget_prefix_name ;

end specification VSmodPlate ;

