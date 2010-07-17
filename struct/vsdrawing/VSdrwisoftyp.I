/*
	I/STRUCT
*/
class implementation VSfeature ;

#include <string.h>
#include <stdio.h>
#include <ctype.h>
#include "msdef.h"
#include "grdpbdef.h"
#include "grdpb.h"
#include "gotextdef.h"
#include "fontdef.h"
#include "font.h"
#include "EMSmsgdef.h"
#include "vsslcdef.h"
#include "vsslc.h"
#include "vsdrwdef.h"
#include "vsdrwapi.h"
#include "VSdrwgrammar.h"
#include "vsglobalmsg.h"
#include "vsmiscmacros.h"
#include "vsdbgmacros.h"

/*
 * Includes for function prototypes.
 */
#include "vsdrwproto.h"

extern OMuword OPP_ACncpx_class_id ;
extern OMuword OPP_VSfeature_class_id ;

from ACcpx_defn	import ACgive_name ;
/*----------------------------------------------------------------------------*/
static unsigned long VSgetVStype( elmId ) const struct GRid *elmId ; {

	unsigned long	type = 0 ;

	if( vs$is_ancestry_valid(	object	= elmId,
					classid	= OPP_VSfeature_class_id ) ) {
		long		msg ;
		unsigned long	attr ;

		om$send(msg	= message VSpart.VSgetUserEditableAttr(
							&msg, &type, &attr ),
			senderid= elmId->objid,
			targetid= elmId->objid,
			targetos= elmId->osnum ) ;
	}

	return type ;

} /* VSgetVStype */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_ISOFTYPE( VS, beam ) {

	if( DRW_wantFilter ) strcpy( DRW_elmFilter, "VS*Beam" ) ;

	if( DRW_wantType ) {
		if( VSgetVStype( DRW_elmId ) == VS_m_SRC_BEAM ) {
			DRW_elmType = VS_gI_Beam ;
		} else {
			DRW_elmType = 0 ;
		}
	}
	if( DRW_wantView ) {
	  long msg ;
	  if( !( 1 & VSdrwGetViewTypeFromBeam( &msg, inp, xData ) ) )
	    DRW_elmView = VSunknownViewType ;
	}

} /* ISOFTYPE( beam ) */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_ISOFTYPE( VS, stiffener ) {

	if( DRW_wantFilter ) strcpy( DRW_elmFilter, "VS*Beam" ) ;

	if( DRW_wantType ) {
		if( VSgetVStype( DRW_elmId ) == VS_m_STF_BEAM ) {
			DRW_elmType = VS_gI_Stiffener ;
		} else {
			DRW_elmType = 0 ;
		}
	}
	if( DRW_wantView ) {
	  long msg ;
	  if( !( 1 & VSdrwGetViewTypeFromBeam( &msg, inp, xData ) ) )
	    DRW_elmView = VSunknownViewType ;
	}

} /* ISOFTYPE( stiffener ) */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_ISOFTYPE( VS, plate ) {

	if( DRW_wantFilter ) strcpy( DRW_elmFilter, "VS*Plate" ) ;

	if( DRW_wantType ) {
		if( VSgetVStype( DRW_elmId ) == VS_m_SRC_PLATE ) {
			DRW_elmType = VS_gI_Plate ;
		} else {
			DRW_elmType = 0 ;
		}
	}
	if( DRW_wantView ) {
	  long msg ;
	  if( !( 1 & VSdrwGetViewTypeFromPlate( &msg, inp, xData ) ) )
	    DRW_elmView = VSunknownViewType ;
	}

} /* ISOFTYPE( plate ) */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_ISOFTYPE( VS, joint ) {

	if( DRW_wantFilter ) strcpy( DRW_elmFilter, "VS*Joint" ) ;

	if( DRW_wantType ) {
		if( VSgetVStype( DRW_elmId ) == VS_m_SRC_JOINT ) {
			DRW_elmType = VS_gI_Joint ;
		} else {
			DRW_elmType = 0 ;
		}
	}
	if( DRW_wantView ) {
	  long msg ;
	  if( !( 1 & VSdrwGetViewTypeFromJoint( &msg, inp, xData ) ) )
	    DRW_elmView = VSunknownViewType ;
	}

} /* ISOFTYPE( joint ) */
/*----------------------------------------------------------------------------*/
/*ARGSUSED*/
#argsused
IMPLEMENT_ISOFTYPE( VS, const ) {

	/*
	 * Do not set filter here, it is read from the 'const' statement.
	 */

	if( DRW_wantType ) {
	  DRW_elmType = 0 ;

	  if( vs$is_ancestry_valid(	object	= DRW_elmId,
					classid	= OPP_ACncpx_class_id ) ) {
		long		sts ;
		struct GRid	macroDef ;
		char		*macName ;

		/*
		 * Since it's a const, get the macro definition name.
		 */
		sts = om$send(	msg	= message ACcpx.find_macro( &macroDef ),
				senderid= DRW_elmId->objid,
				targetid= DRW_elmId->objid,
				targetos= DRW_elmId->osnum ) ;
		__CheckRC( sts, 1, "ACcpx.find_macro", wrapup ) ;

		sts = om$send(	msg	= message ACcpx_defn.ACgive_name(
								&macName ),
				senderid= macroDef.objid,
				targetid= macroDef.objid,
				targetos= macroDef.osnum ) ;
		__CheckRC( sts, 1, " ACcpx_defn.ACgive_name", wrapup ) ;

		strcpy( inp->constDefName, macName ) ;
		DRW_elmType = VS_gI_InAsbly ;
	  }
	}

	if( DRW_wantView ) {
	  long msg ;
	  if( !( 1 & VSdrwGetViewTypeFromConst( &msg, inp, xData ) ) )
	    DRW_elmView = VSunknownViewType ;
	}

	wrapup: ;

} /* ISOFTYPE( const ) */
/*----------------------------------------------------------------------------*/

end implementation VSfeature ;
