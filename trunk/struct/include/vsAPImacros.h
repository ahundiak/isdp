/* $Id: vsAPImacros.h,v 1.1.1.1 2001/01/04 21:09:42 cvs Exp $  */
 
/***************************************************************************
 * I/STRUCT
 *
 * File:        include/vsAPImacros.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: vsAPImacros.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:09:42  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/30  10:08:06  pinnacle
 * STRUCT 2.5.1
 *
 * Revision 1.3  1998/04/21  13:29:28  pinnacle
 * CR179800807
 *
 *
 * History:
 * MM/DD/YY     AUTHOR  DESCRIPTION
 * 02/27/98     ah      CR179800807 Add Web Alignment Option
 * 04/17/98	suresh	added orientbyCurve, extToTrim and extToPast for beam
			axis.
 ***************************************************************************/
/*	I/STRUCT API macros.	*/

#ifndef vsAPImacros_include
#	define vsAPImacros_include

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

#ifndef vsAPIwelddef_include
#	include "vsAPIwelddef.h"
#endif

/* ************************************************************************** */
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
	* The macro returns MSSUCC if succesfull or MSFAIL if an error
          occur in argument 'msg'.

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

		name = <directory>:<basename><number>

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
/* ************************************************************************** */

/* ************************************************************************** */
/*+M
Macro vs$place_beam

Abstract
	This macro places a beam on a given surface.
Arguments
	OUT	long		 *msg		Completion code.
	IN	struct GRid	 inputId[2]	Id of graphics input
						( See notes ).
	IN	struct GRmd_env  inputEnv[2]	Env of graphics input
						( See notes ).
	IN	VSdspRep	 representation Representation of beam.
	IN	int		 transtable	Does the beam use the
						transtable ? ( TRUE/FALSE ).
	IN	char		 *basename	Basename of beam.
	IN	char		 *directory	Directory where the beam
						should be.
	IN	struct IGRdisplay
				 *display	Display of beam.
	IN	short		 level		Level of beam.
	IN	char		 *matType	Material type of beam.
	IN	char		 *matGrade	Material grade of beam.
	IN	char		 *partFam	Beam type of beam.
	IN	char		 *partNum	Section name of beam.
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
	IN	double		 xOffset	X-offset of beam wrt
						support axis.
	IN	double		 yOffset	Y-offset of beam wrt
						support axis.
	IN	double		 rotAngle	Angle of beam wrt support
						axis.
	IN	enum VScardinal_point
				 cardPnt	Cardinal point of cross-section.
	IN	enum VSsymmetry  symmetry	Symmetry of beam wrt
						support axis.
	IN	IGRboolean	 displayFlag	Display Flag 
	IN	enum GRdpmode	 dpmode		The display mode
        IN      int              webAlign       Web Alignment (TRUE/FALSE)
	OUT	struct GRid	 *beamId	Placed beam.
Notes
	* The macro returns MSSUCC if succesfull or MSFAIL if an error
          occur in argument 'msg'.

	* 'inputId' and 'inputEnv' are Id and Env of graphics input used to
	  place the beam.
		- inputId[0] and inputEnv[0] : Id + Env of surface support.
		- inputId[1] and inputEnv[1] : Id + Env of curve axis.

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

		- directory where the beam should be.
		- display of beam.
		- level of beam.

	  in this case arguments 'directory' and 'display' can be NULL and
	  level can be set to 0.

	  If 'transtable' is FALSE, the function will take informations from
	  the given arguments :

		- 'directory' : directory where the beam should be.
		- 'display'   : display of beam.
		- 'level'     : level of beam.

	Default is TRUE.

	* 'basename' is the base name of the beam. The final name is :

		name = <directory>:<basename><number>

	  where <number> is a calculated number.

	  i.e : if basename = "Bea" and "directory" is "usr:test:beam" then
	  the name of beam will be usr:test:beam:Bea0 if the element Bea0
	  doesn't exit. Or, usr:test:beam:Bea1 if the element Bea0 exist.

	* 'directory' is the directory where the beam should be.
	  i.e : "usr:test:beam"

	* 'display' is the display of beam ( color, weight and style ).

	* 'level' is the level of beam.

	* 'matType' is the material type of beam. this material type should
	  exist in the relational data base. It can be retrieve by using the
	  macro vs$extract_materials_from_RDB defined in
	  $STRUCT/include/vsRDBmacros.h

	* 'matGrade' is the material grade of beam. this material grade
	  should exist in the relational data base. It can be retrieve by
	  using the macro vs$extract_grades_from_RDB defined in
	  $STRUCT/include/vsRDBmacros.h

	* 'partFam' is the beam type of beam. this beam type should
	  exist in the relational data base. It can be retrieve by using the
	  macro vs$extract_shapes_from_RDB defined in
	  $STRUCT/include/vsRDBmacros.h

	* 'partNum' is the section name of beam. this section should
	  exist in the relational data base. It can be retrieve by using the
	  macro vs$extract_parts_from_RDB defined in
	  $STRUCT/include/vsRDBmacros.h

	* 'usrNotes' can be NULL. The carriage return should be the character
	  '\n'.
	  i.e: if we want the following note :
		The beam has 3
		childrens.
	       then 'usrNotes' = "The beam has 3\nchildren"

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

	* 'Xoffset' is the X-offset of beam with respect to its constructed
	  support axis. The default value is 0.

	* 'Yoffset' is the Y-offset of beam with respect to its constructed
	  support axis. The default value is 0.

	* 'rotAngle' is the rotation angle of beam with respect to its
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

	* 'symmetry' is the symmetry of beam with respect to its
	  constructed support axis. It can take one of the following values :
		- VS_e_No_Symm	: No symmetry
		- VS_e_X_Symm	: X symmetry
		- VS_e_Y_Symm	: Y symmetry
		- VS_e_XY_Symm	: XY symmetry

	 default value is VS_e_No_Symm.
	 ( enum defined in $STRUCT/include/vsdpb.h )

	* 'displayFlag' Whether to display the beam'
	   Default is to display

	* 'dpmode' is the display mode. Default is to backgroung Draw

        * 'webAlign' specifies the stiffener axis alignment - CR179800807
          It can be TRUE or FALSE.
                  - TRUE  : Along Web
                  - FALSE : Along Profile

	* 'beamId' is the placed beam.

	* The part of the beam should exist in the DB cache, otherwise
	  the user must be logged in PDM.

	* Example :
	  We want to place the beam with the following values :
		- Detailled representation.
		- 'B' as base name.
		- Use of transtable.
		- Material type is 'acier'.
		- Material grade is 'E355FP'.
		- Stiffener type is 'PL'.
		- Section Name is '100x5'.

	  The call of the macro should be :

	 long			msg ;
	 struct GRid		surfaceId ;
	 struct GRmd_env	surfaceEnv ;
	 struct GRid		axisId ;
	 struct GRmd_env	axisEnv ;
	 struct GRid		beam ;
	 struct GRid		inputId[2] ;
	 struct GRmd_env	inputEnv[2] ;

	    .
	    .
	    Locate surface and direction, then
	    .
	    .

	 inputId[0]  = surfaceId ;
	 inputEnv[0] = surfaceEnv ;

	 inputId[1]  = axisId ;
	 inputEnv[1] = axisEnv ;

	 sts = vs$place_beam( msg		= &msg,
			      inputId		= inputId,
			      inputEnv		= inputEnv,
			      representation	= AC_3D_REP,
			      basename		= "S",
			      matType		= "acier",
			      matGrade		= "E355FP",
			      partFam		= "PL",
			      partNum		= "100x5",
			      beamId		= &beam ) ;

	if( !( sts & 1 & msg ) ) printf( "Error in placement of beam\n" ) ;
-M*/
extern long
VSplace_beam	__((	long			*msg,
			struct GRid		inputId[2],
			struct GRmd_env 	inputEnv[2],
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
			IGRboolean		displayFlag,
			enum GRdpmode		dpmode,
                        int                     webAlign,
			struct GRid		*beamId )) ;

