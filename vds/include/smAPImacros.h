/* $Id: smAPImacros.h,v 1.1.1.1 2001/01/04 21:07:31 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	include/smAPImacros.h
 *
 * Description:
 *		API support macros for frame system and single plane objects.
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: smAPImacros.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:31  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.4  1998/03/27  21:45:14  pinnacle
 * CR179800868
 *
 * Revision 1.3  1998/03/27  19:50:52  pinnacle
 * CR_179800868: Included unique prototypes from smframeapi.h, then deleted smframeapi.h
 *
 * Revision 1.2  1997/09/19  18:47:08  pinnacle
 * Replaced: include/smAPImacros.h for:  by impd for vds
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.2  1996/09/26  06:40:42  pinnacle
 * Replaced: include/smAPImacros.h for:  by ksundar for vds.241
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.2  1996/03/25  16:10:24  pinnacle
 * Replaced: ./include/smAPImacros.h for:  by azuurhou for vds.240
 *
 * Revision 1.1  1996/02/20  20:33:20  pinnacle
 * Created: ./include/smAPImacros.h by azuurhou for vds.240
 *
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *		   i-paris	creation date
 *	03/27/98   ejm		CR_179800868  Brought in code from smframeapi.h,
 *				deleting prototypes already existing in this
 *				file and keeping CFS, MFS, CSP prototypes.
 *
 ***************************************************************************/

#ifndef smAPImacros_include
#	define smAPImacros_include

#ifndef smframedef_include
#       include "smframedef.h"
#endif

