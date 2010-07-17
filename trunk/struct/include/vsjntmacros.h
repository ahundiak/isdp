/* $Id: vsjntmacros.h,v 1.1.1.1 2001/01/04 21:09:43 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	struct/include/vsjntmacros.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vsjntmacros.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:09:43  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/30  10:08:06  pinnacle
 * STRUCT 2.5.1
 *
 * Revision 1.3  1997/12/18  13:36:12  pinnacle
 * Replaced: include/vsjntmacros.h for:  by svkadamb for struct
 *
 * Revision 1.2  1997/11/14  12:37:10  pinnacle
 * Replaced: include/vsjntmacros.h for:  by svkadamb for struct
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			suresh		modification 
 ***************************************************************************/
/*
	I/STRUCT
*/
#ifndef vsjntmacros_include
#	define vsjntmacros_include

#ifndef _STANDARDS_H_
#	include <standards.h>
#endif

#ifndef OM_D_MINIMUM
#	include "OMminimum.h"
#endif
#ifndef igetypedef_include
#	include "igetypedef.h"
#endif
#ifndef igrtypedef_include
#	include "igrtypedef.h"
#endif
#ifndef gr_include
#	include "gr.h"
#endif
#ifndef igr_include
#	include "igr.h"
#endif
#ifndef igrdp_include
#	include "igrdp.h"
#endif
#ifndef growner_include
#	include "growner.h"
#endif
#ifndef vsattr_include
#	include "vsattr.h"
#endif
#ifndef vsjoint_include
#	include "vsjoint.h"
#endif

/*+M
Macro vs$getLoopset

Abstract
	Finds the loopset of a surface.
Arguments
	OUT	long			*msg		Completion code.
	IN	struct GRobj_env	*surface	Surface (EMSsubbs).
	OUT	struct GRid		*loopset	Id of loopset.
Note
	If surface has no topology, this macro will put some onto it.
-M*/
extern long
VSgetLoopset			__((	long			*msg,
					struct GRobj_env	*surface,
					struct GRid		*loopset )) ;

#omdef vs$getLoopset( msg, surface, loopset )
	VSgetLoopset( (msg), (surface), (loopset) )
#endomdef

/*+M
Macro vs$rejoin

Abstract
	After an operation has been performed on a structural element (eg.
	plate, beam ), and this element was joined to other structural elements,
	this macro rejoins the structural element after the operation to
	the other structural element.

Arguments
	OUT	long			*msg	Completion code.
	IN	struct GRobj_env	*elBfOp	Element before operation.
	IN	unsigned long		type	Type of above.
	IN	struct GRobj_env	*elAfOp	Element after operation.
	IN	char			*subJointDir
						Directory where  sub-joints
						will name themselves (may be
						NULL).

Note
	`elBfOp' (operand of the operation) has been consumed by `elAfOp'
	(result of the operation).
	`type' may take two values :
		- VS_m_MOD_GENERIC if operation gives out one result.
		- VS_m_DIV_GENERIC if operation gives several results
				   (division).
	Both are #define'd in `vsdef.h'.

	`subJointDir' is only considered when `type' is VS_m_DIV_GENERIC, where
	new sub-joints must be named, if it is NULL, sub-joints will not be
	names.
-M*/
extern long
VSrejoin			__((	long			*msg,
					unsigned long		type,
					struct GRobj_env	*elBfOp,
					struct GRobj_env	*elAfOp,
					char			*subJointDir )) ;

#omdef vs$rejoin( msg, type, elBfOp, elAfOp, subJointDir = NULL )
	VSrejoin( (msg), (type), (elBfOp), (elAfOp), (subJointDir) )
#endomdef