#omdef vs$place_beam( msg,
		      inputId,
		      inputEnv,
		      representation	= AC_2D_REP,
		      transtable	= TRUE,
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
		      displayFlag	= TRUE,
		      dpmode		= GRbd,
                      webAlign          = FALSE,
		      beamId )

	VSplace_beam( (msg),
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
		      (displayFlag),
		      (dpmode),
                      (webAlign),
		      (beamId) )
#endomdef
/* ************************************************************************** */

/* ************************************************************************** */
/*+M
Macro vs$place_stiffener

Abstract
	This macro places a stiffener on a given plate.
	The axis of the stiffener is constructed by vs$place_stiffener_axis().
Arguments
	OUT	long		 *msg		Completion code.
	IN	struct GRid	 *axisId	Stiffener axis.
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
	IN	int		 alongPlane	Stiffener is placed along plane.
	IN      int              topOfPlate     Stiffener lies on top of plate
                                                ( TRUE/FALSE ).
	IN      int              webAlign       Web Alignment (TRUE/FALSE)
	OUT	struct GRid	 *stiffenerId	Placed stiffener.
Notes
	* The macro returns MSSUCC if succesfull, MSFAIL if an error
          occur or OM_E_INVARG if the given axis is not	a stiffener
          axis in argument 'msg'.

	* 'axisId' is constructed by vs$place_stiffener_axis().

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

	Default is TRUE.

	* 'basename' is the base name of the stiffener. The final name is :

		name = <directory>:<basename><number>

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

	* 'alongPlane' can be TRUE or FALSE. If its FALSE, then the stiffener
	  use the side of plate to place its cross-section. Otherwise, instead
	  of the side of plate, the stiffener generates a surface of
	  projection perpendicular to its constructed support axis.

	* 'topOfPlate' is the side of plate where the stiffener axis should be.
          It can be TRUE or FALSE.
                  - TRUE  : On top of plate.
                  - FALSE : On bottom of plate.

        * 'webAlign' specifies the stiffener axis alignment - CR179800807
          It can be TRUE or FALSE.
                  - TRUE  : Along Web
                  - FALSE : Along Profile


	* 'stiffenerId' is the placed stiffener.

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

	  The call of the macro should be :

	 long			msg ;
	 struct GRid		plateId ;
	 struct GRmd_env	plateEnv ;
	 struct GRid		directionId ;
	 struct GRmd_env	directionEnv ;
	 struct GRid		stf_axis ;
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

	 sts = vs$place_stiffener_axis( msg		= &msg,
				        inputId		= inputId,
				        inputEnv	= inputEnv,
				        axisId		= &stf_axis ) ;

	if( !( sts & 1 & msg ) )
		printf( "Error in placement of stiffener axis\n" ) ;

	 sts = vs$place_stiffener( msg			= &msg,
				   axisId		= &stf_axis,
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
				struct GRid		*axisId,
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
				int			alongPlane,
				int			topOfPlate,
				int			webAlign,
				struct GRid		*stiffenerId )) ;

#omdef vs$place_stiffener( msg,
			   axisId,
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
			   alongPlane		= FALSE,
			   topOfPlate		= FALSE,
			   webAlign             = FALSE,
			   stiffenerId )

	VSplace_stiffener( (msg),
			   (axisId),
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
			   (alongPlane),
			   (topOfPlate),
			   (webAlign),
			   (stiffenerId) )
#endomdef
/* ************************************************************************** */

/* ************************************************************************** */
/*+M
Macro vs$place_stiffener_axis

Abstract
	This macro places a stiffener axis on a given plate.
Arguments
	OUT	long		 *msg		Completion code.
	IN	struct GRid	 inputId[4]	Id of graphics input
						( See notes ).
	IN	struct GRmd_env  inputEnv[4]	Env of graphics input
						( See notes ).
	IN	int		 transtable	Does the stiffener axis use the
						transtable ? ( TRUE/FALSE ).
				 *display	Display of stiffener axis.
	IN	short		 level		Level of stiffener axis.
	IN	int		 topOfPlate	Stiffener axis lies on top of
						plate ( TRUE/FALSE ).
        IN      int              orientByCurve  Orient the axis by support
                                                curve vice surface
                                                (TRUE/FALSE)
        IN      int              extToTrim[2]   Extend to trimming surfaces
                                                (TRUE/FALSE)

	OUT	struct GRid	 *axisId	Constructed stiffener axis.
Notes
	* The macro returns MSSUCC if succesfull or MSFAIL if an error
          occur in argument 'msg'.

	* 'inputId' and 'inputEnv' are Id and Env of graphics input used to
	  place the stiffener axis.
		- inputId[0] and inputEnv[0] : Id + Env of plate support.
		- inputId[1] and inputEnv[1] : Id + Env of surface or curve
					       defining the direction of the
					       constructed axis.
		- inputId[2] and inputEnv[2] : Id + Env of start surface limit.
		- inputId[3] and inputEnv[3] : Id + Env of end surface limit.

	  If the constructed support axis should not be limited by surfaces,
	  inputId[2].objid and inputId[3].objid should be set to NULL_OBJID.

	* 'transtable' can be TRUE or FALSE. If it's TRUE, the function will
	  take the following informations from the transtable :

		- display of stiffener axis.
		- level of stiffener axis.

	  in this case arguments 'display' can be NULL and level can be set to 0.

	  If 'transtable' is FALSE, the function will take informations from
	  the given arguments :

		- 'display'   : display of stiffener axis.
		- 'level'     : level of stiffener axis.

	Default is TRUE.

	* 'display' is the display of stiffener axis ( color, weight and style).

	* 'level' is the level of stiffener axis.

	* 'topOfPlate' is the side of plate where the stiffener axis should be.
	  It can be TRUE or FALSE.
		  - TRUE  : On top of plate.
		  - FALSE : On bottom of plate.

	 default value is FALSE.

        * 'orientToCurve' - Orient axis based on support curve
                            vice support surface
 
        * 'extToTrim' - Extend to trimming surfaces going past
                        edge of plate if required
                        Use only for short extensions if axis
                        is curved

	* 'axisId' is its constructed support axis. It can be NULL.
-M*/
extern long
VSplace_stiffener_axis	__((	long			*msg,
				struct GRid		inputId[4],
				struct GRmd_env 	inputEnv[4],
				int			transtable,
				struct IGRdisplay	*display,
				short			level,
				int			topOfPlate,
                                int                     orientToCurve,
                                int                     extToTrim[2],
				struct GRid		*axisId )) ;