/* ************************************************************************** */
/*+M
Macro sm$create_frame_system

Abstract
	This macro creates a frame system object.
Arguments
	OUT	long		 *msg		Completion code.
	IN	char		 *name		Name given to the frame system.
	IN	int		 frameDisplay	Frame display toggle.
	IN	struct GRid	 *csId		Id of coordinate system.
	IN	int		 axis		Selected axis.
	IN	int		 orientation	Axis orientation.
	IN	double		 *revDistance	Reverse distance.
	IN	int		 regulSize	Size of regular frames.
	IN	double		 *regulValue	Size value of an EMS plane.
	IN	int		 reinfSize	Size of reinforced frames.
	IN	double		 *reinfValue	Size value of an EMS plane.
	IN	char		 *annotation	Prefix of frames.
	IN	double		 originOffset	Origin offset value, along axis.
	IN	int		 wJustif	Width justification.
	IN	int		 hJustif	Height justification.
	IN	int		 sectionNumber	Number of sections.
	IN	char		 *distanceUnit	Unit use for distances.
	IN	int		 sectionOption	Type of section definition.
	IN	int		 *frNumber	From frame numbers.
	IN	int		 *toNumber	To frame numbers.
	IN	double		 *spacing	Spacings between frames.
	IN	double		 *frDistance	From distance along axis.
	IN	double		 *toDistance	To distance along axis.
	IN	int		 *frameNumber	Number of frames.
	IN	int		 *layerOffset	Layer where frames will be
						created.
						Offset from active layer.
	IN	char		 *reinforce	Parse string describing which
						frames will be reinforced.
	IN	char		 *reverse	Parse string describing which
						frames will be reversed.
	OUT	struct GRid	 *frameSystemId	Resulting frame system.
Notes
	* The macro returns MSSUCC if succesfull or MSFAIL if an error
          occur in argument 'msg'.

	* 'name' is the name that will be given to the frame system.
	  Default value is "Fx".

	* 'frameDisplay' is a toggle between two display options :
	  SM_FD_Number : frame will be "<annotation><frame number>".
	  SM_FD_Distance : frame will be "<frame distance>"
	  'frameDisplay' must be select in "smframedef.h" in the 1st section
	  called "FRAME DISPLAY or SECTION DEFINITION".
	  Default value is SM_FD_Number.

	* 'csId' is the coordinate system that will be the reference
	  for frames construction.
  
	* 'axis' defines the cs axis that will be orthogonal to the frames.
	  'axis' must be select in "smframedef.h" in the 2nd section
	  called "FRAME AXIS".
	  Default value is SM_FA_Xaxis.

	* 'orientation' defines if the regular frames are reversed (normal
	  opposed to cs axis).
	  'orientation' must be select in "smframedef.h" in the 3rd section
	  called "FRAME ORIENTATION".
	  Default value is SM_FO_Parallel.
	
	* '*revDistance' is the distance from cs where the planes are reversed.
	  Default value is NULL.

	* 'regulSize' defines the size of regular frames.
	  'regulSize' must be select in "smframedef.h" in the 4th section
	  called "PLANE SIZE (REGULAR and REINFORCED)".
	  Default value is SM_FS_Regular.

	* '*regulValue' defines the size of regular frames when 'regulSize'
	  is SM_FS_Ems.
	  Default value is NULL.

	* 'reinfSize' defines the size of reinforced frames.
	  'reinfSize' must be select in "smframedef.h" in the 4th section
	  called "PLANE SIZE (REGULAR and REINFORCED)".
	  Default value is SM_FS_Large.

	* '*reinfValue' defines the size of reinforced frames when 'reinfSize'
	  is SM_FS_Ems.
	  Default value is NULL.

	* 'annotation' defines the name that will prefix the frames' number.
	  Default value is "F".

	* 'originOffset' defines the gap between cs origin and first frame.
	  Default value is 0.0.

	* 'wJustif' defines the width justification of the frame.
	  'wJustif' must be select in "smframedef.h" in the 5th section
	  called "PLANE WIDTH JUSTIFICATION".
	  Default value is SM_FJ_Width_Center.

	* 'hJustif' defines the height justification of the frame.
	  'hJustif' must be select in "smframedef.h" in the 6th section
	  called "PLANE HEIGHT JUSTIFICATION".
	  Default value is SM_FJ_Height_Center.

	* 'sectionNumber' is the number of frames's definition (sections).

	* '*distanceUnit' defines what kind of units of measure is used to 
	  define the '*revDistance', 'regulValue', 'reinfValue', 'originOffset',
	  'spacing[]', 'frDistance[]' & 'toDistance[]' values.
	  Default value is "mm" (millimeters).

	* 'sectionOption' set if sections are by NUMBER ( frNumber, toNumber &
	  spacing ) or by DISTANCE ( frDistance, toDistance & frameNumber ).
	  'sectionOption' must be select in "smframedef.h" in the 1st section
	  called "FRAME DISPLAY or SECTION DEFINITION".
	  Default value is SM_FD_Number.

	* 'frNumber' is array of 'sectionNumber' integers defining the first
	  frame number, for each set of frames.
	  Used when 'sectionOption' is set to NUMBER.
	  Default value is NULL.

	* 'toNumber' is array of 'sectionNumber' integers defining the last
	  frame number, for each set of frames.
	  Used when 'sectionOption' is set to NUMBER.
	  Default value is NULL.

	* 'spacing' is array of 'sectionNumber' doubles defining the spacing
	  between following frames, for each set of frames.
	  Used when 'sectionOption' is set to NUMBER.
	  Default value is NULL.

	* 'frDistance' is array of 'sectionNumber' doubles defining the first
	  frame distance, for each set of frames.
	  Used when 'sectionOption' is set to DISTANCE.
	  Default value is NULL.

	* 'toDistance' is array of 'sectionNumber' doubles defining the last
	  frame distance, for each set of frames.
	  Used when 'sectionOption' is set to DISTANCE.
	  Default value is NULL.

	* 'frameNumber' is array of 'sectionNumber' integers defining the total
	  number of frames, for each set of frames.
	  Used when 'sectionOption' is set to DISTANCE.
	  Default value is NULL.

	* 'layerOffset' is array of 'sectionNumber' integers defining the layer
	  offset (from active layer), for each set of frames.
	  Default value is NULL that will be taken as an array of zeros.

	* 'reinforce' is a parse string (see example) defining which frames
	  will take the 'reinfSize' value.
	  Default value is NULL.

	* 'reverse' is a parse string (see example) defining which frames
	  will be reversed (normal opposed to cs axis if 'orientation' is
	  parallel, normal parallel to cs axis if 'orientation' is reverse).
	  Also 'revDistance' parameter have influence ...
	  Default value is NULL.

	* 'frameSystemId' is the constructed frame system.

	* Example :

	  1) Simple example :
	  	long		msg,
	  	struct GRid	coordSystem;
	  	int		first[1];
	  	int		last[1];
	  	double		between[1];
	  	int		layer[1];
	  	struct GRid	frameSystem;

	  .
	  locate a coordinate system to fill coordSystem structure.
	  .
	  first[0]   = 0;
	  last[0]    = 3;
	  between[0] = 100.0;
	  layer[0]   = 1;
	  sts = sm$create_frame_system ( msg		= &msg,
					 csId		= &coordSystem,
					 sectionNumber	= 1,
					 frNumber	= first,
					 toNumber	= last,
					 spacing	= between,
					 layerOffset	= layer,
					 frameSystemId	= &frameSystem );
	  if( !( sts & 1 & msg ) )
		printf( "Error in creation of frame system\n" ) ;

	  --> The frame system Fx will be created.
	      Fx held 4 frames ( F0, F1, F2 & F3 ), at ( 0, 100, 200 & 300 )
	      millimeters of newCs center, along newCs X axis.
	      The 4 frames are displayed with regular size on active layer+1.


	  2) Complex example :
	  	long		msg,
	  	struct GRid	coordSystem;
		double		rDist;
	  	double		first[4];
	  	double		last[4];
	  	int		number[4];
	  	int		layer[4];
		char		reinf[80];
		char		rever[80];
	  	struct GRid	frameSystem;

	  .
	  locate a coordinate system to fill coordSystem structure.
	  .
	  rDist = 5000.0;
          first[0] = -500.0; last[0] = -200.0; number[0] =  3; layer[0] = 1;
          first[1] = -200.0; last[1] = 2000.0; number[1] = 11; layer[1] = 2;
          first[2] = 2000.0; last[2] = 3000.0; number[2] = 10; layer[2] = 3;
          first[3] = 3000.0; last[3] = 9000.0; number[3] = 20; layer[3] = 4;
          strcpy( reinf, "[0-35,5]");
          strcpy( rever, "[0-20,2]");
	  sts = sm$create_frame_system ( msg		= &msg,
					 name		= "Buttocks",
					 csId		= &coordSystem,
					 axis		= SM_FA_Yaxis,
					 orientation	= SM_FO_Reversed,
					 revDistance	= &rDist,
					 regulSize	= SM_FS_Small,
					 reinfSize	= SM_FS_Regular,
					 annotation	= "btk",
					 originOffset   = 1000.0,
					 sectionNumber	= 4,
					 sectionOption  = SM_FD_Distance,
					 frDistance	= first,
					 toDistance	= last,
					 frameNumber	= number,
					 layerOffset	= layer,
					 reinforce	= reinf,
					 reverse	= rever,
					 frameSystemId	= &frameSystem );
	  if( !( sts & 1 & msg ) )
		printf( "Error in creation of frame system\n" ) ;
-M*/
extern long
SMcreate_frame_system	__((	long			*msg,
				char			*name,
				int			frameDisplay,
				struct GRid		*csId,
				int			axis,
				int			orientation,
				double			*revDistance,
				int			regulSize,
				double			*regulValue,
				int			reinfSize,
				double			*reinfValue,
				char			*annotation,
				double			originOffset,
				int			wJustif,
				int			hJustif,
				int			sectionNumber,
				char			*distanceUnit,
				int			sectionOption,
				int			*frNumber,
				int			*toNumber,
				double			*spacing,
				double			*frDistance,
				double			*toDistance,
				int			*frameNumber,
				int			*layerOffset,
				char			*reinforce,
				char			*reverse,
				struct GRid		*frameSystemId )) ;