/*+M
Macro vs$joinAfterDivision

Abstract
	After a structural element has undergone a division operation giving
	out two results, this macro joins the two results (sub-elements) to
	the structural elements to which the element was joined before the
	division, if any. Moreover it joins the two sub-elements together,
	or to the operator of the division if requested ( `jnInfo' not NULL ).
Arguments
	OUT	long			*msg		Completion code.
	IN	VSjoinInfo		*jnInfo		Joining information.
	IN	struct GRobj_env	*elBfDiv	Operand of division.
	IN	struct GRobj_env	*elAfDiv	Division manager.
	IN	struct GRobj_env	*divOperator	Operator of division.
	IN	OM_S_OBJID		subElement0	1st sub-element.
	IN	OM_S_OBJID		subElement1	2nd sub-element.
	IN	struct GRmd_env		*subEnv		Env. of sub-elements.
Notes
	`elBfDiv' (operand of the operation) has been consumed by `elAfDiv'
	(intermediate result of the operation: division manager).

	If `jnInfo' is NULL, the sub-elements will not be joined either
	together or to the operator. If not NULL, the following action will be
	taken according to the value of `jnInfo->action' :

	- VS_K_JOIN_RESULTS_TOGETHER	: sub-elements joined together.
	- VS_K_JOIN_RESULTS_WITH_DIVISOR: each sub-element joined with the
					  operator of the division.
	Both are #define'd in `vsjointdef.h'.

	If `jnInfo->action' is VS_K_JOIN_RESULTS_TOGETHER, then `divOperator'
	may be NULL.

	The type `VSjoinInfo' is defined in `vsjoint.h'.
-M*/
extern long
VSjoinAfterDivision		__((	long			*msg,
					VSjoinInfo		*jnInfo,
					struct GRobj_env	*elBfDiv,
					struct GRobj_env	*elAfDiv,
					struct GRobj_env	*divOperator,
					OM_S_OBJID		subElement0,
					OM_S_OBJID		subElement1,
					struct GRmd_env		*subEnv )) ;

#omdef vs$joinAfterDivision(	msg,
				jnInfo	= NULL,
				elBfDiv,
				elAfDiv,
				divOperator,
				subElement0,
				subElement1,
				subEnv )
	VSjoinAfterDivision(	(msg),
				(jnInfo),
				(elBfDiv),
				(elAfDiv),
				(divOperator),
				(subElement0),
				(subElement1),
				(subEnv) )
#endomdef

/*+M
Macro vs$getJunctionType

Abstract
	Finds the type of junction between two structural elements.
Arguments
	OUT	long			*msg		Completion code.
	IN	struct GRobj_env	*elToJoin1	First element to join.
	IN	struct GRobj_env	*elToJoin2	Second element to join.
	OUT	int			*junctionType	Junction type.
Node
	`*elToJoin1' and `*elToJoin2' must be both plates, both beams, a beam
	and a plate or a plate and a beam.

	`*junctionType' will be one of
		VS_K_J_PL_PL
		VS_K_J_BM_BM
		VS_K_J_PL_BM
		VS_K_J_BM_PL
		VS_K_J_ST_TP
		VS_K_J_ST_BT
		VS_K_J_TP_ST
		VS_K_J_BT_ST
	#define'd in vsjointdef.h
-M*/
extern long
VSgetJunctionType		__((	long			*msg,
					struct GRobj_env	*elToJoin1,
					struct GRobj_env	*elToJoin2,
					int			*junctionType )) ;

#omdef vs$getJunctionType( msg, elToJoin1, elToJoin2, junctionType )
	VSgetJunctionType( (msg), (elToJoin1), (elToJoin2), (junctionType) )
#endomdef

/*+M
Macro vs$giveJointType

Abstract
	Finds the type of joint between two plates.
Arguments
	OUT	long			*msg		Completion code.
	IN	struct GRobj_env	*joint		Joint between plates.
	IN	struct GRobj_env	plate0		First plate.
	IN	struct GRobj_env	plate1		Second plate
	OUT	int			*jointType	Joint type.
Node
	The joint should be the joint between the two plates that are sent
	as an input to this macro.

	`*jointType' will be one of
		VS_K_SURF_SURF
		VS_K_SURF_EDGE
		VS_K_EDGE_SURF
		VS_K_EDGE_EDGE


-M*/
extern long
VSgiveJointType		__((	long			*msg,
				struct GRobj_env	*joint,
				struct GRobj_env	plate0,
				struct GRobj_env	plate1,
				int			*jointType )) ;

#omdef vs$giveJointType( msg, joint,plate0, plate1, jointType )
	VSgiveJointType( (msg), (joint), (plate0), (plate1), (jointType) )
#endomdef