#omdef vs$place_stiffener_axis( msg,
			   	inputId,
			   	inputEnv,
				transtable	= TRUE,
			   	display		= NULL,
			   	level		= 0,
			   	topOfPlate	= FALSE,
                                orientToCurve   = FALSE,
                                extToTrim       = NULL,
			   	axisId )

	VSplace_stiffener_axis( (msg),
			   	(inputId),
			   	(inputEnv),
				(transtable),
			   	(display),
			   	(level),
			   	(topOfPlate),
                                (orientToCurve),
                                (extToTrim),
			   	(axisId) )
#endomdef
/* ************************************************************************** */

/* ************************************************************************** */
/*+M
Macro vs$place_joint

Abstract
	This macro places a joint between two structural plates.
Arguments
	OUT	long		 *msg		Completion code.
	IN	struct GRid	 elemId[2]	Id of the two structural elem.
	IN	struct GRmd_env  elemEnv[2]	Env of two structural elem.
	IN	int		 transtable	Does the joint use the
						transtable ? ( TRUE/FALSE ).
	IN	char		 *directory	Directory where the joint
						should be.
	IN	struct IGRdisplay
				 *display	Display of joint.
	IN	short		 level		Level of joint.
	IN	int		 weldCode	Weld code.
	IN	int		 weldProcess 	Weld process.
	IN	int		 weldInfo	Weld info.
	IN	int		 weldContour	Weld contour.
	IN	int		 weldSide	Weld side.
	IN	double		 allowance	Joint allowance value.
	IN	double		 grooveAngle	Joint groove angle value.
	IN	double		 pitch		Joint pitch value.
	IN	double		 lengthOfIncr	Length of increments value.
	IN	char		 *usrSymbol	User symbol for joint.
	IN	struct GRid	 *UAid		Id of collection of user
						attributes.
	IN	int		 fieldWeld	Field Weld Option (TRUE/FALSE)
	IN	int		 weldPosition	Position of Weld 
						0
						1
						2
						3
	IN	double		shrinkage	Weld Shrinkage value
	OUT	struct GRid	 *jointId	Placed joint.
Notes
	* The macro returns MSSUCC if succesfull or MSFAIL if an error
          occur in argument 'msg'.

	* 'elemId' and 'elemEnv' are Id and Env of graphics input used to
	  place the joint.
	  The following junctions are allowed :	plate-plate
						beam-beam
						plate-beam
						beam-plate
						stiffener-support plate
						support plate-stiffener

        * 'transtable' can be TRUE or FALSE. If it's TRUE, the function will
          take the following informations from the transtable :

                - directory where the joint should be.
                - display of joint.
                - level of joint.

          in this case arguments 'directory' and 'display' can be NULL and
          level can be set to 0.

          If 'transtable' is FALSE, the function will take informations from
          the given arguments :

                - 'directory' : directory where the joint should be.
                - 'display'   : display of joint.
                - 'level'     : level of joint.

	  Default is TRUE.

	* 'directory' is the directory where the joint should be.
	  i.e : "usr:test:joint"

	* 'display' is the display of joint ( color, weight and style ).

	* 'level' is the level of joint.

	* 'weldCode' must be selected in 'vsAPIwelddef.h' in the 1st section
	  called "WELD CODE".
	  default value is VS_WC_Fillet.

	* 'weldProcess' must be selected in 'vsAPIwelddef.h' in the 2nd section
	  called "WELD PROCESS".
	  default value is VS_WP_Undefined.

	* 'weldInfo' must be selected in 'vsAPIwelddef.h' in the 3rd section
	  called "WELD INFO".
	  default value is VS_WI_No_No_No.

	* 'weldContour' must be selected in 'vsAPIwelddef.h' in the 4th section
	  called "WELD CONTOUR".
	  default value is VS_WK_Flush.

	* 'weldSide' must be selected in 'vsAPIwelddef.h' in the 5th section
	  called "WELD SIDE".
	  default value is VS_WS_Arrow.

	* 'allowance' is the joint allowance value. 
	  Default value is 0.0

	* 'grooveAngle' is the joint groove angle value. 
	  Default value is 0.0

	* 'pitch' is the oint pitch value.
	  Default value is 0.0

	* 'lengthOfIncr' is the joint length of increments value. 
	  Default value is 0.0

	* 'usrSymbol' is the joint alphanumerical representation.

	* 'UAid' is the id of the collection of user attributes. It can be
	  NULL or can be created by using the macro vs$makeActiveUsrAttr
	  defined in $STRUCT/include/vsuattmacros.h.

	* 'jointId' is the placed joint.
-M*/
extern long
VSplace_joint		__((	long			*msg,
				struct GRid		elemId[2],
				struct GRmd_env		elemEnv[2],
				int			transtable,
				char			*directory,
				struct IGRdisplay	*display,
				short			level,
				int			weldCode,
				int			weldProcess,
				int			weldInfo,
				int			weldContour,
				int			weldSide,
				double			allowance,
				double			grooveAngle,
				double			pitch,
				double			lengthOfIncr,
				char			*usrSymbol,
				struct GRid		*UAid ,
				int 			fieldWeld, //added by Manoj
				int 			weldPosition, //added by Manoj
				double			shrinkage, //added by Manoj
				struct GRid		*jointId )) ;

#omdef vs$place_joint( msg,
		       elemId,
		       elemEnv,
		       transtable	= TRUE,
		       directory	= NULL,
		       display		= NULL,
		       level		= 0,
		       weldCode		= VS_WC_Fillet,
		       weldProcess	= VS_WP_Undefined,
		       weldInfo		= VS_WI_No_No_No,
		       weldContour	= VS_WK_Flush,
		       weldSide		= VS_WS_Arrow,
		       allowance	= 0.0,
		       grooveAngle	= 0.0,
		       pitch		= 0.0,
		       lengthOfIncr	= 0.0,
		       usrSymbol	= NULL,
		       UAid 		= NULL,
		       fieldWeld        = FALSE,
		       weldPosition     = 0,
		       shrinkage        = 0.2,
		       jointId )

	VSplace_joint( (msg),
		       (elemId),
		       (elemEnv),
		       (transtable),
		       (directory),
		       (display),
		       (level),
		       (weldCode),
		       (weldProcess),
		       (weldInfo),
		       (weldContour),
		       (weldSide),
		       (allowance),
		       (grooveAngle),
		       (pitch),
		       (lengthOfIncr),
		       (usrSymbol),
		       (UAid),
		       (fieldWeld),  
		       (weldPosition), 
		       (shrinkage), 
		       (jointId) )
#endomdef
/* ************************************************************************** */

/* ************************************************************************** */
/*+M
Macro vs$modify_plate

Abstract
	This macro modifies a plate.
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
	* The macro returns MSSUCC if succesfull or MSFAIL if an error
          occur in argument 'msg'.

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
/* ************************************************************************** */

