/*
	I/STRUCT
*/
#include <stdio.h>		/* For NULL		*/
#include <stdlib.h>		/* For malloc and free	*/
#include "OMminimum.h"
#include "OMprimindex.h"
#include "OMprimitives.h"
#include "OMerrordef.h"
#include "OMmacros.h"
#include "igetypedef.h"		/* IGE typedefs GR*		*/
#include "igrtypedef.h"		/* Typedef IGR*			*/
#include "gr.h"			/* Structs GR* for graphic info	*/
#include "msdef.h"
#include "EMSutlmacros.h"
#include "vspart.h"
#include "vsdatadef.h"
#include "vsdatamacros.h"
#include "vsmiscmacros.h"
#include "vsipthmacros.h"
#include "vsdbgmacros.h"
/*
 * Includes of function prototypes.
 */
#include "vsgetchanobj.h"
/*----------------------------------------------------------------------------*/
static long VS__getCmpIndexPath( msg, owner, component, depth, p_size, ipath )

long		*msg ;
struct GRid	*owner,
		*component ;
int		depth,
		*p_size,
		ipath[] ; {

	long		sts ;
	int		i,		/* Loop-on-component index	*/
			index,		/* Of input component		*/
			count ;		/* Count of components		*/
	struct GRid	*cmpList ;

	cmpList = NULL ; count = 0 ; sts = OM_S_SUCCESS ;

	if( *p_size >= depth ) {
		/*
		 * Depth too high...
		 */
		*msg = MSFAIL ; sts = OM_W_ABORT ; goto wrapup ;
	}

	/*
	 * BEWARE that `owner' may not be an owner but just a component.
	 */
	{ OM_S_CHANSELECT toCmps ;
	  ems$make_chanselect( chan_label    = GRcmpowner_to_components,
	                       chan_selector = &toCmps ) ;
	  if( !VS_GetChanObjWithMalloc( owner, &toCmps, &count, &cmpList ) ) {
		/*
		 * Not an owner.
		 */
		*msg = MSFAIL ; sts = OM_W_ABORT ; goto wrapup ;
	  }
	}

	index = -1 ;
	for( i = 0 ; i < count ; i++ ) {
		if( IF_EQ_pGRID( component, cmpList + i ) ) {
			index = i ;
			break ;
		}
	}
	if( index != -1 ) {
		/*
		 * Component belonged to input owner.
		 */
		ipath[(*p_size)++] = index ;
		sts	= OM_S_SUCCESS ;
		*msg	= MSSUCC ;
	} else {
		int u ;
		/*
		 * Maybe component belongs to one of owner's components.
		 */
		u = (*p_size)++ ;

		for( i = 0 ; i < count ; i++ ) {
			ipath[u] = i ;
			sts = VS__getCmpIndexPath(
						msg,
						cmpList + i,
						component,
						depth,
						p_size,
						ipath ) ;
			if( sts & 1 & *msg ) {
				ipath[u] = i ;
				u = -1 ;
				break ;
			}
		}
		if( u != -1 ) (*p_size)-- ;
		*msg = MSSUCC ; sts = OM_S_SUCCESS ;
	}
	wrapup :
		if( count ) _FREE( cmpList ) ;
		return sts ;

} /* VS__getCmpIndexPath */
/*----------------------------------------------------------------------------*/
long VSgetCmpIndexPath( msg, owner, component, p_size, ipath )

/*
 * This function is interfaced by macro `vs$getCmpIndexPath'.
 */

long		*msg ;
struct GRid	*owner,
		*component ;
int		*p_size,
		ipath[] ; {

#define MAX VS_K_MAXOWNDEPTH

	long	sts ;
	int	depth ;	/* In ownership graph		*/

	depth = MAX ; *p_size = 0 ;
	sts = VS__getCmpIndexPath( msg, owner, component, depth, p_size, ipath ) ;

	return sts ;

} /* VSgetCmpIndexPath */
/*----------------------------------------------------------------------------*/
long VSgetCmpIdFromIpath( msg, owner, size, ipath, component ) 

/*
 * This function is interfaced by macro `vs$getCmpIdFromIpath'.
 */

