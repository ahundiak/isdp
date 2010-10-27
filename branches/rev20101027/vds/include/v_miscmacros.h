/* $Id: v_miscmacros.h,v 1.1.1.1 2001/01/04 21:07:31 cvs Exp $  */

/*************************************************************************
 * I/VDS
 *
 * File:	include / v_miscmacros.h
 *
 * Description:
 * 	Miscellaneous utility macros.
 * Dependencies:
 *
 * Revision History:
 *	$Log: v_miscmacros.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:31  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.2  1997/10/29  14:44:00  pinnacle
 * Replaced: include/v_miscmacros.h for:  by rchennup for vds
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.3  1995/08/16  20:56:28  pinnacle
 * Replaced: include/v_misc* for:  by tlbriggs for vds.240
 *
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *	08/03/95   tlb		Move _MALLOC, _CALLOC, _FREE into VDmem.h
 *
 *************************************************************************/

#ifndef v_miscmacros_include
#	define v_miscmacros_include

#ifndef _STANDARDS_H_
#	include <standards.h>
#endif

#ifndef v_include
#	include "v_.h"
#endif
#ifndef v_cmd_include
#	include "v_cmd.h"
#endif
#ifndef v_globals_include
#	include "v_globals.h"
#endif

/* 
 * Memory allocation macros 
 */
#	include	"VDmem.h"


/*
Abstract
	The following macros are short forms for the (sub-)fields of type
	`struct GRmd_env' and `struct GRobj_env'.
*/

#define _MD_ID		md_id.objid
#define _MD_OS		md_id.osnum
#define _MATRIX		md_env.matrix
#define _MATRIX_TYPE	md_env.matrix_type
#define	_grid		obj_id
#define	_objid		obj_id.objid
#define	_osnum		obj_id.osnum
#define _md_id		mod_env._MD_ID
#define _md_os		mod_env._MD_OS
#define _matrix		mod_env._MATRIX
#define _matrix_type	mod_env._MATRIX_TYPE

extern GRclassid	OPP_ACconst_class_id;

/* --------------------------- om$send macros -------------------------*/

#define _VD_SEND( obj, mesg )			\
	om$send(targetid = obj,			\
		msg = message mesg )

#define _VD_SEND_MY( mesg )			\
	om$send(targetid = my_id,		\
		msg = message mesg )

#define _VD_SEND_OS( objid, osnum, mesg )	\
        om$send(targetid = objid,		\
		targetos = osnum,		\
		msg = message mesg )

#define _VD_SEND_OBJ( object, mesg )		\
        om$send(targetid = (object).objid,	\
		targetos = (object).osnum,	\
		msg = message mesg )

#define _VD_SEND_OBJN( object, mesg )		\
        om$send(senderid = NULL_OBJID,		\
		targetid = (object).objid,	\
		targetos = (object).osnum,	\
		msg = message mesg )

#define	_VD_SEND_NULL( obj, mesg )		\
	om$send(senderid = NULL_OBJID,		\
		targetid = obj,			\
		msg = message mesg )
	
#define	_VD_SEND_WRT_M( obj, mesg )		\
	om$send(msg = message mesg,		\
		mode = OM_e_wrt_message,	\
		senderid = NULL_OBJID,		\
		targetid = obj )
	
#define _VD_SEND_CHAN( chan, mesg )		\
	om$send(p_chanselect = & chan,		\
		msg = message mesg )

/*+M
Macro IF_EQ_GRID

Abstract
	Tests the equality of two GRids.
Note
	OMmacros.h must be included for this macro.
-M*/
#define IF_EQ_GRID( gr1, gr2 )\
	(    IF_EQ_OBJID( (gr1).objid, (gr2).objid )\
	  && (gr1).osnum == (gr2).osnum )

/*+M
Macro IF_EQ_pGRID

Abstract
	Tests the equality of two GRid's using pointers.
Note
	OMmacros.h must be included for this macro.
-M*/
#define IF_EQ_pGRID( p_gr1, p_gr2 )\
	(    IF_EQ_OBJID( (p_gr1)->objid, (p_gr2)->objid )\
	  && (p_gr1)->osnum == (p_gr2)->osnum )