#omdef sm$create_frame_system(	msg,
				name		= "Fx",
				frameDisplay	= SM_FD_Number,
				csId,
				axis		= SM_FA_Xaxis,
				orientation	= SM_FO_Parallel,
				revDistance	= NULL,
				regulSize	= SM_FS_Regular,
				regulValue	= NULL,
				reinfSize	= SM_FS_Large,
				reinfValue	= NULL,
				annotation	= "F",
				originOffset	= 0.0,
				wJustif 	= SM_FJ_Width_Center,
				hJustif 	= SM_FJ_Height_Center,
				sectionNumber,
				distanceUnit 	= "mm",
				sectionOption 	= SM_FD_Number,
				frNumber 	= NULL,
				frDistance 	= NULL,
				toNumber 	= NULL,
				toDistance 	= NULL,
				spacing 	= NULL,
				frameNumber 	= NULL,
				layerOffset	= NULL,
				reinforce 	= "",
				reverse 	= "",
				frameSystemId )

#if om$equal (sectionOption,SM_FD_Number)
#	if om$equal(frNumber,NULL) || om$equal(toNumber,NULL) || om$equal(spacing,NULL)
#		omerror "frNumber, toNumber & spacing must be given"
#	else
		SMcreate_frame_system( (msg),
				       (name),
				       (frameDisplay),
				       (csId),
				       (axis),
				       (orientation),
				       (revDistance),
				       (regulSize),
				       (regulValue),
				       (reinfSize),
				       (reinfValue),
				       (annotation),
				       (originOffset),
				       (wJustif),
				       (hJustif),
				       (sectionNumber),
				       (distanceUnit),
				       SM_FD_Number,
				       (frNumber),
				       (toNumber),
				       (spacing),
				       NULL,
				       NULL,
				       NULL,
				       (layerOffset),
				       (reinforce),
				       (reverse),
				       (frameSystemId) )
