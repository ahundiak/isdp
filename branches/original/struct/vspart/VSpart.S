/*
	I/STRUCT
*/
class specification VSpart(0:0) of Root ;

#ifndef igetypedef_include
#	include "igetypedef.h"		/* IGE typedefs GR*		*/
#endif
#ifndef igrtypedef_include
#	include "igrtypedef.h"		/* Typedef IGR*			*/
#endif
#ifndef exdef_include
#	include "exdef.h"		/* Constants for exec (IGE)	*/
#endif
#ifndef ex_include
#	include "ex.h"			/* Structs EX*			*/
#endif
#ifndef igrdef_include
#	include "igrdef.h"		/* Constants IGR*		*/
#endif
#ifndef igr_include
#	include "igr.h"			/* Structs IGR* for geometries	*/
#endif
#ifndef igrdp_include
#	include "igrdp.h"		/* Structs IGR* for display	*/
#endif
#ifndef gr_include
#	include "gr.h"			/* Structs GR* for graphic info	*/
#endif
#ifndef godef_include
#	include "godef.h"		/* Definitions for graphics	*/
#endif
#ifndef go_include
#	include "go.h"			/* Struct GR* for graphics	*/
#endif
#ifndef growner_include
#	include "growner.h"		/* For `struct GRobj_env'	*/
#endif
#ifndef dp_include
#	include "dp.h"			/* Enums, structs for display	*/
#endif
#ifndef vsdef_include
#	include "vsdef.h"
#endif
#ifndef vs_include
#	include "vs.h"
#endif
#ifndef vsattr_include
#	include "vsattr.h"
#endif
#ifndef vsoptdef_include
#	include "vsoptdef.h"
#endif
#ifndef vspart_include
#	include "vspart.h"
#endif
#ifndef vsglobals_include
#	include "vsglobals.h"
#endif
#ifndef vsdpb_include
#	include "vsdpb.h"
#endif

/*+c
	Abstract class defining the protocole of access to the internals of
	the different representation of structural parts.
-c*/

/*+d
Message VSget_sub_cmp_id

Abstract
	Returns the id of a (sub-) component of a part's component from a
	(path-)name.
	A sub-component is for instance the face of a solid owned by the part.
Arguments
	OUT	long		*msg		Completion code.
	IN	char		*name		(Path-)name of (sub-)component.
	OUT	struct GRid	*sub_cmp	Id of (sub-)component.
-d*/
message VSget_sub_cmp_id(	long		*msg ;
				char		*name ;
				struct GRid	*sub_cmp ) ;

/*+d
Message VSget_sub_cmp_nm

Abstract
	Returns the name of a (sub-) component of a part's component from an id.
Arguments
	OUT	long		*msg		Completion code.
	IN	struct GRid	*sub_cmp	Id of (sub-)component.
	OUT	GRname		name		Name of sub-component.
-d*/
message VSget_sub_cmp_nm(	long		*msg ;
				struct GRid	*sub_cmp ;
				GRname		name ) ;

/*+d
Message VSget_sub_cmp_ix

Abstract
	Given the real index path of a (sub-) component of a part, returned its
	virtual index path and vice-versa according to the flag.
	This message is for consumed parts, i.e. when a part gets consumed,
	some of its (sub-) components may disappear, therefore the remaining
	(sub-) components get re-indexed. This message maps the index of a
	(sub-) component after consuming onto that of this component before
	consuming and vice-versa.
	For non-consumed parts the real and virtual index paths are equal; this
	message is implemented at this level to have this latter behavior.
Arguments
	OUT	long		*msg	Completion code.
	IN	VScmpixtype	flag	Type of conversion.
	I/O	VSixPath	*rpath	Current index path of (sub-)component.
	I/O	VSixPath	*vpath	Index path of (sub-)component before
					consume operation.
Note
	- I/O variables work as follows
		flag			rpath	vpath
		VS_e_real_to_virtual	IN	OUT
		VS_e_virtual_to_real	OUT	IN

	- Type `VScmpixtype' defined in vspart.h
	- This message used by `VSget_sub_cmp_nm' and `VSget_sub_cmp_ix'.
-d*/