/*+M
Macro vd_$is_ancestry_valid

Abstract
	Checks if input object is of given class or of one of its subclasses.

Arguments
	IN	const struct GRid	*object		Object to test.
	IN	OMuword			classid		Class id.

Returns
	TRUE if `object' of (sub)class `classid' else FALSE.
-M*/
extern int
VD_is_ancestry_valid		__((	const struct GRid	*object,
					OMuword			classid )) ;

#omdef vd_$is_ancestry_valid(	object,
				classid )
	VD_is_ancestry_valid( (object), (classid) )
#endomdef

/*+M
Macro vd_$is_object_of_classes

Abstract
	Checks if input object's class is among list or is a sub-class of
	classes in list, or conversly, checks if input object's class is
	NOT among list or is NOT a sub-class of classes in list.

Arguments
	IN	OM_S_OBJID		objid		Id of object to test.
	IN	OMuword			osnum		Object space number
							of object to test.
	IN	const OM_S_CLASSLIST	*classList	Class list for check.
Note
	To check if objects are NOT in the class list `classList->w_flags`
	must be set to `OM_CLST_negation'. This is the only flag recognized.

	vd_$is_object_of_classes( objid = <some_id>, osnum = <some_os> ) is
	always TRUE.

Sample usage
	OMuword		classes[3] ;
	OM_S_CLASSLIST	list ;
	OM_S_OBJID	test_id ;

	list.w_count = 3 ;
	list.p_classes = classes ;
	list.w_flags = 0 ;
	if( vd_$is_object_of_classes(	objid		= test_id,
					classList	= &list ) ) {
			...
	}

Returns
	TRUE if `objid, osnum' satifies criterion else FALSE.

-M*/
extern int
VD_is_object_of_classes		__((	OM_S_OBJID		objid,
					OMuword			osnum,
					const OM_S_CLASSLIST	*classList )) ;

#omdef vd_$is_object_of_classes(	objid		= my_id,
				osnum		= OM_Gw_current_OS,
				classList 	= NULL )
	VD_is_object_of_classes( (objid), (osnum), (classList) )
#endomdef

/*+M
Macro vd_$is_osnum_in_list

Abstract
	Checks if input object space number is among list.

Arguments
	IN	OMuword			osnum		Object space number
							of object to test.
	IN	int			spaceCount	Count of input OSes.
	IN	const OMuword		spaceList[]	List of input OSes.
Returns
	TRUE if `osnum' in `spaceList' else FALSE.
Note
	vd_$is_osnum_in_list( osnum = <some_os> ) is always TRUE.
-M*/
extern int
VD_is_osnum_in_list		__((	OMuword			osnum,
					int			spaceCount,
					const OMuword		spaceList[] )) ;

#omdef vd_$is_osnum_in_list(	osnum,
				spaceCount	= 0,
				spaceList	= NULL )
	VD_is_osnum_in_list( (osnum), (spaceCount), (spaceList) )
#endomdef

/*+M
Macro vd_$get_gs_content

Abstract
	Returns the content of a graphic set, ridden of the clipping polygon
	in case of a fence content operation, possibly ridden of objects which
	are not in the specified object spaces or not of the specified classes.

Arguments
	OUT	long			*msg		Completion code.
	IN	struct GRid		*gs		Graphic set to process.
	IN	OMuword			spaceList[]	Objects spaces to keep.
	IN	int			spaceCount	Count of OSes in list.
	IN	OM_S_CLASSLIST		classList[]	Classes to keep.
	IN	int			(*filter)()	Filter function.
	IN	VD_fenceArgs		*args		Arguments to filter.
	OUT	int			*p_count	Count of objects in set.
	OUT	struct GRobj_env	**p_content	List of objects in set.
	OUT	int			*p_notCount	Count of objects in set
							not kept (optional).
	OUT	struct GRobj_env	**p_notKeep	List of objects in set
							not kept (optional).

Note
	If `spaceList' is NULL or spaceCount is 0, objects from all spaces will be
	returned.

	If `classList' is NULL or `classList->w_count` is 0, objects from
	all classes will be kept.

	To check if objects are NOT in the class list `classList->w_flags`
	must be set to `OM_CLST_negation'. This is the only flag recognized.

	`filter' must be declared as follows:

		int filter( object, args )
		struct GRobj_env *object ;
		VD_fenceArgs	 *args ;

	and must return TRUE if object is to be kept else FALSE.
	
	`*p_content' and `*p_notKeep' are malloced by this function, it is up 
	to the caller to free it if not NULL.

	*msg will be
		MSSUCC	if successfull
		MSFAIL	if severe error
-M*/
extern int
VD_get_gs_content
	__((	long			*msg,
		struct GRid		*gs,
		OMuword			spaceList[],
		int			spaceCount,
		OM_S_CLASSLIST		classList[],
		int			(*filter) __((	struct GRobj_env *o,
							VD_fenceArgs      *a )),
		VD_fenceArgs		*args,
		int			*p_count,
		struct GRobj_env	**p_content,
		int			*p_notCount,
		struct GRobj_env	**p_notKeep )) ;