#	endif
#elif om$equal (sectionOption,SM_FD_Distance)
#	if om$equal(frDistance,NULL) || om$equal(toDistance,NULL) || om$equal(frameNumber,NULL)
#		omerror "frDistance, toDistance & frameNumber must be given"
#	else
		SMcreate_frame_system( (msg),
				       (name),
				       (frameDisplay),
				       (csId),
				       (axis),
				       (orientation),
				       (revDistance),
				       (regulSize),
				       (regulValue),
				       (reinfSize),
				       (reinfValue),
				       (annotation),
				       (originOffset),
				       (wJustif),
				       (hJustif),
				       (sectionNumber),
				       (distanceUnit),
				       SM_FD_Distance,
				       NULL,
				       NULL,
				       NULL,
				       (frDistance),
				       (toDistance),
				       (frameNumber),
				       (layerOffset),
				       (reinforce),
				       (reverse),
				       (frameSystemId) )
#	endif
#else
#	omerror "sectionOption must be SM_FD_Number or SM_FD_Distance"
#endif

#endomdef
/* ************************************************************************** */

/* ************************************************************************** */
/*+M
Macro sm$create_single_plane

Abstract
	This macro creates a single plane object.
Arguments
	OUT	long		 *msg		Completion code.
	IN	struct GRid	 *csId		Id of coordinate system.
	IN	struct GRmd_env  *csEnv		Env of coordinate system.
	IN	int		 axis		Selected axis.
	IN	double		 distance	Distance from cs along axis.
	IN	char		 *distanceUnit	Unit use for distances.
	IN	int		 planeSize	Size of the plane generated.
	IN	double		 *planeValue	Size value of an EMS plane.
	IN	char		 *name		Name given to the plane.
	IN	char		 *label		Label given to the plane.
	IN	int		 orientation	Is the plane reversed ?
	IN	int		 wJustif	Width justification :
	IN	int		 hJustif	Height justification :
	OUT	struct GRid	 *singlePlaneId	Resulting single plane.
Notes
	* The macro returns MSSUCC if succesfull or MSFAIL if an error
          occur in argument 'msg'.

	* 'csId' and 'csEnv' is the coordinate system that will be the reference
	  for plane construction.
  
	* 'axis' defines the cs axis that will be orthogonal to the plane.
	  'axis' must be select in "smframedef.h" in the 2nd section
          called "FRAME AXIS".
	  Default value is SM_FA_Xaxis.

	* 'distance' defines the distance from the cs center to the plane.
	  It can be negative. Default value is 0.0.

	* '*distanceUnit' defines what kind of units of measure is used to 
	  define the 'distance' & '*plnValue' values.
	  To be consistent with Frame System macros, an unit of measure
	  can be used. The conversion to internal units is automatic.
	  Default value is "mm" (millimeters).

	* 'planeSize' defines the size of plane.
	  'planeSize' must be select in "smframedef.h" in the 4th section
          called "PLANE SIZE (REGULAR and REINFORCED)".
          Default value is SM_FS_Regular.

	* '*planeValue' defines the size of regular frames when 'planeSize'
	  is SM_FS_Ems.
	  Default value is NULL.

	* 'name' defines the name that will be given to the plane.
	  Default value is "Name_0".

	* 'label' defines the name that will be displayed with the plane.
	  Default value is "$0". In that case 'name' is used as 'label'.

	* 'orientation' defines if the plane will be reversed (i.e. the normal
	  of the plane will be opposed to cs axis selected) or not.
	  'orientation' must be select in "smframedef.h" in the 3rd section
          called "FRAME ORIENTATION".
          Default value is SM_FO_Parallel.

	* 'wJustif' defines the width justification of the plane.
	  'wJustif' must be select in "smframedef.h" in the 5th section
          called "PLANE WIDTH JUSTIFICATION".
          Default value is SM_FJ_Width_Center.

	* 'hJustif' defines the height justification of the plane.
	  'hJustif' must be select in "smframedef.h" in the 6th section
          called "PLANE HEIGHT JUSTIFICATION".
          Default value is SM_FJ_Height_Center.

	* 'singlePlaneId' is the constructed single plane.
-M*/
extern long
SMcreate_single_plane	__((	long			*msg,
				struct GRid		*csId,
				struct GRmd_env 	*csEnv,
				int			axis,
				double			distance,
				char			*distanceUnit,
				int			planeSize,
				double			*planeValue,
				char			*name,
				char			*label,
				int			orientation,
				int			wJustif,
				int			hJustif,
				struct GRid		*singlePlaneId )) ;

