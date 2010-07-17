/* $Id: vlAPImacros.h,v 1.1.1.1 2001/01/04 21:11:11 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	include/vlAPImacros.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vlAPImacros.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:11:11  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:32:50  pinnacle
 * LOFT 2.5.1
 *
 * Revision 1.1  1997/05/08  14:05:56  pinnacle
 * Loft 250
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			i-paris		creation date
 *
 ***************************************************************************/

#ifndef vlAPImacros_include
#	define vlAPImacros_include

/* ************************************************************************

	In this file you will find the list of apis use to place and modify
	the following LOFT entities.

				- base butt
				- base seam
				- curved butt
				- curved seam
				- trace
				- water line
				- Next butt
				= Next seam


	The apis are wrapped with a macro that allow the management of optional
	arguments.
	Mamy of this macros have the same descriptions for arguments. We will
	comments this common descriptions here.

	--- Standard argument description ---

	* [OUT] IGRlong* msg

	  The macro returns MSSUCC if succesfull or MSFAIL if an error occurs.

	* [IN]	int		transtable

	  'transtable' can be TRUE or FALSE. If it's TRUE, the function will
	  take the following informations from the transtable :

		- directory where the constructed object is named.
		- display properties of the constructed object.
		- level (layer) of the constructed object.

	  If 'transtable' is FALSE, the function will take informations from
	  the given arguments :

		- 'directory' : directory where the constructed object is named.
		- 'display'   : display properties of the constructed object.
		- 'level'     : level (layer) of the constructed object.

	 If 'transtable' is FALSE and argument is NULL then the active
	 properties will be used. 

	* [IN]	char	*basename 

	  'basename' is the base name of the constructed object. The final
	  name is :

		name = <directory>:<basename><number>

	  where <number> is a calculated number.

	  i.e : if basename = "BButt_" and "directory" is "usr:test:butt" then
	  the name of base butt will be usr:test:butt:BButt_0 if the element
	  BButt_0 doesn't exit. Or, usr:test:butt:BButt_1 if the element
	  BButt_0 exist.

	* [IN]	char	*directory

	  'directory' is the directory where the constructed object is named.
	  If null, the object is named in the active one.
	  Could be overridden by the transtable mechanism,
	  i.e : "usr:test:butt"

	* [IN]	struct IGRdisplay	*display

	  'display' is the display properties of the constructed object 
	  ( color, weight and style ).
	  If null, the active display properties are taken
	  Could be overridden by the transtable mechanism.

	* [IN]	short	*level

	  'level' is the level (layer) of the constructed object.
	  If null, the active level is taken.
	  Could be overriden by the transtable mechanism. 

	* [IN]	struct GRid		*projectionId
	  [IN]	struct GRmod_env	*projectionEnv

	  'projectionId' and 'projectionEnv' allows to compute the vector
	  of projection.
	  When it is a point, the vector of projection is computed from 
	  base coordinate system origin to this point.
	  When it is a segment, the vector of projection is computed from start
	  to end points.
	  When it is a coordinate systen, the x vector is used.
	  When it is a text expression or a NULL pointer, it means that any 
	  projection vector is given. 

	* [IN]	struct GRid		*pointId
	  [IN]	struct GRmod_env	*pointEnv

	  'pointId' and 'pointEnv' defines the selector point. When more that
	  one graphic solution is found, this point allows to select the
	  closiest one instead the first one.  Default value is NULL (No).

	* [IN]	struct GRid		*hullId
	  [IN]	struct GRmod_env	*hullEnv

	  'hullId' and 'hullEnv' defines the hull surface where the base butt
	  will be placed.

	* [IN]	struct GRid		*allowanceDirId
	  [IN]	struct GRmod_env	*allownaceDirEnv

	  'allowanceDirId' and 'allowanceDirEnv' is the direction of the
	  main allowance.  See projectionId for a full description.	  

	* [IN]	double	*allowanceVal

	 'allowanceVal' is the value of the main allowance.
	  Default value is NULL (No).

	* [IN]	double	*allowanceExt

	 'allowanceExt' is the value of the extra allowance.
	  Default value is NULL (No).

	* [IN]	struct GRid		*dataId
	  [IN]	struct GRmod_env	*dataEnv

	  'dataId' and 'dataEnv' defines the geometry intersecting the hull
	  use to place the construted object.

	* [OUT] struct GRid		*constructId

	  'constructedId' is the Id of constructed object into the current
	  object space.
	
	* [IN]	struct GRid		*modifiedId

	  'modifiedId' is the Id of the object to modify.

	* [IN]	struct GRid		*previousId
	  [IN]	struct GRmod_env	*previousEnv

	  They define the entity on witch we calculate a next entity.
	  For example for the calculation of a next butt, the previous entity
	  need to be a butt.

	* [IN]	struct GRid		*propagDirId	
	  [IN]	struct GRmd_env	*propagDirEnv

	  They define the direction of propagation from previous entity to
	  next one.  See projectionId for a full description.	  

   ************************************************************************** */


/* ************************************************************************** */
/*+M
Macro vl$modify_base_butt

Abstract
	This macro modifies a base butt.
Arguments
	OUT	long		*msg		Completion code.
	IN	struct GRid	*modifiedId	Id of the object to modify.
	IN	struct GRid	*projectionId	Id of the object that represents
						the projection direction.
	IN	struct GRmd_env	*projectionEnv	Env of the projection direction
	IN	struct GRid	*pointId	Id of selector point.
	IN	struct GRmd_env	*pointEnv	Env of the selector point.
	IN	struct GRid	*hullId		Id of hull surface.
	IN	struct GRmd_env	*hullEnv	Env of hull surface.
	IN	struct GRid	*allowanceDirId	Id of the object that represents
						the allowance direction.
	IN	struct GRmd_env	*allowanceDirEnv Env of allowance direction.
	IN	double		*allowanceVal	Allowance value.
	IN	double		*allowanceExt	Allowance extra value.
	IN	struct GRid	*dataId		Id of base data.
	IN	struct GRmd_env	*dataEnv	Env of base data.

Notes
	* The macro returns MSSUCC if succesfull or MSFAIL if an error
          occur in argument 'msg'.

	* All arguments can be NULL except 'msg' and 'modifiedId'.

	* check global description to get more information.

-M*/
extern long
VLmodify_base_butt	__((	long			*msg,
				struct	GRid		*modifiedId,
				struct	GRid		*projectionId,
				struct	GRmd_env	*projectionEnv,
				struct	GRid		*pointId,
				struct	GRmd_env 	*pointEnv,
				struct	GRid		*hullId,
				struct	GRmd_env 	*hullEnv,
				struct	GRid		*allowanceDirId,
				struct	GRmd_env	*allowanceDirEnv,
				double			*allowanceVal,
				double			*allowanceExt,
				struct	GRid		*dataId,
				struct	GRmd_env 	*dataEnv ));

#omdef vl$modify_base_butt(	msg,
				modifiedId,
				projectionId	= NULL,
				projectionEnv	= NULL,
				pointId		= NULL,
				pointEnv	= NULL,
				hullId		= NULL,
				hullEnv		= NULL,
				allowanceDirId	= NULL,
				allowanceDirEnv	= NULL,
				allowanceVal	= NULL,
				allowanceExt	= NULL,
				dataId		= NULL,
				dataEnv		= NULL )

	VLmodify_base_butt( 	(msg),
				(modifiedId),
		       		(projectionId),
		       	  	(projectionEnv),
		       	  	(pointId),
		       	  	(pointEnv),
		       	  	(hullId),
		       	  	(hullEnv),
		       	  	(allowanceDirId),
		       	  	(allowanceDirEnv),
		       	  	(allowanceVal),
		       	 	(allowanceExt),
		       	  	(dataId),
		       	  	(dataEnv) )