#omdef vd_$get_gs_content(	msg,
				gs,
				spaceList	= 0,
				spaceCount	= NULL,
				classList	= NULL,
				filter		= NULL,
				args		= NULL,
				p_count,
				p_content,
				p_notCount	= NULL,
				p_notKeep 	= NULL)
	VD_get_gs_content( (msg), (gs), (spaceList), (spaceCount),
				(classList), (filter), (args),
				(p_count), (p_content),
				(p_notCount), (p_notKeep) )
#endomdef

/*+M
Macro vd_$process_fence

Abstract
	Given a fence id, processes its content after asking the user to
	accept or reject it.
	Returns the content of the fence, ridden of the clipping polygon
	in case of a fence content operation, possibly ridden of objects which
	are not in the specified object spaces or not of the specified classes.

Arguments
	OUT	long			*msg		Completion code.
	IN	struct GRobj_env	*fence		Graphic set to process.
	IN	OMuword			spaceList[]	Objects spaces to keep.
	IN	int			spaceCount	Count of OSes in list.
	IN	OM_S_CLASSLIST		*classList	Classes to keep.
	IN	int			(*filter)()	Filter function.
	IN	VD_fenceArgs		*args		Arguments to filter.
	OUT	int			*p_count	Count of objects in set.
	OUT	struct GRobj_env	**p_content	List of objects in set.
	OUT	int			*response	From user.
	OUT	char			*response_data	From user.
Note
	If `spaceList' is NULL or spaceCount is 0, objects from all spaces will
	be returned.

	If `classList' is NULL or `classList->w_count` is 0, objects from
	all classes will be kept.

	`filter' must be declared as follows:

		int filter( object )
		struct GRobj_env *object ;
		VD_fenceArgs	 *args ;

	and must return TRUE if object is to be kept else FALSE.

	`*p_content' is malloced by this function, it is up to the caller to
	free it if not NULL.

	This function simply returns the object if it is not a fence.

	Nothing will be returned if fence was rejected (*response != EX_DATA)
	*msg will be
		MSSUCC		if successful
		EMS_I_Fail	if input object is not a fence
				(returned in `(*p_content[0])' anyway )
		MSFAIL		if severe error
-M*/
extern int
VD_process_fence
	__((	long			*msg,
		struct GRobj_env	*fence,
		OMuword			spaceList[],
		int			spaceCount,
		OM_S_CLASSLIST		*classList,
		int			(*filter) __((	struct GRobj_env *o,
							VD_fenceArgs      *a )),
		VD_fenceArgs		*args,
		int			*p_count,
		struct GRobj_env	**p_content,
		int			*response,
		char			*response_data )) ;

#omdef vd_$process_fence(	msg,
				fence,
				spaceCount	= 0,
				spaceList	= NULL,
				classList	= NULL,
				filter		= NULL,
				args		= NULL,
				p_count,
				p_content,
				response,
				response_data )

	VD_process_fence( (msg), (fence), (spaceList), (spaceCount),
				(classList), (filter), (args),
				(p_count), (p_content),
				(response), (response_data) )
#endomdef