#omdef sm$create_single_plane(	msg,
				csId,
				csEnv,
				axis		= SM_FA_Xaxis,
				distance	= 0.0,
				distanceUnit	= "mm",
				planeSize	= SM_FS_Regular,
				planeValue	= NULL,
				name		= "Name_0",
				label		= "$0",
				orientation	= SM_FO_Parallel,
				wJustif 	= SM_FJ_Width_Center,
				hJustif 	= SM_FJ_Height_Center,
				singlePlaneId )

	SMcreate_single_plane( (msg),
			       (csId),
			       (csEnv),
			       (axis),
			       (distance),
			       (distanceUnit),
			       (planeSize),
			       (planeValue),
			       (name),
			       (label),
			       (orientation),
			       (wJustif),
			       (hJustif),
			       (singlePlaneId) )
#endomdef
/* ************************************************************************** */

/* ************************************************************************** */
/*+M
Macro sm$modify_frame_system

Abstract
	This macro modifies a frame system object.
Arguments
	OUT	long		 *msg		Completion code.
	IN	struct GRid	 *frameSystemId	The frame system to modify.
	IN	char		 *name		Name given to the frame system.
	IN	int		 *frameDisplay	Frame display toggle.
						(cf "smframedef.h").
	IN	struct GRid	 *csId		Id of coordinate system.
	IN	struct GRmd_env  *csEnv		Env of coordinate system.
	IN	int		 *axis		Selected axis.
	IN	int		 *orientation	Axis orientation.
						(cf "smframedef.h").
	IN	double		 *revDistance	Reverse distance.
	IN	int		 *regulSize	Size of regular frames.
						(cf "smframedef.h").
	IN	double		 *regulValue	Size value of an EMS plane.
	IN	int		 *reinfSize	Size of reinforced frames.
						(cf "smframedef.h").
	IN	double		 *reinfValue	Size value of an EMS plane.
	IN	char		 *annotation	Prefix of frames.
	IN	double		 *originOffset	Origin offset value, along axis.
	IN	int		 *wJustif	Width justification.
						(cf "smframedef.h").
	IN	int		 *hJustif	Height justification.
						(cf "smframedef.h").
	IN	int		 *sectionNumber	Number of sections.
	IN	char		 *distanceUnit	Unit use for distances.
	IN	int		 *sectionOption	Type of section definition.
						(cf "smframedef.h").
	IN	int		 *frNumber	From frame numbers.
	IN	int		 *toNumber	To frame numbers.
	IN	double		 *spacing	Spacings between frames.
	IN	double		 *frDistance	From distance along axis.
	IN	double		 *toDistance	To distance along axis.
	IN	int		 *frameNumber	Number of frames.
	IN	int		 *layerOffset	Layer where frames will be
						modifyd.
						Offset from active layer.
	IN	char		 *reinforce	Parse string describing which
						frames will be reinforced.
	IN	char		 *reverse	Parse string describing which
						frames will be reversed.
Notes
	* The macro returns MSSUCC if succesfull or MSFAIL if an error
          occur in argument 'msg'.

	* All arguments can be NULL except 'msg' and 'frameSystemId'.
-M*/
extern long
SMmodify_frame_system	__((	long			*msg,
				struct GRid		*frameSystemId,
				char			*name,
				int			*frameDisplay,
				struct GRid		*csId,
				struct GRmd_env		*csEnv,
				int			*axis,
				int			*orientation,
				double			*revDistance,
				int			*regulSize,
				double			*regulValue,
				int			*reinfSize,
				double			*reinfValue,
				char			*annotation,
				double			*originOffset,
				int			*wJustif,
				int			*hJustif,
				int			*sectionNumber,
				char		        *distanceUnit,
				int			*sectionOption,
				int			*frNumber,
				int			*toNumber,
				double			*spacing,
				double			*frDistance,
				double			*toDistance,
				int			*frameNumber,
				int			*layerOffset,
				char			*reinforce,
				char			*reverse )) ;

