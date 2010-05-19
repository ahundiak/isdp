/* $Id: vdAPImacros.h,v 1.3 2001/02/06 15:11:27 build Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	include/vdAPImacros.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdAPImacros.h,v $
 *	Revision 1.3  2001/02/06 15:11:27  build
 *	Changed boolean to IGRboolean (Ramarao)
 *	
 *	Revision 1.2  2001/02/02 21:45:34  ramarao
 *	Fix for ETL# 4635.
 *	
 *	Revision 1.1.1.1  2001/01/04 21:07:31  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.2  1996/10/29  17:43:50  pinnacle
 * Int 2 Elem API
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.2  1996/03/21  22:56:56  pinnacle
 * Replaced: include/vdAPImacros.h for:  by yzhu for vds.240
 *
 * Revision 1.1  1996/02/20  20:33:26  pinnacle
 * Created: ./include/vdAPImacros.h by azuurhou for vds.240
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	10/29/96	ah		Intersect 2 elements api
 *			i-paris		creation date
 *
 ***************************************************************************/

#ifndef vdAPImacros_include
#define vdAPImacros_include

/* ************************************************************************** */
/*+M
Macro vd$locate_by_name

Abstract
	This macro executes a VDS locate by name and returns a array of
	located objects.
Arguments
	OUT	long		 *msg		Completion code.
	IN	char		 *prefix	Prefix string.
	IN	char		 *select	Selection expression string.
	IN	char		 *suffix	Suffix string.
	IN	char		 *attach	Attachement name for reference
						files.
	OUT	int		 *number	Number of located objects.
	OUT	struct GRobj_env **object	Array of located objects.
Notes
	* The macro returns MSSUCC if succesfull or MSFAIL if an error
          occur in argument 'msg'.

	* 'prefix' is the common prefix of searched objects.
	  For example the frame system Fx holding {F0, F1, .., F20} frames can
	  be search. In this case 'prefix' will be "F".
	  Default is "".

	* 'select' is the selection expression for searching.
	  For example the frame system Fx holding {F0, F1, .., F20} frames can
	  be search. In this case 'select' can be "[0-20,5]" and the frames
	  {F0, F5, F10, F15, F20} will be located.
	  Default is "".

	* 'suffix' is the common suffix of searched objects.
	  For example the joints with left plate equal P23 can be search.
	  In this case 'prefix' will be "P", select will be "23" and prefix
	  will be "-J". The result will be all the joints P23-###-J.
	  Default is "".

	* 'attach' is used when you have to search in a reference file. It's
	  the name given to attachement.
	  Default is "".

	* '*number' is the number of objects located or the maximum number of
	  objects wanted.
	  See example for more enlightments.

	* 'object' is the array of objects located.
	  User have allocate this array, use it, then free it.
	  If 'object' is set to NULL when you call vd$locate_by_name(), only
	  the 'number' of objects is returned. After that 'object' can be
	  allocated with the right size. At last vd$locate_by_name() can be
	  called with 'number' and 'object'.
	  Default is NULL.
	  See example for more enlightments.

	* Example :
		Locate 10 odd frames.

		long			msg;
		int			count = 10;
		struct GRmd_env		frame[10];

		sts = vd$locate_by_name( msg	= &msg,
					 prefix = "F",
					 select = "[1-99,2]",
					 number = &count,
					 object = frame );
		if( !( sts & 1 & msg ) )
			printf( "Error in locate by name\n" ) ;

	* Example :
		Locate all odd frames.

		long			msg;
		int			count;
		struct GRmd_env		*frame;
		int			size=sizeof( struct GRmd_env );

		frame = NULL;

		count = 0;
		sts = vd$locate_by_name( msg	= &msg,
					 prefix = "F",
					 select = "[1-99,2]",
					 number = &count );
		if( !( sts & 1 & msg ) )
			printf( "Error in locate by name\n" ) ;

		frame = (struct GRmd_env *) malloc( count * size );
		sts = vd$locate_by_name( msg	= &msg,
					 prefix = "F",
					 select = "[1-99,2]",
					 number = &count,
					 object = frame );
		if( !( sts & 1 & msg ) )
			printf( "Error in locate by name\n" ) ;

-M*/
extern long
VDlocate_by_name	__((	long			*msg,
				char			*prefix,
				char			*select,
				char			*suffix,
				char			*attach,
				int			*number,
				struct GRobj_env	**object )) ;

#omdef vd$locate_by_name(	msg,
				prefix		= "",
				select		= "",
				suffix		= "",
				attach		= "",
				number,
				object		= NULL )

	VDlocate_by_name( (msg),
			  (prefix),
			  (select),
			  (suffix),
			  (attach),
			  (number),
			  (object) )
#endomdef
/* ************************************************************************** */

