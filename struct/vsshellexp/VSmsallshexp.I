/*
	I/STRUCT
*/
class implementation VSmergeShExp ;

#include <stdio.h>
#include "EMSmsgdef.h"
#include "vsdatamacros.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

#define	VD_DEBUG
#include	<VDdebug.h>

/*
 * Includes of function prototypes.
 */

extern OMuword	OPP_VSmergeShExp_class_id ;

/*----------------------------------------------------------------------------*/
method VSget_all_original_shell_exp( long		*msg ;
				      struct GRmd_env	*myEnv ;
				      int		*count ;
				      struct GRobj_env	*list[] )
{
	long			sts ;	    /* OM completion code.	      */
	int			i ;	    /* Loop index.		      */
	struct GRobj_env	parent[2] ; /* My shell expansion parents.    */

	SetProc( VSmergeShEx_VSget_all_original_shell_exp ) ; Begin ;

        __enterMethod ( name = "VSget_all_original_shell_exp" //, argfmt = "", args = ``
        );
	__DBGpr_me() ;

	/*
	 * Find my shell expansion parents.
	 */
	sts = om$send( msg	= message VSmergeShExp.VSget_shell_exp_parents(
								     msg,
								     myEnv,
								     parent,
								     parent+1 ),
		       targetid = my_id ) ;

	__CheckRC( sts, *msg, "VSmergeShExp.VSget_shell_exp_parents", wrapup ) ;

	/*
	 * If my parent is a merge shell expansion, resend the message.
	 */
	for( i=0; i<2; i++ ) {
#ifdef vsDEBUG
		printf( "Parent #%d", i ) ;
		ShowObj( &parent[i]._grid ) ;
#endif

		if( vs$is_ancestry_valid( object  = &parent[i]._grid,
					  classid = OPP_VSmergeShExp_class_id)){
			__DBGpr_com( "\tIt's a merged" ) ;

			sts = om$send( msg	= OPPmargs,
				       targetid = parent[i]._objid,
				       targetos = parent[i]._osnum ) ;

			__CheckRC( sts, *msg, "VSget_all_original_shell_exp",
				   wrapup ) ;

			continue ;
		}

		__DBGpr_com( "\tIt's an original" ) ;

		if( list ) {
			if( *list )
				*list = _REALLOC( *list,
						  *count + 1,
						  struct GRobj_env ) ;
			else
				*list = _MALLOC( 1, struct GRobj_env ) ;

			if( !*list ) vs$mem_fail() ;

			(*list)[*count] = parent[i] ;
		}

		(*count)++ ;
	}

	sts  = OM_S_SUCCESS ;
	*msg = MSSUCC ;

	wrapup :
		if( !( sts & 1 & *msg ) ) {
			if( list ) {
				_FREE( *list ) ;
				*list = NULL ;
			}
			*count = 0 ;
		}

        __exitMethod ( name = "VSget_all_original_shell_exp", argfmt = "sts = %d, msg = %#x", args = `sts, *msg` );

		End

		return sts ;

} /* VSget_all_original_shell_exp */
/*----------------------------------------------------------------------------*/

end implementation VSmergeShExp ;
