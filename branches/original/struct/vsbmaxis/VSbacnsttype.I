/* $Id: VSbacnsttype.I,v 1.2 2001/11/16 14:24:33 ahundiak Exp $  */

/***************************************************************************
 * I/STRUCT
 *
 * File:        vsbmaxis/VSbacnsttype.I
 *
 * Description: Determines if parent 1 is a curve or surface
 *
 * Dependencies:
 *
 * Revision History:
 * $Log: VSbacnsttype.I,v $
 * Revision 1.2  2001/11/16 14:24:33  ahundiak
 * ah
 *
 * Revision 1.1.1.1  2001/01/04 21:10:13  cvs
 * Initial import to CVS
 *
# Revision 1.1  1998/04/30  10:08:06  pinnacle
# STRUCT 2.5.1
#
# Revision 1.2  1998/04/24  15:27:10  pinnacle
# TR179801025
#
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 04/24/98  ah      TR179801025 Add warning if parent is not found
 * 11/15/01  ah      By popular demand, suppress warnings by default
 ***************************************************************************/

class implementation VSbeamAxis ;

#include <stdio.h>
#include "nddef.h"
#include "vsmiscmacros.h"
#include "vsbmaxisdef.h"
#include "vsdbgmacros.h"

#include "VDobj.h"

extern OMuword OPP_EMSsubbs_class_id ;

/*----------------------------------------------------------------------------*/
method VSgetConstructionType( long	*msg ;
			      int	*p_ctype ; ) {

	long		sts ;
	int		count ;
	short		mat_type ;
	double		matrix[16] ;
	struct GRid	ASparent,
			GRparent ;

	*msg = MSSUCC ;

	/*
	 * Retrieve parent #1.
	 */
	sts = om$send( msg	= message NDnode.NDget_objects( ND_ROOT,
								&ASparent,
								1,
								NULL,
								1,
								1,
								&count ),
		       targetid = my_id ) ;
	if( !(sts & 1) ) *msg = MSFAIL ;
	__CheckRC( sts, *msg, "NDnode.NDget_objects", wrapup ) ;

	/*
	 * Retrieve graphic object of parent #1.
	 */
	sts = om$send( msg	= message NDnode.ASreturn_go( &GRparent,
							      &mat_type,
							      matrix ),
		       targetid = ASparent.objid,
		       targetos = ASparent.osnum ) ;
	if( !(sts & 1) ) *msg = MSFAIL ;
	__CheckRC( sts, *msg, "NDnode.ASreturn_go", wrapup ) ;

	/*
	 * See if parent #1 is a curve or a surface.
	 */
	if( vs$is_ancestry_valid( object  = &GRparent,
				  classid = OPP_EMSsubbs_class_id ) ) {
		*p_ctype = VS_K_baIntersection ;
	} else {
		*p_ctype = VS_K_baProjection ;
	}

	*msg = MSSUCC ;

	wrapup :

	  // TR179801025
	  if (!(sts & 1)) {

	    if (VDwarnGetStruct2ndParentIsMissing()) {
	      
	      TGRid myID;
	    
	      myID.objid = my_id ;
	      myID.osnum = OM_Gw_current_OS ;

	      printf("Warning: 2nd Parent Not Found For:\n");
	      vdobj$Print(objID = &myID);
	      
	    }
	  }
	
		return sts ;

} /* method VSgetConstructionType */
/*----------------------------------------------------------------------------*/

end implementation VSbeamAxis ;
