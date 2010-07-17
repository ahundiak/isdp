/* $Id: VSdpbColl.I,v 1.1.1.1 2001/01/04 21:10:32 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:	struct/vsdpb/VSdpbColl.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VSdpbColl.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:10:32  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.5  1998/01/06  04:35:34  pinnacle
# Replaced: vsdpb/VSdpbColl.I for:  by svkadamb for struct
#
# Revision 1.3  1997/11/14  12:30:04  pinnacle
# Replaced: vsdpb/VSdpbColl.I for:  by svkadamb for struct
#
# Revision 1.2  1997/11/14  12:26:20  pinnacle
# Replaced: vsdpb/VSdpbColl.I for:  by svkadamb for struct
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *			suresh		modification 
	01/06/98	suresh		added weld position as extra attr.
 ***************************************************************************/
/*
	I/STRUCT
*/
class implementation ACrg_collect ;

#include <stdlib.h>
#include <string.h>
#include "OMmacros.h"
#include "EMSmsgdef.h"
#include "vspart.h"
#include "vsglobals.h"
#include "vsdpbdef.h"
#include "vsmiscmacros.h"
#include "vsuattmacros.h"
#include "vsdatamacros.h"
#include "vsdbgmacros.h"

typedef struct VSdpbCollAttr {
	char		*attrName,
			*initDefaultValue ;
	unsigned long	attrType ;
} VSdpbCollAttr ;
%safe
/*
 * More attributes may be added at will *BEFORE* the end-of-list line.
 */
static VSdpbCollAttr dpbCollAttrs[] = {
	{ VS_K_dpbActJnGrvAng		, "0.0"	, double_type	},
	{ VS_K_dpbActJnPitch		, "0.0"	, double_type	},
	{ VS_K_dpbActJnIncrLn		, "0.0"	, double_type	},
	{ VS_K_dpbActJnUsrSym		, "?"	, text_type	},
	{ VS_K_dpbActJnPlcMode		, "0.0"	, double_type	},
	{ VS_K_dpbActStfnNrmlToSd	, "1.0"	, double_type	},
	{ VS_K_dpbActGapDetection	, "0.0" , double_type	},
	{ VS_K_dpbActMaxAdmGapVal	, "0.0"	, double_type	},
	{ VS_K_dpbActJnShrkRatio        , "0.2" , double_type   },
	{ VS_K_dpbActJnWeldSize		, "3.5" , double_type	},
	{ VS_K_dpbActJnWeldPos		, "0.0" , double_type	},
	/*
	 * This last line flags the end of the list: do not add anything beyond
	 * it, it would not be taken into account. And do not suppress this
	 * end-of-list line !.
	 */
	{ NULL				, NULL	, 0		}
	
} ;
%endsafe

/*----------------------------------------------------------------------------*/
long VSinitDpbColl( msg, collId )

long		*msg ;
struct GRid	*collId ; {

	long		sts ;
	int		i,
			maxAttrs ;
	char		**names	= NULL,
			**values= NULL ;
SetProc(VSinitDpbColl ) ; Begin
	for( i = maxAttrs = 0 ; ; i++ ) {
		if( dpbCollAttrs[i].attrName ) maxAttrs++ ;
		else break ;
	}

	names = _MALLOC( maxAttrs, char * ) ;
	values= _MALLOC( maxAttrs, char * ) ;
	if( !names || !values ) vs$mem_fail() ;

	for( i = 0 ; i < maxAttrs ; i++ ) {
		names[i]	= dpbCollAttrs[i].attrName ;
		values[i]	= dpbCollAttrs[i].initDefaultValue ;
	}
	sts = vs$makeActiveUsrAttr(	msg		= msg,
					basename	= VS_K_dpbCollection,
					nbEntries	= maxAttrs,
					names		= names,
					syntaxes	= values,
					p_activeUA	= collId ) ;

	wrapup :
		_FREE( names ) ; _FREE( values ) ;
		End 
	return sts ;

} /* VSinitDpbColl */
/*----------------------------------------------------------------------------*/
long VSgetDpbCollAttr( msg, attrName, attrValue )