#endomdef
/* ************************************************************************** */

/* ************************************************************************** */
/*+M
Macro vl$modify_base_seam

Abstract
	This macro modifies a base seam.

Arguments
	OUT	long		*msg		Completion code.
	IN	struct GRid	*modifiedId	Id of the object to modify.
	IN	struct GRid	*projectionId	Id of the object that represents
						the projection direction.
	IN	struct GRmd_env	*projectionEnv	Env of the projection direction
	IN	struct GRid	*pointId	Id of selector point.
	IN	struct GRmd_env	*pointEnv	Env of the selector point.
	IN	struct GRid	*hullId		Id of hull surface.
	IN	struct GRmd_env	*hullEnv	Env of hull surface.
	IN	struct GRid	*allowanceDirId	Id of the object that represents
						the allowance direction.
	IN	struct GRmd_env	*allowanceDirEnv Env of allowance direction.
	IN	double		*allowanceVal	Allowance value.
	IN	double		*allowanceExt	Allowance extra value.
	IN	struct GRid	*dataId		Id of base data.
	IN	struct GRmd_env	*dataEnv	Env of base data.

Notes
	* The macro returns MSSUCC if succesfull or MSFAIL if an error
          occur in argument 'msg'.

	* All arguments can be NULL except 'msg' and 'modifiedId'.

	* check global description to get more information.

-M*/
extern long
VLmodify_base_seam	__((	long			*msg,
				struct	GRid		*modifiedId,
				struct	GRid		*projectionId,
				struct	GRmd_env	*projectionEnv,
				struct	GRid		*pointId,
				struct	GRmd_env 	*pointEnv,
				struct	GRid		*hullId,
				struct	GRmd_env 	*hullEnv,
				struct	GRid		*allowanceDirId,
				struct	GRmd_env	*allowanceDirEnv,
				double			*allowanceVal,
				double			*allowanceExt,
				struct	GRid		*dataId,
				struct	GRmd_env 	*dataEnv ));

#omdef vl$modify_base_seam(	msg,
				modifiedId,
				projectionId	= NULL,
				projectionEnv	= NULL,
				pointId		= NULL,
				pointEnv	= NULL,
				hullId		= NULL,
				hullEnv		= NULL,
				allowanceDirId	= NULL,
				allowanceDirEnv	= NULL,
				allowanceVal	= NULL,
				allowanceExt	= NULL,
				dataId		= NULL,
				dataEnv		= NULL )

	VLmodify_base_seam( 	(msg),
				(modifiedId),
		       		(projectionId),
		       	  	(projectionEnv),
		       	  	(pointId),
		       	  	(pointEnv),
		       	  	(hullId),
		       	  	(hullEnv),
		       	  	(allowanceDirId),
		       	  	(allowanceDirEnv),
		       	  	(allowanceVal),
		       	 	(allowanceExt),
		       	  	(dataId),
		       	  	(dataEnv) )
#endomdef
/* ************************************************************************** */

/* ************************************************************************** */
/*+M
Macro vl$modify_curved_butt

Abstract
	This macro modifies a curved butt.

Arguments
	OUT	long		*msg		Completion code.
	IN	struct GRid	*modifiedId	Id of the object to modify.
	IN	struct GRid	*projectionId	Id of the object that represents
						the projection direction.
	IN	struct GRmd_env	*projectionEnv	Env of the projection direction
	IN	struct GRid	*pointId	Id of selector point.
	IN	struct GRmd_env	*pointEnv	Env of the selector point.
	IN	struct GRid	*hullId		Id of hull surface.
	IN	struct GRmd_env	*hullEnv	Env of hull surface.
	IN	struct GRid	*allowanceDirId	Id of the object that represents
						the allowance direction.
	IN	struct GRmd_env	*allowanceDirEnv Env of allowance direction.
	IN	double		*allowanceVal	Allowance value.
	IN	double		*allowanceExt	Allowance extra value.
	IN	struct GRid	*dataId		Id of base data.
	IN	struct GRmd_env	*dataEnv	Env of base data.

Notes
	* The macro returns MSSUCC if succesfull or MSFAIL if an error
          occurs in argument 'msg'.

	* All arguments can be NULL except 'msg' and 'modifiedId'.

	* check global description to get more information.

-M*/
extern long
VLmodify_curved_butt	__((	long			*msg,
				struct	GRid		*modifiedId,
				struct	GRid		*projectionId,
				struct	GRmd_env	*projectionEnv,
				struct	GRid		*pointId,
				struct	GRmd_env 	*pointEnv,
				struct	GRid		*hullId,
				struct	GRmd_env 	*hullEnv,
				struct	GRid		*allowanceDirId,
				struct	GRmd_env	*allowanceDirEnv,
				double			*allowanceVal,
				double			*allowanceExt,
				struct	GRid		*dataId,
				struct	GRmd_env 	*dataEnv ));

#omdef vl$modify_curved_butt(	msg,
				modifiedId,
				projectionId	= NULL,
				projectionEnv	= NULL,
				pointId		= NULL,
				pointEnv	= NULL,
				hullId		= NULL,
				hullEnv		= NULL,
				allowanceDirId	= NULL,
				allowanceDirEnv	= NULL,
				allowanceVal	= NULL,
				allowanceExt	= NULL,
				dataId		= NULL,
				dataEnv		= NULL )

	VLmodify_curved_butt( 	(msg),
				(modifiedId),
		       		(projectionId),
		       	  	(projectionEnv),
		       	  	(pointId),
		       	  	(pointEnv),
		       	  	(hullId),
		       	  	(hullEnv),
		       	  	(allowanceDirId),
		       	  	(allowanceDirEnv),
		       	  	(allowanceVal),
		       	 	(allowanceExt),
		       	  	(dataId),
		       	  	(dataEnv) )
#endomdef
/* ************************************************************************** */

/* ************************************************************************** */
/*+M
Macro vl$modify_curved_seam

Abstract
	This macro modifies a curved seam.

Arguments
	OUT	long		*msg		Completion code.
	IN	struct GRid	*modifiedId	Id of the object to modify.
	IN	struct GRid	*projectionId	Id of the object that represents
						the projection direction.
	IN	struct GRmd_env	*projectionEnv	Env of the projection direction
	IN	struct GRid	*pointId	Id of selector point.
	IN	struct GRmd_env	*pointEnv	Env of the selector point.
	IN	struct GRid	*hullId		Id of hull surface.
	IN	struct GRmd_env	*hullEnv	Env of hull surface.
	IN	struct GRid	*allowanceDirId	Id of the object that represents
						the allowance direction.
	IN	struct GRmd_env	*allowanceDirEnv Env of allowance direction.
	IN	double		*allowanceVal	Allowance value.
	IN	double		*allowanceExt	Allowance extra value.
	IN	struct GRid	*dataId		Id of base data.
	IN	struct GRmd_env	*dataEnv	Env of base data.

Notes
	* The macro returns MSSUCC if succesfull or MSFAIL if an error
          occur in argument 'msg'.
	* All arguments can be NULL except 'msg' and 'modifiedId'.
	* check global description to get more information.

-M*/
extern long
VLmodify_curved_seam	__((	long			*msg,
				struct	GRid		*modifiedId,
				struct	GRid		*projectionId,
				struct	GRmd_env	*projectionEnv,
				struct	GRid		*pointId,
				struct	GRmd_env 	*pointEnv,
				struct	GRid		*hullId,
				struct	GRmd_env 	*hullEnv,
				struct	GRid		*allowanceDirId,
				struct	GRmd_env	*allowanceDirEnv,
				double			*allowanceVal,
				double			*allowanceExt,
				struct	GRid		*dataId,
				struct	GRmd_env 	*dataEnv ));