message VSget_sub_cmp_ix(	long		*msg ;
				VScmpixtype	flag ;
				VSixPath	*rpath,
						*vpath ) ;

/*+d
Message VStransNameToIPATH

Abstract
	Translates a (sub-)component's (path-)name to its index path.
Arguments
	OUT	long		*msg		Completion code.
	IN	char		*name		(Path-)name of (sub-)component.
	OUT	VSixPath	*ipath		Index path of (sub-)component.
Note
	At this level, this methods expects `name' to be
			"$<n1>:$<n2>:$<n3>:...",
	 where `<nX>' is an integer and returns
		 	`ipath = { n1, n2, n3, ... }'.
-d*/
message VStransNameToIPATH(	long		*msg ;
				char		*name ;
				VSixPath	*ipath ) ;

/*+d
Message VStransIPATHToName

Abstract
	Translates a (sub-)component's index path index to its (path-)name.
Arguments
	OUT	long		*msg		Completion code.
	IN	VSixPath	*ipath		Index of (sub-)component.
	OUT	GRname		name		(Path-)name of (sub-)component.
Note
	At this level, this methods expects 
			`ipath = { n1, n2, n3, ... }',
	where `<nX>' is an integer and returns
			`name = "$<n1>:$<n2>:$<n3>:..."'.
-d*/
message VStransIPATHToName(	long		*msg ;
				VSixPath	*ipath ;
				GRname		name ) ;

/*+d
Message VSifSourceThenSend

Abstract
	Queries if part is a source part.A source part is a root for a hierarchy
	of consumed parts of the same kind. Only the last part of
	the hirarchy  being reachable by the user.
	This message is used when going up the hierachy and to query each
	node of that hierarchy to know whether or not to send a message to that
	node, for instance to get attributes, since most of the time only the
	part on top of everybody needs to keep some data.
Arguments
	IN	int		OMmsgType	Type of message to be sent.
						( #defined in vsdef.h )
Returns
	OM_S_SUCCESS		Send me action message and pass up to my parent
	OM_I_STOP_SENDING	Send me action message, don't pass up
	OM_W_ABORT		Don't send me action message but pass up
	OM_E_ABORT		Don't send me action, don't pass up
	OM_E_ERROR		Failure. Stop everything.
Note
	Implemented at this level as "Yes, I'm a root part", i.e. returns
	OM_S_STOP_SENDING.
-d*/

message VSifSourceThenSend(	int	OMmsgType ) ;

/*+d
Message VSisNameHolder

Abstract
	Queries if part holds a name, that is there exists a name in the
	directory subsytem associated with this object. Parts may have names
	without holding a name, i.e. when asked for their name, they return
	somebody else's. If asked to change their name, they change that
	somebody else's name. May return "YES" even if nameless but potential
	name holder.
Arguments
	IN	int	OMmsgType	Type of the bubbling-up action message
Note
	Implemented at this level as "Yes, I'm a name holder".
Returns
	OM_S_SUCCESS		Send me action message and pass up to my parent
	OM_I_STOP_SENDING	Send me action message, don't pass up
	OM_W_ABORT		Don't send me action message but pass up
	OM_E_ABORT		Don't send me action, don't pass up
	OM_E_ERROR		Failure. Stop everything.
-d*/
message VSisNameHolder(	int OMmsgType ) ;

/*+d
Message VSgetSupports

Abstract
	Finds the support(s) of a part, i.e. the graphics and expressions, if
	any, with the help of which is was constructed.
Arguments
	OUT	long			*msg		Completion code.
	IN	struct GRmd_env		*myEnv		Mod. env. of target.
	OUT	int			*count		Count of supports.
	OUT	VSsuppList		mySupports	Supports of part.
-d*/
message	VSgetSupports(	long		*msg ;
			struct GRmd_env	*myEnv ;	
			int		*count ;
			VSsuppList	mySupports ) ;
