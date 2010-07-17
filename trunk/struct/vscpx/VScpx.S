/*
	I/STRUCT
*/

class specification VScpx(0:0) of VDSroot ;

#ifndef igetypedef_include
#	include "igetypedef.h"		/* IGE typedefs GR*		*/
#endif
#ifndef igrtypedef_include
#	include "igrtypedef.h"		/* Typedef IGR* 		*/
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
#	include "igr.h" 		/* Structs IGR* for geometries	*/
#endif
#ifndef igrdp_include
#	include "igrdp.h"		/* Structs IGR* for display	*/
#endif
#ifndef gr_include
#	include "gr.h"			/* Structs GR* for graphic info */
#endif
#ifndef godef_include
#	include "godef.h"		/* Definitions for graphics	*/
#endif
#ifndef go_include
#	include "go.h"			/* Struct GR* for graphics	*/
#endif
#ifndef griodef_include
#	include "griodef.h"		/* Constants for graphic I/O	*/
#endif
#ifndef grio_include
#	include "grio.h"		/* Structs for graphic I/O	*/
#endif
#ifndef growner_include
#	include "growner.h"		/* For `struct GRobj_env'	*/
#endif
#ifndef dpdef_include
#	include "dpdef.h"		/* Constants for display	*/
#endif
#ifndef dp_include
#	include "dp.h"			/* Enums, structs for display	*/
#endif
#ifndef acrepdef_include
#	include "acrepdef.h"
#endif
#ifndef vs_include
#	include "vs.h"
#endif

/*+c
	Abstract class for Structural Associative Complexes.
-c*/

/*
 * Value given to the compute-type flag of ACncpx.ACconstruct_feet when
 * used at placement time.
 */
#define VS_K_InitialPlacement	0x8000

override
/*+o
Message ACattach

Abstract
	Creates macro definition if not yet done, then attaches complex to it.
	Uses message VScpx.VScreate_def sent to self to create definition.
Arguments
	OUT	int	*succ		TRUE : success, FALSE : error.
	IN	char	*macDefName	Name to give to macro definition.

-o*/
		ACattach,

/*+o
Message VDdescribeOutput

Abstract
        Sent by a pretend to this object, used to pretty-print an output in
        the "Directory Command" form.
Arguments
        OUT     long            *msg            Completion code.
        IN      char            *nameOfOutput   Name of output to describe.
        OUT     char            *description    Description of output.
-o*/
		VDdescribeOutput,

/*+o
Message DIgive_output

Abstract
	Allows the type of the object to be output next to its name (if object
	is named) in the "Directory Command" form.
Arguments
	See message DIgive_output of class ACncpx.
-o*/
		DIgive_output ;

/*+d
Message VSpre_construct

Abstract
	Connects to parents, defines macro definition corresponding to this
	object.
	To be sent in GRconstruct before the actual formatting of the object
	takes place.
Arguments
	IN	struct GRvg_construct
				*L		Construction list as for
						`GRvg.GRconstruct'
	OUT	struct GRid	newRoots[]	If parents are dumb graphics,
						these parents will be those
						resulting from the make-source
						operations and must be used in
						associative operations.
Note
	`newRoots' must be dimensioned to the number of input parents.
-d*/
message VSpre_construct( struct GRvg_construct	*L ;
			 struct GRid		newRoots[] ) ;

/*+d
Message VSget_graphic_input

Abstract
	Returns the graphic objects associated to the templates of the
	complex.
Arguments
	OUT	long			*msg		Completion code.
	IN	int			count		Count of templates.
	IN	struct GRid		roots[] 	List of templates.
	OUT	struct GRobj_env	graphics[]	List of graphic objects
							along with their module
							environments.
Note
	If `roots' is NULL, then the complex will retrieve its templates
	by itself.
-d*/
message VSget_graphic_input(	long			*msg ;
				int			count ;
				struct GRid		roots[] ;
				struct GRobj_env	graphics[] ) ;

/*+d
Message VSgetObjDef

Abstract
	Returns the definition of an object: name of templates and feet, etc.
Arguments
	OUT	long		*msg		Completion code.
	IN	VSobjDef	*objDef 	Object definition.
Note
	The fields of `objDef' point to static buffers and therefore should
	not be freed.
-d*/
message VSgetObjDef(	long		*msg ;
			VSobjDef	*objDef ; ) ;
reject VSgetObjDef ;

/*+d
Message VSevaluate

Abstract
	Generic method to be used by place:

		- gets count of feet
		- does a construct-feet operation
		- does a change-feet
Arguments
	OUT	long		*msg		Completion code.
	IN	int		count		Count of templates.
	IN	struct GRmd_env *env		Complex's module environment.
	IN	struct GRid	list[]		List of parents.
	IN	short		level		Level of feet.
	IN	struct IGRdisplay
				*display	Display of feet.
-d*/
message VSevaluate(	long			*msg ;
			int			count ;
			struct GRid		list[] ;
			struct GRmd_env 	*env ;
			short			level ;
			struct IGRdisplay	*display ) ;

/*+d
Message VScreate_def

Abstract
	Creates macro definition for object if not yet done.
Arguments
	OUT	long		*msg		Completion code.
	IN	char		*macDefName	Name for macro definition.
	IN	OMuword 	osnum		Object space for macro def.
	OUT	OM_S_OBJID	*p_objid	Object id for macro def.
Note
	This method generally does not need to be overridden.
-d*/
message VScreate_def(	long		*msg ;
			char		*macDefName ;
			OMuword 	osnum ;
			OM_S_OBJID	*p_objid ) ;

/*+d
Message VSwhoIsDying

Abstract
	Queries object for which of its parents is dying, ie. is in the delete
	queue of the Associative Sub-system (this message is useful when the
	objects receives a move-to-root triggered by the deletion of one of
	its parents, and it wants to have a different behavior based on which
	parent is being deleted )
Arguments
	OUT	long		*msg		Completion code.
	OUT	int		*index		Index of parent being deleted.
	OUT	struct GRid	*parent 	Id of parent.
-d*/
message VSwhoIsDying(	long		*msg ;
			int		*index ;
			struct GRid	*parent ) ;

/*+d
Message VSalways_TRUE

Abstract
	Message which is a pass-up condition for message ACbubble_up of class
	ACncpx so that complex receives bubbling-up message no matter what and
	passing up stops here.
Arguments
	None.
Note
	Returns OM_I_STOP_SENDING.
-d*/
message VSalways_TRUE() ;

/*+d
Message VSdescribeOutput

Abstract
	Sent by a pretend to this object, used to pretty-print an output in
	the "Directory Command" form.
Arguments
	OUT	long		*msg		Completion code.
	IN	char		*nameOfOutput	Name of output to describe.
	OUT	char		*description	Description of output.
-d*/

message VSdescribeOutput( long *msg ; char *nameOfOuput; char *description ) ;

end specification VScpx ;