/*+M
Macro vs$findEdgeSurfaceMatch

Abstract
	Finds the edges of one surface which touch another surface. Returns the
	list of edges with the paramaters of the edge curve where they start
	and stop touching the surface.
Arguments
	OUT	long			*msg		Completion code.
	IN	struct GRobj_env	*sfForEdges	Surface the edges of
							which are to be
							considered.
	IN	struct GRobj_env	*surface	Surface against which
							edges are to be tested.
	OUT	int			*matchCount	Count of matches.
	OUT	VSmatchingEdges		**matchList	List of matches.
Note
	This macro may be invoked several times in a row, before the first call
	`*matchCount' must be set to 0 and `*matchList' to NULL; upon
	sub-sequent calls `*matchCount' will be incremented and new lists will
	be added to `*matchList'.
	The memory allocated for the linked list `*matchList' must be freed
	with :
		VSfreeMatchList( *matchList ) ;
-M*/
extern long
VSfindEdgeSurfaceMatch		__((	long			*msg,
					struct GRobj_env	*sfForEdges,
					struct GRobj_env	*surface,
					int			*matchCount,
					VSmatchingEdges		**matchList )) ;

#omdef vs$findEdgeSurfaceMatch(	msg,
				sfForEdges,
				surface,
				matchCount,
				matchList )
	VSfindEdgeSurfaceMatch(	(msg),
				(sfForEdges),
				(surface),
				(matchCount),
				(matchList) )
#endomdef

/*+M
Macro vs$findOverlappingEdges

Abstract
	Finds the edges of one surface which touch those of another surface.
Arguments
	OUT	long			*msg		Completion code.
	IN	struct GRobj_env	*surface1	First surface.
	IN	struct GRobj_env	*surface2	Second surface.
	OUT	int			*matchCount	Count of matches.
	OUT	VSmatchingEdges		**matchList	List of matches.
Note
	This macro may be invoked several times in a row, before the first call
	`*matchCount' must be set to 0 and `*matchList' to NULL; upon
	sub-sequent calls `*matchCount' will be incremented and new lists will
	be added to `*matchList'.
	The memory allocated for the linked list `*matchList' must be freed
	with :
		VSfreeMatchList( *matchList ) ;
-M*/
extern long
VSfindOverlappingEdges		__((	long			*msg,
					struct GRobj_env	*surface1,
					struct GRobj_env	*surface2,
					int			*matchCount,
					VSmatchingEdges		**matchList )) ;

#omdef vs$findOverlappingEdges(	msg,
				surface1,
				surface2,
				matchCount,
				matchList )
	VSfindOverlappingEdges(	(msg),
				(surface1),
				(surface2),
				(matchCount),
				(matchList) )
#endomdef

/*+M
Macro vs$getWeldCodeASCII

Abstract
	Returns the list of descriptions of the available weld codes in the
	given file.

Arguments
	OUT	long		*msg		Completion code.
	IN	char		*name		File name to pick up the 
						weld code types
	OUT	int		*count		Count of available codes.
	OUT	char		***list		List of weld codes in the
						ASCII file
Note
	`*list' is alloced internally, hence MUST BE FREED by the
	caller usinf VSfreeList();

	sample call:

		long 	msg ;
		int 	count ;
		char	**list ;

		vs$getWeldCodeASCII(	msg	= &msg,
					name	= "weld_code",
					count	= &count,
					list	= &list ) ;
	wrapup:
	
		VSfreeList(count,list);

-M*/
extern long
VSgetWeldCodeASCII		__((	long		*msg,
					char		*name,
					int		*count,
					char		***list )) ;

#omdef vs$getWeldCodeASCII( 	msg, 
				name = "weld_code", 
				count, 
				list )

	VSgetWeldCodeASCII( (msg), (name), (count), (list) )
#endomdef

/*+M
Macro vs$getWeldProcASCII

Abstract
	Returns the list of descriptions of the available weld processes in the
	given file.

Arguments
	OUT	long		*msg		Completion code.
	IN	char		*name		File name to pick up the 
						weld processes.
	OUT	int		*count		Count of available Processes.
	OUT	char		***list		List of weld processes in the
						given ASCII file
Note
	`*list' is alloced internally, hence MUST BE FREED by the
	caller.

	sample call:

		long 	msg ;
		int 	count ;
		char	**list ;

		vs$getWeldProcASCII(	msg	= &msg,
					name	= "weld_proc",
					count	= &count,
					list	= &list ) ;
	wrapup:
		VSfreeList ( count, list );
-M*/
extern long
VSgetWeldProcASCII		__((	long		*msg,
					char		*name,
					int		*count,
					char		***list )) ;

