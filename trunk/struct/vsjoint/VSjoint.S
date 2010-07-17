/* $Id: VSjoint.S,v 1.1.1.1 2001/01/04 21:10:48 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	struct/vsjoint/VSjoint.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSjoint.S,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:48  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.6  1998/04/02  10:40:10  pinnacle
# Replaced: vsjoint/VSjoint.S for:  by svkadamb for struct
#
# Revision 1.5  1998/01/02  11:59:08  pinnacle
# Replaced: vsjoint/VSjoint.S for:  by svkadamb for struct
#
# Revision 1.4  1997/12/15  22:37:06  pinnacle
# VDGetCenterLine
#
# Revision 1.3  1997/11/21  04:32:52  pinnacle
# Replaced: vsjoint/VSjoint.S for:  by svkadamb for struct
#
# Revision 1.2  1997/11/14  13:19:12  pinnacle
# Replaced: vsjoint/VSjoint.S for:  by svkadamb for struct
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			suresh		modification 
 *    12/14/97       	ah              Override VDSroot.VDGetCenterline
 *	01/02/98	suresh		Override VSpre_construct,
						 VSfindCollection and added 
					 	 method VSgetCollectorId.
 ***************************************************************************/
/*
	I/STRUCT
*/ 
class specification VSjoint(0:0) of VSfeature, GRlistener ;

/*+c
	Abstract class for all types of joints between beam and plates.
-c*/

#ifndef OM_D_MACROS
#	include "OMmacros.h"
#endif
#ifndef vs_include
#	include "vs.h"
#endif
#include "vsweld.h"
#include "vsjointdef.h"
#include "vsjoint.h"

override
		VDGetCenterLine,
		GRnotifylis,
		ACconstruct_feet,
		ACgive_structure,
		VSgetObjDef,
/*
 * We do not place joints between joints, so the following messages are
 * irrelevant, they either do nothing or return that there are no joints.
 */
		VSputJoint,
		VSgetJoints,
		VSputModJoints,
		VSputDivJoints,
		VSdescribeOutput,
		VSfindCollection,
		VSpre_construct,
		VSgetMassProperties ;

from VSfeature inherit
		ACset_db_info,
		ACget_db_info,
		ACcheckin_candidate;
from ACncpx inherit
		delete ;
/*+d
	return either a butt weld or a fillet weld
-d*/
message VSgetJointType( long                    *msg ;
                        struct GRobj_env        feature0 ;
                        struct GRobj_env        feature1 ;
			int			*weldType );

message VSgetplplweldtype( long			*msg;
			   struct GRobj_env	plates[2];
			   int			*weldType );
/*+d
Message VScstPlPlJoint

Abstract
	Construct the graphics representing the joints between two plates.
	The graphics are bundled together in a group.
Arguments
	OUT	long			*msg		Completion code.
	IN	struct GRobj_env	plates[2]	Plates to join.
	IN	VSdspRep		myRep		My display rep.
	IN	struct GRvg_construct	*cst		Construction list for
							graphics.
	OUT	struct GRid		*grJoin		Group of graphics
							representing join.
-d*/
message VScstPlPlJoint(	long			*msg ;
			struct GRobj_env	plates[2] ;
			VSdspRep		myRep ;
			struct GRvg_construct	*cst ;
			int			weldSide ;
			struct GRid		*grJoint ) ;

/*+d
Message VScstBmBmJoint

Abstract
	Construct the graphics representing the joints between two beams.
	The graphics are bundled together in a group.
Arguments
	OUT	long			*msg		Completion code.
	IN	struct GRobj_env	beams[2]	Beams to join.
	IN	VSdspRep		myRep		My display rep.
	IN	struct GRvg_construct	*cst		Construction list for
							graphics.
	OUT	struct GRid		*grJoin		Group of graphics
							representing join.
-d*/
message VScstBmBmJoint(	long			*msg ;
			struct GRobj_env	beams[2] ;
			VSdspRep		myRep ;
			struct GRvg_construct	*cst ;
			int			weldSide ;
			struct GRid		*grJoint ) ;

/*+d
Message VScstPlBmJoint

Abstract
	Construct the graphics representing the joints between a plate and a
	beam.
	The graphics are bundled together in a group.
Arguments
	OUT	long			*msg		Completion code.
	IN	struct GRobj_env	elements[2]	Elements to join.
	IN	VSdspRep		myRep		My display rep.
	IN	struct GRvg_construct	*cst		Construction list for
							graphics.
	IN	int			jType		Junction type.
	OUT	struct GRid		*grJoin		Group of graphics
							representing join.
Note
	`jType' must be one of the following :
 - VS_K_J_PL_BM	: plate-beam
 - VS_K_J_BM_PL : beam-plate (functionally equivalent to plate-beam)
 - VS_K_J_ST_TP : stiffener with its support plate, stiffener being on top.
 - VS_K_J_ST_BT : stiffener with its support plate, stiffener being on bottom.
 - VS_K_J_TP_ST : same as VS_K_J_ST_TP but plate-stiffener.
 - VS_K_J_BT_ST : same as VS_K_J_ST_BT but plate-stiffener.

 	All #define'd in vsjointdef.h
 
 	`jType' is obtained by the macro `vs$getJunctionType', #define'd in
 	vsjntmacros.h
-d*/
message VScstPlBmJoint(	long			*msg ;
			struct GRobj_env	elements[2] ;
			VSdspRep		myRep ;
			struct GRvg_construct	*cst ;
			int			jType ;
			int			weldSide ;
			struct GRid		*grJoint ) ;

/*+d
Message VSgetJoinedFeatures

Abstract
	Returns the two features joined by joint, and optionally the parent
	joint from where this joints gets its data (if any).
Arguments
	OUT	long			*msg		Completion code.
	OUT	struct GRobj_env	*feature0	First feature.
	OUT	struct GRobj_env	*feature1	Second feature.
	OUT	struct GRobj_env	*parentJoint	Parent joint (if any).
Note
	`parentJoint' may be set to NULL if not needed. If `parentJoint' is
	not NULL but there is no parent joint, then `parentJoint->_objid' will
	be NULL_OBJID.
-d*/
message VSgetJoinedFeatures(	long			*msg ;
				struct GRobj_env	*feature0,
							*feature1,
							*parentJoint ) ;
/*+d
Message VSgetCollectionId
 
Abstract
	Retrieves a collection associated with the joint object. There is 
	always one or two collections associated with a VSjoint:
		- private attributes            Name: VS_K_prPrvAttr
		- user attributes (optional)    Name: VS_K_prUsrAttr
Arguments
	OUT     long            *msg    Completion code (failure if !found).
	IN      char            *name   Name of collection.
	OUT     struct GRid     *coll   Id of collection.
-d*/
message VSgetCollectionId( long *msg ; char *name ; struct GRid *coll ) ;

override 

/*+o
Message VDget_prefix_name

Abstract
	Returns the real name of the joint which is :
		<name of first feature>-<name of second feature>-J
Arguments
	See message VDget_prefix_name of class VDSroot.
-o*/
	VDget_prefix_name,
	
/*+o
Message VDget_trans_table_entries

Abstract
	Returns the first joined feature as main root and 'joint' as command 
	name.
Arguments
	See message VDget_trans_table_entries of class VDSroot.
-o*/
	VDget_trans_table_entries ;

end specification VSjoint ;

