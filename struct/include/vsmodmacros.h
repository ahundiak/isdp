/*
 * I/STRUCT
 * Macros to modify plate/beam/stiffener.
 */

#ifndef vsmodmacros_include
#	define vsmodmacros_include

#ifndef acrepdef_include
#	include "acrepdef.h"
#endif

#ifndef vsplatedef_include
#	include "vsplatedef.h"
#endif

#ifndef vsbeamdef_include
#	include "vsbeamdef.h"
#endif

#ifndef vsdpb_include
#	include "vsdpb.h"
#endif

#ifndef vs_include
#	include "vs.h"
#endif

/*+M
Macro vs$modify_plate

Abstract
	This macro modify a plate.
Arguments
	OUT	long		 *msg		 Completion code.
	IN	struct GRid	 *plateId	 The plate to modify.
	IN	VSdspRep	 *representation Representation of plate.
	IN	char		 *matType	 Material type of plate.
	IN	char		 *matGrade	 Material grade of plate.
	IN	char		 *partFam	 Plate type of plate.
	IN	char		 *partNum	 Tickness type of plate.
	IN	char		 *usrNotes	 User notes.
	IN	char		 *mtoSrc	 MTO source.
	IN	char		 *mtoStk	 MTO stock.
	IN	double		 *fireProofing	 Thickness of fireproofing
						 material.
	IN	int		 *mtoChgNo	 MTO change request number.
	IN	char		 *apprvStat	 Approval status.
	IN	char		 *constStat	 Construction status.
	IN	int		 *mbrClass	 Member class.
	IN	int		 *mbrType	 Member type.
	IN	int		 *orientation	 Orientation wrt support
						 surface.
	IN	double		 *cutOff	 Cut-off thickness.
	IN	double		 *offset	 Offset from support surface.
	IN	double		 *thickness	 Thickness of plate.
	IN	struct GRid	 *UAid		 Id of collection of user
						 attributes.
Notes
	* All arguments can be NULL except 'msg' and 'plateId'.

	* Example :
	  We want to modify the plate with the following values as new values :
		- Material type is 'steel'.
		- Material grade is 'A42'.
		- Plate type is 'imp_plate'.
		- Tickness type is '0.1875 in'.
		- Thickness of plate is '0.1875 mm'.

	  The call of the macro should be :

	 long			msg ;
	 struct GRid		plate ;
	 double 		thickness ;

	 thickness = 0.1875 ;

	 sts = vs$modify_plate( msg		= &msg,
				plateId 	= &plate,
				matType 	= "steel",
				matGrade	= "A42",
				partFam 	= "imp_plate",
				partNum 	= "0.1875 in",
				thickness	= &thickness ) ;

	 if( !( sts & 1 & msg ) ) printf( "Error in modification of plate\n" ) ;

	  We want to change the representation to detailled.

	  The call of the macro should be :

	 long			msg ;
	 struct GRid		plate ;
	 VSdspRep		representation ;

	 representation = AC_3D_REP ;

	 sts = vs$modify_plate( msg		= &msg,
				plateId 	= &plate,
				representation	= &representation ) ;

	 if( !( sts & 1 & msg ) ) printf( "Error in changing representation\n");
-M*/
extern long
VSmodify_plate		__((	long			*msg,
				struct GRid		*plateId,
				VSdspRep		*representation,
				char			*matType,
				char			*matGrade,
				char			*partFam,
				char			*partNum,
				char			*usrNotes,
				char			*mtoSrc,
				char			*mtoStk,
				double			*fireProofing,
				int			*mtoChgNo,
				char			*apprvStat,
				char			*constStat,
				int			*mbrClass,
				int			*mbrType,
				int			*orientation,
				double			*cutOff,
				double			*offset,
				double			*thickness,
				struct GRid		*UAid )) ;

#omdef vs$modify_plate( msg,
			plateId,
			representation	= NULL,
			matType 	= NULL,
			matGrade	= NULL,
			partFam 	= NULL,
			partNum 	= NULL,
			usrNotes	= NULL,
			mtoSrc		= NULL,
			mtoStk		= NULL,
			fireProofing	= NULL,
			mtoChgNo	= NULL,
			apprvStat	= NULL,
			constStat	= NULL,
			mbrClass	= NULL,
			mbrType 	= NULL,
			orientation	= NULL,
			cutOff		= NULL,
			offset		= NULL,
			thickness	= NULL,
			UAid		= NULL )

	VSmodify_plate( (msg),
			(plateId),
			(representation),
			(matType),
			(matGrade),
			(partFam),
			(partNum),
			(usrNotes),
			(mtoSrc),
			(mtoStk),
			(fireProofing),
			(mtoChgNo),
			(apprvStat),
			(constStat),
			(mbrClass),
			(mbrType),
			(orientation),
			(cutOff),
			(offset),
			(thickness),
			(UAid) )
#endomdef

