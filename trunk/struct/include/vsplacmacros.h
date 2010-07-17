/*
 * I/STRUCT
 * Macros to place plate/beam/stiffener.
 */

#ifndef vsplacmacros_include
#	define vsplacmacros_include

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
Macro vs$place_plate

Abstract
	This macro places a plate on a given support surface.
Arguments
	OUT	long		 *msg		Completion code.
	IN	struct GRid	 *surfaceId	Id of surface support of plate.
	IN	struct GRmd_env  *surfaceEnv	Env of surface support of plate.
	IN	VSdspRep	 representation Representation of plate.
	IN	int		 transtable	Does the plate use the
						transtable ? ( TRUE/FALSE ).
	IN	char		 *basename	Basename of plate.
	IN	char		 *directory	Directory where the plate
						should be.
	IN	struct IGRdisplay
				 *display	Display of plate.
	IN	short		 level		Level of plate.
	IN	char		 *matType	Material type of plate.
	IN	char		 *matGrade	Material grade of plate.
	IN	char		 *partFam	Plate type of plate.
	IN	char		 *partNum	Tickness type of plate.
	IN	char		 *usrNotes	User notes.
	IN	char		 *mtoSrc	MTO source.
	IN	char		 *mtoStk	MTO stock.
	IN	double		 fireProofing	Thickness of fireproofing
						material.
	IN	int		 mtoChgNo	MTO change request number.
	IN	char		 *apprvStat	Approval status.
	IN	char		 *constStat	Construction status.
	IN	int		 mbrClass	Member class.
	IN	int		 mbrType	Member type.
	IN	int		 orientation	Orientation wrt support surface.
	IN	double		 cutOff 	Cut-off thickness.
	IN	double		 offset 	Offset from support surface.
	IN	double		 thickness	Thickness of plate.
	IN	struct GRid	 *UAid		Id of collection of user
						attributes.
	OUT	struct GRid	 *plateId	Placed plate.