#omdef vl$modify_curved_seam(	msg,
				modifiedId,
				projectionId		= NULL,
				projectionEnv		= NULL,
				pointId			= NULL,
				pointEnv		= NULL,
				hullId			= NULL,
				hullEnv			= NULL,
				allowanceDirId		= NULL,
				allowanceDirEnv		= NULL,
				allowanceVal		= NULL,
				allowanceExt		= NULL,
				dataId			= NULL,
				dataEnv			= NULL )

	VLmodify_curved_seam( 	(msg),
				(modifiedId),
		       		(projectionId),
		       	  	(projectionEnv),
		       	  	(pointId),
		       	  	(pointEnv),
		       	  	(hullId),
		       	  	(hullEnv),
		       	  	(allowanceDirId),
		       	  	(allowanceDirEnv),
		       	  	(allowanceVal),
		       	 	(allowanceExt),
		       	  	(dataId),
		       	  	(dataEnv) )
#endomdef
/* ************************************************************************** */

/* ************************************************************************** */
/*+M
Macro vl$modify_next_butt

Abstract
	This macro modifies a next butt.

Arguments
	OUT	long		*msg		Completion code.
	IN	struct GRid	*modifiedId	Id of the object to modify.
	IN	struct GRid	*propagDirId	Id of the object that represents
						the propagation direction.
	IN	struct GRmd_env	*propagDirEnv	Env of the propagation direction
	IN	double		*length		Distance between previous butt
						and the next butt to be.
	IN	struct GRid	*pointId	Id of selector point.
	IN	struct GRmd_env	*pointEnv	Env of the selector point.
	IN	struct GRid	*hullId		Id of hull surface.
	IN	struct GRmd_env	*hullEnv	Env of hull surface.
	IN	struct GRid	*allowanceDirId	Id of the object that represents
						the allowance direction.
	IN	struct GRmd_env	*allowanceDirEnv Env of allowance direction.
	IN	double		*allowanceVal	Allowance value.
	IN	double		*allowanceExt	Allowance extra value.
	IN	struct GRid	*previousId	Id of previous line.
	IN	struct GRmd_env	*previousEnv	Env of previous line.
	IN	int		*nbWaterLine	Number of waterlines.
	IN	struct GRid	*waterLineId	Array of waterlines Id.
	IN	struct GRmd_env	*waterLineEnv	Array of waterlines Env.
	IN	short		removeDevOption	Allow to remove the Development
						property
	IN	double		*devWidth	Development width value.

Notes
	* The macro returns MSSUCC if succesfull or MSFAIL if an error
          occurs, in argument 'msg'.
	* 'nbWaterLine' and 'waterLineId' are dependent. If one is specified, 
	   second one need to be specified.
	* if 'removeDevOption' is filled with TRUE and 'devWidth' is given, the
	  removeDevOption is without effect.   
	* check global description or check vl$place_next_butt to get more 
	  information on arguments.

-M*/
extern long
VLmodify_next_butt	__((	long			*msg,
				struct	GRid		*modifiedId,
				struct	GRid		*propagDirId,
				struct	GRmd_env	*propagDirEnv,
				double			*length,
				struct	GRid		*pointId,
				struct	GRmd_env	*pointEnv,
				struct	GRid		*hullId,
				struct	GRmd_env 	*hullEnv,
				struct	GRid		*allowanceDirId,
				struct	GRmd_env	*allowanceDirEnv,
				double			*allowanceVal,
				double			*allowanceExt,
				struct	GRid		*previousId,
				struct	GRmd_env	*previousEnv,
				int			*nbWaterLine,
				struct	GRid		*waterLineId,
				struct	GRmd_env	*waterLineEnv,
				short			removeDevOption,
				double			*devWidth ));

#omdef vl$modify_next_butt(	msg,
				modifiedId,
				propagDirId		= NULL,
				propagDirEnv		= NULL,
				length			= NULL,
				pointId			= NULL,
				pointEnv		= NULL,
				hullId			= NULL,
				hullEnv			= NULL,
				allowanceDirId		= NULL,
				allowanceDirEnv		= NULL,
				allowanceVal		= NULL,
				allowanceExt		= NULL,
				previousId		= NULL,
				previousEnv		= NULL,
				nbWaterLine		= NULL,
				waterLineId		= NULL,
				waterLineEnv		= NULL,
				removeDevOption		= FALSE,
				devWidth		= NULL )

	VLmodify_next_butt((msg),
			   (modifiedId),
		       	   (propagDirId),
		       	   (propagDirEnv),
		       	   (length),
		       	   (pointId),
		       	   (pointEnv),
		       	   (hullId),
		       	   (hullEnv),
		       	   (allowanceDirId),
		       	   (allowanceDirEnv),
		       	   (allowanceVal),
		       	   (allowanceExt),
		       	   (previousId),
		       	   (previousEnv),
		       	   (nbWaterLine),
		       	   (waterLineId),
		       	   (waterLineEnv),
			   (removeDevOption),
		       	   (devWidth) )
#endomdef
/* ************************************************************************** */

/* ************************************************************************** */
/*+M
Macro vl$modify_next_seam

Abstract
	This macro modifies a next seam.

Arguments
	OUT	long		*msg		Completion code.
	IN	struct GRid	*modifiedId	Id of the object to modify.
	IN	struct GRid	*propagDirId	Id of the object that represents
						the propagation direction.
	IN	struct GRmd_env	*propagDirEnv	Env of the propagation direction
	IN	double		*width1		Distance between previous seam
						and the next seam to be.
	IN	double		*width2		Use with complex laws.
	IN	int		*law		Type of repartition law used.
	IN	int		*nbDivisor	Number of areas between 2
						limits.
	IN	struct GRid	*pointId	Id of selector point.
	IN	struct GRmd_env	*pointEnv	Env of the selector point.
	IN	struct GRid	*hullId		Id of hull surface.
	IN	struct GRmd_env	*hullEnv	Env of hull surface.
	IN	struct GRid	*allowanceDirId	Id of the object that represents
						the allowance direction.
	IN	struct GRmd_env	*allowanceDirEnv Env of allowance direction.
	IN	double		*allowanceVal	Allowance value.
	IN	double		*allowanceExt	Allowance extra value.
	IN	struct GRid	*previousId	Id of previous line.
	IN	struct GRmd_env	*previousEnv	Env of previous line.
	IN	int		*nbLimit	Number of waterlines.
	IN	struct GRid	*limitId	Array of waterlines Id.
	IN	struct GRmd_env	*limitEnv	Array of waterlines Env.
	IN	short	 	*smooth		Smoothing seam curve.
	IN	short		removeDevOption Allow to remove the Development
						property
	IN	short		*devIteration	Maximum iterations allowed
						during development.

Notes
	* The macro returns MSSUCC if succesfull or MSFAIL if an error
          occurs, in argument 'msg'.
	* 'nbWaterLine' and 'waterLineId' are dependent. If one is specified, 
	   second one need to be specified.
	* if 'removeDevOption' is filled with TRUE and 'devIteration' is given,
	  the removeDevOption is without effect.   
	* check global description or check vl$place_next_seam to get more 
	  information on arguments.

-M*/
extern long
VLmodify_next_seam	__((	long			*msg,
				struct	GRid		*modifiedId,
				struct	GRid		*propagDirId,
				struct	GRmd_env	*propagDirEnv,
				double			*width1,
				double			*width2,
				int			*law,
				int			*nbDivisor,
				struct	GRid		*pointId,
				struct	GRmd_env	*pointEnv,
				struct	GRid		*hullId,
				struct	GRmd_env 	*hullEnv,
				struct	GRid		*allowanceDirId,
				struct	GRmd_env	*allowanceDirEnv,
				double			*allowanceVal,
				double			*allowanceExt,
				struct	GRid		*previousId,
				struct	GRmd_env	*previousEnv,
				int			*nbLimit,
				struct	GRid		*limitId,
				struct	GRmd_env	*limitEnv,
				short			*smooth,
				short			removeDevOption,
				double			*devIteration ));