/* ************************************************************************** */
/*+M
Macro vd$vds_query

Abstract
	This macro executes a VDS query and returns a array of located objects.
Arguments
	OUT	long		 *msg		Completion code.
	IN	char		 *types		Element types searched.
	IN	int		 where		Where clause :
							-1 :	no where clause.
							 0 :	where not
							 1 :	where
	IN	char		 *condition	Where clause.
	IN	IGRboolean	 ref_search	TRUE : Search in reference files.
						FALSE: Search only in active.
	OUT	int		 *number	Number of located objects.
	OUT	struct GRobj_env **object	Array of located objects.
Notes
	* The macro returns MSSUCC if succesfull or MSFAIL if an error
          occur in argument 'msg'.

	* 'types' is a string describing the element types searched.

	* 'where' defines what kind of where clause is used.
	  Default value is -1 (No where clause).

	* 'condition' is used if 'where' is 0 or 1.
	  It can be composed of several elementaries conditions.
	  An elementary condition is : <name> <operator> <value> where :
		<name> is an object attribute or symbology member name.
		<operator> can be !=, =, >=, <=, > or <.
		<value> is a integer, a double or a string (without quotes if in
			a single block).
	  'condition' is : (ec1) <operator> (ec2) ... <operator> (ecn) where :
		(eci) is an elementary condition between brackets.
		<operator> can be :	&	And
					&!	And not
					|	Or
					|!	Or not
					@	Xor
	  Default value is "".

	* '*number' is the number of objects located or the maximum number of
	  objects wanted.
	  See example for more enlightments.

	* 'object' is the array of objects located.
	  If 'object' is set to NULL when you call vd$vds_query(), only
	  the 'number' of objects is returned.
	  If 'object' is not set to NULL it's allocated automaticaly to
	  the right size. In that case, user must free 'object'.
	  Default is NULL.
	  See example for more enlightments.

	* Example :
		Locate all plates and stiffener in steel and not in aluminium.

		long			msg;
		int			count;
		char			type[80];
		char			clause[80];
		struct GRobj_env	*elem;

        	count = 0;
        	elem  = NULL;
	
        	strcpy ( type, "VSplate-VSstfBeam" );
        	strcpy ( clause,
			 "(material = steel) &! (material = aluminium)" );
        	sts = vd$vds_query ( msg        = &msg,
	                             types      = type,
	                             where      = 1,
	                             condition  = clause,
	                             number     = &count,
	                             object     = &elem );
	        if ( sts & 0x00000001 & msg ) {
	                for ( i=0; i<count; i=i+1 ) {
printf( "\tResult %03d : [%2d|%4d] in [%2d|%d]\n", i,
        elem[i].obj_id.osnum, elem[i].obj_id.objid,
        elem[i].mod_env.md_id.osnum, elem[i].mod_env.md_id.objid );
                	}
        	}
        	else    printf( "vd$vds_query() returns msg=%d, count=%d\n",
                        	msg, count );

        	if (elem) {
			om$dealloc (ptr = elem);
			elem = NULL;
		}

		
-M*/
extern long
VDvds_query	__((	long			*msg,
			char			*types,
			int			where,
			char			*condition,
			IGRboolean		ref_search,
			int			*number,
			struct GRobj_env	**object )) ;

#omdef vd$vds_query(	msg,
			types,
			where		= -1,
			condition	= "",
			ref_search      = TRUE,
			number,
			object		= NULL )

	VDvds_query( (msg),
		     (types),
		     (where),
		     (condition),
		     (ref_search), 
		     (number),
		     (object) )
#endomdef
/*+M
Macro vd_$return_foot

Abstract
        Encapsulate stupid NDmacro.ACreturn_foot message.

Arguments
        OUT             IGRlong         *msg            Completion code.
        IN              IGRchar         *name           Name of the foot wanted.
        IN      struct  GRid            *objId          Object of target.
        IN      struct  GRmd_env        *objEnv         Environ of target.
        OUT     struct  GRid            *footId         Object returned.
        OUT     struct  GRmd_env        *footEnv        Environ returned.

-M*/
extern IGRint 
VDreturn_foot            __((    IGRlong *msg,
                                        IGRchar *name,
                                        struct GRid *objId,
                                        struct GRmd_env *objEnv,
                                        struct GRid *footId,
                                        struct GRmd_env *footEnv));

#omdef vd_$return_foot ( msg,
                        name = "",
                        objId,
                        objEnv = NULL,
                        footId,
                        footEnv = NULL )

        VDreturn_foot ( (msg),
                        (name),
                        (objId),
                        (objEnv),
                        (footId),
                        (footEnv) )
#endomdef

/* ************************************************************************** */
/*
 * Intersection of two elements
 */

/* Trim Values */
enum TrimValuesTable {
	INF_B, 	// infinite graphic objects (line or plane)
	IMP_B,	// imposed boundaries (surface)
	NAT_B	// natural boundaries (surface or plane)
};

extern IGRlong
VDint2elem __((
		struct GRobj_env *elem1,	// I   - First element
		struct GRobj_env *elem2,	// I   - Second element
		IGRint		trim1req,	// I   - Trim code
		IGRint		trim2req,	// I   - Trim code
		IGRboolean	approx,		// I   - Approximation
		IGRint		*NumbInt,	// O   - Number of intersections
		struct GRid	**GRidInt));	// I/O - Intersections
/*+M
Macro 	vd$int2elem

Abstract
	This macro intersects two elements.

Notes

	* The macro returns 1 if successful or 0 if not

	* The trim codes are defined in the TrimValuesTable enum.

	* NumbInt is the number of generated intersection elements.

	* GRidId is a pointer to a pointer to a list of generated elements.  
	  If NULL, the list will not be returned.
	  If NOT NULL, the macro will allocate the necessary memory.
	  The user must free the memory when done.

	* See $VDS/api/int2elem/APIint2elem.u for example.

-M*/
#omdef vd$int2elem(
			elem1,
			elem2,
			trim1req = INF_B,
			trim2req = INF_B,
			approx   = FALSE,
			NumbInt,
			GRidInt)

	VDint2elem(	
			(elem1),
			(elem2),
			(trim1req),
			(trim2req),
			(approx),
			(NumbInt),
			(GRidInt));

#endomdef

#endif /* vdAPImacros_include */