Notes
	* 'representation' can have one of the following value :

		- AC_2D_REP  ( Symbolic representation	).
		- AC_3D_REP  ( Detailled representation ).
		- AC_ENV_REP ( Envelope representation	).

	  flags defined in $GRNUC/include/acrepdef.h
	  Default is AC_2D_REP.

	* 'transtable' can be TRUE or FALSE. If it's TRUE, the function will
	  take the following informations from the transtable :

		- directory where the plate should be.
		- display of plate.
		- level of plate.

	  in this case arguments 'directory' and 'display' can be NULL and
	  level can be set to 0.

	  If 'transtable' is FALSE, the function will take informations from
	  the given arguments :

		- 'directory' : directory where the plate should be.
		- 'display'   : display of plate.
		- 'level'     : level of plate.

	* 'basename' is the base name of the plate. The final name is :

		name = <directory>:<basename>:<number>

	  where <number> is a calculated number.

	  i.e : if basename = "Pl" and "directory" is "usr:test:plate" then
	  the name of plate will be usr:test:plate:Pl0 if the element Pl0
	  doesn't exit. Or, usr:test:plate:Pl1 if the element Pl0 exist.

	* 'directory' is the directory where the plate should be.
	  i.e : "usr:test:plate"

	* 'display' is the display of plate ( color, weight and style ).

	* 'level' is the level of plate.

	* 'matType' is the material type of plate. this material type should
	  exist in the relational data base. It can be retrieve by using the
	  macro vs$extract_materials_from_RDB defined in
	  $STRUCT/include/vsRDBmacros.h

	* 'matGrade' is the material grade of plate. this material grade
	  should exist in the relational data base. It can be retrieve by
	  using the macro vs$extract_grades_from_RDB defined in
	  $STRUCT/include/vsRDBmacros.h

	* 'partFam' is the plate type of plate. this plate type should exist
	  in the relational data base. It can be retrieve by using the macro
	  vs$extract_plates_from_RDB defined in $STRUCT/include/vsRDBmacros.h

	* 'partNum' is the tickness type of plate. this tickness type should
	  exist in the relational data base. It can be retrieve by using the
	  macro vs$extract_parts_from_RDB defined in
	  $STRUCT/include/vsRDBmacros.h

	* 'usrNotes' can be NULL. The carriage return should be the character
	  '\n'.
	  i.e: if we want the following note :
		The plate is inside the block
		number 255.
	       then 'usrNotes' = "The plate is inside the block\nnumber 255."

	* 'mtoSrc' is the MTO source. It can be NULL.

	* 'mtoStk' is the stock number. It can be NULL.

	* 'fireProofing' is thickness of fireproofing material.

	* 'mtoChgNo' is the change number.

	* 'apprvStat' is the approval status. It can be NULL.

	* 'constStat' is the construction status. It can be NULL.

	* 'mbrClass' is the member class code. It can be retrieve by using
	  the macro vs$get_member_classes_from_RDB defined in
	  $STRUCT/include/vsRDBmacros.h

	* 'mbrType' is the member type code. It can be retrieve by using
	  the macro vs$get_mb_plate_types_from_RDB defined in
	  $STRUCT/include/vsRDBmacros.h

	* 'orientation' is the orientation of the plate with respect to the
	  surface support. It can take one of the following value :
		- VS_K_USE_NAT_NORM ( the top surface of plate is on the
				      direction of the natural normal of the
				      support surface ).
		- VS_K_USE_REV_NORM ( the top surface of plate is on the
				      opposite direction of the natural normal
				      of the support surface ).

	  flags are defined in $STRUCT/include/vsplatedef.h
	  Default is VS_K_USE_NAT_NORM.

	* 'cutOff' is the cut-off thickness.

	* 'offset' is the offset from support surface.

	* 'thickness' is the thickness value of the plate. It can be retrieve
	  by using the macro vs$extract_parms_from_RDB defined in
	  $STRUCT/include/vsRDBmacros.h

	* 'UAid' is the id of the collection of user attributes. It can be
	  NULL or can be created by using the macro vs$makeActiveUsrAttr
	  defined in $STRUCT/include/vsuattmacros.h

	* 'plateId' is the constructed plate.

	* The macro returns MSSUCC if succesfull or MSFAIL if an error
	  occur in argument 'msg'.

	* The part of the plate should exist in the DB cache, otherwise
	  the user must be logged in PDM.

	* Example :
	  We want to place the plate with the following values :
		- Detailled representation
		- 'P' as base name.
		- Use of transtable.
		- Material type is 'steel'.
		- Material grade is 'A42'.
		- Plate type is 'imp_plate'.
		- Tickness type is '0.1875 in'.
		- orientation is 'Natural Normal'.
		- Thickness of plate is '0.1875 mm'.

	  The call of the macro should be :

	 long			msg ;
	 struct GRid		surfaceId ;
	 struct GRmd_env	surfaceEnv ;
	 struct GRid		plate ;

	 sts = vs$place_plate( msg		= &msg,
			       surfaceId	= &surfaceId,
			       surfaceEnv	= &surfaceEnv,
			       representation	= AC_3D_REP,
			       basename 	= "P",
			       matType		= "steel",
			       matGrade 	= "A42",
			       partFam		= "imp_plate",
			       partNum		= "0.1875 in",
			       thickness	= 0.1875,
			       plateId		= &plate ) ;

	if( !( sts & 1 & msg ) ) printf( "Error in placement of plate\n" ) ;
-M*/
extern long
VSplace_plate		__((	long			*msg,
				struct GRid		*surfaceId,
				struct GRmd_env 	*surfaceEnv,
				VSdspRep		representation,
				int			transtable,
				char			*basename,
				char			*directory,
				struct IGRdisplay	*display,
				short			level,
				char			*matType,
				char			*matGrade,
				char			*partFam,
				char			*partNum,
				char			*usrNotes,
				char			*mtoSrc,
				char			*mtoStk,
				double			fireProofing,
				int			mtoChgNo,
				char			*apprvStat,
				char			*constStat,
				int			mbrClass,
				int			mbrType,
				int			orientation,
				double			cutOff,
				double			offset,
				double			thickness,
				struct GRid		*UAid,
				struct GRid		*plateId )) ;

#omdef vs$place_plate(	msg,
			surfaceId,
			surfaceEnv,
			representation	= AC_2D_REP,
			transtable	= TRUE,
			basename,
			directory	= NULL,
			display 	= NULL,
			level		= 0,
			matType,
			matGrade,
			partFam,
			partNum,
			usrNotes	= NULL,
			mtoSrc		= NULL,
			mtoStk		= NULL,
			fireProofing	= 0.,
			mtoChgNo	= 0,
			apprvStat	= NULL,
			constStat	= NULL,
			mbrClass	= 0,
			mbrType 	= 0,
			orientation	= VS_K_USE_NAT_NORM,
			cutOff		= 0.,
			offset		= 0.,
			thickness,
			UAid		= NULL,
			plateId )

	VSplace_plate( (msg),
		       (surfaceId),
		       (surfaceEnv),
		       (representation),
		       (transtable),
		       (basename),
		       (directory),
		       (display),
		       (level),
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
		       (UAid),
		       (plateId) )