#omdef vl$modify_next_seam(	msg,
				modifiedId,
				propagDirId		= NULL,
				propagDirEnv		= NULL,
				width1			= NULL,
				width2			= NULL,
				law			= NULL,
				nbDivisor		= NULL,
				pointId			= NULL,
				pointEnv		= NULL,
				hullId			= NULL,
				hullEnv			= NULL,
				allowanceDirId		= NULL,
				allowanceDirEnv		= NULL,
				allowanceVal		= NULL,
				allowanceExt		= NULL,
				previousId		= NULL,
				previousEnv		= NULL,
				nbLimit			= NULL,
				limitId			= NULL,
				limitEnv		= NULL,
				smooth			= NULL,
				removeDevOption		= FALSE,
				devIteration		= NULL )

	VLmodify_next_seam(
			(msg),
			(modifiedId),
		       	(propagDirId),
		       	(propagDirEnv),
		       	(width1),
		       	(width2),
		       	(law),
		       	(nbDivisor),
		       	(pointId),
		       	(pointEnv),
		       	(hullId),
		       	(hullEnv),
		       	(allowanceDirId),
		       	(allowanceDirEnv),
		       	(allowanceVal),
		       	(allowanceExt),
		       	(previousId),
		      	(previousEnv),
		       	(nbLimit),
		       	(limitId),
		       	(limitEnv),
			(smooth),
			(removeDevOption),
		      	(devIteration) )
#endomdef

/* ************************************************************************** */

/* ************************************************************************** */
/*+M
Macro vl$modify_trace

Abstract
	This macro modifies a trace.

Arguments
	OUT	long		*msg		Completion code.
	IN	struct GRid	*modifiedId	Id of the object to modify.
	IN	struct GRid	*projectionId	Id of the object that represents
						the projection direction.
	IN	struct GRmd_env	*projectionEnv	Env of the projection direction
	IN	struct GRid	*pointId	Id of selector point.
	IN	struct GRmd_env	*pointEnv	Env of the selector point.
	IN	struct GRid	*hullId		Id of hull surface.
	IN	struct GRmd_env	*hullEnv	Env of hull surface.
	IN	struct GRid	*dataId		Id of base data.
	IN	struct GRmd_env	*dataEnv	Env of base data.

Notes
	* The macro returns MSSUCC if succesfull or MSFAIL if an error
          occur in argument 'msg'.
	* All arguments can be NULL except 'msg' and 'modifiedId'.
	* check global description to get more information.

-M*/
extern long
VLmodify_trace	__((	long			*msg,
			struct	GRid		*modifiedId,
			struct	GRid		*projectionId,
			struct	GRmd_env	*projectionEnv,
			struct	GRid		*pointId,
			struct	GRmd_env 	*pointEnv,
			struct	GRid		*hullId,
			struct	GRmd_env 	*hullEnv,
			struct	GRid		*dataId,
			struct	GRmd_env 	*dataEnv ));

#omdef vl$modify_trace(	msg,
			modifiedId,
			projectionId		= NULL,
			projectionEnv		= NULL,
			pointId			= NULL,
			pointEnv		= NULL,
			hullId			= NULL,
			hullEnv			= NULL,
			dataId			= NULL,
			dataEnv			= NULL )

	VLmodify_trace( (msg),
			(modifiedId),
		       	(projectionId),
		       	(projectionEnv),
		       	(pointId),
		       	(pointEnv),
		       	(hullId),
		       	(hullEnv),
		       	(dataId),
		       	(dataEnv) )
#endomdef

/* ************************************************************************** */

/* ************************************************************************** */
/*+M
Macro vl$modify_waterline

Abstract
	This macro modifies a water line.

Arguments
	OUT	long		*msg		Completion code.
	IN	struct GRid	*modifiedId	Id of the object to modify.
	IN	struct GRid	*projectionId	Id of the object that represents
						the projection direction.
	IN	struct GRmd_env	*projectionEnv	Env of the projection direction
	IN	struct GRid	*pointId	Id of selector point.
	IN	struct GRmd_env	*pointEnv	Env of the selector point.
	IN	struct GRid	*hullId		Id of hull surface.
	IN	struct GRmd_env	*hullEnv	Env of hull surface.
	IN	struct GRid	*dataId		Id of base data.
	IN	struct GRmd_env	*dataEnv	Env of base data.

Notes
	* The macro returns MSSUCC if succesfull or MSFAIL if an error
          occur in argument 'msg'.
	* All arguments can be NULL except 'msg' and 'modifiedId'.
	* check global description to get more information.

-M*/
extern long
VLmodify_waterline	__((	long			*msg,
				struct	GRid		*modifiedId,
				struct	GRid		*projectionId,
				struct	GRmd_env	*projectionEnv,
				struct	GRid		*pointId,
				struct	GRmd_env 	*pointEnv,
				struct	GRid		*hullId,
				struct	GRmd_env 	*hullEnv,
				struct	GRid		*dataId,
				struct	GRmd_env 	*dataEnv ));

#omdef vl$modify_waterline(	msg,
				modifiedId,
				projectionId		= NULL,
				projectionEnv		= NULL,
				pointId			= NULL,
				pointEnv		= NULL,
				hullId			= NULL,
				hullEnv			= NULL,
				dataId			= NULL,
				dataEnv			= NULL )

	VLmodify_waterline( 
			(msg),
			(modifiedId),
		       	(projectionId),
		       	(projectionEnv),
		       	(pointId),
		       	(pointEnv),
		       	(hullId),
		       	(hullEnv),
		       	(dataId),
		       	(dataEnv) )
#endomdef

/* ************************************************************************** */

/* ************************************************************************** */
/*+M
Macro vl$place_base_butt

Abstract
	This macro places a base butt on a given hull surface.

Arguments
	OUT	long		*msg		Completion code.
	IN	int		transtable	Use the transtable ?
							( TRUE/FALSE ).
	IN	char		*basename	Basename of constructed object.
	IN	char		*directory	Directory where the
						constructed object is named.
						Could be overridden when
						transtable option is set.
	IN	struct IGRdisplay *display	Display properties of the
						constructed object.
						Could be overridden when
						transtable option is set.
	IN	short		*level		Level property of the
						constructed object.
						Could be overridden when
						transtable option is set.
	IN	struct GRid	*projectionId	Id of the object that represents
						the projection direction.
	IN	struct GRmd_env	*projectionEnv	Env of the projection direction
	IN	struct GRid	*pointId	Id of selector point.
	IN	struct GRmd_env	*pointEnv	Env of the selector point.
	IN	struct GRid	*hullId		Id of hull surface.
	IN	struct GRmd_env	*hullEnv	Env of hull surface.
	IN	struct GRid	*allowanceDirId	Id of the object that represents
						the allowance direction.
	IN	struct GRmd_env	*allowanceDirEnv Env of allowance direction.
	IN	double		*allowanceVal	Allowance value.
	IN	double		*allowanceExt	Allowance extra value.
	IN	struct GRid	*dataId		Id of base data.
	IN	struct GRmd_env	*dataEnv	Env of base data.
	OUT	struct GRid	*constructedId	Id of the constructed object.

Notes
	* The macro returns MSSUCC if succesfull or MSFAIL if an error
          occurs, in argument 'msg'.
	* All arguments can be NULL except 'msg' and 'constructedId',
	  hullId and dataId.
	* check global description to get more information.

-M*/
extern long
VLplace_base_butt	__((	long			*msg,
				int			transtable,
				char			*basename,
				char			*directory,
				struct	IGRdisplay	*display,
				short			*level,
				struct	GRid		*projectionId,
				struct	GRmd_env	*projectionEnv,
				struct	GRid		*pointId,
				struct	GRmd_env 	*pointEnv,
				struct	GRid		*hullId,
				struct	GRmd_env 	*hullEnv,
				struct	GRid		*allowanceDirId,
				struct	GRmd_env	*allowanceDirEnv,
				double			*allowanceVal,
				double			*allowanceExt,
				struct	GRid		*dataId,
				struct	GRmd_env 	*dataEnv,
				struct	GRid		*constructedId )) ;