/*+M
Macro vd_$fill_cnst_list

Abstract
	Fills a "struct GRvg_construct" structure.
Arguments
	The fields of "struct GRvg_construct".

-M*/
#omdef	vd_$fill_cnst_list(
			Cnst_list,
			Msg		= msg,
			Env_info,
			Newflag		= FALSE,
			Level		= VD_Gi_DummyLevel,
			Display		= VD_Gp_DummyDisplay,
			Geometry	= NULL,
			Properties	= GRIS_DISPLAYABLE | GRIS_LOCATABLE,
			Class_attr	= NULL,
			Name		= NULL )

	(Cnst_list).msg		= (Msg) ; 
	(Cnst_list).env_info	= (Env_info) ;
	(Cnst_list).newflag	= (Newflag) ;
	(Cnst_list).level	= (Level) ;
	(Cnst_list).display	= (Display) ;
	(Cnst_list).geometry	= (char *) (Geometry) ;
	(Cnst_list).properties	= (Properties) ;
	(Cnst_list).class_attr	= (char *) (Class_attr) ;
	(Cnst_list).name	= (Name) ;
#endomdef

/*+M
Macro vd_$consume

Abstract
	Consumes an object and returns the feet of the consumed object.
Arguments
	OUT	long		*msg		Completion code.
	IN	struct GRid	*object		Object to consume.
	IN	struct GRmd_env	*ftEnv		Environment feet must be in.
	IN	int		nbfeet		Count of feet wanted.
	OUT	struct GRid	feet[]		List of feet (array of
						dimension >= nbfeet ).
	OUT	struct GRmd_env	*objEnv		Environment of consumed object
						(optional).
-M*/
extern long
VD_consume		__((	long		*msg,
				struct GRid	*object,
				struct GRmd_env	*ftEnv,
				int		nbfeet,
				struct GRid	feet[],
				struct GRmd_env	*objEnv )) ;

#omdef	vd_$consume( msg, objId, ftEnv, nbfeet, feet, objEnv = NULL )

	VD_consume( (msg), (objId), (ftEnv), (nbfeet), (feet), (objEnv) )

#endomdef

/*+M
Macro vd_$unconsume

Abstract
	Unconsumes an object.
	If a representation is specified, it will be set to the object.
	if `compute' is specified, the object will be recomputed.
Arguments
	OUT	long		*msg		Completion code.
	IN	struct GRid	*object		Object to consume.
	IN	struct GRmd_env	*mod_env	Module environment of all feet.
	IN	int		rep		Representation.
	IN	int		compute		Recompute object ?
-M*/
extern long
VD_unconsume			__((	long		*msg,
					struct GRid	*object,
					struct GRmd_env	*mod_env,
					int		rep,
					int		compute )) ;

#omdef	vd_$unconsume( msg, object, mod_env, rep = AC_NO_REP, compute = FALSE )

	VD_unconsume( (msg), (object), (mod_env), (rep) , (compute) )

#endomdef

/*+M
Macro vd$plmacro()

Abstract  
  	Place a macro occurrence.

Arguments 
	IN 	char			*macName	Macro name
	IN      char			*name		Occurrence name
	IN	int			tplNb		Number of templates
	IN	struct  GRobj_env	*tplList	List of templates
	IN	struct  GRsymbology	*symb		Symbology
	IN	struct  GRid		*occId		Example occurence
	IN	GRclassid		classid		Classid of macro
	IN	short			props		Placement properties
	IN	short 			rep		Macro representation
	IN	char			asState		Assoc properties
	IN	struct  GRmd_env	*curMdEnv	Placement environment
	OUT	struct  GRid		*macId		Macro Id
-M*/

extern long
VDplMacro		__(( 	char                    *macName,
				char			*name,
				int			tplNb,
				struct  GRobj_env	*tplList,
				struct  GRsymbology	*symb,
				struct  GRid		*occId,
				GRclassid 		classid,
				short			props,
				short			rep,
				char			asState,
				struct  GRmd_env	*curMdEnv,
				struct  GRid		*macId 	     ));

#omdef vd$plmacro( 	macName,
			name		= NULL,
			tplNb,
			tplList,
			symb		= NULL,
			occId		= NULL,
			classid		= OPP_ACconst_class_id,
			props		= 0,
			rep		= 0,
			asState		= 0,
			env,
			macId		= NULL )

	VDplMacro( (macName), (name), (tplNb), (tplList), (symb), (occId), 
		   (classid), (props), (rep), (asState), (env), (macId) )

#endomdef