/* ************************************************************************** */
/*+M
Macro vs$modify_beam

Abstract
	This macro modifies a beam.
Arguments
	OUT	long		 *msg		 Completion code.
	IN	struct GRid	 *beamId	 The beam to modify.
	IN	VSdspRep	 *representation Representation of beam.
	IN	char		 *matType	 Material type of beam.
	IN	char		 *matGrade	 Material grade of beam.
	IN	char		 *partFam	 Beam type of beam.
	IN	char		 *partNum	 Section name of beam.
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
	IN	double		 *xOffset	 X-offset of beam wrt
						 support axis.
	IN	double		 *yOffset	 Y-offset of beam wrt
						 support axis.
	IN	double		 *rotAngle	 Angle of beam wrt support
						 axis.
	IN	enum VScardinal_point
				 *cardPnt	Cardinal point of cross-section.
	IN	enum VSsymmetry  *symmetry	Symmetry of beam wrt
						support axis.
        IN      int              webAlign       Web Alignment (TRUE/FALSE)

Notes
	* The macro returns MSSUCC if succesfull or MSFAIL if an error
          occur in argument 'msg'.

	* All arguments can be NULL except 'msg' and 'beamId'.

	* Example :
	  We want to modify the beam with the following values as new values :
		- Material type is 'acier'.
		- Material grade is 'E355FP'.
		- Beam type is 'PL'.
		- Section Name is '100x5'.

          The call of the macro should be :

         long                   msg ;
         struct GRid            beam ;

         sts = vs$modify_beam( msg         = &msg,
                               beamId 	   = &beam,
                               matType     = "acier",
                               matGrade    = "E355FP",
                               partFam     = "PL",
                               partNum     = "100x5" ) ;

         if( !( sts & 1 & msg ) )
                printf( "Error in modification of beam\n" ) ;

          We want to change the representation to detailled.

          The call of the macro should be :

         long                   msg ;
         struct GRid            beam ;
         VSdspRep               representation ;

         representation = AC_3D_REP ;

         sts = vs$modify_beam( msg            = &msg,
                               beamId         = &beam,
                               representation = &representation ) ;

         if( !( sts & 1 & msg ) ) printf( "Error in changing representation\n");
-M*/
extern long
VSmodify_beam	__((	long			*msg,
			struct GRid		*beamId,
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
			int                     webAlign )) ;

#omdef vs$modify_beam( msg,
		       beamId,
		       representation	= NULL,
		       matType		= NULL,
		       matGrade		= NULL,
		       partFam		= NULL,
		       partNum		= NULL,
		       usrNotes		= NULL,
		       mtoSrc		= NULL,
		       mtoStk		= NULL,
		       fireProofing 	= NULL,
		       mtoChgNo		= NULL,
		       apprvStat	= NULL,
		       constStat	= NULL,
		       mbrClass		= NULL,
		       mbrType		= NULL,
		       UAid 		= NULL,
		       xOffset		= NULL,
		       yOffset		= NULL,
		       rotAngle		= NULL,
		       cardPnt		= NULL,
		       symmetry		= NULL,
		       webAlign         = FALSE )

	VSmodify_beam( (msg),
		       (beamId),
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
		       (webAlign) )
#endomdef
/* ************************************************************************** */

/* ************************************************************************** */
/*+M
Macro vs$modify_stiffener

Abstract
	This macro modifies a stiffener.
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
        IN      int              webAlign       Web Alignment (TRUE/FALSE)

Notes
	* The macro returns MSSUCC if succesfull or MSFAIL if an error
          occur in argument 'msg'.

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

        * 'webAlign' specifies the stiffener axis alignment - CR179800807
          It can be TRUE or FALSE.
                  - TRUE  : Along Web
                  - FALSE : Along Profile

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
					int			*alongPlane,
					int 			webAlign )) ;

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
			    alongPlane		= NULL,
			    webAlign		= FALSE )

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
			    (alongPlane),
			    (webAlign) )
#endomdef
/* ************************************************************************** */

/* ************************************************************************** */
/*+M
Macro vs$modify_stiffener_axis

Abstract
	This macro modifies a stiffener axis.
Arguments
	OUT	long		 *msg		Completion code.
	IN	struct GRid	 *axisId	The stiffener axis to modify.
	IN	struct GRid	 *plateId	Id of the new plate parent.
	IN	struct GRmd_env	 *plateEnv	Env of the new plate parent.
	IN	struct GRid	 *directionId	Id of the new curve or surface
						direction parent.
	IN	struct GRmd_env	 *directionEnv	Env of the new curve or surface
						direction parent.
	IN	struct GRid	 *startSurfId	Id of the new start surface limit
						parent.
	IN	struct GRmd_env	 *startSurfEnv	Env of the new start surface limit
						parent.
	IN	struct GRid	 *endSurfId	Id of the new end surface limit
						parent.
	IN	struct GRmd_env	 *endSurfEnv	Env of the new end surface limit
						parent.
	IN	int	 	 *topOfPlate	New side of plate. 
						(TRUE = top side, FALSE = bottom
						side ).
        IN      int              extPastTrim    Extend axis past trim
                                                based on stiff profile
                                                (TRUE/FALSE)
        IN      int              orientByCurve  Orient the axis by support
                                                curve vice surface
                                                (TRUE/FALSE)
        IN      int              extToTrim[2]   Extend to trimming surfaces
                                                (TRUE/FALSE)
Notes
	* The macro returns MSSUCC if succesfull, MSFAIL if an error occur 
	  or EMS_E_InvalidArg if input arguments are not valid in argument 'msg'.

	* The limiting surfaces are optionnal parents during the construction of
	  the stiffener axis. This macro allows the caller to change this surfaces,
	  remove this surfaces or add this surfaces.

	  - To change, just fill the four argumnets 'startSurfId', 'startSurfEnv',
	  'endSurfId' and 'endSurfEnv' with the new limiting surfaces.
	  You can change one of the two surfaces.

	  - To remove, just set startSurfId->objid = NULL_OBJID AND
	  endSurfId->objid = NULL_OBJID, the corresponding Env can be NULL.

	  - To add, just fill the four argumnets 'startSurfId', 'startSurfEnv',
	  'endSurfId' and 'endSurfEnv' with the new limiting surfaces.

	  You can modify one of the two limiting surfaces, but you add the
	  two surfaces, you cannot add only one limiting surface.

	* Examples :
	  1) We want to change the side of the plate where the stiffener
	     axis lies from top to bottom.

	     long		msg;
	     struct GRid	axisId;
	     int		top = FALSE;

	     sts = vs$modify_stiffener_axis( msg	= &msg,
	     				     axisId	= &axisId,
					     topOfPlate = &top ) ;

	  2) We want to remove the two limiting surfaces from the list
	     of parents.

	     long 		msg;
	     struct GRid	axisId;
	     struct GRid	nullId;

	     nullId.objid = NULL_OBJID;

	     sts = vs$modify_stiffener_axis( msg	 = &msg,
	     				     axisId	 = &axisId,
					     startSurfId = &nullId,
					     endSurfId   = &nullId ) ;
        * 'extPastTrim' - Extend Past Trimming Command
 
        * 'orientToCurve' - Orient axis based on support curve
                            vice support surface
 
        * 'extToTrim' - Extend to trimming surfaces going past
                        edge of plate if required
                        Use only for short extensions if axis
                        is curved

-M*/
extern long
VSmodify_stiffener_axis	__((	long			*msg,
			        struct GRid		*axisId,
			        struct GRid		*plateId,
			        struct GRmd_env		*plateEnv,
			        struct GRid		*directionId,
			        struct GRmd_env		*directionEnv,
			        struct GRid		*startSurfId,
			        struct GRmd_env		*startSurfEnv,
			        struct GRid		*endSurfId,
			        struct GRmd_env		*endSurfEnv,
			        int			*topOfPlate,
                                int                     extPastTrim,
                                int                     orientToCurve,
                                int                     extToTrim[2] )) ;

