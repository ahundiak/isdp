/* $Id: VSbeam.S,v 1.1.1.1 2001/01/04 21:10:11 cvs Exp $  */
 
/***************************************************************************
 * I/STRUCT
 *
 * File:        struct/vsbeam/VSbeam.S
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSbeam.S,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:11  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.4  1998/04/20  14:28:52  pinnacle
# TR179801020
#
# Revision 1.3  1997/12/15  22:18:58  pinnacle
# CenterLine
#
# Revision 1.2  1997/10/06  09:01:24  pinnacle
# Replaced: vsbeam/VSbeam.S for:  by svkadamb for struct
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 *           suresh  modification
 * 12/14/97  ah      Override VDSroot.VDGetCenterLine
 * 04/20/98  ah      TR179801020 Moved GetCenterline to VSfeature since VSsubBeam
 *                   was not getting the message
 ***************************************************************************/
/*
	I/STRUCT
*/ 
class specification VSbeam(0:0) of VSfeature ;

#include "OMmacros.h"
#include "vs.h"
#include "vsbeamdef.h"
#include "vssectiondef.h"
#include "vsbeam.h"

/*+c
	Abstract class for all types of beams.
-c*/

// override  VDGetCenterLine; // TR179801020

override	VStransNameToIPATH,
		VStransIPATHToName,
/*+o
Message VSgetSupports

Abstract
	Returns the axis and surface with which a beam was built.
Arguments
	See message VSgetSupports of class VSpart.
Note
	Only use this message if you need the surface (#0) and the axis (#1),
	if you only need one of them, use messages VSbeam.VSgetSupportSf and
	VSbeam.VSgetSupportAxis: sometimes an axis or a support surface has
	to be generated on the fly, not creating unneeded objects will reduce
	the overhead.
-o*/
		VSgetSupports,
		VSgetObjDef,
		VSshowOrientation,
		VSgetMassProperties,
		VScreateFrozenCopy,
		VSdescribeOutput,
		ACgive_db_structure,
		ACadd_to_list_1,

/*+o
Message ACgive_structure

Abstract
	Queries the object for data to feed the Relational Data Base in
	connection with I/STRUCT. May use same message defined in ancestor
	classes.
Arguments
	See message ACgive_structure of class NDmacro.
-o*/
		ACgive_structure,

/*+o
Message VDget_prefix_name

Abstract
	Returns 'B' as prefix and FALSE for 'real_name'.
Arguments
	See message VDget_prefix_name of class VDSroot.
-o*/
		VDget_prefix_name ;


/*+d
Message VSgetsolidbeam

Abstract
	Constructs the solid beam in filleted representation. If fails in
	filleted representation then constructs the beam in 3D rep.
	The message must sent to an already existing beam for getting its
	solid in filleted representation.

	The caller must delete the solidBeam once its use is completed.

Arguments
	OUT	long			*msg		Completion code.
	IN	struct GRmd_env		*bmEnv		beam environment.
	OUT	struct GRid		*solidBeam	Solid rep. object.
-d*/

message VSgetSolidBeam ( IGRlong                        *msg ;
                         struct GRmd_env                *bmEnv ;
                         struct GRid                    *solidBeam ) ;

reject VSgetSolidBeam ;


/*+d
Message VSgetSupportAxis

Abstract
	Returns the curve from which a beam was built.
Arguments
	IN	long		 *msg		Completion code.
	IN	struct GRmd_env	 *myEnv		Environment of target beam.
	OUT	struct GRobj_env *axis		Id and mod. env. of axis.
-d*/
message VSgetSupportAxis(	long			*msg ;
				struct GRmd_env		*myEnv ;
				struct GRobj_env	*axis ) ;
reject VSgetSupportAxis ;

/*+d
Message VSgetSupportSf

Abstract
	Returns the surface on which a beam was built.
Arguments
	IN	long		 *msg		Completion code.
	IN	struct GRmd_env	 *myEnv		Environment of target beam.
	OUT	struct GRobj_env *surface	Id and mod. env. of surface.
-d*/
message VSgetSupportSf(	long			*msg ;
			struct GRmd_env		*myEnv ;
			struct GRobj_env	*surface ) ;
reject VSgetSupportSf ;

/*+d
Message VSgetProfileDef

Abstract
	Retrieves the cached object defining a beam's profile.
Arguments
	OUT	long		*msg		Completion code.
	OUT	struct GRid	*profileDef	Id of profile definition.
-d*/
message	VSgetProfileDef(	long		*msg ;
				struct GRid	*profileDef ; ) ;