long		*msg ;
struct GRid	*owner,
		*component ;
int		size,
		ipath[] ; {

	long		sts ;
	int		i ;
	struct GRid	current,
			cmp ;
	OM_S_CHANSELECT toCmps ;

	component->objid	= NULL_OBJID ;
	current			= *owner ;
	sts			= OM_S_SUCCESS ;

	ems$make_chanselect( chan_label    = GRcmpowner_to_components,
	                     chan_selector = &toCmps ) ;
	for( i = 0 ; i < size ; i++ ) {

		sts = om$get_objid_at_index(	p_chanselect	= &toCmps,
						osnum		= current.osnum,
						objid		= current.objid,
						index		= ipath[i],
						objidaddr	= &cmp.objid,
						osnumaddr	= &cmp.osnum ) ;
		if( sts != OM_S_SUCCESS ) {
			*msg = MSFAIL ; sts = OM_W_ABORT ; goto wrapup ;
		}
		current = cmp ;
	}
	*msg = MSSUCC ;
	*component = cmp ;

	wrapup :
		return sts ;

} /* VSgetCmpIdFromIpath */
/*----------------------------------------------------------------------------*/
static long VS__getSubCmpCount( msg, owner, count )

long		*msg ;
struct GRid	*owner ;
int		*count ; {

	long		sts ;
	int		i,
			cnt ;
	struct GRid	*cmpList = NULL ;

	*msg = MSSUCC ; sts = OM_S_SUCCESS ;
	/*
	 * BEWARE that owner may not be an owner but just a component.
	 */
	{ OM_S_CHANSELECT toCmps ;
	  ems$make_chanselect( chan_label    = GRcmpowner_to_components,
	                       chan_selector = &toCmps ) ;
	  if( !VS_GetChanObjWithMalloc( owner, &toCmps, &cnt, &cmpList ) ) {
		goto wrapup ;
	  }
	}

	*count += cnt ;

	for( i = 0 ; i < cnt ; i++ ) {
		sts = VS__getSubCmpCount( msg, cmpList + i, count ) ;
		if( !( sts & 1 & *msg ) ) break ;
	}
	wrapup :
		if( cnt ) _FREE( cmpList ) ;
		return sts ;

} /* VS__getSubCmpCount */
/*----------------------------------------------------------------------------*/
long VSgetSubCmpCount( msg, owner, count )

/*
 * This function is interfaced by macro `vs$getSubCmpCount'.
 */

long		*msg ;
struct GRid	*owner ;
int		*count ; {

	*count = 0 ;
	return VS__getSubCmpCount( msg, owner, count ) ;

} /* VSgetSubCmpCount */
/*----------------------------------------------------------------------------*/
static long VS__getSubComponents( msg, owner, list, count )

long		*msg ;
struct GRid	*owner,
		list[] ;
int		*count ; {

	long		sts ;
	int		i,
			cnt,
			cnt2 = 0 ;
	struct GRid	*cmpList = NULL,
			*l = list ;

	sts = OM_S_SUCCESS ; *msg = MSSUCC ;

	/*
	 * BEWARE that owner may not be an owner but just a component.
	 */
	{ OM_S_CHANSELECT toCmps ;
	  ems$make_chanselect( chan_label    = GRcmpowner_to_components,
	                       chan_selector = &toCmps ) ;
	  if( !VS_GetChanObjWithMalloc( owner, &toCmps, &cnt, &cmpList ) ) {
		*count = 0 ; goto wrapup ;
	  }	
	}

	for( i = 0 ; i < cnt ; i++ ) {
		*l++ = cmpList[i] ;
		sts = VS__getSubComponents( msg, cmpList + i, l, &cnt2 ) ;
		if( !( sts & 1 & *msg ) ) goto wrapup ;
		l += cnt2 ;
		*count += 1 + cnt2 ;
	}

	wrapup :
		if( cnt ) _FREE( cmpList ) ;
		return sts ;

} /* VS__getSubComponents */
/*----------------------------------------------------------------------------*/
long VSgetSubComponents( msg, owner, list )