#omdef vs$modify_stiffener_axis( msg,
			         axisId,
			         plateId	= NULL,
			         plateEnv	= NULL,
			         directionId	= NULL,
			         directionEnv	= NULL,
			         startSurfId	= NULL,
			         startSurfEnv	= NULL,
			         endSurfId	= NULL,
			         endSurfEnv	= NULL,
			         topOfPlate 	= NULL,
                                 extPastTrim    = FALSE,
                                 orientToCurve  = FALSE,
                                 extToTrim      = NULL)

	VSmodify_stiffener_axis( (msg),
			         (axisId),
			         (plateId),
			         (plateEnv),
			         (directionId),
			         (directionEnv),
			         (startSurfId),
			         (startSurfEnv),
			         (endSurfId),
			         (endSurfEnv),
			         (topOfPlate),
                                 (extPastTrim),
                                 (orientToCurve),
                                 (extToTrim))
#endomdef
/* ************************************************************************** */
/* ************************************************************************** */
/*+M
Macro vs$modify_joint

Abstract
	This macro modifies a joint.
Arguments
	OUT	long		 *msg		 Completion code.
	IN	struct GRid	 *jointId	 The joint to modify.
	IN	int		 *weldCode	 Weld code (cf 'vsAPIwelddef.h').
	IN	int		 *weldProcess	 Weld process (cf 'vsAPIwelddef.h').
	IN	int		 *weldInfo	 Weld info (cf 'vsAPIwelddef.h').
	IN	int		 *weldContour	 Weld contour (cf 'vsAPIwelddef.h').
	IN	int		 *weldSide	 Weld side (cf 'vsAPIwelddef.h').
	IN	double		 *allowance	 Joint allowance value.
	IN	double		 *grooveAngle	 Joint groove angle value.
	IN	double		 *pitch		 Joint pitch value.
	IN	double		 *lengthOfIncr	 Length of increments value.
	IN	char		 *usrSymbol	 User symbol for joint.
	IN	int		 *fieldWeld	
	IN	int		 *weldPosition	Position of weld 
						 *weldPosition = 0,
								 1,
								 2,
								 3.
					
	IN	double		 *shrinkage	
	IN	struct GRid	 *UAid		 Id of collection of user
						 attributes.
Notes
	* The macro returns MSSUCC if succesfull or MSFAIL if an error
          occur in argument 'msg'.

	* All arguments can be NULL except 'msg' and 'jointId'.
-M*/
extern long
VSmodify_joint		__((	long			*msg,
				struct GRid		*jointId,
				int			*weldCode,
				int			*weldProcess,
				int			*weldInfo,
				int			*weldContour,
				int			*weldSide,
				double			*allowance,
				double			*grooveAngle,
				double			*pitch,
				double			*lengthOfIncr,
				char			*usrSymbol,
				int                     *fieldWeld, 
				int                     *weldPosition, 
				double                  *shrinkage, 
				struct GRid		*UAid )) ;

#omdef vs$modify_joint( msg,
		        jointId,
		        weldCode	= NULL,
		        weldProcess	= NULL,
		        weldInfo	= NULL,
		        weldContour	= NULL,
		        weldSide	= NULL,
		        allowance	= NULL,
		        grooveAngle	= NULL,
		        pitch		= NULL,
		        lengthOfIncr	= NULL,
			usrSymbol	= NULL,
			fieldWeld       = NULL, 
			weldPosition    = NULL, 
			shrinkage       = NULL, 
		        UAid 		= NULL )

	VSmodify_joint( (msg),
		        (jointId),
		        (weldCode),
		        (weldProcess),
		        (weldInfo),
		        (weldContour),
		        (weldSide),
		        (allowance),
		        (grooveAngle),
		        (pitch),
		        (lengthOfIncr),
			(usrSymbol),
			(fieldWeld), 
			(weldPosition), 
			(shrinkage), 
		        (UAid) )
#endomdef
/* ************************************************************************** */

/* ************************************************************************** */
/*+M
Macro vs$split_plate

Abstract
	This macro splits a plate with a given geometric element.
Arguments
	OUT	long		 *msg		Completion code.
	IN	struct GRid	 *plateId	Id of plate to be split.
	IN	struct GRmd_env	 *plateEnv	Env of plate to be split.
	IN	struct GRid	 *cutterId	Id of splitting object.
	IN	struct GRmd_env	 *cutterEnv	Env of splitting object.
	OUT	struct GRid	 splitId[2]	Resulting split plates.
Notes
	* The macro returns MSSUCC if succesfull or MSFAIL if an error
	  occur in argument 'msg'.

	* 'plateId' and 'plateEnv' refer to the plate to be split. It can be
	  in a reference file.

	* 'cutterId' and 'cutterEnv' refer to the geometric object ( only a
	  curve or a plane ) used to split the plate. It can be in a 
	  reference file.

	* If you want to place a joint between the two results, just call
	  after this macro:

	  struct GRid		jointId ;
	  struct GRmd_env	elemEnv[2] ;

	  .
	  ,
	  Retrieve current environnement curEnv,

	  elemEnv[0] = elemEnv[1] = curEnv ;
	  .
	  .

	  sts = vs$place_joint( msg	= &msg,
	  		        jointId	= &jointId,
				elemId	= splitId,
				elemEnv = elemEnv ) ;
-M*/
extern long
VSsplit_plate	__((	long			*msg,
			struct GRid		*plateId,
			struct GRmd_env 	*plateEnv,
			struct GRid		*cutterId,
			struct GRmd_env 	*cutterEnv,
			struct GRid		splitId[2] )) ;

#omdef vs$split_plate(	msg,
			plateId,
			plateEnv,
			cutterId,
			cutterEnv,
			splitId )

	VSsplit_plate( (msg),
		       (plateId),
		       (plateEnv),
		       (cutterId),
		       (cutterEnv),
		       (splitId) )
#endomdef
/* ************************************************************************** */

/* ************************************************************************** */
/*+M
Macro vs$split_beam

Abstract
	This macro splits a beam with a given geometric element.
Arguments
	OUT	long		 *msg		Completion code.
	IN	struct GRid	 *beamId	Id of beam to be split.
	IN	struct GRmd_env	 *beamEnv	Env of beam to be split.
	IN	struct GRid	 *cutterId	Id of splitting object.
	IN	struct GRmd_env	 *cutterEnv	Env of splitting object.
	OUT	struct GRid	 splitId[2]	Resulting split beams.
Notes
	* The macro returns MSSUCC if succesfull or MSFAIL if an error
	  occur in argument 'msg'.

	* 'beamId' and 'beamEnv' refer to the beam to be split. It can be
	  in a reference file.

	* 'cutterId' and 'cutterEnv' refer to the geometric object ( only a
	  curve or a plane ) used to split the beam. It can be in a 
	  reference file.

	* If you want to place a joint between the two results, just call
	  after this macro:

	  struct GRid		jointId ;
	  struct GRmd_env	elemEnv[2] ;

	  .
	  ,
	  Retrieve current environnement curEnv,

	  elemEnv[0] = elemEnv[1] = curEnv ;
	  .
	  .

	  sts = vs$place_joint( msg	= &msg,
	  		        jointId	= &jointId,
				elemId	= splitId,
				elemEnv = elemEnv ) ;
-M*/
extern long
VSsplit_beam	__((	long			*msg,
			struct GRid		*beamId,
			struct GRmd_env 	*beamEnv,
			struct GRid		*cutterId,
			struct GRmd_env 	*cutterEnv,
			struct GRid		splitId[2] )) ;

