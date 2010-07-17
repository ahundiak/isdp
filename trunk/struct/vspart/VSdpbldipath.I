/*
	I/STRUCT
*/
class implementation VSdprPart ;

#include <stdlib.h>
#include <stdio.h>
#include "OMmacros.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include "vsdatadef.h"
#include "vsmiscmacros.h"
#include "vsdatamacros.h"
#include "vsipthmacros.h"
#include "vsdbgmacros.h"

extern int	VSfindIPATH() ;
/*----------------------------------------------------------------------------*/
method VSbuildIPATHs(	long		*msg ;
			int		solidIndex,
					bfCount ;
			VSipathANDid	*bfList ;
			struct GRid	*parentId,
					*solidAfter ) {

	long		sts ;	/* OM return code			*/
	int		count,	/* Of (sub-)components before operation	*/
			ovsz,	/* Size of virtual IPATH of operand	*/
			orsz,	/* Size of real IPATH of operand	*/
			maxSize,/* Of both VLAs				*/
			i,	/* Loop-on-components index		*/
			j ;	/* Loop-on-indices index		*/
	struct GRid	*list ;	/* Of (sub-)components before operation	*/
	char		*orpaths,/* Array of real IPATHs of operand	*/
			*ovpaths;/* Array of virtual IPATHs of operand	*/
	VSixPath	rpath,	/* Real index path of one component	*/
			vpath ;	/* Virtual index path of one component	*/

	count = bfCount ;
	list = NULL ; orpaths = ovpaths = NULL ;

	sts = om$send(	msg	= message VSdprPart.VSgetMatchingIPATHs(
								msg,
								&orsz,
								&orpaths,
								&ovsz,
								&ovpaths ),
			targetid= parentId->objid,
			targetos= parentId->osnum ) ;

	if( sts == OM_W_UNKNOWN_MSG ) {
		int	rsz,		/* Size of me->realIPATHs	*/
			vsz,		/* Size of me->virtIPATHs	*/
			vsize ;
		char	*vip,		/* Points to me->virtIPATHs	*/
			*rip ;		/* Points to me->virtIPATHs	*/
			
		/*
		 * Parent part was not a dpr part, use before-list to get
		 * sub-components.
		 */

		if( !( list = _MALLOC( count, struct GRid ) ) ) vs$mem_fail() ;

		maxSize = count * VS_K_MAXOWNDEPTH ;
		if( !(	  om$vla_set_dimension(	varray	= me->realIPATHs,
						size	= maxSize )
			& 1
			& om$vla_set_dimension(	varray	= me->virtIPATHs,
						size	= maxSize ) ) ) {
			vs$mem_fail() ;
		}

		vsz = rsz = 0 ; rip = me->realIPATHs ; vip = me->virtIPATHs ;

		for( i = 0 ; i < count ; i++ ) {
			int delta ;

			if( om$is_objid_valid(
				osnum = bfList[i].id.osnum,
				objid = bfList[i].id.objid )
			    & 1
			    & vs$getCmpIndexPath(
						msg		= msg,
						owner		= solidAfter,
						component	= &bfList[i].id,
						p_size		= &rpath.sz,
						ipath		= rpath.ls ) ) {
				delta = 2 ;
			} else {
				/*
				 * Component suppressed or moved out of
				 * ownership graph.
				 */

				delta = 1 ;
				rpath.sz = 1 ; rpath.ls[0] = VS_K_CMP_LOST ;
			}

			/*
			 * Trap a possible overflow ( if there is one, then
			 * the EMS implementation of solids & surfaces have
			 * changed! ).
			 */
			vsize = bfList[i].ip.sz ;
			if(    vsz + vsize    + 2     >= maxSize
			    || rsz + rpath.sz + delta >= maxSize ) {
				sts = OM_W_ABORT ; *msg = MSFAIL ;
				goto wrapup ;
			}
			/*
			 * Add index of solid in part as 1st index in path but
			 * not when copying from bfList where this index is
			 * already included.
			 */
			if( delta == 2 ) rip[rsz++] = solidIndex ;

			for( j = 0 ; j < vsize ; j++ ) {
				vip[vsz++] = bfList[i].ip.ls[j] ;
			}
			for( j = 0 ; j < rpath.sz ; j++ ) {
				rip[rsz++] = rpath.ls[j] ;
			}
			/*
			 * End this sequence.
			 */
			vip[vsz++] = rip[rsz++] = VS_K_NULL_INDEX ;
		}
		/*
		 * Now shrink VLAs.
		 */		
		if( !(	  om$vla_set_dimension(	varray	= me->realIPATHs,
						size	= rsz )
			& 1
			& om$vla_set_dimension(	varray	= me->virtIPATHs,
						size	= vsz ) ) ) {
			vs$mem_fail() ;
		}
	} else if( !( sts & 1 & *msg ) ) {
		goto wrapup ;
	} else {
		/*
		 * Operand part was a dpr part itself, its real IPATHs are those
		 * of the solid before the operation; we are going to compose
		 * maps :
		 *
		 *	OPERAND		real 1 -> virtual 1
		 *	ME		real 2 -> virtual 2
		 * Such as I have the map
		 *			real 2 -> virtual 1
		 * For this, take an IPATH ORI of a component of solid before op
		 * (a real path for operand), find id of component in this
		 * solid, then find real path RI (for me) of component
		 * in `solidAfter'. Associate OVI (virtual path for parent),
		 * with RI.
		 */
		char	*rip ;	/* Pointer to my real IPATHs		*/
		int	rsz,	/* Actual size of my real IPATHs	*/
			delta ;
		struct GRid
			cmp ;	/* Id of one component			*/


		/*
		 * Count number of IPATHs in operand's matching arrays (we can
		 * either use the real one or the virtual one because we have
		 * a bijection).
		 */
		for( count = i = 0 ; i < orsz ; i++ ) {
			if( orpaths[i] == VS_K_NULL_INDEX ) count++ ;
		}
		maxSize = count * VS_K_MAXOWNDEPTH ;

		if( !( om$vla_set_dimension(	varray	= me->realIPATHs,
						size	= maxSize ) & 1 ) ) {
			vs$mem_fail() ;
		}
		/*
		 * Loop on parent's real paths -> it is those of the solid
		 * before op for me, get corresponding real paths, in
		 * `solidAfter', for myself and fill array of IPATHs.
		 */
		rip = me->realIPATHs ;
		rsz = 0 ;

		/*
		 * Loop on parent's real IPATHs.
		 */
		for( i = 0 ; i < orsz ; ) {
			
			vpath.sz = 0 ;
			while( orpaths[i] != VS_K_NULL_INDEX ) {
				vpath.ls[vpath.sz++] = orpaths[i++] ;
			}
			/*
			 * Skip VS_K_NULL_INDEX.
			 */
			orpaths[i++] ;

			if( vpath.ls[0] == VS_K_CMP_LOST ) {
				/*
				 * Lost before (not in before list)
				 * -> lost after.
				 */
				rpath.sz = 1 ;
				rpath.ls[0] = VS_K_CMP_LOST ;
				delta = 1 ;
			} else {

				/*
				 * Look for vpath in bfList (it is necessarily
				 * in there!).
				 */
				cmp.objid = NULL_OBJID ;
				j = VSfindIPATH( &vpath, bfCount, bfList ) ;
				if( j != VS_K_NULL_INDEX ) {
					cmp = bfList[j].id ;
				}

				/*
				 * If this fails then an index path valid for
				 * parent is no longer valid for us: this means
				 * that the corresponding sub-component has been
				 * suppressed when the solid was re-organized.
				 */
				if(   om$is_objid_valid(
						objid = cmp.objid,
						osnum = cmp.osnum )
				    & 1
				    & vs$getCmpIndexPath(
						msg		= msg,
						owner		= solidAfter,
						component	= &cmp,
						p_size		= &rpath.sz,
						ipath		= rpath.ls ) ) {
					
					delta = 2 ;
				} else {
					/*
					 * Component suppressed or moved out of
					 * ownership graph.
					 */
					delta = 1 ;
					rpath.sz = 1 ; rpath.ls[0] = VS_K_CMP_LOST ;
				}
			}
			/*
			 * Check for overflow.
			 * Copy paths to array of IPATHs.
			 * Add index of solid in part as 1st index in path.
			 */
			if( rsz + rpath.sz + delta >= maxSize ) {
				sts = OM_W_ABORT ; *msg = MSFAIL ;
				goto wrapup ;
			}
			if( delta == 2 ) rip[rsz++] = solidIndex ;
			for( j = 0 ; j < rpath.sz ; j++ ) {
				rip[rsz++] = rpath.ls[j] ;
			}
			rip[rsz++] = VS_K_NULL_INDEX ;
		}
		/*
		 * Shrink VLA.
		 */
		if( !( om$vla_set_dimension(	varray	= me->realIPATHs,
						size	= rsz ) & 1 ) ) {
			vs$mem_fail() ;
		}
		/*
		 * Then my virtual array is parent's virtual array.
		 */
		if( !( om$vla_set_dimension(	varray	= me->virtIPATHs,
						size	= ovsz ) & 1 ) ) {
			vs$mem_fail() ;
		}
		OM_BLOCK_MOVE( ovpaths, me->virtIPATHs, ovsz ) ;
	}
	sts	= OM_S_SUCCESS ;
	*msg	= MSSUCC ;

	wrapup :
		_FREE( list ) ; _FREE( orpaths ) ; _FREE( ovpaths ) ;

		return sts ;

} /* method VSbuildIPATHs */
/*----------------------------------------------------------------------------*/

end implementation VSdprPart ;