#omdef vl$place_base_butt(	msg,
				transtable		= TRUE,
				basename		= "BButt",
				directory		= NULL,
				display 		= NULL,
				level			= NULL,
				projectionId		= NULL,
				projectionEnv	 	= NULL,
				pointId			= NULL,
				pointEnv		= NULL,
				hullId,
				hullEnv			= NULL,
				allowanceDirId		= NULL,
				allowanceDirEnv		= NULL,
				allowanceVal		= NULL,
				allowanceExt		= NULL,
				dataId,
				dataEnv			= NULL,
				constructedId )

	VLplace_base_butt( (msg),
		       	   (transtable),
		       	   (basename),
		       	   (directory),
		       	   (display),
		       	   (level),
		       	   (projectionId),
		       	   (projectionEnv),
		       	   (pointId),
		       	   (pointEnv),
		       	   (hullId),
		       	   (hullEnv),
		       	   (allowanceDirId),
		       	   (allowanceDirEnv),
		       	   (allowanceVal),
		       	   (allowanceExt),
		       	   (dataId),
		       	   (dataEnv),
		       	   (constructedId) )
#endomdef
/* ************************************************************************** */

/* ************************************************************************** */
/*+M
Macro vl$place_base_seam

Abstract
	This macro places a base seam on a given hull surface.
Arguments
	OUT	long		*msg		Completion code.
	IN	int		transtable	Use the transtable ?
							( TRUE/FALSE ).
	IN	char		*basename	Basename of constructed object.
	IN	char		*directory	Directory where the
						constructed object is named.
						Could be overridden when
						transtable option is set.
	IN	struct IGRdisplay *display	Display properties of the
						constructed object.
						Could be overridden when
						transtable option is set.
	IN	short		*level		Level property of the
						constructed object.
						Could be overridden when
						transtable option is set.
	IN	struct GRid	*projectionId	Id of the object that represents
						the projection direction.
	IN	struct GRmd_env	*projectionEnv	Env of the projection direction
	IN	struct GRid	*pointId	Id of selector point.
	IN	struct GRmd_env	*pointEnv	Env of the selector point.
	IN	struct GRid	*hullId		Id of hull surface.
	IN	struct GRmd_env	*hullEnv	Env of hull surface.
	IN	struct GRid	*allowanceDirId	Id of the object that represents
						the allowance direction.
	IN	struct GRmd_env	*allowanceDirEnv Env of allowance direction.
	IN	double		*allowanceVal	Allowance value.
	IN	double		*allowanceExt	Allowance extra value.
	IN	struct GRid	*dataId		Id of base data.
	IN	struct GRmd_env	*dataEnv	Env of base data.
	OUT	struct GRid	*constructedId	Id of the constructed object.

Notes
	* The macro returns MSSUCC if succesfull or MSFAIL if an error
          occurs, in argument 'msg'.
	* All arguments can be NULL except 'msg' and 'constructedId',
	  hullId and dataId.
	* check global description to get more information.

-M*/
extern long
VLplace_base_seam	__((	long			*msg,
				int			transtable,
				char			*basename,
				char			*directory,
				struct	IGRdisplay	*display,
				short			*level,
				struct	GRid		*projectionId,
				struct	GRmd_env	*projectionEnv,
				struct	GRid		*pointId,
				struct	GRmd_env 	*pointEnv,
				struct	GRid		*hullId,
				struct	GRmd_env 	*hullEnv,
				struct	GRid		*allowanceDirId,
				struct	GRmd_env	*allowanceDirEnv,
				double			*allowanceVal,
				double			*allowanceExt,
				struct	GRid		*dataId,
				struct	GRmd_env 	*dataEnv,
				struct	GRid		*constructedId )) ;

#omdef vl$place_base_seam(	msg,
				transtable		= TRUE,
				basename		= "BSeam",
				directory		= NULL,
				display 		= NULL,
				level			= NULL,
				projectionId		= NULL,
				projectionEnv		= NULL,
				pointId			= NULL,
				pointEnv		= NULL,
				hullId,
				hullEnv			= NULL,
				allowanceDirId		= NULL,
				allowanceDirEnv		= NULL,
				allowanceVal		= NULL,
				allowanceExt		= NULL,
				dataId,
				dataEnv			= NULL,
				constructedId )

	VLplace_base_seam( (msg),
		       	   (transtable),
		       	   (basename),
		       	   (directory),
		       	   (display),
		       	   (level),
		       	   (projectionId),
		       	   (projectionEnv),
		       	   (pointId),
		       	   (pointEnv),
		       	   (hullId),
		       	   (hullEnv),
		       	   (allowanceDirId),
		       	   (allowanceDirEnv),
		       	   (allowanceVal),
		       	   (allowanceExt),
		       	   (dataId),
		       	   (dataEnv),
		       	   (constructedId) )
#endomdef

/* ************************************************************************** */

/* ************************************************************************** */
/*+M
Macro vl$place_curved_butt

Abstract
	This macro places a curved butt on a given hull surface.
Arguments
	OUT	long		*msg		Completion code.
	IN	int		transtable	use the transtable ?
							( TRUE/FALSE ).
	IN	char		*basename	Basename of constructed object.
	IN	char		*directory	Directory where the
						constructed object is named.
						Could be overridden when
						transtable option is set.
	IN	struct IGRdisplay *display	Display properties of the
						constructed object.
						Could be overridden when
						transtable option is set.
	IN	short		*level		Level property of the
						constructed object.
						Could be overridden when
						transtable option is set.
	IN	struct GRid	*projectionId	Id of the object that represents
						the projection direction.
	IN	struct GRmd_env	*projectionEnv	Env of the projection direction
	IN	struct GRid	*pointId	Id of selector point.
	IN	struct GRmd_env	*pointEnv	Env of the selector point.
	IN	struct GRid	*hullId		Id of hull surface.
	IN	struct GRmd_env	*hullEnv	Env of hull surface.
	IN	struct GRid	*allowanceDirId	Id of the object that represents
						the allowance direction.
	IN	struct GRmd_env	*allowanceDirEnv Env of allowance direction.
	IN	double		*allowanceVal	Allowance value.
	IN	double		*allowanceExt	Allowance extra value.
	IN	struct GRid	*dataId		Id of base data.
	IN	struct GRmd_env	*dataEnv	Env of base data.
	OUT	struct GRid	*constructedId	Id of the constructed object.

Notes
	* The macro returns MSSUCC if succesfull or MSFAIL if an error
          occurs, in argument 'msg'.
	* All arguments can be NULL except 'msg' and 'constructedId',
	  hullId and dataId.
	* check global description to get more information.

-M*/
extern long
VLplace_curved_butt	__((	long			*msg,
				int			transtable,
				char			*basename,
				char			*directory,
				struct	IGRdisplay	*display,
				short			*level,
				struct	GRid		*projectionId,
				struct	GRmd_env	*projectionEnv,
				struct	GRid		*pointId,
				struct	GRmd_env 	*pointEnv,
				struct	GRid		*hullId,
				struct	GRmd_env 	*hullEnv,
				struct	GRid		*allowanceDirId,
				struct	GRmd_env	*allowanceDirEnv,
				double			*allowanceVal,
				double			*allowanceExt,
				struct	GRid		*dataId,
				struct	GRmd_env 	*dataEnv,
				struct	GRid		*constructedId )) ;

