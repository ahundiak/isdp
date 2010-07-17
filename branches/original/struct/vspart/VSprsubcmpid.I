/* $Id $  */
/* --------------------------------------------------------------------
 * I/STRUCT
 *
 * File:               vspart/VSprsubcmpid.I 
 *
 * Description: 
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log $
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      07/05/00        Rama Rao        Header Creation.
 * -------------------------------------------------------------------*/

class implementation VSpart ;

#include <stdio.h>
#include "OMerrordef.h"
#include "msdef.h"
#include "EMSmsgdef.h"
#include "vsmiscmacros.h"
#include "vsipthmacros.h"
#include "vsdbgmacros.h"

extern GRclassid	OPP_VSbooPlate_class_id;

/*----------------------------------------------------------------------------*/
method VSget_sub_cmp_id(	long		*msg ;
				char		*name ;
				struct GRid	*sub_cmp ) {

	long		sts ;	/* OM return code			*/
	VSixPath	vpath,	/* Virtual index path of (sub-)component*/
			rpath ;	/* Real index path of (sub-)component	*/
	struct GRid	myGRid ;
	
	sub_cmp->objid  = NULL_OBJID ;
        myGRid.objid    = my_id ;
        myGRid.osnum    = OM_Gw_current_OS ;

	sts = om$send(	msg	= message VSpart.VStransNameToIPATH(
							msg, name, &vpath ),
			targetid= my_id ) ;
	if( !( sts & 1 & *msg ) ) goto wrapup ;

	/*
	 * We have virtual path, ie. as path should be if graphic object had
	 * not been modified by a boolean operation, if any. Ask self to
	 * find the real path into possibly modified object (if no boolean
	 * operation took place, the real and virtual paths are the same).
	 */
        if( vs$is_ancestry_valid( object  = &myGRid,
                                  classid = OPP_VSbooPlate_class_id ) )
        {
           rpath = vpath ;
        }
        else
        {
	   sts = om$send(	msg	= message VSpart.VSget_sub_cmp_ix(
						 msg,
						 VS_e_virtual_to_real,
						 &rpath,	/* OUT : real */
						 &vpath ),	/* IN  : virt */
			targetid= my_id ) ;
	}

	/*
	 * Conversion virtual -> real may fail if a sub-component was lost.
	 */
	if( !( sts & 1 & *msg ) ) goto wrapup ;
	if( *msg == EMS_I_NoSolution ) {
		*msg = EMS_W_NoSolution ; goto wrapup ;
	}

	sts = vs$getCmpIdFromIpath(	msg		= msg,
					owner		= &myGRid,
					size		= rpath.sz,
					ipath		= rpath.ls,
					component	= sub_cmp ) ;
	__CheckRC( sts, *msg, "vs$getCmpIdFromIpath", wrapup ) ;

	wrapup :
		return sts ;

} /* method VSget_sub_cmp_id */
/*----------------------------------------------------------------------------*/

end implementation VSpart ;