/*+d
Message VSgetSectionParameter

Abstract
	Retrieves the value of a parameter of a cross-section.

Arguments
	OUT	long		*msg		Completion code.
	IN	char		*parm		Name of parameter.
	IN	struct GRmd_env	*myEnv		My module environment.
	OUT	double		*value		Value of parameter.
-d*/	
message VSgetSectionParameter(	long		*msg ;
				char		*parm ;
				struct GRmd_env	*myEnv ;
				double		*value ) ;

/*+d
Message VSgetCrossSectionCS

Abstract
	Evaluates the co-ordinate of a cross-section of a beam given
	all the position information.

Arguments
	OUT	long			*msg	Completion code.
	IN	struct GRmd_env         *myEnv	Beam's mod. environment.
	IN	struct GRobj_env	*surface
	IN	struct GRobj_env	*axis
	IN	double			pntParm Parameter of point on axis where
						the CS is wanted.
	OUT	struct GRid		*xDef	Section.
        OUT	IGRmatrix		xCS	Co-ordinate system of profile.
-d*/
message VSgetCrossSectionCS(	long			*msg ;
				struct GRmd_env		*myEnv ;
				struct GRobj_env	*surface,
							*axis ;
				double			pntParm ;
				struct GRid		*xDef ;
				IGRmatrix		xCS ) ;

/*+d
Message VSextractProfile

Abstract
	Copies and returns a cross-section of a beam at the desired position
	on the specified surfaces and axis. If surface and axis are not
	specified, those of the beam which is target of the message will be
	used.
Arguments
	OUT	long			*msg	Completion code.
	IN	struct GRmd_env         *myEnv	Beam's module environment.
	IN	struct GRobj_env	*surface
					*axis	Both may be NULL.
	IN	double			pntParm Parameter of point on axis where
						the CS is wanted.
	IN	struct GRvg_construct	*cst	Construction list of section.
        IN	VSdspRep		xRep	Representation for section.
	OUT	struct GRid		*xId	Constructed cross-section.

Note
	The construction list is used for the module environment and the
	symbology only.
-d*/
message VSextractProfile(
			long			*msg ;
			struct GRmd_env         *myEnv ;
			struct GRobj_env	*surface,
						*axis ;
			double			pntParm ;
			struct GRvg_construct	*cst ;
                        VSdspRep		xRep ;
			struct GRid		*xId  ) ;

/*+d
Message VSgetSegmentEnds

Abstract
	Returns the co-ordinates of the end points of a beam segment.

Arguments
	OUT	long		*msg	Completion code.
	IN	struct GRmd_env	*myEnv	Environment of target beam.
	OUT	IGRpoint	endp[2]	Co-ordinates of end points.
-d*/
message VSgetSegmentEnds(	long		*msg ;
				struct GRmd_env	*myEnv ;
				IGRpoint	endp[2] ) ;

/*+d
Message VSfaceNameToIndex

Abstract
	Given the name of a side of the body of a beam (ie. excluding the
	end caps), retrieves its index as a component of the surface which
	constitutes the body of the beam.
Arguments
	OUT	long		*msg		Completion code.
	IN	VSdspRep	myRep		Display representation of beam.
	IN	char		*faceName	Name of face.
	OUT	int		*faceIndex	Index of face.
-d*/
message VSfaceNameToIndex(	long		*msg ;
				VSdspRep	myRep ;
				char		*faceName ;
				int		*faceIndex ) ;

/*+d
Message VSfaceIndexToName

Abstract
	Given the index of a side as a component of the surface which
	constitutes the body of the beam (ie. excluding the end caps),
	retrieves its logical name.
Arguments
	OUT	long		*msg		Completion code.
	IN	VSdspRep	myRep		Display representation of beam.
	IN	int		faceIndex	Index of face.
	OUT	GRname		faceName	Name of face.
-d*/
message VSfaceIndexToName(	long		*msg ;
				VSdspRep	myRep ;
				int		faceIndex ;
				GRname		faceName ) ;

/*+d
Message VSgetBeamLength

Abstract
	Computes the length of the beam.
Arguments
	OUT	long		*msg		Completion code.
	IN	struct GRmd_env	*myEnv		Module environment of beam.
	OUT	double		*length		Length of beam.
-d*/
message VSgetBeamLength( long *msg ; struct GRmd_env *myEnv ; double *length ) ;

/*+d
Message VSgetXdirectionForCrossSectionCS

Abstract
	This method returns the available direction for the x-vector of the
	cross-section CS if any.
Arguments
	OUT	long			*msg	   Completion code.
	OUT	int			*haveDir   Have direction (TRUE/FASLE).
	OUT	IGRvector		xDir	   X direction.
Note
	This direction is only computed for stiffeners.
-d*/
message VSgetXdirectionForCrossSectionCS( long		*msg ;
					  int		*haveDir ;
					  IGRvector	xDir ) ;

end specification VSbeam ;