#omdef vs$split_beam(	msg,
			beamId,
			beamEnv,
			cutterId,
			cutterEnv,
			splitId )

	VSsplit_beam(  (msg),
		       (beamId),
		       (beamEnv),
		       (cutterId),
		       (cutterEnv),
		       (splitId) )
#endomdef
/* ************************************************************************** */

/* ************************************************************************** */
/*+M
Macro vs$split_stiffener

Abstract
	This macro splits a stiffener with a given geometric element.
Arguments
	OUT	long		 *msg		Completion code.
	IN	struct GRid	 *stiffenerId	Id of stiffener to be split.
	IN	struct GRmd_env	 *stiffenerEnv	Env of stiffener to be split.
	IN	struct GRid	 *cutterId	Id of splitting object.
	IN	struct GRmd_env	 *cutterEnv	Env of splitting object.
	OUT	struct GRid	 splitId[2]	Resulting split stiffeners.
Notes
	* The macro returns MSSUCC if succesfull or MSFAIL if an error
	  occur in argument 'msg'.

	* 'stiffenerId' and 'stiffenerEnv' refer to the stiffener to be split.
	  It can be in a reference file.

	* 'cutterId' and 'cutterEnv' refer to the geometric object ( only a
	  curve or a plane ) used to split the stiffener. It can be in a 
	  reference file.

	* If you want to place a joint between the two results, just call
	  after this macro:

	  struct GRid		jointId ;
	  struct GRmd_env	elemEnv[2] ;

	  .
	  ,
	  Retrieve current environnement curEnv,

	  elemEnv[0] = elemEnv[1] = curEnv ;
	  .
	  .

	  sts = vs$place_joint( msg	= &msg,
	  		        jointId	= &jointId,
				elemId	= splitId,
				elemEnv = elemEnv ) ;
-M*/
extern long
VSsplit_stiffener	__((	long			*msg,
				struct GRid		*stiffenerId,
				struct GRmd_env 	*stiffenerEnv,
				struct GRid		*cutterId,
				struct GRmd_env 	*cutterEnv,
				struct GRid		splitId[2] )) ;

#omdef vs$split_stiffener(	msg,
				stiffenerId,
				stiffenerEnv,
				cutterId,
				cutterEnv,
				splitId )

	VSsplit_stiffener(  (msg),
		       	    (stiffenerId),
		       	    (stiffenerEnv),
		       	    (cutterId),
		       	    (cutterEnv),
		       	    (splitId) )
#endomdef
/* ************************************************************************** */