/*+M
Macro vd_$bulk_delete

Abstract
	Deletes a list of graphic objects.
Arguments
	IN	int			count		Count of graphics.
	I/O	OM_S_OBJID		objids[]	Object ids of graphics.
-OR-	I/O	struct GRid		grids[]		GRids of graphics.
-OR-	I/O	struct GRobj_env	objenvs[]	GRobj_envs of graphics.
	IN	const struct GRmd_env	*theEnv		Mod. env. of graphics.
Note
	`theEnv' must be specified if `objids' or `grids' is specified.
	For `objids', the object space taken is that of the module in `theEnv'.
	Some object ids may be NULL_OBJID (no action taken).
	CAUTION: Upon exit the object ids are all NULL_OBJID.
-M*/
extern long
VD_bulkDeleteByGRobj_envs	__((	int			count,
					struct GRobj_env	objenvs[] )) ;
extern long
VD_bulkDeleteByGRids		__((	const struct GRmd_env	*theEnv,
					int			count,
					struct GRid		grids[] )) ;
extern long
VD_bulkDeleteByObjid		__((	const struct GRmd_env	*theEnv,
					int			count,
					OM_S_OBJID		objids[] )) ;

#omdef vd_$bulk_delete(	count	= 1,
			objids	= NULL,
			grids	= NULL,
			objenvs	= NULL,
			theEnv	= NULL )
#	if om$specified( objenvs )
		VD_bulkDeleteByGRobj_envs(
				(count),
				(objenvs) )
#	elif om$specified( grids )
#		if om$equal( theEnv, NULL )
#			omerror "vd_$bulk_delete: `theEnv' must be set."
#		else
			VD_bulkDeleteByGRids(
				(theEnv),
				(count),
				(grids) )
#		endif
#	elif om$specified( objids )
#		if om$equal( theEnv, NULL )
#			omerror "vd_$bulk_delete: `theEnv' must be set."
#		else
			VD_bulkDeleteByObjid(
				(theEnv),
				(count),
				(objids) )
#		endif
#	else
#		omerror "vd_$bulk_delete: must specify objids, grids or objenvs."
#	endif
#endomdef

/*+M
Macro vd_$bulk_display

Abstract
	Displays a list of graphic objects.
Arguments
	IN	enum GRdpmode		dpmode		The display mode.
	IN	int			count		Count of graphics.
	IN	OM_S_OBJID		objids[]	Object ids of graphics.
-OR-	IN	struct GRid		grids[]		GRids of graphics.
-OR-	IN	struct GRobj_env	objenvs[]	GRobj_envs of graphics.
	IN	struct GRmd_env		*theEnv		Mod. env. of graphics.
Note
	`theEnv' must be specified if `objids' or `grids' is specified.
	For `objids', the object space taken is that of the module in `theEnv'.
	Some object ids may be NULL_OBJID (no action taken).
-M*/
extern long
VD_bulkDisplayByGRobj_envs	__((	enum GRdpmode		dpmode,
					int			count,
					struct GRobj_env	objenvs[] )) ;
extern long
VD_bulkDisplayByGRids		__((	struct GRmd_env		*theEnv,
					enum GRdpmode		dpmode,
					int			count,
					struct GRid		grids[]	)) ;
extern long
VD_bulkDisplayByObjid		__((	struct GRmd_env		*theEnv,
					enum GRdpmode		dpmode,
					int			count,
					OM_S_OBJID		objids[] )) ;

#omdef vd_$bulk_display(	dpmode	= GRbd,
			count	= 1,
			objids	= NULL,
			grids	= NULL,
			objenvs	= NULL,
			theEnv	= NULL )
#	if om$specified( objenvs )
		VD_bulkDisplayByGRobj_envs( (dpmode), (count), (objenvs) )
#	elif om$specified( grids )
#		if om$equal( theEnv, NULL )
#			omerror "vd_$bulk_display: `theEnv' must be set."
#		else
			VD_bulkDisplayByGRids(	(theEnv), (dpmode),
						(count), (grids) )
#		endif
#	elif om$specified( objids )
#		if om$equal( theEnv, NULL )
#			omerror "vd_$bulk_display: `theEnv' must be set."
#		else
			VD_bulkDisplayByObjid(	(theEnv), (dpmode),
						(count), (objids) )
#		endif
#	else
#		omerror "vd_$bulk_display: must specify objids, grids or objenvs."
#	endif
#endomdef

#endif /* v_miscmacros_include */

