
/* $Id: VCTermInit.I,v 1.1.1.1 2001/01/04 21:12:38 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:	vcterm / VCTermInit.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VCTermInit.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:12:38  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/30  10:52:34  pinnacle
# ROUTE 2.5.1
#
# Revision 1.2  1998/03/16  00:55:18  pinnacle
# Replaced: vcterm/VCTermInit.I for:  by kddinov for route
#
# Revision 1.1  1998/02/18  20:12:20  pinnacle
# Created: vcterm/VCTermInit.I by kddinov for route
#
 *
 * History:
 *	MM/DD/YY   AUTHOR	DESCRIPTION
 *
 *************************************************************************/

class implementation VCTerm;

method VCInitInstance (IGRlong *msg)
{
  IGRlong 	status;

  status = om$vla_set_dimension( varray = me->JumpConn,
                                 size   = 0 );

  me->JumpConnType = 0; 				/* unknown data type */


  status = om$vla_set_dimension( varray = me->JumpData,
                                 size   = 0 );
 
  me->JumpDataType = 0;                                 /* unknown data type */


return (  om$send( msg      = message VCRoot.VCInitInstance (msg),
		   mode     = OM_e_wrt_message,
                   targetid = my_id )  );
}


end implementation VCTerm;