/*
 * This function is interfaced by macro `vs$getSubComponents'.
 */

long		*msg ;
struct GRid	*owner,
		list[] ; {

	int	count = 0 ;

	return VS__getSubComponents( msg, owner, list, &count ) ;

} /* VSgetSubComponents */
/*----------------------------------------------------------------------------*/
long VSgetIPATHsandIDs( msg, owner, ownerIndex, count, p_list )

/*
 * This function is interfaced by macro `vs$getIPATHsandIDs'.
 */

long		*msg ;
struct GRid	*owner ;
int		ownerIndex,
		*count ;
VSipathANDid	**p_list ; {

	long		sts ;
	struct GRid	*list = NULL ;
	int		i,
			size ;
	VSipathANDid	*l ;

	*p_list = NULL ;

	sts = vs$getSubCmpCount(	msg	= msg,
					owner	= owner,
					count	= count ) ;
	__CheckRC( sts, *msg, "vs$getSubCmpCount", wrapup ) ;

	/*
	 * Add 1 to include owner in list (with ownerIndex) if requested.
	 */
	if( ownerIndex != VS_K_NULL_INDEX ) {
		(*count)++ ;
	}
	if( !(    ( *p_list = _MALLOC( *count, VSipathANDid ) )
	       && ( list    = _MALLOC( *count, struct GRid  ) ) ) )
	       		vs$mem_fail() ;

	sts = vs$getSubComponents(	msg	= msg,
					owner	= owner,
					list	= list ) ;
	__CheckRC( sts, *msg, "vs$getSubComponents", wrapup ) ;

	l = *p_list ;
	if( ownerIndex != VS_K_NULL_INDEX ) {
		int	max ;

		l[0].id 	= *owner ;
		l[0].ip.sz 	= 1 ;
		l[0].ip.ls[0]	= ownerIndex ;

		max = *count - 1 ;
		for( i = 0 ; i < max ; i++ ) {
			l[i+1].id = list[i] ;
			sts = vs$getCmpIndexPath(
					msg		= msg,
					owner		= owner,
					component	= list + i,
					p_size		= &size,
					ipath		= l[i+1].ip.ls + 1 ) ;
			__CheckRC( sts, *msg, "vs$getCmpIndexPath", wrapup ) ;
			l[i+1].ip.ls[0]	= ownerIndex ;
			l[i+1].ip.sz	= size + 1 ;
		}
	} else {
		for( i = 0 ; i < *count ; i++ ) {
			l[i].id = list[i] ;
			sts = vs$getCmpIndexPath(
						msg		= msg,
						owner		= owner,
						component	= list + i,
						p_size		= &size,
						ipath		= l[i].ip.ls ) ;
			__CheckRC( sts, *msg, "vs$getCmpIndexPath" , wrapup ) ;
			l[i].ip.sz = size ;
		}
	}

	wrapup :
		if( !( sts & 1 & *msg ) ) {
			_FREE( *p_list ) ; *p_list = NULL ; *count = 0 ;
		}
		_FREE( list ) ;

		return sts ;

} /* VSgetIPATHsandIDs */
/*----------------------------------------------------------------------------*/
int VSeqIPATHs( ip1, ip2 ) VSixPath *ip1, *ip2 ; {

	int eq ;

	if( ip1->sz == ip2->sz ) {
		int i ;
		eq = TRUE ;
		for( i = 0 ; i < ip1->sz ; i++ ) {
			if( ip1->ls[i] != ip2->ls[i] ) { eq = FALSE ; break ; }
		}		
	} else {
		eq = FALSE ;
	}
	return eq ;

} /* VSeqIPATHs */
/*----------------------------------------------------------------------------*/
int VSfindIPATH( ip, count, list )

VSixPath	*ip ;
int		count ;
VSipathANDid	list[] ; {

	int	i,
		found = VS_K_NULL_INDEX ;

	for( i = 0 ; i < count ; i++ ) {
		if( VSeqIPATHs( ip, &list[i].ip ) ) {
			found = i ;
			break ;
		}
	}
	return found ;

} /* VSfindIPATH */
/*----------------------------------------------------------------------------*/