#omdef vl$place_curved_butt(	msg,
				transtable		= TRUE,
				basename		= "CButt",
				directory		= NULL,
				display 		= NULL,
				level			= NULL,
				projectionId		= NULL,
				projectionEnv		= NULL,
				pointId			= NULL,
				pointEnv		= NULL,
				hullId,
				hullEnv			= NULL,
				allowanceDirId		= NULL,
				allowanceDirEnv		= NULL,
				allowanceVal		= NULL,
				allowanceExt		= NULL,
				dataId,
				dataEnv			= NULL,
				constructedId )

	VLplace_curved_butt( (msg),
		       	   (transtable),
		       	   (basename),
		       	   (directory),
		       	   (display),
		       	   (level),
		       	   (projectionId),
		       	   (projectionEnv),
		       	   (pointId),
		       	   (pointEnv),
		       	   (hullId),
		       	   (hullEnv),
		       	   (allowanceDirId),
		       	   (allowanceDirEnv),
		       	   (allowanceVal),
		       	   (allowanceExt),
		       	   (dataId),
		       	   (dataEnv),
		       	   (constructedId) )
#endomdef
/* ************************************************************************** */

/* ************************************************************************** */
/*+M
Macro vl$place_curved_seam

Abstract
	This macro places a curved seam on a given hull surface.
Arguments
	OUT	long		*msg		Completion code.
	IN	int		transtable	use the transtable ?
							( TRUE/FALSE ).
	IN	char		*basename	Basename of constructed object.
	IN	char		*directory	Directory where the
						constructed object is named.
						Could be overridden when
						transtable option is set.
	IN	struct IGRdisplay *display	Display properties of the
						constructed object.
						Could be overridden when
						transtable option is set.
	IN	short		*level		Level property of the
						constructed object.
						Could be overridden when
						transtable option is set.
	IN	struct GRid	*projectionId	Id of the object that represents
						the projection direction.
	IN	struct GRmd_env	*projectionEnv	Env of the projection direction
	IN	struct GRid	*pointId	Id of selector point.
	IN	struct GRmd_env	*pointEnv	Env of the selector point.
	IN	struct GRid	*hullId		Id of hull surface.
	IN	struct GRmd_env	*hullEnv	Env of hull surface.
	IN	struct GRid	*allowanceDirId	Id of the object that represents
						the allowance direction.
	IN	struct GRmd_env	*allowanceDirEnv Env of allowance direction.
	IN	double		*allowanceVal	Allowance value.
	IN	double		*allowanceExt	Allowance extra value.
	IN	struct GRid	*dataId		Id of base data.
	IN	struct GRmd_env	*dataEnv	Env of base data.
	OUT	struct GRid	*constructedId	Id of the constructed object.

Notes
	* The macro returns MSSUCC if succesfull or MSFAIL if an error
          occurs, in argument 'msg'.
	* All arguments can be NULL except 'msg' and 'constructedId',
	  hullId and dataId.
	* check global description to get more information.

-M*/
extern long
VLplace_curved_seam	__((	long			*msg,
				int			transtable,
				char			*basename,
				char			*directory,
				struct	IGRdisplay	*display,
				short			*level,
				struct	GRid		*projectionId,
				struct	GRmd_env	*projectionEnv,
				struct	GRid		*pointId,
				struct	GRmd_env 	*pointEnv,
				struct	GRid		*hullId,
				struct	GRmd_env 	*hullEnv,
				struct	GRid		*allowanceDirId,
				struct	GRmd_env	*allowanceDirEnv,
				double			*allowanceVal,
				double			*allowanceExt,
				struct	GRid		*dataId,
				struct	GRmd_env 	*dataEnv,
				struct	GRid		*constructedId )) ;

#omdef vl$place_curved_seam(	msg,
				transtable		= TRUE,
				basename		= "CSeam",
				directory		= NULL,
				display 		= NULL,
				level			= NULL,
				projectionId		= NULL,
				projectionEnv		= NULL,
				pointId			= NULL,
				pointEnv		= NULL,
				hullId,
				hullEnv			= NULL,
				allowanceDirId		= NULL,
				allowanceDirEnv		= NULL,
				allowanceVal		= NULL,
				allowanceExt		= NULL,
				dataId,
				dataEnv			= NULL,
				constructedId )

	VLplace_curved_seam( (msg),
		       	   (transtable),
		       	   (basename),
		       	   (directory),
		       	   (display),
		       	   (level),
		       	   (projectionId),
		       	   (projectionEnv),
		       	   (pointId),
		       	   (pointEnv),
		       	   (hullId),
		       	   (hullEnv),
		       	   (allowanceDirId),
		       	   (allowanceDirEnv),
		       	   (allowanceVal),
		       	   (allowanceExt),
		       	   (dataId),
		       	   (dataEnv),
		       	   (constructedId) )
#endomdef
/* ************************************************************************** */

/* ************************************************************************** */
/*+M
Macro vl$place_next_butt

Abstract
	This macro places a next butt on a given hull surface.

Arguments
	OUT	long		*msg		Completion code.
	IN	int		transtable	Use the transtable ?
							( TRUE/FALSE ).
	IN	char		*basename	Basename of constructed object.
	IN	char		*directory	Directory where the
						constructed object is named.
						Could be overridden when
						transtable option is set.
	IN	struct IGRdisplay *display	Display properties of the
						constructed object.
						Could be overridden when
						transtable option is set.
	IN	short		*level		Level property of the
						constructed object.
						Could be overridden when
						transtable option is set.
	IN	struct GRid	*propagDirId	Id of the object that represents
						the propagation direction.
	IN	struct GRmd_env	*propagDirEnv	Env of the propagation direction
	IN	double		length		Distance between previous butt
						and the next butt to be.
	IN	struct GRid	*pointId	Id of selector point.
	IN	struct GRmd_env	*pointEnv	Env of the selector point.
	IN	struct GRid	*hullId		Id of hull surface.
	IN	struct GRmd_env	*hullEnv	Env of hull surface.
	IN	struct GRid	*allowanceDirId	Id of the object that represents
						the allowance direction.
	IN	struct GRmd_env	*allowanceDirEnv Env of allowance direction.
	IN	double		*allowanceVal	Allowance value.
	IN	double		*allowanceExt	Allowance extra value.
	IN	struct GRid	*previousId	Id of previous line.
	IN	struct GRmd_env	*previousEnv	Env of previous line.
	IN	int	 	nbWaterLine	Number of waterlines.
	IN	struct GRid	*waterLineId	Array of waterlines Id.
	IN	struct GRmd_env	*waterLineEnv	Array of waterlines Env.
	IN	double		*devWidth	Development width value.
	OUT	struct GRid	*constructedId	Placed next butt.


Notes
	* The macro returns MSSUCC if succesfull or MSFAIL if an error
          occurs, in argument 'msg'.
	* All arguments can be NULL except 'msg' and 'constructedId',
	  hullId, previousId, nbWaterLine and waterLineId.
	* check global description to get more information on arguments.
	* 'length' is the approximate (in case of development) distance between
	  previous butt 'previousId' and the next butt to be 'constructedId'.
	  Default value is 10000.0 (10 meters).
	* 'nbWaterLine' is the number of waterlines used to evaluate the
	  next butt.
	* 'waterLineId' and 'waterLineEnv' define the array of waterlines
	  used to evaluate the next butt.
	* 'devWidth' is the width value used during development.
	  if 'devWidth' is NULL no development is done.
	  Default value is NULL.

-M*/
extern long
VLplace_next_butt	__((	long			*msg,
				int			transtable,
				char			*basename,
				char			*directory,
				struct	IGRdisplay	*display,
				short			*level,
				struct	GRid		*propagDirId,
				struct	GRmd_env	*propagDirEnv,
				double			length,
				struct	GRid		*pointId,
				struct	GRmd_env	*pointEnv,
				struct	GRid		*hullId,
				struct	GRmd_env 	*hullEnv,
				struct	GRid		*allowanceDirId,
				struct	GRmd_env	*allowanceDirEnv,
				double			*allowanceVal,
				double			*allowanceExt,
				struct	GRid		*previousId,
				struct	GRmd_env	*previousEnv,
				int			nbWaterLine,
				struct	GRid		*waterLineId,
				struct	GRmd_env	*waterLineEnv,
				double			*devWidth,
				struct	GRid		*constructedId )) ;