long	*msg ;
char	*attrName,
	*attrValue ; {

	long			sts ;
	struct GRid		collId ;
	struct ret_struct	rs ;
	int			index = -1,
				ACrc ;
	SetProc( VSgetDpbCollAttr ) ; Begin 

	sts = vs$getActiveUsrAttr(	msg		= msg,
					basename	= VS_K_dpbCollection,
					p_activeUA	= &collId ) ;

	if( !( sts & 1 & *msg ) ) goto wrapup ;

	if( IF_NULL_OBJID( collId.objid ) ) {
		sts = VSinitDpbColl( msg, &collId ) ;
		__CheckRC( sts, *msg, "VSinitDpbColl", wrapup ) ;
	}

	sts = om$send(	msg	= message NDmacro.ACgive_structure(
					&ACrc, &index, attrName, &rs, NULL ),
			senderid= collId.objid,
			targetid= collId.objid,
			targetos= collId.osnum ) ;
	__DBGpr_obj(" CollectId ", collId );
	if( !( sts & 1 & ACrc ) ) {
		/*
		 * Is it a new entry invented by us programmers after
		 * collection was created ? If attribute was not here before
		 * well initialize it.
		 */
		int		i ;
		VSdpbCollAttr	*found = NULL ;
		double		*dval ;

		/*
		 * Find item in list, if present add it to collection.
		 */
		for( i = 0 ; ; i++ ) {
			if( dpbCollAttrs[i].attrName ) {
				if( !strcmp( attrName,
					     dpbCollAttrs[i].attrName ) ) {
					found = dpbCollAttrs + i ;
					break ;
				}
			} else break ;
		}
		if( !found ) vs$inv_arg() ;

		switch( rs.type	= found->attrType ) {
			case double_type:
				dval = (double *) attrValue ;
				*dval = atof( found->initDefaultValue );
				break ;

			case text_type	:
				strcpy( attrValue, found->initDefaultValue ) ;
				break ;
		}
		om$send(msg	= message ACdiowner.ACadd_attribute(
						msg,
						found->attrName,
						found->initDefaultValue ),
			senderid= collId.objid,
			targetid= collId.objid,
			targetos= collId.osnum ) ;
	} else {
		double	*dval ;

		switch( rs.type ) {
			case double_type:
				dval = (double *) attrValue ;
				*dval= rs.var.root_pm_st.value ;
				break ;

			case text_type	:
				strcpy( attrValue, rs.var.text_st.text_string );
				break ;

			default		:
				vs$inv_arg() ;
		}
	}

	*msg = MSSUCC ;
	wrapup :
		End
		return sts ;

} /* VSgetDpbCollAttr */
/*----------------------------------------------------------------------------*/
long VSputDpbCollAttr( msg, attrName, attrValue )

long	*msg ;
char	*attrName,
	*attrValue ; {

	long			sts ;
	struct GRid		collId ;
	char			syntax[50] ;

	sts = vs$getActiveUsrAttr(	msg		= msg,
					basename	= VS_K_dpbCollection,
					p_activeUA	= &collId ) ;

	if( !( sts & 1 & *msg ) ) goto wrapup ;

	if( IF_NULL_OBJID( collId.objid ) ) {
		sts = VSinitDpbColl( msg, &collId ) ;
		__CheckRC( sts, *msg, "VSinitDpbColl", wrapup ) ;
	}

	{
	  int	i ;
	  int	found = -1 ;
	  for( i = 0 ; dpbCollAttrs[i].attrName ; i++ ) {
	    if( !strcmp( attrName, dpbCollAttrs[i].attrName ) ) {
	      found = i ; break ;
	    }
	  }
	  if( found >= 0 ) {
	  	if( double_type == dpbCollAttrs[found].attrType ) {
		  sprintf( syntax, "%g", *(double *) attrValue ) ;
		  attrValue = syntax ;
	  	}
	  } else {
	    vs$inv_arg() ;
	  }
        }

	sts = om$send(	msg	= message ACdiowner.ACmod_attribute(
						msg, attrName, attrValue ),
			senderid= collId.objid,
			targetid= collId.objid,
			targetos= collId.osnum ) ;

	wrapup :
		return sts ;

} /* VSputDpbCollAttr */
/*----------------------------------------------------------------------------*/

end implementation ACrg_collect ;