#endomdef

/*+M
Macro vs$place_stiffener

Abstract
	This macro places a stiffener on a given plate. The axis of the
	stiffener will be also constructed.
Arguments
	OUT	long		 *msg		Completion code.
	IN	struct GRid	 inputId[4]	Id of graphics input
						( See notes ).
	IN	struct GRmd_env  inputEnv[4]	Env of graphics input
						( See notes ).
	IN	VSdspRep	 representation Representation of stiffener.
	IN	int		 transtable	Does the stiffener use the
						transtable ? ( TRUE/FALSE ).
	IN	char		 *basename	Basename of stiffener.
	IN	char		 *directory	Directory where the stiffener
						should be.
	IN	struct IGRdisplay
				 *display	Display of stiffener.
	IN	short		 level		Level of stiffener.
	IN	char		 *matType	Material type of stiffener.
	IN	char		 *matGrade	Material grade of stiffener.
	IN	char		 *partFam	Beam type of stiffener.
	IN	char		 *partNum	Section name of stiffener.
	IN	char		 *usrNotes	User notes.
	IN	char		 *mtoSrc	MTO source.
	IN	char		 *mtoStk	MTO stock.
	IN	double		 fireProofing	Thickness of fireproofing
						material.
	IN	int		 mtoChgNo	MTO change request number.
	IN	char		 *apprvStat	Approval status.
	IN	char		 *constStat	Construction status.
	IN	int		 mbrClass	Member class.
	IN	int		 mbrType	Member type.
	IN	struct GRid	 *UAid		Id of collection of user
						attributes.
	IN	double		 xOffset	X-offset of stiffener wrt
						support axis.
	IN	double		 yOffset	Y-offset of stiffener wrt
						support axis.
	IN	double		 rotAngle	Angle of stiffener wrt support
						axis.
	IN	enum VScardinal_point
				 cardPnt	Cardinal point of cross-section.
	IN	enum VSsymmetry  symmetry	Symmetry of stiffener wrt
						support axis.
	IN	int		 topOfPlate	Stiffener lies on top of plate
						( TRUE/FALSE ).
	IN	int		 alongPlane	Stiffener is placed along plane.
	OUT	struct GRid	 *axisId	Constructed support axis.
	OUT	struct GRid	 *stiffenerId	Placed stiffener.
Notes
	* 'inputId' and 'inputEnv' are Id and Env of graphics input used to
	  place the stiffener.
		- inputId[0] and inputEnv[0] : Id + Env of plate support.
		- inputId[1] and inputEnv[1] : Id + Env of surface or curve
					       defining the direction of the
					       constructed axis.
		- inputId[2] and inputEnv[2] : Id + Env of start surface limit.
		- inputId[3] and inputEnv[3] : Id + Env of end surface limit.

	  If the constructed support axis should not be limited by surfaces,
	  inputId[2].objid and inputId[3].objid should be set to NULL_OBJID.

	* 'representation' can have one of the following value :

		- AC_2D_REP		( Symbolic representation  ).
		- AC_3D_REP		( Detailled representation ).
		- AC_ENV_REP		( Envelope representation  ).

	  ( flags defined in $GRNUC/include/acrepdef.h )

		- VS_m_2dSurface	( Struct2D representation     ).
		- VS_m_3dWFillet	( FilletedBeam representation ).

	  ( flags defined in $STRUCT/include/vsbeamdef.h )

	  Default is AC_2D_REP.

	* 'transtable' can be TRUE or FALSE. If it's TRUE, the function will
	  take the following informations from the transtable :

		- directory where the stiffener should be.
		- display of stiffener.
		- level of stiffener.

	  in this case arguments 'directory' and 'display' can be NULL and
	  level can be set to 0.

	  If 'transtable' is FALSE, the function will take informations from
	  the given arguments :

		- 'directory' : directory where the stiffener should be.
		- 'display'   : display of stiffener.
		- 'level'     : level of stiffener.

	* 'basename' is the base name of the stiffener. The final name is :

		name = <directory>:<basename>:<number>

	  where <number> is a calculated number.

	  i.e : if basename = "Stf" and "directory" is "usr:test:stif" then
	  the name of stiffener will be usr:test:stif:Stf0 if the element Stf0
	  doesn't exit. Or, usr:test:stif:Stf1 if the element Stf0 exist.

	* 'directory' is the directory where the stiffener should be.
	  i.e : "usr:test:stif"

	* 'display' is the display of stiffener ( color, weight and style ).

	* 'level' is the level of stiffener.

	* 'matType' is the material type of stiffener. this material type should
	  exist in the relational data base. It can be retrieve by using the
	  macro vs$extract_materials_from_RDB defined in
	  $STRUCT/include/vsRDBmacros.h

	* 'matGrade' is the material grade of stiffener. this material grade
	  should exist in the relational data base. It can be retrieve by
	  using the macro vs$extract_grades_from_RDB defined in
	  $STRUCT/include/vsRDBmacros.h

	* 'partFam' is the beam type of stiffener. this stiffener type should
	  exist in the relational data base. It can be retrieve by using the
	  macro vs$extract_shapes_from_RDB defined in
	  $STRUCT/include/vsRDBmacros.h

	* 'partNum' is the section name of stiffener. this section should
	  exist in the relational data base. It can be retrieve by using the
	  macro vs$extract_parts_from_RDB defined in
	  $STRUCT/include/vsRDBmacros.h

	* 'usrNotes' can be NULL. The carriage return should be the character
	  '\n'.
	  i.e: if we want the following note :
		The stiffener has 3
		childrens.
	       then 'usrNotes' = "The stiffener has 3\nchildren"

	* 'mtoSrc' is the MTO source. It can be NULL.

	* 'mtoStk' is the stock number. It can be NULL.

	* 'fireProofing' is thickness of fireproofing material.

	* 'mtoChgNo' is the change number.

	* 'apprvStat' is the approval status. It can be NULL.

	* 'constStat' is the construction status. It can be NULL.

	* 'mbrClass' is the member class code. It can be retrieve by using
	  the macro vs$get_member_classes_from_RDB defined in
	  $STRUCT/include/vsRDBmacros.h

	* 'mbrType' is the member type code. It can be retrieve by using
	  the macro vs$get_mb_beam_types_from_RDB defined in
	  $STRUCT/include/vsRDBmacros.h

	* 'UAid' is the id of the collection of user attributes. It can be
	  NULL or can be created by using the macro vs$makeActiveUsrAttr
	  defined in $STRUCT/include/vsuattmacros.h

	* 'Xoffset' is the X-offset of stiffener with respect to its constructed
	  support axis. The default value is 0.

	* 'Yoffset' is the Y-offset of stiffener with respect to its constructed
	  support axis. The default value is 0.

	* 'rotAngle' is the rotation angle of stiffener with respect to its
	  constructed support axis. The default value is 0.

	* 'cardPnt' is the cardinal point of cross-section, it could be one
	  of the following values :
		- VS_e_UPP_LEFT : upper-left	corner
		- VS_e_LFT_MIDD : left-middle	point
		- VS_e_BOT_LEFT : bottom-left	corner
		- VS_e_TOP_MIDD : top-middle	point
		- VS_e_BOT_MIDD : bottom-middle point
		- VS_e_UPP_RGHT : upper-right	corner
		- VS_e_GEO_CENT : geometric	center
		- VS_e_RGH_MIDD : right-middle	point
		- VS_e_BOT_RGHT : bottom-right	point

	 default value is VS_e_BOT_LEFT.
	 ( enum defined in $STRUCT/include/vsdpb.h )

	* 'symmetry' is the symmetry of stiffener with respect to its
	  constructed support axis. It can take one of the following values :
		- VS_e_No_Symm	: No symmetry
		- VS_e_X_Symm	: X symmetry
		- VS_e_Y_Symm	: Y symmetry
		- VS_e_XY_Symm	: XY symmetry

	 default value is VS_e_No_Symm.
	 ( enum defined in $STRUCT/include/vsdpb.h )

	* 'topOfPlate' is the side of plate where the stiffener should be.
	  It can be TRUE or FALSE.
		  - TRUE  : On top of plate.
		  - FALSE : On bottom of plate.

	 default value is FALSE.

	* 'alongPlane' can be TRUE or FALSE. If its FALSE, then the stiffener
	  use the side of plate to place its cross-section. Otherwise, instead
	  of the side of plate, the stiffener generates a surface of
	  projection perpendicular to its constructed support axis.

	* 'axisId' is its constructed support axis. It can be NULL.

	* 'stiffenerId' is the placed stiffener.

	* The macro returns MSSUCC if succesfull or MSFAIL if an error
	  occur in argument 'msg'.

	* The part of the stiffener should exist in the DB cache, otherwise
	  the user must be logged in PDM.

	* Example :
	  We want to place the stiffener with the following values :
		- Detailled representation.
		- 'S' as base name.
		- Use of transtable.
		- Material type is 'acier'.
		- Material grade is 'E355FP'.
		- Stiffener type is 'PL'.
		- Section Name is '100x5'.
		- Axis not limited.

	  The call of the macro should be :

	 long			msg ;
	 struct GRid		plateId ;
	 struct GRmd_env	plateEnv ;
	 struct GRid		directionId ;
	 struct GRmd_env	directionEnv ;
	 struct GRid		stiffener ;
	 struct GRid		inputId[4] ;
	 struct GRmd_env	inputEnv[4] ;

	    .
	    .
	    Locate plate and direction, then
	    .
	    .

	 inputId[0]  = plateId ;
	 inputEnv[0] = plateEnv ;

	 inputId[1]  = directionId ;
	 inputEnv[1] = directionEnv ;

	 inputId[2].objid = inputId[3].objid = NULL_OBJID ; ( No limits ).

	 sts = vs$place_stiffener( msg			= &msg,
				   inputId		= inputId,
				   inputEnv		= inputEnv,
				   representation	= AC_3D_REP,
				   basename		= "S",
				   matType		= "acier",
				   matGrade		= "E355FP",
				   partFam		= "PL",
				   partNum		= "100x5",
				   stiffenerId		= &stiffener ) ;

	if( !( sts & 1 & msg ) ) printf( "Error in placement of stiffener\n" ) ;
-M*/
extern long
VSplace_stiffener	__((	long			*msg,
				struct GRid		inputId[4],
				struct GRmd_env 	inputEnv[4],
				VSdspRep		representation,
				int			transtable,
				char			*basename,
				char			*directory,
				struct IGRdisplay	*display,
				short			level,
				char			*matType,
				char			*matGrade,
				char			*partFam,
				char			*partNum,
				char			*usrNotes,
				char			*mtoSrc,
				char			*mtoStk,
				double			fireProofing,
				int			mtoChgNo,
				char			*apprvStat,
				char			*constStat,
				int			mbrClass,
				int			mbrType,
				struct GRid		*UAid,
				double			xOffset,
				double			yOffset,
				double			rotAngle,
				enum VScardinal_point	cardPnt,
				enum VSsymmetry 	symmetry,
				int			topOfPlate,
				int			alongPlane,
				struct GRid		*axisId,
				struct GRid		*stiffenerId )) ;