#omdef vl$place_next_butt(	msg,
				transtable		= TRUE,
				basename		= "Butt",
				directory		= NULL,
				display 		= NULL,
				level			= NULL,
				propagDirId,
				propagDirEnv		= NULL,
				length			= 10000.0,
				pointId			= NULL,
				pointEnv		= NULL,
				hullId,
				hullEnv			= NULL,
				allowanceDirId		= NULL,
				allowanceDirEnv		= NULL,
				allowanceVal		= NULL,
				allowanceExt		= NULL,
				previousId,
				previousEnv		= NULL,
				nbWaterLine,
				waterLineId,
				waterLineEnv		= NULL,
				devWidth		= NULL,
				constructedId )

	VLplace_next_butt( (msg),
		       	   (transtable),
		       	   (basename),
		       	   (directory),
		       	   (display),
		       	   (level),
		       	   (propagDirId),
		       	   (propagDirEnv),
		       	   (length),
		       	   (pointId),
		       	   (pointEnv),
		       	   (hullId),
		       	   (hullEnv),
		       	   (allowanceDirId),
		       	   (allowanceDirEnv),
		       	   (allowanceVal),
		       	   (allowanceExt),
		       	   (previousId),
		       	   (previousEnv),
		       	   (nbWaterLine),
		       	   (waterLineId),
		       	   (waterLineEnv),
		       	   (devWidth),
		       	   (constructedId) )
#endomdef

/* ************************************************************************** */

/* ************************************************************************** */
/*+M
Macro vl$place_next_seam

Abstract
	This macro places a next seam on a given hull surface.

Arguments
	OUT	long		*msg		Completion code.
	IN	int		transtable	Use the transtable ?
							( TRUE/FALSE ).
	IN	char		*basename	Basename of constructed object.
	IN	char		*directory	Directory where the
						constructed object is named.
						Could be overridden when
						transtable option is set.
	IN	struct IGRdisplay *display	Display properties of the
						constructed object.
						Could be overridden when
						transtable option is set.
	IN	short		*level		Level property of the
						constructed object.
						Could be overridden when
						transtable option is set.
	IN	struct GRid	*propagDirId	Id of the object that represents
						the propagation direction.
	IN	struct GRmd_env	*propagDirEnv	Env of the propagation direction
	IN	double		width1		Distance between previous seam
						and the next seam to be.
	IN	double		*width2		Use with complex laws.
	IN	int	 	law		Type of repartition law used.
	IN	int	 	nbDivisor	Number of areas between
						2 linits.
	IN	struct GRid	*pointId	Id of selector point.
	IN	struct GRmd_env	*pointEnv	Env of the selector point.
	IN	struct GRid	*hullId		Id of hull surface.
	IN	struct GRmd_env	*hullEnv	Env of hull surface.
	IN	struct GRid	*allowanceDirId	Id of the object that represents
						the allowance direction.
	IN	struct GRmd_env	*allowanceDirEnv Env of allowance direction.
	IN	double		*allowanceVal	Allowance value.
	IN	double		*allowanceExt	Allowance extra value.
	IN	struct GRid	*previousId	Id of previous line.
	IN	struct GRmd_env	*previousEnv	Env of previous line.
	IN	int		nbLimit		Number of limits.
	IN	struct GRid	*limitId	Array of limits Id.
	IN	struct GRmd_env	*limitEnv	Array of limits Env.
	IN	short	 	smooth	Smoothing seam curve (TRUE/FALSE).
	IN	short		*devIteration	Max. iterations allowed during 
						development.
	OUT	struct GRid	*constructedId	Placed next seam.

Notes
	* The macro returns MSSUCC if succesfull or MSFAIL if an error
          occurs, in argument 'msg'.
	* All arguments can be NULL except 'msg' and 'constructedId',
	  hullId, previousId, limitId and width.
	* check global description to get more information on arguments.
	* 'width1' is the approximate (in case of development) distance between
	  previous seam 'prevSeamId' and the next seam to be 'nextSeamId'.
	  Default value is 2000.0 (2 meters).
	* 'width2' is a distance used by complex approximation laws.
	  Default value is 0.
	* 'law' is the approximation law used.
	  'law' must be select in "vllinedef.h" in the 3rd section
          called "APPROXIMATION LAW".
	  Default value is VL_LL_Linear.
	* 'nbDivisor' is number of intermediary virtual butts used to evaluate
	  the next seam. More that number is big, less is the responce time but
	  the accuracy is increased.
	  To be significant nbDivisor need to be superior or equal to 1.
	  Default value is 1.
	* 'limitNum' is the number of limits used to evaluate the next seam.
	  Need to be at least superior or equal to 1.
	* 'limitId' and 'limitEnv' define the limits used to evaluate the
	  next seam.  Limit can be butts or seams. 'limitId' is necessary.
	  'limitEnv' can be NULL else Env for each limit need to be specified.
	* 'devIteration' is the maximum iterations allowed during development.
	  if 'devIteration' is NULL, no development occurs else need to be >= 1.
	  Default value is NULL.
	* 'smooth' defines if seam curve will be smoothed or not.
	   Possible values are TRUE or FALSE. The default value is TRUE.

-M*/
extern long
VLplace_next_seam	__((	long			*msg,
				int			transtable,
				char			*basename,
				char			*directory,
				struct	IGRdisplay	*display,
				short			*level,
				struct	GRid		*propagDirId,
				struct	GRmd_env	*propagDirEnv,
				double			width1,
				double			*width2,
				int			law,
				int			nbDivisor,
				struct	GRid		*pointId,
				struct	GRmd_env	*pointEnv,
				struct	GRid		*hullId,
				struct	GRmd_env 	*hullEnv,
				struct	GRid		*allowanceDirId,
				struct	GRmd_env	*allowanceDirEnv,
				double			*allowanceVal,
				double			*allowanceExt,
				struct	GRid		*previousId,
				struct	GRmd_env	*previousEnv,
				int			nbLimit,
				struct	GRid		*limitId,
				struct	GRmd_env	*limitEnv,
				short 			smooth,
				short			*devIteration,
				struct	GRid		*constructedId )) ;

