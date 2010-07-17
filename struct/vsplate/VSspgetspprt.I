/* $Id: VSspgetspprt.I,v 1.1.1.1 2001/01/04 21:10:53 cvs Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        vsplate/VSspgetspprt.I
 *
 * Description: Get the plates support surface
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VSspgetspprt.I,v $
 *      Revision 1.1.1.1  2001/01/04 21:10:53  cvs
 *      Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.2  1998/03/27  22:38:34  pinnacle
# TR179800865
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 03/27/98  ah      TR179800865 Add warning if parent is not found
 *
 ***************************************************************************/

class implementation VSsrcPlate ;

#include "vsmiscmacros.h"
#include "VDbro1.h"

/*
 * Includes of function prototypes.
 */
#include "vsgetinpbynm.h"
/*----------------------------------------------------------------------------*/
method VSgetSupports(	long		*msg ;
			struct GRmd_env	*myEnv ;
			int		*count ;
			VSsuppList	mySupp ) {

	struct GRid	moi ;
	int sts;
	
	*count	= 1 ;

	moi.objid = my_id ;
	moi.osnum = OM_Gw_current_OS ;
	sts = VSgetInputByName( msg, &moi, VS_K_plSuppSurf, &mySupp->_grid,
				 &mySupp->mod_env ) ;

	if (!(sts & *msg & 1)) {

	  // TR179800865
	  printf("Unable to find parent surface for:\n");
	  vdbro$PrintObject(objID = &moi);
	}
	
	return sts;
	
} /* method VSgetSupports */
/*----------------------------------------------------------------------------*/

end implementation VSsrcPlate ;

