/*
	I/STRUCT
*/
class implementation ACrg_collect ;

#include <stdio.h>
#include <stdlib.h>
#include "OMmacros.h"
#include "igrtypedef.h"
#include "igetypedef.h"
#include "igrdp.h"
#include "godef.h"
#include "go.h"
#include "gr.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "grdpbmacros.h"
#include "ACrg_collect.h"
#include "EMSmsgdef.h"
#include "vspart.h"
#include "vsdatamacros.h"
#include "vsmiscmacros.h"
#include "vsuattmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsaddmodattr.h"
#include "vsstrngproto.h"
/*----------------------------------------------------------------------------*/
long VSgetUsrAttrContent( msg, UAid, p_size, p_names, p_syntaxes )

/*
 * This function interfaced by macro vs$makeActiveUsrAttr.
 */
long		*msg ;
struct GRid	*UAid ;
int		*p_size ;
char		***p_names,
		***p_syntaxes ; {

	long		sts ;		/* OM return code		*/
	int		size,		/* Size of collection		*/
			i ;		/* Loop-on-attributes index	*/
	struct ACrg_coll
			oneAttr ;	/* Description of one attribute	*/
	char		dblBuffer[20],	/* String buf. for double values*/
			*value,		/* Pointer to string value buf.	*/
			**names,	/* Array of names		*/
			**syntaxes ;	/* Array of syntaxes		*/

	size = 0 ; names = syntaxes = NULL ;

	sts = om$send(	msg	= message ACrg_collect.AClist_attribute(
							msg, 0, NULL, &size ),
			senderid= UAid->objid,
			targetid= UAid->objid,
			targetos= UAid->osnum ) ;
	__CheckRC( sts, *msg, "ACrg_collect.AClist_attribute", wrapup ) ;

	if( !size ) goto wrapup ;

	if( !(    ( names	= _CALLOC( size, char * ) )
	       && ( syntaxes	= _CALLOC( size, char * ) ) ) ) vs$mem_fail() ;

	for( i = 0 ; i < size ; i++ ) {
		sts = om$send(
			msg	= message ACrg_collect.ACget_attribute_at_index(
							msg, i, &oneAttr ),
			senderid= UAid->objid,
			targetid= UAid->objid,
			targetos= UAid->osnum ) ;
		__CheckRC( sts, *msg, "ACget_attribute_at_index", wrapup ) ;

		switch( oneAttr.desc.type ) {
		
		case AC_ATTRIB_DOUBLE	:
			sprintf( dblBuffer, "%g", oneAttr.desc.value.att_exp ) ;
			value = dblBuffer ;
			break ;
		case AC_ATTRIB_TEXT	:
			value = oneAttr.desc.value.att_txt ;
			break ;
		default			:
			/*
			 * Should never get here !.
			 */
			value = "Unknown type of collection member." ;
			break ;
		}
		if( !(    ( names[i]	= VSstrdup( oneAttr.name ) )
		       && ( syntaxes[i] = VSstrdup( value	 ) ) ) ) {
		       	vs$mem_fail() ;
		}
	}

	wrapup :
		if( !( sts & 1 & *msg ) ) {
			VSfreeList( size, names		) ;
			VSfreeList( size, syntaxes	) ;
			*p_size		= 0 ;
			*p_names	= *p_syntaxes = NULL ;
		} else {
			*p_size		= size ;
			*p_names	= names ;
			*p_syntaxes	= syntaxes ;
		}

		return sts ;

} /* VSgetUsrAttrContent */
/*----------------------------------------------------------------------------*/
long VSaddOrModAttr(	long			*msg,
			const struct GRid	*coll,
			const char		*name,
			int			type,
			const void		*value ) {

	long			sts ;
	int			rc ;
	struct ret_struct	rs ;
	struct ACrg_coll	attr ;

	if( strlen( name ) >= ATTR_NAME ) vs$inv_arg() ;

	switch( type ) {
	  case AC_ATTRIB_DOUBLE:
	    attr.desc.value.att_exp = *(const double *) value      ; break ;
	  case AC_ATTRIB_TEXT  :
	    if( strlen( (const char*) value ) >= ATTR_NAME ) vs$inv_arg() ;
	    strcpy( attr.desc.value.att_txt, (const char*) value ) ; break ;
	  default		: vs$inv_arg() ;
	}
	strcpy( attr.name, name ) ;
	attr.desc.type = type ;

	sts = om$send(	msg	= message NDmacro.ACgive_structure(
					&rc, (int*) NULL, (char*) name,
					&rs, (struct GRmd_env*) NULL ),
			senderid= NULL_OBJID,
			targetid= coll->objid,
			targetos= coll->osnum ) ;
	if( !( sts & 1 & rc ) ) {
	  sts = om$send(msg	= message ACrg_collect.ACadd_list_attribute(
								msg, 1, &attr ),
			senderid= NULL_OBJID,
			targetid= coll->objid,
			targetos= coll->osnum ) ;
	} else {
	  sts = om$send(msg	= message ACrg_collect.ACmod_list_attribute(
								msg, 1, &attr ),
			senderid= NULL_OBJID,
			targetid= coll->objid,
			targetos= coll->osnum ) ;
	}
	wrapup:
	   return sts ;

} /* VSaddOrModAttr */
/*----------------------------------------------------------------------------*/

end implementation ACrg_collect ;