#omdef vl$place_next_seam(	msg,
				transtable		= TRUE,
				basename		= "Seam",
				directory		= NULL,
				display 		= NULL,
				level			= NULL,
				propagDirId,
				propagDirEnv		= NULL,
				width1			= 2000.0,
				width2			= NULL,
				law			= V_ATT_LINEAR,
				nbDivisor		= 1,
				pointId			= NULL,
				pointEnv		= NULL,
				hullId,
				hullEnv			= NULL,
				allowanceDirId		= NULL,
				allowanceDirEnv		= NULL,
				allowanceVal		= NULL,
				allowanceExt		= NULL,
				previousId,
				previousEnv		= NULL,
				nbLimit,
				limitId,
				limitEnv		= NULL,
				smooth			= TRUE,
				devIteration		= NULL,
				constructedId )

	VLplace_next_seam( 	(msg),
		       	(transtable),
		       	(basename),
		       	(directory),
		       	(display),
		       	(level),
		       	(propagDirId),
		       	(propagDirEnv),
		       	(width1),
		       	(width2),
		       	(law),
		       	(nbDivisor),
		       	(pointId),
		       	(pointEnv),
		       	(hullId),
		       	(hullEnv),
		       	(allowanceDirId),
		       	(allowanceDirEnv),
		       	(allowanceVal),
		       	(allowanceExt),
		       	(previousId),
		       	(previousEnv),
		       	(nbLimit),
		       	(limitId),
		       	(limitEnv),
		       	(smooth),
		       	(devIteration),
		       	(constructedId) )
#endomdef

/* ************************************************************************** */

/* ************************************************************************** */
/*+M
Macro vl$place_waterline

Abstract
	This macro places a waterline on a given hull surface.

Arguments
	OUT	long		*msg		Completion code.
	IN	int		transtable	use the transtable ? 
							( TRUE/FALSE ).
	IN	char		*basename	Basename of constructed object.
	IN	char		*directory	Directory where the
						constructed object is named.
						Could be overridden when
						transtable option is set.
	IN	struct IGRdisplay *display	Display properties of the
						constructed object.
						Could be overridden when
						transtable option is set.
	IN	short		*level		Level property of the
						constructed object.
						Could be overridden when
						transtable option is set.
	IN	struct GRid	*projectionId	Id of the object that represents
						the projection direction.
	IN	struct GRmd_env	*projectionEnv	Env of the projection direction
	IN	struct GRid	*pointId	Id of selector point.
	IN	struct GRmd_env	*pointEnv	Env of the selector point.
	IN	struct GRid	*hullId		Id of hull surface.
	IN	struct GRmd_env	*hullEnv	Env of hull surface.
	IN	struct GRid	*dataId		Id of base data.
	IN	struct GRmd_env	*dataEnv	Env of base data.
	OUT	struct GRid	*constructedId	Id of the constructed object.

Notes
	* The macro returns MSSUCC if succesfull or MSFAIL if an error
          occurs, in argument 'msg'.
	* All arguments can be NULL except 'msg' and 'constructedId',
	  hullId and dataId.
	* check global description to get more information.

-M*/
extern long
VLplace_waterline	__((	long			*msg,
				int			transtable,
				char			*basename,
				char			*directory,
				struct	IGRdisplay	*display,
				short			*level,
				struct	GRid		*projectionId,
				struct	GRmd_env	*projectionEnv,
				struct	GRid		*pointId,
				struct	GRmd_env 	*pointEnv,
				struct	GRid		*hullId,
				struct	GRmd_env 	*hullEnv,
				struct	GRid		*dataId,
				struct	GRmd_env 	*dataEnv,
				struct	GRid		*constructedId )) ;

#omdef vl$place_waterline(	msg,
				transtable		= TRUE,
				basename		= "WaterL",
				directory		= NULL,
				display 		= NULL,
				level			= NULL,
				projectionId		= NULL,
				projectionEnv		= NULL,
				pointId			= NULL,
				pointEnv		= NULL,
				hullId,
				hullEnv			= NULL,
				dataId,
				dataEnv			= NULL,
				constructedId )

	VLplace_waterline( (msg),
		       	   (transtable),
		       	   (basename),
		       	   (directory),
		       	   (display),
		       	   (level),
		       	   (projectionId),
		       	   (projectionEnv),
		       	   (pointId),
		       	   (pointEnv),
		       	   (hullId),
		       	   (hullEnv),
		       	   (dataId),
		       	   (dataEnv),
		       	   (constructedId) )
#endomdef

/* ************************************************************************** */

/* ************************************************************************** */
/*+M
Macro vl$place_trace

Abstract
	This macro places a trace on a given hull surface.

Arguments
	OUT	long		*msg		Completion code.
	IN	int		transtable	use the transtable ?
							( TRUE/FALSE ).
	IN	char		*basename	Basename of constructed object.
	IN	char		*directory	Directory where the
						constructed object is named.
						Could be overridden when
						transtable option is set.
	IN	struct IGRdisplay *display	Display properties of the
						constructed object.
						Could be overridden when
						transtable option is set.
	IN	short		*level		Level property of the
						constructed object.
						Could be overridden when
						transtable option is set.
	IN	struct GRid	*projectionId	Id of the object that represents
						the projection direction.
	IN	struct GRmd_env	*projectionEnv	Env of the projection direction
	IN	struct GRid	*pointId	Id of selector point.
	IN	struct GRmd_env	*pointEnv	Env of the selector point.
	IN	struct GRid	*hullId		Id of hull surface.
	IN	struct GRmd_env	*hullEnv	Env of hull surface.
	IN	struct GRid	*dataId		Id of base data.
	IN	struct GRmd_env	*dataEnv	Env of base data.
	OUT	struct GRid	*constructedId	Id of the constructed object.

Notes
	* The macro returns MSSUCC if succesfull or MSFAIL if an error
          occurs, in argument 'msg'.
	* All arguments can be NULL except 'msg' and 'constructedId',
	  hullId and dataId.
	* check global description to get more information.

-M*/
extern long
VLplace_trace	__((		long			*msg,
				int			transtable,
				char			*basename,
				char			*directory,
				struct	IGRdisplay	*display,
				short			*level,
				struct	GRid		*projectionId,
				struct	GRmd_env	*projectionEnv,
				struct	GRid		*pointId,
				struct	GRmd_env 	*pointEnv,
				struct	GRid		*hullId,
				struct	GRmd_env 	*hullEnv,
				struct	GRid		*dataId,
				struct	GRmd_env 	*dataEnv,
				struct	GRid		*constructedId )) ;

#omdef vl$place_trace(	msg,
			transtable		= TRUE,
			basename		= "Trace",
			directory		= NULL,
			display 		= NULL,
			level			= NULL,
			projectionId		= NULL,
			projectionEnv		= NULL,
			pointId			= NULL,
			pointEnv		= NULL,
			hullId,
			hullEnv			= NULL,
			dataId,
			dataEnv			= NULL,
			constructedId )

	VLplace_trace( (msg),
		       	   (transtable),
		       	   (basename),
		       	   (directory),
		       	   (display),
		       	   (level),
		       	   (projectionId),
		       	   (projectionEnv),
		       	   (pointId),
		       	   (pointEnv),
		       	   (hullId),
		       	   (hullEnv),
		       	   (dataId),
		       	   (dataEnv),
		       	   (constructedId) )
#endomdef

/* ************************************************************************** */

#endif /* vlAPImacros_include */