reject VSgetSupports ;

/*+d
Message VSsetOrientation

Abstract
	Tells part to create means to orient it. This message is used to enable
	one to place parts relatively to one another in macro-constructions.
Arguments
	OUT	long		*msg		Completion code.
	IN	GRmd_env	*myEnv		Part's module environment.
	IN	int		orientation	One among :
						- VS_K_NoOrient
						- VS_K_NatOrient
						- VS_K_RevOrient
Note
	Implemented at this level as a no-op for orientation-less part.
	VS_K_NoOrient removes the orientation.
	By convention, if "myEnv" is NULL, the orientation flag in the instance
	data will be set but no computation induced by the orientation will be
	done. Sub-classes should respect this convention.
-d*/
message VSsetOrientation(	long		*msg ;
				struct GRmd_env	*myEnv ;
				int		orientation ) ;

/*+d
Message VSgetOrientation

Abstract
	Queries part for its orientation.
Arguments
	OUT	long		*msg		Completion code.
	IN	int		*orientation	One among :
						- VS_K_NoOrient
						- VS_K_NatOrient
						- VS_K_RevOrient
-d*/
message VSgetOrientation(	long	*msg ;
				int	*orientation ) ;

/*+d
Message VShasOrientation

Abstract
	Queries part whether it stores an orientation information (if it does
	not then somebody in the consumed hierarchy does).
Arguments
	IN	int		OMmsgType	Type of message to be sent.	
						( #defined in vsdef.h )
Returns
	OM_S_SUCCESS		Send me action message and pass up to my parent.
	OM_I_STOP_SENDING	Send me action message, don't pass up.
	OM_W_ABORT		Don't send me action message but pass up.
	OM_E_ABORT		Don't send me action, don't pass up.
	OM_E_ERROR		Failure. Stop everything.
Note
	Implemented at this level as "No, I don't store an orientation", i.e.
	returns OM_W_ABORT.
-d*/
message VShasOrientation( int OMmsgType ) ;

/*+d
Message VSshowOrientation

Abstract
	Asks part to display its orientation.
Arguments
	OUT	long			*msg		Completion code.
	IN	struct GRmd_env		*myEnv		Module env. of target.
	IN	int			wantReverse	TRUE if reversed
							orientation wanted else
							FALSE.
	IN	enum GRdpmode		pen		Display mode.
	IN	struct IGRdisplay	*symbology	How orientation must
							be displayed.
-d*/
message VSshowOrientation(	long			*msg ;
				struct GRmd_env		*myEnv ;
				int			wantReverse ;
				enum GRdpmode		pen ;
				struct IGRdisplay	*symbology ; ) ;

/*+d
Message VSgetUserEditableAttr

Abstract
	Returns the list of user-modifiable attributes (some attributes may
	be constrained by parentage).
Arguments
	OUT	long		*msg	Completion code.
	OUT	unsigned long	*type	Type of part.
	OUT	unsigned long	*attr	Mask of modifiable gadgets.
-d*/
message VSgetUserEditableAttr(	long			*msg ;
				unsigned long		*type ;
				unsigned long		*attr ; ) ;
reject VSgetUserEditableAttr ;

/*+d
Message VSgetMassProperties

Abstract
	Computes the mass properties of the part if the computation of those
	mass properties is enabled.
Arguments
	OUT	long		*msg	Completion code.
	IN	struct GRmd_env	*myEnv	Module environment of target.
	OUT	VSintegral	*mp	Mass properties.
Note
	If mass properties computation is not enabled, `*msg' will be
	`EMS_I_Fail'.
-d*/
message VSgetMassProperties(	long		*msg ;
				struct GRmd_env	*myEnv ;
				VSintegral	*mp ) ;

reject VSgetMassProperties ;

end specification VSpart ;