#omdef sm$modify_frame_system(	msg,
				frameSystemId,
				name		= NULL,
				frameDisplay	= NULL,
				csId		= NULL,
				csEnv		= NULL,
				axis		= NULL,
				orientation	= NULL,
				revDistance	= NULL,
				regulSize	= NULL,
				regulValue	= NULL,
				reinfSize	= NULL,
				reinfValue	= NULL,
				annotation	= NULL,
				originOffset	= NULL,
				wJustif 	= NULL,
				hJustif 	= NULL,
				sectionNumber 	= NULL,
				distanceUnit 	= NULL,
				sectionOption 	= NULL,
				frNumber 	= NULL,
				toNumber 	= NULL,
				spacing 	= NULL,
				frDistance 	= NULL,
				toDistance 	= NULL,
				frameNumber 	= NULL,
				layerOffset 	= NULL,
				reinforce 	= NULL,
				reverse 	= NULL )

	SMmodify_frame_system( (msg),
			       (frameSystemId),
			       (name),
			       (frameDisplay),
			       (csId),
			       (csEnv),
			       (axis),
			       (orientation),
			       (revDistance),
			       (regulSize),
			       (regulValue),
			       (reinfSize),
			       (reinfValue),
			       (annotation),
			       (originOffset),
			       (wJustif),
			       (hJustif),
			       (sectionNumber),
			       (distanceUnit),
			       (sectionOption),
			       (frNumber),
			       (toNumber),
			       (spacing),
			       (frDistance),
			       (toDistance),
			       (frameNumber),
			       (layerOffset),
			       (reinforce),
			       (reverse) )