/*+M
Macro vs$modify_stiffener

Abstract
	This macro modify a stiffener.
Arguments
	OUT	long		 *msg		 Completion code.
	IN	struct GRid	 *stiffenerId	 The stiffener to modify.
	IN	VSdspRep	 *representation Representation of stiffener.
	IN	char		 *matType	 Material type of stiffener.
	IN	char		 *matGrade	 Material grade of stiffener.
	IN	char		 *partFam	 Beam type of stiffener.
	IN	char		 *partNum	 Section name  of stiffener.
	IN	char		 *usrNotes	 User notes.
	IN	char		 *mtoSrc	 MTO source.
	IN	char		 *mtoStk	 MTO stock.
	IN	double		 *fireProofing	 Thickness of fireproofing
						 material.
	IN	int		 *mtoChgNo	 MTO change request number.
	IN	char		 *apprvStat	 Approval status.
	IN	char		 *constStat	 Construction status.
	IN	int		 *mbrClass	 Member class.
	IN	int		 *mbrType	 Member type.
	IN	struct GRid	 *UAid		 Id of collection of user
						 attributes.
	IN	double		 *xOffset	 X-offset of stiffener wrt
						 support axis.
	IN	double		 *yOffset	 Y-offset of stiffener wrt
						 support axis.
	IN	double		 *rotAngle	 Angle of stiffener wrt support
						 axis.
	IN	enum VScardinal_point
				 *cardPnt	 Cardinal point of
						 cross-section.
	IN	enum VSsymmetry  *symmetry	 Symmetry of stiffener wrt
						 support axis.
	IN	int		 *alongPlane	 Stiffener is placed along
						 plane.
Notes
	* All arguments can be NULL except 'msg' and 'stiffenerId'.

	* Example :
	  We want to modify the stiffener with the following values as new
	  values :
		- Material type is 'acier'.
		- Material grade is 'E355FP'.
		- Stiffener type is 'PL'.
		- Section Name is '100x5'.

	  The call of the macro should be :

	 long			msg ;
	 struct GRid		stiffener ;

	 sts = vs$modify_stiffener( msg 	= &msg,
				    stiffenerId = &stiffener,
				    matType	= "acier",
				    matGrade	= "E355FP",
				    partFam	= "PL",
				    partNum	= "100x5" ) ;

	 if( !( sts & 1 & msg ) )
		printf( "Error in modification of stiffener\n" ) ;

	  We want to change the representation to detailled.

	  The call of the macro should be :

	 long			msg ;
	 struct GRid		stiffener ;
	 VSdspRep		representation ;

	 representation = AC_3D_REP ;

	 sts = vs$modify_stiffener( msg 	   = &msg,
				    stiffenerId    = &stiffener,
				    representation = &representation ) ;

	 if( !( sts & 1 & msg ) ) printf( "Error in changing representation\n");

	 We want the stiffener placed along plane.

	  The call of the macro should be :

	 long			msg ;
	 struct GRid		stiffener ;
	 int			alongPlane ;

	 alongPlane = TRUE ;

	 sts = vs$modify_stiffener( msg 	= &msg,
				    stiffenerId = &stiffener,
				    alongPlane	= &alongPlane ) ;

	 if( !( sts & 1 & msg ) )
		printf( "Error in modification of stiffener\n" ) ;
-M*/
extern long
VSmodify_stiffener		__((	long			*msg,
					struct GRid		*stiffenerId,
					VSdspRep		*representation,
					char			*matType,
					char			*matGrade,
					char			*partFam,
					char			*partNum,
					char			*usrNotes,
					char			*mtoSrc,
					char			*mtoStk,
					double			*fireProofing,
					int			*mtoChgNo,
					char			*apprvStat,
					char			*constStat,
					int			*mbrClass,
					int			*mbrType,
					struct GRid		*UAid,
					double			*xOffset,
					double			*yOffset,
					double			*rotAngle,
					enum VScardinal_point	*cardPnt,
					enum VSsymmetry 	*symmetry,
					int			*alongPlane )) ;

#omdef vs$modify_stiffener( msg,
			    stiffenerId,
			    representation	= NULL,
			    matType		= NULL,
			    matGrade		= NULL,
			    partFam		= NULL,
			    partNum		= NULL,
			    usrNotes		= NULL,
			    mtoSrc		= NULL,
			    mtoStk		= NULL,
			    fireProofing	= NULL,
			    mtoChgNo		= NULL,
			    apprvStat		= NULL,
			    constStat		= NULL,
			    mbrClass		= NULL,
			    mbrType		= NULL,
			    UAid		= NULL,
			    xOffset		= NULL,
			    yOffset		= NULL,
			    rotAngle		= NULL,
			    cardPnt		= NULL,
			    symmetry		= NULL,
			    alongPlane		= NULL )

	VSmodify_stiffener( (msg),
			    (stiffenerId),
			    (representation),
			    (matType),
			    (matGrade),
			    (partFam),
			    (partNum),
			    (usrNotes),
			    (mtoSrc),
			    (mtoStk),
			    (fireProofing),
			    (mtoChgNo),
			    (apprvStat),
			    (constStat),
			    (mbrClass),
			    (mbrType),
			    (UAid),
			    (xOffset),
			    (yOffset),
			    (rotAngle),
			    (cardPnt),
			    (symmetry),
			    (alongPlane) )
#endomdef

#endif /* vsmodmacros_include */