#omdef vs$place_stiffener( msg,
			   inputId,
			   inputEnv,
			   representation	= AC_2D_REP,
			   transtable		= TRUE,
			   basename,
			   directory		= NULL,
			   display		= NULL,
			   level		= 0,
			   matType,
			   matGrade,
			   partFam,
			   partNum,
			   usrNotes		= NULL,
			   mtoSrc		= NULL,
			   mtoStk		= NULL,
			   fireProofing 	= 0.,
			   mtoChgNo		= 0,
			   apprvStat		= NULL,
			   constStat		= NULL,
			   mbrClass		= 0,
			   mbrType		= 0,
			   UAid 		= NULL,
			   xOffset		= 0.,
			   yOffset		= 0.,
			   rotAngle		= 0.,
			   cardPnt		= VS_e_BOT_LEFT,
			   symmetry		= VS_e_No_Symm,
			   topOfPlate		= FALSE,
			   alongPlane		= FALSE,
			   axisId		= NULL,
			   stiffenerId )

	VSplace_stiffener( (msg),
			   (inputId),
			   (inputEnv),
			   (representation),
			   (transtable),
			   (basename),
			   (directory),
			   (display),
			   (level),
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
			   (topOfPlate),
			   (alongPlane),
			   (axisId),
			   (stiffenerId) )
#endomdef

#endif /* vsplacmacros_include */