#endomdef
/* ************************************************************************** */

/* ************************************************************************** */
/*+M
Macro sm$modify_single_plane

Abstract
	This macro modifies a single plane object.
Arguments
	OUT	long		 *msg		Completion code.
	IN	struct GRid	 *singlePlaneId	The single plane to modify.
	IN	struct GRid	 *csId		Id of coordinate system.
	IN	struct GRmd_env  *csEnv		Env of coordinate system.
	IN	int		 *axis		Selected axis.
						(cf "smframedef.h").
	IN	double		 *distance	Distance from cs along axis.
	IN	char		 *distanceUnit	Unit use for distances.
	IN	int		 *planeSize	Size of the plane generated.
						(cf "smframedef.h").
	IN	double		 *planeValue	Size value of an EMS plane.
	IN	char		 *name		Name given to the plane.
	IN	char		 *label		Label given to the plane.
	IN	int		 *orientation	Is the plane reversed ?
						(cf "smframedef.h").
	IN	int		 *wJustif	Width justification.
						(cf "smframedef.h").
	IN	int		 *hJustif	Height justification.
						(cf "smframedef.h").
Notes
	* The macro returns MSSUCC if succesfull or MSFAIL if an error
          occur in argument 'msg'.

	* All arguments can be NULL except 'msg' and 'singlePlaneId'.

	* For arguments eligible values, have look to sm$create_single_plane().

	* '*distanceUnit' isn't a internal parameter of the SMinfPlane object.
	  So user have to use '*distanceUnit' for creation and for modification.
	  to be consistent with Frame System macros, an unit of measure
	  can be used. The conversion to internal units is automatic.
	  Default value is "mm" (millimeters).
-M*/
extern long
SMmodify_single_plane	__((	long			*msg,
				struct GRid		*singlePlaneId,
				struct GRid		*csId,
				struct GRmd_env		*csEnv,
				int			*axis,
				double			*distance,
				char			*distanceUnit,
				int			*planeSize,
				double			*planeValue,
				char			*name,
				char			*label,
				int			*orientation,
				int			*wJustif,
				int			*hJustif )) ;

#omdef sm$modify_single_plane(	msg,
				singlePlaneId,
				csId		= NULL,
				csEnv		= NULL,
				axis		= NULL,
				distance	= NULL,
				distanceUnit	= "mm",
				planeSize	= NULL,
				planeValue	= NULL,
				name		= NULL,
				label		= NULL,
				orientation	= NULL,
				wJustif 	= NULL,
				hJustif 	= NULL )

	SMmodify_single_plane( (msg),
			       (singlePlaneId),
			       (csId),
			       (csEnv),
			       (axis),
			       (distance),
			       (distanceUnit),
			       (planeSize),
			       (planeValue),
			       (name),
			       (label),
			       (orientation),
			       (wJustif),
			       (hJustif) )
#endomdef
/* ************************************************************************** */

/* ************************************************************************** */
/*+M
Macro sm$validate_reinforce

Abstract
	Given the string inforce for reinforcement, this macro checks the
        inforce is in valid syntax or not. If the valid is 1 valid else not
        valid.
Arguments
	OUT	IGRint		*valid		1 true, 0 false.
	IN	IGRchar		*inforce	Reinforce string.
Notes
	* '*valid' will have value 1 if the given reinforce string is valid,
	  otherwise it contains 0.
	
	* '*inforce' defines the reinforce string.

-M*/

extern IGRint 
SMvalidate_reinforce __((	IGRint         *valid,
				IGRchar 	*inforce));

#omdef sm$validate_reinforce(	valid, 
				inforce )

	SMvalidate_reinforce( 	(valid), 
				(inforce) );
#endomdef
/* ************************************************************************** */