/* ************************************************************************** */
/*+M
Macro vs$get_plate_attributes

Abstract
	This macro retrieves attributes of a plate.
Arguments
	OUT	long		 *msg		 Completion code.
	IN	struct GRid	 *plateId	 The plate from which attributes
						 will be retrieved.
	OUT	char		 *plateName	 Plate name.
	OUT	VSdspRep	 *representation Representation of plate.
	OUT	char		 *matType	 Material type of plate.
	OUT	char		 *matGrade	 Material grade of plate.
	OUT	char		 *partFam	 Plate type of plate.
	OUT	char		 *partNum	 Tickness type of plate.
	OUT	char		 *usrNotes	 User notes.
	OUT	char		 *mtoSrc	 MTO source.
	OUT	char		 *mtoStk	 MTO stock.
	OUT	double		 *fireProofing	 Thickness of fireproofing
						 material.
	OUT	int		 *mtoChgNo	 MTO change request number.
	OUT	char		 *apprvStat	 Approval status.
	OUT	char		 *constStat	 Construction status.
	OUT	int		 *mbrClass	 Member class.
	OUT	int		 *mbrType	 Member type.
	OUT	int		 *orientation	 Orientation wrt support
						 surface.
	OUT	double		 *cutOff	 Cut-off thickness.
	OUT	double		 *offset	 Offset from support surface.
	OUT	double		 *thickness	 Thickness of plate.
	OUT	struct GRid	 *UAid		 Id of collection of user
						 attributes.
Notes
	* The macro returns MSSUCC if succesfull or MSFAIL if an error
          occur in argument 'msg'.

	* All arguments can be NULL except 'msg' and 'plateId'.
-M*/
extern long
VSget_plate_attributes	__((	long			*msg,
				struct GRid		*plateId,
			  	char			*plateName,
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

#omdef vs$get_plate_attributes( msg,
				plateId,
				plateName	= NULL,
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

	VSget_plate_attributes( (msg),
				(plateId),
				(plateName),
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
/* ************************************************************************** */

/* ************************************************************************** */
/*+M
Macro vs$get_beam_attributes

Abstract
	This macro retrieves attributes of a beam.
Arguments
	OUT	long		 *msg		 Completion code.
	IN	struct GRid	 *beamId	 The beam from which attributes
                                                 will be retrieved.
	OUT	char		 *beamName	 Beam name.
	OUT	VSdspRep	 *representation Representation of beam.
	OUT	char		 *matType	 Material type of beam.
	OUT	char		 *matGrade	 Material grade of beam.
	OUT	char		 *partFam	 Profile type of beam.
	OUT	char		 *partNum	 Profile name of beam.
	OUT	char		 *usrNotes	 User notes.
	OUT	char		 *mtoSrc	 MTO source.
	OUT	char		 *mtoStk	 MTO stock.
	OUT	double		 *fireProofing	 Thickness of fireproofing
						 material.
	OUT	int		 *mtoChgNo	 MTO change request number.
	OUT	char		 *apprvStat	 Approval status.
	OUT	char		 *constStat	 Construction status.
	OUT	int		 *mbrClass	 Member class.
	OUT	int		 *mbrType	 Member type.
	OUT	struct GRid	 *UAid		 Id of collection of user
						 attributes.
	OUT	double		 *xOffset	 X-offset of beam wrt
						 support axis.
	OUT	double		 *yOffset	 Y-offset of beam wrt
						 support axis.
	OUT	double		 *rotAngle	 Angle of beam wrt support
						 axis.
	OUT	enum VScardinal_point
				 *cardPnt	Cardinal point of cross-section.
	OUT	enum VSsymmetry  *symmetry	Symmetry of beam wrt
						support axis.
Notes
	* The macro returns MSSUCC if succesfull or MSFAIL if an error
          occur in argument 'msg'.

	* All arguments can be NULL except 'msg' and 'beamId'.
-M*/
extern long
VSget_beam_attributes	__((	long			*msg,
				struct GRid		*beamId,
				char			*beamName,
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
				enum VSsymmetry 	*symmetry )) ;

#omdef vs$get_beam_attributes( msg,
			       beamId,
			       beamName		= NULL,
			       representation	= NULL,
			       matType		= NULL,
			       matGrade		= NULL,
			       partFam		= NULL,
			       partNum		= NULL,
			       usrNotes		= NULL,
			       mtoSrc		= NULL,
			       mtoStk		= NULL,
			       fireProofing 	= NULL,
			       mtoChgNo		= NULL,
			       apprvStat	= NULL,
			       constStat	= NULL,
			       mbrClass		= NULL,
			       mbrType		= NULL,
			       UAid 		= NULL,
			       xOffset		= NULL,
			       yOffset		= NULL,
			       rotAngle		= NULL,
			       cardPnt		= NULL,
			       symmetry		= NULL )

	VSget_beam_attributes( (msg),
			       (beamId),
			       (beamName),
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
			       (symmetry) )
#endomdef
/* ************************************************************************** */

/* ************************************************************************** */
/*+M
Macro vs$get_stiffener_attributes

Abstract
	This macro retrieves attributes of a stiffener.
Arguments
	OUT	long		 *msg		 Completion code.
	IN	struct GRid	 *stiffenerId	 The stiffener from which
						 attributes will be retrieved.
	OUT	char		 *stiffenerName	 Stiffener name.
	OUT	VSdspRep	 *representation Representation of stiffener.
	OUT	char		 *matType	 Material type of stiffener.
	OUT	char		 *matGrade	 Material grade of stiffener.
	OUT	char		 *partFam	 Profile type of stiffener.
	OUT	char		 *partNum	 Profile name  of stiffener.
	OUT	char		 *usrNotes	 User notes.
	OUT	char		 *mtoSrc	 MTO source.
	OUT	char		 *mtoStk	 MTO stock.
	OUT	double		 *fireProofing	 Thickness of fireproofing
						 material.
	OUT	int		 *mtoChgNo	 MTO change request number.
	OUT	char		 *apprvStat	 Approval status.
	OUT	char		 *constStat	 Construction status.
	OUT	int		 *mbrClass	 Member class.
	OUT	int		 *mbrType	 Member type.
	OUT	struct GRid	 *UAid		 Id of collection of user
						 attributes.
	OUT	double		 *xOffset	 X-offset of stiffener wrt
						 support axis.
	OUT	double		 *yOffset	 Y-offset of stiffener wrt
						 support axis.
	OUT	double		 *rotAngle	 Angle of stiffener wrt support
						 axis.
	OUT	enum VScardinal_point
				 *cardPnt	 Cardinal point of
						 cross-section.
	OUT	enum VSsymmetry  *symmetry	 Symmetry of stiffener wrt
						 support axis.
	OUT	int		 *alongPlane	 Stiffener is placed along
						 plane.
Notes
	* The macro returns MSSUCC if succesfull or MSFAIL if an error
          occur in argument 'msg'.

	* All arguments can be NULL except 'msg' and 'stiffenerId'.
-M*/
extern long
VSget_stiffener_attributes	__((	long			*msg,
					struct GRid		*stiffenerId,
					char			*stiffenerName,
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

#omdef vs$get_stiffener_attributes( msg,
				    stiffenerId,
				    stiffenerName	= NULL,
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

	VSget_stiffener_attributes( (msg),
				    (stiffenerId),
				    (stiffenerName),
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
/* ************************************************************************** */

/* ************************************************************************** */
/*+M
Macro vs$modify_user_attribute

Abstract
	This macro modifies user attributes of a structural element.
Arguments
	OUT	long		 *msg		 Completion code.
	IN	struct GRid	 *elemId	 The structural element.
	IN	char		 *attName	 User attribute name.
	IN	char		 *attValue	 User attribute value.
Notes
	* The macro returns MSSUCC if succesfull or MSFAIL if an error
          occur in argument 'msg'.

	* 'elemId' is the structural element whom user attribute will be
	  modified. It can be a plate, a beam, a stiffener, ...

	* 'attName' is the user attribute name that will be modified.

	* 'attValue' is the new user attribute value.
	  Default value is NULL.

	* Behavior :
	  If 'attName' exists as an user attribute name :
		If 'attValue' is NULL, this attribute will deleted.
		If 'attValue' is not NULL, this attribute value will modified.
	  If 'attName' don't exist as an user attribute name :
		If 'attValue' is NULL, nothing will be done.
		If 'attValue' is not NULL, this new attribute will created.
-M*/
extern long
VSmodify_user_attribute	__((	long			*msg,
				struct GRid		*elemId,
				char			*attName,
				char			*attValue )) ;

#omdef vs$modify_user_attribute( msg,
				 elemId,
				 attName,
				 attValue 	= NULL )

	VSmodify_user_attribute( (msg),
				 (elemId),
				 (attName),
				 (attValue) )
#endomdef
/* ************************************************************************** */

/* ************************************************************************** */
/*+M
Macro vs$create_shell_expansion

Abstract
	This macro creates a shell expansion plane.
Arguments
	OUT	long		 *msg		Completion code.
	IN	struct GRid	 *shellId	Id of shell surface.
	IN	struct GRmd_env  *shellEnv	Env of shell surface.
	IN	struct GRid	 *rPlanId	Id of reference plane.
	IN	struct GRmd_env	 *rPlanEnv	Env of reference plane.
	IN	struct GRid	 *sPlanId	Id of start plane limit.
	IN	struct GRmd_env	 *sPlanEnv	Env of start plane limit.
	IN	struct GRid	 *ePlanId	Id of end plane limit.
	IN	struct GRmd_env	 *ePlanEnv	Env of end plane limit.
	OUT	struct GRid	 *xPlanId	Shell expansion plane.
Notes
	* The macro returns MSSUCC if succesfull or MSFAIL if an error
          occur in argument 'msg'.

	* 'shellId' and 'shellEnv' define the shell surface to be expanded.
	  It can be attached, in reference, to the current file.
	  See below for position of this shell.
	  If 'shellEnv' is NULL, the current object space is taken by default.

	* 'rPlanId' and 'rPlanEnv' define the reference plane of the shell 
	  expansion. See below for position of this plane.
	  It can be attached, in reference, to the current file.
	  If 'rPlanId' is NULL, no reference plane is taken.
	  If 'rPlanEnv' is NULL, the current object space is taken by default.

	* 'sPlanId' and 'sPlanEnv' define the start plane limit of the shell 
	  expansion. See below for position of this plane.
	  It can be attached, in reference, to the current file.
	  If 'sPlanId' is NULL, no start plane limit is taken.
	  If 'sPlanEnv' is NULL, the current object space is taken by default.

	* 'ePlanId' and 'ePlanEnv' define the end plane limit of the shell 
	  expansion. See below for position of this plane.
	  It can be attached, in reference, to the current file.
	  If 'ePlanId' is NULL, no end plane limit is taken.
	  If 'ePlanEnv' is NULL, the current object space is taken by default.

	* 'xPlanId' is the shell expansion plane, result of this macro.
	  This a VSshellExp class object.

	* Position of each elements.

		---------------------------------------------  <- Shell.
		|					    /
		|					   /
     rPlan.	|					  /
	|	|					 /
	v	|					/
       ---	|					\
		|					 \
		|					 /
	Z	|					/
	^	----------------------------------------
	|
	---> X		|		    |

			^		    ^
			|		    |
		     sPlan		  ePlan

				 |
				 |
				 V

			---------------------
			|		    |
			|		    |
			|		    |
			|		    |  <- Shell expansion (xPlan).
			|		    |
			|		    |
			|		    |
			 \		   /
			  \		  /
			   \		 /
			    -------------


	The shell is the half hull along Y-axis.


		---------------------------------------------  
		|					    /
		|					   /
           	|					  /
	 	|					 /
	 	|					/
          	|					\
		|					 \
		|					 /
	Z	|					/
	^	----------------------------------------
	|
	---> X		 		     


	Y	---------------------------------
		|     				 \
	^	|   			   	  \---
	|	| 			    	      \
	---> X  ----------------------------------------


	The surface constructed is the unfolding of the shell with respect
	to the reference plane along the Z-axis ( between start and end plane ).

		- rPlan is optional, thus in this case the XY plane
		  defining the reference plane will be the XY plane at Z=0.

		- sPlan and ePlan are optionals, thus in this case
		  the entire shell will be process.
-M*/
extern long
VScreate_shell_expansion	__((	long			*msg,
					struct GRid		*shellId,
					struct GRmd_env 	*shellEnv,
					struct GRid		*rPlanId,
					struct GRmd_env 	*rPlanEnv,
					struct GRid		*sPlanId,
					struct GRmd_env 	*sPlanEnv,
					struct GRid		*ePlanId,
					struct GRmd_env 	*ePlanEnv,
					struct GRid		*xPlanId )) ;

#omdef vs$create_shell_expansion(	msg,
					shellId,
					shellEnv	= NULL,
					rPlanId		= NULL,
					rPlanEnv	= NULL,
					sPlanId		= NULL,
					sPlanEnv	= NULL,
					ePlanId		= NULL,
					ePlanEnv	= NULL,
					xPlanId )

	VScreate_shell_expansion( (msg),
		       		  (shellId),
		       		  (shellEnv),
		       		  (rPlanId),
		       		  (rPlanEnv),
		       		  (sPlanId),
		       		  (sPlanEnv),
		       		  (ePlanId),
		       		  (ePlanEnv),
		       		  (xPlanId) )
#endomdef
/* ************************************************************************** */

/* ************************************************************************** */
/*+M
Macro vs$expand_shell_curve

Abstract
	This macro expand shell curve on a shell expansion plane.
Arguments
	OUT	long		 *msg		Completion code.
	IN	struct GRid	 *xPlanId	Shell expansion plane.
	IN	struct GRid	 *sCurvId	Id of shell curve.
	IN	struct GRmd_env  *sCurvEnv	Env of shell curve.
	IN	struct GRid	 *xCurvId	Id of expanded curve.
Notes
	* The macro returns MSSUCC if succesfull or MSFAIL if an error
          occur in argument 'msg'.

	* 'xPlanId' is the shell expansion plane.

	* 'sCurvId' and 'sCurvEnv' define the shell curve to be expanded.
	  It can be attached, in reference, to the current file.
	  If 'sCurvEnv' is NULL, the current object space is taken by default.

	* 'xCurvId' is the shell expanded curve object.
-M*/
extern long
VSexpand_shell_curve	__((	long			*msg,
				struct GRid		*xPlanId,
				struct GRid		*sCurvId,
				struct GRmd_env 	*sCurvEnv,
				struct GRid		*xCurvId )) ;

#omdef vs$expand_shell_curve(	msg,
				xPlanId,
				sCurvId,
				sCurvEnv	= NULL,
				xCurvId )

	VSexpand_shell_curve( (msg),
			      (xPlanId),
			      (sCurvId),
			      (sCurvEnv),
			      (xCurvId) )
#endomdef
/* ************************************************************************** */

/* ************************************************************************** */
/*+M
Macro vs$merge_shell_expansion

Abstract
	This macro merges two shell expansions.
Arguments
	OUT	long		 *msg		Completion code.
	IN	struct GRid	 *frXpansId	Id of "from" shell expansion.
	IN	struct GRmd_env	 *frXpansEnv	Env of "from" shell expansion.
	IN	struct GRid	 *toXpansId	Id of "to" shell expansion.
	IN	struct GRmd_env	 *toXpansEnv	Env of "to" shell expansion.
	OUT	struct GRid	 *mgXpansId	Merged shell expansion plane.
Notes
	* The macro returns MSSUCC if succesfull or MSFAIL if an error
          occur in argument 'msg'.

	* 'frXpansId' and 'frXpansEnv' define the "from" shell expansion plane.
	  This is a shell expansion or a merged shell expansion plane.
  	  If 'frXpansEnv' is NULL, the current object space is taken by default.

	* 'toXpansId' and 'toXpansEnv' define the "to" shell expansion plane.
	  This is a shell expansion or a merged shell expansion plane.
  	  If 'toXpansEnv' is NULL, the current object space is taken by default.

	* 'mgXpansId' is the merge expansion plane.
-M*/
extern long
VSmerge_shell_expansion	__((	long			*msg,
				struct GRid		*frXpansId,
				struct GRmd_env		*frXpansEnv,
				struct GRid		*toXpansId,
				struct GRmd_env		*toXpansEnv,
				struct GRid		*mgXpansId )) ;

#omdef vs$merge_shell_expansion(	msg,
					frXpansId,
					frXpansEnv	= NULL,
					toXpansId,
					toXpansEnv	= NULL,
					mgXpansId )

	VSmerge_shell_expansion( (msg),
		       		 (frXpansId),
				 (frXpansEnv),
		       		 (toXpansId),
				 (toXpansEnv),
		       		 (mgXpansId) )
#endomdef
/* ************************************************************************** */

/* ************************************************************************** */
/*+M
Macro vs$move_and_mirror_stiffener

Abstract
	This macro moves a stiffener in a mirror position (symetry regarding
	the support surface of the stiffener).
Arguments
	OUT	long		 *msg		 Completion code.
	IN	struct GRid	 *stiffenerId	 The stiffener that will be
						 moved and mirrored.
Notes
	* The macro returns MSSUCC if succesfull or MSFAIL if an error
          occur in argument 'msg'.

	* 'stiffenerId' is the target stiffener. It must be in the current
	  object space.

-M*/
extern long
VSmove_and_mirror_stiffener	__((	long		*msg,
					struct GRid	*stiffenerId )) ;

#omdef vs$move_and_mirror_stiffener( msg,
				     stiffenerId )

	VSmove_and_mirror_stiffener( (msg),
				     (stiffenerId) )
#endomdef
/* ************************************************************************** */
/*----------------------------------------------------------------------------*/
/*+M
macro vs$get_stf_angle 

ABSTRACT

Arguments
	OUT  long                     *msg        Completion Code
	IN   struct GRobj_env         stiffener   The stiffener object
	IN   double                   *param      Parameter at the point angle 
						  is needed
	IN   struct GRobj_env         oprObj      If param is not specified,
						  then provide a plane object.
	OUT  double 		      *angle      The angle between plate and
						  stiffener.
-M*/
extern  long 
VSangleBetStfAndPlate		__(( long                *msg, 
				     struct GRobj_env    stf,  
				     double              *param ,
				     struct GRobj_env    surface,
				     double              *angle));
#omdef vs$get_stf_angle( msg, 
			 stf,  
			 param,
			 surface,
			 angle)

	VSangleBetStfAndPlate( 	( msg ),  
				( stf ),  
				( param ),
				( surface ),
				( angle ) )
#endomdef
/* ************************************************************************** */

#endif /* vsAPImacros_include */