#omdef vs$getWeldProcASCII( 	msg, 
				name = "weld_proc", 
				count, 
				list )

	VSgetWeldProcASCII( (msg), (name), (count), (list) )
#endomdef

/*+M
Macro vs$getWeldCodes

Abstract
	Returns the list of descriptions of the available weld codes.

Arguments
	OUT	long		*msg		Completion code.
	OUT	int		*count		Count of available codes.
	OUT	long		**list		List of message keys of
						descriptions.
Note
	`*list' will point to a static buffer, hence MUST NOT BE FREED by the
	caller.
	Weld code number N ( 0 <= N < *count ) will have the message key to
	its description given by `(*list)[N]', which may be input to macro
	`ex$message'.

	Sample call :
		long	msg,
			*list ;
		int	count ;
		char	buf[MS_MAX_MSG_LENGTH] ;

		vs$getWeldCodes(	msg	= &msg,
					count	= &count,
					list	= &list ) ;

		(* Get description of weld code #0 in a character buffer *)
		ex$message(	msgnumb	= list[0],
				in_buf	= buf ) ;
-M*/
extern long
VSgetWeldCodes			__((	long		*msg,
					int		*count,
					long		**list )) ;

#omdef vs$getWeldCodes( msg, count, list )
	VSgetWeldCodes( (msg), (count), (list) )
#endomdef

/*+M
Macro vs$getWeldProcesses

Abstract
	Returns the list of descriptions of the available weld processes.

Arguments
	OUT	long		*msg		Completion code.
	OUT	int		*count		Count of available processes.
	OUT	long		**list		List of message keys of
						descriptions.
Note
	`*list' will point to a static buffer, hence MUST NOT BE FREED by the
	caller.
	Weld process number N ( 0 <= N < *count ) will have the message key to
	its description given by `(*list)[N]', which may be input to macro
	`ex$message'.
-M*/
extern long
VSgetWeldProcesses		__((	long		*msg,
					int		*count,
					long		**list )) ;

#omdef vs$getWeldProcesses( msg, count, list )
	VSgetWeldProcesses( (msg), (count), (list) )
#endomdef


/*+M
Macro vs$fillJointAttr

Abstract
	Fill some or all of the fields of a joint attribute structure.
Arguments
	OUT	long		*msg		Completion code.
	IN	int		options		Mask of attributes to be filled.
	IN	double		allowance
	IN	double		grooveAngle
	IN	double		pitch
	IN	double		incrLength
	IN	VSweldAttr	*weldAttr
	IN	VSaddWldAttr	*addWldAttr
	IN	char		*usrSymbol
	IN	double		size
	IN	double		shrinkage
	IN	struct GRid	*usrAttrId	Collection of user attributes.
	OUT	VSpartAttr	*partAttr	Part attributes.
	OUT	VSjointAttr	*jointAttr	Joint-specific attributes.
Notes
	If an attribute is specified in the options, the corresponding value
	must be input (the default values are meaningless and even dangerous).
	If an input character string attribute was too long, it is truncated and
	`*msg' is set to EMS_I_Fail.
-M*/
extern long
VSfillJointAttr			__((	long		*msg,
					int		options,
					double		allowance,
					double		grooveAngle,
					double		pitch,
					double		incrLength,
					VSweldAttr	*weldAttr,
					VSaddWldAttr	*addWldAttr,
					char		*usrSymbol,
					double		size,
					double		shrinkage,
					struct GRid	*usrAttrId,
					VSpartAttr	*partAttr,
					VSjointAttr	*jointAttr )) ;

#omdef vs$fillJointAttr(msg,
			options,
			allowance	= 0.,
			grooveAngle	= 0.,
			pitch		= 0.,
			incrLength	= 0.,
			weldAttr,
			addWldAttr	= NULL,
			usrSymbol	= "",
			size		= "2.5",	/* min value 	*/
			shrinkage	= "0.2",	/* min value	*/
			usrAttrId	= NULL,
			partAttr,
			jointAttr )

	VSfillJointAttr((msg),
			(options),
			(allowance),
			(grooveAngle),
			(pitch),
			(incrLength),
			(weldAttr),
			(addWldAttr),
			(usrSymbol),
			(size),
			(shrinkage),
			(usrAttrId),
			(partAttr),
			(jointAttr) )
#endomdef

#endif