/* ************************************************************************** */
/*+M
Macro sm$get_frs_from_frsys

Abstract
	Given frame system and reinforce string it gives reinforced frames.
Arguments
	OUT		IGRint		*num_elm	No.of Frames in list.
	IN		struct GRid	fr_obj		GRid of Frame
	IN		IGRchar		*inforce	Reinforce string.
	OUT		struct GRid	*frames		Frames.
Notes
	* "*num_elm' contains the number of reinfored frames in reinforce
	  string of frame system.

	* 'fr_obj' contains grid of frame system.

	* '*inforce' defines the reinforce string.
	
	* '**frames' contains the grids of frames in reinforced string of
	  frame system. Memory will be allocated to *frames inside the
	  function, so that user has to free it.
-M*/

extern IGRlong 
SMget_frs_from_frsys __(( 	IGRlong         *num_elm,
				struct GRid     fr_obj,
				IGRchar         *inforce,
				struct GRid     **frames));

#omdef sm$get_frs_from_frsys(	num_elm,
                		fr_obj,
                		inforce	= NULL,
                		frames  )
 
	SMget_frs_from_frsys( 	(num_elm), 
				(fr_obj), 
				(inforce), 
				(frames) );
#endomdef
/* ************************************************************************** */

/* ************************************************************************** */
/*+M
Macro sm$validate_frame

Abstract
	Given frame and reinforce string it tells frame is in the reforced
        list or not.
Arguments
	OUT		IGRlong         *check		Is it in list.
	IN		struct GRid	frame		Frame GRid.
	IN		IGRchar		*inforce	Reinforce string.
	
Notes
        * '*check' will have value 1 if the given frame is in the reinforced
	  string, otherwise 0.
 
        * 'frame' contains the grid of the give frame.
 
        * '*inforce' defines the reinforce string.

-M*/

extern IGRlong 
SMvalidate_frame __((	IGRlong         *check,
			struct GRid     frame,
			IGRchar         *inforce));

#omdef sm$validate_frame( 	check,
                        	frame,
                       		inforce)

	SMvalidate_frame( 	(check), 
				(frame), 
				(inforce) );
#endomdef
/* ************************************************************************** */
/* From now deleted smframeapi.h:					      */


#if defined(__STDC__) || defined(__cplusplus)
#ifndef __
#define __(args) args
#endif
#else
#ifndef __
#define __(args) ()
#endif
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* FrameSystem.I */
extern IGRboolean CFSaxis __((struct frame_def *Frame, IGRint axis));
extern IGRboolean CFSorient __((struct frame_def *Frame, IGRint orient));
extern IGRboolean CFSrevDist __((struct frame_def *Frame, IGRchar *unit, IGRdouble *revDist));
extern IGRboolean CFSplnSize __((IGRdouble *Size, IGRint size, IGRdouble *value, IGRchar *unit));
extern IGRboolean CFSjustif __((IGRchar *Cjust, IGRint Ijust));
extern IGRboolean CFSdistToNumb __((struct sect_dist *Fdist, IGRint *lyO, struct frame_def *Frame));
extern IGRboolean CFSsectionInfo __((IGRint opt, IGRchar *unit, IGRint *frN, IGRint *toN, IGRdouble *spN, IGRdouble *frD, IGRdouble *toD, IGRint *nmD, IGRint *lyO, struct frame_def *Frame));
extern IGRboolean MFSsectionInfo __((IGRint *opt, IGRchar *unit, IGRint *frN, IGRint *toN, IGRdouble *spN, IGRdouble *frD, IGRdouble *toD, IGRint *nmD, IGRint *lyO, struct frame_def *old, struct frame_def *new));


/* SinglePlane.I */
extern IGRboolean CSPinitCst __((struct GRvg_construct *cst));
extern IGRboolean CSPconvert __((IGRdouble *value, IGRchar *unit));
extern IGRboolean CSPnewName __((IGRchar *nam));

#if defined(__cplusplus)
}
#endif

#endif /* smAPImacros_include */
